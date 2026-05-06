# add-device-site-selection Specification

## Purpose
Site selection behavior during the Add Device flow - including empty state handling, tree-based site/area selection, and site creation.

## Requirements

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

#### Scenario: Empty state includes Create Site or Area button
- **WHEN** empty state is displayed
- **THEN** system SHALL display a "Create Site or Area" button below the message
- **AND** tapping the button SHALL navigate to SiteInformationView with `site: nil`

#### Scenario: Empty state disappears after Site creation
- **WHEN** user creates a Site or Area via SiteInformationView and returns to MoveToSiteView
- **THEN** empty state SHALL be replaced by the Site list containing the newly created Site or Area

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

### Requirement: SiteInformationView supports type selection
SiteInformationView SHALL allow the user to choose between creating a Site or an Area via a segmented picker when in create mode.

#### Scenario: Type picker displayed in create mode
- **WHEN** user enters SiteInformationView with `site: nil` (create mode)
- **THEN** a segmented Picker with options "Site" and "Area" SHALL be displayed under a "Type" label
- **AND** "Site" SHALL be selected by default

#### Scenario: Type picker hidden in edit mode
- **WHEN** user enters SiteInformationView with a non-nil `site` (edit mode)
- **THEN** the type picker SHALL NOT be displayed
- **AND** the view SHALL determine site vs area from `site.parentId`

#### Scenario: Navigation title changes with mode and type
- **WHEN** in create mode with "Site" type selected
- **THEN** the navigation title SHALL be "Create Site"
- **WHEN** in create mode with "Area" type selected
- **THEN** the navigation title SHALL be "Create Area"
- **WHEN** in edit mode with a site (no parentId)
- **THEN** the navigation title SHALL be "Site Information"
- **WHEN** in edit mode with an area (has parentId)
- **THEN** the navigation title SHALL be "Area Information"

#### Scenario: Site type shows name and location fields
- **WHEN** user selects "Site" type in create mode, or edits a site
- **THEN** the form SHALL display Name (required) and Location (optional, feature-gated) fields
- **AND** the "Parent Site" field SHALL NOT be displayed

#### Scenario: Area type shows name and parent picker fields in create mode
- **WHEN** user selects "Area" type in create mode
- **THEN** the form SHALL display Name (required) and "Parent Site" (required) fields
- **AND** the Location field SHALL NOT be displayed

#### Scenario: Area edit shows name field only
- **WHEN** user edits an area (site with non-empty parentId)
- **THEN** the form SHALL display only the Name field
- **AND** the Location field SHALL NOT be displayed
- **AND** the "Parent Site" field SHALL NOT be displayed

#### Scenario: Auto-generated name changes with type
- **WHEN** user selects "Site" type in create mode
- **THEN** the default name SHALL be "Site N" where N is the current site count
- **WHEN** user selects "Area" type in create mode
- **THEN** the default name SHALL be "Area N" where N is the current site count

### Requirement: Area parent selection
When creating an Area, the user MUST select a parent Site or Area. The parent field SHALL be marked as required.

#### Scenario: Parent picker opens as sheet
- **WHEN** user taps the parent field in Area creation mode
- **THEN** a sheet SHALL present the site tree view for parent selection

#### Scenario: Parent selection displayed
- **WHEN** user selects a parent from the tree view
- **THEN** the parent field SHALL display the selected parent's name
- **AND** the sheet SHALL dismiss

#### Scenario: Create button disabled without parent
- **WHEN** user is in Area creation mode
- **AND** no parent has been selected
- **THEN** the Create button SHALL be disabled

### Requirement: CreateSite API supports parentId
The `createSite` function SHALL accept an optional `parentId` parameter and pass it to the backend API.

#### Scenario: Creating a top-level Site
- **WHEN** user creates a Site (type = Site)
- **THEN** `createSite` SHALL be called with `parentId: nil`
- **AND** `AddSiteInput` SHALL omit `parentId` or send empty string

