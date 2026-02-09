## Why

The current `/analyze-uitest` command loads all context (workflows, knowledge base, decision trees) upfront, consuming significant tokens even when only a subset is needed. This change refactors the monolithic command into a Command + Skills hybrid architecture, enabling dynamic context loading where each phase loads only what's relevant, reducing token consumption and improving maintainability.

## What Changes

- Slim down `/analyze-uitest` command to only handle CI data download and skill invocation
- Create 4 new Skills for dynamic loading:
  - `analyzing-uitest-failures` - Phase 1: Pattern matching and initial recommendations
  - `investigating-uitest` - Phase 2: Screenshot-based visual analysis
  - `reporting-uitest` - Phase 3: Traditional Chinese report generation
  - `uitest-actions` - Phase 4: Execute actions (observe/fix/restore/learn)
- Move knowledge base (patterns.md, external-dependencies.md) to skill references
- Add smart learning prompts that only trigger when new information exists
- Add data freshness pre-check (today's data = use directly, old data = ask user)

## Capabilities

### New Capabilities
- `analyzing-uitest-failures-skill`: Core analysis skill with Phase 1 decision flow, pattern matching, history checking, and recommendation generation
- `investigating-uitest-skill`: Visual analysis skill for screenshot-based failure diagnosis
- `reporting-uitest-skill`: Report generation skill with Traditional Chinese templates
- `uitest-actions-skill`: Action execution skill with observe/fix/restore/learn workflows and conditional learning prompts

### Modified Capabilities
- `analyze-uitest-command`: Slim down existing command to only handle startup, CI data download, and explicit skill invocation

## Impact

- **Files to create**:
  - `.claude/skills/analyzing-uitest-failures/SKILL.md`
  - `.claude/skills/analyzing-uitest-failures/references/patterns.md`
  - `.claude/skills/analyzing-uitest-failures/references/external-dependencies.md`
  - `.claude/skills/investigating-uitest/SKILL.md`
  - `.claude/skills/reporting-uitest/SKILL.md`
  - `.claude/skills/reporting-uitest/references/report-template.md`
  - `.claude/skills/uitest-actions/SKILL.md`
- **Files to modify**:
  - `.claude/commands/analyze-uitest.md` (slim down)
- **Files to remove** (after migration):
  - `uitest-automation/UITEST_AGENT.md`
  - `uitest-automation/workflows/*.md`
  - `uitest-automation/knowledge/decision-tree.md`
- **Files to move**:
  - `uitest-automation/knowledge/patterns.md` → skills reference
  - `uitest-automation/knowledge/external-dependencies.md` → skills reference
- **Data files unchanged**:
  - `uitest-automation/observations/` (keep original location)
