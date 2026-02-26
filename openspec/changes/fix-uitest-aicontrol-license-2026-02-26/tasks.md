## 1. AIControlSetting Restore Mechanism

- [x] 1.1 Add `test_restore_deleteOrganization_testAIControlSetting` to `RestoreUITest.swift` — sign in with `.testAIControlSetting(true)` and call `UATHelper.deleteTestOrganization(app)`
- [ ] 1.2 Run the restore test via Restore scheme to clean up the current residual organization on CI (manual — requires CI access)

## 2. License Tab Check Update

- [x] 2.1 In `LicensePhaseUITest.checkTabItemStatus()`, change `checkTabStatus(.deepSearch, isEnable: isEnable)` to `checkTabStatus(.aiHub, isEnable: isEnable)`

## 3. Verification

- [ ] 3.1 Confirm the feature owner has removed `isDeveloperMode` restriction on aiHub (prerequisite for License fix to take effect)
- [ ] 3.2 Run AIControlSettingUITest locally to verify all 5 tests pass after restore
- [ ] 3.3 Run LicensePhaseUITest locally to verify testLicenseGracePeriod and testLicenseOverdue pass with aiHub check
- [ ] 3.4 Verify next CI run recovers the 7 affected tests
