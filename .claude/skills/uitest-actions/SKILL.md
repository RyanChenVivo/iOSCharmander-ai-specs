---
name: uitest-actions
description: >
  Use after analysis conclusion is determined. Triggers on: ready to
  record observation, ready to create fix proposal, need environment
  restoration, or want to record new pattern to knowledge base.
---

# UITest Actions

Execute follow-up actions after UITest failure analysis.

## Entry Context

**When invoked from `analyzing-uitest-failures` or `investigating-uitest`:**

| Field | Description | Required |
|-------|-------------|----------|
| test_names | Tests to process | Yes |
| error_messages | Error for each test | Yes |
| action_type | observe / fix / restore | Yes |
| batch | Whether to process as batch | No |
| root_cause | From investigation (if available) | No |

**If context missing:** Ask user which action and which test(s).

## Available Actions

- **Observe** - Record issue and wait for recurrence
- **Fix** - Prepare OpenSpec proposal to fix the issue
- **Restore** - Handle environment/account issues
- **Learn** - Record analysis experience to patterns

---

## Observe Action

Record issue to observations and wait to see if it recurs.

### When to Use
- First occurrence of an issue
- Transient/intermittent failures
- Suspected timing or network issues

### Steps

1. **Record to observations**
   - File: `uitest-automation/observations/active.json`
   - Add entry with:
     - Test name
     - Error message
     - Date observed
     - Observation period (default: 2 days)

2. **Set observation period**
   - Default: 2 days
   - Can extend for complex issues

3. **Inform user**
   - Confirm recording
   - Explain next analysis will check for recurrence

### After Completion

Check if should ask about recording learning (see Learn section).

### Batch Mode

When multiple tests need to be observed together (from Phase 0 multi-failure handling):

**Entry:** User selects "批次記錄觀察" from summary options

**Steps:**

1. **Generate batch ID**
   - Format: `obs-YYYYMMDD-batch-NNN`
   - Example: `obs-20250210-batch-001`
   - NNN increments based on existing batches for that date

2. **Record all tests in one operation**
   - Each test gets unique id: `obs-YYYYMMDD-NNN`
   - All tests share the same `batch_id`
   - All tests share the same `expires_at` (observation period)

3. **Write to active.json**
   ```json
   {
     "observations": [
       {
         "id": "obs-20250210-001",
         "batch_id": "obs-20250210-batch-001",
         "test_name": "SSO_Login",
         "error_message": "timeout on Stay signed in",
         "observed_at": "2025-02-10",
         "expires_at": "2025-02-12"
       },
       {
         "id": "obs-20250210-002",
         "batch_id": "obs-20250210-batch-001",
         "test_name": "SSO_Logout",
         "error_message": "element not found",
         "observed_at": "2025-02-10",
         "expires_at": "2025-02-12"
       }
     ]
   }
   ```

4. **Confirm to user**
   ```
   已批次記錄 N 個測試的觀察
   批次 ID: obs-YYYYMMDD-batch-NNN
   觀察期限: YYYY-MM-DD

   記錄的測試:
   • test_name_1
   • test_name_2
   • ...
   ```

**Note:** Batch mode skips the "record learning" prompt since batch observations are typically for similar/related issues.

---

## Fix Action

Route to `fixing-uitest` skill with entry context.

### When to Use
- Root cause is clear
- Issue is recurring (observation period passed)
- Deterministic and programmable issue

### Steps

1. **Package context for fixing-uitest**

   | Field | Source | Required |
   |-------|--------|----------|
   | test_names | From analysis | Yes |
   | error_messages | From analysis | Yes |
   | root_cause | From investigation | Yes |
   | screenshot_path | From investigation | No |
   | pattern_id | From patterns.md match | No |

2. **Invoke fixing-uitest skill**

   The skill handles: understanding test code, classifying fix pattern, creating OpenSpec change (opsx:ff), asking user to apply, build validation during implementation.

3. **Receive completion result**

   | Field | Description |
   |-------|-------------|
   | processed_tests | Test names that were fixed |
   | conclusion | "Fix" |
   | summary | OpenSpec change name + status |

4. **Update tracking**
   - If was under observation → close observation in `active.json`

### After Completion

Check if should ask about recording learning (see Learn section).

---

## Restore Environment Action

Handle environment configuration issues.

### When to Use
- Test account issues (locked, expired credentials)
- Residual test data from previous runs
- Configuration drift

### Steps

1. **Diagnose environment issue**
   - Account locked?
   - Credentials expired?
   - Residual data?

2. **Provide restoration steps**
   - For account issues: Credential refresh instructions
   - For residual data: UAT cleanup instructions
   - For configuration: Reset instructions

3. **Verify restoration**
   - Guide user to verify environment is clean
   - Suggest re-running affected tests

### After Completion

Check if should ask about recording learning (see Learn section).

---

## Learn Action

Record analysis experience to patterns.md for future reference.

### When to Ask About Recording

**Ask user:**
- ✅ New situation (no pattern matched during analysis)
- ✅ Recurring observation (previous judgment may have been wrong)
- ✅ During fix process, discovered new judgment rule

**Don't ask:**
- ❌ Matched known pattern (no new information to record)

### Smart Prompting Logic

```
After action completion:

Was pattern matched during analysis?
├─ Yes (known pattern) → Don't ask about learning
└─ No (new situation) → Ask: "Would you like to record this as a new pattern?"

Is this a recurring issue (seen in observations)?
├─ Yes → Ask: "This issue recurred. Should we update the pattern or record a correction?"
└─ No → Follow above logic
```

### Recording Process

1. **Ask what to record:**
   - New pattern (never seen before)
   - Correct previous judgment (observation was wrong)
   - Fix experience (learned something during fix)

2. **Guide through content:**
   - What are the trigger conditions?
   - What's the recommended action?
   - Why this recommendation?
   - Any historical context?

3. **Update patterns.md**
   - Location: `.claude/skills/analyzing-uitest-failures/references/patterns.md`
   - Use standard pattern format
   - Add historical case entry

### Pattern Template

```markdown
## pattern-id

**Trigger Conditions:**
- Error message contains "X"
- Test name matches pattern
- Other identifying conditions

**Recommended Action:** Observe | Investigate | Fix | Restore

**Reason:** Why this recommendation makes sense

**Historical Cases:**
- YYYY-MM-DD: Description of occurrence and resolution
```

---

## Action Selection Guide

| Situation | Recommended Action |
|-----------|-------------------|
| First occurrence, unclear cause | Observe |
| Recurring issue, cause now clear | Fix |
| Account/credential problem | Restore |
| Test data residual | Restore |
| External service change (programmable) | Fix |
| External service blocking (non-programmable) | Report (via reporting-uitest) |
| New failure type discovered | Learn (after other action) |

---

## Return Protocol

**Report back to `analyzing-uitest-failures`:**

| Action | Return Fields |
|--------|---------------|
| Observe | processed_tests, conclusion: "Observe", summary: "已記錄 N 筆觀察" |
| Fix | processed_tests, conclusion: "Fix", summary: "已建立 OpenSpec proposal" |
| Restore | processed_tests, conclusion: "Restore", summary: "環境已修復" / "需手動處理" |
| Learn | processed_tests, conclusion: "Learn", summary: "已新增 pattern: <id>" |

**Example:** `✓ Observe 組 - 已記錄 3 筆觀察 (obs-20250210-batch-001)`
