# AI Assistant Guidance Specification

## ADDED Requirements

### Requirement: Vortex Feature Implementation Skill

The system SHALL provide a Claude Code skill that teaches AI assistants how to implement Vortex features following project conventions and best practices.

#### Scenario: Skill auto-triggers on relevant keywords
- **WHEN** user request contains keywords like "implement", "develop", "add API", "create ViewModel", "write test", "add translation", "feature toggle", "commit message", or "UI test"
- **THEN** the skill is loaded and provides relevant project conventions

#### Scenario: Skill provides code style guidance
- **WHEN** AI assistant needs to write or format code
- **THEN** skill provides SwiftFormat rules, naming conventions, and indentation standards

#### Scenario: Skill provides architecture guidance
- **WHEN** AI assistant needs to implement ViewModels, Managers, or dependencies
- **THEN** skill provides MVVM patterns, dependency injection rules, and error handling patterns

#### Scenario: Skill provides API integration guidance
- **WHEN** AI assistant needs to add RESTful or GraphQL APIs
- **THEN** skill provides naming conventions, model patterns, and error handling requirements

#### Scenario: Skill provides testing guidance
- **WHEN** AI assistant needs to write unit, integration, or UI tests
- **THEN** skill provides testing strategies, patterns, and best practices

#### Scenario: Skill provides feature management guidance
- **WHEN** AI assistant needs to implement feature toggles or dark releases
- **THEN** skill provides FeatureToggle patterns and MyOrganization.SupportFeature usage

#### Scenario: Skill provides localization guidance
- **WHEN** AI assistant needs to add translations or localized strings
- **THEN** skill provides string key format rules and placeholder conventions

#### Scenario: Skill provides git workflow guidance
- **WHEN** AI assistant needs to create commits or branches
- **THEN** skill provides commit message format and branching strategy

#### Scenario: Progressive disclosure of detailed rules
- **WHEN** AI assistant needs comprehensive details beyond quick reference
- **THEN** skill references full project.md sections for in-depth information

### Requirement: Skill Organization and Discoverability

The skill SHALL be organized with progressive disclosure and clear section structure for efficient reference.

#### Scenario: Skill content stays under 500 lines
- **WHEN** skill file is created
- **THEN** main SKILL.md content is under 500 lines with links to detailed documentation

#### Scenario: Skill sections are clearly categorized
- **WHEN** AI assistant loads the skill
- **THEN** content is organized into sections: Quick Reference, Code Style, Architecture, API Integration, Testing, Feature Management, Localization, Git Workflow

#### Scenario: Skill references project.md for details
- **WHEN** AI assistant needs comprehensive rules
- **THEN** skill provides links to specific sections in openspec/project.md

### Requirement: Skill File Location and Structure

The skill SHALL be stored in the project's `.claude/skills/` directory for team-wide access.

#### Scenario: Skill is stored in project directory
- **WHEN** skill is created
- **THEN** skill is located at `.claude/skills/implement-vortex-feature/SKILL.md`

#### Scenario: Skill has required metadata
- **WHEN** skill file is created
- **THEN** YAML frontmatter includes `name: implement-vortex-feature` and description with trigger keywords including "implement" and "develop"

#### Scenario: Skill is version controlled
- **WHEN** skill is committed to git
- **THEN** all team members and AI assistants have access to the same conventions
