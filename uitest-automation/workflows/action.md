# Phase 4: Action

**Purpose:** Execute decisions - record observations, prepare for fixes, or record learnings.

**When:** After analysis is complete and decision has been made.

---

## Action Types

### Option 1: Observe
Record failure to observations tracker and wait for next occurrence.

### Option 2: Fix
Prepare to create OpenSpec proposal for fixing the issue.

### Option 3: Learn
Record fix experience to knowledge base for future reference.

---

## Option 1: Observe - Record to Observations

**When to use:**
- Likely transient/temporary issue
- Single occurrence, not critical
- Want to see if it repeats
- Monday morning backend slowness

**Process:**

### Step 1: Read Current Observations

```bash
cat uitest-automation/observations/active.json
```

### Step 2: Add New Observation

For each failed test to observe, add to `active.json`:

```json
{
  "id": "TestClassName.testMethodName",
  "firstSeen": "2025-12-10",
  "lastSeen": "2025-12-10",
  "occurrences": 1,
  "pattern": "UI_ELEMENT_NOT_FOUND",
  "decision": "observe",
  "expiresOn": "2025-12-12"
}
```

**Field Definitions:**
- `id`: Full test name (format: `ClassName.methodName`)
- `firstSeen`: Today's date (ISO 8601 format)
- `lastSeen`: Same as firstSeen for new observation
- `occurrences`: 1 (first time observing)
- `pattern`: Error pattern (e.g., `UI_ELEMENT_NOT_FOUND`, `TIMING_ISSUE`, `SSO_AUTH_FAILED`)
- `decision`: Always `"observe"`
- `expiresOn`: firstSeen + 2 days (observation period)

### Step 3: Update active.json

Use Edit tool to add the new observation to the `observations` array.

### Step 4: Cleanup Expired Observations

Before adding new observations, move expired ones to resolved.json:

**Logic:**
- If `expiresOn` < today → move to `resolved.json`
- Set `outcome: "transient"` (issue didn't recur)
- Set `resolvedOn: today`

**Cleanup resolved.json:**
- Remove entries older than 30 days

---

## Option 2: Fix - Prepare for OpenSpec Proposal

**When to use:**
- Root cause clear and needs code fix
- Recurring issue (found in resolved.json)
- External service permanently changed
- Test needs update

**Process:**

### Step 1: Prompt User to Use OpenSpec

```
To fix this issue, please use:
/openspec:proposal

Suggested title: fix-uitest-[brief-description]-YYYY-MM-DD

Based on the analysis:
- Root cause: [summary]
- Affected tests: [list]
- Recommended solution: [brief description]

After creating and completing the proposal, consider recording this
pattern to knowledge/patterns.md for future reference.
```

### Step 2: (Optional) Record Experience Later

After user completes `/openspec:proposal` and `/openspec:archive`:

User can say: "Record the [fix-name] pattern"

AI will help add to `knowledge/patterns.md`

---

## Option 3: Learn - Record to Knowledge Base

**When to use:**
- After fix is completed
- Pattern is likely to recur
- Want to improve future triage decisions

**Process:**

### Step 1: Extract Pattern from Fix

Ask user for the archived proposal name:

```
Which OpenSpec proposal should I learn from?
(e.g., fix-uitest-sso-blocking-2025-12-10)
```

### Step 2: Analyze Proposal

Read from `openspec/changes/archive/[proposal-name]/`:
- proposal.md - for root cause and solution
- tasks.md - for implementation details

### Step 3: Generate Pattern Draft

```markdown
## Pattern: [Name]

### Identification Triggers
- Test name regex: `.*SSO.*`
- Error contains: "Stay signed in"
- Context: login.live.com

### Diagnostic Decision
- **Action**: investigate
- **Reasoning**: External service issue, needs visual confirmation
- **Priority**: High

### Root Causes
- Microsoft Entra ID blocking automated logins
- IP flagged as suspicious
- Security policy change

### Next Steps When Matched
1. Download screenshots (confirm Microsoft error page)
2. Check Azure AD sign-in logs
3. Contact IT for whitelisting

### Related Fixes
- [fix-uitest-sso-blocking-2025-12-10](../../openspec/changes/archive/fix-uitest-sso-blocking-2025-12-10/)
```

### Step 4: Ask User Confirmation

```
Should I add this pattern to knowledge/patterns.md?

a) Yes, add now
b) Save as draft (I'll edit later)
c) No, skip
```

### Step 5: Update knowledge/patterns.md

If user confirms, append the pattern to `knowledge/patterns.md`.

---

## Recording Best Practices

### For Observations
- Be specific with pattern name (not just "ERROR")
- Record enough context to recognize if it recurs
- Set reasonable expiration (2 days is standard)

### For Patterns
- Focus on **how to recognize** the issue
- Include **diagnostic decision** (what to do)
- Link to **archive/** for details (don't duplicate content)
- Update if pattern evolves over time

---

## Examples

### Example 1: Record Observation

```
User: /analyze-uitest observe MessageUITests

AI:
Adding to observations/active.json:
{
  "id": "MessageUITests.test_userFeedbackStatusShowOnVCAMessageDetail",
  "firstSeen": "2025-12-10",
  "lastSeen": "2025-12-10",
  "occurrences": 1,
  "pattern": "BUTTON_NOT_ENABLED",
  "decision": "observe",
  "expiresOn": "2025-12-12"
}

Recorded 4 tests to observations.
Will automatically check if they recur on next CI run.
```

### Example 2: Prompt for Fix

```
User: /analyze-uitest fix

AI:
Recommended next step: Create OpenSpec proposal

Command:
/openspec:proposal

Suggested details:
- Title: fix-uitest-sso-auth-blocked-2025-12-10
- Root cause: Microsoft Entra ID blocking CI IP address
- Solution: Contact IT to whitelist IP in Azure AD conditional access
- Affected tests: 3 SSO tests

After completing the fix and archiving:
- Consider recording this pattern with: "Record sso-auth-blocked pattern"
```

### Example 3: Record Learning

```
User: Record the fix-uitest-sso-blocking-2025-12-10 pattern

AI:
[Read archive/fix-uitest-sso-blocking-2025-12-10/proposal.md]

Generated pattern:
───────────────────
## Pattern: SSO Authentication Blocked

### Identification Triggers
- Test: .*SSO.*|.*SignIn.*
- Error: "Stay signed in?" not exist
- Context: login.live.com error

[...pattern details...]
───────────────────

Add to knowledge/patterns.md? (a/b/c)

User: a

AI:
✅ Pattern added to knowledge/patterns.md
   Future triage will recognize this issue automatically.
```

---

## 💡 Tip: Handling Mixed Decisions

If different test groups need different actions:

```
User: observe for Message tests, but prepare fix for SSO tests

AI:
[Record Message tests to observations/active.json]
[Prompt for OpenSpec proposal for SSO tests]

Done:
✅ Observed: 4 Message tests
📝 Ready for fix: SSO tests (use /openspec:proposal)
```

---

**Workflow Complete!** Return to Phase 1 for next CI run or analysis.
