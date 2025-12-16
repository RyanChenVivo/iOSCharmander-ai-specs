# Phase 1: Triage

**Purpose:** Download test data, perform initial analysis, and recommend next steps.

**When:** Always the first step when analyzing UITest failures.

---

## Step 1: Download Test Data (Lightweight)

Use the download script to get JSON files only (fast, ~100KB):

```bash
cd /Users/ryanchen/code/XcodeFile/iOSCharmander-ai-specs/uitest-automation
./download_test_data.sh
```

**What you'll get:**
- `test_summary.json` - Overall test results
- `test_details.json` - Detailed info with exact line numbers
- `test_failures.json` - Failure details (only if tests failed)
- `failed_test_ids.txt` - List of failed test IDs
- `metadata.json` - Extraction metadata

**Note:** Screenshots and diagnostics are NOT downloaded at this stage. They can be downloaded later in Phase 2 if needed.

---

## Step 2: Check for Failures

First, check if there are any failures to analyze:

```bash
cd "$HOME/Downloads/UITestAnalysis/latest"
jq -r '.failedTests' metadata.json
```

If 0 failures → stop here and report success ✅

Otherwise → proceed with analysis

---

## Step 3: Update Observation Status

**Purpose:** Check if tests currently under observation have changed status today (passed/failed).

Before analyzing new failures, update the status of tests we're already observing.

### 3.1: Read Current Observations

```bash
cat uitest-automation/observations/active.json
```

Check `expiresOn` dates - any observations past their expiration date should be processed.

### 3.2: Compare with Today's Results

For each test in `active.json`:

**If the test is NOT in today's failures:**
- ✅ The test **passed** today
- **Action**: Move to `resolved.json` with `outcome: "transient"`
- **Note**: Record that it was resolved after observation

**If the test IS in today's failures:**
- ❌ The test **failed again** today
- **Action**: Update `lastSeen` to today's date
- **Action**: Increment `occurrences` count
- **Decision**:
  - If `occurrences >= 3` → Consider escalating from "observe" to "investigate"
  - If still within observation period → Keep observing
  - If past `expiresOn` → Escalate to "investigate" or "fix"

### 3.3: Update Files

**Update `active.json`:**
- Remove tests that passed today
- Update `lastSeen` and `occurrences` for tests that failed again
- Update `decision` if escalation needed

**Update `resolved.json`:**
- Add newly resolved tests with:
  - `resolvedOn`: today's date
  - `outcome`: "transient" (if it self-resolved)
  - `notes`: Summary of observation period and outcome

### 3.4: Report Observation Updates

When presenting findings (Step 6), include a summary:

**Example:**
```
📊 Observation Status Update:
- ✅ AIControlSettingUITest.testSPSLPRNotConfigure passed today → Moved to resolved (transient)
- ❌ MessageAlarmUITest.testPauseAlarm failed again (occurrences: 2) → Continue observing
```

### Important Notes:

- **Do this BEFORE analyzing new failures** - it provides context
- **Keep it brief** - detailed updates can be done after presenting findings
- **Flag escalations** - if an observed test needs to escalate, mention it prominently

---

## Step 4: Information Sources for Analysis

AI should read and analyze the following sources:

### Source 1: Test Failure Data (Downloaded)
- **Location**: `$HOME/Downloads/UITestAnalysis/latest/`
- **Files**:
  - `test_failures.json` - Error messages and failure text
  - `test_details.json` - Exact line numbers and detailed test info
  - `metadata.json` - Test summary and statistics
  - `test_summary.json` - Overall results

### Source 2: Test Source Code
- **Location**: `/Users/ryanchen/code/XcodeFile/iOScharmander/iOSCharmanderUITests/`
- **Purpose**: Understand test intent and what was expected
- **How**: Use line numbers from `test_details.json` to find exact failing code

### Source 3: External Dependencies Knowledge
- **Location**: `uitest-automation/knowledge/external-dependencies.md`
- **Purpose**: Check if failure matches known external service issues
- **Key Information**:
  - Microsoft SSO known behaviors (passkey dialog, timeouts)
  - UAT Backend patterns (Monday slowness, rate limiting)
  - Device connectivity issues
  - Network and simulator limitations
  - Historical changes to external services

### Source 4: Historical Fixes
- **Location**: `openspec/changes/archive/`
- **Purpose**: Find similar past failures and their solutions
- **How**: Search for:
  - Similar error patterns
  - Same test class names
  - Similar symptoms

### Source 5: Observation Tracker
- **Location**: `uitest-automation/observations/`
- **Files**:
  - `active.json` - Currently observing issues (< 5 records typically)
  - `resolved.json` - Recently resolved observations (30-day retention)
- **Purpose**: Check if this failure is already under observation or was previously observed
- **How**:
  - Check `active.json` for ongoing observations
  - Check `resolved.json` for issues that recurred after being marked as transient

### Source 6: Failure Pattern Library
- **Location**: `uitest-automation/knowledge/patterns.md`
- **Purpose**: Match against known failure patterns for consistent decisions
- **How**:
  - Read pattern definitions
  - Match test name + error message against triggers
  - If matched → use pattern's recommended decision
  - If not matched → AI reasoning (mark as potential new pattern)

---

## Step 5: Triage Analysis Process

For each failed test, AI should determine:

### 5.1: Read the Failure
- Test name and identifier
- Error message from `test_failures.json`
- Exact line number from `test_details.json`

### 5.2: Read Test Source Code
- What does the test expect?
- What assertion failed?
- What UI element or behavior is being tested?

### 5.3: Check External Dependencies
- Does the error match a known external service issue?
- Is it Monday morning? (Backend slowness)
- Does it involve SSO? (Check for new Microsoft/Google changes)
- Could it be network or simulator-related?

