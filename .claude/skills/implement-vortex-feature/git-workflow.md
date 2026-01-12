# Git Workflow & Repository Structure

## ⚠️ CRITICAL: Two-Repo Architecture

**YOU MUST READ THIS BEFORE ANY GIT OPERATIONS**

### Repository Layout

**Main Repo** (`iOSCharmander`): iOS app source code
**AI Specs Repo** (`iOSCharmander-ai-specs`): OpenSpec docs + AI configurations

**Key Point**: `.claude/` and `openspec/` in main repo are **symlinks** to ai-specs repo.

### Git Workflow for OpenSpec/AI Files

**When modifying these files**:
- `openspec/` (proposals, specs, archives)
- `.claude/` (skills, slash commands, hooks)

**MUST use ai-specs repo**:
```bash
cd ../iOSCharmander-ai-specs
git status
git add openspec/ .claude/
git commit -m "feat(Vortex): description"
git push origin main  # Direct to main, no PR needed
```

### Critical Rules

- ❌ **NEVER** commit `openspec/` or `.claude/` in main `iOSCharmander` repo
- ✅ **ALWAYS** navigate to `iOSCharmander-ai-specs` first
- ✅ Specs/AI configs push directly to `main` branch
- ✅ App code uses feature branches + PRs

---

## Commit Conventions

### Format

**Pattern**: `<type>(<project>): <description>`

**Projects**: `Vortex` or `CloudSight`

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code restructuring
- `docs`: Documentation changes
- `test`: Test additions/modifications
- `chore`: Build, dependencies, etc.

### Examples

```
feat(Vortex): add floor plan device selection
fix(CloudSight): resolve thread issue in video streaming
refactor(Vortex): update icon and layout
test(Vortex): add UI tests for camera selection
```

### Guidelines

- Reference ticket IDs when applicable (e.g., `[VOR-24280]`)
- Keep descriptions concise, focus on **what changed**
- Use filename only (not full path) when mentioning files
- **IMPORTANT**: Confirm project name (Vortex/CloudSight) with user if uncertain

---

## Branch Strategy

### Branch Types

- **`main`**: Production-ready code (main branch for PRs)
- **Feature branches**: Descriptive names (e.g., `floorMap`, `feature-name`)

### Workflow

1. Branch from `main` for new features
2. Develop on feature branch
3. Merge via pull requests with code review
4. Keep branches up-to-date with `main`

---

## File Management

### Adding Files Outside VortexFeatures

**When adding to main project**:
1. Update Xcode project file to include new files
2. Build project to verify no errors
3. Files in VortexFeatures SPM package are auto-included (no project file update needed)

### Modifying project.pbxproj

- Use **relative paths** (not absolute)
- Follow existing path format in project file
- Example: relative to project root or group

---

## Quick Reference

| Task | Repository | Branch Strategy |
|------|------------|-----------------|
| App code changes | `iOSCharmander` | Feature branch → PR to `main` |
| OpenSpec/`.claude` changes | `iOSCharmander-ai-specs` | Direct to `main` |
| Commit format | Both | `<type>(<project>): <description>` |
