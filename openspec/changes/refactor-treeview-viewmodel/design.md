## Context

The app uses a custom `TreeView` / `SearchableTreeView` component pair to render hierarchical site data in multiple screens (MoveToSiteView, ViewTabSiteView). Currently:

- **TreeView** internally builds a `childrenLookup` dictionary and computes a `flatList` on every SwiftUI body evaluation.
- **SearchableTreeView** independently builds an `idLookup` dictionary for ancestor-chain search, duplicating work that TreeView also does.
- **ViewTabSiteView** manages `rebuildItems()`, expand state, and toggle-all logic in View-layer `@State`.
- **DeviceManager.findSite(id:)** does O(n) linear scan, called repeatedly from computed properties inside SwiftUI body.

As TreeView adoption grows across the app, this scattered data-processing logic becomes harder to maintain and increasingly expensive at scale.

## Goals / Non-Goals

**Goals:**
- Centralize tree data processing (lookups, flat list, search, expand state) into a single generic `TreeViewModel`
- Eliminate redundant dictionary construction across TreeView and SearchableTreeView
- Cache `flatList` so it only recomputes when `items` or `expandedState` change
- Make `DeviceManager.findSite(id:)` O(1)
- Keep TreeView/SearchableTreeView as generic reusable components — no domain-specific coupling

**Non-Goals:**
- Server-side search or pagination (architectural change, separate initiative)
- Moving search to background thread (workaround; proper fix is server-side)
- Changing the flat-array + parentId data model (current model is correct)
- Redesigning the TreeView visual appearance or UX

## Decisions

### 1. Introduce `TreeViewModel<Item>` as `@Observable` class

**Decision**: Create a generic `@Observable` `TreeViewModel<Item>` that owns items, expandedState, childrenLookup, idLookup, and cached flatList.

**Why over alternatives**:
- *Alternative: Keep logic in View `@State`* — Current approach. Causes redundant computation on every body eval, duplicated across consumers. Rejected.
- *Alternative: Environment-based shared object* — SwiftUI `@Environment` doesn't support generic types cleanly. Would require per-type EnvironmentKey boilerplate. Rejected.
- *Alternative: Pass ViewModel via init injection* — Simple, explicit, no Environment magic. TreeView and SearchableTreeView receive the ViewModel in init. **Chosen.**

```
TreeViewModel<Item: Hierarchable & Equatable>
├── items: [Item]                          // set by consumer
├── expandedState: ExpandedState<Item.ID>  // managed internally + consumer access
├── childrenLookup: [Item.ID?: [Item]]     // auto-rebuilt on items change
├── idLookup: [Item.ID: Item]              // auto-rebuilt on items change
├── flatList: [(item: Item, depth: Int)]   // auto-rebuilt on items or expandedState change
└── search (when Item: Searchable)
    ├── searchText: String                 // debounced
    ├── filteredItems: [Item]
    └── filteredFlatList: [(item: Item, depth: Int)]
```

### 2. TreeView becomes a pure rendering View

**Decision**: TreeView reads `flatList` (or `filteredFlatList` during search) from the ViewModel. It no longer holds `@State lookup` or calls `buildFlatList()` in body.

**Rationale**: Separates data processing from rendering. The View's only job is `ForEach(viewModel.activeFlatList)` → render rows.

**API change**:
```swift
// Before
TreeView(items: sites, expandedState: $expandedState, depthIndent: 0) { item, depth, hasChildren in ... }

// After
TreeView(viewModel: siteTreeVM, depthIndent: 0) { item, depth, hasChildren in ... }
```

### 3. SearchableTreeView becomes a thin wrapper

**Decision**: SearchableTreeView connects the `@Environment(\.searchingText)` to `viewModel.searchText`. All filtering, ancestor expansion, and state save/restore logic lives in TreeViewModel.

**Rationale**: SearchableTreeView currently duplicates TreeView's structure (it creates an inner TreeView). With the ViewModel owning search state, SearchableTreeView just needs to:
1. Bind search text from environment to ViewModel
2. Render TreeView with the same ViewModel
3. Show NoResultCover when filtered results are empty

### 4. DeviceManager adds `siteLookup` via `didSet`

