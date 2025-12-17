# iOS Real-time AppSync Events

## ADDED Requirements

### Requirement: AppSync Events Client Wrapper

The iOS app SHALL implement an AppSync Events client following the existing AWSMqttClient wrapper pattern to isolate AWS SDK dependencies and provide a clean protocol-based interface, using the official AWS AppSync Events Swift SDK (`https://github.com/aws-amplify/aws-appsync-events-swift`).

#### Scenario: Connect to AppSync Events using SDK

**Given** the user is signed in with a valid Cognito JWT token
**When** the app initializes AppSync Events connection
**Then** the client SHALL:
- Create `AppSyncEventBridgeConfig` with endpoint, region, and JWT auth provider
- Instantiate `AppSyncEventBridgeClient` from `aws-appsync-events-swift` SDK
- Call SDK's `connect()` method to establish connection
- Let SDK handle WebSocket protocol details (connection_init, connection_ack)
- Wait for SDK connection confirmation before allowing subscriptions

**File references**:
- `VortexFeatures/Sources/AWSServices/AWSAppSyncEvents/AppSyncEventsClient.swift:30-65`

#### Scenario: Handle connection lifecycle using SDK

**Given** an active AppSync Events connection via SDK
**When** connection state changes occur
**Then** the client SHALL:
- Monitor SDK connection state changes (connecting, connected, disconnected, error)
- Delegate keep-alive handling to SDK (built-in 60-second interval)
- Handle SDK reconnection events (SDK provides automatic reconnection)
- Verify user is still signed in before allowing SDK reconnection
- Call SDK's `disconnect()` if user signed out
- Cancel reconnection if user signed out

**File references**:
- `VortexFeatures/Sources/AWSServices/AWSAppSyncEvents/AppSyncEventsClient.swift:99-120`

#### Scenario: Subscribe to AppSync Events channel using SDK

**Given** an established AppSync Events connection via SDK
**When** subscribing to a user-level channel (e.g., `vortex-app/user/{userId}/device/presenceChanged`)
**Then** the client SHALL:
- Call SDK's `subscribe(to: channel)` method with user-level channel path
- SDK handles subscription ID generation and protocol messaging
- Receive AsyncStream or event sequence from SDK
- Extract event payload data from SDK's event objects
- Transform SDK events to app's AsyncStream interface
- Yield parsed events to AsyncStream (all events are pre-authorized by backend)

**File references**:
- `VortexFeatures/Sources/AWSServices/AWSAppSyncEvents/AppSyncEventsClient.swift:82-97`

#### Scenario: Map AWS SDK errors to VortexError

**Given** the AWS AppSync Events Swift SDK throws an error
**When** the error is caught by the wrapper layer
**Then** the wrapper SHALL:
- Identify SDK error types (authentication, connection, subscription errors)
- Map authentication failures to `VortexError.sessionExpired`
- Map connection timeouts to `VortexError.networkError`
- Map subscription failures to `VortexError.error` with descriptive message
- Log error details using `VortexLogger` with appropriate level
- Preserve SDK error context for debugging

**File references**:
- `VortexFeatures/Sources/AWSServices/AWSAppSyncEvents/AppSyncEventsClientWrapper.swift:45-65`

### Requirement: Consistent 1:1 Channel-to-Method Mapping

The iOS app SHALL expose 9 separate subscription methods in BackendNotifier, maintaining 1:1 mapping with backend's 9 user-level AppSync Events channels for API consistency.

#### Scenario: 9 separate methods for 9 backend channels

**Given** Backend provides 9 user-level AppSync Events channels
**When** BackendNotifier implements subscription API
**Then** the app SHALL:
- Expose 9 separate public methods, one for each channel:
  - `devicePresenceValues()` → `device/presenceChanged` channel
  - `deviceRecordingValues()` → `device/recordingStateChanged` channel
  - `deviceFirmwareValues()` → `device/firmwareUpdated` channel
  - `archiveValues()` → `archive/stateChanged` channel
  - `licenseValues()` → `organization/licensePhaseChanged` channel
  - `planValues()` → `organization/planChanged` channel
  - `aiSettingsValues()` → `organization/aiSettingsChanged` channel
  - `roleValues()` → `user/roleChanged` channel
  - `revokeValues()` → `user/tokenRevoked` channel
- Maintain consistent API design across all event types
- **NO merging** of channels - each method corresponds to exactly one channel

