# iOS Migration: Subscription to AWS AppSync Events Protocol

## Why

The iOS app currently uses a custom GraphQL WebSocket implementation for real-time device state notifications. The backend is migrating to AWS AppSync Events to:

1. **Prepare for notification features**: Enable future in-app alarm notifications to mobile and desktop
2. **Decouple from GraphQL**: Remove dependency on custom GraphQL subscription implementation
3. **Improve authorization**: Move to channel-level authorization with Lambda authorizer
4. **Reduce complexity**: Use native WebSocket API with a simpler protocol

**Current iOS Implementation**:
- Custom GraphQL WebSocket in `GraphQLSubscriber.swift`
- Backend handles all permission filtering server-side
- Receives only authorized device events

**Target Architecture**:
- Native `URLSessionWebSocketTask` with AppSync Events protocol
- Client-side filtering by device group permissions
- Organization-level channels: receives all org events, filters locally

## What Changes

### 1. Implement AppSync Events Client

Create a new `AppSyncEventsClient` to replace the existing GraphQL subscription implementation.

**WebSocket Protocol Implementation**:
- Endpoint: `wss://{domain}.appsync-realtime-api.{region}.amazonaws.com/event/realtime`
- Use `URLSessionWebSocketTask` (already in use by current implementation)
- Implement AppSync Events message protocol:
  - `connection_init` → `connection_ack`
  - `subscribe` → `subscribe_success`
  - `data` (server push)
  - `ka` (keep-alive, 60s interval)

**Authentication**:
- JWT Bearer token in WebSocket subprotocol header
- Base64URL encoding: `["aws-appsync-event-ws", "header-{encodedAuth}"]`
- Reuse existing Cognito JWT from `vortexAuthService`

**Connection Management**:
- Maximum connection duration: 24 hours
- Reconnection strategy: **10 seconds fixed delay** (matching current `BackendSubscriber` implementation)
- Only reconnect on non-normal close (code ≠ 1000)
- Check user sign-in status before reconnecting

### 2. Update BackendNotifier

Modify `BackendNotifier.swift` to support AppSync Events subscriptions.

**New Method**:
```swift
func deviceValuesAppSync() async -> AsyncStream<DeviceStateEvent>
```

**Interface Compatibility**:
- Maintain existing `AsyncStream` interface for consumers
- No changes required for code using `BackendNotifier`

### 3. Implement Client-Side Filtering

**Background**:
- Current system: Backend filters events by device group permissions
- AppSync Events: iOS receives **all organization device events**, must filter locally

**Solution**: Introduce `DeviceEventFilter` protocol to decouple filtering logic

```swift
protocol DeviceEventFilter {
    func canAccessDevice(deviceGroupID: String) -> Bool
}
```

**Implementation**:
- Inject `DeviceEventFilter` into `BackendNotifier` or subscription handler
- Current implementation: use `FeatureToggle` with `privilegeProvider`
- Future-proof: easy to replace with alternative permission checking mechanism
- Filter events silently (discard unauthorized events without logging)

**Channels Requiring Filtering**:
- `/devices/{orgId}` - Filter by device group permissions
- `/archives/{orgId}` - Filter by device group permissions (if needed)
- `/organizations/{orgId}` - No filtering (all org members receive)
- `/privileges/{userId}` - No filtering (user-specific channel)

### 4. Channel Subscription

Subscribe to the following AppSync Events channels:

| Current GraphQL Subscription | AppSync Events Channel | Filtering |
|------------------------------|------------------------|-----------|
| `subscribeDeviceState` | `/devices/{orgId}` | Client-side by device group |
| `subscribeArchiveState` | `/archives/{orgId}` | Client-side by device group |
| `subscribeOrganizationState` | `/organizations/{orgId}` | None |
| `subscribeRoleChange` | `/privileges/{userId}` | None |
| `subscribeUserTokenRevoke` | `/privileges/{userId}` | None |

### 5. Message Format

AppSync Events wraps payloads in a standard envelope:

```json
{
  "type": "data",
  "id": "<subscription-id>",
  "event": ["<JSON-stringified-payload>"]
}
```

**Inner Payload**: Unchanged from current GraphQL subscription format
- `DeviceStateOutput`: `{ mac, derivant, online, recording, fwUpdateState, thingName, deviceGroupID }`
- No changes required to existing payload parsing logic

### 6. Remove GraphQL Subscription Code

After successful migration and testing:

- Remove `GraphQLSubscriber.swift`
- Remove `GraphQLSubscription.swift`
- Update `VortexFactoryProvider.swift` to remove GraphQL subscription factory methods
- Clean up unused WebSocket connection code

## Impact

### Code Changes

**New Files**:
- `AppSyncEventsClient.swift` - WebSocket client implementing AppSync Events protocol
- `DeviceEventFilter.swift` - Protocol for permission-based event filtering

**Modified Files**:
- `BackendNotifier.swift` - Add AppSync Events subscription methods
- `VortexFactoryProvider.swift` - Add factory for AppSync Events client (remove old GraphQL factories post-migration)

**Removed Files** (post-migration):
- `GraphQLSubscriber.swift`
- `GraphQLSubscription.swift`
- Related GraphQL WebSocket implementation files

### Configuration

**Endpoint Configuration**:
- Add AppSync Events API endpoint URL to environment configuration
- Domain and region parameters for WebSocket URL construction

**No Feature Flags Required**:
- Dev site will fully migrate to AppSync Events
- Production migration follows after dev site validation

### Testing Requirements

**Existing Tests**:
- All current subscription-related unit tests must pass with new implementation
- Maintain test coverage for device state updates, reconnection, and lifecycle management

**New Tests**:
- `AppSyncEventsClient`: Message encode/decode, connection lifecycle, reconnection logic
- `DeviceEventFilter`: Permission-based filtering with mock permissions
- Auth header encoding (base64URL)
- WebSocket protocol handshake (init, ack, subscribe, data)
- Channel subscription for all event types
- Event filtering scenarios (authorized vs unauthorized devices)

**Testing Strategy**:
- Unit tests: Protocol implementation, filtering logic
- Integration tests: Connect to staging backend, receive and filter events
- Manual testing: Various scenarios (network interruption, app lifecycle, permission changes)

### Dependencies

- No new external dependencies required
- Uses native `URLSessionWebSocketTask`
- Uses existing `vortexAuthService` for JWT tokens

### Migration Path

1. **Development**: Implement AppSync Events client in parallel with existing GraphQL implementation
2. **Dev Site Testing**: Deploy to dev site, full migration to AppSync Events
3. **Validation**: Testing team validates all subscription functionality
4. **Staging**: Deploy to staging environment
5. **Production**: Gradual rollout after successful staging validation
6. **Cleanup**: Remove GraphQL subscription code after stable production operation

## Success Criteria

1. **Functional Parity**: All device state updates, archive notifications, and privilege events work identically to current implementation
2. **Performance**: Event delivery latency remains sub-second (P99)
3. **Reliability**: Reconnection works reliably after network disruption
4. **Testing**: All existing tests pass, new tests achieve comprehensive coverage
5. **No Regressions**: No increase in crash rates or subscription-related bugs
6. **Permission Filtering**: Users only see events for devices they have access to (client-side filtering works correctly)

## References

- High-level spec: `/Users/ryanchen/code/AI/agentic-development-alignment-taskforce/docs/openspec/changes/switch-to-appsync-events/`
- AWS AppSync Events WebSocket Protocol: https://docs.aws.amazon.com/appsync/latest/eventapi/event-api-websocket-protocol.html
- Current implementation: `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/`
