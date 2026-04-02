## ADDED Requirements

### Requirement: Site-only grouping for all device pickers

All device pickers in the App SHALL group devices exclusively by their assigned Site/Subsite. Device-type-based grouping (e.g., separate NVR, VSS, Bridge sections) SHALL NOT be used as a top-level grouping strategy.

#### Scenario: DevicePickerView displays devices under sites

- **WHEN** user opens the DevicePickerView (Help & Feedback)
- **THEN** all devices (NVR, VSS, Bridge, Camera, NVR Channel, VSS Channel) SHALL be displayed under their assigned Site using `compactName` as the group header
- **AND** there SHALL be no separate NvrGroupView, VssGroupView, or BridgeGroupView sections

#### Scenario: DevicePickerView search mode

- **WHEN** user searches for a device in DevicePickerView
- **THEN** matching devices SHALL be displayed as a flat filtered list
- **AND** devices SHALL NOT be separated into device-type groups during search

#### Scenario: DevicePickerView single-selection behavior preserved

- **WHEN** user taps a device in DevicePickerView
- **THEN** the device SHALL be selected and the picker SHALL dismiss
- **AND** the single-selection behavior SHALL be unchanged from current implementation

#### Scenario: NVR appears under its assigned site

- **GIVEN** an NVR device assigned to "Main Office > Server Room"
- **WHEN** DevicePickerView displays the device list
- **THEN** the NVR SHALL appear under the "Main Office > Server Room" site group

#### Scenario: Bridge appears under its assigned site

- **GIVEN** a Bridge device assigned to "Taipei Office"
- **WHEN** DevicePickerView displays the device list
- **THEN** the Bridge SHALL appear under the "Taipei Office" site group

---

### Requirement: compactName display in all device picker group headers

All device pickers that display site group headers SHALL use `SiteItem.compactName` instead of `SiteItem.name` for the displayed text.

#### Scenario: DeviceFilter group header uses compactName

- **WHEN** DeviceFilter renders a site group header
- **THEN** the displayed text SHALL be `site.compactName`
- **AND** the site icon, text style (`.title3Semibold`), and `lineLimit(1)` SHALL remain unchanged

#### Scenario: CustomizedViewEditorAddCamerasView group header uses compactName

- **WHEN** CustomizedViewEditorAddCamerasView renders a site group row
- **THEN** the displayed text SHALL be `site.compactName`
- **AND** the site icon, text style, and layout SHALL remain unchanged

#### Scenario: DevicePickerView group header uses compactName

- **WHEN** the restructured DevicePickerView renders a site group header
- **THEN** the displayed text SHALL be `site.compactName`

#### Scenario: Search still matches full path name

- **GIVEN** a subsite with `name` "Taipei Office > 3F" and `compactName` "Taip… > 3F"
- **WHEN** user searches for "Taipei" in any device picker
- **THEN** the subsite group SHALL appear in search results
- **AND** search SHALL match against `SiteItem.name` (full path), not `compactName`

#### Scenario: Sort order unchanged

- **GIVEN** device pickers display site groups
- **WHEN** sorting the site group list
- **THEN** sort order SHALL be based on `SiteItem.name` (full path) alphabetical order
- **AND** sort order SHALL NOT be affected by the switch to `compactName` display
