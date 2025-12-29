# iOS Real-time AppSync Events

## ADDED Requirements

### Requirement: AppSync Events Client Protocol

The iOS app SHALL implement an AppSync Events client following the existing AWSMqttClient pattern to isolate AWS SDK dependencies and provide a clean protocol-based interface, using the official AWS AppSync Events Swift SDK (`https://github.com/aws-amplify/aws-appsync-events-swift`).

#### Scenario: Lazy initialization of AppSync Events client

**Given** the app starts and AppSyncEventsClient is created
**When** the first subscription is requested
**Then** the client SHALL:
- Defer WebSocket connection until first `subscribe()` call (lazy initialization)
- Create `Events` instance with endpoint URL on first subscription
- Instantiate `AuthTokenAuthorizer` with JWT token provider from AuthService
- Let SDK handle WebSocket protocol details (connection_init, connection_ack)
- Return AsyncThrowingStream for event delivery
- Reuse existing connection for subsequent subscriptions

**Rationale**: Lazy initialization avoids unnecessary connections and reduces startup overhead

**File references**:
- `VortexFeatures/Sources/AWSServices/AWSAppSyncEvents/AppSyncEventsClient.swift:30-80`

#### Scenario: Subscribe to AppSync Events channel using SDK

**Given** AppSyncEventsClient receives a subscription request
**When** subscribing to a user-level channel (e.g., `vortex-app/user/{userId}/device/*`)
**Then** the client SHALL:
- Initialize client on first subscribe if not already initialized
- Call SDK's `subscribe(to: channel)` method with user-level channel path
- SDK handles subscription ID generation and protocol messaging
- Receive AsyncThrowingStream from SDK
- Return raw event Data payloads to caller
- Yield all events to AsyncThrowingStream (backend pre-authorizes all events)

**File references**:
- `VortexFeatures/Sources/AWSServices/AWSAppSyncEvents/AppSyncEventsClient.swift:82-97`
- `VortexFeatures/Sources/AWSServices/AWSAppSyncEvents/AppSyncEventsClientProtocol.swift:19-26`

#### Scenario: Disconnect and cleanup

**Given** an active AppSync Events connection
**When** disconnect is requested (e.g., user signs out or switches organization)
**Then** the client SHALL:
- Call SDK's `disconnect(flushEvents: true)` to gracefully close connection
- SDK automatically cleans up all active subscriptions
- SDK cancels all pending tasks
- Reset client state for potential reconnection

**File references**:
- `VortexFeatures/Sources/AWSServices/AWSAppSyncEvents/AppSyncEventsClient.swift:99-105`

#### Scenario: Provide mock implementation for testing

**Given** unit tests need to test subscription behavior
**When** tests use MockAppSyncEventsClient
**Then** the mock SHALL:
- Implement AppSyncEventsClientProtocol
- Provide test control methods: `yieldEvent()`, `throwError()`, `getActiveChannels()`
- Track subscribed channels for verification
- Allow tests to simulate events and errors
- Support continuation-based event delivery

**File references**:
- `VortexFeatures/Sources/AWSServices/AWSAppSyncEvents/MockAppSyncEventsClient.swift:10-84`

### Requirement: Wildcard Subscriptions for Backward Compatibility

The iOS app SHALL use wildcard pattern subscriptions (`device/*`, `organization/*`) internally while preserving the existing public API, achieving zero breaking changes for consumers.

#### Scenario: Subscribe to device wildcard channel

**Given** BackendNotifier starts subscribing
**When** handling organization ID change
**Then** the app SHALL:
- Subscribe to `vortex-app/user/{userId}/device/*` wildcard channel
- Receive all device events (presenceChanged, recordingStateChanged, firmwareUpdated)
- Parse events into existing `DeviceStateOutput` struct
- Yield all events to existing `deviceValues()` AsyncStream
- **NO breaking changes** - consumers continue using `deviceValues()` as before

**Rationale**: Wildcard subscriptions reduce subscription overhead (1 instead of 3) while maintaining API compatibility

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:145-152`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/BackendAppSyncEventsSubscription.swift:110`

#### Scenario: Subscribe to organization wildcard channel

