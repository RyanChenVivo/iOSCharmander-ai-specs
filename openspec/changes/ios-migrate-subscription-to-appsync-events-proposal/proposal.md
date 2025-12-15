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
- AWS AppSync Events SDK for WebSocket subscriptions
- Client-side filtering by site permissions (`siteId`)
- Organization-level channels: receives all org events, filters locally
- Single WebSocket connection with multiple channel subscriptions

## What Changes

### 1. Implement AppSync Events SDK Wrapper

**Architecture Pattern**: Follow existing `AWSServices` wrapper pattern (similar to `AWSIoT/AWSMqttClient`)

Create new components under `VortexFeatures/Sources/AWSServices/AWSAppSyncEvents/`:

**AppSyncEventsClientProtocol**:
- Define unified interface for AppSync Events operations
- Methods: `connect()`, `subscribe(channels:)`, `unsubscribe()`, `disconnect()`
- Return AsyncStream for event delivery
- Conform to Sendable protocol

**AppSyncEventsClient** (Actor):
- Implement AppSyncEventsClientProtocol using AWS SDK
- Manage single WebSocket connection lifecycle
- Subscribe to multiple channels on one connection
- Use AppSyncEventsClientWrapper to isolate SDK dependency
- Handle error mapping to VortexError (reuse existing error types)

**AppSyncEventsClientWrapper**:
- Wrap AWS AppSync Events SDK (`AWSAppSyncEvents` package)
- Isolate SDK-specific code to this layer only
- Transform SDK errors to domain errors

**AppSyncEventTypes**:
- Define 6 channel types matching Apidog schema
- Map channel names to event types
- Validate against Apidog OpenAPI schemas

**Connection Management**:
- Maximum connection duration: 24 hours
- Reconnection strategy: **10 seconds fixed delay** (matching current `BackendSubscriber`)
- Only reconnect on non-normal close
- Check user sign-in status before reconnecting
- Reuse existing Cognito JWT from `vortexAuthService`

### 1.1. Schema Synchronization with Apidog MCP

**Purpose**: Ensure iOS event type definitions remain synchronized with backend API contracts.

**Apidog as Source of Truth**:
- Apidog OpenAPI schemas are the authoritative source
- Backend must update Apidog before changing implementation
- If backend changes without updating Apidog, it's a backend bug

**Implementation** (manual validation during development):
- Use Apidog MCP server to fetch authoritative OpenAPI schema definitions
- Validate Swift event types against Apidog schemas before implementation
- Check format correctness, channel names, and field definitions

**Workflow**:
1. Fetch latest schemas from Apidog MCP
2. Compare with existing Swift event type definitions
3. Identify schema drift (missing fields, type mismatches, new event types)
4. Update Swift structs to match authoritative schemas
5. Re-validate before committing changes

**Note**: This is a manual development-time validation, not automated CI/CD. Future schema changes from backend will come as new requirements.

### 2. Extend BackendSubscriber

Create new subscription layer under `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/`:

**AppSyncEventsSubscriber** (Protocol):
- Define interface for AppSync Events subscription
- Similar to existing `GraphQLSubscriber` protocol
- Methods: `subscribe(channels:)`, `unsubscribe()`
- Return AsyncStream for event delivery

**AppSyncEventsSubscription** (Protocol):
- Define channel subscription metadata
- Properties: `channelName`, `eventType`
- Similar to existing `GraphQLSubscription` protocol

**Subscription Implementations**:
- DevicePresenceSubscription
- DeviceRecordingSubscription
- DeviceFirmwareSubscription
- ArchiveStateEventsSubscription
- RoleChangeEventsSubscription
- UserTokenRevokeEventsSubscription

**EventFilter** (Protocol):
- Define client-side event filtering interface
- Method: `canAccessSite(siteId:) -> Bool`
- Implementation uses existing `FeatureToggle.privilegeProvider`
- Query privileges on every event (no caching)
- Permission changes handled by existing app refresh logic

### 2.1. Update BackendNotifier

**Add new methods** to `BackendNotifier.swift` (existing methods remain unchanged):

**New AppSync Events Methods**:
```swift
func deviceValuesAppSync() async -> AsyncStream<DeviceStateOutput>
func archiveValuesAppSync() async -> AsyncStream<ArchiveStateOutput>
func roleValuesAppSync() async -> AsyncStream<RoleChangeOutput>
func organizationValuesAppSync() async -> AsyncStream<OrganizationStateOutput>
func revokeValuesAppSync() async -> AsyncStream<UserTokenRevokeOutput>
```

**Existing GraphQL Methods** (unchanged):
```swift
func deviceValues() async -> AsyncStream<DeviceStateOutput>
func archiveValues() async -> AsyncStream<ArchiveStateOutput>
// ... other existing methods
```