### 5.4: Search Historical Fixes and Observations

**Search `knowledge/patterns.md`:**
- Does this match a known pattern?
- What decision does the pattern recommend?

**Search `openspec/changes/archive/`:**
- Has this test been fixed before?
- Are there similar error patterns in the archive?
- What was the solution last time?

**Search `observations/active.json`:**
- Is this test currently under observation?
- When did it first fail?
- How many times has it failed?

**Search `observations/resolved.json`:**
- Was this test previously observed and resolved?
- Was it marked as "transient" (temporary issue)?
- Is this a recurrence of a previously resolved issue?

**Critical Pattern:** If found in `resolved.json` → This is NOT a first-time issue → Recommend fix instead of observe

### 5.5: Categorize the Failure

Based on analysis, categorize as:

1. **Environment Issue**
   - Simulator not starting properly
   - CI machine resource problems
   - Network connectivity issues
   - Recommendation: Usually transient, observe

2. **External Service Issue**
   - Microsoft SSO changed behavior
   - Backend API timeout or down
   - Device offline
   - Recommendation: Check external-dependencies.md, may need test update

3. **Timing/Flaky Test**
   - Race condition
   - Insufficient wait time
   - Network delay
   - Recommendation: If happens once, observe. If consistent, needs fix.

4. **Real Code/Test Bug**
   - Assertion logic wrong
   - App behavior changed
   - UI element changed
   - Recommendation: Needs investigation and fix

5. **Known Issue**
   - Already documented in external-dependencies.md
   - Acceptable failure
   - Recommendation: May not need action

---

## Step 6: Present Initial Findings

AI should present findings verbally (NOT as formal report yet).

**Format:** Brief summary including:

1. **Observation Status Updates** (from Step 3)
   - Which observed tests passed today (moved to resolved)
   - Which observed tests failed again (updated counts)
   - Any escalations needed

2. **New Failure Analysis** (for each failed test group)
   - Test names and error messages
   - Initial categorization (Environment/Service/Timing/Bug/Known)
   - Root cause hypothesis
   - Preliminary recommendation (investigate/observe/report/ignore)

**Example Presentation:**
```
📊 Observation Status Update:
- ✅ AIControlSettingUITest.testSPSLPRNotConfigure passed today → Moved to resolved (transient)
- ❌ MessageAlarmUITest.testPauseAlarm failed again (occurrences: 2) → Continue observing

📋 New Failures Analysis:
[Present each failure group as usual]
```

**Important:**
- **Always start with observation updates** - it provides context
- Keep it concise and conversational
- Focus on helping user decide next action
- Reserve detailed formal report for Phase 3 (if needed)
- Mention if screenshots would be helpful for better diagnosis

---

## Step 7: Recommend Next Steps

Based on triage analysis, provide recommendations:

### Recommendation Logic:

**If no failures:**
→ Report success, done ✅

**If failures are clear and simple:**
→ Recommend Phase 4 (observe)

**If failures need visual confirmation (UI-related):**
→ Recommend Phase 2 (investigate)

**If failures are complex or need management decision:**
→ Recommend Phase 2 (investigate) → then Phase 3 (report)

**If multiple groups with different priorities:**
→ Recommend handling each group differently
→ Example: "Investigate high-priority group, observe low-priority"

---

## User Decision Options

After presenting findings, ask the user what they want to do:

```
Based on the triage analysis above, what would you like to do?

A) Create OpenSpec proposal to track and fix
B) Download screenshots for visual analysis (Phase 2)
C) Observe tomorrow (wait to see if it repeats)
D) No action needed
E) Generate detailed triage report for management (Phase 3)

Please choose: A, B, C, D, or E
```

**IMPORTANT:** Do NOT automatically proceed. Wait for user's explicit decision.

---

## Examples

### Example 1: All Pass
```
[Download data]
→ metadata.json shows: failedTests: 0
→ AI: "All 120 tests passed ✅ No further action needed."
```

### Example 2: Single Simple Failure
```
[Download data]
→ 1 failure: NetworkTimeoutTest
→ Error: "Request timeout after 30s"
→ Check patterns.md: No match
→ Check external-dependencies.md: Known UAT backend slowness
→ Check day: Monday morning
→ AI: "Found 1 failure - NetworkTimeoutTest
      Category: External Service (Monday backend slowness)
      Recommendation: observe

      What would you like to do? (A/B/C/D/E)"
```

### Example 3: Multiple Groups (Today's Case)
```
[Download data]
→ 8 failures in 3 groups

[Check patterns.md]
→ Group 1 (SSO) matches pattern: "SSO Authentication Issues"
  → Pattern says: investigate (need screenshots)

→ Group 2 (Message) no match
  → AI reasoning: Backend timing issue
  → Recommendation: observe

→ Group 3 (License) no match
  → AI reasoning: Single test, likely transient
  → Recommendation: observe

[Present findings]
→ AI: "Found 8 failures in 3 groups:

      Group 1 (SSO, 3 tests) - 🔴 High Priority
        Matched pattern: SSO Authentication Issues
        Error: 'Stay signed in?' not found
        Recommendation: investigate (need screenshots to confirm)

      Group 2 (Message, 4 tests) - 🟡 Medium Priority
        Error: Button not enabled
        Possible cause: Backend timing
        Recommendation: observe

      Group 3 (License, 1 test) - 🟢 Low Priority
        Error: Banner not shown
        Single test, likely transient
        Recommendation: observe

      Overall recommendation:
      - Start with B) investigate for SSO group
      - After investigation, consider E) report

      What would you like to do? (A/B/C/D/E)"
```

---

**Next Phase:** Based on user choice, proceed to Phase 2, 3, or 4.