**Given** BackendNotifier starts subscribing
**When** handling organization ID change
**Then** the app SHALL:
- Subscribe to `vortex-app/user/{userId}/organization/*` wildcard channel
- Receive all organization events (licensePhaseChanged, planChanged, aiSettingsChanged)
- Parse events into existing `OrganizationStateOutput` struct
- Yield all events to existing `organizationValues()` AsyncStream
- **NO breaking changes** - consumers continue using `organizationValues()` as before

**Rationale**: Single subscription delivers all organization events to existing unified API

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:162-169`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/BackendAppSyncEventsSubscription.swift:111`

#### Scenario: Preserve single-channel subscriptions

**Given** some events are single-channel (archive, role, token)
**When** BackendNotifier starts subscribing
**Then** the app SHALL:
- Subscribe to `vortex-app/user/{userId}/archive/stateChanged` (single channel)
- Subscribe to `vortex-app/user/{userId}/roleChanged` (single channel)
- Subscribe to `vortex-app/user/{userId}/tokenRevoked` (single channel)
- Maintain existing `archiveValues()`, `roleValues()`, `revokeValues()` methods
- **NO breaking changes** - all existing APIs preserved

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:154-185`

### Requirement: BackendAppSyncEventsSubscriber with Automatic Retry

The iOS app SHALL implement a BackendAppSyncEventsSubscriber actor that handles subscriptions with automatic retry on connection failures, matching the existing GraphQL subscriber behavior.

#### Scenario: Subscribe and return non-throwing stream

**Given** a subscription request with channel and return type
**When** BackendAppSyncEventsSubscriber.subscribe() is called
**Then** the subscriber SHALL:
- Fetch userId from VortexAuthService
- Construct full channel name: `vortex-app/user/{userId}/{channelName}`
- Subscribe to AppSyncEventsClient
- Decode event Data to requested type using JSONDecoder
- Return AsyncStream (NOT AsyncThrowingStream) - errors handled internally
- Log decoding failures but continue stream

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/BackendAppSyncEventsSubscriber.swift:54-107`

#### Scenario: Automatic retry on connection failure

**Given** an active subscription encounters a connection error
**When** the error occurs (network failure, WebSocket disconnection, etc.)
**Then** the subscriber SHALL:
- Check if user is still signed in via `vortexAuthService.isSignIn()`
- If user signed out: stop subscription, finish stream
- If user still signed in: initiate retry sequence
- Coordinate retry delay across all subscription tasks (first task leads, others wait)
- Call `appSyncEventsClient.disconnect()`
- Wait 10 seconds (configurable for testing via `test_setRetryDelay()`)
- Retry subscription automatically
- Continue retry loop indefinitely until success or user signs out

**Rationale**: Matches existing GraphQL subscriber behavior for transparent reconnection

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/BackendAppSyncEventsSubscriber.swift:74-96`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/BackendAppSyncEventsSubscriber.swift:128-173`

#### Scenario: Coordinate retry across multiple subscriptions

