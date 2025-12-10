# UITest Failure Decision Tree

> **Purpose:** Guide decision-making during Phase 1 triage analysis.
> **For:** AI agents and human developers performing failure analysis.

---

## Overview

This decision tree helps determine the appropriate next action after analyzing a UITest failure. It complements `patterns.md` by providing structured decision logic when no pattern matches.

**Decision Sequence:**
1. Check if failure matches a known pattern (`patterns.md`)
2. If matched → Use pattern's recommended decision
3. If not matched → Use this decision tree
4. Consider recording new pattern if issue recurs

---

## Decision Criteria

### Factor 1: Failure Count and Scope

**Single Test Failed (1 failure)**
- → Likely transient or edge case
- → Default: **observe** (unless critical path test)

**Test Group Failed (2-5 related tests)**
- → Possible systematic issue
- → Check if tests share common dependency
- → Default: **investigate** if unclear, **observe** if timing-related

**Many Tests Failed (6+ tests)**
- → Likely environmental or service issue
- → Check day/time (Monday mornings?)
- → Default: **investigate** to understand scope

---

### Factor 2: Error Type

**UI Element Not Found**
```
Error contains: "not exist", "not found", "no match"
```
**Decision Path:**
- Is this a new UI? → **investigate** (may need test update)
- Is this external UI (SSO, etc.)? → **investigate** (screenshot needed)
- Is this stable UI? → **observe** (may be timing)

**Timeout / Timing Issue**
```
Error contains: "timeout", "wait", "delayed"
```
**Decision Path:**
- Check day/time → Monday morning? → **observe**
- Check external dependency → Backend slow? → **observe**
- Check timeout duration → Too short? → **fix** (increase timeout)
- Consistent timeout? → **investigate**

**Assertion Failed**
```
Error contains: "XCTAssert", "expected", "actual"
```
**Decision Path:**
- Data mismatch? → Check test data setup → **investigate**
- UI state wrong? → Need screenshot → **investigate**
- Logic error? → Code bug → **fix**

**Button/Control Not Enabled**
```
Error contains: "not enabled", "disabled"
```
**Decision Path:**
- Check prerequisites → Data loaded? → **observe** (backend timing)
- Check UI state → Need screenshot → **investigate**
- Consistent failure? → **fix** (add proper wait or fix test)

**External Service Error**
```
Error contains: "login.live.com", "google.com", service URLs
Context: SSO, authentication, third-party
```
**Decision Path:**
- Always → **investigate** (need screenshot confirmation)
- Check `external-dependencies.md` for known issues
- Likely → **report** (may need IT/admin help)

---

### Factor 3: Test History

**First-Time Failure (new failure)**
- Not in `observations/active.json`
- Not in `observations/resolved.json`
- → Default: **observe** (unless critical or external service)

**Recurring Failure (observed before)**
- Found in `observations/active.json` with occurrences ≥ 2
- → **Do NOT observe again**
- → **investigate** or **fix** (issue is not transient)

**Previously Resolved (recurrence)**
- Found in `observations/resolved.json` with outcome="transient"
- → Issue came back → NOT transient
- → **investigate** or **fix** (requires permanent solution)

**Fixed Before (historical fix)**
- Similar error found in `openspec/changes/archive/`
- → Check if same root cause
- → May need similar fix or test update
- → **investigate** to confirm, then **fix**

---

### Factor 4: Day/Time Context

**Monday Morning (8 AM - 11 AM)**
- Backend services may be slow (weekend restart)
- → Timing/timeout errors → **observe**
- → Will likely pass on next run

**Friday Afternoon (4 PM - 6 PM)**
- Less likely environmental
- → Treat as normal failure
- → Follow standard decision path

**After Deployment**
- Check if app/backend was deployed recently
- → May be related to deployment
- → **investigate** (possible regression)

**After External Service Change**
- Check `external-dependencies.md` for recent changes
- → Microsoft/Google updated auth flow?
- → **investigate** with screenshots

---

### Factor 5: Test Category

**Critical Path Test**
```
Tests: Login, Payment, Core Features
```
- → Always **investigate** (even single failure)
- → High business impact

**Regression Test**
```
Tests: Previously fixed bugs
```
- → If fails → Regression detected
- → **fix** immediately (bug came back)

**Edge Case Test**
```
Tests: Rare scenarios, boundary conditions
```
- → Single failure → **observe**
- → Repeated failure → **fix**

**External Integration Test**
```
Tests: SSO, third-party APIs
```
- → Always **investigate** (screenshot needed)
- → Check `external-dependencies.md`

---

## Decision Matrix

| Scenario | Failure Count | Error Type | History | Decision |
|----------|---------------|------------|---------|----------|
| Monday timeout | 1-5 | Timeout | First-time | **observe** |
| Monday timeout | 1-5 | Timeout | Recurring | **fix** (not transient) |
| SSO error | Any | Element not found | Any | **investigate** → **report** |
| Button disabled | 1 | Not enabled | First-time | **observe** |
| Button disabled | 1 | Not enabled | Recurring | **investigate** → **fix** |
| Critical path | 1 | Any | Any | **investigate** |
| Edge case | 1 | Any | First-time | **observe** |
| Many tests | 6+ | Any | Any | **investigate** (scope analysis) |
| Assertion fail | 1-3 | Assert | Any | **investigate** |
| Post-deployment | Any | Any | Any | **investigate** |

