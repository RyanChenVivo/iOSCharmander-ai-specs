# iOS AppSync Events Migration Tasks

## Phase 0: Preparation

### 0.1 Dependencies and Schema Review
- [ ] Add AWS AppSync Events Swift SDK (`https://github.com/aws-amplify/aws-appsync-events-swift`) to Swift Package Manager dependencies
- [ ] Review SDK documentation and `AppSyncEventBridgeClient` API
- [ ] Review SDK authentication options (JWT token provider)
- [ ] Review latest OpenAPI schema (`/Users/ryanchen/Downloads/Default module.openapi.yaml`)
- [ ] Identify schema changes (9 channels vs 7 in original proposal)
- [ ] Document all event payload structures
- [ ] Coordinate with backend team on staging environment access

### 0.2 Development Environment Setup
- [ ] Configure staging AppSync Events endpoint URLs
- [ ] Obtain test Cognito JWT tokens for staging
- [ ] Set up test organization with proper permissions
- [ ] Verify backend dual-publishing is enabled in staging
- [ ] Test WebSocket connectivity to staging endpoint

## Phase 1: AWSServices Layer Implementation

### 1.1 Protocol Definition
- [ ] Create `AWSServices/AWSAppSyncEvents/AppSyncEventsClientProtocol.swift`
- [ ] Define `connect(region:endpoint:)` method signature
- [ ] Define `subscribe(channels:)` returning AsyncStream
- [ ] Define `unsubscribe()` and `disconnect()` methods
- [ ] Mark protocol as `Sendable`
- [ ] Add comprehensive documentation comments

**File**: `VortexFeatures/Sources/AWSServices/AWSAppSyncEvents/AppSyncEventsClientProtocol.swift`

### 1.2 SDK Wrapper Implementation
- [ ] Create `AWSServices/AWSAppSyncEvents/AppSyncEventsClientWrapper.swift`
- [ ] Import `AppSyncEventsSDK` from `aws-appsync-events-swift` package
- [ ] Create `AppSyncEventBridgeClient` instance with config
- [ ] Implement JWT token provider conforming to SDK's auth protocol
- [ ] Configure `AppSyncEventBridgeConfig` with endpoint, region, auth provider
- [ ] Use SDK's `connect()` method (no manual WebSocket handling needed)
- [ ] Use SDK's `subscribe(to:)` method for channel subscriptions
- [ ] Map SDK errors to VortexError types
- [ ] Add VortexLogger integration (trace, debug, error levels)
- [ ] Make wrapper an Actor for thread safety

**File**: `VortexFeatures/Sources/AWSServices/AWSAppSyncEvents/AppSyncEventsClientWrapper.swift`

