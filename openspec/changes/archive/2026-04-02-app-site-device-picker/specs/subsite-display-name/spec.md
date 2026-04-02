## MODIFIED Requirements

### Requirement: View Tab Site Row Display

The View tab `SiteRow` SHALL use `compactName` for display text instead of `name`. Additionally, all device picker site group headers across the App SHALL use `compactName` for display text.

#### Scenario: Subsite in View tab section header

- **GIVEN** a subsite with long full path name
- **WHEN** rendering in View tab site row (single-line, width-constrained)
- **THEN** the displayed text SHALL be `compactName`
- **AND** the row layout and truncation behavior SHALL remain unchanged (tail truncation)

#### Scenario: Subsite in device picker group header

- **GIVEN** a subsite with long full path name
- **WHEN** rendering as a group header in any device picker (DeviceFilter, CustomizedViewEditorAddCamerasView, DevicePickerView)
- **THEN** the displayed text SHALL be `compactName`
- **AND** the group header layout and truncation behavior SHALL remain unchanged (tail truncation)
