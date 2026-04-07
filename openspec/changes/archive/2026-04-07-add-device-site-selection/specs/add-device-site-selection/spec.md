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
MoveToSiteView SHALL display the normal searchable Site list when at least one Site exists.

#### Scenario: Sites exist in organization
- **WHEN** user navigates to MoveToSiteView during Add Device flow
- **AND** `deviceManager.sites` is not empty
- **THEN** system SHALL display the searchable Site list
- **AND** empty state SHALL NOT be displayed