**Interface Compatibility**:
- Maintain existing `AsyncStream` interface
- Reuse existing Output models (DeviceStateOutput, etc.)
- No breaking changes to existing consumers
- Subscription timing follows existing logic (subscribe when BackendNotifier subscribes)

**Migration approach**:
- Replace all `deviceValues()` calls with `deviceValuesAppSync()` in codebase
- Do not change when/where subscriptions happen
- Only change the underlying implementation

### 3. Implement Client-Side Filtering

**Background**:
- Current system: Backend filters events by device group permissions
- AppSync Events: iOS receives **all organization device events**, must filter locally by `siteId`

**Solution**: Introduce `DeviceEventFilter` protocol to decouple filtering logic

```swift
protocol DeviceEventFilter {
    func canAccessSite(siteId: String) -> Bool
}
```

**Implementation**:
- Inject `DeviceEventFilter` into `BackendNotifier` or subscription handler
- Current implementation: use `FeatureToggle` with `privilegeProvider`
- Future-proof: easy to replace with alternative permission checking mechanism
- Filter events silently (discard unauthorized events without logging)
- **Note**: Field name changed from `deviceGroupID` to `siteId` per Apidog schema

**Channels Requiring Filtering**:
- `/organization/{orgId}/device/presenceChanged` - Filter by `siteId`
- `/organization/{orgId}/device/recordingStateChanged` - Filter by `siteId`
- `/organization/{orgId}/device/firmwareUpdated` - Filter by `siteId`
- `/organization/{orgId}/archive/stateChanged` - Filter by `siteId`
- `/user/{userId}/roleChanged` - No filtering (user-specific channel)
- `/user/{userId}/tokenRevoked` - No filtering (user-specific channel)

### 4. Channel Subscription

**Schema Validation**: All channel definitions and event types are validated against Apidog OpenAPI schemas to ensure consistency with backend API contracts.

Subscribe to the following AppSync Events channels (6 channels total):

| Current GraphQL Subscription | AppSync Events Channel | Event Type | Filtering |
|------------------------------|------------------------|------------|-----------|
| `subscribeDeviceState` (online) | `/organization/{orgId}/device/presenceChanged` | `device/presenceChanged` | Client-side by `siteId` |
| `subscribeDeviceState` (recording) | `/organization/{orgId}/device/recordingStateChanged` | `device/recordingStateChanged` | Client-side by `siteId` |
| `subscribeDeviceState` (firmware) | `/organization/{orgId}/device/firmwareUpdated` | `device/firmwareUpdated` | Client-side by `siteId` |
| `subscribeArchiveState` | `/organization/{orgId}/archive/stateChanged` | `archive/stateChanged` | Client-side by `siteId` |
| `subscribeRoleChange` | `/user/{userId}/roleChanged` | `user/roleChanged` | None |
| `subscribeUserTokenRevoke` | `/user/{userId}/tokenRevoked` | `user/tokenRevoked` | None |

**Note**: The single GraphQL `subscribeDeviceState` subscription is split into 3 separate AppSync Events channels based on event type (presence, recording, firmware).

### 5. Message Format

**Schema Source**: All event payload schemas are sourced from Apidog OpenAPI definitions and validated via MCP integration.

AppSync Events wraps payloads in a standard envelope:

```json
{
  "type": "data",
  "id": "<subscription-id>",
  "event": ["<JSON-stringified-payload>"]
}
```

**Event Payload Schema Changes**:

All events now include these **required** fields (per Apidog schema):
- **`eventType`** (string): Event type identifier for routing (e.g., `"device/presenceChanged"`)
- **`timestamp`** (string, ISO 8601): Event occurrence timestamp

Most events also include these **optional** fields:
- **`orgId`** (string | null): Organization identifier
- **`siteId`** (string | null): Site/device group identifier (used for client-side filtering)
- **`thingName`** (string | null): AWS IoT thing name (device identifier)
- **`derivant`** (string | null): Device model identifier
- **`mac`** (string | null): Device MAC address

**Event-Specific Fields** (validated against Apidog schemas):
- `device/presenceChanged`: `online` (boolean)
- `device/recordingStateChanged`: `recording` (boolean)
- `device/firmwareUpdated`: `fwUpdateState` (integer, -1 to 14)
- `archive/stateChanged`: `status` (enum), `videoLength`, `videoSize`, `cloudSize`, `hasH265`, `createdAt`
- `user/roleChanged`: `reason` (string)
- `user/tokenRevoked`: `userId` (required), `revokedAt` (required), `reason` (enum), `requestId`

**Note**: Field name changed from `deviceGroupID` to `siteId` per Apidog schema. All Swift event type definitions in `VortexEventTypes.swift` must match Apidog schemas.

