## Why

The Floor Plan Tab currently displays a blank screen when no floor plan data is available, lacking clear visual feedback. An empty state view centered on the screen is needed to inform users that no floor plans are currently available.

## What Changes

- Add empty state view display logic to `FloorPlanTabView`
- Create a centered empty state view that displays when `siteFloorPlans` is empty
- Use `.iconGeneralFloorPlanSolid` icon
- Display localized text: "No floor plans / 沒有平面圖 / フロアプランがありません"
- Reference `NoResultView` implementation pattern, but center content on screen
- No refresh button included (users can use pull-to-refresh functionality)

## Capabilities

### New Capabilities
- `floorplan-empty-state`: Empty state view for Floor Plan Tab that displays centered icon and message when no floor plan data is available

### Modified Capabilities
<!-- No existing spec requirements are being changed -->

## Impact

**Affected Code:**
- `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanTabView.swift` - Add empty state display logic
- `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanTabViewModel.swift` - May need to add computed property to determine if empty
- `Localizable.xcstrings` - Add new localized string

**Reference Components:**
- `NoResultView` / `NoResultCover` / `NoResultCenterCover` / `NoResultBackground` (in `NoResultCover.swift`) - Design reference for empty state view

**Not Affected:**
- Other Floor Plan related pages (FloorPlanDetailView, FloorPlanSiteView, etc.)
- FloorPlanManager and backend API logic
- Existing pull-to-refresh functionality
