## 1. FeatureProvider Layer

- [x] 1.1 Add `accessibleSitesForFloorPlan() -> [SiteItem]` to `FeatureProvider` protocol (`VortexFeatures/Sources/VortexFeatures/Core/FeatureProvider/FeatureProvider.swift`)
- [x] 1.2 Implement `accessibleSitesForFloorPlan()` in `FeatureToggle` using `hasDevicePrivilege($0, .live)` filter (`iOSCharmander/Common/FeatureProvider/FeatureToggle.swift`)
- [x] 1.3 Add `_accessibleSitesForFloorPlan` mock support in `MockFeatureProvider` (`VortexFeatures/Sources/VortexFeatures/Core/FeatureProvider/MockFeatureProvider.swift`)

## 2. FloorPlanManager Interface Change

- [x] 2.1 Change `fetchAllFloorPlans()` to `fetchAllFloorPlans(sites: [SiteItem])` in `FloorPlanManagerProtocol` (`VortexFeatures/Sources/VortexFeatures/Core/FloorPlanManager/FloorPlanManagerProtocol.swift`)
- [x] 2.2 Update `FloorPlanManager.fetchAllFloorPlans()` implementation to use the passed-in `sites` parameter instead of `deviceManager.allSites()` (`VortexFeatures/Sources/VortexFeatures/Core/FloorPlanManager/FloorPlanManager.swift`)
- [x] 2.3 Update `MockFloorPlanManager` to match the new interface

## 3. ViewModel Integration

- [x] 3.1 Add `featureProvider` dependency to `FloorPlanTabViewModel` and update `make()` factory method
- [x] 3.2 Update `fetchAll()` to call `featureProvider.accessibleSitesForFloorPlan()` and pass sites to `floorPlanManager.fetchAllFloorPlans(sites:)`

## 4. Tests

- [x] 4.1 Update `FloorPlanManagerTest` — adjust `fetchAllFloorPlans` tests to pass sites parameter
- [x] 4.2 Update `FloorPlanTabViewModelTest` — mock `featureProvider` and verify accessible sites are passed to manager
