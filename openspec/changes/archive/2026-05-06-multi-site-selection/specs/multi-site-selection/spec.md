## ADDED Requirements

### Requirement: Multi-select mode for SiteSelectionView
SiteSelectionView SHALL support a `.multi` mode that allows the user to select multiple sites/areas with checkboxes, displaying a count of selected items and providing select all / deselect all functionality.

#### Scenario: Multi mode renders checkbox on every row
- **WHEN** SiteSelectionView is opened in multi mode
- **THEN** each site/area row SHALL display a checkbox icon (checked or unchecked circle) on the trailing side
- **AND** the checkbox SHALL always be visible regardless of selection state

#### Scenario: Tapping row toggles selection
- **WHEN** user taps a site/area row in multi mode
- **AND** the site is not currently selected
- **THEN** the site SHALL be added to the selected set
- **AND** the checkbox SHALL change to checked state

#### Scenario: Tapping selected row deselects it
- **WHEN** user taps a site/area row in multi mode
- **AND** the site is currently selected
- **THEN** the site SHALL be removed from the selected set
- **AND** the checkbox SHALL change to unchecked state

### Requirement: Control bar displays selection count and toggle
In multi mode, SiteSelectionView SHALL display a control bar showing the number of selected items and a button to select all or deselect all.

#### Scenario: Count display with selections
- **WHEN** SiteSelectionView is in multi mode
- **AND** N sites are selected out of M total
- **THEN** the control bar SHALL display "{N}/{M} selected" text

#### Scenario: Count display with no selections
- **WHEN** SiteSelectionView is in multi mode
- **AND** no sites are selected
- **THEN** the control bar SHALL display "No items selected yet" text

#### Scenario: Deselect all button when all selected
- **WHEN** all sites are selected (N == M)
- **THEN** the toggle button SHALL display "Deselect all"
- **AND** tapping it SHALL clear all selections

#### Scenario: Select all button when not all selected
- **WHEN** not all sites are selected (N < M)
- **THEN** the toggle button SHALL display "Select all"
- **AND** tapping it SHALL select all sites

### Requirement: Multi mode Save behavior
In multi mode, the Save button SHALL apply the selected sites to the binding and dismiss the view.

#### Scenario: Save applies selected sites
- **WHEN** user taps Save in multi mode
- **THEN** the selected `[SiteItem]` array SHALL be written to the binding
- **AND** the view SHALL dismiss

#### Scenario: Save disabled when empty selection not allowed
- **WHEN** SiteSelectionView is in multi mode with `allowEmptySelection: false`
- **AND** no sites are selected
- **THEN** the Save button SHALL be disabled

#### Scenario: Save enabled when empty selection allowed
- **WHEN** SiteSelectionView is in multi mode with `allowEmptySelection: true`
- **AND** no sites are selected
- **THEN** the Save button SHALL be enabled

#### Scenario: Cancel discards changes
- **WHEN** user taps Cancel in multi mode
- **THEN** the binding SHALL remain unchanged
- **AND** the view SHALL dismiss

### Requirement: Multi mode initializes from existing selection
SiteSelectionView in multi mode SHALL initialize its selection state from the provided binding value.

#### Scenario: Pre-selected sites shown as checked on open
- **WHEN** SiteSelectionView opens in multi mode
- **AND** the binding contains previously selected sites
- **THEN** those sites SHALL appear with checked checkboxes
- **AND** the count SHALL reflect the pre-selected count

### Requirement: Multi mode tree rendering with search
Multi mode SHALL use the same tree structure rendering and search filtering as single mode.

#### Scenario: Tree hierarchy displayed
- **WHEN** SiteSelectionView is in multi mode
- **THEN** sites SHALL be displayed at depth 0 with site icon
- **AND** areas SHALL be displayed at their hierarchy depth with `└` connector
- **AND** dividers SHALL separate top-level site groups

#### Scenario: Search filters tree preserving ancestors
- **WHEN** user types a keyword in the search bar
- **THEN** only matching sites/areas and their ancestors SHALL be displayed
- **AND** matched text SHALL be highlighted with blue background
- **AND** checkboxes SHALL remain functional on filtered results

#### Scenario: Search does not affect selection state
- **WHEN** user searches and the tree is filtered
- **THEN** previously selected sites that are not visible SHALL remain selected
- **AND** clearing the search SHALL restore the full tree with all selections intact

### Requirement: Multi mode has no site management features
In multi mode, SiteSelectionView SHALL NOT display site management features (create site, context menu, site information, delete).

#### Scenario: No create site button
- **WHEN** SiteSelectionView is in multi mode
- **THEN** the "Create site or area" button SHALL NOT be displayed

#### Scenario: No context menu
- **WHEN** user long-presses a site row in multi mode
- **THEN** no context menu SHALL appear

### Requirement: SiteCheckboxTreeRow component
A new `SiteCheckboxTreeRow` component SHALL render site/area rows with checkbox indicators, sharing the same tree layout structure as `SiteTreeRow`.

#### Scenario: Depth 0 row renders site icon and checkbox
- **WHEN** a site at depth 0 is rendered in `SiteCheckboxTreeRow`
- **THEN** the row SHALL display the site pin icon (24x24) on the leading side
- **AND** the site name (with optional keyword highlight)
- **AND** a checkbox icon (24x24) on the trailing side within a 44x44 tap area

#### Scenario: Child row renders connector and checkbox
- **WHEN** an area at depth > 0 is rendered in `SiteCheckboxTreeRow`
- **THEN** the row SHALL display `└` connector text
- **AND** the area name (with optional keyword highlight)
- **AND** a checkbox icon on the trailing side
- **AND** leading padding SHALL match `SiteTreeRow` depth indentation logic
