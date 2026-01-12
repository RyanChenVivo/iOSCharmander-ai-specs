# Proposal: Add Project Conventions Skill

## Why

The project has extensive development rules, patterns, and conventions documented in `openspec/project.md` (580+ lines). AI assistants working on the codebase need quick access to these guidelines when performing specific tasks like adding APIs, implementing ViewModels, writing tests, or managing localizations. Currently, these rules are buried in a large document and may not be applied consistently.

A Claude Code skill will provide context-aware guidance by surfacing relevant conventions only when needed, improving code quality and reducing review cycles.

## What Changes

- Add new Claude Code skill for implementing Vortex features following project conventions
- Create `.claude/skills/implement-vortex-feature/SKILL.md` with categorized guidance
- Extract key rules from `openspec/project.md` into skill format:
  - Code style and formatting (SwiftFormat rules)
  - Architecture patterns (MVVM, dependency injection)
  - ViewModel error handling patterns
  - Manager and dependency layer guidelines
  - API integration conventions (RESTful, GraphQL, model patterns)
  - Testing strategies (unit, integration, UI testing)
  - Feature toggle and dark release patterns
  - Localization and translation rules
  - Git workflow and commit conventions
  - File management rules
- Organize content with progressive disclosure (main skill <500 lines, link to project.md for details)
- Auto-trigger on keywords: "implement", "add API", "create ViewModel", "write test", "add translation", "feature toggle", "develop", etc.

## Impact

- **Affected specs**: New capability `ai-assistant-guidance`
- **Affected code**: New directory `.claude/skills/implement-vortex-feature/`
- **Benefits**:
  - Consistent application of project conventions
  - Faster onboarding for AI assistants on new tasks
  - Reduced errors from missing convention knowledge
  - Context-aware guidance without overwhelming every interaction
