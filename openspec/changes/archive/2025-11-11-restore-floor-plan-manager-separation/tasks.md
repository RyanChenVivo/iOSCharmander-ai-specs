# Tasks

## Phase 1: Backend Model Creation and API Naming
- [ ] Update API method and output model naming to follow HTTP method convention
  - [ ] Rename listFloorPlans(siteID:) to getFloorPlans(siteID:) in VortexRestfulApiProtocol
  - [ ] Rename listDevicePositions(floorPlanID:) to getDevicePositions(floorPlanID:) in VortexRestfulApiProtocol
  - [ ] Rename ListFloorPlansOutput to GetFloorPlansOutput (match method name)
  - [ ] Rename ListDevicePositionsOutput to GetDevicePositionsOutput (match method name)
  - [ ] Update VortexRestfulApi implementation with new method and type names
  - [ ] Update MockVortexRestfulApi with new method and type names
  - [ ] Update any existing usage of ListFloorPlansOutput and ListDevicePositionsOutput
- [ ] Create FloorPlanBackendModel struct in VortexFeatures/Common/VortexBackend/Model/FloorPlan/
  - [ ] Add all properties matching FloorPlanItem (except deviceCount)
  - [ ] Conform to VortexBackendModel protocol
  - [ ] Add Codable, Sendable conformances
- [ ] Create DevicePositionBackendModel struct in VortexFeatures/Common/VortexBackend/Model/FloorPlan/
  - [ ] Add all properties matching DevicePosition
  - [ ] Conform to VortexBackendModel protocol
  - [ ] Add Codable, Sendable conformances
- [ ] Update GetFloorPlansOutput to use [FloorPlanBackendModel]
- [ ] Update GetDevicePositionsOutput to use [DevicePositionBackendModel]
- [ ] Verify VortexRestfulApi still compiles with Backend models and new method names
- [ ] Run build to verify no errors in API layer

## Phase 2: FloorPlanManager Protocol and Implementation
- [ ] Create FloorPlanManagerProtocol.swift in VortexFeatures/Core/FloorPlanManager/
  - [ ] Define protocol with Sendable conformance
  - [ ] Add fetchFloorPlans(forSiteID:) method
  - [ ] Add fetchDevicePositions(forFloorPlanID:) method
  - [ ] Add fetchAllFloorPlans(sites:) method
- [ ] Update DevicePosition.swift to include essential device information properties
  - [ ] Add deviceCompositeType: DeviceCompositeType property (for lookup if full device needed)
  - [ ] Add deviceName: String? property
  - [ ] Add connectionIcon: String? property (simpleStateIcon)
  - [ ] Add isOnline: Bool property
  - [ ] Add isUpdatingFirmware: Bool property
  - [ ] Add computed property cameraStatus: CameraOverlayStatus
  - [ ] Update init to accept device parameters
  - [ ] Verify NO dependency on full DeviceItem (loose coupling)
- [ ] Create FloorPlanManager.swift in VortexFeatures/Core/FloorPlanManager/
  - [ ] Conform to FloorPlanManagerProtocol
  - [ ] Add @Dependency(\.vortexRestfulApi) property
  - [ ] Add @Dependency(\.deviceManager) property (for device lookup)
  - [ ] Implement fetchFloorPlans with Backend→UI transformation
  - [ ] Implement fetchDevicePositions with Backend→UI transformation AND device pre-population
  - [ ] Implement fetchAllFloorPlans with device count aggregation
  - [ ] Add private transformation method for FloorPlanItem
  - [ ] Add private transformation method for DevicePosition (with device parameter)
  - [ ] Add error handling and logging
- [ ] Register FloorPlanManager dependency in Dependencies+.swift
  - [ ] Add floorPlanManager property to DependencyValues
  - [ ] Create FloorPlanManagerKey with liveValue
- [ ] Verify Manager compiles and dependency registration works

## Phase 3: Mock FloorPlanManager for Tests
- [ ] Create MockFloorPlanManager.swift in iOSCharmanderTests/Mock/
  - [ ] Conform to FloorPlanManagerProtocol
  - [ ] Add optional closure properties for each method
  - [ ] Implement methods to call closures or return defaults
  - [ ] Add Sendable conformance
