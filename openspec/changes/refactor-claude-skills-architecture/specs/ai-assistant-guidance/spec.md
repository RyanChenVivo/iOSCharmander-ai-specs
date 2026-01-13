## MODIFIED Requirements

### Requirement: Vortex Feature Implementation Skill

The system SHALL provide multiple focused Claude Code skills that teach AI assistants how to implement Vortex features following project conventions and best practices. Each skill SHALL focus on a single domain for precise triggering and minimal context loading.

#### Scenario: API integration skill triggers on API keywords
- **WHEN** user request contains keywords like "API", "RESTful", "GraphQL", "VortexBackendModel", "endpoint"
- **THEN** the `integrating-api` skill is loaded and provides API-specific conventions

#### Scenario: ViewModel skill triggers on architecture keywords
- **WHEN** user request contains keywords like "ViewModel", "ObservableObject", "@Published", "@Dependency", "MVVM"
- **THEN** the `creating-viewmodel` skill is loaded and provides architecture patterns

#### Scenario: Unit testing skill triggers on test keywords
- **WHEN** user request contains keywords like "unit test", "Swift Testing", "@Test", "@Suite", "#expect", "MockAppManager"
- **THEN** the `writing-unit-tests` skill is loaded and provides testing patterns

#### Scenario: Feature toggle skill triggers on feature management keywords
- **WHEN** user request contains keywords like "feature toggle", "FeatureToggle", "canViewTab", "dark release", "SupportFeature"
- **THEN** the `managing-feature-toggles` skill is loaded and provides feature management patterns

#### Scenario: Localization skill triggers on i18n keywords
- **WHEN** user request contains keywords like "localization", "translation", "Localizable.xcstrings", "i18n", "localized string"
- **THEN** the `localizing-strings` skill is loaded and provides localization conventions

#### Scenario: Git skill triggers on version control keywords
- **WHEN** user request contains keywords like "commit", "git", "branch", "PR", "two-repo"
- **THEN** the `committing-code` skill is loaded and provides git workflow patterns

#### Scenario: Skills do not trigger unnecessarily
- **WHEN** user request does not contain domain-specific keywords
- **THEN** no skill is loaded, avoiding context bloat

### Requirement: Skill Organization and Discoverability

Each skill SHALL be organized with progressive disclosure, focused scope, and clear structure for efficient reference.

#### Scenario: Each skill content stays under 100 lines
- **WHEN** skill file is created
- **THEN** main SKILL.md content is under 100 lines with links to detailed documentation only when needed

#### Scenario: Skills use gerund naming convention
- **WHEN** skill is named
- **THEN** skill uses gerund form like `integrating-api`, `writing-unit-tests`, `committing-code`

#### Scenario: Skills have specific trigger descriptions
- **WHEN** skill description is written
- **THEN** description includes specific keywords that trigger the skill and explains when to use it

#### Scenario: Skills reference project.md for comprehensive details
- **WHEN** AI assistant needs rules beyond skill scope
- **THEN** skill provides links to specific sections in openspec/project.md

### Requirement: Skill File Location and Structure

Each skill SHALL be stored in the project's `.claude/skills/` directory with its own subdirectory.

#### Scenario: Skills are stored in separate directories
- **WHEN** skills are created
- **THEN** each skill is located at `.claude/skills/{skill-name}/SKILL.md`

#### Scenario: Skill directories follow naming convention
- **WHEN** skill directory is created
- **THEN** directory name matches skill name in gerund form (e.g., `integrating-api`, `writing-unit-tests`)

#### Scenario: Skills have required metadata
- **WHEN** skill file is created
- **THEN** YAML frontmatter includes `name` matching directory name and `description` with domain-specific trigger keywords

#### Scenario: Skills are version controlled in ai-specs repo
- **WHEN** skill is committed to git
- **THEN** skill is committed to `iOSCharmander-ai-specs` repository (symlinked to main repo)
