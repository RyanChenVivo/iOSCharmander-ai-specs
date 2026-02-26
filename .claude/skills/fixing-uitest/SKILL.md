---
name: fixing-uitest
description: >
  Use when UITest failures need test code fixes. Triggers on: confirmed code bug
  from analysis, standalone broken test report, UI element change, new dialog
  handler needed, timing fix needed.
---

# Fixing UITest

Structured UITest fix with OpenSpec integration and build validation. Scope: test code only.

## Entry Context

| Entry | Source | Has Context? |
|-------|--------|-------------|
| A | From analysis pipeline (uitest-actions Fix) | Yes: test_names, error_messages, root_cause |
| B | Standalone ("testX 壞了") | No: only test name |

Entry A: skip to Step 1.
Entry B: start at Step B1.

## Step B1: Gather Context (Entry B Only)

1. Find and read test code + helpers
2. Check `analyzing-uitest-failures/references/patterns.md` for known pattern match
3. Check triage report (`$HOME/Downloads/UITestAnalysis/latest/triage_report_*.md`) for error details
4. Determine failure type — you MUST have a concrete error message before proceeding to B2

## Step B2: Decision Gate (Entry B Only)

Before ANY fix attempt, classify:

| Signal | Route To | Action |
|--------|----------|--------|
| Error at setup/signin stage + test expects fresh state | `restoring-uitest-environment` | Pack context, route out |
| Matches `environment-state-residual` pattern | `restoring-uitest-environment` | Pack context, route out |
| Non-programmable (external blocking, IT needed) | `reporting-uitest` | Pack context, route out |
| UI element changed / new dialog / timing issue | Continue to Step 1 | This IS a fix |

**When routing, pass:** test_names, error_messages, root_cause, restore_hint, screenshot_path, pattern_id

## Step 1: Understand Test (MANDATORY)

Read ALL of these before touching any code:

1. **Test source code** — what does the test do, step by step?
2. **Helper functions** — what helpers does it call?
3. **Product code** — confirm types, enum cases, accessibility IDs actually exist in product code

## Step 2: Classify Fix Pattern

| Pattern | Characteristics | Key Step |
|---------|----------------|----------|
| UI element change | Tab/button renamed, removed, added | `git log` product code, confirm new type exists |
| New dialog/popup | External service added UI element | Read existing handler patterns, follow naming conventions |
| Timing issue | Element not found + short duration | Find proper wait condition (NOT blind timeout) |

## Step 3: Create OpenSpec Change

Call `opsx:ff` with accumulated context:
- Change name: `fix-uitest-<brief-description>-<YYYY-MM-DD>`
- Include: test names, root cause, fix approach, affected files

## Step 4: Ask User

"OpenSpec change created. Apply now? (Y/n)"
- Yes → call `opsx:apply`
- No → done, user applies later

## Step 5: Build Validation

After EACH task in `opsx:apply`: build must pass. If you changed an enum case or ID, grep product code to confirm it exists. Build fails → fix until it passes. Do NOT skip.

## Red Flags — STOP

| Rationalization | Reality |
|-----------------|---------|
| "Just one line, no need for OpenSpec" | One-line changes break builds. OpenSpec tracks them. |
| "I'll add defensive code for robustness" | Environment problems need environment fixes, not code workarounds. |
| "Let me propose a few options" | Verify the correct fix. Options = uncertainty = unverified. |
| "Long-term prevention" for env issue | Wrong layer. Route to `restoring-uitest-environment`. |
| Changing code without reading product code | STOP. Step 1 is MANDATORY. |
| Skipping patterns.md on Entry B | STOP. Step B1 is MANDATORY. |
| "Depends on the error" without finding it | Get the actual error first. Check triage report or run the test. |

## Return Protocol

| Field | Value |
|-------|-------|
| processed_tests | Test names fixed |
| conclusion | "Fix" |
| summary | OpenSpec change name + build status |
