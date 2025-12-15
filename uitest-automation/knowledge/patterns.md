# UITest Failure Pattern Library

> **Purpose:** Record known failure patterns to improve triage decision consistency.
> **Maintenance:** Manual editing - update when new patterns emerge or after fixes.

---

## How to Use This File

### For AI (During Phase 1 Triage):
1. Read this file when analyzing failures
2. Match test name + error message against pattern triggers
3. If matched → use pattern's recommended decision
4. If not matched → perform AI reasoning (may be new pattern)

### For Humans (Maintenance):
1. After fixing a recurring issue, consider adding pattern
2. Keep patterns concise - link to archive/ for details
3. Focus on **recognition** and **decision** - avoid duplicating full solution

---

## Pattern 1: SSO Authentication Blocked by Microsoft

**Added:** 2025-12-10
**Category:** External Service Issue
**Priority:** 🔴 High

### Identification Triggers
- **Test name matches:** `.*SSO.*` or `.*SignIn.*`
- **Error contains:** "Stay signed in?" not exist
- **Additional context:** URL `login.live.com`

### Symptoms
- All SSO tests fail simultaneously (100% failure rate)
- Error occurs during Microsoft authentication flow
- Tests timeout waiting for "Stay signed in?" dialog

### Root Causes
1. Microsoft Entra ID blocking automated login attempts
2. CI machine IP flagged as suspicious activity
3. Simulator environment detected and blocked
4. Azure AD security policy change

### Diagnostic Decision
- **Recommended action:** `investigate` (**NOT** `observe`)
- **Reasoning:** External service blocking won't self-resolve, needs visual confirmation
- **Screenshots needed:** ✅ Yes (critical - must see Microsoft error page)
- **Check docs:** `knowledge/external-dependencies.md` → Microsoft Entra ID section

### Next Steps When This Pattern Matches
1. Download screenshots to confirm Microsoft blocking page
2. Check Azure AD sign-in logs for the test account
3. Contact IT/Azure administrator
4. Options:
   - Whitelist CI IP in Azure AD conditional access
   - Use different test account
   - Update test strategy

### Historical Occurrences
| Date | Issue | Resolution | Archive Link |
|------|-------|------------|--------------|
| 2025-12-03 | Passkey dialog introduced | Added `handlePasskeyDialogIfNeeded()` | [fix-uitest-failures-2025-12-03](../../openspec/changes/archive/fix-uitest-failures-2025-12-03/) |
| 2025-12-10 | Microsoft blocking login | Observed (Day 1) | - |
| 2025-12-11 | Microsoft blocking continues | Observed (Day 2) | - |
| 2025-12-12 | Microsoft blocking continues | Screenshot evidence confirmed. Report generated: triage_report_2025-12-12.md. Awaiting IT/management decision. | - |

### Notes
- This is a **recurring pattern** with Microsoft auth changes
- Each time may have different root cause (passkey vs blocking vs policy)
- Always download screenshots - don't assume same issue as before

---

## Pattern 2: Message User Feedback Button Not Enabled

<!-- 🔮 FUTURE: Add after next occurrence or fix -->

**Status:** 🚧 Placeholder - to be documented

**Context from 2025-12-10 failure:**
- 4 tests failed: MessageUITests user feedback tests
- Error: "sendUserFeedbackButton" Button is not enabled
- Hypothesis: Backend timing, VCA message data not loaded
- Decision: observe (may be Monday backend slowness)

*If this recurs and gets fixed, document full pattern here.*

---

## Pattern 3: License Banner Not Displayed

<!-- 🔮 FUTURE: Add if becomes recurring -->

**Status:** 🚧 Placeholder - single occurrence

**Context from 2025-12-10 failure:**
- 1 test failed: test_cantDowngrade_activeLicenseExists
- Error: "License expired!" StaticText not exist
- Hypothesis: Timing or test data state
- Decision: observe

*If this recurs, document full pattern here.*

---

## Pattern 4: UAT Environment Cleanup Failure

