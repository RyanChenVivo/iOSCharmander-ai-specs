## MODIFIED Requirements

### Requirement: Alert-based move device confirmation
When a user taps the "Move device" bottom button in MoveToSiteView, the system SHALL present a system Alert dialog for confirmation instead of a full-page confirmation view.

#### Scenario: Alert presented after tapping Move device button
- **WHEN** user taps the "Move device" bottom button in MoveToSiteView
- **THEN** the system SHALL present an Alert via `alertControl.showAlert(item: .checkToMoveDevice(to:action:))`
- **AND** the Alert SHALL display the destination site name
- **AND** the system SHALL NOT use a full-page `MoveDeviceConfirmationView`

#### Scenario: Confirm move executes device move
- **WHEN** user taps "Move" on the Alert
- **THEN** the system SHALL call `deviceManager.updateDevice(device, siteID: site.id)`
- **AND** on success, dismiss all presented sheets via `sheetManager.dismissAll()`

#### Scenario: Cancel returns to site picker
- **WHEN** user taps "Cancel" on the Alert
- **THEN** the Alert SHALL dismiss
- **AND** the user SHALL remain on MoveToSiteView with the previous selection preserved
- **AND** no API call SHALL be made

#### Scenario: Move failure shows error
- **WHEN** the move API call fails
- **THEN** the system SHALL display an error via `appManager.handleError(error, defaultAlert: .failToMove())`
- **AND** the MoveToSiteView SHALL remain presented (no dismissAll)
