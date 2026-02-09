## Context

The current `/analyze-uitest` command is a monolithic system that loads all content (UITEST_AGENT.md, workflows, knowledge base) into context upfront. This wastes tokens when only a subset of functionality is needed. The goal is to refactor into a Command + Skills architecture following Claude Code's progressive disclosure pattern.

**Current State:**
- Single command file references multiple workflow files
- All knowledge base loaded regardless of use
- No dynamic loading capability
- Approximately 600+ lines loaded for every analysis

**Constraints:**
- Must maintain backward compatibility during migration
- Skills must follow Anthropic's official best practices
- SKILL.md files should be under 500 lines
- All skill content must be in English

## Goals / Non-Goals

**Goals:**
- Reduce token consumption by loading only relevant skills
- Enable Claude to auto-discover skills based on context
- Make each phase independently maintainable
- Support incremental learning through smart prompting
- Pre-check data freshness before analysis

**Non-Goals:**
- Changing the fundamental analysis logic
- Modifying the CI data download mechanism
- Creating new data storage formats
- Adding new analysis capabilities (focus is on architecture)

## Decisions

### Decision 1: Skill Granularity - 4 Skills + 1 Command

**Choice:** Create 4 separate skills (analyzing, investigating, reporting, actions) rather than 1 large skill or many small skills.

**Rationale:**
- Matches the natural 4-phase workflow (Triage → Investigate → Report → Action)
- Each skill has distinct trigger conditions for auto-discovery
- Avoids over-fragmentation that would complicate maintenance

**Alternatives Considered:**
- Single monolithic skill: Would defeat the purpose of dynamic loading
- Many small skills (one per action): Over-engineering, harder to maintain

### Decision 2: Command Explicitly Invokes Core Skill

**Choice:** Command explicitly instructs Claude to use `analyzing-uitest-failures` skill.

**Rationale:**
- Reliable triggering for user-initiated workflows
- Clear entry point for the analysis pipeline
- Other skills are discovered dynamically based on user choices

**Alternatives Considered:**
- Pure auto-discovery: Less reliable for explicit `/analyze-uitest` invocation
- Multiple command variants: Adds complexity without benefit

### Decision 3: Knowledge Base in Skill References

**Choice:** Move patterns.md and external-dependencies.md to skill references folder.

**Rationale:**
- Follows progressive disclosure pattern
- Loaded only when skill reads them
- Co-located with the skill that uses them

**Alternatives Considered:**
- Keep in original location: Would require cross-directory references
- Embed in SKILL.md: Would exceed recommended line count

### Decision 4: Learning Integrated into uitest-actions

**Choice:** Add Learn as an action in uitest-actions skill, not a separate skill.

**Rationale:**
- Learning naturally follows other actions (observe/fix/restore)
- Conditional prompting logic is action-specific
- Avoids proliferation of small skills

**Alternatives Considered:**
- Separate learning skill: Over-engineering for simple use case
- No learning feature: Loses opportunity for system improvement

### Decision 5: Data Freshness Pre-check in Core Skill

**Choice:** analyzing-uitest-failures skill checks data date and prompts if stale.

**Rationale:**
- Handles both command-triggered and direct skill invocation
- User stays informed about data currency
- Simple date comparison logic

**Alternatives Considered:**
- Always re-download: Wasteful for same-day reruns
- No check: Could analyze outdated data silently

## Risks / Trade-offs

**[Risk] Skill auto-discovery may not trigger reliably**
→ Mitigation: Command explicitly invokes core skill; other skills have clear descriptions with trigger keywords

**[Risk] Migration disrupts existing workflow**
→ Mitigation: Implement in phases; keep old files until new system validated

**[Risk] References not found due to path issues**
→ Mitigation: Use relative paths from skill directory; test thoroughly

**[Trade-off] More files to maintain**
→ Accepted: Organization benefits outweigh file count concern

**[Trade-off] Slight delay from skill loading**
→ Accepted: Token savings worth minimal latency; skills are small

## Migration Plan

**Phase 1: Create Core Skill**
1. Create `analyzing-uitest-failures` skill with full decision flow
2. Create references (patterns.md, external-dependencies.md)
3. Test skill in isolation

**Phase 2: Create Secondary Skills**
4. Create `investigating-uitest` skill
5. Create `reporting-uitest` skill with template reference
6. Create `uitest-actions` skill with learn functionality

**Phase 3: Update Command**
7. Slim down analyze-uitest.md command
8. Add explicit skill invocation instruction
9. Test full workflow

**Phase 4: Cleanup**
10. Remove deprecated uitest-automation files
11. Update any documentation references

**Rollback Strategy:**
- Keep original files in uitest-automation/ until Phase 4
- If issues arise, revert command to reference original files
