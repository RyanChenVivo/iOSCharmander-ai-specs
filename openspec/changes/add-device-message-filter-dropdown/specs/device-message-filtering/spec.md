## ADDED Requirements

### Requirement: Filter Chips Display

The Device Message tab SHALL display a horizontal scrollable row of filter chips below the navigation bar. Each chip represents a filter dimension: Event Type, Devices, and Time Frame.

#### Scenario: Chips row displays all filter types

- **WHEN** the Device Message tab is displayed
- **THEN** a horizontal scrollable row shows three filter chips: "Event Type", "Devices", "Time Frame"
- **AND** chips are left-aligned with 8pt spacing between them
- **AND** the row has 16pt horizontal padding

#### Scenario: Chip shows selection count

- **WHEN** a filter has active selections
- **THEN** the chip displays the filter name followed by the count in parentheses (e.g., "Event Type (3)")
- **AND** the chip border color changes to primary color

#### Scenario: Active chip visual state

- **WHEN** a chip's dropdown is expanded
- **THEN** the chip displays with larger size (16pt text, 16pt horizontal padding, 10pt vertical padding)
- **AND** the chip background changes to surface17
- **AND** the chip border is primary color with 1.5pt width
- **AND** the chevron icon rotates 180 degrees (pointing up)
- **AND** the transition animates with 0.15s easeInOut

---

### Requirement: Filter Dropdown Expansion

The system SHALL expand a dropdown panel below the filter chips row when a chip is tapped, displaying filter options specific to that filter type.

#### Scenario: Opening a dropdown

- **WHEN** user taps a filter chip
- **THEN** a dropdown panel expands below the chips row
- **AND** the dropdown appears with opacity fade animation (0.2s easeInOut)
- **AND** a dimmed overlay (black 50%) covers the message list below
- **AND** only one dropdown can be open at a time

#### Scenario: Dropdown height constraint

- **WHEN** dropdown content exceeds available space
- **THEN** the dropdown height is limited to 3/4 of the content area
- **AND** the dropdown content becomes scrollable

#### Scenario: Switching between dropdowns

- **WHEN** user taps a different chip while a dropdown is open
- **THEN** the current dropdown closes (discarding uncommitted changes)
- **AND** the new dropdown opens

---

### Requirement: Temp State Pattern

The system SHALL use a temporary state pattern where filter changes are not applied until explicitly confirmed.

#### Scenario: Opening dropdown initializes temp state

- **WHEN** user opens a filter dropdown
- **THEN** the current filter selections are copied to temporary state
- **AND** all user interactions modify the temporary state only

#### Scenario: Confirming applies changes

- **WHEN** user taps the "Confirm" button
- **THEN** the temporary state is applied to the real filter state
- **AND** the dropdown closes
- **AND** the message list refreshes with new filter criteria
- **AND** the chip count updates to reflect new selections

#### Scenario: Clearing resets temp state

- **WHEN** user taps the "Clear" button
- **THEN** the temporary state selections are cleared (all unselected)
- **AND** the dropdown remains open

#### Scenario: Closing without confirm discards changes

- **WHEN** user closes the dropdown by tapping the overlay, same chip, or different chip
- **THEN** the temporary state is discarded
- **AND** the original filter selections remain unchanged

---

### Requirement: Event Type Filter Content

The Event Type filter dropdown SHALL display an icon list style with search capability and multi-select checkboxes.

#### Scenario: Search filters event types

- **WHEN** user enters text in the search field
- **THEN** the list filters to show only event types matching the search text
- **AND** matching is case-insensitive on event type name

#### Scenario: Select all functionality

- **WHEN** user taps "Select all" button
- **THEN** all visible event types are selected
- **AND** the count updates to show "{selected} / {total} selected"

#### Scenario: Event type list item display

- **WHEN** event types are displayed
- **THEN** each item shows an icon (40x40pt with primary background), title, and subtitle
- **AND** a circular checkbox (24pt) indicates selection state
- **AND** selected items show checkmark.circle.fill in primary color

---

### Requirement: Devices Filter Content

The Devices filter dropdown SHALL display a grouped list style with expandable device groups, thumbnails, and recording indicators.

#### Scenario: Device groups display

- **WHEN** devices dropdown is opened
- **THEN** devices are organized into groups (e.g., "Ungrouped Cameras", site-based groups)
- **AND** each group header shows a folder icon, group name, and device count
- **AND** groups can be expanded/collapsed by tapping the chevron icon

#### Scenario: Group checkbox states

- **WHEN** some devices in a group are selected
- **THEN** the group checkbox shows partial state (primary fill with horizontal line)
- **WHEN** all devices in a group are selected
- **THEN** the group checkbox shows fully selected state (primary fill with checkmark)
- **WHEN** no devices in a group are selected
- **THEN** the group checkbox shows unselected state (outline only)

#### Scenario: Device item display

- **WHEN** a device group is expanded
- **THEN** each device shows with 50pt left indent
- **AND** displays a thumbnail (56x40pt), device name, and checkbox
- **AND** shows a red recording indicator (8pt circle) if device is recording

---

### Requirement: Time Frame Filter Content

The Time Frame filter dropdown SHALL display date selection options using the existing DateFilterView component.

#### Scenario: All time option

- **WHEN** user selects "All time" option
- **THEN** no date filter is applied to message queries
- **AND** the Time Frame chip shows no count indicator

#### Scenario: Custom date range

- **WHEN** user selects "Custom" option
- **THEN** start and end date pickers are displayed
- **AND** user can select a custom date range
- **AND** the Time Frame chip shows "(1)" to indicate a custom range is set

---

### Requirement: Action Buttons

The filter dropdown SHALL display Clear and Confirm action buttons at the bottom.

#### Scenario: Button layout and styling

- **WHEN** dropdown is displayed
- **THEN** two buttons are shown side by side with 12pt gap
- **AND** Clear button uses ghost style (outline, primary border and text)
- **AND** Confirm button uses primary style (filled primary background, inverted text)
- **AND** both buttons are 50pt height with 8pt corner radius
- **AND** buttons container has 16pt padding
