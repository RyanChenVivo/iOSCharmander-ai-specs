# mobile-floor-plan-code-quality

## ADDED Requirements

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

## MODIFIED Requirements

### Requirement: Floor Plan Data Management
The system SHALL manage floor plan data and delegate error handling to ViewModels following separation of concerns.

#### Scenario: Handle API failure gracefully
- **WHEN** floor plan API request fails
- **THEN** FloorPlanManager logs error via VortexLogger
- **AND** FloorPlanManager throws error to ViewModel (does NOT call AppManager.handleError)
- **AND** ViewModel calls `appManager.handleError(error, defaultAlert:)` to display error to user
- **AND** user can retry via pull-to-refresh
- **AND** system does not crash or show mock data
