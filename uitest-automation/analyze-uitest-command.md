# Analyze UITest Results and Create Fix Tasks

You are an expert iOS UITest analyzer. Your task is to:

1. **Fetch and analyze UITest results from CI machine**
2. **Identify failed tests and root causes**
3. **Create OpenSpec change proposals for fixes**

## Step 1: Fetch UITest Results

Run the analysis script to fetch today's CI test results:

```bash
cd /Users/ryanchen/code/VIVOTEK/iOSCharmander-ai-specs
./uitest-automation/analyze_uitest_failures.sh -d today
```

If the script fails, try fetching a specific date:
```bash
./uitest-automation/analyze_uitest_failures.sh -d 2025-12-03
```

## Step 2: Check for Test Failures

**IMPORTANT:** Before proceeding, check if there are any test failures:

```bash
# Find the latest analysis directory
LATEST_DIR=$(ls -td ~/Downloads/UITestAnalysis/*/ | head -1)

# Check failure count
FAILED_COUNT=$(jq -r '.failedTests' "${LATEST_DIR}test_summary.json")

if [ "$FAILED_COUNT" -eq 0 ]; then
  echo "✅ All tests passed! No failures to analyze."
  exit 0
fi

echo "Found $FAILED_COUNT failed test(s). Proceeding with analysis..."
```

**Decision Point:**
- If `failedTests == 0` → **STOP HERE** and report: "All tests passed successfully! ✅ No action needed."
- If `failedTests > 0` → **Continue to Step 3**

## Step 3: Load Failure Analysis Results

After confirming there are failures, read the analysis data:

1. **Read test summary first:**
   ```bash
   cat ~/Downloads/UITestAnalysis/*/test_summary.json
   ```

2. **Read failure details:**
   - `~/Downloads/UITestAnalysis/*/test_failures.json` - Failure messages
   - `~/Downloads/UITestAnalysis/*/test_details.json` - Full test tree
   - `~/Downloads/UITestAnalysis/*/failed_test_ids.txt` - Failed test IDs

3. **Check screenshots:**
   - Look in `~/Downloads/UITestAnalysis/*/attachments/` for visual evidence

## Step 4: Search Historical Fixes (Optional but Recommended)

Before analyzing, search `openspec/archive/` for similar historical issues:

```bash
cd /Users/ryanchen/code/VIVOTEK/iOSCharmander-ai-specs

# Search by error message pattern
grep -r "StaticText is not exist" openspec/archive/*/proposal.md

# Search by test class
grep -r "AccessControlMessageUITest" openspec/archive/*/proposal.md

# Search by error pattern tag
grep -r "Error Pattern:" openspec/archive/*/proposal.md
```

If you find similar issues:
- Review the previous diagnosis and solution
- Reference the archived change in your new proposal
- Reuse successful fix strategies

## Step 5: Analyze Failures

For each failed test, follow this diagnostic process:

### 5.1 Extract Error Information (in order of detail)

1. **Read test_failures.json**: Get general error message
   - Example: `"XCTAssertTrue failed"` or `"Element not found"`
   - This may be too generic - proceed to next step

2. **Read test_details.json**: Get **exact failure location with line numbers**
   - Look for the failed test's detail node
   - Extract the detailed error: e.g., `"LicensePhaseUITest.swift:65: XCTAssertTrue failed"`
   - **This is crucial** - it tells you exactly which line failed

3. **Examine failure screenshots**: See the actual UI state at time of failure
   - Find screenshots in `attachments/` directory
   - Use `manifest.json` to match screenshots to failed test
   - Screenshot shows ground truth of what the UI looked like

4. **Read test source code**: Understand the test logic
   - Identify the test file in `/Users/ryanchen/code/VIVOTEK/iOSCharmander/iOSCharmanderUITests/`
   - Go to the exact line number from step 2
   - Understand what the assertion is checking
   - Read surrounding code for context

### 5.2 Determine Root Cause

Compare all evidence sources:
- **Error message** (what failed)
- **Line number** (where it failed)
- **Screenshot** (UI state when it failed)
- **Test code** (what was expected)

Common root causes:
   - **UI element not found**: Identifier changed? Element not displayed? Wrong timing?
   - **Assertion mismatch**: Test expects wrong value (e.g., wrong banner style)
   - **Timing issue**: Element not loaded yet? Animation not complete?
   - **App behavior changed**: Feature updated but test not updated?
   - **Test data issue**: UAT environment data changed?
   - **External dependency**: SSO provider changed UI? API response different?

### 5.3 Verify Root Cause

1. Read related app source code to confirm expected behavior
2. Check if test expectations match actual implementation
3. Look for recent changes in git history that might explain the failure
4. Check historical patterns in Step 4 - have we seen this before?

## Step 6: Create OpenSpec Change Proposals

For each distinct issue found, create an OpenSpec change proposal using the slash command:

```
/openspec:proposal
```

When creating the proposal:

- **Title**: `fix-uitest-{test-name}` (e.g., `fix-uitest-access-control-door-status`)
- **Type**: `fix` (since we're fixing broken tests)
- **Description Template**:
  ```markdown
  ## Test Failure Analysis

  **Failed Test:** {TestClass}/{testMethod}
  **Error Message:** {from test_failures.json}
  **Error Pattern:** {UI_ELEMENT_NOT_FOUND | ASSERTION_FAILED | EXTERNAL_CHANGE | TIMING_ISSUE}
  **Screenshots:** {list attachment paths}

  ## Root Cause
  {Your analysis based on test code, screenshots, and error messages}

  ## Historical Context
  {If found similar issue in archive, reference it here}
  **Related Changes:** {link to openspec/archive/similar-change/}

  ## Proposed Solution
  {How to fix the test}

  ## Prevention
  {How to avoid similar issues in the future}
  ```
- **Scope**: List the affected test files
- **Testing**: Describe how to verify the fix

**Important:** Include enough diagnostic information so that when this proposal is archived, it becomes a useful reference for future similar issues.

## Step 7: Summarize Findings

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