### 6. Coexistence Strategy

**Code-level coexistence** (not runtime coexistence):

**Keep Existing GraphQL Code** (for gradual code migration):
- Retain `GraphQLSubscriber.swift`
- Retain `GraphQLSubscription.swift`
- Retain `BackendNotifier.deviceValues()` and other GraphQL methods
- Keep existing factory methods in `VortexFactoryProvider.swift`

**Add New AppSync Events Code**:
- New `AppSyncEventsSubscriber.swift`
- New `AppSyncEventsSubscription.swift`
- New `BackendNotifier.deviceValuesAppSync()` and other AppSync methods
- New factory methods for AppSync Events client

**Migration Strategy** (one-time cutover):
- **IMPORTANT**: At runtime, only ONE implementation will be active (either GraphQL OR AppSync Events)
- During code migration: Replace all `deviceValues()` calls with `deviceValuesAppSync()` calls
- After migration: Verify no code uses old GraphQL methods
- Future cleanup: Remove GraphQL code entirely after successful migration

**Not Supported**:
- Running both GraphQL and AppSync Events simultaneously
- Gradual feature-by-feature migration
- Mixed usage of old and new methods

## Impact

### Code Changes

**New Directory Structure**:
```
VortexFeatures/Sources/
├── AWSServices/
│   └── AWSAppSyncEvents/                    📁 NEW
│       ├── AppSyncEventsClientProtocol.swift
│       ├── AppSyncEventsClient.swift
│       ├── AppSyncEventsClientWrapper.swift
│       └── AppSyncEventTypes.swift
│
└── VortexFeatures/Common/VortexBackend/
    ├── BackendSubscriber/
    │   ├── AppSyncEventsSubscriber.swift    📄 NEW
    │   ├── AppSyncEventsSubscription.swift  📄 NEW
    │   └── EventFilter.swift                📄 NEW
    │
    └── BackendNotifier/
        ├── BackendNotifier.swift            ✏️ MODIFIED (add new methods)
        └── BackendNotifierProtocol.swift    ✏️ MODIFIED (optional)
```

**New Files - AWSServices Layer** (following AWSMqttClient pattern):
- `AppSyncEventsClientProtocol.swift` - Protocol defining AppSync Events client interface
- `AppSyncEventsClient.swift` - Actor implementing protocol with AWS SDK
- `AppSyncEventsClientWrapper.swift` - Wrapper isolating AWS SDK dependency
- `AppSyncEventTypes.swift` - Channel and event type definitions

**New Files - BackendSubscriber Layer**:
- `AppSyncEventsSubscriber.swift` - Subscription interface and implementation
- `AppSyncEventsSubscription.swift` - 6 subscription type definitions
- `EventFilter.swift` - Client-side filtering protocol and implementation

**Modified Files**:
- `BackendNotifier.swift` - Add new AppSync Events methods (existing methods unchanged)
- `VortexFactoryProvider.swift` - Add factory methods for AppSync Events client
- **Output Models** (e.g., `DeviceStateOutput`, `ArchiveStateOutput`):
  - Replace `deviceGroupID` with `siteId`
  - Add `eventType` field (String)
  - Add `timestamp` field (String, ISO 8601)
  - These models are shared - changes affect both GraphQL and AppSync implementations

**Unchanged Files** (coexistence):
- `GraphQLSubscriber.swift` - Kept for gradual migration
- `GraphQLSubscription.swift` - Kept for existing features
- Existing `BackendNotifier` methods - Continue working alongside new methods

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
- **AWSServices Layer**:
  - `AppSyncEventsClient`: Connection lifecycle, error mapping, reconnection logic
  - `AppSyncEventsClientWrapper`: SDK isolation, error transformation
  - Protocol conformance tests
- **BackendSubscriber Layer**:
  - `AppSyncEventsSubscriber`: Subscription flow, event parsing
  - `EventFilter`: Permission-based filtering with mock privileges using `siteId`
  - 6 subscription type implementations
- **Integration Tests**:
  - Channel subscription for all 6 event types
  - Event routing based on `eventType` field
  - Event filtering scenarios (authorized vs unauthorized sites)
  - Multiple concurrent channel subscriptions

**Testing Strategy**:
- Unit tests: Protocol implementation, filtering logic
- Integration tests: Connect to staging backend, receive and filter events
- Manual testing: Various scenarios (network interruption, app lifecycle, permission changes)

### Dependencies

**Runtime Dependencies**:
- **AWS AppSync Events SDK** (new): AWS official Swift SDK for AppSync Events
  - Package: `AWSAppSyncEvents` via Swift Package Manager
  - Wrapped in `AppSyncEventsClientWrapper` to isolate dependency
