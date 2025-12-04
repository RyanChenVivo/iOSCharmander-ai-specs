# Fix UITest Failures from CI (2025-12-03)

## Why

Three UITests failed in the December 3, 2025 CI run (117 passed, 3 failed). These failures prevent full test coverage validation and may indicate either test data issues, timing problems, or changes in external SSO behavior that need to be addressed.

## Diagnostic Process

### Sources of Information
1. **Error text from test_failures.json**: General failure message (e.g., "XCTAssertTrue failed")
2. **Detailed error from test_details.json**: Exact failure location with line numbers (e.g., "LicensePhaseUITest.swift:65: XCTAssertTrue failed")
3. **Failure screenshots**: Actual UI state at time of failure (found in attachments/)
4. **Test source code**: Expected behavior and assertion logic

### Failure Analysis

#### testSignInWithSSO_Success
- **Error message**: `failed - "Stay signed in?" StaticText is not exist`
- **Screenshot evidence**: Shows Microsoft passkey dialog instead of expected "Stay signed in?" dialog
- **Root cause**: Microsoft Entra ID introduced new passkey setup dialog in simulator
- **Fix approach**: Add optional handler to dismiss passkey dialog before waiting for "Stay signed in?"

#### testLicenseGracePeriod
- **Error message**: `XCTAssertTrue failed` (generic)
- **Detailed error**: `LicensePhaseUITest.swift:65: XCTAssertTrue failed` (from test_details.json)
- **Screenshot evidence**: Shows test continued past failure point (because continueAfterFailure wasn't set)
- **Code inspection**: Line 65 expects `dangerStyle` but NoticeBanner.swift:145 shows grace period uses `alertStyle`
- **Root cause**: Incorrect banner value assertion - grace period uses alert banner, not danger banner
- **Fix approach**:
  1. Add `continueAfterFailure = false` to stop test immediately on assertion failure
  2. Fix banner value check: `.gracePeriod` → `"alertStyle"` (not `"dangerStyle"`)
  3. Refactor to switch statement for clarity

#### testCannotRemoteUnlockDoorWhenDND
- **Error message**: `failed - "doorComponentInfo_Force Close" StaticText is not exist`
- **Root cause**: TBD - requires UAT environment investigation
- **Possible causes**:
  - Door status changed in UAT environment
  - Test data configuration issue
  - Door name or identifier changed

## What Changes

- **Fix testSignInWithSSO_Success**: Handle Microsoft Entra ID passkey dialog in simulator
- **Fix testLicenseGracePeriod**: Correct banner value assertion and add continueAfterFailure = false
- **Fix testCannotRemoteUnlockDoorWhenDND**: TBD after UAT investigation

## Impact

- **Affected specs**: `uitests` (UI test reliability and maintenance)
- **Affected code**:
  - `iOSCharmanderUITests/Device/AccessControlMessageUITest.swift:57-60`
  - `iOSCharmanderUITests/LicensePlan/LicensePhaseUITest.swift:38-46`
  - `iOSCharmanderUITests/SignIn/SigninWithSSOUITest.swift:41-46`
  - `iOSCharmanderUITests/Infrastructure/CommonOperation.swift:204-207`
- **Risk**: Low - test-only changes with no production code impact
- **User impact**: None (test infrastructure only)
