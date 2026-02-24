# Implementation Tasks for Floor Plan Tab Empty State

## 1. Localization Setup

- [x] 1.1 Add "No_floor_plans" key to Localizable.xcstrings with English translation "No floor plans"
- [x] 1.2 Add Traditional Chinese translation "沒有平面圖" for "No_floor_plans" key
- [x] 1.3 Add Japanese translation "フロアプランがありません" for "No_floor_plans" key
- [x] 1.4 Verify icon asset `.iconGeneralFloorPlanSolid` exists in Assets.xcassets

## 2. View Implementation

- [x] 2.1 Open FloorPlanTabView.swift and locate the body property
- [x] 2.2 Replace current ScrollView with conditional: if empty show empty state, else show ScrollView
- [x] 2.3 Implement empty state view with VStack containing Spacers for vertical centering
- [x] 2.4 Add Image(.iconGeneralFloorPlanSolid) with resizable and frame(width: 100, height: 100)
- [x] 2.5 Add Text("No_floor_plans") with .textStyle(.title2Bold) and .padding(.top, 8)
- [x] 2.6 Set empty state condition: !viewModel.isLoading && viewModel.siteFloorPlans.isEmpty

## 3. Testing & Verification

- [x] 3.1 Build project and verify no compilation errors
- [x] 3.2 Test empty state display when no floor plans exist
- [x] 3.3 Test that empty state is NOT shown during loading
- [x] 3.4 Test that empty state is replaced by content when floor plans exist
- [x] 3.5 Test pull-to-refresh works from empty state
- [x] 3.6 Verify all three language translations display correctly
- [x] 3.7 Verify icon displays correctly (not missing/broken)
- [x] 3.8 Verify content is centered vertically and horizontally on both iPhone and iPad

## 4. Code Review & Polish

- [x] 4.1 Review code follows Swift coding standards
- [x] 4.2 Verify accessibility identifier if needed for UI tests
- [x] 4.3 Check that existing FloorPlanTabView tests still pass (if any)
- [x] 4.4 Verify no unintended side effects on other floor plan views
