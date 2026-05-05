## MODIFIED Requirements

### Requirement: Site selection uses SiteSelectionView
AddDeviceByMacView and AddVSSView SHALL use the new SiteSelectionView instead of MoveToSiteView for site selection.

#### Scenario: NavigationLink destination changed
- **WHEN** user taps the Site field in AddDeviceByMacView or AddVSSView
- **THEN** the NavigationLink SHALL push `SiteSelectionView(device:)` instead of `MoveToSiteView(device:, source: .add)`

### Requirement: Selection behavior changed to Save-to-confirm
Site selection SHALL no longer immediately dismiss the view. The user must tap Save to confirm.

#### Scenario: Site persists after Save
- **WHEN** user selects a Site in SiteSelectionView
- **AND** taps Save
- **AND** returns to AddDeviceByMacView
- **THEN** the selected Site name SHALL be displayed in the Site field

#### Scenario: Selection discarded on Cancel
- **WHEN** user selects a Site in SiteSelectionView
- **AND** taps Cancel (or navigates back)
- **THEN** the device's siteID SHALL remain unchanged
- **AND** the Site field SHALL display the previous value (or placeholder if none)

### Requirement: Empty state and tree display unchanged
The empty state behavior and tree display requirements from the base spec remain unchanged. SiteSelectionView inherits these behaviors.

### Requirement: Site deletion clears selection
When a selected site is deleted within SiteSelectionView, the selection SHALL be cleared.

#### Scenario: Selected site deleted
- **WHEN** user deletes the currently selected site via context menu
- **THEN** the local selection SHALL be cleared
- **AND** the Save button SHALL become disabled
