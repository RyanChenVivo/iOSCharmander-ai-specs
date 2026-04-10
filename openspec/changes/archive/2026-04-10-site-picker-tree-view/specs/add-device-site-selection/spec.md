## MODIFIED Requirements

### Requirement: Site list display when Sites exist
MoveToSiteView SHALL display Sites in a hierarchical tree view using the generic TreeView component when at least one Site exists, replacing the current flat SearchableScrollItemListView.

#### Scenario: Sites exist in organization
- **WHEN** user navigates to MoveToSiteView during Add Device or Move Device flow
- **AND** `deviceManager.sites` is not empty
- **THEN** system SHALL display a TreeView with SiteItem hierarchy
- **AND** the flat SearchableScrollItemListView SHALL NOT be used

#### Scenario: Tree row shows site name with selection indicator
- **WHEN** the tree view renders each SiteItem row
- **THEN** the row SHALL display the site's leaf name (last pathComponent) and icon
- **AND** if the site matches `viewModel.selectedSite`, a checkmark indicator SHALL be shown

#### Scenario: Selecting a site from tree
- **WHEN** user taps a Site/Area row in the tree view
- **THEN** the same selection logic as the current flat list SHALL execute (tapSiteRow)
- **AND** the view SHALL dismiss after selection (Add flow) or confirm-then-dismiss (Move flow)

## ADDED Requirements

### Requirement: Search filters tree while preserving ancestor hierarchy
When the user searches in MoveToSiteView, the tree SHALL show only matching Sites/Areas and their ancestor chain, keeping the tree structure intact.

#### Scenario: Search matches a deep node
- **WHEN** user types a keyword in the search bar
- **AND** a Site/Area at depth N matches the keyword
- **THEN** the tree SHALL display that node and all its ancestors up to the root
- **AND** the tree structure (indentation, parent-child relationship) SHALL be preserved

#### Scenario: Search matches expand ancestors automatically
- **WHEN** search results are displayed in the tree
- **THEN** all ancestor nodes of matching items SHALL be automatically expanded
- **AND** the user SHALL see matching items without manually expanding nodes

#### Scenario: Non-matching siblings hidden
- **WHEN** user types a keyword in the search bar
- **AND** a node does not match the keyword and has no matching descendants
- **THEN** that node SHALL NOT appear in the tree

#### Scenario: Search cleared restores full tree
- **WHEN** user clears the search keyword
- **THEN** the full tree SHALL be restored with the previous expand/collapse state

#### Scenario: No results found
- **WHEN** user types a keyword that matches no Sites/Areas
- **THEN** the tree SHALL display an empty state (NoResultCover)