- **Existing Dependencies**:
  - `vortexAuthService` for JWT tokens
  - `VortexLogger` for logging
  - `Dependencies` package for dependency injection
  - Existing `FeatureToggle.privilegeProvider` for permissions

**Development Dependencies**:
- **Apidog MCP Server**: Schema validation and synchronization
  - Used for fetching authoritative OpenAPI schemas
  - Validates Swift event types against backend contracts
  - Project ID: 626117

### Migration Path

**Phase 0: Preparation**
- Install AWS AppSync Events SDK via Swift Package Manager
- Configure Apidog MCP for schema validation
- Set up testing environment with dev backend

**Phase 1: AWSServices Layer Implementation**
- Create `AWSServices/AWSAppSyncEvents/` directory structure
- Implement Protocol, Actor, Wrapper following AWSMqttClient pattern
- Write unit tests for AWSServices layer
- Validate SDK wrapper isolation

**Phase 2: BackendSubscriber Extension**
- Implement AppSyncEventsSubscriber protocol and implementations
- Create 6 subscription type definitions
- Implement EventFilter for client-side filtering
- Write unit tests for subscription layer

**Phase 3: BackendNotifier Integration**
- Add new AppSync Events methods to BackendNotifier
- Keep existing GraphQL methods unchanged
- Update VortexFactoryProvider with new factory methods
- Write integration tests

**Phase 4: Schema Validation**
- Validate all event types against Apidog schemas
- Ensure field mappings are correct (`deviceGroupID` → `siteId`)
- Update Output models if needed
- Run schema validation tests

**Phase 5: Code Migration**
- **Replace all** `deviceValues()` calls with `deviceValuesAppSync()` calls
- Update all calling code to use new methods
- Update all tests to use new methods
- Verify no usage of old GraphQL methods remains

**Phase 6: Dev Environment Testing**
- Deploy to dev environment with AppSync Events only
- Test all 6 channels concurrently
- Validate event filtering by `siteId`
- Test reconnection and error scenarios
- Monitor performance and stability

**Phase 7: Production Migration**
- Staging environment validation with AppSync Events
- Deploy to production (one-time cutover)
- Monitor metrics and error rates
- Rollback plan: Revert to GraphQL if critical issues

**Phase 8: Cleanup (Future)**
- After stable production operation (suggested: 2-4 weeks)
- Remove GraphQL subscription code (`GraphQLSubscriber.swift`, `GraphQLSubscription.swift`)
- Remove old `BackendNotifier` methods (`deviceValues()`, etc.)
- Clean up factory methods in `VortexFactoryProvider.swift`
- Update documentation

## Success Criteria

1. **Architecture Compliance**:
   - Follows AWSServices wrapper pattern (Protocol + Actor + Wrapper)
   - SDK dependency isolated to wrapper layer only
   - Uses Dependencies package for dependency injection
   - Actor isolation ensures thread-safety

2. **Functional Parity**:
   - All 6 AppSync Events channels working correctly
   - Event delivery matches GraphQL subscription behavior
   - Client-side filtering by `siteId` works correctly
   - Reconnection handles network disruption reliably

3. **Code Migration**:
   - All usage of old GraphQL methods replaced with AppSync Events methods
   - No code calls `deviceValues()`, only `deviceValuesAppSync()`
   - Existing tests updated to use new methods
   - Code compiles without breaking changes during transition

4. **Schema Consistency**:
   - All event types validated against Apidog schemas (manual validation)
   - Field mappings correct (`deviceGroupID` → `siteId`)
   - Zero schema drift detected
   - Event types include `eventType` and `timestamp` fields

5. **Testing**:
   - Unit tests for all new components
   - Integration tests for 6-channel subscription
   - Coexistence tests (GraphQL + AppSync running together)
   - Performance tests validate <1s latency (P99)

6. **Production Readiness**:
   - No increase in crash rates
   - Memory usage within acceptable limits
   - Error handling comprehensive
   - Logging consistent with VortexLogger patterns

## References

- **Backend OpenAPI Schemas**: Apidog Project 626117 (accessed via MCP)
  - Schema validation: Use Apidog MCP server configured in project
  - Event type definitions: `DevicePresenceChanged`, `DeviceRecordingStateChanged`, `DeviceFirmwareUpdated`, `ArchiveStateChanged`, `RoleChanged`, `UserTokenRevoked`
- **AWS AppSync Events WebSocket Protocol**: https://docs.aws.amazon.com/appsync/latest/eventapi/event-api-websocket-protocol.html
- **Current implementation**: `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/`
- **Demo project** (reference only): `/Users/ryanchen/code/SwiftPractice/appsync-event`
  - Learning project demonstrating AWS SDK usage
  - Not intended for direct code reuse in production
  - Use as reference for SDK API patterns
