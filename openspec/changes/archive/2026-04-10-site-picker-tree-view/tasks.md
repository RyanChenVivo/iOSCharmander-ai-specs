## 1. Model: Add parentId to SiteItem

- [x] 1.1 Add `public let parentId: String?` to `SiteItem`, populated from `site.parentId` (empty string → nil)
- [x] 1.2 Update `TestUtility.makeSiteItem` in iOSCharmanderTests to include `parentId` parameter (default `""`)

## 2. Generic TreeView Component

- [x] 2.1 Create `Hierarchable` protocol (`Identifiable` + `parentId`) in `TreeView.swift`
- [x] 2.2 Create `ExpandedState<ID>` value type with `toggle()`, `isExpanded()`, `expandAll()`, `collapseAll()`
- [x] 2.3 Create `TreeView<Item: Hierarchable, RowContent>` with flattened single-`LazyVStack` architecture, accepting `items` flat list, `expandedState` binding, and `rowContent(item, depth, hasChildren)` builder
- [x] 2.4 Create `SearchableTreeView` wrapper that reads `@Environment(\.searchingText)`, filters items with ancestor preservation, and auto-expands ancestor nodes

## 3. MoveToSiteView Integration

- [x] 3.1 Add `SiteItem: Hierarchable` conformance in `SiteItem+Extension.swift`
- [x] 3.2 Replace `SearchableScrollItemListView` in MoveToSiteView with `SearchableTreeView`
- [x] 3.3 Provide site-specific row content with expand arrow, site icon, leaf name, and checkmark selection indicator
- [x] 3.4 Wire row tap to existing `viewModel.tapSiteRow` selection logic
- [x] 3.5 Add `TreeView.swift` to Xcode project.pbxproj (both targets)
