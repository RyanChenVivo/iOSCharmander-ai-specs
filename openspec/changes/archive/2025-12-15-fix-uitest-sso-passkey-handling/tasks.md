# Implementation Tasks

## 1. Add Passkey Web Page Handler (Priority: High)
- [x] 1.1 Add `handlePasskeyWebPageIfNeeded()` function before `handlePasskeyDialogIfNeeded()` in `CommonOperation.swift:204-209`
  - Use `waitElementToAppearOptionally` to detect "Setting up your passkey..." text in web view
  - Click "Cancel" button in web view to skip Passkey setup
  - Function should run before the native biometrics dialog handler
- [x] 1.2 Call `handlePasskeyWebPageIfNeeded()` in `entraWebSSOSignIn()` flow at line 224 (after `otherCheckIfNeeded()`, before `handlePasskeyDialogIfNeeded()`)
- [x] 1.3 Keep existing `handlePasskeyDialogIfNeeded()` unchanged (lines 210-215) - it handles the subsequent native dialog
- [x] 1.4 Keep `ssoConfirmToEnterApp()` unchanged (lines 216-219) - it handles the final "Stay signed in?" dialog

## 2. Test Verification (Priority: High)
- [x] 2.1 Run `testSignInWithSSO_ShouldFailed_whenTypeDifferentEmailOnMicrosoftPage` locally to verify fix
- [x] 2.2 Run `testSSOSignInWithOrgForceMFA` locally to verify fix
- [x] 2.3 Run all SSO-related tests to ensure no regression:
  - `SigninWithSSOUITest` test suite
  - `OrgForceMFAUITest` test suite
- [x] 2.4 Verify tests pass consistently (run 2-3 times minimum)

## 3. Documentation & Cleanup (Priority: Medium)
- [ ] 3.1 Update `uitest-automation/knowledge/external-dependencies.md` to document the new Microsoft Passkey web page flow
- [ ] 3.2 Update `uitest-automation/observations/active.json` to mark SSO tests as fixed
- [ ] 3.3 Consider adding code comments in `entraWebSSOSignIn()` explaining the Passkey handling sequence

## 4. CI Validation (Priority: High)
- [ ] 4.1 Commit and push changes
- [ ] 4.2 Wait for CI test run (next daily run)
- [ ] 4.3 Verify both SSO tests pass in CI
- [ ] 4.4 Update triage report or observations if tests pass

---

## Implementation Notes

### Code Location
- **File**: `iOSCharmanderUITests/Infrastructure/CommonOperation.swift`
- **Function**: `entraWebSSOSignIn(account:password:)` (lines 172-220)
- **Insertion point**: Between `otherCheckIfNeeded()` and `handlePasskeyDialogIfNeeded()`

### Handler Sequence
The correct order of handlers in `entraWebSSOSignIn()` should be:
1. `enterAccount()` - Enter email
2. `enterPassword()` - Enter password (may include Passkey prompts)
3. `otherCheckIfNeeded()` - Handle "Sign in faster..." dialog
4. **NEW**: `handlePasskeyWebPageIfNeeded()` - Handle web-based "Setting up your passkey..." page
5. `handlePasskeyDialogIfNeeded()` - Handle native biometrics dialog
6. `ssoConfirmToEnterApp()` - Handle "Stay signed in?" dialog

### Expected Code Pattern
```swift
func handlePasskeyWebPageIfNeeded() {
    // Handle Microsoft's web-based Passkey setup page
    UATHelper.waitElementToAppearOptionally(element: app.webViews.staticTexts["Setting up your passkey..."]) {
        UATHelper.waitElementToTap(app.webViews.buttons["Cancel"].firstMatch)
    }
}
```

### Alternative Approaches Considered
1. **Click "Cancel" on biometrics dialog only**: Won't work - the web page blocks progress
2. **Click "Next" to proceed with Passkey setup**: Requires biometrics enrollment in simulator (not feasible)
3. **Wait for timeout**: Too slow, causes test timeout failures
4. **Skip SSO tests**: Not acceptable - SSO is critical functionality

---

**Validation**: All fixes will be verified through the next CI test report (2025-12-16).
