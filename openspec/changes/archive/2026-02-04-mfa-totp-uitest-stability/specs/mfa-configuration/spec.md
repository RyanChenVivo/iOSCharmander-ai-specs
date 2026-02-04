# MFA Configuration Specification

## ADDED Requirements

### Requirement: MFA Config Manager for UAT
The system SHALL provide a `MFAConfigManagerForUAT` singleton class to manage MFA operations in UITest mode.

#### Scenario: Singleton instance access
- **WHEN** code accesses `MFAConfigManagerForUAT.shared`
- **THEN** the system SHALL return the same shared instance
- **AND** the instance SHALL be marked `@MainActor`
- **AND** the instance SHALL conform to `@Observable`

#### Scenario: Dependency injection
- **WHEN** `MFAConfigManagerForUAT` is initialized
- **THEN** the system SHALL inject the following dependencies:
  - `authService` for TOTP setup and verification
  - `vortexApi` for enabling/disabling user MFA
  - `userDefaults` for reading user email

### Requirement: Complete MFA Setup Flow
The system SHALL provide a `setupMFA()` async method that executes the complete MFA configuration flow.

#### Scenario: Successful MFA setup execution
- **WHEN** `setupMFA()` is called
- **THEN** the system SHALL:
  1. Read `vortexSignInEmail` from UserDefaults
  2. Call `authService.getTOTPSetupDetail()` with app name and email
  3. Store returned secret code in `secretCodeForUAT` property
  4. Generate TOTP code using `SwiftOTP.TOTP` with current time
  5. Call `authService.verifyTOTPSetup()` with generated code
  6. Call `vortexApi.setUserMFA(true)` to enable MFA

#### Scenario: Setup fails at secret retrieval
- **WHEN** `authService.getTOTPSetupDetail()` throws an error
- **THEN** `setupMFA()` SHALL propagate the error
- **AND** no subsequent steps SHALL be executed

#### Scenario: Setup fails at TOTP generation
- **WHEN** secret code cannot be base32 decoded
- **OR** `TOTP.generate()` returns nil
- **THEN** `setupMFA()` SHALL throw `MFAError.failedToGenerateTOTP`

#### Scenario: Setup fails at verification
- **WHEN** `authService.verifyTOTPSetup()` throws an error
- **THEN** `setupMFA()` SHALL propagate the error
- **AND** MFA SHALL NOT be enabled for the user

### Requirement: TOTP Generation and Clipboard Copy
The system SHALL provide a `generateAndCopyToClipboard()` method that generates current TOTP and copies to clipboard.

#### Scenario: Successful TOTP copy
- **WHEN** `generateAndCopyToClipboard()` is called
- **AND** `secretCodeForUAT` is not empty
- **THEN** the system SHALL:
  1. Generate TOTP code using stored secret with current time
  2. Copy the code to `UIPasteboard.general.string`

#### Scenario: Copy fails when secret not set
- **WHEN** `generateAndCopyToClipboard()` is called
- **AND** `secretCodeForUAT` is empty
- **THEN** the system SHALL throw `MFAError.secretCodeNotSet`

#### Scenario: Copy fails on generation error
- **WHEN** TOTP generation fails (invalid secret or generation returns nil)
- **THEN** the system SHALL throw `MFAError.failedToGenerateTOTP`

### Requirement: MFA Error Types
The system SHALL define specific error types for MFA operations.

#### Scenario: Secret code not set error
- **WHEN** an operation requires secret code but it's not set
- **THEN** the system SHALL throw `MFAError.secretCodeNotSet`
- **AND** error description SHALL be "Secret code not set"

#### Scenario: TOTP generation failure error
- **WHEN** TOTP generation fails for any reason
- **THEN** the system SHALL throw `MFAError.failedToGenerateTOTP`
- **AND** error description SHALL be "Failed to generate TOTP"

### Requirement: ViewModel MFA Setup Cleanup
The `MFAConfigurationViewModel` SHALL NOT call UAT-specific code during normal MFA setup flow.

#### Scenario: prepareTOTP without UAT code
- **WHEN** `MFAConfigurationViewModel.prepareTOTP()` is called
- **THEN** the method SHALL:
  1. Call `authService.getTOTPSetupDetail()` to get secret and QR URI
  2. Store values in `secretCode` and `qrcodeURI` properties
  3. NOT call `MFAConfigManagerForUAT.setSecretCode()` (removed)
  4. NOT check `VortexEnvironment.isUITest` flag

#### Scenario: No automatic secret sharing
- **WHEN** ViewModel obtains TOTP secret during setup
- **THEN** the secret SHALL NOT be automatically passed to `MFAConfigManagerForUAT`
- **AND** UITest SHALL use `setupMFA()` method instead for complete flow

## REMOVED Requirements

### Requirement: Automatic TOTP display for UITest
**Reason**: Replaced by clipboard-based approach for better test stability. Automatic display caused timing issues due to 30-second TOTP refresh cycle.

**Migration**:
- Remove `UATMFAUtilityModifier.swift` file
- Remove all `.mfaUtilityView()` modifier usages
- Use `MFAConfigManagerForUAT.generateAndCopyToClipboard()` instead
- Update UITests to read from `UIPasteboard.general.string`

### Requirement: MFAConfigManagerForUAT published verifyCode property
**Reason**: No longer needed with clipboard approach. Property was used for automatic display.

**Migration**:
- Remove `@Published var verifyCode: String` from `MFAConfigManagerForUAT`
- Remove `genVerifyCode()` method
- Remove `setSecretCode(_ code: String)` method
- Use `setupMFA()` for complete flow or `generateAndCopyToClipboard()` for code retrieval
