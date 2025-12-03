# Analyze UITest Results and Create Fix Tasks

You are an expert iOS UITest analyzer. Your task is to:

1. **Fetch and analyze UITest results from CI machine**
2. **Identify failed tests and root causes**
3. **Create OpenSpec change proposals for fixes**

## Step 1: Fetch UITest Results

Run the analysis script to fetch today's CI test results:

```bash
# Get the script directory relative to this AI specs repo
SCRIPT_DIR="$(git rev-parse --show-toplevel)/Scripts"
$SCRIPT_DIR/analyze_uitest_failures.sh -d today
```

If the script fails, try fetching a specific date:
```bash
$SCRIPT_DIR/analyze_uitest_failures.sh -d 2025-12-03
```

## Step 2: Load Analysis Results

After the script completes, add the analysis directory to your context:

1. Read the analysis report: `~/Downloads/UITestAnalysis/ANALYSIS_REPORT.md`
2. If there are failures, read:
   - `~/Downloads/UITestAnalysis/test_failures.json`
   - `~/Downloads/UITestAnalysis/test_details.json`
   - Screenshots in `~/Downloads/UITestAnalysis/attachments/`

## Step 3: Analyze Failures

For each failed test:

1. **Identify the test file** in `{iOSCharmander}/iOSCharmanderUITests/` (use relative path from config)
2. **Read the test code** to understand what it's testing
3. **Examine failure screenshots** to see the actual UI state
4. **Compare expected vs actual behavior**
5. **Determine root cause**:
   - UI element not found (identifier changed?)
   - Timing issue (element not loaded yet?)
   - Test assertion incorrect?
   - App behavior changed?
   - Test data issue?

## Step 4: Create OpenSpec Change Proposals

For each distinct issue found, create an OpenSpec change proposal using the slash command:

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

## Step 5: Summarize Findings

Provide a summary report:

```markdown
# UITest Analysis Summary

**Date**: {date}
**Total Tests**: {total}
**Failed**: {failed}
**Passed**: {passed}

## Failed Tests

{List each failed test with brief description}

## Root Causes Identified

{Categorize failures by root cause}

## OpenSpec Proposals Created

{List the proposals created}

## Recommended Next Steps

{Priority order for fixing}
```

## Important Notes

- **CI Machine Access**: The script attempts to fetch from `vivotekinc@10.1.30.38`
  - Update the `CI_MACHINE` variable in the script if the address is different
  - Ensure SSH key access is configured
- **Test Data**: UITests depend on specific test accounts and data in UAT environment
- **Screenshots**: Screenshots are crucial - always review them to understand visual failures
- **Timing Issues**: Many UITest failures are timing-related; look for missing waits

## Example Usage

User says: "我們來看看今天UITest的狀況並且建立openspec格式的修正任務"

You should:
1. Run the analysis script
2. Load and analyze the results
3. Create OpenSpec proposals for each issue
4. Provide summary and recommendations
