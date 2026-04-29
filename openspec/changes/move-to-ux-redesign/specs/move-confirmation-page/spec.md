## ADDED Requirements

### Requirement: Full-page move device confirmation
When a user selects a destination site in the Move flow, MoveToSiteView SHALL present a full-page confirmation view instead of a system alert dialog.

#### Scenario: Confirmation view presented after site selection
- **WHEN** user taps the "Move device" bottom button in MoveToSiteView (Move flow)
- **THEN** the system SHALL present `MoveDeviceConfirmationView` as a sheet
- **AND** the system SHALL NOT use `AlertItem.checkToMoveDevice` alert

#### Scenario: Confirmation view layout
- **WHEN** `MoveDeviceConfirmationView` is presented
- **THEN** it SHALL display a centered warning icon (triangle exclamation, orange)
- **AND** a title "Move this device"
- **AND** a subtitle 'The device will be moved to "{site name}".'
- **AND** an orange "ATTENTION!" label
- **AND** an info card with text: "Moving device may change their permissions. Some functions may become unavailable."
- **AND** a blue full-width "Move Device" button at the bottom
- **AND** a "Cancel" text button below the Move Device button

#### Scenario: Confirm move executes device move
- **WHEN** user taps the "Move Device" button on the confirmation view
- **THEN** the system SHALL call `deviceManager.updateDevice(device, siteID: site.id)`
- **AND** on success, dismiss all presented sheets back to the originating view

#### Scenario: Cancel returns to site picker
- **WHEN** user taps "Cancel" on the confirmation view
- **THEN** the confirmation view SHALL dismiss
- **AND** the user SHALL return to MoveToSiteView with the previous selection preserved

#### Scenario: Move failure shows error
- **WHEN** the move API call fails
- **THEN** the system SHALL display an error alert on the confirmation view
- **AND** the confirmation view SHALL remain presented
