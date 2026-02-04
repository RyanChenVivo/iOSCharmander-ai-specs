# UAT MFA Utility Specification

## ADDED Requirements

### Requirement: MFA Utility Button Display
The system SHALL display a MFA utility button (button 18, identifier `mfaUtilityButton`) in the `UATUtilityView` when running in UITest mode (`VortexEnvironment.isUITest == true`).

#### Scenario: Button appears in UITest mode
- **WHEN** the app is running with `VortexEnvironment.isUITest` enabled
- **THEN** the `mfaUtilityButton` with identifier "mfaUtilityButton" SHALL be visible in the UAT utility toolbar

#### Scenario: Button hidden in production mode
- **WHEN** the app is running in production mode (`VortexEnvironment.isUITest == false`)
- **THEN** the `mfaUtilityButton` SHALL NOT be visible

### Requirement: MFA Option Sheet Display
The system SHALL display a bottom sheet with MFA options when the MFA utility button is tapped.

#### Scenario: Sheet opens on button tap
- **WHEN** user taps the `mfaUtilityButton`
- **THEN** a bottom sheet with identifier "MFAOptionSheet" SHALL appear
- **AND** the sheet SHALL contain two options: "Setup MFA" and "Copy TOTP"

#### Scenario: Setup MFA option accessibility
- **WHEN** the MFA option sheet is displayed
- **THEN** the "Setup MFA" button SHALL have accessibility identifier "setupMFAOption"

#### Scenario: Copy TOTP option accessibility
- **WHEN** the MFA option sheet is displayed
- **THEN** the "Copy TOTP" button SHALL have accessibility identifier "copyTOTPOption"

### Requirement: Complete MFA Setup
The system SHALL complete the entire MFA setup flow when "Setup MFA" option is selected.

#### Scenario: Successful MFA setup
- **WHEN** user taps "Setup MFA" option in the sheet
- **THEN** the system SHALL:
  1. Retrieve TOTP secret code from backend
  2. Store secret code locally in `MFAConfigManagerForUAT`
  3. Generate current TOTP code using the secret
  4. Verify the TOTP code with backend
  5. Enable MFA for the user account
  6. Dismiss the option sheet

#### Scenario: MFA setup failure handling
- **WHEN** any step in MFA setup fails (network error, invalid code, etc.)
- **THEN** the system SHALL throw a `MFAConfigManagerForUAT.MFAError`
- **AND** the error SHALL be logged to console
- **AND** the option sheet SHALL be dismissed

### Requirement: TOTP Code Generation and Clipboard Copy
The system SHALL generate a fresh TOTP code and copy it to the system clipboard when "Copy TOTP" option is selected.

#### Scenario: Successful TOTP generation and copy
- **WHEN** user taps "Copy TOTP" option in the sheet
- **AND** MFA secret code has been previously set up
- **THEN** the system SHALL:
  1. Generate current TOTP code using stored secret
  2. Copy the 6-digit code to `UIPasteboard.general.string`
  3. Dismiss the option sheet

#### Scenario: Copy TOTP without setup
- **WHEN** user taps "Copy TOTP" option
- **AND** no secret code has been set up yet
- **THEN** the system SHALL throw `MFAError.secretCodeNotSet`
- **AND** the error SHALL be logged to console

#### Scenario: Invalid TOTP generation
- **WHEN** TOTP code generation fails due to invalid secret
- **THEN** the system SHALL throw `MFAError.failedToGenerateTOTP`
- **AND** the error SHALL be logged to console

### Requirement: UITest Helper Integration
The system SHALL provide a UITest helper method to interact with MFA utility options programmatically.

#### Scenario: Helper method triggers Setup MFA
- **WHEN** UITest calls `UATHelper.clickMFAUtilityOption("Setup MFA", app)`
- **THEN** the helper SHALL:
  1. Tap the `mfaUtilityButton`
  2. Wait for "MFAOptionSheet" to appear
  3. Tap the "setupMFAOption" button
  4. Wait for "MFAOptionSheet" to disappear
  5. Wait 2 seconds for async operation completion

#### Scenario: Helper method triggers Copy TOTP
- **WHEN** UITest calls `UATHelper.clickMFAUtilityOption("Copy TOTP", app)`
- **THEN** the helper SHALL:
  1. Tap the `mfaUtilityButton`
  2. Wait for "MFAOptionSheet" to appear
  3. Tap the "copyTOTPOption" button
  4. Wait for "MFAOptionSheet" to disappear
  5. Wait 2 seconds for async operation completion

### Requirement: Clipboard-Based TOTP Retrieval in UITests
UITests SHALL retrieve TOTP codes from the system clipboard instead of reading from screen elements.

#### Scenario: UITest reads TOTP from clipboard
- **WHEN** UITest triggers "Copy TOTP" action
- **THEN** the test SHALL read the TOTP code from `UIPasteboard.general.string`
- **AND** the clipboard SHALL contain exactly 6 digits
- **AND** the code SHALL be valid for current time window

#### Scenario: Clipboard empty validation
- **WHEN** UITest reads from clipboard after "Copy TOTP"
- **AND** clipboard is empty or nil
- **THEN** the test SHALL fail with assertion "TOTP code should not be empty"

### Requirement: Automatic TOTP Display Removal
The system SHALL NOT automatically display TOTP codes on screen in UITest mode.

#### Scenario: No automatic TOTP display
- **WHEN** user navigates to MFA verification screen
- **THEN** no TOTP code SHALL be automatically displayed with identifier "mfaVerifyCode"
- **AND** the `UATMFAUtilityModifier` SHALL NOT be applied to any view

#### Scenario: Modifier cleanup
- **WHEN** application builds
- **THEN** no reference to `.mfaUtilityView()` modifier SHALL exist in the codebase
- **AND** `UATMFAUtilityModifier.swift` file SHALL be deleted
