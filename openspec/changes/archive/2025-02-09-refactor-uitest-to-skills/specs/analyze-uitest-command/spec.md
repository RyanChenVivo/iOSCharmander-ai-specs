# analyze-uitest-command

## Overview

Slim down the existing `/analyze-uitest` command to only handle startup, CI data download, and explicit skill invocation. This is a modification of an existing file.

## Files to Modify

### `.claude/commands/analyze-uitest.md`

**Current State:** ~196 lines with full documentation of all phases, workflows, and knowledge base references.

**Target State:** ~50 lines with only:
1. Command description
2. CI data download steps
3. Explicit skill invocation instruction

**New Content Structure:**

```markdown
# Analyze UITest Failures

> **Command:** `/analyze-uitest`

Analyze UITest failures from CI using a modular skill-based approach.

---

## What This Command Does

1. Downloads test data from CI (lightweight JSON files)
2. Invokes the `analyzing-uitest-failures` skill for analysis
3. Follow-up actions are handled by additional skills as needed

---

## Download CI Data

### Step 1: Create Download Directory

```bash
mkdir -p $HOME/Downloads/UITestAnalysis/latest
```

### Step 2: Download Test Results

[Specific CI download commands - keep existing commands]

---

## Start Analysis

After downloading data, use the `analyzing-uitest-failures` skill to analyze the failures.

The skill will:
- Check data freshness
- Match against known patterns
- Check observation history
- Provide recommendations

Based on the recommendation, additional skills may be invoked:
- `investigating-uitest` - For visual analysis
- `reporting-uitest` - For formal reports
- `uitest-actions` - For executing actions

---

## Data Files Location

- **Downloaded data:** `$HOME/Downloads/UITestAnalysis/latest/`
- **Observations:** `uitest-automation/observations/`
- **Historical fixes:** `openspec/changes/archive/`
```

**Estimated Lines:** ~50

## Changes from Current

| Section | Current | New |
|---------|---------|-----|
| Complete Documentation | ~100 lines | Removed (moved to skills) |
| Phase descriptions | Detailed | Brief mention only |
| Knowledge Base refs | Listed | Removed (in skill references) |
| Workflow files refs | Listed | Removed (integrated into skills) |
| Download commands | Present | Keep |
| Skill invocation | N/A | Added explicit instruction |

## Files to Remove (After Migration)

These files will be removed in Phase 4 cleanup after validating the new system:

- `uitest-automation/UITEST_AGENT.md`
- `uitest-automation/workflows/triage.md`
- `uitest-automation/workflows/investigate.md`
- `uitest-automation/workflows/report.md`
- `uitest-automation/workflows/action.md`
- `uitest-automation/knowledge/decision-tree.md`

## Files to Keep

- `uitest-automation/observations/active.json`
- `uitest-automation/observations/resolved.json`
- `uitest-automation/downloads/` (CI downloaded data)

## Acceptance Criteria

- [ ] Command file is ~50 lines (down from ~196)
- [ ] CI download commands are preserved
- [ ] Explicit instruction to use `analyzing-uitest-failures` skill
- [ ] Mentions other skills as follow-up options
- [ ] Does NOT duplicate skill content
- [ ] All content in English

## Dependencies

- All 4 skills must be created before slimming down the command
- Test full workflow before removing old files

## Testing

1. Run `/analyze-uitest` command
2. Verify CI data download works
3. Verify `analyzing-uitest-failures` skill is invoked
4. Verify full workflow (triage → investigate → report → action) works
5. Verify no broken references to removed files
