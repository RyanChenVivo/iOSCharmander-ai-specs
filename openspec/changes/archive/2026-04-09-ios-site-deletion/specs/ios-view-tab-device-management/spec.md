## MODIFIED Requirements

### Requirement: View Tab Control Panel Display Condition

The View Tab SHALL display a control panel above the site list only when there are 2 or more sites.

#### Scenario: Hide control panel when 0 or 1 site

- **GIVEN** organization has 0 or 1 site
- **WHEN** user browses View Tab
- **THEN** control panel is not displayed
- **AND** site list displays normally

#### Scenario: Show control panel when 2 or more sites

- **GIVEN** organization has 2 or more sites
- **WHEN** user browses View Tab
- **THEN** control panel displays above site list
- **AND** control panel height is 44pt

#### Scenario: Site list refreshes after site deletion

- **WHEN** a site is successfully deleted from MoveToSiteView
- **AND** `DeviceManager.sites` updates via `@Published`
- **THEN** the View Tab site list SHALL reactively update to reflect the removal
