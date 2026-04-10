## ADDED Requirements

### Requirement: No default Site pre-selection in Add Device flow
The Add Device configuration screen SHALL NOT pre-select a default Site. The user MUST explicitly select a Site.

#### Scenario: Initial Site field state
- **WHEN** user enters the Add Device configuration screen (AddDeviceByMacView or AddVSSView)
- **THEN** the Site field SHALL display "Select a site" placeholder text in a muted color (no Site selected)
- **AND** no default Site SHALL be assigned to the device

#### Scenario: Site persists after explicit selection
- **WHEN** user selects a Site in MoveToSiteView
- **AND** returns to AddDeviceByMacView
- **THEN** the selected Site name SHALL be displayed in the Site field

### Requirement: Add button disabled without valid Site
The Add button SHALL be disabled when no valid Site is selected for the device.

#### Scenario: Add button disabled when no Site selected
- **WHEN** user is on AddDeviceByMacView
- **AND** no Site has been selected (siteID is empty)
- **THEN** the Add button SHALL be disabled

#### Scenario: Add button disabled when selected Site was deleted
- **WHEN** user has selected a Site
- **AND** that Site is deleted via MoveToSiteView
- **THEN** `device.siteID` SHALL be cleared by MoveToSiteViewModel
- **AND** the Add button SHALL be disabled

#### Scenario: Add button enabled after Site selection
- **WHEN** user selects a valid Site in MoveToSiteView
- **AND** returns to AddDeviceByMacView
- **THEN** the Add button SHALL be enabled

### Requirement: Empty state display when no Sites exist
MoveToSiteView SHALL display an empty state illustration when the organization has no Sites during the Add Device flow.

#### Scenario: No Sites exist in organization
- **WHEN** user navigates to MoveToSiteView during Add Device flow
- **AND** `deviceManager.sites` is empty
- **THEN** system SHALL display a centered empty state illustration using the shared `NoResultView` component
- **AND** display a descriptive message indicating no Sites exist and prompting the user to create one

#### Scenario: Empty state includes Create Site button
- **WHEN** empty state is displayed
- **THEN** system SHALL display a "Create Site" button below the message
- **AND** tapping the button SHALL navigate to CreateSiteView

#### Scenario: Empty state disappears after Site creation
- **WHEN** user creates a Site via CreateSiteView and returns to MoveToSiteView
- **THEN** empty state SHALL be replaced by the Site list containing the newly created Site

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
