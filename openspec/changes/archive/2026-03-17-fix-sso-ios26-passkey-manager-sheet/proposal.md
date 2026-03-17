## Why

iOS 26 introduces a system-level passkey manager selection sheet ("Choose how to manage your passkeys.") that appears automatically when Microsoft SSO triggers passkey setup. This sheet is presented by the AuthenticationServices framework and is not part of the app's accessibility hierarchy, so the existing `settingUpPasskey` handler cannot tap the web Cancel button it blocks. All SSO tests fail (3/3) with "SSO flow exceeded maximum iterations (15)".

## What Changes

- Add handling for the iOS 26 system-level passkey manager sheet by accessing it through the springboard accessibility tree
- Modify `settingUpPasskey` handler to dismiss the system sheet before tapping the web Cancel button
- Update `detectCurrentPage` to prioritize system-level sheet detection (since it overlays all other elements)

## Capabilities

### New Capabilities

_None_

### Modified Capabilities

- `sso-operation`: Add detection and handling for the iOS 26 system-level passkey manager sheet. The existing `choosePasskeyManager` case handles an in-app native alert (with a Cancel button). The new flow is a system-level sheet (with ✕ close button, "Open Settings", "More Options") that must be accessed via the springboard accessibility tree.

## Impact

- **Files affected**: `iOSCharmanderUITests/Infrastructure/SSOOperation.swift`
- **Tests affected**: All tests using `performEntraSSOSignIn` (SigninWithSSO, OrgForceMFAUITest, etc.)
- **Platform dependency**: iOS 26 Simulator behavior change; must verify backward compatibility with iOS 25
- **External dependency**: Interaction between Microsoft Entra SSO and iOS AuthenticationServices framework
