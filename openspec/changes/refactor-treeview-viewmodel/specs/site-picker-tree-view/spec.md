## MODIFIED Requirements

### Requirement: Generic tree view component
TreeView SHALL be a generic SwiftUI component that renders any `Identifiable` item collection as a hierarchical tree with expand/collapse support. The row content SHALL be provided by the caller via a `@ViewBuilder` closure. TreeView SHALL receive a `TreeViewModel` instance instead of raw items and expand state.

#### Scenario: Component generic interface
- **WHEN** TreeView is instantiated
- **THEN** it SHALL accept a `TreeViewModel<Item>` instance and a `@ViewBuilder rowContent: @escaping (Item, Int, Bool) -> RowContent` closure
- **AND** it SHALL read `activeFlatList` from the ViewModel for rendering
- **AND** it SHALL read `childrenLookup` from the ViewModel to determine if a node has children

#### Scenario: Rendering tree from ViewModel flat list
- **WHEN** TreeView renders its body
- **THEN** it SHALL iterate over `viewModel.activeFlatList` with `ForEach`
- **AND** it SHALL NOT compute flat list or build lookup dictionaries internally

### Requirement: Flattened rendering with single LazyVStack
TreeView SHALL render the ViewModel's flat list with one `LazyVStack`. It SHALL NOT use nested lazy containers or compute the flat list itself.

#### Scenario: Flattened list construction
- **WHEN** the tree is rendered
- **THEN** TreeView SHALL read the pre-computed flat list from `viewModel.activeFlatList`
- **AND** render it with a single `LazyVStack` + `ForEach`

#### Scenario: Collapsed subtree excluded from flat list
- **WHEN** a node is collapsed
- **THEN** all its descendants SHALL be excluded from the flat list regardless of their own expand state

#### Scenario: Performance at scale
- **WHEN** the tree contains tens of thousands of nodes total
- **THEN** the flat list SHALL only contain expanded branches (O(visible nodes))
- **AND** LazyVStack SHALL only render rows visible on screen
- **AND** SwiftUI body re-evaluation SHALL NOT trigger flat list recomputation