### 1.3 Client Actor Implementation
- [ ] Create `AWSServices/AWSAppSyncEvents/AppSyncEventsClient.swift` as Actor
- [ ] Implement AppSyncEventsClientProtocol
- [ ] Inject `@Dependency(\.vortexAuthService)` for JWT tokens
- [ ] Inject `@Dependency(\.appSyncEventsClientWrapper)` for SDK access
- [ ] Delegate connection management to SDK's `AppSyncEventBridgeClient`
- [ ] Implement subscribe/unsubscribe logic using SDK's `subscribe(to:)` method
- [ ] Configure SDK reconnection behavior (use SDK's built-in reconnection with 10-second delay if configurable)
- [ ] Check user sign-in status before reconnecting
- [ ] Handle SDK connection state changes (connected, disconnected, error)
- [ ] Implement graceful disconnect on user sign-out
- [ ] Map SDK's AsyncStream/events to our AsyncStream interface

**File**: `VortexFeatures/Sources/AWSServices/AWSAppSyncEvents/AppSyncEventsClient.swift`

### 1.4 Event Types Definition
- [ ] Create `AWSServices/AWSAppSyncEvents/AppSyncEventTypes.swift`
- [ ] Define 9 channel path constants matching latest schema (all user-level: `vortex-app/user/{userId}/*`)
- [ ] Define event type constants (e.g., "device/presenceChanged", "organization/licensePhaseChanged")
- [ ] Add helper methods for channel path construction with userId
- [ ] Document mapping between GraphQL subscriptions and AppSync user-level channels

**File**: `VortexFeatures/Sources/AWSServices/AWSAppSyncEvents/AppSyncEventTypes.swift`

### 1.5 Unit Tests - AWSServices Layer
- [ ] Create `VortexFeaturesTests/AWSServices/AppSyncEventsClientTests.swift`
- [ ] Test connection lifecycle (connect, disconnect, reconnect)
- [ ] Test subscription flow with mock wrapper
- [ ] Test error mapping (authentication failure, timeout, subscription failure)
- [ ] Test SDK error handling and transformation to VortexError
- [ ] Test sign-out during connection (should cancel)
- [ ] Mock AppSyncEventsClientWrapper (mock the SDK) for isolated testing
- [ ] Test AsyncStream interface matches protocol expectations

**File**: `VortexFeatures/Tests/VortexFeaturesTests/AWSServices/AppSyncEventsClientTests.swift`

## Phase 2: BackendSubscriber Extension

### 2.1 AppSync Events Subscriber Protocol
- [ ] Create `BackendSubscriber/AppSyncEventsSubscriber.swift`
- [ ] Define `AppSyncEventsSubscriber` protocol
- [ ] Add `subscribe<R>(_ subscription:returning:)` method returning AsyncThrowingStream
- [ ] Add `unsubscribe()` method
- [ ] Mark protocol as `Sendable`
- [ ] Implement `VortexAppSyncEventsSubscriber` actor
- [ ] Inject `@Dependency(\.appSyncEventsClient)` for AppSync client
- [ ] **NO event filtering needed** - backend handles all authorization
- [ ] Implement event parsing from AppSync Events message format
- [ ] Parse events directly without filtering (user-level channels provide only authorized events)
- [ ] Add VortexLogger integration

**File**: `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/AppSyncEventsSubscriber.swift`

### 2.2 AppSync Events Subscription Types
- [ ] Create `BackendSubscriber/AppSyncEventsSubscription.swift`
- [ ] Define `AppSyncEventsSubscription` protocol with `channelName` and `eventType` properties
- [ ] Implement `DevicePresenceSubscription` struct (channel: `vortex-app/user/{userId}/device/presenceChanged`)
- [ ] Implement `DeviceRecordingSubscription` struct (channel: `vortex-app/user/{userId}/device/recordingStateChanged`)
- [ ] Implement `DeviceFirmwareSubscription` struct (channel: `vortex-app/user/{userId}/device/firmwareUpdated`)
- [ ] Implement `ArchiveStateEventsSubscription` struct (channel: `vortex-app/user/{userId}/archive/stateChanged`)
- [ ] Implement `LicensePhaseSubscription` struct (channel: `vortex-app/user/{userId}/organization/licensePhaseChanged`) - NEW
- [ ] Implement `PlanTypeSubscription` struct (channel: `vortex-app/user/{userId}/organization/planChanged`) - NEW
- [ ] Implement `AISettingsSubscription` struct (channel: `vortex-app/user/{userId}/organization/aiSettingsChanged`) - NEW
- [ ] Implement `RoleChangeEventsSubscription` struct (channel: `vortex-app/user/{userId}/roleChanged`)
- [ ] Implement `UserTokenRevokeEventsSubscription` struct (channel: `vortex-app/user/{userId}/tokenRevoked`)
- [ ] Document ALL user-level channel paths and event types for each subscription

**File**: `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/AppSyncEventsSubscription.swift`

### 2.3 Unit Tests - BackendSubscriber Layer
- [ ] Create `VortexFeaturesTests/BackendSubscriber/AppSyncEventsSubscriberTests.swift`
- [ ] Test subscription flow with mock AppSyncEventsClient
- [ ] Test event parsing and decoding
- [ ] Verify NO filtering applied (all events received are already authorized)
- [ ] Test user-level channel subscription (userId matching)
- [ ] Test error handling for invalid event payloads

**File**:
- `VortexFeatures/Tests/VortexFeaturesTests/Common/VortexBackend/AppSyncEventsSubscriberTests.swift`

## Phase 3: BackendNotifier Integration

### 3.1 Internal AppSync Event Models (for parsing only)
- [ ] Create `Model/Subscribe/Internal/AppSyncDeviceEvent.swift`
- [ ] Define struct with `eventType`, `timestamp`, `online`, `recording`, `fwUpdateState` fields
- [ ] Conform to `Decodable` and `Sendable`
- [ ] Create `Model/Subscribe/Internal/AppSyncLicenseEvent.swift`
- [ ] Define struct with `eventType`, `timestamp`, `orgId`, `licensePhase` fields
- [ ] Create `Model/Subscribe/Internal/AppSyncPlanEvent.swift`
- [ ] Define struct with `eventType`, `timestamp`, `orgId`, `isFreePlan` fields
- [ ] Create `Model/Subscribe/Internal/AppSyncAISettingsEvent.swift`
- [ ] Define struct with `eventType`, `timestamp`, `orgId`, `AIControlSetting` fields
- [ ] These models are INTERNAL only - map to existing public models

**Files**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Subscribe/Internal/AppSyncDeviceEvent.swift`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Subscribe/Internal/AppSyncLicenseEvent.swift`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Subscribe/Internal/AppSyncPlanEvent.swift`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Subscribe/Internal/AppSyncAISettingsEvent.swift`

### 3.2 New Device Event Output Models
- [ ] Create `Model/Subscribe/DevicePresenceOutput.swift`
- [ ] Define struct with `eventType: "device/presenceChanged"`, `timestamp`, `orgId`, `siteId`, `thingName`, `mac`, `derivant`, `online` fields
- [ ] Create `Model/Subscribe/DeviceRecordingOutput.swift`
- [ ] Define struct with `eventType: "device/recordingStateChanged"`, `timestamp`, `orgId`, `siteId`, `thingName`, `mac`, `derivant`, `recording` fields
- [ ] Create `Model/Subscribe/DeviceFirmwareOutput.swift`
- [ ] Define struct with `eventType: "device/firmwareUpdated"`, `timestamp`, `orgId`, `siteId`, `thingName`, `mac`, `derivant`, `fwUpdateState` fields
- [ ] All conform to `Decodable` and `Sendable`
- [ ] Note: `siteId` is metadata only, NOT for filtering

**Files**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Subscribe/DevicePresenceOutput.swift`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Subscribe/DeviceRecordingOutput.swift`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Subscribe/DeviceFirmwareOutput.swift`

### 3.3 New Organization State Output Models
- [ ] Create `Model/Subscribe/LicenseStateOutput.swift`
- [ ] Define struct with `eventType`, `timestamp`, `orgId`, `licensePhase` fields
- [ ] Create `Model/Subscribe/PlanStateOutput.swift`
- [ ] Define struct with `eventType`, `timestamp`, `orgId`, `isFreePlan` fields
- [ ] Create `Model/Subscribe/AISettingsOutput.swift`
- [ ] Define struct with `eventType`, `timestamp`, `orgId`, `aiControlSetting` fields
- [ ] All conform to `Decodable` and `Sendable`

**Files**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Subscribe/LicenseStateOutput.swift`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Subscribe/PlanStateOutput.swift`
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Subscribe/AISettingsOutput.swift`

### 3.4 BackendNotifier Migration (**BREAKING CHANGE**, GraphQL Preserved)
- [ ] Update `BackendNotifier.swift`
- [ ] **DELETE** `deviceValues() -> AsyncStream<DeviceStateOutput>` method from BackendNotifier
- [ ] **DELETE** `organizationValues() -> AsyncStream<OrganizationStateOutput>` method from BackendNotifier
- [ ] **KEEP** GraphQL subscription methods in BackendNotifier (commented out or unused)
- [ ] **ADD** `devicePresenceValues() -> AsyncStream<DevicePresenceOutput>` method (NEW)
- [ ] **ADD** `deviceRecordingValues() -> AsyncStream<DeviceRecordingOutput>` method (NEW)
- [ ] **ADD** `deviceFirmwareValues() -> AsyncStream<DeviceFirmwareOutput>` method (NEW)
- [ ] **ADD** `archiveValues() -> AsyncStream<ArchiveStateOutput>` using AppSync Events
- [ ] **ADD** `licenseValues() -> AsyncStream<LicenseStateOutput>` method (NEW)
- [ ] **ADD** `planValues() -> AsyncStream<PlanStateOutput>` method (NEW)
- [ ] **ADD** `aiSettingsValues() -> AsyncStream<AISettingsOutput>` method (NEW)
- [ ] **ADD** `roleValues() -> AsyncStream<RoleChangeOutput>` using AppSync Events
- [ ] **ADD** `revokeValues() -> AsyncStream<UserTokenRevokeOutput>` using AppSync Events
- [ ] Update `handleOrganizationIDChanged()` to subscribe to 9 AppSync channels separately
- [ ] Add 9 separate subscription tasks (one for each channel, NO merging)
- [ ] Update `unsubscribeAll()` to cancel all 9 AppSync subscription tasks
- [ ] **PRESERVE** GraphQL implementation files (for rollback)

**File**: `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendNotifier/BackendNotifier.swift`

**Files to PRESERVE (not delete)**:
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/GraphQLSubscriber.swift` - **Keep**
- `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/BackendSubscriber/GraphQLSubscription.swift` - **Keep**

### 3.5 Factory Provider Updates
- [ ] Update `VortexFactoryProvider.swift`
- [ ] **KEEP** GraphQL factory methods (preserved but unused)
- [ ] **ADD** factory method for `AppSyncEventsClient`
- [ ] **ADD** factory method for `AppSyncEventsClientWrapper`
- [ ] **ADD** factory method for `AppSyncEventsSubscriber`
- [ ] Register dependencies in DependencyValues extension
- [ ] Both GraphQL and AppSync Events factories coexist

**File**: `VortexFeatures/Sources/VortexFeatures/VortexFactoryProvider.swift`

### 3.6 Integration Tests - BackendNotifier
- [ ] Create `VortexFeaturesTests/BackendNotifier/BackendNotifierAppSyncTests.swift`
- [ ] Test 3 separate device streams: `devicePresenceValues()`, `deviceRecordingValues()`, `deviceFirmwareValues()`
- [ ] Test `archiveValues()` returns AppSync Events stream
- [ ] Test 3 separate organization streams: `licenseValues()`, `planValues()`, `aiSettingsValues()`
- [ ] Test `roleValues()` and `revokeValues()` return AppSync Events streams
- [ ] Mock AppSyncEventsSubscriber
- [ ] Verify all 9 channels are subscribed separately (1:1 mapping)

**File**: `VortexFeatures/Tests/VortexFeaturesTests/Common/BackendNotifier/BackendNotifierAppSyncTests.swift`

## Phase 4: Schema Validation

### 4.1 Schema Comparison
- [ ] Compare Swift event types with latest OpenAPI schema
- [ ] Verify `DevicePresenceChanged` schema matches Swift `DeviceStateOutput` (online field)
- [ ] Verify `DeviceRecordingStateChanged` schema matches Swift `DeviceStateOutput` (recording field)
- [ ] Verify `DeviceFirmwareUpdated` schema matches Swift `DeviceStateOutput` (fwUpdateState field)
- [ ] Verify `ArchiveStateChanged` schema matches Swift `ArchiveStateOutput`
- [ ] Verify `LicensePhaseChanged` schema matches Swift `LicenseStateOutput`
- [ ] Verify `PlanTypeChanged` schema matches Swift `PlanStateOutput`
- [ ] Verify `AISettingsChanged` schema matches Swift `AISettingsOutput`
- [ ] Verify `RoleChanged` schema matches Swift `RoleChangeOutput`
- [ ] Verify `UserTokenRevoked` schema matches Swift `UserTokenRevokeOutput`
- [ ] Document any field name discrepancies (e.g., `orgId` vs `userId`)

### 4.2 Field Mapping Validation
- [ ] Check `eventType` field exists in all Output models
- [ ] Check `timestamp` field exists in all Output models
- [ ] Check `siteId` field exists in device/archive Output models (metadata only - NOT for filtering)
- [ ] Check `orgId` field exists in organization-level Output models
- [ ] Verify enum values match schema (licensePhase, status, reason)
- [ ] Verify nullable fields match schema optionality
- [ ] Confirm NO client-side filtering logic based on `siteId`

### 4.3 Schema Validation Tests
- [ ] Create test suite with real OpenAPI schema samples
- [ ] Test decoding of each event type from schema-compliant JSON
- [ ] Test handling of missing optional fields
- [ ] Test rejection of invalid enum values
- [ ] Test timestamp format parsing (ISO 8601)

**File**: `VortexFeatures/Tests/VortexFeaturesTests/Common/VortexBackend/SchemaValidationTests.swift`

## Phase 5: Consumer Code Migration (**BREAKING CHANGE**)

### 5.1 Find All deviceValues() and organizationValues() Usage
- [ ] Search codebase for all `deviceValues()` calls using grep/search
- [ ] Search codebase for all `organizationValues()` calls using grep/search
- [ ] Document all locations that need migration

**Search commands**:
- `rg "deviceValues\(\)" --type swift`
- `rg "organizationValues\(\)" --type swift`

**Expected locations**:
- **Device events**: `VortexFeatures/Sources/VortexFeatures/Core/DeviceManager/DeviceManager.swift`
- **Organization events**:
  - `iOSCharmander/Common/AppManager/AppManager.swift`
  - `iOSCharmander/Common/FeatureProvider/FeatureToggle.swift`
  - `iOSCharmander/View/SignIn/AIControlSettings/AIControlSettingsView.swift`
  - Other potential files

### 5.2 Migrate Each Consumer
- [ ] **DeviceManager**: Replace `deviceValues()` with 3 separate subscriptions
  - [ ] Use `devicePresenceValues()` for online state changes
  - [ ] Use `deviceRecordingValues()` for recording state changes
  - [ ] Use `deviceFirmwareValues()` for firmware update state changes
  - [ ] Update tests
- [ ] **Organization consumers**: Replace `organizationValues()` with 3 separate subscriptions
  - [ ] Use `licenseValues()` for license phase changes
  - [ ] Use `planValues()` for plan type changes
  - [ ] Use `aiSettingsValues()` for AI settings changes
  - [ ] Update tests for each file
- [ ] Ensure all streams are properly handled concurrently using separate Tasks

**Device events migration pattern**:
```swift
// Before
Task {
    for await device in await backendNotifier.deviceValues() {
        await updateDeviceState(by: device)
    }
}

// After
Task {
    for await presence in await backendNotifier.devicePresenceValues() {
        await updateDeviceState(by: presence)
    }
}
Task {
    for await recording in await backendNotifier.deviceRecordingValues() {
        await updateDeviceState(by: recording)
    }
}
Task {
    for await firmware in await backendNotifier.deviceFirmwareValues() {
        await updateDeviceState(by: firmware)
    }
}
```

**Organization events migration pattern**:
```swift
// Before
for await orgState in await BackendNotifier.shared.organizationValues() {
    if let licensePhase = orgState.licensePhase { ... }
    if let isFreePlan = orgState.isFreePlan { ... }
    if let aiSettings = orgState.AIControlSetting { ... }
}

// After
Task {
    for await license in await BackendNotifier.shared.licenseValues() {
        handleLicenseChange(license.licensePhase)
    }
}
Task {
    for await plan in await BackendNotifier.shared.planValues() {
        handlePlanChange(plan.isFreePlan)
    }
}
Task {
    for await ai in await BackendNotifier.shared.aiSettingsValues() {
        handleAISettings(ai.aiControlSetting)
    }
}
```

### 5.3 Update All Tests
- [ ] Update unit tests to use 3 separate organization streams
- [ ] Update integration tests
- [ ] Update mock BackendNotifier to provide 3 separate methods
- [ ] Remove any references to `organizationValues()`

### 5.4 Compiler Verification
- [ ] Remove old `deviceValues()` method definition
- [ ] Remove old `organizationValues()` method definition
- [ ] Compile project - compiler will find any missed usages
- [ ] Fix all compiler errors for both device and organization methods
- [ ] Ensure clean build with zero warnings about missing methods

## Phase 6: Dev Environment Testing

### 6.1 Staging Connection Testing
- [ ] Deploy code to TestFlight beta build
- [ ] Connect to staging AppSync Events endpoint using SDK
- [ ] Verify SDK connection establishes successfully
- [ ] Verify all 9 channel subscriptions are active
- [ ] Check SDK logs for connection and subscription confirmation
- [ ] Verify JWT token is correctly passed to SDK's auth provider

### 6.2 Event Delivery Testing
- [ ] Trigger device online/offline state change in staging
- [ ] Verify `device/presenceChanged` event received
- [ ] Trigger device recording start/stop
- [ ] Verify `device/recordingStateChanged` event received
- [ ] Trigger firmware update
- [ ] Verify `device/firmwareUpdated` event received
- [ ] Create archive
- [ ] Verify `archive/stateChanged` event received
- [ ] Change license phase
- [ ] Verify `license/phaseChanged` event received
- [ ] Change plan type
- [ ] Verify `plan/typeChanged` event received
- [ ] Update AI settings
- [ ] Verify `ai/settingsChanged` event received
- [ ] Change user role
- [ ] Verify `user/roleChanged` event received
- [ ] Revoke token
- [ ] Verify `user/tokenRevoked` event received

### 6.3 Authorization Testing (Server-Side)
- [ ] Test with user having access to specific devices/sites
- [ ] Verify device events received only for authorized devices (backend filtering)
- [ ] Verify archive events received only for authorized archives (backend filtering)
- [ ] Verify organization events received only for user's organization (backend filtering)
- [ ] Verify user-level events received only for user's own channel (backend filtering)
- [ ] Test with user having no device access (should receive no device/archive events from backend)

### 6.4 Reconnection Testing
- [ ] Enable airplane mode to disconnect
- [ ] Verify SDK's automatic reconnection when network returns
- [ ] Verify all subscriptions re-established after reconnect
- [ ] Background/foreground app transitions
- [ ] Verify SDK handles connection lifecycle during app state changes
- [ ] Test sign-out during reconnection (should cancel reconnect)
- [ ] Monitor SDK reconnection logs and delays

### 6.5 Organization Change Testing
- [ ] Switch organization in app
- [ ] Verify old subscriptions unsubscribed
- [ ] Verify new subscriptions established with new organization ID
- [ ] Verify events received for new organization only

### 6.6 Error Scenario Testing
- [ ] Test with expired JWT token (should fail authorization)
- [ ] Test with invalid endpoint URL (should log error)
- [ ] Test with malformed event payload (should log error, not crash)
- [ ] Test with missing required fields (should log error, not crash)

## Phase 7: Staging and Production Deployment

### 7.1 Staging Validation
- [ ] Deploy to staging environment with AppSync Events
- [ ] Run full regression testing
- [ ] Verify all 9 AppSync channels working correctly
- [ ] Monitor staging logs for errors
- [ ] Measure event delivery latency (target: <1s P99)
- [ ] Performance testing (memory, battery, CPU usage)
- [ ] Security validation
- [ ] QA sign-off required before production

### 7.2 Production Deployment (One-Time Switch)
- [ ] Deploy to production with AppSync Events
- [ ] Monitor deployment process closely
- [ ] Verify app launches successfully
- [ ] Check initial connection metrics
- [ ] Monitor for any immediate issues

### 7.3 Post-Deployment Monitoring (First 48 Hours)
- [ ] Monitor crash rates (should not increase)
- [ ] Monitor event delivery success rate
- [ ] Monitor reconnection frequency
- [ ] Monitor memory usage
- [ ] Monitor battery usage
- [ ] Check Crashlytics for AppSync-related issues
- [ ] Monitor backend AppSync Events infrastructure

### 7.4 Rollback Plan (If Needed)
- [ ] GraphQL code already preserved in codebase (no need for separate branch)
- [ ] Document rollback procedure:
  1. Update BackendNotifier to use GraphQL methods instead of AppSync Events
  2. Build and test hotfix quickly
  3. Deploy hotfix to production (estimated 1-2 hours, faster than before)
  4. Backend continues dual-publishing (no backend change needed)
- [ ] Test rollback procedure in staging before production deployment
- [ ] Keep GraphQL code in codebase for 2-4 weeks minimum after deployment

### 7.5 Extended Monitoring (2-4 Weeks)
- [ ] Continue monitoring all metrics
- [ ] Collect user feedback
- [ ] Address any issues found
- [ ] Confirm migration successful
- [ ] Document lessons learned

## Phase 8: Documentation and Cleanup

### 8.1 Update Documentation
- [ ] Update CHANGELOG with migration details
- [ ] Document new AppSync Events architecture
- [ ] Remove GraphQL subscription documentation
- [ ] Update developer onboarding guide
- [ ] Update architecture diagrams

### 8.2 Code Cleanup (Optional, after stable operation)
- [ ] Review internal AppSync event models - consider simplifying if possible
- [ ] Remove any temporary debugging code added during migration
- [ ] Clean up comments and TODOs

### 8.3 Optional: Delete GraphQL Code (after 2-4 weeks)
- [ ] After 2-4 weeks of stable AppSync Events operation
- [ ] Consider deleting GraphQL subscription files if no issues found:
  - `GraphQLSubscriber.swift`
  - `GraphQLSubscription.swift`
  - GraphQL factory methods from `VortexFactoryProvider`
- [ ] OR keep GraphQL code permanently as fallback reference
- [ ] Close any migration-related tickets

## Validation Checklist

Before marking this migration as complete, verify:

**Functionality**:
- [ ] All 9 AppSync Events channels receive events correctly
- [ ] Device presence (online/offline) updates work
- [ ] Device recording state updates work
- [ ] Firmware update progress works
- [ ] Archive processing state updates work
- [ ] License phase changes trigger UI updates
- [ ] Plan type changes trigger UI updates
- [ ] AI settings changes trigger UI updates
- [ ] Role changes trigger privilege refresh
- [ ] Token revoke triggers sign-out

**Authorization (Server-Side)**:
- [ ] Device events received only for authorized devices (backend handles filtering)
- [ ] Archive events received only for authorized archives (backend handles filtering)
- [ ] Organization events received only for user's organization (backend handles filtering)
- [ ] User-level events received correctly for user's channel (backend handles filtering)

**Connection Management**:
- [ ] Reconnection works after network interruption (10-second delay)
- [ ] Reconnection cancelled if user signs out
- [ ] Organization change triggers unsubscribe and resubscribe
- [ ] App backgrounding/foregrounding handled correctly
- [ ] No connection leaks over 24+ hours

**Schema Compliance**:
- [ ] All event types validated against latest OpenAPI schema
- [ ] Field names match schema exactly
- [ ] Event types match schema exactly
- [ ] Enum values match schema

**Performance**:
- [ ] Event delivery latency <1s P99
- [ ] Memory usage within acceptable limits (<90KB for 9 subscriptions)
- [ ] No CPU spikes during event processing

**Testing**:
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Manual testing completed in staging
- [ ] Beta testing completed with no critical issues
- [ ] Production monitoring shows stable metrics

**Code Quality**:
- [ ] No GraphQL subscription usage remains in codebase
- [ ] Code follows project conventions (AWSMqttClient pattern)
- [ ] Documentation complete and accurate
- [ ] CHANGELOG updated

**Cleanup**:
- [ ] GraphQL subscription code removed (after 2-4 weeks stable operation)
- [ ] Factory methods cleaned up
- [ ] Tests updated
- [ ] Documentation updated
