## MODIFIED Requirements

### Requirement: Toggle Button Tap Behavior

The toggle button SHALL expand or collapse all site groups when tapped, by recomputing the flat grid array.

#### Scenario: Tap to expand all

- **GIVEN** button displays `iconGeneralExpandAllSolid` (all collapsed state)
- **WHEN** user taps button
- **THEN** all site groups expand via flat array recomputation (no per-site binding mutation)
- **AND** `allSiteExpanded` is set to `true`
- **AND** button icon changes to `iconGeneralCollapseAllSolid`

#### Scenario: Tap to collapse all

- **GIVEN** button displays `iconGeneralCollapseAllSolid` (all expanded state)
- **WHEN** user taps button
- **THEN** all site groups collapse via flat array recomputation
- **AND** `allSiteExpanded` is set to `false`
- **AND** button icon changes to `iconGeneralExpandAllSolid`
