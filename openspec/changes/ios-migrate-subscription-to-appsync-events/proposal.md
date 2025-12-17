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

**Subscription Implementations** (9 types - all user-level channels):
1. DevicePresenceSubscription → `vortex-app/user/{userId}/device/presenceChanged`
2. DeviceRecordingSubscription → `vortex-app/user/{userId}/device/recordingStateChanged`
3. DeviceFirmwareSubscription → `vortex-app/user/{userId}/device/firmwareUpdated`
4. ArchiveStateEventsSubscription → `vortex-app/user/{userId}/archive/stateChanged`
5. LicensePhaseSubscription → `vortex-app/user/{userId}/organization/licensePhaseChanged` ⚠️ NEW
6. PlanTypeSubscription → `vortex-app/user/{userId}/organization/planChanged` ⚠️ NEW
7. AISettingsSubscription → `vortex-app/user/{userId}/organization/aiSettingsChanged` ⚠️ NEW
8. RoleChangeEventsSubscription → `vortex-app/user/{userId}/roleChanged`
9. UserTokenRevokeEventsSubscription → `vortex-app/user/{userId}/tokenRevoked`

**NO EventFilter Needed**:
- Backend publishes to each user's channel separately
- iOS receives only authorized events (no client-side filtering required)
- Authorization enforced by AppSync custom authorizer (validates userId match)

### 4. Update BackendNotifier with New AppSync Events Methods

**Breaking Changes** - New API to match backend's 9-channel architecture:

**New Methods** (replacing old GraphQL methods):
```swift
// Device events (3 SEPARATE methods - BREAKING CHANGE)
func devicePresenceValues() async -> AsyncStream<DevicePresenceOutput>      // NEW - online state
func deviceRecordingValues() async -> AsyncStream<DeviceRecordingOutput>    // NEW - recording state
func deviceFirmwareValues() async -> AsyncStream<DeviceFirmwareOutput>      // NEW - firmware update

// Archive events
func archiveValues() async -> AsyncStream<ArchiveStateOutput>

// Organization events (3 SEPARATE methods - BREAKING CHANGE)
func licenseValues() async -> AsyncStream<LicenseStateOutput>     // NEW
func planValues() async -> AsyncStream<PlanStateOutput>           // NEW
func aiSettingsValues() async -> AsyncStream<AISettingsOutput>    // NEW

// User events
func roleValues() async -> AsyncStream<RoleChangeOutput>
func revokeValues() async -> AsyncStream<UserTokenRevokeOutput>
```

**Key Changes**:
- `deviceValues()` is **REMOVED** - split into 3 separate methods (devicePresenceValues, deviceRecordingValues, deviceFirmwareValues)
- `organizationValues()` is **REMOVED** - split into 3 separate methods
- **Consistent API**: All backend channels map 1:1 to iOS methods (9 channels → 9 methods)
- Consumers must update to subscribe to multiple streams

**Implementation**:
```swift
actor BackendNotifier {
    // Device events - 3 separate methods
    func devicePresenceValues() async -> AsyncStream<DevicePresenceOutput> {
        // Subscribe to vortex-app/user/{userId}/device/presenceChanged
    }

    func deviceRecordingValues() async -> AsyncStream<DeviceRecordingOutput> {
        // Subscribe to vortex-app/user/{userId}/device/recordingStateChanged
    }

    func deviceFirmwareValues() async -> AsyncStream<DeviceFirmwareOutput> {
        // Subscribe to vortex-app/user/{userId}/device/firmwareUpdated
    }

    // Organization events - 3 separate methods
    func licenseValues() async -> AsyncStream<LicenseStateOutput> {
        // Subscribe to vortex-app/user/{userId}/organization/licensePhaseChanged
    }

    func planValues() async -> AsyncStream<PlanStateOutput> {
        // Subscribe to vortex-app/user/{userId}/organization/planChanged
    }

    func aiSettingsValues() async -> AsyncStream<AISettingsOutput> {
        // Subscribe to vortex-app/user/{userId}/organization/aiSettingsChanged
    }
}
```

**Migration approach**:
- **Device events**: Replace `deviceValues()` with 3 separate subscriptions (devicePresenceValues, deviceRecordingValues, deviceFirmwareValues)
- **Organization events**: Replace `organizationValues()` with 3 separate subscriptions
- **Consistent 1:1 mapping**: 9 backend channels → 9 iOS methods
- Update all consumer code (DeviceManager, etc.) to subscribe to multiple streams
- Update all references across the codebase

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

Subscribe to the following AppSync Events channels (9 channels total - all user-level):

