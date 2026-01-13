## 1. Create New Skills

### 1.1 integrating-api
- [x] 1.1.1 Create `.claude/skills/integrating-api/SKILL.md`
- [x] 1.1.2 Write description with specific triggers (RESTful, GraphQL, VortexBackendModel, API endpoint)
- [x] 1.1.3 Extract API patterns from current skill (api-patterns.md content)
- [x] 1.1.4 Keep under 100 lines, link to references as needed

### 1.2 creating-viewmodel
- [x] 1.2.1 Create `.claude/skills/creating-viewmodel/SKILL.md`
- [x] 1.2.2 Write description with triggers (ViewModel, ObservableObject, @Published, @Dependency)
- [x] 1.2.3 Include MVVM pattern, DI setup, error handling via AppManager
- [x] 1.2.4 Reference `openspec/project.md` for full architecture details

### 1.3 writing-unit-tests
- [x] 1.3.1 Create `.claude/skills/writing-unit-tests/SKILL.md`
- [x] 1.3.2 Write description with triggers (Swift Testing, @Test, @Suite, #expect, MockAppManager)
- [x] 1.3.3 Extract testing-guide.md content
- [x] 1.3.4 Include Swift Testing vs XCTest comparison

### 1.4 managing-feature-toggles
- [x] 1.4.1 Create `.claude/skills/managing-feature-toggles/SKILL.md`
- [x] 1.4.2 Write description with triggers (FeatureToggle, canViewTab, canTriggerTab, dark release)
- [x] 1.4.3 Document three control methods pattern
- [x] 1.4.4 Include priority order (Dark Release → Permission → License)

### 1.5 localizing-strings
- [x] 1.5.1 Create `.claude/skills/localizing-strings/SKILL.md`
- [x] 1.5.2 Write description with triggers (localization, Localizable.xcstrings, i18n, translation)
- [x] 1.5.3 Document string key format and product name placeholders
- [x] 1.5.4 Include non-English language handling guidelines

### 1.6 committing-code
- [x] 1.6.1 Create `.claude/skills/committing-code/SKILL.md`
- [x] 1.6.2 Write description with triggers (commit, git, PR, two-repo)
- [x] 1.6.3 Extract git-workflow.md content
- [x] 1.6.4 Emphasize critical two-repo architecture rules

## 2. Remove Old Skill

- [x] 2.1 ~~Backup current `implement-vortex-feature/` directory~~ (skipped, git controlled)
- [x] 2.2 Remove `.claude/skills/implement-vortex-feature/` directory
- [x] 2.3 Verify no broken references in other files

## 3. Validation

- [x] 3.1 Verify all skills created with correct structure
- [x] 3.2 Check line counts (all under ~100 lines)
- [x] 3.3 Confirm old skill removed
- [x] 3.4 Update tasks.md with completion status
