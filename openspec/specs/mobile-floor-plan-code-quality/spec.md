# mobile-floor-plan-code-quality Specification

## Purpose
TBD - created by archiving change refactor-floor-plan-code-quality. Update Purpose after archive.
## Requirements
### Requirement: Floor Plan ViewModel Unit Test Coverage
The floor plan feature SHALL have comprehensive unit test coverage for all ViewModels and business logic to ensure reliability and prevent regressions.

#### Scenario: FloorPlanTabViewModel has 80%+ test coverage
- **WHEN** FloorPlanTabViewModel is tested
- **THEN** unit tests cover at least 80% of code paths
- **AND** tests verify site filtering and grouping logic
- **AND** tests verify view mode toggle (grid/list) persistence
- **AND** tests verify floor plan search functionality
- **AND** tests verify pull-to-refresh behavior
- **AND** tests verify empty state handling
- **AND** tests verify API failure scenarios
- **AND** tests verify API calls are made with correct parameters

#### Scenario: FloorPlanDetailViewModel has 80%+ test coverage
- **WHEN** FloorPlanDetailViewModel is tested
- **THEN** unit tests cover at least 80% of code paths
- **AND** tests verify device selection and deselection logic
- **AND** tests verify streaming lifecycle management
- **AND** tests verify zoom and pan state transitions
- **AND** tests verify device status updates (online/offline/updating)
- **AND** tests verify full-screen mode toggle
- **AND** tests verify camera switching with cleanup delay
- **AND** tests verify view dismissal cleanup
- **AND** tests verify device position API calls with correct floor plan ID

#### Scenario: Use MockVortexRestfulApi for testing
- **WHEN** floor plan ViewModels are tested
- **THEN** tests use MockVortexRestfulApi as dependency
- **AND** mock provides realistic floor plan list responses
- **AND** mock provides realistic device position responses
- **AND** mock can simulate API failures for error testing

### Requirement: Production Code Must Not Contain Mock Data
The floor plan implementation SHALL NOT include mock or fake data in production code to maintain code quality and prevent accidental data leakage.

#### Scenario: No mock data flags in production code
- **WHEN** floor plan code is built for production
- **THEN** no `useMockData` flags exist in ViewModels
- **AND** no conditional mock data toggles exist in production code
- **AND** no fake data generation logic exists outside test targets

#### Scenario: Mock data only in test targets
- **WHEN** mock data is needed for testing
- **THEN** mock data exists only in test targets (iOSCharmanderTests)
- **AND** mock data is provided via MockVortexRestfulApi
- **AND** production code has no references to mock data

### Requirement: Dependency Injection for API Access
The floor plan feature SHALL use dependency injection pattern instead of singleton managers for API access to improve testability and follow project architecture conventions.

#### Scenario: ViewModels use injected VortexRestfulApi dependency
- **WHEN** FloorPlanTabViewModel needs to fetch floor plan data
- **THEN** ViewModel uses `@Dependency(\.vortexRestfulApi)` injection
- **AND** ViewModel calls API methods directly on injected dependency
- **AND** no singleton manager (FloorPlanManager) is used

#### Scenario: FloorPlanManager singleton is removed
- **WHEN** floor plan code is refactored
- **THEN** FloorPlanManager.swift file is deleted
- **AND** all references to FloorPlanManager singleton are removed
- **AND** API calls are made directly via injected vortexRestfulApi

#### Scenario: API calls in ViewModels are testable
- **WHEN** ViewModels use dependency injection
- **THEN** tests can inject MockVortexRestfulApi
- **AND** API behavior can be mocked and verified in tests
- **AND** no network calls are made during unit tests

#### Scenario: ViewModels use injected DeviceManager dependency
- **WHEN** FloorPlanTabViewModel needs to access site data
- **THEN** ViewModel uses `@Dependency(\.deviceManager)` injection
- **AND** ViewModel calls `deviceManager.allSites()` instead of accessing `.sites` property
- **AND** no direct `DeviceManager.shared` access is used

#### Scenario: DeviceManager injection enables test isolation
- **WHEN** ViewModels use DeviceManager dependency injection
- **THEN** tests can inject MockDeviceManager with predefined test sites
- **AND** tests verify behavior with different site configurations (empty, single, multiple sites)
- **AND** no shared global state is accessed during unit tests

### Requirement: Floor Plan Data Management
The system SHALL manage floor plan data and delegate error handling to ViewModels following separation of concerns.

#### Scenario: Handle API failure gracefully
- **WHEN** floor plan API request fails
- **THEN** FloorPlanManager logs error via VortexLogger
- **AND** FloorPlanManager throws error to ViewModel (does NOT call AppManager.handleError)
- **AND** ViewModel calls `appManager.handleError(error, defaultAlert:)` to display error to user
- **AND** user can retry via pull-to-refresh
- **AND** system does not crash or show mock data

