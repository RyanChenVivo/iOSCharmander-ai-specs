## Why

View Tab's `ViewTabSiteView` uses nested lazy containers (`LazyVStack` > `DisclosureGroup` > `FlexibleGridView`/`LazyVGrid`), which triggers a known Apple framework bug (FB21851974) causing `AsyncRenderer dispatch_assert_queue_fail` crash at scale. The newly built `TreeView` component uses a flattened single-`LazyVStack` architecture that eliminates nested lazy containers entirely.

## What Changes

- **Replace `ViewTabSiteView` with TreeView-based implementation**: Replace the nested `LazyVStack` > `RoundedBackgroundDisclosureGroup` > `FlexibleGridView` structure with a single `TreeView` flat rendering architecture.
- **Introduce `ViewTabItem` enum**: Unify sites and devices into a single `Hierarchable` data model. All sites are flat (parentId = nil), devices are children of their site (parentId = siteID). Grid mode uses `deviceRow([DeviceItem])` for pre-grouped 2-column layout.
- **Replace `ViewTabSiteSearchingView` with `SearchableTreeView`**: Unify search and non-search modes into a single `SearchableTreeView`, eliminating nested lazy containers in search mode while preserving existing search behavior (both site name and device name searchable).
- **Replace expand/collapse state management**: Replace manual `[String: Bool]` dictionary with `ExpandedState<ID>`. Expand all / collapse all uses `expandedState.expandAll()` / `expandedState.collapseAll()`.

## Capabilities

### New Capabilities
- `viewtab-treeview-integration`: Integration layer for rendering View Tab's site/device list using the TreeView component, including the `ViewTabItem` data model, flat list construction logic for grid/list modes, and `SearchableTreeView` search integration.

### Modified Capabilities
- `ios-view-tab-device-management`: Expand/collapse behavior changes from per-site `Binding<Bool>` to unified `ExpandedState` management. Control panel's toggle-all logic uses `ExpandedState.expandAll()` / `collapseAll()`.

## Impact

- `ViewTabSiteView` — Full rewrite using `TreeView`
- `ViewTabSiteSearchingView` — Removed, merged into `SearchableTreeView`
- `SiteList.swift` — Simplified, no longer needs separate searching/non-searching views
- `SiteView.swift` — Internal `ViewTabSiteView` and `ViewTabSiteSearchingView` refactored
- New `ViewTabItem.swift` — Enum data model
- `TreeView` / `SearchableTreeView` / `ExpandedState` — No changes
- `DeviceView` / `SiteRow` content and styling — No changes
- `ViewTabViewModel` — No changes
- `NoticeBanner` / `exportingRow` — No changes
