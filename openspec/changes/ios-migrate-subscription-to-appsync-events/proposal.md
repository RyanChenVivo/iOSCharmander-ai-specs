# iOS Migration: GraphQL Subscriptions to AWS AppSync Events

## Why

The iOS app currently uses a custom GraphQL WebSocket implementation for real-time device state notifications. The backend is migrating to AWS AppSync Events to:

1. **Prepare for notification features**: Enable future in-app alarm notifications to mobile and desktop
2. **Decouple from GraphQL**: Remove dependency on custom GraphQL subscription implementation
3. **Improve authorization**: Move to channel-level authorization with Lambda authorizer
4. **Reduce complexity**: Use native WebSocket API with a simpler protocol
5. **Align with backend infrastructure**: Follow the backend team's migration to AppSync Events (see `/Users/ryanchen/code/AI/agentic-development-alignment-taskforce/docs/openspec/changes/switch-to-appsync-events`)

**Current iOS Implementation**:
- Custom GraphQL WebSocket in `GraphQLSubscriber.swift` (VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/)
- Backend handles all permission filtering server-side
- Receives only authorized device events via `BackendNotifier.swift`

**Target Architecture**:
- AWS AppSync Events SDK for WebSocket subscriptions
- **User-level channels**: Backend publishes to each user's channel separately (`vortex-app/user/{userId}/*`)
- **NO client-side filtering needed**: Backend handles all authorization server-side
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
- Implement AppSyncEventsClientProtocol using AWS AppSync Events Swift SDK
- Use `AppSyncEventBridgeClient` from `https://github.com/aws-amplify/aws-appsync-events-swift`
- Manage single WebSocket connection lifecycle
- Subscribe to multiple channels on one connection
- Use AppSyncEventsClientWrapper to isolate SDK dependency
- Handle error mapping to VortexError (reuse existing error types)

**AppSyncEventsClientWrapper**:
- Wrap AWS AppSync Events Swift SDK (`aws-appsync-events-swift` package)
- Use SDK's `AppSyncEventBridgeClient` for connection and subscription management
- Isolate SDK-specific code to this layer only
- Transform SDK errors to domain errors

**AppSyncEventTypes**:
- Define 9 channel types matching latest OpenAPI schema
- Map channel names to event types
- Validate against Apidog OpenAPI schemas

**Connection Management**:
- Maximum connection duration: 24 hours
- Reconnection strategy: **10 seconds fixed delay** (matching current `BackendSubscriber`)
- Only reconnect on non-normal close
- Check user sign-in status before reconnecting
- Reuse existing Cognito JWT from `vortexAuthService`

### 2. Schema Synchronization with Latest OpenAPI

**Source of Truth**: Backend OpenAPI schema from `/Users/ryanchen/code/AI/agentic-development-alignment-taskforce/docs/openspec/changes/switch-to-appsync-events/openapi-schemas.yaml`

**Key Schema Updates**:
- Backend uses **user-level channels only**: `vortex-app/user/{userId}/*` pattern
- Backend has split `subscribeOrganizationState` into 3 separate channels
- Total channels: **9 channels** (all user-level)
- **Backend handles all filtering**: iOS receives only authorized events

**Implementation** (manual validation during development):
- Use latest OpenAPI schema to validate Swift event types
- Check format correctness, channel names, and field definitions
- Ensure iOS implementation matches backend contract

### 3. Add AppSync Events Subscriber (GraphQL Code Remains)

**Keep Existing GraphQL Code** - no deletions:
- **Keep** `GraphQLSubscriber` protocol and implementation
- **Keep** `GraphQLSubscription` protocol and implementations
- **Keep** GraphQL factory methods in `VortexFactoryProvider`
- **Keep** WebSocket implementation files

**Add New AppSync Events Code** - parallel implementation:

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

**Subscription Implementations** (using wildcard patterns for efficiency):
1. `.deviceWildcard` → `vortex-app/user/{userId}/device/*`
   - Receives: `presenceChanged`, `recordingStateChanged`, `firmwareUpdated`
2. `.organizationWildcard` → `vortex-app/user/{userId}/organization/*`
   - Receives: `licensePhaseChanged`, `planChanged`, `aiSettingsChanged`
3. `.archiveState` → `vortex-app/user/{userId}/archive/stateChanged`
4. `.roleChange` → `vortex-app/user/{userId}/roleChanged`
5. `.tokenRevoke` → `vortex-app/user/{userId}/tokenRevoked`

