## 1. FloorPlanManager Extension

- [x] 1.1 Add `@Published private(set) var siteFloorPlans: [SiteFloorPlans] = []` cache property
- [x] 1.2 Add `siteFloorPlansValues() async -> AsyncStream<[SiteFloorPlans]>` method
- [x] 1.3 Modify `fetchAllFloorPlans()` to update `siteFloorPlans` cache before returning
- [x] 1.4 Add `findFloorPlan(byID:) -> FloorPlan?` method to lookup from cache
- [x] 1.5 Add `searchFloorPlans(keyword:) -> [SiteFloorPlans]` method (move from TabViewModel)
- [x] 1.6 Update `FloorPlanManagerProtocol` with new method signatures
- [x] 1.7 Update `MockFloorPlanManager` to support new methods

## 2. FloorPlanTabViewModel Adjustment

- [x] 2.1 Keep local `@Published var siteFloorPlans` property (for View binding)
- [x] 2.2 Add subscription to Manager's `siteFloorPlansValues()` stream
- [x] 2.3 Delegate `searchFloorPlans(with:)` to Manager
- [x] 2.4 Update `fetchAll()` to call Manager and let Manager publish updates
- [x] 2.5 Keep `tapFloorPlan(_:)` and `tapSite(_:)` action methods
- [x] 2.6 Add `onViewDisappear()` to cancel subscription

## 3. FloorPlanDetailViewModel Refactor

- [x] 3.1 Change `let floorPlan: FloorPlan` to `@Published var floorPlan: FloorPlan?`
- [x] 3.2 Add `let floorPlanID: String` property
- [x] 3.3 Change `init(floorPlan:)` to `init(floorPlanID:)`
- [x] 3.4 Change `make(floorPlan:)` to `make(floorPlanID:)`
- [x] 3.5 In `onViewAppear()`, lookup FloorPlan from FloorPlanManager
- [x] 3.6 Update `loadDevicePositions()` to use `floorPlanID` instead of `floorPlan.id`
- [x] 3.7 Handle case when FloorPlan is not found (log error, skip loading)
- [x] 3.8 Remove unused `groupDevicesBySite()` method

## 4. FloorPlanDetailView Adjustment

- [x] 4.1 Change `init(floorPlan:)` to `init(floorPlanID:)`
- [x] 4.2 Update navigation title binding to `viewModel.floorPlan?.name`
- [x] 4.3 Update image loading logic to handle optional `floorPlan?`
- [x] 4.4 Add `onDisappear` to call cleanup

## 5. SheetManager Update

- [x] 5.1 Change `openFloorPlanDetail(floorPlan:)` to `openFloorPlanDetail(floorPlanID:)`
- [x] 5.2 Update FloorPlanDetailView initialization in SheetManager
- [x] 5.3 Update MockSheetManager with new signature

## 6. FloorPlanTabViewModel Call Update

- [x] 6.1 Update `tapFloorPlan(_:)` to call `sheetManager.openFloorPlanDetail(floorPlanID: floorPlan.id)`

## 7. Test Updates

- [x] 7.1 Update `MockFloorPlanManager` with `siteFloorPlans`, `searchFloorPlans`, `findFloorPlan` support
- [x] 7.2 Update `FloorPlanDetailViewModelTest`'s `makeViewModel()` helper to use `floorPlanID`
- [x] 7.3 Add test: FloorPlan lookup from Manager (success, not found cases)
- [x] 7.4 Add test: filterDevices method
- [x] 7.5 Add test: cleanup method
- [x] 7.6 Update `FloorPlanTabViewModelTest` to verify Manager data stream subscription
- [x] 7.7 Simplify mocks - remove unused `_fetchFloorPlans`, `_fetchDevicePositions` from test mocks
- [x] 7.8 Move `FloorPlanManagerTest` to VortexFeatures/Tests
- [x] 7.9 Add Manager tests: searchFloorPlans, findFloorPlan

## 8. Verification

- [x] 8.1 Run `xcodebuild build` to confirm compilation passes
- [x] 8.2 Run FloorPlanDetailViewModelTest to confirm tests pass
- [x] 8.3 Run FloorPlanTabViewModelTest to confirm tests pass
- [x] 8.4 Run FloorPlanManagerTest to confirm tests pass
- [x] 8.5 Manual test: open detail view from floor plan list
- [x] 8.6 Manual test: search functionality works correctly