- [ ] Create helper method to create mock with test data
  - [ ] Add makeMockFloorPlanManager() helper
  - [ ] Return MockFloorPlanManager with realistic test data
  - [ ] Support multiple test scenarios (success, failure, empty)
- [ ] Verify mock compiles and can be used in tests

## Phase 4: FloorPlanManager Unit Tests
- [ ] Create FloorPlanManagerTest.swift in iOSCharmanderTests/Test/
  - [ ] Add @Suite annotation
  - [ ] Create helper methods for mock API creation
- [ ] Add tests for fetchFloorPlans:
  - [ ] test_fetchFloorPlans_shouldReturnUIModels_whenAPISuccess
  - [ ] test_fetchFloorPlans_shouldTransformBackendToUI_correctly
  - [ ] test_fetchFloorPlans_shouldThrowError_whenAPIFails
  - [ ] test_fetchFloorPlans_shouldReturnEmpty_whenAPIReturnsEmpty
- [ ] Add tests for fetchDevicePositions:
  - [ ] test_fetchDevicePositions_shouldReturnUIModels_whenAPISuccess
  - [ ] test_fetchDevicePositions_shouldTransformBackendToUI_correctly
  - [ ] test_fetchDevicePositions_shouldThrowError_whenAPIFails
  - [ ] test_fetchDevicePositions_shouldReturnEmpty_whenNoPositions
- [ ] Add tests for fetchAllFloorPlans:
  - [ ] test_fetchAllFloorPlans_shouldFetchForAllSites_whenMultipleSites
  - [ ] test_fetchAllFloorPlans_shouldPopulateDeviceCounts_correctly
  - [ ] test_fetchAllFloorPlans_shouldReturnEmpty_whenNoSites
  - [ ] test_fetchAllFloorPlans_shouldHandlePartialFailures_gracefully
- [ ] Add tests for error handling:
  - [ ] test_shouldHandleNetworkError_whenAPIUnavailable
  - [ ] test_shouldLogErrors_whenAPIFails
- [ ] Run FloorPlanManager tests and verify 100% pass
- [ ] Verify 80%+ code coverage for FloorPlanManager

## Phase 5: Refactor FloorPlanTabViewModel
- [ ] Update FloorPlanTabViewModel.swift:
  - [ ] Replace @Dependency(\.vortexRestfulApi) with @Dependency(\.floorPlanManager)
  - [ ] Remove fetchFloorPlans(forSiteID:) method (now in Manager)
  - [ ] Remove fetchDevicePositions(forFloorPlanID:) method (now in Manager)
  - [ ] Update fetchAll() to call floorPlanManager.fetchAllFloorPlans(sites:)
  - [ ] Remove any data transformation logic
  - [ ] Keep only UI state management and user interaction methods
  - [ ] Update make() method for dependency injection
- [ ] Verify FloorPlanTabViewModel compiles
- [ ] Run build to check for errors

## Phase 6: Refactor FloorPlanDetailViewModel
- [ ] Update FloorPlanDetailViewModel.swift:
  - [ ] Replace @Dependency(\.vortexRestfulApi) with @Dependency(\.floorPlanManager)
  - [ ] Update loadDevicePositions() to call floorPlanManager.fetchDevicePositions()
  - [ ] Update getDeviceStatus() to use position.cameraStatus (computed property)
  - [ ] Update getSelectedDevice() to lookup via position.deviceCompositeType
  - [ ] Keep findDevice() only for streaming operations (lookup via DeviceCompositeType)
  - [ ] Remove any data transformation logic
  - [ ] Keep only UI state management and user interaction methods
  - [ ] Update make() method for dependency injection
- [ ] Update FloorPlanDetailView.swift:
  - [ ] Replace viewModel.findDevice() calls with position.connectionIcon for marker display
  - [ ] Use position.cameraStatus for status display
  - [ ] Use position.deviceName for name display
  - [ ] Simplify marker rendering code (no findDevice lookup needed)
- [ ] Verify FloorPlanDetailViewModel and View compile
- [ ] Verify NO full DeviceItem dependency in DevicePosition
- [ ] Run build to check for errors

## Phase 7: Update ViewModel Tests
- [ ] Update FloorPlanTabViewModelTest.swift:
  - [ ] Replace MockVortexRestfulApi with MockFloorPlanManager
  - [ ] Update makeViewModel() helper to inject MockFloorPlanManager
  - [ ] Update all test expectations to match new architecture
  - [ ] Remove API call verification tests (moved to Manager tests)
  - [ ] Focus tests on UI state changes and user interactions
  - [ ] Verify all 15 tests still pass
