# Analyze UITest Failures

> **Command:** `/analyze-uitest`

Analyze UITest failures from CI using a skill-based approach with dynamic context loading.

---

## What This Command Does

1. Downloads test data from CI (lightweight JSON files)
2. Invokes the `analyzing-uitest-failures` skill for analysis
3. Follow-up actions are handled by additional skills as needed

---

## Download CI Data

Run the download script:

```bash
uitest-automation/scripts/download_uitest_data.sh
```

This downloads JSON test data (~100KB) to `$HOME/Downloads/UITestAnalysis/latest/`.

---

## Start Analysis

After downloading data, use the `analyzing-uitest-failures` skill to analyze the failures.

The skill will:
- Check data freshness (today's data used directly, older data prompts user)
- **Handle multiple failures** with grouped summary view (Phase 0)
- Match against known patterns in the pattern library
- Check observation history for recurring issues
- Provide recommendations (Observe/Investigate/Fix/Restore/Report)

### Multi-Failure Handling

When multiple tests fail, the skill provides:
- **Grouped summary** — Failures organized by recommended action
- **Same-source detection** — Identifies potentially related failures
- **Batch processing** — Low-risk actions (Observe) can be processed together
- **Flexible options** — Choose to process groups or individual tests

Based on the recommendation, additional skills are available:
- `investigating-uitest` - Visual analysis with screenshots
- `reporting-uitest` - Generate Traditional Chinese reports
- `uitest-actions` - Execute actions (observe/fix/restore/learn)

---

## Data Files Location

- **Downloaded data:** `$HOME/Downloads/UITestAnalysis/latest/`
- **Observations:** `uitest-automation/observations/`
- **Historical fixes:** `openspec/changes/archive/`
