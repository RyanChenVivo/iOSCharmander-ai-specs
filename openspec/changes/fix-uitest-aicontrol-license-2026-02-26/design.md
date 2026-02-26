## Context

Two UITest failure groups from 2026-02-26 CI require test-level fixes:

1. **AIControlSetting (5 failures):** The `testAIControlSetting` account (`aitoggletester@thedaring.org`) has residual organization data from a previous test run. All 5 tests in `AIControlSettingUITest` fail at `createOrganization()` because the app skips the "Create Organization" screen and goes directly to the main View screen. The current `tearDownWithError()` does not include organization cleanup, and no restore test exists for this account.

2. **License (2 failures):** `LicensePhaseUITest.checkTabItemStatus()` still checks `.deepSearch` as a top-level tab, but commit `16041b125` (2026-02-24) removed DeepSearch from `supportedHomeViewTabs()` and integrated it into AI Hub as a sub-tab. Additionally, with only 4 tabs visible, `getDisplayTabs()` no longer appends `.more`, so the "More" button is absent.

**Current test files:**
- `iOSCharmanderUITests/SignIn/AIControlSettingUITest.swift` — `tearDownWithError()` only calls `checkTestResult` + `app.terminate()`
- `iOSCharmanderUITests/Restore/RestoreUITest.swift` — only has `test_restore_deleteOrganization_newToVORTEX`
- `iOSCharmanderUITests/LicensePlan/LicensePhaseUITest.swift` — `checkTabItemStatus()` checks `.deepSearch`

## Goals / Non-Goals

**Goals:**
- Restore CI stability for the 7 affected tests
- Provide a restore mechanism for `testAIControlSetting` account cleanup
- Prevent future cascading failures from residual organization data
- Update License tests to reflect the DeepSearch-to-AI-Hub integration

**Non-Goals:**
- Changing production app code (all changes are test-only)
- Fixing the "More" button visibility (handled by the feature owner removing `isDeveloperMode` restriction on aiHub)
- Addressing the Archive test failure (separate issue, assigned to another team member)

## Decisions

### 1. Add restore test to RestoreUITest

**Decision:** Add `test_restore_deleteOrganization_testAIControlSetting` using the existing pattern: `setupAndSignIn(.testAIControlSetting(true))` + `UATHelper.deleteTestOrganization(app)`.

**Rationale:** Follows the established restore test convention (`test_restore_{action}_{credential}`). Using `testAIControlSetting(true)` ensures the sign-in waits for the View tab, which is required since the account already has an organization.

**Alternative considered:** Adding cleanup to a CI pre-test script. Rejected because the UAT button approach is the standard mechanism and doesn't require additional infrastructure.

### 2. Replace .deepSearch with .aiHub in checkTabItemStatus

**Decision:** Change `checkTabStatus(.deepSearch, isEnable: isEnable)` to `checkTabStatus(.aiHub, isEnable: isEnable)` in `LicensePhaseUITest.checkTabItemStatus()`.

**Rationale:** DeepSearch is no longer a top-level `HomeViewTab` — it's now an `AiHubTab` sub-tab within AI Hub. The License test should verify the AI Hub tab's enabled/disabled state under different license phases, which is the replacement for what DeepSearch validation previously covered.

**Prerequisite:** The feature owner must remove the `isDeveloperMode` guard on `canView(for: .aiHub)` so that AI Hub appears in CI. Once visible, the tab count returns to > 4 and the "More" button reappears, resolving the first failure point.

## Risks / Trade-offs

- **[Risk] Residual organization from external factors** → The test flow already includes `deleteTestOrganization` at the end of each test body. Residual organization data is caused by external/human factors (e.g., manual testing, CI interruption), not by test flow issues. Mitigation: the restore test provides a manual escape hatch to clean up when needed, without adding complexity to tearDown.

- **[Risk] License fix depends on external prerequisite** → The `.aiHub` check will fail if the feature owner hasn't removed the `isDeveloperMode` restriction yet. Mitigation: the test change can be merged first since `checkTabStatus` uses optional matching (`.first { $0.isHittable }` + `.map`), so a missing aiHub tab won't crash — it just won't assert. The assertion becomes effective once aiHub is visible.
