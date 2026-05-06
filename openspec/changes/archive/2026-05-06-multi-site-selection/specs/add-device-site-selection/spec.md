## MODIFIED Requirements

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