---

## Action Definitions

### observe
**When:** Likely transient, want to see if it repeats
**Action:** Record to `observations/active.json` (Phase 4)
**Timeline:** Check after next CI run (1-2 days)
**Outcome:** If doesn't recur → mark resolved. If recurs → escalate to **fix**

### investigate
**When:** Need visual confirmation or more evidence
**Action:** Download screenshots (Phase 2)
**Timeline:** Immediate (same day)
**Outcome:** After investigation → decide **fix** or **observe** or **report**

### fix
**When:** Root cause clear, needs code change
**Action:** Prompt for `/openspec:proposal` (Phase 4)
**Timeline:** Depends on priority (1-5 days)
**Outcome:** Create proposal → implement → archive → record pattern

### report
**When:** Needs management decision or external help
**Action:** Generate formal report (Phase 3)
**Timeline:** Immediate (same day)
**Outcome:** Management decides on action

---

## Examples

### Example 1: Single Monday Timeout

```
Input:
- Test: NetworkRequestTest
- Error: "Timeout after 30s"
- Day: Monday 9:00 AM
- History: First-time failure

Decision Path:
1. Check patterns.md → No match
2. Factor 1 (count): 1 failure → Lean toward observe
3. Factor 2 (type): Timeout → Check timing
4. Factor 4 (day): Monday morning → Backend slow likely
5. Factor 3 (history): First-time → observe

Result: **observe**
Action: Record to observations/active.json, expires in 2 days
```

### Example 2: SSO Error with "Stay signed in?" Missing

```
Input:
- Tests: 3 SSO tests
- Error: "Stay signed in?" not exist
- Context: login.live.com
- History: Similar issue fixed 2025-12-03

Decision Path:
1. Check patterns.md → MATCH: Pattern 1 (SSO Authentication Blocked)
2. Pattern says: **investigate** (NOT observe)
3. Pattern says: Screenshot needed (critical)

Result: **investigate** (download screenshots)
Next: After screenshot analysis → **report** (needs IT help)
```

### Example 3: Button Not Enabled (First Time)

```
Input:
- Tests: 4 user feedback tests
- Error: "sendUserFeedbackButton not enabled"
- Day: Monday 8:30 AM
- History: First-time failure

Decision Path:
1. Check patterns.md → No match (Pattern 2 is placeholder)
2. Factor 1 (count): 4 related tests → Systematic issue
3. Factor 2 (type): Not enabled → Backend timing likely
4. Factor 4 (day): Monday morning → Backend slow
5. Factor 3 (history): First-time → observe

Result: **observe**
Action: Record to observations/active.json
Note: If recurs, escalate to **investigate** (will become Pattern 2)
```

### Example 4: Button Not Enabled (Recurring)

```
Input:
- Tests: 4 user feedback tests
- Error: "sendUserFeedbackButton not enabled"
- Day: Tuesday 2:00 PM
- History: Found in observations/active.json with 2 occurrences

Decision Path:
1. Factor 3 (history): Recurring → Do NOT observe again
2. Factor 2 (type): Not enabled → Need to see UI state
3. NOT Monday → Not likely backend slow

Result: **investigate** (download screenshots)
Next: After investigation → **fix** (create OpenSpec proposal)
Pattern: Consider recording as Pattern 2
```

### Example 5: Critical Path Regression

```
Input:
- Test: PaymentUITest.testCheckout
- Error: "Pay button not found"
- History: Archive shows similar fix in 2025-11-20
- Category: Critical path

Decision Path:
1. Factor 5 (category): Critical path → Always investigate
2. Factor 3 (history): Fixed before → Possible regression
3. Factor 2 (type): Element not found → UI changed?

Result: **investigate** immediately
Priority: 🔴 High (critical path)
Next: After investigation → **fix** (regression needs urgent fix)
```

---

## Special Cases

### Mixed Failure Groups

When failures fall into different categories, handle separately:

**Example from 2025-12-10:**
- Group 1 (SSO): 3 tests → Pattern match → **investigate**
- Group 2 (Message): 4 tests → Monday morning → **observe**
- Group 3 (License): 1 test → First-time → **observe**

**Recommendation:**
- Present options separately for each group
- User can choose mixed approach: "B for SSO, C for others"

### Unknown Error Type

If error message is unclear or ambiguous:
1. **Always investigate** (download screenshots)
2. After visual analysis → re-evaluate
3. May discover new pattern → document

### Environmental Issues

If multiple unrelated tests fail:
- Likely simulator/CI machine issue
- **observe** first (may self-resolve)
- If persists → Check CI infrastructure

---

## Integration with Patterns

**Before using this tree:**
1. Always check `patterns.md` first
2. If failure matches pattern → use pattern's decision
3. Pattern decisions override general tree logic

**After using this tree:**
1. If issue recurs and gets fixed → consider adding to `patterns.md`
2. Phase 4 action workflow will prompt for pattern recording

---

## Updates and Maintenance

**When to update:**
- When decision criteria change
- When new failure categories emerge
- When team's risk tolerance changes

**Update process:**
- Discuss with team
- Update decision matrix
- Add examples for new scenarios

---

**Last Updated:** 2025-12-10
**Next Review:** After 5 failure analyses or 1 month
