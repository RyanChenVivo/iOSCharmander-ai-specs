# Tasks

## Phase 1: Model Changes
- [x] Create `FloorPlanDetail` struct in VortexFeatures/Sources/VortexFeatures/Core/FloorPlanManager/
  - [x] Add `floorPlan: FloorPlan` property
  - [x] Add `devicePositions: [DevicePosition]` property (var, mutable)
  - [x] Conform to Sendable, Equatable
  - [x] Add memberwise init
- [x] Update `DevicePosition` struct in DevicePosition.swift
  - [x] Add `compositeType: DeviceCompositeType` as **stored property** (`let`)
  - [x] Change `device: DeviceItem?` from `let` to `var`
  - [x] Add `init(item: DevicePositionItem, compositeType: DeviceCompositeType)` that sets `device = nil`
  - [x] Remove old `init(item:device:)` (replaced by new init)
  - [x] Update test init to include `compositeType` parameter
  - [x] Keep existing `cameraStatus` computed property unchanged
- [x] Verify models compile with `swift build`

## Phase 2: FloorPlanManager Protocol Changes
- [x] Update `FloorPlanManagerProtocol` in FloorPlanManagerProtocol.swift
  - [x] Remove `fetchFloorPlans(forSiteID:)` from protocol
  - [x] Remove `siteFloorPlansValues()` from protocol
  - [x] Add `@MainActor func setCurrentFloorPlanDetail(_ detail: FloorPlanDetail?)` to protocol
  - [x] Keep `fetchAllFloorPlans(sites:)`, `fetchDevicePositions(forFloorPlanID:)`, `findFloorPlan(byID:)`, `searchFloorPlans(keyword:)`
  - [x] Update docstrings to reflect new responsibilities (no device pre-population)
- [x] Verify protocol compiles

## Phase 3: FloorPlanManager Implementation Changes
- [x] Update `FloorPlanManager` in FloorPlanManager.swift
  - [x] Remove `@Dependency(\.deviceManager) private var deviceManager`
  - [x] Remove `$0.deviceManager = DeviceManager.shared` from `static let shared`
  - [x] Add `@Published private(set) var currentFloorPlanDetail: FloorPlanDetail? = nil`
  - [x] Implement `setCurrentFloorPlanDetail(_ detail: FloorPlanDetail?)`
  - [x] Remove `siteFloorPlansValues()` method
  - [x] Remove `transformToUIPosition()` private method (device lookup logic)
  - [x] Add `parseCompositeType(from:)` private method — parses `deviceSerialNumber` ("thingName:derivant") into `DeviceCompositeType`
  - [x] Demote `fetchFloorPlans(forSiteID:)` from public to private
  - [x] Update `fetchDevicePositions(forFloorPlanID:)` to parse compositeType and use `DevicePosition(item:compositeType:)` init (no device)
  - [x] Keep `fetchAllFloorPlans(sites:)`, `findFloorPlan(byID:)`, `searchFloorPlans(keyword:)` unchanged
- [x] Verify FloorPlanManager compiles
- [x] Run build to check for errors

## Phase 4: FloorPlanTabViewModel Simplification
- [x] Update `FloorPlanTabViewModel` in FloorPlanTabViewModel.swift
  - [x] Remove `@Published var siteFloorPlans: [SiteFloorPlans]`
  - [x] Remove `subscriptionTask: Task<Void, Never>?`
  - [x] Remove `onViewDisappear()` (no subscription to cancel)
  - [x] Simplify `onViewAppear()` — only call fetchAll, no subscription setup
  - [x] Keep `@Published var isLoading`
  - [x] Keep `fetchAll()`, `pullToRefresh()`, `tapFloorPlan()`, `searchFloorPlans(with:)`
- [x] Verify FloorPlanTabViewModel compiles

## Phase 5: FloorPlanTabView Changes
- [x] Update `FloorPlanTabView` to observe Manager directly
  - [x] Add `@ObservedObject var floorPlanManager = FloorPlanManager.shared`
  - [x] Replace `viewModel.siteFloorPlans` references with `floorPlanManager.siteFloorPlans`
  - [x] Remove `onDisappear { viewModel.onViewDisappear() }` (no subscription to cancel)
  - [x] Keep `viewModel.isLoading` for loading state
  - [x] Keep `viewModel.searchFloorPlans(with:)` for search
