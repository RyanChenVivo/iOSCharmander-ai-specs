## MODIFIED Requirements

### Requirement: Empty state display when no Sites exist
MoveToSiteView SHALL display an empty state illustration when the organization has no Sites during the Add Device flow.

#### Scenario: Empty state includes Create Site or Area button
- **WHEN** empty state is displayed
- **THEN** system SHALL display a "Create Site or Area" button below the message
- **AND** tapping the button SHALL navigate to SiteInformationView with `site: nil`

#### Scenario: Empty state disappears after Site creation
- **WHEN** user creates a Site or Area via SiteInformationView and returns to MoveToSiteView
- **THEN** empty state SHALL be replaced by the Site list containing the newly created Site or Area

### Requirement: CreateSiteView supports type selection
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

#### Scenario: Creating an Area
- **WHEN** user creates an Area (type = Area) with a selected parent
- **THEN** `createSite` SHALL be called with `parentId` set to the selected parent's ID

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

## ADDED Requirements

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

## REMOVED Requirements

### Requirement: CreateSiteView as separate view
**Reason**: CreateSiteView and CreateSiteViewModel are merged into SiteInformationView and SiteInformationViewModel. All create capabilities (type picker, parent picker, area creation) are now handled by SiteInformationView.
**Migration**: All navigation destinations that pointed to CreateSiteView SHALL point to SiteInformationView with `site: nil`. CreateSiteView.swift and CreateSiteViewModel.swift SHALL be deleted.
