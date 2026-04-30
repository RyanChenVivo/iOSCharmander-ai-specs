## ADDED Requirements

### Requirement: ViewTabItem Data Model

The View Tab SHALL use a `ViewTabItem` enum as the unified data model for TreeView rendering, conforming to `Hierarchable`, `Identifiable`, `Equatable`, and `Searchable`.

#### Scenario: Site item parentId

- **WHEN** a `ViewTabItem.site(SiteItem)` is created
- **THEN** its `parentId` SHALL be `nil` (all sites are root-level, flat layout)

#### Scenario: Device item parentId in list mode

- **WHEN** a `ViewTabItem.device(DeviceItem)` is created
- **THEN** its `parentId` SHALL be the device's `siteID`

#### Scenario: DeviceRow item parentId in grid mode

- **WHEN** a `ViewTabItem.deviceRow([DeviceItem])` is created
- **THEN** its `parentId` SHALL be the first device's `siteID`

#### Scenario: Searchable conformance for site

- **WHEN** searching with a keyword
- **THEN** `ViewTabItem.site(s)` SHALL delegate to `s.contains(keyword:)`

#### Scenario: Searchable conformance for device

- **WHEN** searching with a keyword
- **THEN** `ViewTabItem.device(d)` SHALL delegate to `d.contains(keyword:)`

#### Scenario: Searchable conformance for deviceRow

- **WHEN** searching with a keyword
- **THEN** `ViewTabItem.deviceRow(devices)` SHALL return `true` if any device in the array matches

---

### Requirement: Flat List Construction by View Mode

The View Tab SHALL construct the TreeView items array differently based on list/grid mode.

#### Scenario: List mode items

- **WHEN** View Tab is in list mode
- **THEN** each device SHALL be an individual `.device(DeviceItem)` item
- **AND** items order SHALL be: `.site`, followed by `.device` items for that site's devices

#### Scenario: Grid mode items

- **WHEN** View Tab is in grid mode
- **THEN** devices under each site SHALL be grouped into `.deviceRow([DeviceItem])` items, each containing at most 2 devices
- **AND** the last `deviceRow` MAY contain 1 device if the total is odd

#### Scenario: Empty site

- **WHEN** a site has no devices on View Tab
- **THEN** only the `.site` item SHALL be present with no child items

---

### Requirement: TreeView-based Site/Device Rendering

The View Tab SHALL render site headers and device cells using a single `TreeView` (or `SearchableTreeView`) component, without nested lazy containers.

#### Scenario: Site header rendering

- **WHEN** rendering a `.site` item in the TreeView rowContent
- **THEN** it SHALL display the site header with rounded gray background, site icon, and compact site name
- **AND** it SHALL display an expand/collapse arrow button
- **AND** the arrow button SHALL toggle the site's expanded state via `ExpandedState`

#### Scenario: Device rendering in list mode

- **WHEN** rendering a `.device` item in the TreeView rowContent
- **THEN** it SHALL render a single `DeviceView` in list mode layout

#### Scenario: DeviceRow rendering in grid mode

- **WHEN** rendering a `.deviceRow` item in the TreeView rowContent
- **THEN** it SHALL render devices in a horizontal layout (2 columns)
- **AND** if the row contains only 1 device, the second column SHALL be empty space

#### Scenario: Large dataset stability

- **GIVEN** organization has 10,000 sites with 5,000 total devices
- **WHEN** user interacts with expand/collapse
- **THEN** the View Tab SHALL NOT crash
- **AND** the list SHALL remain scrollable

---

### Requirement: Unified Search with SearchableTreeView

The View Tab SHALL use `SearchableTreeView` to handle both searching and non-searching modes in a single view.

#### Scenario: Search by device name

- **WHEN** user searches with a keyword matching a device name
- **THEN** the matching device items SHALL appear in the filtered list
- **AND** the parent site of each matching device SHALL also appear and be expanded

#### Scenario: Search by site name

- **WHEN** user searches with a keyword matching a site name
- **THEN** the matching site item SHALL appear in the filtered list
- **AND** devices under that site SHALL NOT automatically appear (only the site header)

#### Scenario: No results

- **WHEN** user searches with a keyword matching no items
- **THEN** a no-result cover SHALL be displayed

#### Scenario: Search exit restores expand state

- **WHEN** user exits search mode
- **THEN** the expand/collapse state SHALL restore to the state before searching
