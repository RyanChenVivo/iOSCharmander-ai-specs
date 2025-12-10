# Phase 2: Investigate

**Purpose:** Download screenshots, perform visual analysis, and confirm root cause.

**When:** When Phase 1 triage suggests investigation is needed (unclear errors, UI-related issues).

---

## When to Use Phase 2

Use investigation when:
- ❓ Root cause unclear from error message alone
- 🖼️ UI-related failures (need to see what user sees)
- 🔍 Need visual confirmation before concluding
- 📊 Multiple theories, need evidence to decide

**Do NOT use** when:
- Error message is clear and matches known pattern
- Obviously environmental (network timeout, etc.)
- Already have enough information to decide

---

## Step 1: Download Screenshots and Diagnostics

If screenshots aren't already downloaded, use:

```bash
scp -r "vivotekinc@10.15.254.191:/Users/vivotekinc/Documents/CICD/UITestAnalysisData/latest/attachments" "$HOME/Downloads/UITestAnalysis/latest/"
```

**What you'll get:**
- Screenshots (.png) - UI state at failure time
- Diagnostics (.txt) - System logs and debug info
- Size: ~100MB-500MB (can be large)

**Note:** This downloads ALL attachments. If only specific tests need investigation, you can be selective.

---

## Step 2: Locate Relevant Screenshots

Screenshots are named by UUID, so need to find which belong to failed tests.

**Method 1: By timestamp**
- Screenshots are sorted by modification time
- Failed tests typically have screenshots near end of test run
- Use `ls -lt` to see most recent

**Method 2: By content inspection**
- Read screenshots with Read tool
- Look for UI that matches test context
- Example: SSO tests → look for login.live.com screenshots

**Method 3: Check largest files**
- Full-screen captures are usually larger
- `ls -lhS *.png | head -20` shows largest first

---

## Step 3: Visual Analysis

For each relevant screenshot, analyze:

### 3.1: What is Shown?
- What page/screen is displayed?
- What UI elements are visible?
- Any error messages on screen?

### 3.2: Compare with Expected
- What did the test expect to see?
- What UI element was it looking for?
- Is the element present but different?
- Or completely missing?

### 3.3: Identify Root Cause
- **UI Change**: Element moved, renamed, or removed
- **External Service**: Error page from third-party (Microsoft, Google)
- **Timing**: Loading indicator still showing
- **Data**: Empty state, missing data
- **Environment**: Simulator issue, permission dialog

---

## Step 4: Document Findings

Update analysis with visual evidence:

**Format:**
```
Screenshot Evidence:
- File: E0B38529-D0E1-48D8-ABC2-2703BDBE05CD.png
- Shows: login.live.com error page
- Message: "Please retry with a different device or other authentication method"
- Root Cause: Microsoft blocking automated login attempts

Confirmed: This is NOT a test code issue, but Microsoft service blocking.
```

---

## Step 5: Update Recommendations

Based on visual evidence, update recommendations:

**If root cause confirmed:**
→ Recommend next action (report/fix/observe)

**If still unclear:**
→ May need to check more screenshots or consult team

**Example:**
```
Initial hypothesis: SSO flow changed
Visual confirmation: Microsoft error page blocking login
Updated recommendation:
  - generate report (needs IT/Azure admin)
  - NOT suitable for observe (won't self-resolve)
```

---

## Common Investigation Patterns

### Pattern 1: External Service Error Page

**Screenshot shows:** Error page from external service (Microsoft, Google, etc.)

**Analysis:**
- Read error message carefully
- Check external-dependencies.md for known issues
- Check if service status page shows outage

**Decision:**
- If known issue → document and observe
- If new issue → investigate, report, likely needs external fix

---

### Pattern 2: UI Element Moved/Changed

**Screenshot shows:** UI exists but element not where test expects

**Analysis:**
- Compare screenshot with test code expectations
- Check if recent UI refactoring occurred
- Look for element with different accessibility ID

**Decision:**
- Needs test update to match new UI
- create OpenSpec proposal

---

### Pattern 3: Loading/Timing Issue

**Screenshot shows:** Loading indicator, empty state, or partial load

**Analysis:**
- Check test timeout settings
- Check if backend is slow (Monday mornings?)
- Look for network issues

**Decision:**
- If timeout too short → fix test timing
- If backend slow → observe or increase timeout
- If flaky → needs retry logic

---

### Pattern 4: Data Issue

**Screenshot shows:** Empty list, missing content, wrong data

**Analysis:**
- Check test data setup
- Check if backend state is correct
- Look for test isolation issues

**Decision:**
- Fix test data setup
- Check backend/UAT environment

---

## Examples

### Example 1: Microsoft SSO Blocking (Today's Case)

```
User: /analyze-uitest investigate

AI:
[Download screenshots...]

[Check recent PNGs]
Found: E0B38529-D0E1-48D8-ABC2-2703BDBE05CD.png

[Read screenshot]
Shows:
- URL: login.live.com
- Error message: "Please retry with a different device or other authentication method to sign in"

Analysis:
- This is Microsoft's blocking page
- NOT a test issue
- NOT a UI change
- External service actively blocking CI

Confirmed Root Cause:
- Microsoft Entra ID security policy blocking simulator/automated logins
- Likely IP-based or behavior-based blocking

Recommendation:
- generate report for management
- Needs IT/Azure admin intervention
- Whitelisting or different test account needed

Updated decision: This is NOT suitable for "observe" - external service won't self-resolve.

What would you like to do next?
E) Generate report
A) Create OpenSpec proposal
```

---

### Example 2: UI Element Not Found

```
User: /analyze-uitest investigate

AI:
[Download screenshots...]
[Find relevant screenshot]

Screenshot shows:
- Payment screen displayed correctly
- But "Pay Now" button has different label: "Complete Payment"

Analysis:
- UI refactoring changed button text
- Test still looking for old "Pay Now" text
- Functionality still works, just label changed

Root Cause:
- Test needs update to match new button label

Recommendation:
A) Create OpenSpec proposal to update test
```

---

**Next Phase:** Based on findings, user can proceed to Phase 3 (report) or Phase 4 (action).