**Individual channel definitions** (for reference, but wildcards used in practice):
- Device: `presenceChanged`, `recordingStateChanged`, `firmwareUpdated`
- Organization: `licensePhaseChanged`, `planChanged`, `aiSettingsChanged`

**NO EventFilter Needed**:
- Backend publishes to each user's channel separately
- iOS receives only authorized events (no client-side filtering required)
- Authorization enforced by AppSync custom authorizer (validates userId match)

### 4. Update BackendNotifier with Wildcard Channel Subscriptions

**NO Breaking Changes** - Preserve existing API using wildcard pattern subscriptions:

**Existing Methods** (interface unchanged):
```swift
// Device events - SAME interface, internal implementation changed
func deviceValues() async -> AsyncStream<DeviceStateOutput>

// Archive events - SAME interface
func archiveValues() async -> AsyncStream<ArchiveStateOutput>

// Organization events - SAME interface, internal implementation changed
func organizationValues() async -> AsyncStream<OrganizationStateOutput>

// User events - SAME interface
func roleValues() async -> AsyncStream<RoleChangeOutput>
func revokeValues() async -> AsyncStream<UserTokenRevokeOutput>
```

**Key Changes**:
- ✅ **NO API changes** - all existing methods preserved
- ✅ **Wildcard subscriptions**: Use `device/*` and `organization/*` patterns to subscribe to multiple channels at once
- ✅ **Backward compatible**: Existing consumer code requires NO changes
- ✅ **Internal only**: Only subscription implementation changes, not the interface

**Implementation**:
```swift
actor BackendNotifier {
    private func handleOrganizationIDChanged(_ organizationID: String?) async {
        // Device events - subscribe to device/* wildcard
        // Receives: presenceChanged, recordingStateChanged, firmwareUpdated
        subscribeDeviceTask = Task { [weak self] in
            guard let self else { return }
            for await event in await self.appSyncSubscriber.subscribe(.deviceWildcard, returning: DeviceStateOutput.self) {
                await self.deviceObservers.values.forEach { $0.yield(event) }
            }
        }

        // Organization events - subscribe to organization/* wildcard
        // Receives: licensePhaseChanged, planChanged, aiSettingsChanged
        subscribeOrganizationTask = Task { [weak self] in
            guard let self else { return }
            for await event in await self.appSyncSubscriber.subscribe(.organizationWildcard, returning: OrganizationStateOutput.self) {
                await self.organizationObservers.values.forEach { $0.yield(event) }
            }
        }

        // Other channels remain single subscriptions
        // archive/stateChanged, roleChanged, tokenRevoked
    }
}
```

