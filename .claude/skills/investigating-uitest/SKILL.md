---
name: investigating-uitest
description: >
  Visual analysis of UITest failure screenshots. Use when screenshots need
  to be downloaded for detailed analysis. Determines failure cause based on
  screenshots: external service changes, code changes, or environment issues.
---

# UITest Visual Analysis

Perform visual analysis of UITest failure screenshots to determine root cause.

## When to Use

- Root cause unclear from error messages alone
- Need visual confirmation of UI state
- "Element not found" errors that could have multiple causes
- Recommended by `analyzing-uitest-failures` skill

## Download Screenshots

### Download Command

```bash
uitest-automation/scripts/download_uitest_data.sh --screenshots
```

### File Location

Screenshots are downloaded to:
```
$HOME/Downloads/UITestAnalysis/latest/attachments/
```

### Finding Relevant Screenshots

Screenshots are named by UUID. Use these methods to find relevant ones:

#### Method 1: Via manifest.json (Recommended)

The `manifest.json` file maps test identifiers to their attachments:

```bash
# Find all attachments for a specific failed test
cat attachments/manifest.json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for entry in data:
    if 'TEST_NAME_HERE' in entry.get('testIdentifier', ''):
        for att in entry.get('attachments', []):
            print(f\"{att.get('exportedFileName')} - {att.get('suggestedHumanReadableName')} - failure: {att.get('isAssociatedWithFailure')}\")
"
```

Key attachment types in manifest:
- `*.png` - Screenshots captured during test
- `*.txt` with "App UI hierarchy" - UI element tree at that moment
- `*.txt` with "Debug description" - Element details
- `*.mp4` - Screen recordings
- Files without extension - Synthesized events (tap, swipe, etc.)

#### Method 2: By timestamp/size

- **By timestamp:** `ls -lt attachments/*.png | head -20`
- **By size:** `ls -lhS attachments/*.png | head -20` (full-screen captures are larger)
- **By date:** `ls -lt attachments/*.png | grep "月  日"` (filter by specific date)

#### Method 3: By content

Read screenshots with Read tool, look for UI matching test context.

## Phase 2 Decision Flow

### Step 0: Understand the Test (Do This First!)

Before looking at screenshots, read the test source code:

1. **Find the test file:**
   ```bash
   grep -r "FAILED_TEST_NAME" --include="*.swift" iOSCharmanderUITests/
   ```

2. **Read the test function** and understand:
   - What screens it navigates to
   - What elements it expects to find (accessibility identifiers)
   - The sequence of operations
   - Any helper functions it calls

3. **Trace helper functions** to understand exact assertions:
   ```bash
   # Example: if test calls checkCanReportFalseAlarm()
   grep -A 20 "func checkCanReportFalseAlarm" iOSCharmanderUITests/
   ```

This context is essential for interpreting screenshots correctly.

### Step 1: Where is the Screen?

Observe screenshot and determine screen state:

**Case A: Screen is on expected page**
- The app navigated to the correct screen
- Element should be visible but test couldn't find it
- → Proceed to Step 2A

**Case B: Screen is completely wrong / on different page**
- App is on unexpected screen (login, error page, wrong tab)
- Usually indicates environment or navigation issue
- → **Recommendation: Restore Environment**

### Step 2A: Why is Element Not Found?

If screen is correct but element missing:

**Case A1: New UI element appeared (blocking)**
- New dialog, popup, or banner covering expected element
- Common examples:
  - Microsoft passkey dialog
  - System permission request
  - New promotional banner
  - External service UI change

**Check:**
- Is this from external service (SSO/Microsoft/Google)?
- Is this a new system dialog?

→ **Recommendation: Fix** (add handler for new element)

**Case A2: Element actually disappeared**
- Screen structure changed
- Element was removed or renamed
- Layout significantly different

**Check:**
- Recent code changes? (`git diff` on relevant files)
- Accessibility identifier changed?
- Element moved to different location?

→ **Recommendation: Fix** (update test or fix code)

**Case A3: Element exists but not interactable**
- Element visible but disabled, hidden, or obscured
- May be timing issue or state issue

**Check:**
- Is element grayed out / disabled?
- Is something overlaying it?
- Is it outside visible viewport?

→ **Recommendation: Investigate further** (may need timing fix or state setup)

### Step 3: Confirm Root Cause

Summarize findings with:

1. **What screenshot shows:**
   - Describe the actual UI state
   - Note any unexpected elements

2. **Reason for determination:**
   - Why this is the root cause
   - Evidence from screenshot

3. **Recommended handling:**
   - Specific action to take
   - Which skill/action to use next

## After Analysis

Based on findings, suggest next steps:

- **External service change** → `uitest-actions` skill (fix) → Create OpenSpec proposal
- **Code change needed** → `uitest-actions` skill (fix) → Create OpenSpec proposal
- **Environment issue** → `uitest-actions` skill (restore)
- **Need management decision** → `reporting-uitest` skill
- **Transient issue confirmed** → `uitest-actions` skill (observe)

## Common Screenshot Patterns

| Screenshot Shows | Likely Cause | Recommended Action |
|------------------|--------------|-------------------|
| Microsoft "Setting up passkey" page | External service change | Fix (add handler) |
| Microsoft blocking/security page | IP/account blocked | Report to IT |
| Login page (should be logged in) | Session/credential issue | Restore Environment |
| Empty screen / loading spinner | Timing or backend issue | Investigate further |
| Different UI layout | Code change or version mismatch | Fix (update test) |
| System permission dialog | Missing permission handling | Fix (add handler) |
