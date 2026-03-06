## 1. Navigation Title

- [x] 1.1 Add `Floorplans` localization key to `Localizable.xcstrings` (EN: "Floorplans", ZH-Hant: "樓層規劃", JA: "フロアプラン")
- [x] 1.2 In `FloorPlanTabView.swift`, change navigation title key from `"Floor_plan"` to `"Floorplans"`

## 2. Site Header Icon

- [x] 2.1 In `FloorPlanSiteGroup.swift`, change `generalIcon: .iconGeneralLayout4ChLine` to `generalIcon: .iconGeneralLocationMark` in the `RoundedBackgroundDisclosureGroupIconTextLabel`

## 3. Search Placeholder

- [x] 3.1 In `CustomSearchBar.swift`, extend `searchable(text:isActive:)` with `prompt: LocalizedStringKey = ""` parameter, set `searchController.searchBar.placeholder` when non-empty
- [x] 3.2 Add `Search_floor_plans_or_sites` key to `Localizable.xcstrings` (EN: "Search floor plans or sites", ZH-Hant: "搜尋平面圖或站點", JA: "フロアプランまたはサイトを検索")
- [x] 3.3 In `FloorPlanTabView.swift`, add `prompt: "Search_floor_plans_or_sites"` to `.searchable()` call
