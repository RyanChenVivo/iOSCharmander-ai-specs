## Why

UITest MFA TOTP code retrieval is unstable due to automatic display on screen that refreshes every 30 seconds. Tests often fail when reading codes that are about to expire, causing timing issues and unreliable test results. This change improves test stability by switching to a user-triggered UATButton + clipboard approach.

## What Changes

- Add new `mfaUtilityButton` (button 18) in `UATUtilityView` with two options:
  - **Setup MFA** - One-click complete MFA setup flow
  - **Copy TOTP** - Generate and copy current TOTP code to clipboard
- Refactor `MFAConfigManagerForUAT` to support new operations (`setupMFA()`, `generateAndCopyToClipboard()`)
- Remove automatic TOTP display mechanism (`UATMFAUtilityModifier`)
- Update all UITests to use clipboard-based TOTP retrieval instead of reading from screen
- **BREAKING**: Remove `mfaVerifyCode` accessibility identifier and automatic display logic

## Capabilities

### New Capabilities
- `uat-mfa-utility`: New UATButton-based MFA testing utilities for UITest support with clipboard integration

### Modified Capabilities
- `mfa-configuration`: Update MFA configuration flow to support UAT-specific setup and TOTP generation without UI display

## Impact

**Affected Code:**
- `iOSCharmander/View/UATUtilityView.swift` - Add new button and option sheet
- `iOSCharmander/View/SideMenu/Settings/MFAConfigurationViewModel.swift` - Refactor `MFAConfigManagerForUAT`
- `iOSCharmander/View/SignIn/VerifyMFA/VerifyMFAView.swift` - Remove `.mfaUtilityView()` modifier
- `iOSCharmander/View/SideMenu/Settings/UATMFAUtilityModifier.swift` - **DELETE** (deprecated)

**Affected UITests:**
- `iOSCharmanderUITests/Infrastructure/UATHelper.swift` - Add `clickMFAUtilityOption()` helper
- `iOSCharmanderUITests/Infrastructure/CommonOperation.swift` - Update `setMFA()` method
- `iOSCharmanderUITests/MFASetting/MFAConfigurationUITest.swift` - Update `enterMFAVerifyCode()`
- `iOSCharmanderUITests/SignIn/OrgForceMFAUITest.swift` - Update both test methods

**Dependencies:**
- Uses existing `UIPasteboard.general` for clipboard access
- No new external dependencies

**Breaking Changes:**
- All existing UITests that reference `mfaVerifyCode` accessibility identifier must be updated
- Automatic TOTP display on screen is removed (UITest-only feature)
