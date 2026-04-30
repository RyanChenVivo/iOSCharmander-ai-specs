## ADDED Requirements

### Requirement: Flat Grid Rendering for Sites and Devices

The View Tab SHALL render site headers and device cells in a single-layer `LazyVGrid`, without nesting lazy containers.

#### Scenario: Render expanded site with devices

- **WHEN** a site is in expanded state
- **THEN** the flat grid contains one site header item followed by device items for that site
- **AND** all items are rendered within a single `LazyVGrid`

#### Scenario: Render collapsed site

- **WHEN** a site is in collapsed state
- **THEN** the flat grid contains only the site header item for that site
- **AND** no device items for that site are present in the flat array

#### Scenario: Large dataset rendering

- **GIVEN** organization has 1000 sites with 5000 total devices
- **WHEN** user taps expand all button
- **THEN** all sites expand without crash
- **AND** the grid remains scrollable and responsive

---

### Requirement: Grid Item Type Differentiation

The flat grid SHALL use an enum-based model to differentiate site headers from device cells.

#### Scenario: Site header cell layout

- **WHEN** rendering a site header grid item
- **THEN** the site header SHALL span the full width of the grid (all columns)

#### Scenario: Device cell layout in list mode

- **WHEN** rendering device grid items in list mode
- **THEN** devices SHALL display in a single-column layout

#### Scenario: Device cell layout in grid mode

- **WHEN** rendering device grid items in grid mode
- **THEN** devices SHALL display in a two-column layout

---

### Requirement: Expand/Collapse State via Flat Array Recomputation

The expand/collapse state SHALL be managed by recomputing the flat array, not by per-site bindings.

#### Scenario: Toggle individual site

- **WHEN** user taps a site header's expand/collapse button
- **THEN** the flat array is recomputed to include or exclude that site's device items
- **AND** only the affected items change in the array

#### Scenario: Toggle all sites

- **WHEN** user taps the expand/collapse all button
- **THEN** the flat array is recomputed for all sites in a single update
- **AND** no per-site binding mutations occur
