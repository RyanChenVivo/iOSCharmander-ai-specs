# investigating-uitest-skill

## Overview

Visual analysis skill for UITest failure investigation. This skill handles Phase 2: downloading screenshots and performing visual analysis to determine root cause.

## Files to Create

### `.claude/skills/investigating-uitest/SKILL.md`

```yaml
---
name: investigating-uitest
description: >
  Visual analysis of UITest failure screenshots. Use when screenshots need
  to be downloaded for detailed analysis. Determines failure cause based on
  screenshots: external service changes, code changes, or environment issues.
---
```

**Content Structure:**

1. **Download Screenshots Section**
   - Commands to download screenshots from CI
   - Expected location: `$HOME/Downloads/UITestAnalysis/latest/screenshots/`

2. **Phase 2 Decision Flow**

   - Step 1: Where is the screen?
     - Observe screenshot, determine screen state
     - **Case A: Screen is on expected page** → Proceed to Step 2A
     - **Case B: Screen is completely wrong / on different page**
       - Usually environment issue
       - Recommendation: Restore Environment

   - Step 2A: Why is element not found?
     - **Case A1: New UI element appeared**
       - Example: passkey dialog, new popup
       - Check if external service change (SSO/Microsoft etc.)
       - Recommendation: Fix (handle new element)
     - **Case A2: Element actually disappeared**
       - Screen structure changed
       - Check for related code changes (git diff)
       - Recommendation: Fix (correct test or code)

   - Step 3: Confirm Root Cause
     - Summarize findings:
       - What screenshot shows
       - Reason for determination
       - Recommended handling approach

3. **Output Section**
   - Present findings to user
   - Suggest next action (report/fix/observe)

**Estimated Lines:** ~80

## Acceptance Criteria

- [ ] SKILL.md follows YAML frontmatter format
- [ ] Description contains trigger keywords (screenshots, visual analysis)
- [ ] Decision flow covers screen location and element analysis
- [ ] Clear branching between environment issues vs code/service changes
- [ ] Provides actionable next steps after analysis
- [ ] Total SKILL.md under 500 lines
- [ ] All content in English

## Dependencies

- Typically invoked after `analyzing-uitest-failures` recommends investigation
- Requires CI screenshot artifacts to be available

## Testing

1. Invoke skill with sample screenshot data
2. Verify screenshot download commands work
3. Verify decision flow handles expected page scenario
4. Verify decision flow handles wrong page scenario
5. Verify root cause summary is generated correctly
