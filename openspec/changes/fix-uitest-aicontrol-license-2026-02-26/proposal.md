## Why

2026-02-26 CI UITest reported 7 failures (AIControlSetting group: 5, License group: 2), all caused by environment residual state or requirement changes — not code bugs. The `testAIControlSetting` account retains a residual organization with no restore mechanism; the License tests still check the removed DeepSearch top-level tab. These need to be fixed to restore CI test stability.

## What Changes

### AIControlSetting Group — Establish Restore Mechanism
- Add `test_restore_deleteOrganization_testAIControlSetting` to `RestoreUITest.swift`, using `setupAndSignIn(.testAIControlSetting(true))` + `UATHelper.deleteTestOrganization(app)` to clean up residual organization data
- Each test already calls `deleteTestOrganization` in its body; the residual state is caused by external/human factors, not test flow issues — no tearDown changes needed

### License Group — Update Tab Check
- In `LicensePhaseUITest.checkTabItemStatus()`, change `checkTabStatus(.deepSearch, isEnable: isEnable)` to `checkTabStatus(.aiHub, isEnable: isEnable)`, reflecting the DeepSearch integration into AI Hub
- **Prerequisite:** The feature owner will remove the `isDeveloperMode` restriction on AI Hub, making the aiHub tab visible in CI environment, restoring tab count to > 4, and the "More" button will reappear naturally

## Capabilities

### New Capabilities
- `uitest-aicontrol-restore`: Restore mechanism for AIControlSettingUITest — add restore test for cleaning up residual organization data

### Modified Capabilities
- `app-license-management`: Update License test tab check from `.deepSearch` to `.aiHub`, reflecting the DeepSearch-to-AI-Hub integration

## Impact

- **Test files:**
  - `iOSCharmanderUITests/Restore/RestoreUITest.swift` — add restore test
  - `iOSCharmanderUITests/SignIn/AIControlSettingUITest.swift` — no changes needed (existing cleanup is sufficient)
  - `iOSCharmanderUITests/LicensePlan/LicensePhaseUITest.swift` — update tab check item
- **CI impact:** Expected to recover 7 tests after fix (pass rate 92.7% → 98.4%)
- **Prerequisite dependency:** License fix requires the feature owner to remove aiHub's `isDeveloperMode` restriction to take effect
- **Analysis report:** `$HOME/Downloads/UITestAnalysis/latest/triage_report_2026-02-26.md`
