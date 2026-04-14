## MODIFIED Requirements

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
- **AND** tapping the button SHALL navigate to CreateSiteView

#### Scenario: Empty state disappears after Site creation
- **WHEN** user creates a Site or Area via CreateSiteView and returns to MoveToSiteView
- **THEN** empty state SHALL be replaced by the Site list containing the newly created Site or Area

## ADDED Requirements

### Requirement: CreateSiteView supports type selection
CreateSiteView SHALL allow the user to choose between creating a Site or an Area via a segmented picker.

#### Scenario: Type picker displayed
- **WHEN** user enters CreateSiteView
- **THEN** a segmented Picker with options "Site" and "Area" SHALL be displayed under a "Type" label
- **AND** "Site" SHALL be selected by default

#### Scenario: Navigation title changes with type
- **WHEN** user selects "Site" type
- **THEN** the navigation title SHALL be "Create Site"
- **WHEN** user selects "Area" type
- **THEN** the navigation title SHALL be "Create Area"

#### Scenario: Site type shows name and location fields
- **WHEN** user selects "Site" type
- **THEN** the form SHALL display Name (required) and Location (optional) fields
- **AND** the "Parent Site" field SHALL NOT be displayed
- **AND** this SHALL match the current CreateSiteView behavior

#### Scenario: Area type shows name and parent picker fields
- **WHEN** user selects "Area" type
- **THEN** the form SHALL display Name (required) and "Parent Site" (required) fields
- **AND** the Location field SHALL NOT be displayed

#### Scenario: Auto-generated name changes with type
- **WHEN** user selects "Site" type
- **THEN** the default name SHALL be "Site N" where N is the current site count
- **WHEN** user selects "Area" type
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
