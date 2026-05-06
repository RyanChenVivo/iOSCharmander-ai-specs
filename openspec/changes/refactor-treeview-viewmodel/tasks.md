## 1. DeviceManager siteLookup

- [ ] ~~1.1 Add `siteLookup: [String: SiteItem]` property to DeviceManager, rebuilt in `sites.didSet`~~ (skipped)
- [ ] ~~1.2 Change `findSite(id:)` to return `siteLookup[id]`~~ (skipped)
- [ ] ~~1.3 Update `MockDeviceManager.findSite(id:)` to match~~ (skipped)
- [ ] ~~1.4 Add unit test verifying `findSite` returns correct result after sites update~~ (skipped)

## 2. TreeViewModel core

- [x] 2.1 Rename `TreeUtilities.swift` to `TreeViewModel.swift`, remove old contents (`idLookup` extension, `ancestorIDs`, `search()`, `ExpandedState`), keep `Hierarchable` protocol
- [x] 2.2 Create `TreeViewModel<Item: Hierarchable & Equatable>` as `@MainActor @Observable` class in the same file
- [x] 2.3 Implement `items` property with `didSet` that rebuilds `childrenLookup`, `idLookup`, and `flatList`
- [x] 2.4 Implement `expandedState` management (`toggle`, `expandAll`, `collapseAll`, `isExpanded`) with `flatList` rebuild on change
- [x] 2.5 Implement `buildFlatList()` using DFS on `childrenLookup`, only descending into expanded nodes
- [x] 2.6 Add `activeFlatList` computed property that returns `filteredFlatList` during search, `flatList` otherwise
- [x] 2.7 Add unit tests for lookups rebuild, flatList caching, and expand/collapse behavior

## 3. TreeViewModel search

- [x] 3.1 Add search support (constrained extension where `Item: Searchable`): `searchText` with 500ms debounce
- [x] 3.2 Implement search filtering with ancestor expansion using `idLookup`
- [x] 3.3 Implement expand state save/restore on search enter/exit
- [x] 3.4 Add unit tests for search filtering, ancestor inclusion, and state restore

## 4. TreeView refactor

- [x] 4.1 Change `TreeView` init to accept `TreeViewModel<Item>` instead of `items` + `expandedState` + internal lookup
- [x] 4.2 Remove `@State lookup`, `buildFlatList()`, and `onChange(of: items)` from TreeView — read from ViewModel
- [x] 4.3 Update `TreeView` body to iterate `viewModel.activeFlatList`

## 5. SearchableTreeView refactor

- [x] 5.1 Remove `@State debouncedText`, `filteredItems`, `idLookup`, `savedExpandedIDs` from SearchableTreeView
- [x] 5.2 Connect `@Environment(\.searchingText)` to `viewModel.searchText`
- [x] 5.3 Render single `TreeView(viewModel:)` + `NoResultCover` based on ViewModel state

## 6. MoveToSiteView adaptation

- [x] 6.1 Create `TreeViewModel<SiteItem>` in MoveToSiteView, set `items` from `deviceManager.sites`
- [x] 6.2 Pass TreeViewModel to SearchableTreeView
- [x] 6.3 Verify MoveToSiteView behavior unchanged (selection, search, create site, context menu)

## 7. HighlightedText fix

- [x] 8.1 Escape keyword with `NSRegularExpression.escapedPattern(for:)` before constructing Regex
- [x] 8.2 Add unit test for special character keyword (e.g., `(test)` matches literal `(test)`)

## 9. API refinement

- [x] 9.1 Add `items` proxy to `SearchableTreeViewModel` (get/set forwarding to `treeVM.items`)
- [x] 9.2 Add `SearchableTreeViewModel.make(sites:)` static factory (`where Item == SiteItem`)
- [x] 9.3 Migrate `MoveToSiteView` to use `.make(sites:)` and `.items` proxy
- [x] 9.4 Migrate `SiteSelectionView` to use `.make(sites:)` and `.items` proxy
- [x] 9.5 Migrate `SitePickerSheet` (in SiteInformationView) to use `.make(sites:)` and `.items` proxy
- [x] 9.6 Change `rebuildFlatList()` to `private`
- [x] 9.7 Replace `managesExpandState: Bool` with `ExpansionMode` enum
- [x] 9.8 Update all call sites for new `ExpansionMode` API

## 10. Search UX consistency

- [x] 10.1 Add `@Environment(\.isSearching)` to `SearchableTreeView`
- [x] 10.2 When `isSearching == true` && `searchText` is empty → show empty state (not full tree)
- [x] 10.3 Hide MoveToSiteView controlBar when `isSearching`
- [x] 10.4 Verify `isSearching` behavior with `displayMode: .always` (manual test task)

## 11. Verification

- [x] 11.1 Build project and verify no compilation errors
- [ ] 11.2 Run existing unit tests and verify all pass (blocked by pre-existing VortexFeaturesTests SharedLink error)
- [x] 11.3 Manual test MoveToSiteView: search, select site, expand/collapse, create site
- [x] 11.4 Manual test SiteSelectionView (single + multi mode)
- [x] 11.5 Manual test SitePickerSheet in SiteInformationView
