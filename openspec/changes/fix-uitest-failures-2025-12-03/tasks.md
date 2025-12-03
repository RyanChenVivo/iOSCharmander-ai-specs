# Implementation Tasks

## 1. Fix testSignInWithSSO_Success (Priority: High)
- [x] 1.1 Add `handlePasskeyDialogIfNeeded()` function in `CommonOperation.swift:204-209` to handle new passkey setup dialog
- [x] 1.2 Use `waitElementToAppearOptionally` to detect and dismiss passkey dialog with Cancel button
- [x] 1.3 Keep `ssoConfirmToEnterApp()` logic unchanged to continue waiting for "Stay signed in?" dialog
- [ ] 1.4 Run `testSignInWithSSO_Success` locally to verify fix
- [ ] 1.5 Verify other SSO tests still pass (`testSignInWithSSO_ShouldFailed_whenTypeDifferentEmailOnMicrosoftPage`)

## 2. Fix testCannotRemoteUnlockDoorWhenDND (Priority: Medium)
- [ ] 2.1 Investigate UAT test environment to determine current status of DND door
- [ ] 2.2 Either: Update test data to ensure DND door has "Force Close" status, OR
- [ ] 2.3 Or: Update test assertion at `AccessControlMessageUITest.swift:59` to check for actual door status
- [ ] 2.4 Run `testCannotRemoteUnlockDoorWhenDND` locally with UAT environment to verify
- [ ] 2.5 Document expected door status in test comments

## 3. Fix testLicenseGracePeriod (Priority: Medium)
- [ ] 3.1 Review license phase behavior specification for grace period
- [ ] 3.2 Determine if camera settings button should be enabled or disabled during grace period
- [ ] 3.3 Update test assertion at `LicensePhaseUITest.swift:43` to match actual expected behavior
- [ ] 3.4 Run all LicensePhaseUITest tests to ensure consistency (`testLicenseNotice`, `testLicenseOverdue`)
- [ ] 3.5 Document correct license phase behavior in test comments

## 4. Validation
- [ ] 4.1 Run full UITest suite locally to ensure no regressions
- [ ] 4.2 Verify all three fixed tests pass consistently (run 3 times minimum)
- [ ] 4.3 Check CI test results after PR merge to confirm fixes in CI environment
- [ ] 4.4 Update test documentation if any behavior clarifications were needed
