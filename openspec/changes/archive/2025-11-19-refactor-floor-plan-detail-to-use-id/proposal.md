## Why

FloorPlanDetailViewModel currently accepts a complete `FloorPlan` object as an init parameter, but only uses `floorPlan.id` for API calls. Additionally, FloorPlanTabViewModel holds `siteFloorPlans` data and search logic, but this data should be centrally managed by the Manager.

By making FloorPlanManager the central data source:
1. DetailViewModel only needs `floorPlanID` to open
2. TabViewModel subscribes to Manager's data stream instead of maintaining local state
3. Search logic is centralized in Manager, making future API-based search easier
4. Maintains MVVM architecture consistency

## What Changes

### FloorPlanManager Extension
- Add `@Published var siteFloorPlans: [SiteFloorPlans]` cache
- Provide `siteFloorPlansValues() -> AsyncStream` for ViewModel subscription
- Provide `searchFloorPlans(keyword:) -> [SiteFloorPlans]` method
- Provide `findFloorPlan(byID:) -> FloorPlan?` method

### FloorPlanTabViewModel Adjustment
- Remove local `siteFloorPlans` state, subscribe to Manager instead
- Remove `searchFloorPlans(with:)` method, delegate to Manager
- Keep user action handlers (tapFloorPlan, tapSite)

### FloorPlanDetailViewModel Refactor
- Change `init(floorPlan:)` to `init(floorPlanID:)`
- Retrieve full FloorPlan data from FloorPlanManager

### SheetManager Update
- Change `openFloorPlanDetail(floorPlan:)` to `openFloorPlanDetail(floorPlanID:)`

## Impact

- Affected specs: `mobile-floor-plan-architecture`
- Affected code:
  - `VortexFeatures/Sources/VortexFeatures/Core/FloorPlanManager/FloorPlanManager.swift`
  - `VortexFeatures/Sources/VortexFeatures/Core/FloorPlanManager/FloorPlanManagerProtocol.swift`
  - `VortexFeatures/Sources/VortexFeatures/Core/FloorPlanManager/MockFloorPlanManager.swift`
  - `VortexFeatures/Tests/VortexFeaturesTests/Core/FloorPlanManagerTest.swift` (moved from iOSCharmanderTests)
  - `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanTabView.swift`
  - `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanTabViewModel.swift`
  - `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanDetail/FloorPlanDetailView.swift`
  - `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanDetail/FloorPlanDetailViewModel.swift`
  - `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanDetail/FloorPlanDeviceSearchView.swift`
  - `iOSCharmander/View/Home/Sheet/SheetManager.swift`
  - `iOSCharmander/View/Home/Sheet/SheetManagerProtocol.swift`
  - `iOSCharmander/View/Home/Sheet/MockSheetManager.swift`
  - `iOSCharmanderTests/Test/FloorPlan/FloorPlanDetailViewModelTest.swift`
  - `iOSCharmanderTests/Test/FloorPlan/FloorPlanTabViewModelTest.swift`
