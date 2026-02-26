## ADDED Requirements

### Requirement: Restore test for testAIControlSetting account
The RestoreUITest SHALL include a restore test that deletes the organization from the `testAIControlSetting` account, following the established `test_restore_{action}_{credential}` naming convention.

#### Scenario: Restore test cleans up residual organization
- **WHEN** `test_restore_deleteOrganization_testAIControlSetting` is executed via the Restore scheme
- **THEN** the test SHALL sign in with `.testAIControlSetting(true)` (canSeeViewTab = true)
- **AND** the test SHALL call `UATHelper.deleteTestOrganization(app)` to delete the organization
- **AND** the account SHALL be restored to a no-organization state

#### Scenario: Restore test follows existing convention
- **WHEN** the restore test is added to `RestoreUITest.swift`
- **THEN** the method name SHALL be `test_restore_deleteOrganization_testAIControlSetting`
- **AND** the test SHALL use `setupAndSignIn(.testAIControlSetting(true))` for sign-in
- **AND** the pattern SHALL match the existing `test_restore_deleteOrganization_newToVORTEX` implementation

