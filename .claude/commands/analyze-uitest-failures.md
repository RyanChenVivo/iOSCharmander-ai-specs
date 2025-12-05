# Analyze UITest Failures and Create Proposal

You are tasked with analyzing UITest failures from CI and creating an OpenSpec proposal for fixes.

## Your Mission

1. **Download test data from CI** (pre-processed by Jenkins)
2. **Analyze each failed test** thoroughly
3. **Create OpenSpec proposal** with complete diagnosis

## Step 1: Download Test Data from CI

Download the pre-processed test data from CI machine:

```bash
# Download today's test data (or latest)
CI_MACHINE="vivotekinc@10.15.254.191"
CI_DATA_BASE="/Users/vivotekinc/Documents/CICD/UITestAnalysisData"
OUTPUT_DIR="$HOME/Downloads/UITestAnalysis"

# Use latest data
REMOTE_PATH="${CI_DATA_BASE}/latest"
LOCAL_OUTPUT="${OUTPUT_DIR}/latest"

# Download
mkdir -p "$OUTPUT_DIR"
rm -rf "$LOCAL_OUTPUT"
scp -r -q "${CI_MACHINE}:${REMOTE_PATH}" "$LOCAL_OUTPUT"

echo "Downloaded to: $LOCAL_OUTPUT"
```

**What you'll get:**
- `test_summary.json` - Overall test results
- `test_details.json` - Detailed info with exact line numbers
- `test_failures.json` - Failure details (only if tests failed)
- `failed_test_ids.txt` - List of failed test IDs
- `diagnostics/` - Crash logs, console output
- `attachments/` - Screenshots of failures
- `metadata.json` - Extraction metadata

## Step 2: Analyze Failures

For each failed test:

### 2.1 Read Failure Information

```bash
cd "$LOCAL_OUTPUT"

# Check if there are failures
FAILED_COUNT=$(jq -r '.failedTests' metadata.json)

if [ "$FAILED_COUNT" -eq 0 ]; then
    echo "No failures to analyze!"
    exit 0
fi

# List failed tests
cat failed_test_ids.txt
```

### 2.2 Extract Key Information

For each failed test, you need:

1. **Test name and location** (from test_details.json)
2. **Error message** (from test_failures.json)
3. **Exact line number** (from test_details.json - CRITICAL for diagnosis!)
4. **Screenshot** (from attachments/ - shows actual UI state)

Example of extracting info:

```bash
# Get detailed failure info with line numbers
jq '.testNodes[] | .. | select(.result? == "Failed") |
    {
      name: .name,
      nodeType: .nodeType,
      result: .result,
      failureMessage: .failureSummaries[0].message?,
      location: .failureSummaries[0].sourceCodeContext?.location?
    }' test_details.json
```

### 2.3 Read Test Source Code

Use the line number from test_details.json to read the exact failing code:

```bash
# Example: if failure is at LicensePhaseUITest.swift:65
# Read the test file around that line
```

### 2.4 View Failure Screenshots

Screenshots in `attachments/` show the actual UI state when test failed.

**IMPORTANT:** Screenshots are the ground truth! They show:
- What UI was actually displayed
- If expected elements exist
- Actual vs expected state

### 2.5 Search Historical Fixes

Search `openspec/archive/` for similar failures:

```bash
cd /path/to/iOSCharmander-ai-specs

# Search for similar error patterns
grep -r "error_keyword" openspec/archive/*/proposal.md

# Search for same test class
grep -r "TestClassName" openspec/archive/*/proposal.md

# Look for related changes
grep -r "UI_ELEMENT_NOT_FOUND" openspec/archive/*/proposal.md
```

If you find similar historical fixes, reference them in your proposal.

## Step 3: Create OpenSpec Proposal

Use `/openspec:proposal` to create a fix proposal:

```bash
/openspec:proposal
```

When creating the proposal, structure it like this:

### Proposal Template

```markdown
# Fix UITest Failures from CI (YYYY-MM-DD)

## Why

[Number] UITests failed in the [date] CI run ([passed] passed, [failed] failed). These failures prevent full test coverage validation and may indicate [test issues/app changes/external service changes].

## Diagnostic Process

### Sources of Information
1. **Error text from test_failures.json**: General failure message
2. **Detailed error from test_details.json**: Exact failure location with line numbers
3. **Failure screenshots**: Actual UI state at time of failure
4. **Test source code**: Expected behavior and assertion logic
5. **Historical fixes**: Reference to similar issues from archive (if any)

### Failure Analysis

#### [Test Name 1]
- **Error message**: `[exact error from test_failures.json]`
- **Location**: `[File:Line from test_details.json]`
- **Screenshot evidence**: [Describe what screenshot shows]
- **Code inspection**: [What the code at that line expects]
- **Root cause**: [Your diagnosis]
- **Fix approach**: [Proposed solution]
- **Related changes**: [Reference to archive if similar issue found]

#### [Test Name 2]
[Same structure...]

## What Changes

- Fix [test name 1]: [Brief description]
- Fix [test name 2]: [Brief description]

## Impact

- **Affected specs**: `uitests`
- **Affected code**: [List test files and line numbers]
- **Risk**: Low - test-only changes
- **User impact**: None (test infrastructure only)
```

### Key Requirements for Proposal

✅ **Include exact line numbers** from test_details.json
✅ **Describe screenshots** - what you see vs what's expected
✅ **Reference historical fixes** if you found similar issues
✅ **Clear root cause analysis** - not just "test failed"
✅ **Specific fix approach** - exactly what needs to change
✅ **Evidence-based** - every claim backed by data

## Example Diagnosis Flow

```
1. Read test_failures.json
   → Error: "StaticText 'Stay signed in?' is not exist"

2. Read test_details.json
   → Location: SigninWithSSOUITest.swift:41

3. Read test source code at line 41
   → Code expects: waitForElement("Stay signed in?")

4. View screenshot
   → Shows: Microsoft passkey dialog instead

5. Search archive
   → Found: similar SSO dialog issue in 2025-11-20 fix

6. Diagnosis
   → Root cause: Microsoft changed SSO flow
   → Fix: Add handler for passkey dialog before waiting

7. Create proposal with complete analysis
```

## Important Notes

- **Always check screenshots first** - they are ground truth
- **Use exact line numbers** - critical for fixing
- **Search archive** - avoid reinventing solutions
- **One proposal per date** - group all failures from same CI run
- **Be specific** - vague diagnosis = hard to fix

## Success Criteria

Your proposal should enable someone to:
1. Understand exactly what failed and why
2. Know exactly where to look in the code
3. Have clear steps to reproduce (if possible)
4. Implement the fix without additional investigation

## After Creating Proposal

The workflow continues:
1. Developer reviews proposal
2. Implements fixes using `/openspec:apply`
3. Tests pass on next CI run
4. Proposal archived using `/openspec:archive`
5. Knowledge accumulated for future reference

---

**Ready?** Let's analyze the failures and create a comprehensive fix proposal!