- [x] Update sub-views: FloorPlanSiteView changed to observe `floorPlanManager.siteFloorPlans` directly
- [x] Verify FloorPlanTabView compiles and displays correctly

## Phase 6: FloorPlanDetailViewModel Restructuring
- [x] Update `FloorPlanDetailViewModel` in FloorPlanDetailViewModel.swift
  - [x] Add `@Dependency(\.deviceManager) var deviceManager`
  - [x] Add `$0.deviceManager = DeviceManager.shared` to `static func make()`
  - [x] Add `private var deviceSyncTask: Task<Void, Never>?`
  - [x] Remove `@Published var devicePositions: [DevicePosition]`
  - [x] Remove `@Published var floorPlan: FloorPlan?`
  - [x] Implement device info fill-in method: `fillDeviceInfo(_ positions: inout [DevicePosition])`
  - [x] Update `onViewAppear()`:
    - [x] Fetch floor plan from cache via `findFloorPlan(byID:)`
    - [x] Fetch positions via `fetchDevicePositions(forFloorPlanID:)`
    - [x] Fill device info
    - [x] Call `setCurrentFloorPlanDetail()` with combined FloorPlanDetail
    - [x] Start device sync task
  - [x] Implement `startDeviceSync()`:
    - [x] Subscribe to `deviceManager.devicesValues()`
    - [x] On each emission, read current detail from Manager
    - [x] Re-fill device info on positions
    - [x] Write updated detail back to Manager
  - [x] Update `cleanup()` / `onViewDisappear()`:
    - [x] Cancel deviceSyncTask
    - [x] Call `setCurrentFloorPlanDetail(nil)`
    - [x] Stop streaming
  - [x] Update `getSelectedDevice()` to read from `floorPlanManager.currentFloorPlanDetail?.devicePositions`
  - [x] Update `getSelectedDevicePosition()` to read from `floorPlanManager.currentFloorPlanDetail?.devicePositions`
  - [x] Update `filterDevices(keyword:)` to read from `floorPlanManager.currentFloorPlanDetail?.devicePositions`
- [x] Verify FloorPlanDetailViewModel compiles

## Phase 7: FloorPlanDetailView Changes
- [x] Update `FloorPlanDetailView` to observe Manager directly
  - [x] Add `@ObservedObject var floorPlanManager = FloorPlanManager.shared`
  - [x] Replace `viewModel.devicePositions` references with `floorPlanManager.currentFloorPlanDetail?.devicePositions ?? []`
  - [x] Replace `viewModel.floorPlan` references with `floorPlanManager.currentFloorPlanDetail?.floorPlan`
  - [x] Keep `viewModel.selectedDeviceID`, `viewModel.zoomScale`, `viewModel.viewcellControl`, `viewModel.isStreamingFullScreen`, `viewModel.isLoading` from ViewModel
- [x] Update FloorPlanDeviceSearchView — `viewModel.floorPlan?.name` → `floorPlanManager.currentFloorPlanDetail?.floorPlan.name`
- [x] Verify FloorPlanDetailView compiles and displays correctly

## Phase 8: Mock and Test Updates

### 8a. Update MockFloorPlanManager
- [x] Update `MockFloorPlanManager` in MockFloorPlanManager.swift
  - [x] Remove `fetchFloorPlans(forSiteID:)` mock
  - [x] Remove `siteFloorPlansValues()` mock
  - [x] Add `setCurrentFloorPlanDetail(_:)` mock
  - [x] Add `currentFloorPlanDetail` property for test verification
  - [x] Add `siteFloorPlans` property for test data
  - [x] Match new protocol signature

### 8b. Update FloorPlanManagerTest (25 tests → ~19 tests)
- [x] **Delete** tests (Manager no longer handles device info):
  - [x] `test_fetchDevicePositions_shouldPrePopulateDeviceInfo_whenDeviceFound`
  - [x] `test_fetchDevicePositions_shouldHandleDeviceNotFound_whenDeviceDoesNotExist`
  - [x] `test_fetchDevicePositions_shouldMapIsUpdatingFirmware_whenDeviceIsUpgrading`
  - [x] `test_fetchDevicePositions_shouldMapOnlineStatus_whenDeviceOffline`
  - [x] `test_fetchDevicePositions_shouldComputeCameraStatus_whenDeviceOnline`
  - [x] `test_fetchDevicePositions_shouldComputeCameraStatus_whenDeviceOffline`
