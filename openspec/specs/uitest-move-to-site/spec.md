## ADDED Requirements

### Requirement: MoveToSite happy path moves device to selected site

The UITest SHALL verify that a device can be moved from Organization Site to a target site using the redesigned MoveToSite flow (tree view selection → Move_device button → confirmation).

#### Scenario: Move device to SiteC successfully
- **WHEN** user opens device more menu and taps "Move to"
- **AND** MoveToSiteView appears with tree view of sites
- **AND** user taps "UAT SiteC" in the tree
- **AND** user taps "Move_device" button
- **AND** user confirms in DeleteConfirmation sheet by tapping "Move_Device"
- **THEN** the device SHALL appear under UAT SiteC in View Tab
- **AND** tearDown SHALL call `moveAllDevicesToOrganizationSite` to restore state

### Requirement: Delete site with devices shows error

The UITest SHALL verify that attempting to delete a site that contains devices triggers the `siteHasDevices` error alert.

#### Scenario: Cannot delete site that has devices
- **WHEN** a device has been moved to UAT SiteA (or SiteA already has a device)
- **AND** user long-presses UAT SiteA in MoveToSiteView to open context menu
- **AND** user taps "Delete"
- **AND** user types "DELETE" and confirms
- **THEN** an alert SHALL appear with message matching "Cannot_delete_site_has_devices"

### Requirement: CommonOperation.move helper matches new MoveToSite UI

The `CommonOperation.move(device:toGroup:)` helper SHALL be updated to use the new flow:
1. Tap device more button
2. Tap "Move to" menu item
3. Wait for MoveToSiteView navigation bar
4. Tap target site name in tree view
5. Tap "Move_device" button
6. Confirm move in DeleteConfirmation sheet

#### Scenario: CommonOperation move helper executes new flow
- **WHEN** `move(device:toGroup:)` is called with a device name and site name
- **THEN** it SHALL navigate through MoveToSite tree → tap site → tap Move_device → confirm
- **AND** the device SHALL no longer appear under the original site

### Requirement: ViewTabExpandCollapseUITest uses displayName identifiers

The `ViewTabExpandCollapseUITest` SHALL use `site.displayName` for `siteToggle_` button identifiers, matching the updated SiteView implementation.

#### Scenario: Site toggle identifiers match displayName format
- **WHEN** the test looks for site toggle buttons
- **THEN** it SHALL use identifiers in the format `siteToggle_<displayName>` where displayName is the path-joined name (e.g., "UAT SiteB > UAT AreaB1")