**Given** multiple subscription tasks are active (e.g., device/*, organization/*)
**When** connection fails and multiple tasks need to retry
**Then** the subscriber SHALL:
- Use `isWaitingToRetry` flag to coordinate retry delay
- First task to encounter error becomes the leader
- Leader task disconnects client and waits retry delay
- Other tasks wait on continuations until leader completes delay
- All tasks resume and retry subscription after coordinated delay
- Avoid multiple concurrent disconnect calls

**Rationale**: Single coordinated retry prevents connection thrashing

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/BackendAppSyncEventsSubscriber.swift:144-173`

#### Scenario: Disconnect prevents retry attempts

**Given** disconnect() is called during active subscriptions
**When** subscriptions are retrying or active
**Then** the subscriber SHALL:
- Set `isDisconnected = true` flag
- Cancel ongoing retry delay task
- Resume all waiting retry continuations
- Call `appSyncEventsClient.disconnect()`
- All subscription tasks check `isDisconnected` and stop
- Prevent any further retry attempts

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/BackendAppSyncEventsSubscriber.swift:109-126`

#### Scenario: Reset disconnect flag on new subscription

**Given** disconnect() was called previously
**When** subscribe() is called again (e.g., after organization change)
**Then** the subscriber SHALL:
- Reset `isDisconnected = false` at start of subscribe()
- Allow new subscriptions to proceed normally
- Enable retry mechanism for new subscriptions

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/BackendAppSyncEventsSubscriber.swift:55-56`

### Requirement: Existing Output Models with Optional Metadata

The iOS app SHALL reuse all existing Output model structs, adding optional `eventType` and `timestamp` fields for AppSync Events metadata while maintaining full backward compatibility.

#### Scenario: Add optional metadata to DeviceStateOutput

**Given** AppSync Events delivers device events with metadata
**When** events are decoded
**Then** DeviceStateOutput SHALL:
- Keep all existing fields: `sub`, `deviceGroupID`, `mac`, `derivant`, `online`, `recording`, `fwUpdateState`, `thingName`
- Add optional `eventType: String?` field (e.g., "device/presenceChanged")
- Add optional `timestamp: String?` field (ISO 8601 format)
- All new fields are optional for backward compatibility
- Existing consumers work without changes

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Subscribe/DeviceStateOutput.swift:1-30`

#### Scenario: Add optional metadata to OrganizationStateOutput

**Given** AppSync Events delivers organization events with metadata
**When** events are decoded
**Then** OrganizationStateOutput SHALL:
- Keep all existing fields: `isFreePlan`, `AIControlSetting`, `licensePhase`
- Add optional `eventType: String?` field (e.g., "organization/licensePhaseChanged")
- Add optional `timestamp: String?` field (ISO 8601 format)
- All new fields are optional for backward compatibility

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Subscribe/OrganizationStateOutput.swift:1-20`

#### Scenario: Add optional metadata to remaining Output models

**Given** AppSync Events delivers archive/role/token events
**When** events are decoded
**Then** the app SHALL:
- Update `ArchiveStateOutput` with optional `eventType` and `timestamp`
- Update `RoleChangeOutput` with optional `eventType` and `timestamp`
- Update `UserTokenRevokeOutput` with optional `eventType` and `timestamp`
- Maintain all existing fields unchanged
- All metadata fields are optional

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Subscribe/ArchiveStateOutput.swift`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Subscribe/RoleChangeOutput.swift`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Subscribe/UserTokenRevokeOutput.swift`

### Requirement: Factory Methods for Dependency Injection

The iOS app SHALL provide factory methods in `AWSServices` and `VortexFeatures` modules following the existing pattern for creating AppSync Events clients and subscribers.

#### Scenario: Create AppSyncEventsClient via factory

**Given** the app needs an AppSyncEventsClient instance
**When** `AWSServices.makeAppSyncEventsClient(endpointURL:)` is called
**Then** the factory SHALL:
- Accept endpoint URL as parameter
- Inject `authService` dependency
- Create and return `AppSyncEventsClient` instance
- Use `withDependencies` for dependency injection

**File references**:
- `VortexFeatures/Sources/AWSServices/AWSServices.swift:35-41`

#### Scenario: Create BackendAppSyncEventsSubscriber via factory

**Given** the app needs a subscriber instance
**When** `VortexFeatures.appSyncEventsSubscriber()` is called
**Then** the factory SHALL:
- Read endpoint URL from `VortexEnvironment.appSyncEventsURL`
- Create `AppSyncEventsClient` via `AWSServices.makeAppSyncEventsClient()`
- Inject `appSyncEventsClient` and `vortexAuthService` dependencies
- Create and return `BackendAppSyncEventsSubscriber` instance

**File references**:
- `VortexFeatures/Sources/VortexFeatures/VortexFeatures.swift:41-52`

#### Scenario: BackendNotifier uses factory-created subscriber

**Given** BackendNotifier needs to subscribe to AppSync Events
**When** BackendNotifier is initialized
**Then** it SHALL:
- Call `VortexFeatures.appSyncEventsSubscriber()` to get subscriber instance
- Store reference in private property
- Use subscriber for all subscription operations

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:20`

## MODIFIED Requirements

### Requirement: BackendNotifier Migration (**NO BREAKING CHANGES**, Wildcard Pattern)

BackendNotifier subscription implementation SHALL use AppSync Events with wildcard pattern subscriptions internally while preserving all existing public APIs for zero-impact migration.

#### Scenario: Preserve all existing public methods

**Given** the iOS app migrates to AppSync Events
**When** BackendNotifier methods are called
**Then** the app SHALL:
- **PRESERVE** `deviceValues() -> AsyncStream<DeviceStateOutput>` (uses device/* wildcard internally)
- **PRESERVE** `organizationValues() -> AsyncStream<OrganizationStateOutput>` (uses organization/* wildcard internally)
- **PRESERVE** `archiveValues() -> AsyncStream<ArchiveStateOutput>`
- **PRESERVE** `roleValues() -> AsyncStream<RoleChangeOutput>`
- **PRESERVE** `revokeValues() -> AsyncStream<UserTokenRevokeOutput>`
- **ZERO breaking changes** - all existing consumers work without modification

**Rationale**: Wildcard subscriptions enable API preservation, avoiding consumer code updates

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:67-135`

#### Scenario: Subscribe on organization ID change

**Given** the user's organization ID or userId changes
**When** BackendNotifier detects the change
**Then** the app SHALL:
- Unsubscribe from all active AppSync subscriptions (cancel 5 subscription tasks)
- Disconnect WebSocket via `appSyncSubscriber.disconnect()`
- Reconnect automatically on next subscription (lazy initialization)
- Subscribe to 5 channels with new userId:
  - `device/*` wildcard (yields to deviceObservers)
  - `organization/*` wildcard (yields to organizationObservers)
  - `archive/stateChanged` (yields to archiveObservers)
  - `roleChanged` (yields to roleObservers)
  - `tokenRevoked` (yields to revokeObservers)

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:141-186`

#### Scenario: Graceful stop on app termination

**Given** the app is stopping or user signs out
**When** `stopSubscribing()` is called
**Then** BackendNotifier SHALL:
- Cancel initTask that monitors organization ID changes
- Cancel all 5 subscription tasks
- Call `appSyncSubscriber.disconnect()` to close WebSocket
- Clean up all continuations

**File references**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift:57-65`

## PRESERVED Code (For Rollback)

### GraphQL Subscription Implementation (Unused)

All GraphQL subscription code is **PRESERVED** but unused:
- `GraphQLSubscriber.swift` - Preserved for rollback capability
- `GraphQLSubscription.swift` - Preserved for reference
- GraphQL factory methods - Preserved in codebase

**Rationale**: Enable quick rollback by switching BackendNotifier implementation if issues found in production.

## NO Consumer Code Changes Required

### Zero-Impact Migration

**NO consumer code updates needed** because:
- All existing BackendNotifier methods preserved (deviceValues, organizationValues, archiveValues, roleValues, revokeValues)
- All existing Output model structures unchanged (optional fields only)
- All existing method signatures identical
- Wildcard subscriptions are internal implementation detail

**Consumer code continues to work as-is:**
```swift
// This code works unchanged with AppSync Events migration
for await device in await BackendNotifier.shared.deviceValues() {
    // Handle device state change (presence, recording, firmware)
}

for await org in await BackendNotifier.shared.organizationValues() {
    // Handle organization state change (license, plan, AI settings)
}
```

## Dependencies

This spec depends on:
- Backend AppSync Events infrastructure deployment
- **Backend OpenAPI schema** - All channels use user-level pattern: `vortex-app/user/{userId}/*`
- Backend handles all authorization server-side (client receives only authorized events)
- AWS AppSync Events Swift SDK (`https://github.com/aws-amplify/aws-appsync-events-swift`) via Swift Package Manager
- SDK provides `Events` and `EventsWebSocketClient` for connection and subscription management

## Testing Requirements

All scenarios SHALL be covered by:

### Unit Tests
- ✅ `BackendAppSyncEventsSubscriberTest.swift` - Comprehensive subscriber tests
  - Subscribe successfully and receive events
  - Handle user ID fetch failure
  - Handle decoding failures
  - Verify channel name format
  - Automatic retry on connection errors
  - Stop on user sign-out
  - Disconnect prevents further retries
  - Multiple tasks coordinate retry delay
  - User sign-out during retry delay
  - Multiple retry cycles
  - Resubscribe after disconnect
- `MockAppSyncEventsClient` provides test control for event simulation
- All tests use configurable retry delay (100ms in tests vs 10s in production)

### Integration Tests (Pending)
- `BackendNotifierAppSyncTests.swift` - Test wildcard subscriptions
- Schema validation tests comparing Swift types to OpenAPI schema
- Staging environment testing with real AppSync Events endpoint

### Manual Testing (Staging)
- ✅ Connection establishment verified in TestFlight
- ✅ Device events (presence, recording, firmware) working
- Authorization testing (user receives only authorized events)
- Reconnection testing (airplane mode, app backgrounding)
- Organization change testing (switch org triggers resubscribe)
- Error scenarios (expired token, malformed events)