**Migration approach**:
- ✅ **Zero consumer code changes** - existing consumers continue to work unchanged
- ✅ **Only BackendNotifier internals change** - switch from GraphQL to AppSync Events
- ✅ **Gradual rollout possible** - can test device/* and organization/* subscriptions independently

### 5. NO Client-Side Filtering Required

**Background**:
- Current system: Backend filters events by device group permissions
- **AppSync Events: Backend filters events by publishing to user-specific channels**

**Architecture**:
- Backend publishes to `vortex-app/user/{userId}/*` channels
- AppSync custom authorizer validates that subscriber's userId matches channel userId
- iOS receives only authorized events (no client-side filtering needed)
- Simpler implementation - no EventFilter protocol required

**All Channels (User-Level)**:
- `vortex-app/user/{userId}/device/presenceChanged` - Backend filters before publishing
- `vortex-app/user/{userId}/device/recordingStateChanged` - Backend filters before publishing
- `vortex-app/user/{userId}/device/firmwareUpdated` - Backend filters before publishing
- `vortex-app/user/{userId}/archive/stateChanged` - Backend filters before publishing
- `vortex-app/user/{userId}/organization/licensePhaseChanged` - Backend filters (org membership)
- `vortex-app/user/{userId}/organization/planChanged` - Backend filters (org membership)
- `vortex-app/user/{userId}/organization/aiSettingsChanged` - Backend filters (org membership)
- `vortex-app/user/{userId}/roleChanged` - Backend filters (user-specific)
- `vortex-app/user/{userId}/tokenRevoked` - Backend filters (user-specific)

### 6. Channel Subscription

**Schema Validation**: All channel definitions and event types are validated against latest OpenAPI schema to ensure consistency with backend API contracts.

**Wildcard Pattern Subscriptions** (efficient single-subscription approach):

| iOS Method | AppSync Events Subscription | Receives Event Types | Filtering |
|------------|----------------------------|---------------------|-----------|
| `deviceValues()` | `vortex-app/user/{userId}/device/*` | `presenceChanged`, `recordingStateChanged`, `firmwareUpdated` | Server-side |
| `organizationValues()` | `vortex-app/user/{userId}/organization/*` | `licensePhaseChanged`, `planChanged`, `aiSettingsChanged` | Server-side |
| `archiveValues()` | `vortex-app/user/{userId}/archive/stateChanged` | `stateChanged` | Server-side |
| `roleValues()` | `vortex-app/user/{userId}/roleChanged` | `roleChanged` | Server-side |
| `revokeValues()` | `vortex-app/user/{userId}/tokenRevoked` | `tokenRevoked` | Server-side |

**Individual Event Types** (for reference):

| GraphQL Subscription | Event Type in Payload | AppSync Events Path |
|----------------------|----------------------|---------------------|
| `subscribeDeviceState` (online) | `device/presenceChanged` | `vortex-app/user/{userId}/device/presenceChanged` |
| `subscribeDeviceState` (recording) | `device/recordingStateChanged` | `vortex-app/user/{userId}/device/recordingStateChanged` |
| `subscribeDeviceState` (firmware) | `device/firmwareUpdated` | `vortex-app/user/{userId}/device/firmwareUpdated` |
| `subscribeOrganizationState` (license) | `organization/licensePhaseChanged` | `vortex-app/user/{userId}/organization/licensePhaseChanged` |
| `subscribeOrganizationState` (plan) | `organization/planChanged` | `vortex-app/user/{userId}/organization/planChanged` |
| `subscribeOrganizationState` (AI) | `organization/aiSettingsChanged` | `vortex-app/user/{userId}/organization/aiSettingsChanged` |

**Key Benefits**:
- ✅ **Wildcard efficiency**: Subscribe to `device/*` once instead of 3 separate subscriptions
- ✅ **Backward compatible**: `deviceValues()` returns unified stream, just like GraphQL
- ✅ **Event type discrimination**: Use `eventType` field to distinguish event types if needed
- ✅ **Server-side filtering**: Backend handles all authorization before publishing

### 7. Message Format

**Schema Source**: All event payload schemas are sourced from the latest OpenAPI definitions and validated via schema file.

AppSync Events wraps payloads in a standard envelope:

```json
{
  "type": "data",
  "id": "<subscription-id>",
  "event": ["<JSON-stringified-payload>"]
}
```

**Event Payload Schema Changes**:

All events now include these **required** fields (per latest OpenAPI schema):
- **`eventType`** (string): Event type identifier for routing (e.g., `"device/presenceChanged"`, `"license/phaseChanged"`)
- **`timestamp`** (string, ISO 8601): Event occurrence timestamp

Most device/archive events include these **optional** fields:
- **`orgId`** (string | null): Organization identifier
- **`siteId`** (string | null): Site/device group identifier (metadata only - authorization handled by backend)
- **`thingName`** (string | null): AWS IoT thing name (device identifier)
- **`derivant`** (string | null): Device model identifier
- **`mac`** (string | null): Device MAC address

**Event-Specific Fields** (validated against latest OpenAPI schemas):
- `device/presenceChanged`: `online` (boolean, nullable)
- `device/recordingStateChanged`: `recording` (boolean, nullable)
- `device/firmwareUpdated`: `fwUpdateState` (integer, nullable, -1 to 14)
- `archive/stateChanged`: `status` (enum, nullable), `videoLength`, `videoSize`, `cloudSize`, `hasH265`, `createdAt`
- `organization/licensePhaseChanged`: `orgId` (nullable), `licensePhase` (nullable, enum: SetupStatus, Valid, NoticePeriod, GracePeriod, RenewalOverdue, Invalid)
- `organization/planChanged`: `orgId` (nullable), `isFreePlan` (nullable, boolean)
- `organization/aiSettingsChanged`: `orgId` (nullable), `aiControlSetting` (nullable, object with uuid, termsAgreement, options) - **Note: camelCase**
- `user/roleChanged`: `reason` (nullable, string)
- `user/tokenRevoked`: `userId` (required), `revokedAt` (required), `reason` (nullable, enum: PASSWORD_CHANGED), `requestId` (nullable)

### 8. Coexistence Strategy (GraphQL Code Preserved)

**Coexistence approach** - Both GraphQL and AppSync Events code exist:

**Keep GraphQL Code** (preserved but unused):
- Keep `GraphQLSubscriber.swift`
- Keep `GraphQLSubscription.swift`
- Keep GraphQL factory methods in `VortexFactoryProvider.swift`
- Keep WebSocket implementation

**Add AppSync Events Code** (new and active):
- New `AppSyncEventsSubscriber.swift`
- New `AppSyncEventsSubscription.swift`
- New factory methods for AppSync Events client
- BackendNotifier uses AppSync Events implementation

**Migration Strategy** (one-time deployment):
- **Phase 1**: Implement AppSync Events infrastructure
- **Phase 2**: Update BackendNotifier internals to use AppSync Events (no API changes)
- **Phase 3**: Test thoroughly in staging environment
- **Phase 4**: Deploy to production (one-time switch)
- **Phase 5**: Monitor production closely after deployment

**Trade-offs**:
- ✅ **NO breaking changes** - consumers require zero code changes
- ✅ **Backward compatible** - existing API preserved completely
- ✅ **Easier rollback** - can switch back to GraphQL implementation instantly (no consumer updates needed)
- ✅ **No deletion risk** - GraphQL code preserved for reference
- ✅ **Gradual cleanup** - can remove GraphQL later when confident
- ✅ **Efficient subscriptions** - wildcard patterns reduce connection overhead
- ❌ **Code duplication** - both GraphQL and AppSync code exist temporarily
- ❌ **Maintenance burden** - need to maintain unused GraphQL code until cleanup

## Impact

### Code Changes

**New Directory Structure**:
```
VortexFeatures/Sources/
├── AWSServices/
│   ├── AWSServices.swift                    ✏️ MODIFIED (added makeAppSyncEventsClient)
│   └── AWSAppSyncEvents/                    📁 NEW
│       ├── AppSyncEventsClientProtocol.swift ✅ COMPLETED
│       └── AppSyncEventsClient.swift         ✅ COMPLETED
│
└── VortexFeatures/Common/VortexBackend/
    ├── BackendSubscriber/
    │   ├── AppSyncEventsSubscriber.swift    📄 NEW (pending)
    │   └── AppSyncEventsSubscription.swift  📄 NEW (pending)
    │
    ├── BackendNotifier/
    │   └── BackendNotifier.swift            ✏️ MODIFIED (internal only, NO API changes)
    │
    └── Model/Subscribe/
        ├── DeviceStateOutput.swift          ✏️ MODIFIED (add eventType, timestamp)
        ├── OrganizationStateOutput.swift    ✏️ MODIFIED (add eventType, timestamp)
        ├── ArchiveStateOutput.swift         ✏️ MODIFIED (add eventType, timestamp)
        ├── RoleChangeOutput.swift           ✏️ MODIFIED (add eventType, timestamp)
        └── UserTokenRevokeOutput.swift      ✏️ MODIFIED (add eventType, timestamp)
```

**New Files - AWSServices Layer** (simplified, direct SDK usage):
- `AppSyncEventsClientProtocol.swift` ✅ - Protocol defining AppSync Events client interface, includes AppSyncEventMessage struct
- `AppSyncEventsClient.swift` ✅ - Actor implementing protocol with direct AWS SDK usage (no wrapper layer)
- `AWSServices.swift` ✅ - Added factory method `makeAppSyncEventsClient(endpointURL:)`
- ~~`AppSyncEventsClientWrapper.swift`~~ - SKIPPED (direct SDK integration chosen)
- ~~`AppSyncEventTypes.swift`~~ - SKIPPED (channel names inline in subscription types)

**New Files - BackendSubscriber Layer** (GraphQL files preserved):
- `AppSyncEventsSubscriber.swift` - Subscription interface and implementation
- `AppSyncEventsSubscription.swift` - 5 subscription type definitions (using wildcards for device/* and organization/*)
- **Keep existing**: `GraphQLSubscriber.swift` (preserved but unused)
- **Keep existing**: `GraphQLSubscription.swift` (preserved but unused)

**NO New Model Files Required**:
- ✅ Reuse existing `DeviceStateOutput` (add `eventType`, `timestamp` optional fields)
- ✅ Reuse existing `OrganizationStateOutput` (add `eventType`, `timestamp` optional fields)
- ✅ Reuse existing `ArchiveStateOutput` (add `eventType`, `timestamp` optional fields)
- ✅ Reuse existing `RoleChangeOutput` (add `eventType`, `timestamp` optional fields)
- ✅ Reuse existing `UserTokenRevokeOutput` (add `eventType`, `timestamp` optional fields)

**Modified Files**:
- `BackendNotifier.swift` - **NO BREAKING CHANGE**: Internal implementation only
  - ✅ **Keep**: `deviceValues() -> AsyncStream<DeviceStateOutput>` (interface unchanged)
  - ✅ **Keep**: `organizationValues() -> AsyncStream<OrganizationStateOutput>` (interface unchanged)
  - 🔄 **Update**: Internal subscription logic to use AppSync Events with wildcard patterns
  - 🔄 **Update**: `handleOrganizationIDChanged()` to subscribe to `device/*` and `organization/*`
  - **GraphQL implementation code preserved but unused**
- `VortexFactoryProvider.swift` - Add AppSync Events factory methods
  - **Keep existing**: GraphQL factory methods (preserved but unused)
  - Add: AppSync Events factory methods
- **Modified Output Models** (all changes are optional fields - backward compatible):
  - **`DeviceStateOutput`** - Add optional `eventType` and `timestamp` fields
  - **`OrganizationStateOutput`** - Add optional `eventType` and `timestamp` fields
  - **`ArchiveStateOutput`** - Add optional `eventType` and `timestamp` fields
  - **`RoleChangeOutput`** - Add optional `eventType` and `timestamp` fields
  - **`UserTokenRevokeOutput`** - Add optional `eventType` and `timestamp` fields
  - Note: All existing fields remain unchanged; only adding metadata fields for debugging/logging

**No Files Deleted**:
- `GraphQLSubscriber.swift` - **Preserved** (unused but kept for rollback)
- `GraphQLSubscription.swift` - **Preserved** (unused but kept for rollback)

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
  - 9 subscription type implementations (user-level channels)
- **Integration Tests**:
  - Channel subscription for all 9 event types (user-level)
  - Event routing based on `eventType` field
  - Verify only authorized events received (backend filtering)
  - Multiple concurrent channel subscriptions
  - Organization state split (license, plan, AI settings)

**Testing Strategy**:
- Unit tests: Protocol implementation, event parsing
- Integration tests: Connect to staging backend, verify backend filtering works
- Manual testing: Various scenarios (network interruption, app lifecycle, permission changes)

### Dependencies

**Runtime Dependencies**:
- **AWS AppSync Events Swift SDK** (new): AWS official Swift SDK for AppSync Events
  - Repository: `https://github.com/aws-amplify/aws-appsync-events-swift`
  - Package: `aws-appsync-events-swift` via Swift Package Manager
  - Uses `AppSyncEventBridgeClient` for WebSocket connection and subscription management
  - Wrapped in `AppSyncEventsClientWrapper` to isolate dependency
- **Existing Dependencies**:
  - `vortexAuthService` for JWT tokens
  - `VortexLogger` for logging
  - `Dependencies` package for dependency injection

**Development Dependencies**:
- **Latest OpenAPI Schema**: Schema validation and synchronization
  - Source: `/Users/ryanchen/Downloads/Default module.openapi.yaml`
  - Validates Swift event types against backend contracts

### Migration Path

**Phase 0: Preparation**
- Add AWS AppSync Events Swift SDK (`https://github.com/aws-amplify/aws-appsync-events-swift`) via Swift Package Manager
- Review SDK documentation and `AppSyncEventBridgeClient` API
- Review latest OpenAPI schema for schema changes
- Set up testing environment with dev backend

**Phase 1: AWSServices Layer Implementation**
- Create `AWSServices/AWSAppSyncEvents/` directory structure
- Implement Protocol, Actor, Wrapper following AWSMqttClient pattern
- Write unit tests for AWSServices layer
- Validate SDK wrapper isolation

**Phase 2: BackendSubscriber Extension**
- Implement AppSyncEventsSubscriber protocol and implementations
- Create 5 subscription type definitions using wildcards:
  - `.deviceWildcard` → `device/*`
  - `.organizationWildcard` → `organization/*`
  - `.archiveState`, `.roleChange`, `.tokenRevoke`
- **NO EventFilter needed** - backend handles all authorization
- Write unit tests for subscription layer

**Phase 3: Output Model Updates**
- Add optional `eventType` and `timestamp` fields to existing models:
  - `DeviceStateOutput`
  - `OrganizationStateOutput`
  - `ArchiveStateOutput`
  - `RoleChangeOutput`
  - `UserTokenRevokeOutput`
- **NO breaking changes** - all new fields are optional
- Maintain backward compatibility with existing code

**Phase 4: BackendNotifier Migration**
- **NO BREAKING CHANGE**: Update internal implementation only
- Keep all existing method signatures unchanged:
  - `deviceValues()` → subscribes to `device/*`
  - `organizationValues()` → subscribes to `organization/*`
  - `archiveValues()`, `roleValues()`, `revokeValues()` → single channel subscriptions
- Update `handleOrganizationIDChanged()` to use AppSync Events
- **Keep GraphQL implementation files** (preserved but unused)
- Update VortexFactoryProvider - **keep GraphQL factories**, add AppSync Events factories
- Write integration tests

**Phase 5: Schema Validation**
- Validate all event types against latest OpenAPI schemas
- Ensure field mappings are correct (verify `orgId`, `siteId`, `thingName`, etc.)
- Verify wildcard subscriptions receive all expected event types
- Run schema validation tests

**Phase 6: Dev Environment Testing**
- Deploy to dev environment with AppSync Events
- Test wildcard subscriptions: `device/*` and `organization/*`
- **Verify backend filtering** - iOS receives only authorized events
- Test that existing consumers work without any code changes
- Test reconnection and error scenarios
- Monitor performance and stability

**Phase 7: Staging Validation**
- Deploy to staging environment
- Run full regression testing (no consumer code changes needed)
- Performance testing (latency, memory, battery)
- Security validation
- QA sign-off

**Phase 8: Production Deployment**
- Deploy to production (one-time switch)
- Close monitoring for first 24-48 hours
- Rollback plan: Instant switch back to GraphQL (no consumer updates needed)
- Post-deployment validation

## Success Criteria

1. **Architecture Compliance**:
   - Follows AWSServices wrapper pattern (Protocol + Actor + Wrapper)
   - SDK dependency isolated to wrapper layer only
   - Uses Dependencies package for dependency injection
   - Actor isolation ensures thread-safety

2. **Functional Parity**:
   - Wildcard subscriptions (`device/*`, `organization/*`) working correctly
   - Event delivery matches GraphQL subscription behavior exactly
   - **Backend filtering verified** - iOS receives only authorized events
   - All event types properly handled (presence, recording, firmware, license, plan, AI settings)
   - Reconnection handles network disruption reliably

3. **Backward Compatibility**:
   - ✅ **Zero consumer code changes** - all existing code works unchanged
   - ✅ All existing method signatures preserved
   - ✅ All existing tests pass without modification
   - ✅ No breaking changes in public API
   - ✅ Instant rollback capability (no consumer updates needed)

4. **Schema Consistency**:
   - All event types validated against latest OpenAPI schema
   - Field mappings correct (verify `orgId`, `siteId`, `thingName`, etc.)
   - Note: `siteId` field present but NOT used for filtering
   - Zero schema drift detected
   - Optional `eventType` and `timestamp` fields added to all models
   - Wildcard subscriptions receive all expected event types

5. **Testing**:
   - Unit tests for all new components
   - Integration tests for wildcard subscriptions
   - Performance tests validate <1s latency (P99)
   - Regression tests confirm existing functionality unchanged

6. **Production Readiness**:
   - No increase in crash rates
   - Memory usage within acceptable limits
   - Error handling comprehensive
   - Logging consistent with VortexLogger patterns

## References

- **Backend Proposal**: `/Users/ryanchen/code/AI/agentic-development-alignment-taskforce/docs/openspec/changes/switch-to-appsync-events/`
- **Latest OpenAPI Schema**: `/Users/ryanchen/Downloads/Default module.openapi.yaml`
  - Defines 9 channels (updated from 7)
  - Event type definitions validated against backend contract
- **AWS AppSync Events WebSocket Protocol**: https://docs.aws.amazon.com/appsync/latest/eventapi/event-api-websocket-protocol.html
- **Current iOS implementation**: `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/`
