## Purpose

Generic `@Observable` ViewModel that centralizes tree data processing — lookups, cached flat list, expand/collapse state, and search filtering — for all TreeView consumers.

## ADDED Requirements

### Requirement: Generic TreeViewModel with cached lookups

TreeViewModel SHALL be a generic `@Observable` class parameterized on `Item: Hierarchable & Equatable` that maintains `childrenLookup` and `idLookup` dictionaries, rebuilt only when `items` changes.

#### Scenario: Lookups rebuilt on items change

- **WHEN** `items` property is set on TreeViewModel
- **THEN** `childrenLookup` SHALL be rebuilt as `Dictionary(grouping: items, by: \.parentId)`
- **AND** `idLookup` SHALL be rebuilt as `Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })`
- **AND** `flatList` SHALL be rebuilt

#### Scenario: Lookups not rebuilt on unrelated state change

- **WHEN** `expandedState` changes but `items` has not changed
- **THEN** `childrenLookup` and `idLookup` SHALL NOT be rebuilt
- **AND** only `flatList` SHALL be rebuilt

### Requirement: Cached flat list computation

TreeViewModel SHALL maintain a cached `flatList: [(item: Item, depth: Int)]` that is recomputed only when `items` or `expandedState` change — not on every SwiftUI body evaluation.

#### Scenario: FlatList built via DFS on expanded nodes

- **WHEN** flatList is computed
- **THEN** it SHALL perform a depth-first walk starting from root items (parentId == nil)
- **AND** it SHALL only descend into nodes whose ID is in the expanded set
- **AND** each entry SHALL contain the item and its depth level

#### Scenario: FlatList recomputed on expand toggle

- **WHEN** a node's expanded state is toggled via `toggle(_:)`
- **THEN** `flatList` SHALL be recomputed to include or exclude descendants

#### Scenario: FlatList not recomputed on body re-evaluation

- **WHEN** SwiftUI re-evaluates a View's body due to unrelated state changes
- **THEN** TreeViewModel's `flatList` SHALL return the previously cached value without recomputation

### Requirement: Expand/collapse state management

TreeViewModel SHALL own and manage `ExpandedState<Item.ID>` internally, exposing methods for toggling, expanding all, and collapsing all.

#### Scenario: Toggle single node

- **WHEN** `toggle(id)` is called
- **THEN** the node's expanded state SHALL flip
- **AND** `flatList` SHALL be recomputed

#### Scenario: Expand all with ID set

- **WHEN** `expandAll(ids)` is called with a set of IDs
- **THEN** all provided IDs SHALL be marked as expanded
- **AND** `flatList` SHALL be recomputed

#### Scenario: Collapse all

- **WHEN** `collapseAll()` is called
- **THEN** all nodes SHALL be marked as collapsed
- **AND** `flatList` SHALL be recomputed

#### Scenario: External read access to expanded state

- **WHEN** a consumer needs to check if a specific node is expanded
- **THEN** `isExpanded(_:)` SHALL return the current state without triggering recomputation

### Requirement: Search filtering for Searchable items

When `Item` also conforms to `Searchable`, TreeViewModel SHALL support keyword-based search with debounce, ancestor expansion, and state save/restore.

#### Scenario: Debounced search text

- **WHEN** `searchText` is set
- **THEN** TreeViewModel SHALL debounce for 500ms before applying the filter
- **AND** if `searchText` changes again within the debounce window, the previous filter SHALL be cancelled

#### Scenario: Search filters items and expands ancestors

- **WHEN** debounced search text is non-empty
- **THEN** TreeViewModel SHALL filter items using `item.contains(keyword:)`
- **AND** for each matching item, all ancestor items SHALL be included in the filtered result
- **AND** ancestor IDs SHALL be added to the expanded set so matches are visible
- **AND** a `filteredFlatList` SHALL be computed from the filtered items

#### Scenario: Empty search restores previous expand state

- **WHEN** search text becomes empty after a non-empty search
- **THEN** TreeViewModel SHALL restore the expand state that was saved before the search began
- **AND** `flatList` SHALL be recomputed using the restored expand state

#### Scenario: Active flat list selection

- **WHEN** search is active (non-empty debounced text)
- **THEN** `activeFlatList` SHALL return `filteredFlatList`
- **WHEN** search is inactive
- **THEN** `activeFlatList` SHALL return `flatList`

### Requirement: DeviceManager site lookup optimization

DeviceManager SHALL maintain a `siteLookup: [String: SiteItem]` dictionary for O(1) site lookup by ID.

#### Scenario: siteLookup rebuilt on sites change

- **WHEN** `DeviceManager.sites` is set
- **THEN** `siteLookup` SHALL be rebuilt as `Dictionary(uniqueKeysWithValues: sites.map { ($0.id, $0) })`

#### Scenario: findSite uses dictionary lookup

- **WHEN** `findSite(id:)` is called
- **THEN** it SHALL return `siteLookup[id]` (O(1))
- **AND** it SHALL NOT iterate over the sites array

### Requirement: HighlightedText regex safety

HighlightedText SHALL escape user input before constructing a Regex to prevent silent failures on special characters.

#### Scenario: Special characters in keyword

- **WHEN** `keyword` contains regex special characters (e.g., `(`, `[`, `*`, `+`)
- **THEN** HighlightedText SHALL escape the keyword before creating the Regex
- **AND** the escaped keyword SHALL match as a literal string

#### Scenario: Normal keyword unchanged

- **WHEN** `keyword` contains no regex special characters
- **THEN** HighlightedText SHALL match case-insensitively as before
