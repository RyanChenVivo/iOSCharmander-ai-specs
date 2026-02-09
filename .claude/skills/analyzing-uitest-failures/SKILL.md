---
name: analyzing-uitest-failures
description: >
  Analyze UITest failures and provide handling recommendations. Use when user
  mentions CI failures, UITest errors, or test failures. Determines whether
  further investigation is needed based on error messages and history,
  and recommends appropriate actions (observe/fix/investigate/restore).
---

# UITest Failure Analysis

Analyze UITest failures from CI and provide handling recommendations.

## Pre-check

Before analysis, verify data availability:

1. Check if `$HOME/Downloads/UITestAnalysis/latest/` exists
2. Check data date:
   - **Today** → Use directly
   - **Past date** → Ask: "Data is from YYYY-MM-DD. Download latest data? Or use this?"
   - **Not exist** → Ask: "No data found. Download now?"

If no data or user wants refresh, guide them to use `/analyze-uitest` command which handles CI data download.

## Phase 1 Decision Flow

### Step 1: Check Known Patterns

Query [patterns.md](references/patterns.md) for matching known patterns.

**Pattern matching criteria:**
- Test name matches pattern regex
- Error message contains pattern trigger text
- Additional context matches (URL, test category)

**If matched:**
- Use the pattern's recommended action
- Explain why it matched and cite historical cases
- Skip to Step 4 with pattern's recommendation

**If not matched:**
- Proceed to Step 2

### Step 2: Check History

Query `uitest-automation/observations/active.json`:
- Is the same test currently under observation?
- What were previous observation results?
- When did observation period start?

**If recurring issue (seen before in observations):**
- Escalate handling: observe → investigate or fix
- Note: "This issue was previously observed on [date]. Previous judgment may need revision."
- Flag for potential learning opportunity

**If first occurrence:**
- Continue to Step 3

### Step 3: Initial Classification

Classify based on error message characteristics:

| Error Characteristic | Category | Default Recommendation |
|---------------------|----------|------------------------|
| timeout, network error | Network issue | Observe |
| element not found | Needs visual confirmation | Investigate |
| crash, fatal error, SIGABRT | Possible bug | Investigate |
| credential, auth, 401, unauthorized | Environment issue | Investigate |
| UAT cleanup failed | Test infrastructure | Restore Environment |
| assertion failure | Possible code change | Investigate |

### Step 4: Provide Recommendation

Present options based on analysis:

```
Based on the analysis, here are the recommended options:

A) Fix via OpenSpec — For severe or recurring issues that need code changes
B) Investigate — Download screenshots for visual analysis
C) Observe — Record and wait (for transient/first occurrence issues)
D) Restore Environment — For environment/account issues
E) Generate Report — For management decision or formal documentation
```

Highlight the recommended option based on analysis results.

## After User Selection

Based on user's choice, the corresponding skill will be invoked:

- **A or Fix** → `uitest-actions` skill (fix action)
- **B or Investigate** → `investigating-uitest` skill
- **C or Observe** → `uitest-actions` skill (observe action)
- **D or Restore** → `uitest-actions` skill (restore action)
- **E or Report** → `reporting-uitest` skill

## Related References

- **Known Patterns**: [patterns.md](references/patterns.md) - Failure patterns with triggers and recommended actions
- **External Services**: [external-dependencies.md](references/external-dependencies.md) - External service behaviors and known issues