| Current GraphQL Subscription | AppSync Events Channel | Event Type | Filtering |
|------------------------------|------------------------|------------|-----------|
| `subscribeDeviceState` (online) | `vortex-app/user/{userId}/device/presenceChanged` | `device/presenceChanged` | Server-side |
| `subscribeDeviceState` (recording) | `vortex-app/user/{userId}/device/recordingStateChanged` | `device/recordingStateChanged` | Server-side |
| `subscribeDeviceState` (firmware) | `vortex-app/user/{userId}/device/firmwareUpdated` | `device/firmwareUpdated` | Server-side |
| `subscribeArchiveState` | `vortex-app/user/{userId}/archive/stateChanged` | `archive/stateChanged` | Server-side |
| `subscribeOrganizationState` (license) | `vortex-app/user/{userId}/organization/licensePhaseChanged` | `organization/licensePhaseChanged` | Server-side |
| `subscribeOrganizationState` (plan) | `vortex-app/user/{userId}/organization/planChanged` | `organization/planChanged` | Server-side |
| `subscribeOrganizationState` (AI) | `vortex-app/user/{userId}/organization/aiSettingsChanged` | `organization/aiSettingsChanged` | Server-side |
| `subscribeRoleChange` | `vortex-app/user/{userId}/roleChanged` | `user/roleChanged` | Server-side |
| `subscribeUserTokenRevoke` | `vortex-app/user/{userId}/tokenRevoked` | `user/tokenRevoked` | Server-side |

**Note**:
- **ALL channels use user-level pattern**: `vortex-app/user/{userId}/*`
- Backend publishes to each authorized user separately (server-side filtering)
- The single GraphQL `subscribeDeviceState` subscription is split into 3 separate AppSync Events channels based on event type (presence, recording, firmware)
- The single GraphQL `subscribeOrganizationState` subscription is split into 3 separate AppSync Events channels based on event type (license, plan, AI settings)

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
- **Phase 2**: Update BackendNotifier to use AppSync Events
- **Phase 3**: Update all consumer code to use new API
- **Phase 4**: Test thoroughly in staging environment
- **Phase 5**: Deploy to production (one-time switch)
- **Phase 6**: Monitor production closely after deployment

**Trade-offs**:
- ❌ **Breaking changes** - all consumers must update code
- ❌ **Code duplication** - both GraphQL and AppSync code exist
- ❌ **Maintenance burden** - need to maintain unused GraphQL code
- ✅ **Easier rollback** - can switch back to GraphQL implementation quickly
- ✅ **No deletion risk** - GraphQL code preserved for reference
- ✅ **Gradual cleanup** - can remove GraphQL later when confident

## Impact

### Code Changes

**New Directory Structure**:
```
VortexFeatures/Sources/
├── AWervSSices/
│   └── AWSAppSyncEvents/                    📁 NEW
│       ├── AppSyncEventsClientProtocol.swift
│       ├── AppSyncEventsClient.swift
│       ├── AppSyncEventsClientWrapper.swift
│       └── AppSyncEventTypes.swift
│
└── VortexFeatures/Common/VortexBackend/
    ├── BackendSubscriber/
    │   ├── AppSyncEventsSubscriber.swift    📄 NEW
    │   └── AppSyncEventsSubscription.swift  📄 NEW
    │
    ├── BackendNotifier/
    │   ├── BackendNotifier.swift            ✏️ MODIFIED (add new methods)
    │   └── BackendNotifierProtocol.swift    ✏️ MODIFIED (optional)
    │
    └── Model/Subscribe/
        ├── LicenseStateOutput.swift         📄 NEW
        ├── PlanStateOutput.swift            📄 NEW
        └── AISettingsOutput.swift           📄 NEW
```

**New Files - AWSServices Layer** (following AWSMqttClient pattern):
- `AppSyncEventsClientProtocol.swift` - Protocol defining AppSync Events client interface
- `AppSyncEventsClient.swift` - Actor implementing protocol with AWS SDK
- `AppSyncEventsClientWrapper.swift` - Wrapper isolating AWS SDK dependency
- `AppSyncEventTypes.swift` - Channel and event type definitions

**New Files - BackendSubscriber Layer** (GraphQL files preserved):
- `AppSyncEventsSubscriber.swift` - Subscription interface and implementation
- `AppSyncEventsSubscription.swift` - 9 subscription type definitions (all user-level channels)
- **Keep existing**: `GraphQLSubscriber.swift` (preserved but unused)
- **Keep existing**: `GraphQLSubscription.swift` (preserved but unused)

**New Files - Model Layer**:
- `DevicePresenceOutput.swift` - Device presence event model (online state)
- `DeviceRecordingOutput.swift` - Device recording event model (recording state)
- `DeviceFirmwareOutput.swift` - Device firmware event model (firmware update state)
- `LicenseStateOutput.swift` - License phase event model
- `PlanStateOutput.swift` - Plan type event model
- `AISettingsOutput.swift` - AI settings event model

