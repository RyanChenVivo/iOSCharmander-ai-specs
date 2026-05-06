## Why

TreeView and SearchableTreeView currently duplicate lookup construction and flat list computation across every usage site. Each View independently builds `childrenLookup`, `idLookup`, and `flatList` on every body evaluation, with no caching or sharing. As TreeView adoption grows (MoveToSiteView, ViewTabSiteView, and future consumers), this duplication compounds — causing redundant O(n) work per render cycle and scattering data-processing logic across View layers that should only handle rendering. Additionally, `DeviceManager.findSite(id:)` performs O(n) linear search, which becomes a bottleneck when called repeatedly from SwiftUI body computations.

## What Changes

- **Introduce `TreeViewModel<Item>`**: A generic `@Observable` class that owns `items`, `expandedState`, `childrenLookup`, `idLookup`, and cached `flatList`. Lookups and flatList are recomputed only when `items` or `expandedState` change — not on every body evaluation.
- **Simplify `TreeView` to a pure rendering View**: TreeView reads `flatList` from the injected ViewModel instead of computing it internally. It no longer holds `@State` lookup or runs `buildFlatList()` in body.
- **Merge `SearchableTreeView` search logic into `TreeViewModel`**: Debounced keyword filtering, ancestor expansion, and filtered item computation move into the ViewModel. `SearchableTreeView` becomes a thin wrapper that connects the search environment to the ViewModel.
- **Add `siteLookup` to `DeviceManager`**: A `[String: SiteItem]` dictionary maintained via `didSet` on `sites`, making `findSite(id:)` O(1). This also serves as the `idLookup` for site-based TreeViewModel instances, avoiding duplicate dictionary construction.
- **Fix `HighlightedText` Regex safety**: Escape user input before constructing `Regex` to prevent silent failures on special characters (e.g., `(`, `[`, `*`).

## Capabilities

### New Capabilities
- `treeview-viewmodel`: Generic TreeViewModel that centralizes tree data processing (lookups, flat list caching, search filtering, expand state management) for all TreeView consumers.

### Modified Capabilities
- `site-picker-tree-view`: TreeView and SearchableTreeView internal architecture changes — consumers pass a TreeViewModel instead of raw items + expandedState. The `idLookup` for site search uses `DeviceManager.siteLookup` instead of building its own.

## Impact

- **TreeView.swift**: API changes — init accepts `TreeViewModel` instead of `items` + `expandedState` + `lookup`. **BREAKING** for all current TreeView consumers (MoveToSiteView, ViewTabSiteView).
- **SearchableTreeView**: Becomes a thin View wrapper; search logic moves to TreeViewModel. Internal-only change, external API can remain compatible. Adds `isSearching` empty state for UX consistency.
- **SearchableTreeViewModel**: Adds `items` proxy property. Adds `static func make(sites:)` factory for SiteItem. Replaces `managesExpandState: Bool` with `ExpansionMode` enum.
- **DeviceManager**: Adds `siteLookup` dictionary property and changes `findSite(id:)` to O(1) lookup. Non-breaking — same public interface, better performance.
- **MoveToSiteView / SiteSelectionView / SitePickerSheet**: Migrated to use `.make(sites:)` and `.items` proxy instead of `searchVM.treeVM.items`.
- **HighlightedText**: Regex input escaping. No API change.
- **Unit tests**: New tests for TreeViewModel caching behavior; existing TreeView tests need adaptation for new init signature.
