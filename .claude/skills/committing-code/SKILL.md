---
name: committing-code
description: Use when committing changes, creating commits, or running git commit. Enforces commit format (<type>(<project>): <description>) and guides two-repo workflow.
---

# Git Workflow

## When to Use This Guide

**Before committing, determine the target repository:**

### iOSCharmander (Main Repo)
Use when changes involve:
- App source code (Swift files, ViewModels, Managers, Views)
- Xcode project files
- Tests (iOSCharmanderTests, UI tests)
- Assets, localization files
- Build configurations

**Workflow:** Feature branch → PR to main

### iOSCharmander-ai-specs (AI Specs Repo)
Use when changes involve:
- `openspec/` directory (specs, proposals)
- `.claude/` directory (skills, settings)
- AI configuration files

**Workflow:** Direct commit to main (no PR needed)

**CRITICAL:** Never commit `openspec/` or `.claude/` in iOSCharmander repo - they are symlinks!

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