### Requirement: SwiftUI Background Modifier Standardization
The floor plan views SHALL use standardized SwiftUI background modifier pattern for consistency with project code style.

#### Scenario: Use background modifier with shape parameter
- **WHEN** floor plan views need background with rounded corners
- **THEN** views use `.background(_:in:)` modifier pattern
- **AND** example: `.background(.colorOverVideoSurface01, in: .rect(cornerRadius: 8))`
- **AND** does NOT use `.background { RoundedRectangle(...) }` closure pattern

#### Scenario: SelectedDeviceInfoPanel uses standardized background
- **WHEN** SelectedDeviceInfoPanel displays device info badges
- **THEN** background uses `.background(.colorOverVideoSurface01.opacity(0.6), in: .rect(cornerRadius: 16))`
- **AND** does NOT use custom RoundedRectangle in closure
- **AND** UI appearance remains identical to previous implementation

### Requirement: Centralized Error Handling via AppManager
Floor Plan ViewModels SHALL use AppManager dependency to handle all user-facing errors consistently, ensuring proper error presentation across the application.

#### Scenario: Inject AppManager dependency in ViewModels
- **WHEN** FloorPlanTabViewModel or FloorPlanDetailViewModel is initialized
- **THEN** ViewModel injects `@Dependency(\.appManager)` following existing MVVM patterns
- **AND** factory method `.make()` includes `$0.appManager = AppManager.shared` in `withDependencies` block
- **AND** follows same pattern as other ViewModels (ArchiveTabViewModel, MessageTabViewModel)

#### Scenario: Handle errors in FloorPlanTabViewModel onViewAppear
- **WHEN** `fetchAllFloorPlans()` throws an error in `onViewAppear()`
- **THEN** ViewModel calls `appManager.handleError(error, defaultAlert: AlertItem.failToLoad())` on MainActor
- **AND** sets `isLoading = false`
- **AND** user sees appropriate error UI (alert, access denied, session expired, etc.)
- **AND** error is logged for debugging

#### Scenario: Handle errors in FloorPlanTabViewModel pullToRefresh
- **WHEN** `fetchAllFloorPlans()` throws an error in `pullToRefresh()`
- **THEN** ViewModel calls `appManager.handleError(error, defaultAlert: AlertItem.failToLoad())` on MainActor
- **AND** user sees appropriate error UI
- **AND** error is logged for debugging

#### Scenario: Handle errors in FloorPlanDetailViewModel loadDevicePositions
- **WHEN** `fetchDevicePositions()` throws an error in `loadDevicePositions()`
- **THEN** ViewModel calls `appManager.handleError(error, defaultAlert: AlertItem.failToLoad())` on MainActor
- **AND** `devicePositions` remains empty
- **AND** user sees appropriate error UI
- **AND** error is logged for debugging

#### Scenario: Preserve logging for non-critical errors
- **WHEN** floor plan is not found in FloorPlanManager cache during `onViewAppear()`
- **THEN** system logs error message
- **AND** does NOT call `appManager.handleError()` (not a data-fetching error)
- **AND** sets `isLoading = false`

### Requirement: Error Handling Test Coverage
Floor Plan ViewModel tests SHALL verify that AppManager.handleError is called correctly for all error scenarios.

#### Scenario: Test error handling in FloorPlanTabViewModel onViewAppear
- **WHEN** running unit test for failed `onViewAppear()`
- **THEN** test uses `MockAppManager` with `_handleErrorWithDefaultAlert` closure
- **AND** test verifies `handleError()` was called exactly once
- **AND** test verifies error matches the thrown error
- **AND** test verifies `isLoading` is set to false

#### Scenario: Test error handling in FloorPlanTabViewModel pullToRefresh
- **WHEN** running unit test for failed `pullToRefresh()`
- **THEN** test verifies `appManager.handleError()` was called exactly once
- **AND** test verifies error matches the thrown error

#### Scenario: Test error handling in FloorPlanDetailViewModel loadDevicePositions
- **WHEN** running unit test for failed `loadDevicePositions()`
- **THEN** test verifies `appManager.handleError()` was called exactly once
- **AND** test verifies error matches the thrown error
- **AND** test verifies `devicePositions` remains empty

#### Scenario: Test MockAppManager in FloorPlan tests
- **WHEN** FloorPlan tests create ViewModels with MockAppManager
- **THEN** MockAppManager captures all `handleError()` calls using `_handleErrorWithDefaultAlert` closure
- **AND** tests can verify error handling without triggering actual UI
- **AND** follows same mock pattern as other ViewModel tests

