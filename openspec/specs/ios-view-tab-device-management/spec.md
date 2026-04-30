# ios-view-tab-device-management Specification

## Purpose
TBD - created by archiving change sync-expand-toggle-icon-with-site-states. Update Purpose after archive.
## Requirements
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

---

### Requirement: Control Panel Site Count Display

The control panel SHALL display the total site count (including subsites) with correct singular/plural form. The count includes all sites regardless of hierarchy depth.

#### Scenario: Singular display

- **GIVEN** organization has 1 site (theoretically control panel won't show, but logic should be correct)
- **WHEN** rendering site count text
- **THEN** display "1 site"

#### Scenario: Plural display with subsites

- **GIVEN** organization has 2 top-level sites and 3 subsites (5 total)
- **WHEN** rendering site count text
- **THEN** display "5 sites"
- **AND** use `.textStyle(.callout.color05)` style

---

### Requirement: Expand/Collapse Toggle Button Icon

The toggle button icon SHALL dynamically reflect the actual expanded state of all site groups, derived from `ExpandedState`.

#### Scenario: All sites expanded

- **GIVEN** all site groups are in expanded state (all site IDs present in `expandedState.ids`)
- **WHEN** rendering toggle button
- **THEN** display `iconGeneralCollapseAllSolid` (double arrow up)

#### Scenario: All sites collapsed

- **GIVEN** all site groups are in collapsed state (`expandedState.ids` contains no site IDs)
- **WHEN** rendering toggle button
- **THEN** display `iconGeneralExpandAllSolid` (double arrow down)

#### Scenario: Mixed state

- **GIVEN** some sites expanded, some sites collapsed (mixed state)
- **WHEN** rendering toggle button
- **THEN** button icon remains unchanged (based on `allSiteExpanded` state)

#### Scenario: User manually changes individual site state

- **GIVEN** user is on View Tab
- **WHEN** user manually expands or collapses a site via the site header arrow button
- **AND** this action causes all sites to reach uniform state (all expanded or all collapsed)
- **THEN** button icon updates immediately to reflect new state

---

### Requirement: Toggle Button Tap Behavior

The toggle button SHALL expand or collapse all site groups when tapped, by operating on `ExpandedState`.

#### Scenario: Tap to expand all

- **GIVEN** button displays `iconGeneralExpandAllSolid` (all collapsed state)
- **WHEN** user taps button
- **THEN** all site groups expand via `expandedState.expandAll(allSiteIDs)`
- **AND** `allSiteExpanded` is set to `true`
- **AND** button icon changes to `iconGeneralCollapseAllSolid`

#### Scenario: Tap to collapse all

- **GIVEN** button displays `iconGeneralCollapseAllSolid` (all expanded state)
- **WHEN** user taps button
- **THEN** all site groups collapse via `expandedState.collapseAll()`
- **AND** `allSiteExpanded` is set to `false`
- **AND** button icon changes to `iconGeneralExpandAllSolid`

---

### Requirement: Toggle Button Style

The toggle button SHALL use `RoundedIconSmallSecondaryButtonStyle`.

#### Scenario: Button visual style

- **GIVEN** control panel displays toggle button
- **WHEN** rendering button
- **THEN** use `.buttonStyle(.roundedIconSmallSecondary)`
- **AND** icon size is 24x24pt
- **AND** button padding is 10pt
- **AND** corner radius is 4pt
- **AND** background color is `.colorSurface03`

---

### Requirement: Toggle Button Accessibility Identifier

The toggle button SHALL have an accessibility identifier for UI testing.

#### Scenario: Accessibility identifier

- **GIVEN** control panel displays toggle button
- **WHEN** UI test or accessibility tool queries button
- **THEN** button has `.accessibilityIdentifier("expandCollapseAllButton")`

