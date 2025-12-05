# Analyze UITest Failures with Triage

You are tasked with analyzing UITest failures from CI, performing triage to determine if action is needed, and conditionally creating an OpenSpec proposal for fixes.

## Your Mission

1. **Download test data from CI** (lightweight JSON files only)
2. **Triage analysis** - Determine if failures need immediate attention
3. **Ask user for decision** - Create proposal, download screenshots, observe, or ignore
4. **Create OpenSpec proposal** (only if user decides to proceed)

## Step 1: Download Test Data from CI (Lightweight)

Use the download script to get JSON files only (fast, ~100KB):

```bash
cd /path/to/iOSCharmander-ai-specs/uitest-automation
./download_test_data.sh
```

**What you'll get:**
- `test_summary.json` - Overall test results
- `test_details.json` - Detailed info with exact line numbers
- `test_failures.json` - Failure details (only if tests failed)
- `failed_test_ids.txt` - List of failed test IDs
- `metadata.json` - Extraction metadata

**Note:** Screenshots and diagnostics are NOT downloaded at this stage. They can be downloaded later if needed for deeper analysis.

## Step 2: AI Triage Analysis

**IMPORTANT:** This step is performed by AI (Claude), not automated scripts. AI reads multiple sources and makes professional judgments based on context and historical knowledge.

### 2.1 Check for Failures

First, check if there are any failures to analyze:

```bash
cd "$HOME/Downloads/UITestAnalysis/latest"
jq -r '.failedTests' metadata.json
```

If 0 failures, stop here. Otherwise, proceed with triage.

### 2.2 Information Sources for Analysis

AI should read and analyze the following sources:

#### Source 1: Test Failure Data (Downloaded)
- **Location**: `$HOME/Downloads/UITestAnalysis/latest/`
- **Files**:
  - `test_failures.json` - Error messages and failure text
  - `test_details.json` - Exact line numbers and detailed test info
  - `metadata.json` - Test summary and statistics
  - `test_summary.json` - Overall results

#### Source 2: Test Source Code
- **Location**: `/path/to/iOSCharmander/iOSCharmanderUITests/`
- **Purpose**: Understand test intent and what was expected
- **How**: Use line numbers from `test_details.json` to find exact failing code

#### Source 3: External Dependencies Knowledge
- **Location**: `/path/to/iOSCharmander-ai-specs/uitest-automation/test-specs/external-dependencies.md`
- **Purpose**: Check if failure matches known external service issues
- **Key Information**:
  - Microsoft SSO known behaviors (passkey dialog, timeouts)
  - UAT Backend patterns (Monday slowness, rate limiting)
  - Device connectivity issues
  - Network and simulator limitations
  - Historical changes to external services

#### Source 4: Historical Fixes
- **Location**: `/path/to/iOSCharmander-ai-specs/openspec/archive/`
- **Purpose**: Find similar past failures and their solutions
- **How**: Search for:
  - Similar error patterns
  - Same test class names
  - Similar symptoms

### 2.3 Triage Analysis Process

For each failed test, AI should determine:

#### Step 2.3.1: Read the Failure
- Test name and identifier
- Error message from `test_failures.json`
- Exact line number from `test_details.json`

#### Step 2.3.2: Read Test Source Code
- What does the test expect?
- What assertion failed?
- What UI element or behavior is being tested?

#### Step 2.3.3: Check External Dependencies
- Does the error match a known external service issue?
- Is it Monday morning? (Backend slowness)
- Does it involve SSO? (Check for new Microsoft/Google changes)
- Could it be network or simulator-related?

#### Step 2.3.4: Search Historical Fixes
- Has this test failed before?
- Are there similar error patterns in the archive?
- What was the solution last time?

#### Step 2.3.5: Categorize the Failure

Based on analysis, categorize as:

1. **Environment Issue**
   - Simulator not starting properly
   - CI machine resource problems
   - Network connectivity issues
   - Recommendation: Usually transient, observe tomorrow

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

### 2.4 Generate Triage Report

AI should create a triage report (`triage_report.md`) containing:

```markdown
# UITest Failure Triage Report - [DATE]

## Test Summary
- Total tests: X
- Passed: Y
- Failed: Z

## Failed Tests Analysis

### Test: [TestClass/testMethod]

**Error Message:**
```
[Full error from test_failures.json]
```

**Location:** [File:Line from test_details.json]

**Test Intent:** [What the test is trying to verify]

**Failure Category:** [Environment/External Service/Timing/Code Bug/Known Issue]

**Analysis:**
- [What AI found in the test code]
- [Matches with external-dependencies.md if any]
- [Similar historical failures if any]

**Root Cause Assessment:**
[AI's professional judgment on why this failed]

**Recommendation:**
- [ ] Create OpenSpec proposal and fix
- [ ] Download screenshots for visual confirmation
- [ ] Observe tomorrow (likely transient)
- [ ] No action needed (known/acceptable issue)

---

## Overall Assessment

[Summary of all failures]

## Recommended Next Steps

[AI's recommendation based on all failures analyzed]
```

### 2.5 Screenshot Decision

Based on triage analysis, AI determines if screenshots are needed:

- **NOT needed** if: Error message is clear, matches known pattern, or clearly environmental
- **NEEDED** if: UI-related issue, unclear what happened, or visual confirmation required

If needed, provide download command:
```bash
scp -r "vivotekinc@10.15.254.191:/Users/vivotekinc/Documents/CICD/UITestAnalysisData/latest/attachments" "$HOME/Downloads/UITestAnalysis/latest/"
```

## Step 3: User Decision

After completing triage analysis and generating the report, **ASK THE USER** what they want to do next.

### Decision Options:

**Option A: Create OpenSpec Proposal**
- User wants to track and fix the issues
- Proceed to Step 4

**Option B: Download Screenshots for Further Analysis**
- Error is unclear or UI-related
- Need visual confirmation before deciding
- Download screenshots, analyze them, then return to decision

**Option C: Observe Tomorrow**
- Failure appears transient (flaky test, timing issue)
- Single occurrence, not critical
- User wants to see if it happens again

**Option D: No Action**
- Known issue already documented in external-dependencies.md
- Acceptable failure (e.g., external service down)
- Environment issue that resolved itself

### How to Ask

Present the triage report and explicitly ask:

```
Based on the triage analysis above, what would you like to do?

A) Create OpenSpec proposal to track and fix
B) Download screenshots for visual analysis
C) Observe tomorrow (wait to see if it repeats)
D) No action needed

Please choose: A, B, C, or D
```

**IMPORTANT:** Do NOT automatically proceed to create a proposal. Wait for user's explicit decision.

## Step 4: Create OpenSpec Proposal (Conditional)

**Only execute this step if user chose Option A.**

Use `/openspec:proposal` to create a fix proposal. The triage report from Step 2 contains all the necessary information - use it as the source for the proposal content.

---

**Ready?** Run the download script and start the triage analysis!