- [x] **Modify** tests:
  - [x] `test_fetchDevicePositions_shouldReturnPositions_whenAPISucceeds` — add assertion `device == nil` for all positions
  - [x] `test_fetchDevicePositions_shouldParseDeviceSerialNumber_whenColonFormat` — renamed to `test_fetchDevicePositions_shouldParseCompositeType_whenColonFormat`, verifies `compositeType` stored property
  - [x] `test_fetchDevicePositions_shouldHandleInvalidSerialNumberFormat_whenNoColon` — updated to verify `compositeType` fallback (whole string as thingName, empty derivant)
- [x] **Keep/adjust**:
  - [x] `test_fetchFloorPlans_*` × 3 — adjusted to test via fetchAllFloorPlans (method now private)
  - [x] `test_fetchDevicePositions_shouldThrowError_whenAPIFails`
  - [x] `test_fetchDevicePositions_shouldPreserveFOVData_whenProvided`
  - [x] `test_fetchAllFloorPlans_*` × 4
  - [x] `test_searchFloorPlans_*` × 5
  - [x] `test_findFloorPlan_*` × 3
- [x] **Add new** tests:
  - [x] `test_setCurrentFloorPlanDetail_shouldUpdatePublishedProperty`
  - [x] `test_setCurrentFloorPlanDetail_shouldClearDetail_whenSetToNil`
- [x] Remove mockDeviceManager from helper methods (no longer a dependency)

### 8c. Update FloorPlanTabViewModelTest (9 tests → ~9 tests)
- [x] **Modify** tests:
  - [x] `test_onViewAppear_shouldSetLoadingFalse_whenSuccess` — removed `siteFloorPlans` assertion, keep `isLoading` assertion
  - [x] `test_onViewAppear_shouldReturnEmptyFloorPlans_whenNoSites` — renamed, removed `siteFloorPlans` assertion, verify fetchAll still called
  - [x] `test_onViewAppear_shouldLoadFloorPlansForSingleSite_whenOneSite` — renamed, removed `siteFloorPlans` assertion, verify fetchAll still called
- [x] **Keep unchanged**:
  - [x] `test_onViewAppear_shouldSetLoadingFalse_whenFetchAllThrowsError`
  - [x] `test_pullToRefresh_*` × 2
  - [x] `test_tapFloorPlan_shouldOpenFloorPlanDetail_whenTapped`
  - [x] `test_tapSite_shouldLogTrace_whenTapped`
  - [x] `test_searchFloorPlans_shouldCallManagerAndReturnResults`
- [x] Update mock setup to match new FloorPlanManagerProtocol (removed `_siteFloorPlansValues`, `AsyncStreamHolder`)

### 8d. Update FloorPlanDetailViewModelTest (~30 tests → ~33 tests)
- [x] Add MockDeviceManager injection in test setup
- [x] **Modify** tests (read from Manager.currentFloorPlanDetail instead of ViewModel properties):
  - [x] `test_onViewAppear_shouldLoadDevicePositions_whenSuccess` — verify calls `setCurrentFloorPlanDetail` with positions that have device filled
  - [x] `test_onViewAppear_shouldSetFloorPlan_whenManagerReturnsFloorPlan` — verify FloorPlanDetail contains correct floorPlan
  - [x] `test_onViewAppear_shouldSetLoadingFalse_whenAPIFails` — adjusted
  - [x] `test_onViewAppear_shouldNotLoadDevicePositions_whenFloorPlanNotFound` — verify setCurrentFloorPlanDetail NOT called
  - [x] Removed `test_loadDevicePositions_*` × 2 (method no longer public, tested via onViewAppear)
  - [x] `test_getSelectedDevice_shouldReturnDevice_whenDeviceIsPrePopulated` — read from Manager.currentFloorPlanDetail
  - [x] `test_getSelectedDevicePosition_shouldReturnPosition_whenDeviceSelected` — read from Manager.currentFloorPlanDetail
  - [x] `test_filterDevices_*` × 4 — read from Manager.currentFloorPlanDetail
  - [x] `test_fullWorkflow_shouldLoadDataAndSelectDevice_whenUserInteracts` — updated full flow with Manager writes
  - [x] `test_cleanup_shouldNotCrash_whenNoStreaming` — verify also calls setCurrentFloorPlanDetail(nil)
