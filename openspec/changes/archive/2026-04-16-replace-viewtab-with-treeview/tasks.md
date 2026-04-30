## 1. Create ViewTabItem Data Model

- [x] 1.1 Create `ViewTabItem.swift` in `iOSCharmander/View/Home/Tab/ViewTab/` with enum cases: `.site(SiteItem)`, `.device(DeviceItem)`, `.gridRow([DeviceItem])`
- [x] 1.2 Conform `ViewTabItem` to `Hierarchable`, `Identifiable`, `Equatable`, `Searchable` with parentId logic: site → nil, device/gridRow → siteID. IDs use raw values without prefix (gridRow joins UUIDs with `-`).
- [x] 1.3 Add helper function to build `[ViewTabItem]` from `DeviceManager.sites` and devices, with list/grid mode parameter controlling device vs gridRow grouping

## 2. Rewrite ViewTabSiteView with TreeView

- [x] 2.1 Replace `ViewTabSiteView` body with `TreeView<ViewTabItem, _>` (not SearchableTreeView — search mode kept separate), passing built `[ViewTabItem]` array and `ExpandedState` binding, with `indentation: 0` to disable auto-indent
- [x] 2.2 Implement `rowContent` closure: `.site` → site header with `RoundedBackgroundDisclosureGroupIconTextLabel` + expand/collapse arrow, `.device` → `DeviceView` in list layout, `.gridRow` → HStack of `DeviceView` in grid layout
- [x] 2.3 Replace `siteExpandStates: [String: Bool]` and `allSiteExpanded: Bool` with `@State var expandedState: ExpandedState<String>`
- [x] 2.4 Update controlPanel's expand/collapse all button to use `expandedState.expandAll(allSiteIDs)` / `expandedState.collapseAll()`, and derive `allSiteExpanded` from `expandedState.ids`
- [x] 2.5 Rebuild `[ViewTabItem]` array when `deviceManager.sites` changes or list/grid mode toggles
- [x] 2.6 Add `indentation` parameter to `TreeView` (default 16, backward compatible)

## 3. Keep ViewTabSiteSearchingView for search mode

- [x] 3.1 Keep `ViewTabSiteSearchingView` in `SiteView.swift` (search behavior preserved as-is, no TreeView for search)
- [x] 3.2 Keep `SiteList` switching between `ViewTabSiteSearchingView` (searching) and `ViewTabSiteView` (non-searching)

## 4. Verification

- [x] 4.1 Clean build and verify no compiler errors
- [x] 4.2 Test expand/collapse individual site, expand all, collapse all
- [x] 4.3 Test list mode and grid mode layout renders correctly
- [x] 4.4 Test search by device name and site name
- [x] 4.5 Test with large dataset (10,000 sites) — expand/collapse without crash
