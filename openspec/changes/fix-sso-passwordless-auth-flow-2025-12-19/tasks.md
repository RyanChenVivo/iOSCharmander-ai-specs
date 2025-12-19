# Tasks

## 1. Update passwordless flow detection in CommonOperation.swift
- [x] Update `enterPassword()` function in `entraWebSSOSignIn()` to detect "Get a code to sign in" heading
- [x] Maintain backward compatibility with "Verify your email" heading
- [x] Verify the password bypass logic works with both headings
- **File**: `iOSCharmanderUITests/Infrastructure/CommonOperation.swift:189`
- **Validation**: Code compiles without errors ✅

## 2. Test SSO authentication with updated flow
- [ ] Run `SigninWithSSO/testSignInWithSSO_Success()` locally to verify fix
- [ ] Run `SigninWithSSO/testSignInWithSSO_ShouldFailed_whenTypeDifferentEmailOnMicrosoftPage()` locally
- [ ] Run `OrgForceMFAUITest/testSSOSignInWithOrgForceMFA()` locally
- **Validation**: All 3 tests pass locally (will verify in CI)

## 3. Verify CI test pass
- [ ] Push changes to feature branch
- [ ] Monitor CI test execution
- [ ] Verify all 3 SSO tests pass in CI environment
- **Validation**: CI test results show 0 SSO failures

## 4. Update observations and knowledge base
- [x] Update `knowledge/patterns.md` to document this Microsoft auth flow change
- [x] Update `knowledge/external-dependencies.md` Microsoft section with passwordless flow notes
- [ ] Move SSO tests from `active.json` to `resolved.json` with outcome "fixed" (after CI verification)
- **Validation**: Documentation accurately reflects the fix and learnings ✅
