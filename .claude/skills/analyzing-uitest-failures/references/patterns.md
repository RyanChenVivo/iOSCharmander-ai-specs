# Known Failure Patterns

Record known failure patterns to improve triage decision consistency.

---

## network-timeout

**Trigger Conditions:**
- Error message contains "timeout" or "network error"
- Test duration abnormally long (>60 seconds for simple operations)

**Recommended Action:** Observe

**Reason:** Network issues are usually transient. Observe 1-2 days to see if recurring.

**Historical Cases:**
- Generally recovers automatically within 24 hours
- If persists beyond observation period, check network infrastructure

---

## sso-new-dialog

**Trigger Conditions:**
- Test name matches `.*SSO.*` or `.*SignIn.*`
- Error contains "element not found" or timeout on SSO flow
- URL contains `login.microsoftonline.com` or `login.live.com`

**Recommended Action:** Investigate

**Reason:** Microsoft frequently updates SSO UI. Need screenshots to identify specific change.

**Historical Cases:**
- 2025-12-03: Native passkey dialog appeared in simulator
  - Fix: Added `handlePasskeyDialogIfNeeded()`
  - Archive: `openspec/changes/archive/fix-uitest-failures-2025-12-03/`
- 2025-12-15: Web-based passkey setup page introduced
  - Fix: Added `handlePasskeyWebPageIfNeeded()`
  - Archive: `openspec/changes/archive/2025-12-15-fix-uitest-sso-passkey-handling/`
- 2025-12-19: Passwordless auth flow changed to "Get a code to sign in"
  - Fix: Added bypass for passwordless default
  - Archive: `openspec/changes/fix-sso-passwordless-auth-flow-2025-12-19/`

**Notes:**
- Microsoft changes are typically permanent and require code fix
- Always download screenshots to identify the specific UI change

---

## credential-expired

**Trigger Conditions:**
- Error contains "401", "unauthorized", "credential", or "auth"
- Auth-related tests failing systematically
- Multiple tests using same account fail at login

**Recommended Action:** Restore Environment

**Reason:** Test account credentials may have expired or been locked.

**Historical Cases:**
- Test account password expiration (manual credential refresh needed)
- Account locked due to too many failed attempts

---

## sso-microsoft-blocking

**Trigger Conditions:**
- All SSO tests fail simultaneously (100% failure rate)
- Error: "Stay signed in?" not exist
- Screenshot shows Microsoft security/blocking page

**Recommended Action:** Investigate (then Report if confirmed)

**Reason:** External service blocking won't self-resolve. Need screenshots to confirm, then may need IT intervention.

**Historical Cases:**
- 2025-12-10 to 2025-12-12: Microsoft blocked CI IP, required IT assistance

**Notes:**
- Non-programmable: Cannot bypass security blocking with code
- Requires human intervention (IT/Azure admin)

---

## uat-cleanup-failure

**Trigger Conditions:**
- Error contains `⚠️UATButton: [button_id] execute action failed`
- Common button IDs: `uatDeleteOrgNUMButton`, `uatDeleteTestCameraButton`
- Occurs at end of test (cleanup/teardown stage)

**Recommended Action:** Restore Environment

**Reason:** Test logic likely passed, only cleanup failed. May cause downstream test failures.

**Historical Cases:**
- 2025-12-15: newToVORTEX account had residual organization data

**Notes:**
- Check for downstream failures (Pattern: environment-state-residual)
- Manual cleanup: Login to UAT and delete test data

---

## environment-state-residual

**Trigger Conditions:**
- Multiple tests using same account fail at setup stage
- Error indicates unexpected initial state:
  - `"illustration_users" Image is not exist`
  - `"Email already exists"`
- Previous test(s) may have uat-cleanup-failure

**Recommended Action:** Restore Environment

**Reason:** Environment not clean from previous test run. NOT a code bug.

**Historical Cases:**
- 2025-12-15: newToVORTEX account had residual organization causing setup failures

---

## timing-element-not-ready

**Trigger Conditions:**
- Error: "element not found" but no UI changes in recent commits
- Test duration shorter than expected (failed quickly)
- Same test passes on retry without code changes
- Failures cluster on Monday mornings or CI heavy load periods
- Error occurs right after screen navigation or data loading

**Recommended Action:** Observe

**Reason:** Element may not be ready when test tries to interact. Often caused by:
- CI machine slower than local environment
- Backend response slower than usual (Monday mornings)
- Network latency variations
- Resource contention during parallel test runs

**Historical Cases:**
- Typically self-resolves within 24 hours
- If recurring 3+ times, may need timeout adjustment in test code

**Notes:**
- Check if error occurs at navigation/loading boundaries
- Compare test duration with normal runs
- If persists, escalate to Fix (add proper wait or increase timeout)

---

## message-user-feedback

**Trigger Conditions:**
- Test name matches `MessageUITests.*UserFeedback.*`
- Error: "sendUserFeedbackButton" Button is not enabled

**Recommended Action:** Observe

**Reason:** May be backend timing issue. VCA message data not loaded in time. More likely on Monday mornings.

**Historical Cases:**
- 2025-12-10: 4 tests failed, recovered next day

**Notes:**
- If recurring, escalate to Investigate
- Check if UAT backend is slow (Monday morning pattern)

---

## Adding New Patterns

When adding a new pattern, include:

**Required:**
- **Trigger Conditions** - How to recognize this pattern
- **Recommended Action** - observe/investigate/fix/restore
- **Reason** - Why this recommendation

**Recommended:**
- **Historical Cases** - When it happened, how it was resolved
- **Notes** - Special considerations

**Template:**
```markdown
## pattern-id

**Trigger Conditions:**
- Error message contains "X" or "Y"
- Test name pattern
- Other conditions

**Recommended Action:** Observe | Investigate | Fix | Restore

**Reason:** Why this recommendation

**Historical Cases:**
- YYYY-MM-DD: What happened
- Related fix: archive link or N/A

**Notes:**
- Special considerations
```

---

**Last Updated:** 2025-02-09
