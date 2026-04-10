## Context

MoveToSiteView currently displays Sites as a flat list using `SearchableScrollItemListView`, with path notation like "Huang > CA > LA". The backend already provides hierarchical data — `Site` has a `parentId` field — but `SiteItem` discards it, keeping only `pathComponents` for display.

The app needs a generic tree view component (like `SearchableScrollItemListView` is a generic flat list) that any feature can use for hierarchical data. MoveToSiteView is the first consumer.

Critical constraint: the app has a known Apple bug (FB21851974) where nested SwiftUI lazy containers (`LazyVStack`/`LazyVGrid` inside another) cause `AsyncRenderer dispatch_assert_queue_fail` crash at scale. The tree view must avoid nested lazy containers entirely. Additionally, the tree must support tens of thousands of nodes across multiple levels.

Key existing pieces:
- `Site.parentId` — already available from backend
- `SiteItem` — flat model with `id`, `name`, `pathComponents` (no `parentId`)
- `CustomDisclosureGroup` — existing expand/collapse component (uses nested view structure — not suitable here)
- `SearchableRow` — existing row component with selection indicator
- `DeviceManager.sites: [SiteItem]` — flat sorted list of all sites

## Goals / Non-Goals

**Goals:**
- Create a generic `TreeView` component that works with any `Identifiable` item type
- Row content provided by caller via `@ViewBuilder` — TreeView has no opinion on what a row looks like
- Single-layer `LazyVStack` rendering to avoid nested lazy container crash and support tens of thousands of nodes
- Replace the flat list in MoveToSiteView with TreeView

**Non-Goals:**
- Multi-select support
- Drag-and-drop reordering
- Infinite/lazy-loading children from backend (all data is already in memory)

## Decisions

### Decision 1: Flattened single-LazyVStack architecture

**Chosen approach**: TreeView internally flattens the visible tree into a `[(item, depth)]` array and renders it with a single `LazyVStack` + `ForEach`. Expand/collapse is a data operation (mutating a `Set<Item.ID>` of expanded IDs), not a view nesting operation.

```
expandedIDs: Set<Item.ID>

func buildFlatList() -> [(item: Item, depth: Int)] {
    walk(rootItems, depth: 0)  // only descends into expanded nodes
}
```

- Collapsed node → skip all descendants → O(visible nodes) per rebuild
- LazyVStack only renders visible rows → tens of thousands of expanded nodes is fine
- **Zero nested lazy containers** → immune to FB21851974

**Alternatives considered**:
- Recursive `CustomDisclosureGroup` nesting: natural tree structure, but creates nested view hierarchy. Not a nested lazy container per se, but at tens of thousands of nodes the deep view tree becomes a performance concern. Also, if any caller puts a lazy container inside `rowContent`, it would trigger the nested lazy bug.
- `VStack` (non-lazy) + `DisclosureGroup`: works for small trees, but evaluates all visible nodes at once — unacceptable at tens of thousands scale.

### Decision 2: Expand/collapse state preserved across parent toggle

**Chosen approach**: `expandedIDs: Set<Item.ID>` stores all expanded node IDs. When a parent is collapsed, its children's IDs stay in the set — they're just not visited during `walk`. When the parent is re-expanded, children that were previously expanded automatically reappear with their subtrees.

This matches standard tree behavior (e.g., Finder, IDE file trees).

### Decision 3: Row includes expand arrow inline, not via CustomDisclosureGroup

**Chosen approach**: Since the tree is flat, we can't use `CustomDisclosureGroup` (which requires nested content). Instead, TreeView renders the expand/collapse arrow as part of the row layout:

```
[arrow (if hasChildren)] [rowContent at depth-based indentation]
```

The arrow icon reuses existing assets (`iconGeneralArrowBottomSolid` / `iconGeneralArrowTopSolid` or similar chevron). The `rowContent` closure receives `(item, depth, hasChildren)` so the caller can control indentation via depth.

### Decision 4: Generic TreeView with children closure

**Chosen approach**: `TreeView<Item: Identifiable, RowContent: View>` that takes:
- `items: [Item]` — root-level items
- `children: @escaping (Item) -> [Item]` — closure to get children for any item
- `@ViewBuilder rowContent: @escaping (Item, Int, Bool) -> RowContent` — row builder receiving (item, depth, hasChildren)

### Decision 5: Expose `parentId` on SiteItem

`SiteItem` currently stores only `id`, `name`, `pathComponents`. To build the tree at the call site, we need `parentId`.

**Chosen approach**: Add `public let parentId: String` to `SiteItem`, populated from `Site.parentId` in the existing init.

The caller (MoveToSiteView) then builds root items and children closure:
```swift
let roots = sites.filter { $0.parentId.isEmpty }
let childrenOf = { parent in sites.filter { $0.parentId == parent.id } }
TreeView(items: roots, children: childrenOf) { site, depth, hasChildren in
    // site-specific row with SearchableRow
}
```

### Decision 6: Search filters tree with ancestor preservation (caller-side)

TreeView itself has no search concept. The search filtering is MoveToSiteView's responsibility:

1. Find all sites matching the keyword via `SiteItem.contains(keyword:)`
2. Collect all ancestor IDs by walking `parentId` up to root
3. Filter `sites` to only include matched items + ancestors
4. Pass filtered list to TreeView with the same `children` closure (children of non-included items naturally return empty)
5. Force-expand all ancestor nodes of matches so results are immediately visible

```swift
// MoveToSiteView pseudo-code
let matched = sites.filter { $0.contains(keyword: keyword) }
var visibleIDs = Set(matched.map(\.id))
for site in matched {
    var parentId = site.parentId
    while !parentId.isEmpty, let parent = lookup[parentId] {
        visibleIDs.insert(parent.id)
        parentId = parent.parentId
    }
}
let filtered = sites.filter { visibleIDs.contains($0.id) }
```

This keeps TreeView generic — it doesn't know about search. The caller controls what items to show and which nodes to expand.

### Decision 7: File placement

- `TreeView.swift` → `iOSCharmander/View/Component/TreeView/TreeView.swift` (generic reusable component)
- `SiteItem.swift` → add `parentId` field (VortexFeatures)
- `MoveToSiteView.swift` → swap `SearchableScrollItemListView` for `TreeView` with site-specific row

## Risks / Trade-offs

**[Risk] Deep nesting causes horizontal overflow** → The `depth` parameter is passed to `rowContent`, so the caller controls indentation. Can cap indentation at a max depth or use diminishing padding.

**[Risk] SiteItem model change affects existing consumers** → Adding `parentId` is additive. Test/mock constructors need the new parameter but can default to `""`.

**[Risk] `children` closure called repeatedly during `buildFlatList`** → For MoveToSiteView, this filters `sites.filter { $0.parentId == parent.id }` per node. With tens of thousands of sites this could be slow. Mitigation: caller can pre-build a `[String: [SiteItem]]` lookup dictionary and pass `{ parent in lookup[parent.id] ?? [] }` as the children closure. This is a caller-side optimization, not TreeView's concern.

**[Trade-off] No CustomDisclosureGroup reuse** → The flatten approach means we can't use the existing `CustomDisclosureGroup` wrapper. But the expand/collapse UI is trivial (arrow icon + tap handler), and the performance/safety benefits far outweigh the code reuse loss.