**Rationale**: API consistency more important than minimal consumer changes

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifierProtocol.swift:1-15`

### Requirement: 9-Channel AppSync Events Subscriptions (User-Level)

The iOS app SHALL subscribe to 9 user-level AppSync Events channels (all using `vortex-app/user/{userId}/*` pattern) to replace the existing 5 GraphQL subscriptions, matching the latest backend OpenAPI schema. Backend handles all authorization and filtering server-side.

#### Scenario: Subscribe to device presence channel

**Given** the user is signed in with a valid userId
**When** BackendNotifier starts subscribing
**Then** the app SHALL:
- Subscribe to `vortex-app/user/{userId}/device/presenceChanged` channel
- Receive events with `eventType: "device/presenceChanged"`
- Parse payload into `DevicePresenceOutput` with `online` boolean field
- **NO client-side filtering** - backend publishes only authorized events to user's channel
- Yield all received events to `devicePresenceValues()` AsyncStream

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/AppSyncEventsSubscription.swift:15-25`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:62-72`

#### Scenario: Subscribe to device recording channel

**Given** the user is signed in with a valid userId
**When** BackendNotifier starts subscribing
**Then** the app SHALL:
- Subscribe to `vortex-app/user/{userId}/device/recordingStateChanged` channel
- Receive events with `eventType: "device/recordingStateChanged"`
- Parse payload into `DeviceRecordingOutput` with `recording` boolean field
- **NO client-side filtering** - backend publishes only authorized events
- Yield all received events to `deviceRecordingValues()` AsyncStream

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/AppSyncEventsSubscription.swift:27-37`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:74-84`

#### Scenario: Subscribe to device firmware channel

**Given** the user is signed in with a valid userId
**When** BackendNotifier starts subscribing
**Then** the app SHALL:
- Subscribe to `vortex-app/user/{userId}/device/firmwareUpdated` channel
- Receive events with `eventType: "device/firmwareUpdated"`
- Parse payload into `DeviceFirmwareOutput` with `fwUpdateState` integer field (range: -1 to 14)
- **NO client-side filtering** - backend publishes only authorized events
- Yield all received events to `deviceFirmwareValues()` AsyncStream

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/AppSyncEventsSubscription.swift:39-49`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:86-96`

#### Scenario: Subscribe to archive state channel

**Given** the user is signed in with a valid userId
**When** BackendNotifier starts subscribing
**Then** the app SHALL:
- Subscribe to `vortex-app/user/{userId}/archive/stateChanged` channel
- Receive events with `eventType: "archive/stateChanged"`
- Parse payload into `ArchiveStateOutput` with status enum and video metadata
- **NO client-side filtering** - backend publishes only authorized events
- Yield all received events to `archiveValues()` AsyncStream

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/AppSyncEventsSubscription.swift:51-61`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:147-157`

#### Scenario: Subscribe to license phase channel

**Given** the user is signed in and belongs to an organization
**When** BackendNotifier starts subscribing
**Then** the app SHALL:
- Subscribe to `vortex-app/user/{userId}/organization/licensePhaseChanged` channel
- Receive events with `eventType: "organization/licensePhaseChanged"`
- Parse payload into `LicenseStateOutput` with `orgId` and `licensePhase` fields (both nullable)
- **NO merging needed** - directly yield events to `licenseValues()` AsyncStream

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/AppSyncEventsSubscription.swift:63-73`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:150-160`

#### Scenario: Subscribe to plan type channel

**Given** the user is signed in and belongs to an organization
**When** BackendNotifier starts subscribing
**Then** the app SHALL:
- Subscribe to `vortex-app/user/{userId}/organization/planChanged` channel
- Receive events with `eventType: "organization/planChanged"`
- Parse payload into `PlanStateOutput` with `orgId` and `isFreePlan` fields (both nullable)
- **NO merging needed** - directly yield events to `planValues()` AsyncStream

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/AppSyncEventsSubscription.swift:75-85`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:162-172`

#### Scenario: Subscribe to AI settings channel

**Given** the user is signed in and belongs to an organization
**When** BackendNotifier starts subscribing
**Then** the app SHALL:
- Subscribe to `vortex-app/user/{userId}/organization/aiSettingsChanged` channel
- Receive events with `eventType: "organization/aiSettingsChanged"`
- Parse payload into `AISettingsOutput` with `orgId` and `aiControlSetting` fields (both nullable) - **Note: camelCase field name**
- **NO merging needed** - directly yield events to `aiSettingsValues()` AsyncStream

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/AppSyncEventsSubscription.swift:87-97`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:174-184`

#### Scenario: Subscribe to role change channel

**Given** the user is signed in
**When** BackendNotifier starts subscribing
**Then** the app SHALL:
- Subscribe to `vortex-app/user/{userId}/roleChanged` channel
- Receive events with `eventType: "user/roleChanged"`
- Parse payload into `RoleChangeOutput` with `reason` field (nullable)
- Yield events to `roleValues()` AsyncStream

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/AppSyncEventsSubscription.swift:99-109`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:163-173`

#### Scenario: Subscribe to token revoke channel

**Given** the user is signed in
**When** BackendNotifier starts subscribing
**Then** the app SHALL:
- Subscribe to `vortex-app/user/{userId}/tokenRevoked` channel
- Receive events with `eventType: "user/tokenRevoked"`
- Parse payload into `UserTokenRevokeOutput` with required `userId` and `revokedAt` fields, optional `reason` and `requestId`
- Yield events to `revokeValues()` AsyncStream

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/AppSyncEventsSubscription.swift:111-121`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:171-181`

### Requirement: Event Schema Validation

The iOS app SHALL validate all event type definitions against the latest backend OpenAPI schema to ensure protocol compliance.

#### Scenario: Validate event structure

**Given** the latest OpenAPI schema from backend (`/Users/ryanchen/Downloads/Default module.openapi.yaml`)
**When** implementing Swift event type structs
**Then** the app SHALL:
- Include required `eventType` field (String constant matching schema)
- Include required `timestamp` field (String, ISO 8601 format)
- Match all field names exactly to schema (e.g., `orgId`, `siteId`, `thingName`)
- Use nullable types for optional fields matching schema
- Conform to `Decodable` and `Sendable` protocols

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Subscribe/DeviceStateOutput.swift:10-30`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Subscribe/LicenseStateOutput.swift:10-20`

#### Scenario: Handle schema evolution

**Given** the backend updates the OpenAPI schema
**When** new event fields are added
**Then** the app SHALL:
- Use optional properties for backward compatibility
- Log unrecognized fields at debug level (do not crash)
- Continue processing events with missing optional fields

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/AppSyncEventsSubscriber.swift:50-58`

### Requirement: Organization State 3-Stream API (**BREAKING CHANGE**)

The iOS app SHALL subscribe to 3 separate AppSync Events channels (license, plan, AI settings) and expose them as 3 separate public methods, replacing the single `organizationValues()` method.

#### Scenario: Expose 3 separate organization streams

**Given** AppSync Events provides 3 separate user-level channels for organization state
**When** BackendNotifier subscribes to organization channels
**Then** the app SHALL:
- Subscribe to `vortex-app/user/{userId}/organization/licensePhaseChanged` channel
- Subscribe to `vortex-app/user/{userId}/organization/planChanged` channel
- Subscribe to `vortex-app/user/{userId}/organization/aiSettingsChanged` channel
- Expose `licenseValues() -> AsyncStream<LicenseStateOutput>` method
- Expose `planValues() -> AsyncStream<PlanStateOutput>` method
- Expose `aiSettingsValues() -> AsyncStream<AISettingsOutput>` method
- **REMOVE** `organizationValues()` method (breaking change)

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:150-200`

#### Scenario: Consumer code must update to use 3 streams

**Given** existing code used `BackendNotifier.shared.organizationValues()`
**When** migrating to AppSync Events
**Then** consumers SHALL:
- Replace single `organizationValues()` call with 3 separate subscriptions
- Subscribe to `licenseValues()` for license phase changes
- Subscribe to `planValues()` for plan type changes
- Subscribe to `aiSettingsValues()` for AI settings changes
- Handle all 3 streams concurrently using separate Tasks

**File references**:
- Consumer example: `iOSCharmander/Common/AppManager/AppManager.swift:150-170` (MUST UPDATE)

## MODIFIED Requirements

### Requirement: BackendNotifier Migration (**BREAKING CHANGE**, GraphQL Preserved)

BackendNotifier subscription implementation SHALL use AppSync Events, including breaking API changes for organization state subscriptions. GraphQL code SHALL be preserved for rollback.

#### Scenario: All methods use AppSync Events (GraphQL code preserved)

**Given** the iOS app migrates to AppSync Events
**When** BackendNotifier methods are called
**Then** the app SHALL:
- Use AppSync Events implementation for all subscriptions
- **PRESERVE** GraphQL subscription code (unused but kept for rollback)
- **DELETE** `organizationValues()` method from BackendNotifier API
- **ADD** `licenseValues()`, `planValues()`, `aiSettingsValues()` methods
- Maintain same method signatures for `deviceValues()`, `archiveValues()`, `roleValues()`, `revokeValues()`

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:62-200`

#### Scenario: Subscribe on organization ID change

**Given** the user's organization ID or userId changes
**When** BackendNotifier detects the change
**Then** the app SHALL:
- Unsubscribe from all 9 user-level AppSync channels
- Disconnect WebSocket
- Reconnect with new userId
- Subscribe to 9 channels with new organization ID

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:135-178`

## ADDED Requirements (Code Migration)

### Requirement: Consumer Code Migration

All code that uses BackendNotifier's `organizationValues()` method SHALL be updated to use the 3 separate organization streams.

#### Scenario: Migrate from single stream to 3 streams

**Given** existing code subscribes to `organizationValues()`
**When** migrating to AppSync Events
**Then** the consumer code SHALL:
- Remove `organizationValues()` subscription
- Add `licenseValues()` subscription for license phase changes
- Add `planValues()` subscription for plan type changes
- Add `aiSettingsValues()` subscription for AI settings changes
- Handle all 3 streams concurrently

**Example migration**:
```swift
// Before
for await orgState in await BackendNotifier.shared.organizationValues() {
    if let license = orgState.licensePhase { handleLicense(license) }
    if let plan = orgState.isFreePlan { handlePlan(plan) }
    if let ai = orgState.AIControlSetting { handleAI(ai) }
}

// After
Task {
    for await license in await BackendNotifier.shared.licenseValues() {
        handleLicense(license.licensePhase)
    }
}
Task {
    for await plan in await BackendNotifier.shared.planValues() {
        handlePlan(plan.isFreePlan)
    }
}
Task {
    for await ai in await BackendNotifier.shared.aiSettingsValues() {
        handleAI(ai.aiControlSetting)
    }
}
```

#### Scenario: Compiler enforces migration

**Given** `organizationValues()` method is removed
**When** project is compiled
**Then** the compiler SHALL:
- Generate errors for all remaining `organizationValues()` calls
- Force developers to update all consumer code
- Ensure complete migration before deployment

## MODIFIED Requirements (Preserved Code)

### Preserved: GraphQL Subscription Implementation

All GraphQL subscription code is **PRESERVED** (but unused):
- `GraphQLSubscriber.swift` - **Preserved** (unused)
- `GraphQLSubscription.swift` - **Preserved** (unused)
- GraphQL factory methods - **Preserved** (unused)

**Rationale**: Keep GraphQL code for easier rollback and reference.

### Removed: organizationValues() Method

The single `organizationValues()` method is REMOVED from BackendNotifier and replaced with 3 separate methods:
- `licenseValues() -> AsyncStream<LicenseStateOutput>`
- `planValues() -> AsyncStream<PlanStateOutput>`
- `aiSettingsValues() -> AsyncStream<AISettingsOutput>`

**Impact**: All consumers must update their code to use 3 separate subscriptions.

## Dependencies

This spec depends on:
- Backend AppSync Events infrastructure deployment (see `/Users/ryanchen/code/AI/agentic-development-alignment-taskforce/docs/openspec/changes/switch-to-appsync-events`)
- **Backend OpenAPI schema** (see `/Users/ryanchen/code/AI/agentic-development-alignment-taskforce/docs/openspec/changes/switch-to-appsync-events/openapi-schemas.yaml`)
  - **ALL channels are user-level**: `vortex-app/user/{userId}/*` pattern
  - Backend handles all authorization server-side
- AWS AppSync Events Swift SDK (`https://github.com/aws-amplify/aws-appsync-events-swift`) via Swift Package Manager
- SDK provides `AppSyncEventBridgeClient` for connection and subscription management

## Testing Requirements

All scenarios SHALL be covered by:
- Unit tests using mock AppSyncEventsClientWrapper
- Integration tests connecting to staging AppSync Events endpoint
- Manual testing for network interruption and reconnection scenarios
- Schema validation tests comparing Swift types to OpenAPI schema
