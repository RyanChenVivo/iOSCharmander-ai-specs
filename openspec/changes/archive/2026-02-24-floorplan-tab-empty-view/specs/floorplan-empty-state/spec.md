# Floor Plan Empty State Specification

## ADDED Requirements

### Requirement: Display empty state when no floor plans exist
The Floor Plan Tab SHALL display a centered empty state view when no floor plan data is available and loading has completed.

#### Scenario: Empty state displayed on first load with no data
- **WHEN** user navigates to Floor Plan Tab
- **AND** loading completes
- **AND** no floor plans exist in the system
- **THEN** empty state view SHALL be displayed in the center of the screen

#### Scenario: Empty state displayed after data deletion
- **WHEN** user had floor plans previously
- **AND** all floor plans are deleted
- **AND** user views Floor Plan Tab
- **THEN** empty state view SHALL be displayed in the center of the screen

#### Scenario: Empty state NOT displayed during loading
- **WHEN** Floor Plan Tab is loading data
- **THEN** empty state view SHALL NOT be displayed
- **AND** loading indicator SHALL be shown instead

#### Scenario: Empty state NOT displayed when data exists
- **WHEN** at least one floor plan exists
- **THEN** empty state view SHALL NOT be displayed
- **AND** floor plan list SHALL be shown instead

### Requirement: Empty state visual design
The empty state view SHALL display an icon and localized text message centered vertically and horizontally on the screen.

#### Scenario: Icon displayed correctly
- **WHEN** empty state is shown
- **THEN** icon image SHALL be `.iconGeneralFloorPlanSolid`
- **AND** icon SHALL be 100x100 points in size

#### Scenario: Text displayed correctly
- **WHEN** empty state is shown
- **THEN** text SHALL display the localized string "No_floor_plans"
- **AND** text SHALL use `.title2Bold` text style
- **AND** text SHALL have 8 points of padding above it

#### Scenario: Layout centered on screen
- **WHEN** empty state is shown
- **THEN** content SHALL be vertically centered using spacers
- **AND** content SHALL be horizontally centered

### Requirement: Empty state localization
The empty state message SHALL be displayed in the user's selected language.

#### Scenario: English localization
- **WHEN** user's language is English
- **AND** empty state is displayed
- **THEN** message SHALL show "No floor plans"

#### Scenario: Traditional Chinese localization
- **WHEN** user's language is Traditional Chinese
- **AND** empty state is displayed
- **THEN** message SHALL show "沒有平面圖"

#### Scenario: Japanese localization
- **WHEN** user's language is Japanese
- **AND** empty state is displayed
- **THEN** message SHALL show "フロアプランがありません"

### Requirement: Empty state interaction
The empty state view SHALL allow pull-to-refresh interaction to reload data.

#### Scenario: Pull-to-refresh available in empty state
- **WHEN** empty state is displayed
- **AND** user performs pull-to-refresh gesture
- **THEN** system SHALL fetch floor plans from server
- **AND** loading indicator SHALL be displayed during fetch

#### Scenario: Empty state replaced by content after refresh
- **WHEN** empty state is displayed
- **AND** user pulls to refresh
- **AND** server returns floor plan data
- **THEN** empty state SHALL be replaced by floor plan list

#### Scenario: Empty state persists if still no data after refresh
- **WHEN** empty state is displayed
- **AND** user pulls to refresh
- **AND** server returns no floor plan data
- **THEN** empty state SHALL remain displayed

### Requirement: Empty state does NOT include refresh button
The empty state view SHALL NOT display a dedicated refresh button.

#### Scenario: No refresh button in empty state
- **WHEN** empty state is displayed
- **THEN** no refresh button SHALL be visible in the empty state view
- **AND** pull-to-refresh gesture SHALL be the only refresh mechanism
