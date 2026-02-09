## Tasks

### Phase 1: Create Core Skill

- [x] **1.1** Create `.claude/skills/analyzing-uitest-failures/SKILL.md`
  - YAML frontmatter with name and description
  - Pre-check section for data freshness
  - Phase 1 decision flow (patterns → history → classify → recommend)
  - References links

- [x] **1.2** Create `.claude/skills/analyzing-uitest-failures/references/patterns.md`
  - Migrate content from `uitest-automation/knowledge/patterns.md`
  - Use detailed format with historical cases
  - Include initial patterns: network-timeout, sso-new-dialog, credential-expired

- [x] **1.3** Create `.claude/skills/analyzing-uitest-failures/references/external-dependencies.md`
  - Migrate content from `uitest-automation/knowledge/external-dependencies.md`

- [x] **1.4** Test core skill in isolation
  - Verify pre-check prompts correctly
  - Verify pattern matching works
  - Verify recommendation options display

### Phase 2: Create Secondary Skills

- [x] **2.1** Create `.claude/skills/investigating-uitest/SKILL.md`
  - YAML frontmatter
  - Screenshot download section
  - Phase 2 decision flow (screen location → element analysis → root cause)

- [x] **2.2** Create `.claude/skills/reporting-uitest/SKILL.md`
  - YAML frontmatter
  - Report format section
  - Output location specification

- [x] **2.3** Create `.claude/skills/reporting-uitest/references/report-template.md`
  - Traditional Chinese template
  - All required sections (TL;DR, Executive Summary, Analysis, Risk, Actions)

- [x] **2.4** Create `.claude/skills/uitest-actions/SKILL.md`
  - YAML frontmatter
  - Four actions: observe, fix, restore, learn
  - Smart prompting logic for learning

- [x] **2.5** Test secondary skills
  - Verify investigating-uitest handles screenshot analysis
  - Verify reporting-uitest generates correct output
  - Verify uitest-actions smart prompting logic

### Phase 3: Update Command

- [x] **3.1** Slim down `.claude/commands/analyze-uitest.md`
  - Reduce to ~50 lines
  - Keep CI download commands
  - Add explicit skill invocation instruction
  - Remove duplicate workflow documentation

- [x] **3.2** Test full workflow
  - `/analyze-uitest` → skill invocation → follow-up actions
  - Verify all phases work together
  - Verify no broken references

### Phase 4: Cleanup

- [x] **4.1** Remove deprecated files (after validation)
  - `uitest-automation/UITEST_AGENT.md`
  - `uitest-automation/workflows/triage.md`
  - `uitest-automation/workflows/investigate.md`
  - `uitest-automation/workflows/report.md`
  - `uitest-automation/workflows/action.md`
  - `uitest-automation/knowledge/decision-tree.md`

- [x] **4.2** Verify observations still work
  - `uitest-automation/observations/active.json` accessible
  - `uitest-automation/observations/resolved.json` accessible

- [x] **4.3** Update any documentation references
  - Check for broken links
  - Update README if needed

## Notes

- Keep original files until Phase 4 for rollback capability
- Test each phase before moving to next
- All skill content must be in English
- SKILL.md files should be under 500 lines each
