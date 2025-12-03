# Fix UITest Failures from CI (2025-12-03)

## Why

Three UITests failed in the December 3, 2025 CI run (117 passed, 3 failed). These failures prevent full test coverage validation and may indicate either test data issues, timing problems, or changes in external SSO behavior that need to be addressed.

## What Changes

- **Fix testCannotRemoteUnlockDoorWhenDND**: Update test to handle current door status or fix test data configuration for DND door
- **Fix testLicenseGracePeriod**: Correct test assertion logic for camera settings button visibility during license grace period
- **Fix testSignInWithSSO_Success**: Update SSO signin flow to handle Microsoft Entra ID's changed authentication UI (removed "Stay signed in?" dialog)

## Impact

- **Affected specs**: `uitests` (UI test reliability and maintenance)
- **Affected code**:
  - `iOSCharmanderUITests/Device/AccessControlMessageUITest.swift:57-60`
  - `iOSCharmanderUITests/LicensePlan/LicensePhaseUITest.swift:38-46`
  - `iOSCharmanderUITests/SignIn/SigninWithSSOUITest.swift:41-46`
  - `iOSCharmanderUITests/Infrastructure/CommonOperation.swift:204-207`
- **Risk**: Low - test-only changes with no production code impact
- **User impact**: None (test infrastructure only)
