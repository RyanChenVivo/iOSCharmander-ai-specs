# Analyze UITest Results and Create Fix Tasks

You are an expert iOS UITest analyzer. Your task is to:

1. **Fetch and analyze UITest results from CI machine**
2. **Identify failed tests and root causes**
3. **⚠️ Verify tests haven't been fixed (check git & openspec)**
4. **Create analysis report MD file**
5. **Create OpenSpec change proposals if needed**

## Step 1: Fetch UITest Results

Run the analysis script to fetch today's CI test results:

```bash
# Navigate to AI specs repo and run the script
cd ../iOSCharmander-ai-specs
./uitest-automation/analyze_uitest_failures.sh -d today
```

If the script fails, try fetching a specific date:
```bash
./uitest-automation/analyze_uitest_failures.sh -d 2025-12-03
```

## Step 2: Load Analysis Results

After the script completes, the results will be in a date-based directory.
Find the latest analysis:

```bash
# Find the most recent analysis directory
ls -lt ~/Downloads/UITestAnalysis/ | head -5
```

Then read:
1. `~/Downloads/UITestAnalysis/{DATE}/ANALYSIS_REPORT.md`
2. If there are failures:
   - `~/Downloads/UITestAnalysis/{DATE}/test_failures.json`
   - `~/Downloads/UITestAnalysis/{DATE}/test_details.json`
   - Screenshots in `~/Downloads/UITestAnalysis/{DATE}/attachments/`

## Step 3: Analyze Failures

For each failed test:

1. **Identify the test file** in `iOSCharmanderUITests/`
2. **Read the test code** to understand what it's testing
3. **Examine failure screenshots** to see the actual UI state
4. **Compare expected vs actual behavior**
5. **Determine root cause**:
   - UI element not found (identifier changed?)
   - Timing issue (element not loaded yet?)
   - Test assertion incorrect?
   - App behavior changed?
   - Test data issue?

---
**⚠️ STOP HERE** - Before proceeding to create proposals, you MUST complete Step 4 to avoid duplicate work.
---

## ⚠️ Step 4: CRITICAL - Verify Test Status Before Creating Proposals

**🛑 DO NOT SKIP THIS STEP** - Many test failures are already fixed but haven't appeared in CI yet due to timing.

**IMPORTANT**: Before creating any OpenSpec proposals, verify each failed test hasn't been fixed or doesn't already have a fix plan.

For each failed test, check:

### 4.1: Check Existing OpenSpec Proposals

```bash
# List all change proposals
openspec list:change

# Search for related proposals
openspec list:change | grep -i "uitest\|test\|{test-name}"
```

**Decision logic**:
- ✅ **No matching proposal found** → Safe to create new proposal
- ⚠️ **Found `proposal` status** → Already has fix plan, DO NOT create duplicate
- ✅ **Found `deployed` status** → Was fixed but might have regressed, safe to create new proposal

### 4.2: Check Git History

```bash
# Check commits since the test failure date
git log --since="{failure-date}" --grep="test\|uitest\|fix\|{test-name}" --oneline

# Check if test file was modified
git log --since="{failure-date}" --oneline -- "*UITests*/*{test-name}*"
```

**Decision logic**:
- If recent commits mention the test → Might be fixed, mark as "⚠️ Needs Review"
- If test file was modified → Likely being worked on, mark as "⚠️ Needs Review"
- No related commits → Safe to create proposal

### 4.3: Categorize Each Failed Test

After verification, categorize each test:

1. **⏰ FIXED_BUT_NOT_YET_TESTED** - Has recent fix commits after CI test time
2. **🔴 HAS_EXISTING_PROPOSAL** - Already has OpenSpec proposal in progress
3. **🟢 NEEDS_FIX** - No existing plan, no recent fixes, needs OpenSpec proposal

## Step 5: Create Analysis Report

Create a markdown report file in `~/Downloads/UITestAnalysis/{DATE}/CLAUDE_ANALYSIS.md` with:

```markdown
# UITest Analysis Report - {DATE}

Generated: {timestamp}

## Summary
- **Total Tests**: {total}
- **Passed**: {passed}
- **Failed**: {failed}
- **Success Rate**: {percentage}%

## Failed Tests Analysis

### ⏰ Fixed But Not Yet Tested ({count})
{List tests with recent fixes, expected to pass in next CI run}

### 🔴 Has Existing Proposal ({count})
{List tests with existing OpenSpec proposals}

### 🟢 Needs Fix ({count})
{List tests that need new OpenSpec proposals with root cause analysis}

## Comparison with Previous Run
- Fixed since last run: {list}
- New failures: {list}
- Persistent failures: {list}

## Detailed Analysis
{For each failed test, include:
- Test name and file path
- Failure message
- Root cause analysis
- Screenshots (if relevant)
- Proposed fix approach}

## Recommended Actions
{Prioritized list of next steps}
```

## Step 6: Ask User for Confirmation

After creating the analysis report, **ask the user**:

> 已完成分析報告：`~/Downloads/UITestAnalysis/{DATE}/CLAUDE_ANALYSIS.md`
>
> 發現 {N} 個測試需要修復。是否要為這些測試建立 OpenSpec change proposals？

**Wait for user confirmation before proceeding to Step 7.**

## Step 7: Create OpenSpec Change Proposals (If User Confirms)

Only proceed if user confirms. For each test categorized as **NEEDS_FIX**, create an OpenSpec change proposal using:

```
/openspec:proposal
```

When creating the proposal:

- **Title**: `fix-uitest-{test-name}` (e.g., `fix-uitest-cloud-playback-speed`)
- **Type**: `fix` (since we're fixing broken tests)
- **Description**: Clearly explain:
  - Which test(s) are failing
  - What the failure symptoms are
  - Root cause analysis
  - Proposed fix approach
- **Scope**: List the affected test files
- **Testing**: Describe how to verify the fix

## Important Notes

- **CI Machine Access**: The script fetches from `vivotekinc@10.15.254.191`
  - Ensure SSH key access is configured
- **Test Data**: UITests depend on specific test accounts and data in UAT environment
- **Screenshots**: Screenshots are crucial - always review them to understand visual failures
- **Timing Issues**: Many UITest failures are timing-related; look for missing waits

## Workflow

This command should be run from the **main iOSCharmander project directory**.
The script will automatically download and analyze the latest UITest results from the CI machine.
