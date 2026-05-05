## NEW Capability: site-selection-page

Standalone site picker page for the Add Device flow, replacing the previous reuse of MoveToSiteView with `source: .add`.

### Requirement: SiteSelectionView presented via NavigationLink push
SiteSelectionView SHALL be presented as a pushed view from AddDeviceByMacView and AddVSSView, replacing the previous MoveToSiteView NavigationLink.

#### Scenario: Navigation from AddDeviceByMacView
- **WHEN** user taps the Site field in AddDeviceByMacView
- **THEN** SiteSelectionView SHALL be pushed onto the navigation stack
- **AND** the view SHALL receive a `Binding<DeviceItem>` for the adding device

#### Scenario: Navigation from AddVSSView
- **WHEN** user taps the Site field in AddVSSView
- **THEN** SiteSelectionView SHALL be pushed onto the navigation stack
- **AND** the view SHALL receive a `Binding<DeviceItem>` for the adding device

### Requirement: Navigation title and toolbar
SiteSelectionView SHALL display "Site" as the navigation title with Cancel and Save toolbar buttons.

#### Scenario: Navigation title
- **WHEN** SiteSelectionView is displayed
- **THEN** the navigation title SHALL be "Site"

#### Scenario: Cancel button
- **WHEN** user taps Cancel (leading toolbar)
- **THEN** the view SHALL pop back without applying any selection change to the device binding

#### Scenario: Save button enabled state
- **WHEN** a site is selected
- **THEN** the Save button (trailing toolbar) SHALL be enabled

#### Scenario: Save button disabled state
- **WHEN** no site is selected
- **THEN** the Save button SHALL be disabled

#### Scenario: Save confirms selection
- **WHEN** user taps Save with a site selected
- **THEN** the selected site's ID SHALL be applied to `device.siteID` via the binding
- **AND** the view SHALL pop back to the AddDevice screen

### Requirement: Search bar
SiteSelectionView SHALL include a search bar for filtering sites.

#### Scenario: Search bar displayed
- **WHEN** SiteSelectionView is displayed
- **THEN** a search bar with placeholder "Search sites" SHALL be shown below the navigation bar

#### Scenario: Search filters tree
- **WHEN** user types a keyword
- **THEN** the site tree SHALL filter to show only matching sites/areas and their ancestors
- **AND** matching text SHALL be highlighted in the site names

#### Scenario: Search cleared
- **WHEN** user clears the search keyword
- **THEN** the full site tree SHALL be restored

### Requirement: Create site or area
SiteSelectionView SHALL provide a "Create site or area" entry point when the user has permission.

#### Scenario: Create button visible
- **WHEN** `canCreateSite()` returns true
- **THEN** a "Create site or area" tappable text SHALL be displayed above the tree list

#### Scenario: Create button hidden
- **WHEN** `canCreateSite()` returns false
- **THEN** the "Create site or area" text SHALL NOT be displayed

#### Scenario: Create navigates to SiteInformationView
- **WHEN** user taps "Create site or area"
- **THEN** SiteInformationView SHALL be pushed with `site: nil` (create mode)

### Requirement: Site tree list with single-select checkmark
SiteSelectionView SHALL display the hierarchical site/area tree with single-selection checkmark indicator.

#### Scenario: Tree display
- **WHEN** sites exist
- **THEN** the tree SHALL be rendered using SearchableTreeView with SiteTreeRow in always-expanded mode (nil expandedState)
- **AND** depth 0 rows SHALL show site pin icon + name
- **AND** depth > 0 rows SHALL show "└" prefix + name with indentation

#### Scenario: Selection checkmark
- **WHEN** user taps a site/area row
- **THEN** that row SHALL show a trailing checkmark
- **AND** any previously selected row SHALL lose its checkmark
- **AND** the selection SHALL be local state (not applied to binding until Save)

#### Scenario: No "Current" badge
- **WHEN** the tree renders
- **THEN** no row SHALL display a "Current" label (this is a new device with no existing site)

#### Scenario: No "Move device" bottom button
- **WHEN** SiteSelectionView is displayed
- **THEN** there SHALL be no bottom-fixed action button

#### Scenario: Dividers between site groups
- **WHEN** the tree renders
- **THEN** depth 0 rows (except the first) SHALL have a divider separator above them

### Requirement: Empty state
SiteSelectionView SHALL display an empty state when no sites exist.

#### Scenario: No sites exist
- **WHEN** `deviceManager.sites` is empty
- **THEN** an empty state illustration SHALL be displayed with a message prompting the user to create a site

### Requirement: Context menu for site management
SiteSelectionView SHALL support context menu actions on site rows for editing and deleting.

#### Scenario: Edit site via context menu
- **WHEN** user long-presses a site row
- **AND** `canEditSite()` returns true
- **THEN** a "Site information" option SHALL be available
- **AND** tapping it SHALL navigate to SiteInformationView with that site

#### Scenario: Delete site via context menu
- **WHEN** user long-presses a site row
- **AND** `canDelete(for: site)` returns true
- **THEN** a "Delete" option SHALL be available
- **AND** tapping it SHALL open a delete confirmation dialog

#### Scenario: Deleted site clears selection
- **WHEN** the currently selected site is deleted
- **THEN** the selection SHALL be cleared
- **AND** the Save button SHALL become disabled

### Requirement: Pre-selection of existing site
SiteSelectionView SHALL pre-select the device's current siteID if one exists (e.g., user returns to edit their previous selection).

#### Scenario: Device already has a siteID
- **WHEN** SiteSelectionView opens with a device that has a non-empty siteID
- **THEN** the corresponding site row SHALL show a checkmark
- **AND** the Save button SHALL be enabled