**Added:** 2025-12-15
**Category:** Test Infrastructure
**Priority:** 🟡 Medium

### Identification Triggers
- **Error contains:** `⚠️UATButton: [button_id] execute action failed`
- **Common button IDs:** `uatDeleteOrgNUMButton`, `uatDeleteTestCameraButton`, etc.
- **Occurs at:** End of test (cleanup/teardown stage)

### Diagnostic Decision
- **Recommended action:** `environment_cleanup_required`
- **Reasoning:** NOT a test logic failure - cleanup step failed
- **Impact:** May cause subsequent tests to fail (see Pattern 5)

### Next Steps When This Pattern Matches
1. Understand: Test's main logic likely passed, only cleanup failed
2. Check for downstream failures (Pattern 5)
3. Manual cleanup: Login to UAT and delete test data
4. Re-run tests to verify

---

## Pattern 5: Environment State Residual

**Added:** 2025-12-15
**Category:** Test Infrastructure
**Priority:** 🔴 High

### Identification Triggers
- **Multiple tests using same account fail at setup stage**
- **Error indicates unexpected initial state:**
  - `"illustration_users" Image is not exist`
  - `"Email already exists"`
- **Correlation:** Previous test(s) may have Pattern 4 failure

### Diagnostic Decision
- **Recommended action:** `environment_restore_required`
- **Reasoning:** Environment not clean, NOT a code bug

### Next Steps When This Pattern Matches
1. Identify test account and residual data
2. Manual cleanup: Login to UAT and delete test data
3. Re-run tests
4. Check previous runs for Pattern 4 failures

### Historical Occurrences
| Date | Test Account | Residual Data | Resolution |
|------|--------------|---------------|------------|
| 2025-12-15 | newToVORTEX | Organization | Manual deletion |

---

## Adding New Patterns

When adding a new pattern, include:

### Required Sections:
- **Identification Triggers** - How to recognize this pattern
- **Diagnostic Decision** - What action to recommend (investigate/observe/report)
- **Next Steps** - What to do when pattern matches

### Optional But Recommended:
- **Symptoms** - Observable characteristics
- **Root Causes** - Known or suspected causes
- **Historical Occurrences** - When it happened before
- **Notes** - Any special considerations

### Template:
```markdown
## Pattern N: [Pattern Name]

**Added:** YYYY-MM-DD
**Category:** [Environment/External Service/Timing/Code Bug]
**Priority:** 🔴/🟡/🟢

### Identification Triggers
- **Test name matches:** `regex`
- **Error contains:** "error text"

### Diagnostic Decision
- **Recommended action:** investigate/observe/report
- **Reasoning:** [why]
- **Screenshots needed:** ✅/❌
- **Check docs:** [reference]

### Next Steps When This Pattern Matches
1. Step 1
2. Step 2

### Historical Occurrences
[Table or list]
```

---

## Pattern Lifecycle

### 1. New Pattern Discovered
- After fixing an issue, consider if it's likely to recur
- If yes, add pattern here

### 2. Pattern Evolves
- Update pattern if root cause changes
- Add new historical occurrence
- Adjust diagnostic decision if needed

### 3. Pattern Becomes Obsolete
- If underlying system changes and pattern no longer relevant
- Move to "Deprecated Patterns" section (create if needed)
- Keep for historical reference

---

## Tips for Pattern Maintenance

### Keep It Simple
- ✅ Focus on **recognition** (triggers) and **decision** (what to do)
- ❌ Don't duplicate full solution from archive/

### Use Links
- ✅ Link to `archive/[fix-name]/` for details
- ✅ Link to `external-dependencies.md` for context
- ❌ Don't copy-paste entire proposals

### Be Specific
- ✅ "Test name matches `MessageUITests.*UserFeedback.*`"
- ❌ "Message tests fail"

### Update Regularly
- After each fix that becomes archived
- When patterns evolve or new variations discovered
- Monthly review to remove obsolete patterns

---

**Last Updated:** 2025-12-15
