---
name: uitest-actions
description: >
  Execute UITest analysis follow-up actions. Includes: observation recording
  (observe), prepare fix (fix), restore environment (restore), and record
  learnings (learn). Executes corresponding flow based on analysis conclusion.
---

# UITest Actions

Execute follow-up actions after UITest failure analysis.

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

---

## Fix Action

Prepare to fix the issue via OpenSpec proposal.

### When to Use
- Root cause is clear
- Issue is recurring (observation period passed)
- Deterministic and programmable issue

### Steps

1. **Create OpenSpec proposal**
   - Use `/openspec:proposal` or `/opsx:new`
   - Include analysis findings
   - Reference screenshots if available

2. **After fix complete**
   - Check if should record learning (see Learn section)

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