**Modified Files**:
- `BackendNotifier.swift` - **BREAKING CHANGE**: Use AppSync Events methods
  - Remove: `deviceValues() -> AsyncStream<DeviceStateOutput>`
  - Remove: `organizationValues() -> AsyncStream<OrganizationStateOutput>`
  - Add: `devicePresenceValues()`, `deviceRecordingValues()`, `deviceFirmwareValues()`
  - Add: `licenseValues()`, `planValues()`, `aiSettingsValues()`
  - Update: All other methods to use AppSync Events
  - **GraphQL implementation code preserved but unused**
- `VortexFactoryProvider.swift` - Add AppSync Events factory methods
  - **Keep existing**: GraphQL factory methods (preserved but unused)
  - Add: AppSync Events factory methods
- **Modified Output Models**:
  - **`ArchiveStateOutput`** - Add `eventType` and `timestamp` fields
  - **`RoleChangeOutput`** - Add `eventType` and `timestamp` fields
  - **`UserTokenRevokeOutput`** - Add `eventType` and `timestamp` fields
  - Note: `siteId` field is metadata only, NOT used for filtering (backend handles authorization)

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
- Create 9 user-level subscription type definitions (including 3 new organization state subscriptions)
- **NO EventFilter needed** - backend handles all authorization
- Write unit tests for subscription layer

**Phase 3: BackendNotifier Migration**
- **BREAKING CHANGE**: Use AppSync Events methods in BackendNotifier
- Remove `organizationValues()` method
- Add `licenseValues()`, `planValues()`, `aiSettingsValues()` methods
- Create new Output models (LicenseStateOutput, PlanStateOutput, AISettingsOutput)
- **Keep GraphQL implementation files** (preserved but unused)
- Update VortexFactoryProvider - **keep GraphQL factories**, add AppSync Events factories
- Write integration tests

**Phase 4: Schema Validation**
- Validate all event types against latest OpenAPI schemas
- Ensure field mappings are correct (verify `orgId`, `siteId`, `thingName`, etc.)
- Note: `siteId` is metadata only - NOT used for client-side filtering
- Update Output models if needed
- Run schema validation tests

**Phase 5: Consumer Code Migration**
- Search for all usages of `organizationValues()` across codebase
- Update each consumer to use 3 separate streams: `licenseValues()`, `planValues()`, `aiSettingsValues()`
- Update tests to use new API
- Ensure compiler passes with no references to old methods

**Phase 6: Dev Environment Testing**
- Deploy to dev environment with AppSync Events
- Test all 9 user-level channels concurrently
- **Verify backend filtering** - iOS receives only authorized events
- Test organization state split (license, plan, AI settings)
- Test reconnection and error scenarios
- Monitor performance and stability

**Phase 7: Staging Validation**
- Deploy to staging environment
- Run full regression testing
- Performance testing (latency, memory, battery)
- Security validation
- QA sign-off

**Phase 8: Production Deployment**
- Deploy to production (one-time switch)
- Close monitoring for first 24-48 hours
- Rollback plan: Hotfix deployment with GraphQL code if critical issues
- Post-deployment validation

## Success Criteria

1. **Architecture Compliance**:
   - Follows AWSServices wrapper pattern (Protocol + Actor + Wrapper)
   - SDK dependency isolated to wrapper layer only
   - Uses Dependencies package for dependency injection
   - Actor isolation ensures thread-safety

2. **Functional Parity**:
   - All 9 user-level AppSync Events channels working correctly
   - Event delivery matches GraphQL subscription behavior
   - **Backend filtering verified** - iOS receives only authorized events
   - Organization state split handled correctly (license, plan, AI settings)
   - Reconnection handles network disruption reliably

3. **Code Migration**:
   - All usage of `organizationValues()` replaced with 3 separate methods
   - All consumers updated: `licenseValues()`, `planValues()`, `aiSettingsValues()`
   - GraphQL code completely removed from codebase
   - Existing tests updated to use new API
   - Code compiles with no references to old GraphQL methods

4. **Schema Consistency**:
   - All event types validated against latest OpenAPI schema
   - Field mappings correct (verify `orgId`, `siteId`, `thingName`, etc.)
   - Note: `siteId` field present but NOT used for filtering
   - Zero schema drift detected
   - Event types include `eventType` and `timestamp` fields
   - New organization state models align with schema

5. **Testing**:
   - Unit tests for all new components
   - Integration tests for 9-channel subscription
   - Performance tests validate <1s latency (P99)
   - Organization state split tested independently

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
