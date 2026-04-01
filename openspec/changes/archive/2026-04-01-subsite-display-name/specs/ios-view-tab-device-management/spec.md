## MODIFIED Requirements

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
