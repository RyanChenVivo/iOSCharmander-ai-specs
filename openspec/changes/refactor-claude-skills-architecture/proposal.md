## Why

The current `implement-vortex-feature` skill covers too many unrelated domains (API integration, unit testing, feature toggles, localization, git workflow, etc.), causing:
1. **Context bloat**: Almost every development task triggers this skill, loading 229+ lines of potentially irrelevant context
2. **Imprecise triggering**: The broad description matches too many scenarios
3. **Poor progressive disclosure**: Too much detail in the main SKILL.md instead of on-demand loading

Reference: [Claude Platform Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices#progressive-disclosure-patterns)

## What Changes

- **BREAKING**: Remove `implement-vortex-feature` skill (single monolithic skill)
- Add `integrating-api` skill (RESTful + GraphQL patterns)
- Add `creating-viewmodel` skill (MVVM + DI + error handling)
- Add `writing-unit-tests` skill (Swift Testing framework)
- Add `managing-feature-toggles` skill (dark release patterns)
- Add `localizing-strings` skill (i18n conventions)
- Add `committing-code` skill (git workflow + two-repo architecture)

## Impact

- Affected files: `.claude/skills/implement-vortex-feature/` (remove entire directory)
- New directories: `.claude/skills/{integrating-api,creating-viewmodel,writing-unit-tests,managing-feature-toggles,localizing-strings,committing-code}/`
- Repository: Changes in `iOSCharmander-ai-specs` (symlinked)

## Design Principles

Following Claude Platform best practices:

1. **Concise is key**: Each skill under 100 lines, focused on single domain
2. **Specific descriptions**: Include trigger keywords for precise activation
3. **Progressive disclosure**: Main SKILL.md as overview, link to references only when needed
4. **Gerund naming**: `integrating-api`, `writing-unit-tests` format
