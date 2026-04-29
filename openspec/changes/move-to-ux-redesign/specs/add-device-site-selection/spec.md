## MODIFIED Requirements

### Requirement: Site list display when Sites exist
MoveToSiteView SHALL display Sites in a hierarchical tree view using the generic TreeView component when at least one Site exists. The tree SHALL be always-expanded (no expand/collapse) with a section header above the tree.

#### Scenario: Sites exist in organization
- **WHEN** user navigates to MoveToSiteView during Add Device or Move Device flow
- **AND** `deviceManager.sites` is not empty
- **THEN** system SHALL display a SearchableTreeView with SiteItem hierarchy and nil expandedState (always-expanded mode)

#### Scenario: Section header above tree
- **WHEN** MoveToSiteView displays the site tree
- **THEN** a section header row SHALL appear above the tree inside the scrollable area
- **AND** the left side SHALL display "Select a destination" in secondary text style
- **AND** the right side SHALL display "Create site or area" as a tappable text link (when `canCreateSite()` is true)
- **AND** tapping "Create site or area" SHALL navigate to SiteInformationView with `site: nil`

#### Scenario: Section header replaces bottom create button
- **WHEN** MoveToSiteView displays the site tree
- **THEN** the previous bottom "Create site" ghost button SHALL be removed
- **AND** "Create site or area" in the section header SHALL be the only entry point for site creation

#### Scenario: Tree row shows site name with trailing indicator
- **WHEN** the tree view renders each SiteItem row
- **THEN** the row SHALL display the site's leaf name (last pathComponent) and icon
- **AND** the trailing area SHALL show one of: "Current" label if the site is the device's current site, a checkmark if the site is selected, or nothing

#### Scenario: Selecting a site from tree
- **WHEN** user taps a Site/Area row in the tree view
- **THEN** the same selection logic as the current flat list SHALL execute (tapSiteRow)
- **AND** the view SHALL dismiss after selection (Add flow) or update selection state (Move flow)

### Requirement: Current site indicator
MoveToSiteView SHALL display a "Current" label on the row corresponding to the device's current site/area location.

#### Scenario: Current site marked in Move flow
- **WHEN** MoveToSiteView is opened in Move flow for a device with an existing siteID
- **THEN** the site row matching the device's current siteID SHALL display "Current" text in secondary style on the trailing side

#### Scenario: No current marker in Add flow
- **WHEN** MoveToSiteView is opened in Add flow (device has no siteID yet)
- **THEN** no row SHALL display the "Current" label

#### Scenario: Current and selected are mutually exclusive in display
- **WHEN** user selects a different site than the current one
- **THEN** the current site row SHALL show "Current" label
- **AND** the selected site row SHALL show a checkmark
- **AND** no row SHALL show both indicators simultaneously

#### Scenario: Selecting the current site
- **WHEN** user taps the row that is marked as "Current"
- **THEN** the row SHALL show both "Current" label and a checkmark is NOT required (site is already there)

### Requirement: Bottom-fixed action button in Move flow
In the Move flow, MoveToSiteView SHALL display a "Move device" button fixed at the bottom of the screen, outside the scrollable area.

#### Scenario: Move button visible in Move flow
- **WHEN** MoveToSiteView is opened in Move flow
- **THEN** a "Move device" button SHALL be displayed fixed at the bottom of the screen
- **AND** the button SHALL be outside the scrollable tree content

#### Scenario: Move button disabled when no selection
- **WHEN** no site is selected
- **THEN** the "Move device" button SHALL be disabled with muted styling

#### Scenario: Move button enabled when site selected
- **WHEN** user selects a site (different from current site)
- **THEN** the "Move device" button SHALL be enabled with filled styling

#### Scenario: Move button triggers confirmation page
- **WHEN** user taps the enabled "Move device" button
- **THEN** the system SHALL present `MoveDeviceConfirmationView` as a sheet

#### Scenario: Move button hidden in Add flow
- **WHEN** MoveToSiteView is opened in Add flow
- **THEN** the bottom "Move device" button SHALL NOT be displayed
- **AND** site selection SHALL immediately dismiss the view as before

### Requirement: Search filters tree while preserving ancestor hierarchy
When the user searches in MoveToSiteView, the tree SHALL show only matching Sites/Areas and their ancestor chain, keeping the tree structure intact.

#### Scenario: Search matches a deep node
- **WHEN** user types a keyword in the search bar
- **AND** a Site/Area at depth N matches the keyword
- **THEN** the tree SHALL display that node and all its ancestors up to the root
- **AND** the tree structure (indentation, parent-child relationship) SHALL be preserved

#### Scenario: Non-matching siblings hidden
- **WHEN** user types a keyword in the search bar
- **AND** a node does not match the keyword and has no matching descendants
- **THEN** that node SHALL NOT appear in the tree

#### Scenario: Search cleared restores full tree
- **WHEN** user clears the search keyword
- **THEN** the full tree SHALL be restored (all nodes visible, since expandedState is nil)

#### Scenario: No results found
- **WHEN** user types a keyword that matches no Sites/Areas
- **THEN** the tree SHALL display an empty state (NoResultCover)