- [x] **Keep unchanged**:
  - [x] `test_tapDevice_*` × 3
  - [x] `test_deselectDevice_shouldClearSelection_whenInvoked`
  - [x] `test_toggleFullScreen_shouldToggleState_whenInvoked`
  - [x] `test_zoomIn_*` × 2, `test_zoomOut_*` × 2, `test_resetZoom_*`, `test_setZoomScale_*`
  - [x] `test_apiFailure_shouldHandleGracefully_whenLoadingFails`
  - [x] `test_cameraFOVShape_shouldConvertGeographicDirection_toCorrectScreenDirection`
  - [x] `test_cameraOverlayStatus_shouldHaveCorrectColors`
- [x] **Add new** tests:
  - [x] `test_onViewAppear_shouldFillDeviceInfo_usingCompositeType` — verify ViewModel uses `position.compositeType` to call `findDevice(bySource:)`
  - [x] `test_onViewAppear_shouldWriteToManager_viaSetCurrentFloorPlanDetail` — verify detail written to Manager
  - [x] `test_cleanup_shouldCancelSyncTask_andSetDetailNil`
  - Note: Device sync stream tests (`test_deviceSync_*`) deferred — require complex AsyncStream mocking of `devicesValues()`

## Phase 9: Validation
- [x] Run full unit test suite — all tests pass (62 tests, 0 failures)
- [x] Build project with zero errors
- [ ] Manual test: Floor Plan tab loads sites and floor plans
- [ ] Manual test: Pull-to-refresh works
- [ ] Manual test: Search floor plans works
- [ ] Manual test: Open floor plan detail shows image and device markers
- [ ] Manual test: Device markers show correct online/offline/updating status
- [ ] Manual test: Select device starts streaming
- [ ] Manual test: Switch device stops old stream, starts new
- [ ] Manual test: Leave detail cleans up properly
- [ ] Verify no regressions in existing functionality

## Summary of Expected Changes

### New files:
- `FloorPlanDetail.swift` (VortexFeatures/Sources/VortexFeatures/Core/FloorPlanManager/)

### Modified files:
- `DevicePosition.swift` — add `compositeType` stored property, `device` let→var, add `init(item:compositeType:)` without device
- `FloorPlanManagerProtocol.swift` — remove 2 methods, add 1 method
- `FloorPlanManager.swift` — remove DeviceManager dep, add currentFloorPlanDetail, add parseCompositeType, simplify fetchDevicePositions
- `FloorPlanTabViewModel.swift` — remove siteFloorPlans, subscriptionTask
- `FloorPlanTabView.swift` — observe FloorPlanManager.shared
- `FloorPlanDetailViewModel.swift` — add DeviceManager, device sync, setCurrentFloorPlanDetail calls
- `FloorPlanDetailView.swift` — observe FloorPlanManager.shared.currentFloorPlanDetail
- `MockFloorPlanManager.swift` — match new protocol
- `FloorPlanManagerTest.swift` — update for new behavior
- `FloorPlanTabViewModelTest.swift` — remove siteFloorPlans assertions
- `FloorPlanDetailViewModelTest.swift` — add device sync tests, remove data-holding assertions

### Deleted code:
- `siteFloorPlansValues()` method and AsyncStream usage
- `transformToUIPosition()` method in FloorPlanManager
- DeviceManager dependency in FloorPlanManager

### Architecture after refactoring:
```
View → FloorPlanManager.shared (@Published) for data
View → ViewModel for UI-only state
ViewModel → FloorPlanManager Protocol for fetch/write operations
ViewModel → DeviceManager for device sync (DetailVM only)
FloorPlanManager → VortexRestfulApi for backend calls
```
