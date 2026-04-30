## Context

View Tab renders site/device lists using nested lazy containers: `LazyVStack` > `RoundedBackgroundDisclosureGroup` (wrapping `DisclosureGroup`) > `FlexibleGridView` (`LazyVGrid`). This triggers Apple bug FB21851974 at scale (10,000 sites × 5,000 devices), causing crashes.

The existing `TreeView` component uses a flattened single-`LazyVStack` architecture, already validated in the site-picker scenario. This change adopts TreeView for View Tab's site/device rendering.

Relevant existing components:
- `TreeView` / `SearchableTreeView` / `ExpandedState` — Generic tree component at `iOSCharmander/View/Component/TreeView/`
- `ViewTabSiteView` / `ViewTabSiteSearchingView` — Current View Tab implementation at `iOSCharmander/View/Home/Tab/ViewTab/SiteView.swift`
- `FlexibleGridView` — Current grid component (`LazyVGrid`) at `VortexFeatures/Sources/VortexFeatures/UI/GridView/`
- `RoundedBackgroundDisclosureGroup` — Current expand/collapse component

## Goals / Non-Goals

**Goals:**
- Eliminate nested lazy container crash
- Support 10,000 sites / 5,000 devices without crash
- Preserve existing UX behavior (expand/collapse, expand all/collapse all, site header rounded background, device grid/list layout)
- Unify search mode with `SearchableTreeView`
- Simplify expand state management (from manual dictionary to `ExpandedState`)

**Non-Goals:**
- Do not change site hierarchy presentation (keep flat layout, no tree indentation)
- Do not change `DeviceView` or `SiteRow` content/styling
- Do not change `ViewTabViewModel` logic
- Do not modify `TreeView` / `SearchableTreeView` / `ExpandedState` components
- Do not optimize for 50M items fully expanded (ensure no crash is sufficient)

## Decisions

### Decision 1: Unified data model — ViewTabItem enum

**Choice**: Create a `ViewTabItem` enum unifying sites and devices into a single `Hierarchable` data model.

```
enum ViewTabItem {
    case site(SiteItem)
    case device(DeviceItem)          // list mode
    case deviceRow([DeviceItem])     // grid mode, max 2 per row
}
```

**parentId logic**:
- `.site(_)` → `parentId = nil` (all sites flat as roots, no tree hierarchy)
- `.device(d)` → `parentId = d.siteID`
- `.deviceRow(devices)` → `parentId = devices.first!.siteID`

**Rejected alternatives**:
- Only put sites in TreeView, render devices in a grid inside site's expanded content → brings back nested lazy problem
- Use `SiteItem.parentId` for real tree hierarchy → doesn't match current flat UI behavior

**Rationale**: Flat sites + devices under site exactly matches current UI behavior. TreeView's `buildFlatList` natively supports this structure.

### Decision 2: Grid mode uses deviceRow pre-grouping

**Choice**: When building the flat list, group devices differently based on list/grid mode.

- List mode: each device is an individual `.device` item
- Grid mode: devices under the same site are paired into `.deviceRow([DeviceItem])`, max 2 per row

**Rejected alternatives**:
- Use ForEach lookahead in view layer to pair consecutive devices → LazyVStack is one item per row, merging logic is ugly
- Drop grid mode → feature regression

**Rationale**: Grouping is O(n), not a performance bottleneck. Data layer handles grouping, view layer simply renders by case.

### Decision 3: Unified search with SearchableTreeView

**Choice**: Remove standalone `ViewTabSiteSearchingView`, use `SearchableTreeView` for both search and non-search modes.

**Search behavior**: `ViewTabItem` conforms to `Searchable`, delegating to `SiteItem.contains()` / `DeviceItem.contains()`. `SearchableTreeView`'s search logic natively supports "matching device → parent site also shows and expands".

**Rationale**: Reduces duplicate code, eliminates nested lazy containers in search mode.

### Decision 4: controlPanel outside TreeView

**Choice**: controlPanel (site count + expand/collapse all button) is placed outside TreeView, not as a tree item.

```
VStack(spacing: 0) {
    controlPanel
    SearchableTreeView(items: viewTabItems, expandedState: $expandedState) { ... }
}
```

**Rationale**: controlPanel is not part of the tree data structure. Expand/collapse all directly operates `ExpandedState.expandAll()` / `collapseAll()`.

### Decision 5: Preserve site header rounded gray background

**Choice**: In TreeView's `rowContent`, render `.site` case with rounded gray background (matching current `RoundedBackgroundDisclosureGroupIconTextLabel` visual), plus an expand/collapse arrow button.

**Rationale**: Maintains current visual appearance. `RoundedBackgroundDisclosureGroup` component is no longer needed since expand/collapse is managed by TreeView's `ExpandedState`.

## Risks / Trade-offs

- **buildFlatList recomputation cost**: Every expand/collapse recomputes the entire flat array. With 10,000 sites all collapsed, the array is only 10,000 items (fast). If many sites are expanded simultaneously, the array grows large → in practice users won't expand all sites, and `LazyVStack` only renders visible items. Acceptable.
- **Grid mode toggle requires flat list rebuild**: Switching between list and grid mode requires rebuilding the flat array (device vs deviceRow) → O(n) operation. Acceptable.
- **SearchableTreeView debounce**: Built-in 500ms debounce may differ slightly from current search behavior → acceptable, arguably better (avoids frequent recomputation).