**Decision**: Add `siteLookup: [String: SiteItem]` to DeviceManager, rebuilt in `sites.didSet`.

**Why not only in TreeViewModel**: `findSite(id:)` is a domain-layer query used across the app (not just in tree views). Fixing it at the source benefits all callers. TreeViewModel's `idLookup` serves a different purpose (generic tree search), and the two don't replace each other.

```swift
@Published public var sites: [SiteItem] = [] {
    didSet { siteLookup = Dictionary(uniqueKeysWithValues: sites.map { ($0.id, $0) }) }
}
private(set) var siteLookup: [String: SiteItem] = [:]

public func findSite(id: String) -> SiteItem? { siteLookup[id] }
```

### 5. HighlightedText Regex escaping

**Decision**: Escape user input with `NSRegularExpression.escapedPattern(for:)` before constructing `Regex`.

**Rationale**: Currently `try? Regex(keyword)` silently fails on special characters like `(`, `[`, `*`. This is a bug, not a performance issue, but it's a one-line fix worth including.

### 6. SearchableTreeViewModel exposes `items` proxy and static factory

**Decision**: Add a top-level `items` property on `SearchableTreeViewModel` that forwards to `treeVM.items`, and a constrained `static func make(sites:)` for `SiteItem` usage.

**Rationale**: Consumers currently write `searchVM.treeVM.items = newSites` which leaks internal structure. The proxy hides the dual-VM implementation. The static factory eliminates explicit generic parameter `<SiteItem>` at call sites and provides a pattern for future item types.

```swift
// SearchableTreeViewModel
var items: [Item] {
    get { treeVM.items }
    set { treeVM.items = newValue }
}

// Constrained extension
extension SearchableTreeViewModel where Item == SiteItem {
    static func make(sites: [SiteItem]) -> SearchableTreeViewModel<SiteItem> {
        let vm = SearchableTreeViewModel<SiteItem>()
        vm.items = sites
        return vm
    }
}
```

### 7. Replace `managesExpandState: Bool` with `ExpansionMode` enum

**Decision**: Introduce an `ExpansionMode` enum to express expansion behavior instead of a Bool controlling optional state.

**Why over alternative**: `managesExpandState: Bool` requires readers to understand that `nil expandedState` means "always expanded" — a non-obvious convention. An enum makes the behavior self-documenting.

```swift
enum ExpansionMode {
    case alwaysExpanded
    case managed
}

init(expansionMode: ExpansionMode = .alwaysExpanded) {
    self.expandedState = expansionMode == .managed ? ExpandedState() : nil
}
```

### 8. SearchableTreeView shows empty state when searching but no text entered

**Decision**: Add `@Environment(\.isSearching)` to `SearchableTreeView`. When `isSearching == true` and `searchText` is empty, render empty content instead of the full tree.

**Rationale**: All other search UIs in the app (ViewTab `SiteList`, `CustomizedViewTabView`) show an empty state when search is activated but no text is typed. The current SearchableTreeView shows the full tree, which is inconsistent.

**Fallback**: If `isSearching` doesn't trigger correctly with `displayMode: .always`, fall back to a custom environment key (e.g., `\.isSearchingActive`) set by `customSearchable`.

## Risks / Trade-offs

**[TreeView API is breaking]** → All current TreeView consumers (MoveToSiteView) must adapt to the new init signature. Mitigation: The migration is mechanical (wrap items + expandedState into a ViewModel). ViewTabSiteView (on a separate branch) will adopt the new API when that branch is updated.

**[TreeViewModel holds mutable state outside View]** → `@Observable` objects as `@State` in SwiftUI have well-defined lifecycle, but care is needed to avoid retain cycles. Mitigation: TreeViewModel has no closures or delegates that could create cycles. It's a plain data container.

**[flatList cache staleness]** → If `items` or `expandedState` are modified outside the ViewModel, the cache won't update. Mitigation: All mutations go through the ViewModel's API. Items are set via property (triggers `didSet`), expand state is managed by ViewModel methods.

**[Two lookup dictionaries for site data]** → `DeviceManager.siteLookup` and `TreeViewModel<SiteItem>.idLookup` both exist. This is intentional — they serve different layers (domain vs. UI component) and different consumers. The memory overhead of a second dictionary is negligible compared to the items array itself.