#### Scenario: Creating an Area
- **WHEN** user creates an Area (type = Area) with a selected parent
- **THEN** `createSite` SHALL be called with `parentId` set to the selected parent's ID
- **AND** `AddSiteInput` SHALL include `parentId` in the request body

### Requirement: Site creation error handling
The system SHALL handle backend 403 errors during site/area creation and display user-friendly messages.

#### Scenario: Site limit exceeded
- **WHEN** backend returns 403 with type `/problems/site-limit-exceeded`
- **THEN** system SHALL display an error message indicating the site limit has been reached

#### Scenario: Hierarchy depth exceeded
- **WHEN** backend returns 403 with type `/problems/hierarchy-depth-exceeded`
- **THEN** system SHALL display an error message indicating the maximum area nesting depth has been reached

#### Scenario: Area count exceeded
- **WHEN** backend returns 403 with type `/problems/subsite-count-exceeded`
- **THEN** system SHALL display an error message indicating the maximum number of areas under this parent has been reached

### Requirement: SiteInformationView supports editing areas
SiteInformationView SHALL support editing areas (sites with non-empty parentId) in addition to root-level sites. Editing an area SHALL only allow changing the name.

#### Scenario: Edit area from context menu
- **WHEN** user long-presses an area in MoveToSiteView
- **AND** taps the edit option
- **THEN** SiteInformationView SHALL open with the area's `SiteItem`
- **AND** the name field SHALL be pre-populated with the area's current name

#### Scenario: Save area name change
- **WHEN** user edits the name of an area and taps Save
- **THEN** `deviceManager.updateSite(_:name:location:)` SHALL be called with the area's SiteItem, new name, and `nil` location
- **AND** the view SHALL dismiss on success

#### Scenario: Area edit error handling
- **WHEN** updating an area fails
- **THEN** the system SHALL display a "fail to save" error alert
- **AND** the view SHALL remain open

### Requirement: Toolbar button varies by mode
SiteInformationView SHALL display a Create button in create mode and a Save button in edit mode.

#### Scenario: Create mode toolbar
- **WHEN** SiteInformationView is in create mode (`site: nil`)
- **THEN** the toolbar SHALL display a NavigationCreateButton

#### Scenario: Edit mode toolbar
- **WHEN** SiteInformationView is in edit mode (non-nil `site`)
- **THEN** the toolbar SHALL display a NavigationSaveButton

### Requirement: Unified canSave validation
SiteInformationView SHALL validate form completeness before enabling the save/create button.

#### Scenario: Name required for all modes
- **WHEN** the name field is empty
- **THEN** the save/create button SHALL be disabled

#### Scenario: Parent required for area creation
- **WHEN** in create mode with Area type selected
- **AND** no parent site has been selected
- **THEN** the create button SHALL be disabled

#### Scenario: Name sufficient for site creation
- **WHEN** in create mode with Site type selected
- **AND** the name field is not empty
- **THEN** the create button SHALL be enabled (location is optional)

#### Scenario: Name sufficient for area edit
- **WHEN** in edit mode for an area
- **AND** the name field is not empty
- **THEN** the save button SHALL be enabled

### Requirement: Site selection uses SiteSelectionView
AddDeviceByMacView and AddVSSView SHALL use `SiteSelectionView` with the single-select init for site selection.

#### Scenario: NavigationLink uses single-select init
- **WHEN** user taps the Site field in AddDeviceByMacView or AddVSSView
- **THEN** the NavigationLink SHALL push `SiteSelectionView(selectedSiteID: $siteID)` where `siteID` is a `Binding<String?>`

#### Scenario: Site persists after Save
- **WHEN** user selects a Site in SiteSelectionView (single mode)
- **AND** taps Save
- **AND** returns to AddDeviceByMacView
- **THEN** the selected Site name SHALL be displayed in the Site field
- **AND** `device.siteID` SHALL be set to the selected site's ID

#### Scenario: Selection discarded on Cancel
- **WHEN** user selects a Site in SiteSelectionView (single mode)
- **AND** taps Cancel (or navigates back)
- **THEN** the device's siteID SHALL remain unchanged