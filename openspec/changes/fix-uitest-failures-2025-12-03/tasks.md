# Implementation Tasks

## 1. Fix testSignInWithSSO_Success (Priority: High)
- [x] 1.1 Add `handlePasskeyDialogIfNeeded()` function in `CommonOperation.swift:204-209` to handle new passkey setup dialog
- [x] 1.2 Use `waitElementToAppearOptionally` to detect and dismiss passkey dialog with Cancel button
- [x] 1.3 Keep `ssoConfirmToEnterApp()` logic unchanged to continue waiting for "Stay signed in?" dialog
- [x] 1.4 Run `testSignInWithSSO_Success` locally to verify fix
- [x] 1.5 Verify other SSO tests still pass (`testSignInWithSSO_ShouldFailed_whenTypeDifferentEmailOnMicrosoftPage`)

## 2. Fix testCannotRemoteUnlockDoorWhenDND (Priority: Medium) ✅ COMPLETED
- [x] 2.1 Investigate UAT test environment to determine current status of DND door
  - **Root Cause**: UAT environment configuration issue - DND door was in "Locked" state instead of "Force Close" (lockedDown)
  - **Evidence**: CI screenshot (3A3F34E0-8F3D-4DD8-93BF-B5A0EB4E3060.png) shows DND door displaying "Locked" with green text and Unlock button visible
  - **Analysis**: Test expects "Force Close" (lockedDown state = cannot unlock), but environment showed "Locked" (locked state = can unlock)
- [x] 2.2 Resolution: UAT environment configuration restored to correct state (DND door set to "Force Close")
  - **No code changes required** - test assertion `AccessControlMessageUITest.swift:59` remains correct
  - **Action Taken**: Environment configuration fixed by operations team

## 3. Fix testLicenseGracePeriod (Priority: Medium) ✅ COMPLETED
- [x] 3.1 Add `continueAfterFailure = false` in `setUpWithError()` to stop test immediately on first assertion failure
- [x] 3.2 Identify exact failing assertion from error log: `LicensePhaseUITest.swift:65: XCTAssertTrue failed`
- [x] 3.3 Fix banner value assertion at line 67 - grace period uses `alertStyle`, not `dangerStyle`
- [x] 3.4 Refactor `switchLicensePhase` to use switch statement for clarity (handles all three phases explicitly)
- [x] 3.5 Run all LicensePhaseUITest tests to ensure consistency (`testLicenseNotice`, `testLicenseGracePeriod`, `testLicenseOverdue`)
- [x] 3.6 Verify tests pass consistently (run 3 times minimum)
- [x] 3.7 Code changes committed and pushed (commit: be7be2d23)

---

**Validation**: All fixes will be verified through tomorrow's CI test report.
