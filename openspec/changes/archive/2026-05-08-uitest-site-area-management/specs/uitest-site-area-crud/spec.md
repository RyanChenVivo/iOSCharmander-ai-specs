## ADDED Requirements

### Requirement: Create area under existing site

The UITest SHALL verify that a user can create a new area under an existing site through SiteInformationView's unified create interface.

#### Scenario: Create area under SiteC successfully
- **WHEN** user navigates to MoveToSiteView or SiteSelectionView
- **AND** user taps "Create_site_or_area" button
- **AND** user selects "Area" in the type segmented control
- **AND** user enters area name (e.g., "TestArea")
- **AND** user taps "Select_a_parent_site" and selects "UAT SiteC"
- **AND** user taps "Create" button
- **THEN** the new area SHALL appear in the site tree under UAT SiteC
- **AND** tearDown SHALL delete the created area to restore state

### Requirement: Delete area successfully

The UITest SHALL verify that a user can delete an area that has no devices and no sub-areas.

#### Scenario: Delete AreaB1 from SiteB
- **WHEN** user long-presses "UAT AreaB1" in the site tree to open context menu
- **AND** user taps "Delete"
- **AND** user types "DELETE" in the confirmation field
- **AND** user taps the Delete button
- **THEN** "UAT AreaB1" SHALL disappear from the site tree
- **AND** tearDown SHALL recreate AreaB1 to restore state (or test creates then deletes its own area)

#### Scenario: Create and delete own test area
- **WHEN** user creates a new area "TestDeleteArea" under SiteC
- **AND** user long-presses "TestDeleteArea" to open context menu
- **AND** user taps "Delete" and confirms with "DELETE"
- **THEN** "TestDeleteArea" SHALL disappear from the site tree
- **AND** no tearDown cleanup is needed (self-contained)

### Requirement: Error when deleting site with sub-areas

The UITest SHALL verify that attempting to delete a site that has sub-areas triggers the `cannotDeleteSiteWithSubSites` error.

#### Scenario: Cannot delete SiteB that has sub-areas
- **WHEN** user long-presses "UAT SiteB" in the site tree to open context menu
- **AND** user taps "Delete"
- **AND** user types "DELETE" and confirms
- **THEN** an alert SHALL appear with message matching "Cannot_delete_site_has_areas"

### Requirement: Error when creating area exceeding hierarchy depth

The UITest SHALL verify that attempting to create an area below the maximum depth (5 levels) triggers the `hierarchyDepthExceeded` error.

#### Scenario: Cannot create area under AreaD4 (5th level)
- **WHEN** user taps "Create_site_or_area" button
- **AND** user selects "Area" type
- **AND** user enters a name
- **AND** user selects "UAT AreaD4" as parent site
- **AND** user taps "Create"
- **THEN** an alert SHALL appear with message matching "Area_hierarchy_depth_exceeded"

### Requirement: Error when creating area exceeding subsite count limit

The UITest SHALL verify that attempting to create an area under a site that has reached its subsite count limit triggers the `subsiteCountExceeded` error.

#### Scenario: Cannot create area when subsite count exceeded
- **WHEN** user taps "Create_site_or_area" button
- **AND** user selects "Area" type
- **AND** user enters a name
- **AND** user selects a site that has reached maximum subsite count as parent
- **AND** user taps "Create"
- **THEN** an alert SHALL appear with message matching "Area_count_exceeded"
