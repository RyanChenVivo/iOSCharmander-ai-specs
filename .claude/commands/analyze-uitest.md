# Analyze UITest Results and Create Fix Tasks

You are an expert iOS UITest analyzer. Your task is to:

1. **Fetch and analyze UITest results from CI machine**
2. **Identify failed tests and root causes**
3. **Create OpenSpec change proposals for fixes**

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

## Step 4: Verify Test Status Before Creating Proposals

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

1. **🟢 CREATE_PROPOSAL** - No existing plan, no recent fixes
2. **🟡 NEEDS_REVIEW** - Has related commits but no OpenSpec, might be fixed outside workflow
3. **🔴 SKIP_DUPLICATE** - Already has OpenSpec proposal in progress

**Only create proposals for tests marked as CREATE_PROPOSAL.**

## Step 5: Create OpenSpec Change Proposals

For each test categorized as **CREATE_PROPOSAL**, create an OpenSpec change proposal using:

```
/openspec:proposal
```

When creating the proposal:

- **Title**: `fix-uitest-{test-name}` (e.g., `fix-uitest-floor-plan-camera-selection`)
- **Type**: `fix` (since we're fixing broken tests)
- **Description**: Clearly explain:
  - Which test(s) are failing
  - What the failure symptoms are
  - Root cause analysis
  - Proposed fix approach
- **Scope**: List the affected test files
- **Testing**: Describe how to verify the fix

## Step 6: Summarize Findings

Provide a summary report:

```markdown
# UITest Analysis Summary

**Date**: {date}
**Total Tests**: {total}
**Failed**: {failed}
**Passed**: {passed}

## Failed Tests Status

### 🟢 Tests Needing New Proposals ({count})
{List tests marked as CREATE_PROPOSAL}

### 🟡 Tests Needing Review ({count})
{List tests marked as NEEDS_REVIEW with reason}

### 🔴 Tests with Existing Plans ({count})
{List tests marked as SKIP_DUPLICATE with existing proposal reference}

## Root Causes Identified

{Categorize failures by root cause}

## OpenSpec Proposals Created

{List the proposals actually created}

## Recommended Next Steps

1. Review tests marked as NEEDS_REVIEW
2. Implement fixes for created proposals
3. {Other priority actions}
```

## Important Notes

- **CI Machine Access**: The script fetches from `vivotekinc@10.15.254.191`
  - Ensure SSH key access is configured
- **Test Data**: UITests depend on specific test accounts and data in UAT environment
- **Screenshots**: Screenshots are crucial - always review them to understand visual failures
- **Timing Issues**: Many UITest failures are timing-related; look for missing waits

## Workflow

This command should be run from the **main iOSCharmander project directory**.
The script will automatically download and analyze the latest UITest results from the CI machine.
