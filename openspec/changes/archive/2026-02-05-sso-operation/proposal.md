## Why

The current `entraWebSSOSignIn` method in `CommonOperation.swift` has hardcoded flow sequences that assume a fixed order (account → password → checks → Passkey → confirmation). This causes UITest instability when Microsoft changes their SSO flow, and multiple sequential `waitElementToAppearOptionally` calls cause slow tests when variants don't appear. Additionally, several Microsoft page variants (Passkey management dialogs, creation failures) are not handled.

## What Changes

- Add new `SSOOperation` protocol with state machine-based flow handling
- Implement `SSOPage` enum to represent all possible Microsoft SSO pages
- Create page detection system that checks all pages simultaneously instead of sequentially
- Add page handlers that process each page type and return flow control signals
- Provide default protocol extension implementation for `performEntraSSOSignIn`
- Update existing SSO UITests to adopt the new `SSOOperation` protocol

## Capabilities

### New Capabilities
- `sso-operation`: State machine-based SSO flow handling protocol for UITests that detects and handles Microsoft Entra SSO pages dynamically, supporting variable page orders and new page variants

### Modified Capabilities
<!-- No existing spec requirements are changing -->

## Impact

- **New file:** `iOSCharmanderUITests/Infrastructure/SSOOperation.swift`
- **Modified files:**
  - `iOSCharmanderUITests/SignIn/SigninWithSSOUITest.swift` - adopt `SSOOperation` protocol
  - `iOSCharmanderUITests/SignIn/OrgForceMFAUITest.swift` - adopt `SSOOperation` protocol
- **Dependencies:** Uses existing `UATHelper` and `CommonOperation` infrastructure
- **Testing impact:** All SSO-related UITests will use the new state machine approach
