# analyzing-uitest-failures-skill

## Overview

Core analysis skill for UITest failure triage. This is the main entry point skill that performs Phase 1 analysis: pattern matching, history checking, and recommendation generation.

## Files to Create

### `.claude/skills/analyzing-uitest-failures/SKILL.md`

```yaml
---
name: analyzing-uitest-failures
description: >
  Analyze UITest failures and provide handling recommendations. Use when user
  mentions CI failures, UITest errors, or test failures. Determines whether
  further investigation is needed based on error messages and history,
  and recommends appropriate actions (observe/fix/investigate/restore).
---
```

**Content Structure:**

1. **Pre-check Section**
   - Check if `$HOME/Downloads/UITestAnalysis/latest/` exists
   - Check data date:
     - Today → Use directly
     - Past date → Ask: "Data is from YYYY-MM-DD, download latest? Or use this?"
     - Not exist → Ask: "No data found, download now?"

2. **Phase 1 Decision Flow**
   - Step 1: Check Known Patterns
     - Query `references/patterns.md` for matching patterns
     - If matched: Use pattern's recommended action with explanation
     - If not matched: Proceed to Step 2

   - Step 2: Check History
     - Query `uitest-automation/observations/active.json`
     - Check if same test is under observation
     - If recurring: Escalate (observe → investigate or fix)
     - If recurring: Ask if user wants to record learning

   - Step 3: Initial Classification
     - Classify by error characteristics:
       | Error Type | Category | Recommendation |
       |------------|----------|----------------|
       | timeout, network error | Network issue | Observe |
       | element not found | Needs visual | Investigate |
       | crash, fatal error | Possible bug | Investigate |
       | credential, auth | Environment | Investigate |

   - Step 4: Provide Recommendation
     - Present options:
       - A) Fix via OpenSpec — Severe/recurring
       - B) Investigate — Need screenshots
       - C) Observe — Transient/first occurrence
       - D) Restore Environment — Environment issues
       - E) Generate Report — Management decision

3. **Related References Section**
   - Link to `references/patterns.md`
   - Link to `references/external-dependencies.md`

**Estimated Lines:** ~100

### `.claude/skills/analyzing-uitest-failures/references/patterns.md`

Move and enhance content from `uitest-automation/knowledge/patterns.md`.

**Format for each pattern:**

```markdown
## pattern-id

**Trigger Conditions:**
- Error message contains "X" or "Y"
- Test name pattern
- Other conditions

**Recommended Action:** Observe | Investigate | Fix | Restore

**Reason:** Why this recommendation

**Historical Cases:**
- YYYY-MM-DD: What happened
- Related fix: archive link or N/A
```

**Initial patterns to include:**
- `network-timeout`
- `sso-new-dialog`
- `credential-expired`
- (migrate existing patterns from current patterns.md)

### `.claude/skills/analyzing-uitest-failures/references/external-dependencies.md`

Move content from `uitest-automation/knowledge/external-dependencies.md`.

Contains knowledge about external services that affect UITests:
- Microsoft SSO behavior
- Azure AD patterns
- Other third-party services

## Acceptance Criteria

- [ ] SKILL.md follows YAML frontmatter format
- [ ] Description contains trigger keywords (CI failures, UITest errors, test failures)
- [ ] Pre-check logic handles all three data states (today/past/missing)
- [ ] Decision flow covers all classification cases
- [ ] References are linked with relative paths
- [ ] Total SKILL.md under 500 lines
- [ ] All content in English

## Dependencies

- None (this is the core skill)

## Testing

1. Invoke skill directly without command
2. Verify pre-check prompts for stale data
3. Verify pattern matching works with known patterns
4. Verify history checking works with active observations
5. Verify recommendation options are presented correctly
