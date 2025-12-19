# Implementation Tasks

## 1. Fix Threading Crash in DowngradeProgressViewModel (Priority: CRITICAL) ✅ COMPLETED
- [x] 1.1 Wrap `dismissAction()` call in `downgradeLicenseExists` error handler (line 75-77) with `MainActor.run`
- [x] 1.2 Wrap `dismissAction()` call in default error cancel action (line 87-89) with `MainActor.run`
- [x] 1.3 Verify no other `dismissAction()` calls exist without main actor protection
- [x] 1.4 Review similar patterns in other ViewModels for same issue

## 2. Verify Fix with Manual Testing (Priority: HIGH) ✅ COMPLETED
- [x] 2.1 Run `test_cantDowngrade_activeLicenseExists` in Xcode simulator
- [x] 2.2 Verify no threading errors appear in console
- [x] 2.3 Verify app does not crash when tapping "OK" on failure alert
- [x] 2.4 Verify "License expired!" text appears correctly after dismissing alert
- [x] 2.5 Test all error scenarios in DowngradeProgressView:
  - [x] 2.5.1 Downgrade with active licenses (VortexError.downgradeLicenseExists) - Manual testing passed

## 3. Run Full UITest Suite (Priority: HIGH) ⏳ PENDING CI
- [ ] 3.1 Run complete OrganizationPlanUITest class locally (will verify via CI tomorrow)
- [x] 3.2 Verify `test_cantDowngrade_activeLicenseExists` now passes (manual testing confirmed)
- [ ] 3.3 Verify `test_downgrade` still passes (regression check) - will check CI tomorrow
- [ ] 3.4 Verify `test_upgrade` still passes (regression check) - will check CI tomorrow
- [ ] 3.5 Run tests 3 times minimum to confirm stability - will check via CI

## 4. Update UITest Triage Documentation (Priority: MEDIUM) ✅ COMPLETED
- [x] 4.1 Update `uitest-automation/UITEST_AGENT.md` with crash detection protocol
- [x] 4.2 Add new section: "Crash Detection Protocol"
- [x] 4.3 Include warning signs checklist:
  - [x] Element not found with no clear screenshot
  - [x] Normal test duration (not immediate failure)
  - [x] No crash logs in CI artifacts
  - [x] Isolated failure with similar tests passing
- [x] 4.4 Add manual testing protocol:
  - [x] Step-by-step guide to run test in simulator
  - [x] What to look for in console (threading errors, crashes)
  - [x] When to create OpenSpec vs observe
- [x] 4.5 Document this case as example: "test_cantDowngrade_activeLicenseExists appeared as UI timing issue but was actually app crash"

## 5. Code Review and Commit (Priority: HIGH) 🔄 IN PROGRESS
- [x] 5.1 Self-review changes for threading safety
- [ ] 5.2 Ensure commit message includes full context:
  - [ ] Root cause (dismissAction on background thread)
  - [ ] Impact (user-facing crash)
  - [ ] Fix (MainActor.run wrapper)
  - [ ] How discovered (manual testing after suspicious UITest failure)
- [ ] 5.3 Reference this OpenSpec proposal in commit
- [ ] 5.4 Push changes and verify CI test results next run

---

**Validation**: Test must pass consistently in both local and CI environments before archiving this change.

**Critical Success Criteria**:
1. No threading errors in console when running test
2. App does not crash when tapping "OK" on downgrade failure alert
3. UITest passes consistently (3/3 runs minimum)
4. No regression in other OrganizationPlanUITest tests