- [ ] Update FloorPlanDetailViewModelTest.swift:
  - [ ] Replace MockVortexRestfulApi with MockFloorPlanManager
  - [ ] Update makeViewModel() helper to inject MockFloorPlanManager
  - [ ] Update all test expectations to match new architecture
  - [ ] Remove API call verification tests (moved to Manager tests)
  - [ ] Focus tests on UI state changes and user interactions
  - [ ] Verify all 24 tests still pass
- [ ] Remove MockVortexRestfulApi helper methods from ViewModel test files
- [ ] Run all ViewModel tests and verify 100% pass rate

## Phase 8: Integration Testing & Validation
- [x] Run full unit test suite:
  - [x] Verify FloorPlanManagerTest (18 tests) passes ✅
  - [x] Verify FloorPlanTabViewModelTest (12 tests) passes ✅
  - [x] Verify FloorPlanDetailViewModelTest (24 tests) passes ✅
  - [x] Total: 54 tests passing ✅
- [x] Build project and verify zero errors ✅
- [ ] Build project and verify zero warnings
- [ ] Run swiftformat on all modified files
- [ ] Verify code follows project conventions in openspec/project.md

## Phase 9: Manual Testing
- [x] Test floor plan tab loading:
  - [x] Verify floor plans load correctly
  - [x] Verify device counts display correctly
  - [x] Verify loading indicator shows during fetch
  - [x] Verify pull-to-refresh works
- [x] Test floor plan detail view:
  - [x] Verify floor plan image displays
  - [x] Verify device markers render correctly
  - [x] Verify device selection works
  - [x] Verify streaming opens on long-press
  - [x] Verify zoom/pan gestures work
- [x] Test error scenarios:
  - [x] Verify graceful handling when API fails
  - [x] Verify appropriate error messages
  - [x] Verify retry works via pull-to-refresh
- [x] Verify no regressions in existing functionality

## Phase 10: OpenSpec Validation & Documentation
- [x] Run `openspec validate restore-floor-plan-manager-separation --strict`
- [x] Fix any validation errors (none found - validation passed)
- [x] Update spec.md if needed based on validation feedback
- [x] Verify all requirements in spec are met
- [x] Add inline documentation for complex Manager logic
- [x] Update proposal.md with any design changes (created REQUIREMENTS_VERIFICATION.md instead)

## Phase 11: Code Review Preparation
- [x] Verify no debug print statements remain
- [x] Check for any TODO/FIXME comments and resolve or document
- [x] Review all changes for code quality
- [x] Prepare commit message following project conventions
- [x] Create git commit with descriptive message (commit f7baa90)
- [ ] Push branch to origin
- [ ] Update PR #7 with architectural changes explanation
- [ ] Link to OpenSpec proposal in PR description
- [ ] Request code review from original reviewer

## Summary of Expected Changes
- New files:
  - FloorPlanBackendModel.swift
  - DevicePositionBackendModel.swift
  - FloorPlanManagerProtocol.swift
  - FloorPlanManager.swift
  - MockFloorPlanManager.swift
  - FloorPlanManagerTest.swift
- Modified files:
  - VortexRestfulApiProtocol.swift (rename methods: getFloorPlans, getDevicePositions)
  - VortexRestfulApi.swift (implement renamed methods)
  - MockVortexRestfulApi.swift (implement renamed methods)
  - FloorPlanApiModels.swift (rename outputs: GetFloorPlansOutput, GetDevicePositionsOutput)
  - DevicePosition.swift (add DeviceCompositeType and display properties)
  - FloorPlanTabViewModel.swift (use Manager dependency)
  - FloorPlanDetailViewModel.swift (use Manager dependency)
  - FloorPlanDetailView.swift (use pre-populated device info)
  - FloorPlanTabViewModelTest.swift (use Manager mock)
  - FloorPlanDetailViewModelTest.swift (use Manager mock)
  - Dependencies+.swift (register Manager)
- Expected test count: 54+ tests (15 Manager + 39 ViewModel)
- Expected architecture: View → ViewModel → Manager → API
- API naming: Follows HTTP method convention (get, post, patch, delete, put)
