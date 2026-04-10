## ADDED Requirements

### Requirement: Generic tree view component
TreeView SHALL be a generic SwiftUI component that renders any `Identifiable` item collection as a hierarchical tree with expand/collapse support. The row content SHALL be provided by the caller via a `@ViewBuilder` closure.

#### Scenario: Component generic interface
- **WHEN** TreeView is instantiated
- **THEN** it SHALL accept generic type parameters: `Item` (conforming to `Identifiable`) and `RowContent: View`
- **AND** it SHALL accept `items: [Item]`, `children: @escaping (Item) -> [Item]`, and `@ViewBuilder rowContent: @escaping (Item, Int, Bool) -> RowContent` parameters
- **AND** the `Int` parameter in rowContent SHALL represent the depth level (0 for root)
- **AND** the `Bool` parameter in rowContent SHALL indicate whether the item has children

#### Scenario: Rendering tree from items and children closure
- **WHEN** TreeView receives items and a children closure
- **THEN** root-level items SHALL be rendered at the top level
- **AND** for each expanded item, the children closure SHALL be called to determine its child items
- **AND** child items SHALL appear below their parent in the flat rendering order

### Requirement: Flattened rendering with single LazyVStack
TreeView SHALL internally flatten the visible tree into a single flat list and render it with one `LazyVStack`. It SHALL NOT use nested lazy containers.

#### Scenario: Flattened list construction
- **WHEN** the tree is rendered
- **THEN** TreeView SHALL walk the tree recursively, only descending into expanded nodes
- **AND** produce a flat array of `(item, depth)` tuples
- **AND** render this flat array with a single `LazyVStack` + `ForEach`

#### Scenario: Collapsed subtree excluded from flat list
- **WHEN** a node is collapsed
- **THEN** all its descendants SHALL be excluded from the flat list regardless of their own expand state

#### Scenario: Performance at scale
- **WHEN** the tree contains tens of thousands of nodes total
- **THEN** the walk SHALL only traverse expanded branches (O(visible nodes))
- **AND** LazyVStack SHALL only render rows visible on screen

### Requirement: Expand and collapse tree nodes
Each tree node that has children SHALL be expandable and collapsible via a tap target on the row.

#### Scenario: Node with children shows expand/collapse indicator
- **WHEN** an item has children (children closure returns non-empty array)
- **THEN** the row SHALL include a tappable expand/collapse arrow indicator

#### Scenario: Node without children renders as leaf
- **WHEN** an item has no children (children closure returns empty array)
- **THEN** the row SHALL render only the rowContent without any expand/collapse indicator

#### Scenario: Tapping expand indicator toggles children visibility
- **WHEN** user taps the expand/collapse indicator on a node
- **THEN** the node's expanded state SHALL toggle
- **AND** the flat list SHALL be recomputed to include or exclude descendants

#### Scenario: Default collapsed state
- **WHEN** the tree view first appears
- **THEN** all nodes SHALL be collapsed by default

#### Scenario: Caller can override expanded state
- **WHEN** the caller provides a set of item IDs to force-expand
- **THEN** those nodes SHALL be expanded in addition to any user-toggled expansions

#### Scenario: Expand state preserved across parent collapse/expand
- **WHEN** a parent node is collapsed and then re-expanded
- **THEN** child nodes that were previously expanded SHALL remain expanded
- **AND** their descendants SHALL reappear in the flat list
