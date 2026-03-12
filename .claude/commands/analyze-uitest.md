# Analyze UITest Failures

> **Command:** `/analyze-uitest`

Analyze UITest failures from CI using a skill-based approach with dynamic context loading.

---

## What This Command Does

Invokes the `analyzing-uitest-failures` skill, which automatically:

1. **Always downloads latest test data from CI** (lightweight JSON files to `$HOME/Downloads/UITestAnalysis/latest/`)
2. **Validates data date** after download — prompts user if not today's data
3. **Analyzes failures** against known patterns and history
4. **Provides recommendations** (Observe/Investigate/Fix/Restore/Report)
5. **Routes to appropriate follow-up skills** as needed

---

## How It Works

The `analyzing-uitest-failures` skill will:
- **Always download fresh data** before analysis (never skips download)
- Validate data date after download (prompts user if CI didn't run today)
- **Handle multiple failures** with grouped summary view
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
