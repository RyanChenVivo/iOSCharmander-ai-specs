## MODIFIED Requirements

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
