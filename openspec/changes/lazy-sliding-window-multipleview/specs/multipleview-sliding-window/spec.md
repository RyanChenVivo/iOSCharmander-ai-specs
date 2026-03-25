## ADDED Requirements

### Requirement: Lazy component initialization for site-based MultipleView

The system SHALL initialize only a sliding window of `ViewcellComponent` instances when opening a site-based MultipleView, instead of eagerly creating components for all devices in the site.

#### Scenario: User taps a device in a 5000-device site
- **WHEN** user taps a device in a site containing 5000 devices
- **THEN** MultipleViewModel SHALL create ViewcellComponents only for the current page ±1 page (3 components for 1x1 layout, 12 for 2x2)
- **AND** the streaming view SHALL open in under 2 seconds

#### Scenario: User taps a device in a small site (≤12 devices)
- **WHEN** user taps a device in a site with 12 or fewer devices
- **THEN** the hot range covers all devices and behavior SHALL be identical to eager initialization

### Requirement: Sliding window updates on page change

The system SHALL update the active component window when the user swipes to a different page.

#### Scenario: User swipes to next page
- **WHEN** user swipes from page N to page N+1
- **THEN** the system SHALL inflate components for page N+2 (if not already active)
- **AND** the system SHALL release components for page N-1 (if outside the new hot range)
- **AND** streaming SHALL start on the newly visible page's devices

#### Scenario: User swipes back to previous page
- **WHEN** user swipes from page N to page N-1
- **THEN** the system SHALL inflate components for page N-2 (if not already active)
- **AND** the system SHALL release components for page N+1 (if outside the new hot range)

### Requirement: Sliding window updates on layout change

The system SHALL recalculate the hot range when the layout changes between 1x1, 2x2, and other supported layouts.

#### Scenario: User switches from 1x1 to 2x2
- **WHEN** user changes layout from 1x1 to 2x2
- **THEN** the system SHALL inflate additional components to fill the new hot range (up to 12 components)
- **AND** the currently focused device SHALL remain visible

#### Scenario: User switches from 2x2 to 1x1
- **WHEN** user changes layout from 2x2 to 1x1
- **THEN** the system SHALL release components outside the new hot range (down to 3 components)
- **AND** the currently focused device SHALL remain visible

### Requirement: Component release stops streaming and cancels tasks

The system SHALL properly clean up resources when releasing a component from the active window.

#### Scenario: Component is released from hot range
- **WHEN** a ViewcellComponent is evicted from the hot range
- **THEN** the system SHALL cancel its observe tasks (viewcellControl states and timeline states)
- **AND** the system SHALL stop its streaming connection
- **AND** the system SHALL remove it from the active components dictionary

### Requirement: Non-inflated cells show placeholder

The system SHALL display a placeholder for grid cells whose components are not yet inflated.

#### Scenario: Grid renders a cell outside the hot range
- **WHEN** MultipleViewGridItem requests a ViewcellControl for an index outside the active window
- **THEN** the system SHALL return nil
- **AND** the view SHALL display the ProductLogo placeholder

### Requirement: Device and CustomizedView cases are unaffected

The `.device` and `.customizedView` init cases SHALL continue to use eager initialization since they have small bounded component counts.

#### Scenario: User opens a single device view
- **WHEN** MultipleViewModel is initialized with a `.device` item
- **THEN** exactly 1 ViewcellComponent SHALL be created eagerly

#### Scenario: User opens a customized view
- **WHEN** MultipleViewModel is initialized with a `.customizedView` item
- **THEN** all ViewcellComponents SHALL be created eagerly for every cell in the customized view
