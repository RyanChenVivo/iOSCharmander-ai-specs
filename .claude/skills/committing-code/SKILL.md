---
name: committing-code
description: Guides commit format (<type>(<project>): <description>) and two-repo workflow. App code to iOSCharmander, openspec/.claude to iOSCharmander-ai-specs.
---

# Git Workflow

## CRITICAL: Two-Repo Architecture

**Main Repo** (`iOSCharmander`): iOS app source code
**AI Specs Repo** (`iOSCharmander-ai-specs`): OpenSpec docs + AI configurations

`.claude/` and `openspec/` in main repo are **symlinks** to ai-specs repo.

### Repository Rules

| Files | Repository | Branch |
|-------|------------|--------|
| App code | `iOSCharmander` | Feature branch → PR |
| `openspec/`, `.claude/` | `iOSCharmander-ai-specs` | Direct to `main` |

### Committing OpenSpec/AI Files

```bash
cd ../iOSCharmander-ai-specs
git status
git add openspec/ .claude/
git commit -m "feat(Vortex): description"
git push origin main
```

**Never** commit `openspec/` or `.claude/` in `iOSCharmander` repo.

## Commit Format

**Pattern**: `<type>(<project>): <description>`

**Projects**: `Vortex` or `CloudSight`

**Types**:
| Type | Use For |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring |
| `docs` | Documentation |
| `test` | Tests |
| `chore` | Build, deps |

**Examples**:
```
feat(Vortex): add floor plan device selection
fix(CloudSight): resolve thread issue in video streaming
test(Vortex): add UI tests for camera selection
```

## Guidelines

- Reference ticket IDs: `[VOR-24280]`
- Keep descriptions concise
- Use filename only (not full path)
- Confirm project name if uncertain

## Branch Strategy

- `main`: Production-ready (PR target)
- Feature branches: Descriptive names (`floorMap`, `feature-name`)

## File Management

**Adding files outside VortexFeatures**:
1. Update Xcode project file
2. Build to verify
3. VortexFeatures SPM files are auto-included

**Modifying project.pbxproj**: Use relative paths only.
