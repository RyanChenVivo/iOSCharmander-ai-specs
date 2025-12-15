# Fix UITest SSO Passkey Handling (2025-12-15)

## Why

Two SSO-related UITests have been failing consistently since December 10, 2025 (6 days). The December 15 CI run revealed a new root cause: Microsoft Entra ID introduced a new "Setting up your passkey..." web page dialog that appears during the SSO authentication flow, which our tests don't handle.

### Failure Analysis

#### Affected Tests
1. `SigninWithSSO/testSignInWithSSO_ShouldFailed_whenTypeDifferentEmailOnMicrosoftPage()`
2. `OrgForceMFAUITest/testSSOSignInWithOrgForceMFA()`

#### Error Message
```
failed - "Stay signed in?" StaticText is not exist
```

#### Screenshot Evidence
- **File**: `410C88E7-8F1B-4E08-841E-0C783E416EEA.png`
- **Shows**: Microsoft web page with title "Setting up your passkey..."
- **Content**: "Your device is opening a security window. Follow the instructions to finish setting up your passkey."
- **Buttons**: "Cancel" and "Next"
- **System Dialog**: "Simulator requires enrolled biometrics to use passkeys."

#### Root Cause
Microsoft Entra ID added a new **web-based** Passkey setup page to the SSO authentication flow:
1. User enters email and password
2. **NEW**: Microsoft shows "Setting up your passkey..." page (web view)
3. **NEW**: System shows biometrics dialog (native) - this is already handled by `handlePasskeyDialogIfNeeded()`
4. Expected: "Stay signed in?" dialog

The existing `handlePasskeyDialogIfNeeded()` function (lines 204-209) only handles the **native** system dialog, but doesn't handle the **web page** that appears before it.

#### Diagnostic History
- **2025-12-10 to 2025-12-14**: Tests failed with same error, initially suspected as Microsoft IP blocking
- **2025-12-12**: Generated triage report suggesting IT/Azure admin intervention
- **2025-12-15**: Visual analysis with screenshots revealed the actual cause is a new Passkey web page flow

#### Previous Similar Fix
- **2025-12-03**: Fixed similar Passkey dialog issue in `fix-uitest-failures-2025-12-03`
- That fix added `handlePasskeyDialogIfNeeded()` for the native biometrics dialog
- This fix extends the solution to handle the web-based Passkey setup page

## What Changes

Add handling for Microsoft's new "Setting up your passkey..." web page in the SSO authentication flow:

- **Add new function**: `handlePasskeyWebPageIfNeeded()` to detect and skip the web-based Passkey setup page
- **Location**: `iOSCharmanderUITests/Infrastructure/CommonOperation.swift:199-203` (before `handlePasskeyDialogIfNeeded()`)
- **Logic**:
  - Detect "Setting up your passkey..." text in web view
  - Click "Cancel" button to skip Passkey setup
  - Continue to existing `handlePasskeyDialogIfNeeded()` for native dialog
  - Proceed to "Stay signed in?" dialog as normal

## Impact

- **Affected specs**: `mobile-floor-plan-ui-testing` (UI test reliability)
- **Affected code**:
  - `iOSCharmanderUITests/Infrastructure/CommonOperation.swift:172-220` (entraWebSSOSignIn function)
- **Risk**: Low - test-only changes with no production code impact
- **User impact**: None (test infrastructure only)
- **CI Impact**: Fixes 2 consistently failing tests (5.8% failure rate reduced to ~0%)
- **Test Environment**: No environment changes required (pure code fix)

## Related

- **Previous fix**: `fix-uitest-failures-2025-12-03` - handled native Passkey dialog
- **Triage report**: `triage_report_2025-12-15.md` - comprehensive analysis with visual evidence
- **Observations**: Updated in `uitest-automation/observations/active.json` (occurrences: 4, decision: requires_fix)
