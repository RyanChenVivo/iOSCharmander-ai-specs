---
name: implement-vortex-feature
description: Guide for implementing Vortex iOS app features. Auto-triggers when developing features, adding APIs, creating ViewModels, writing tests, implementing feature toggles, adding translations, or making commits. Provides project conventions, architecture patterns, and best practices.
---

# Vortex Feature Implementation Guide

This skill provides essential conventions and patterns for implementing features in the VIVOTEK Vortex iOS app.

**When to use this guide**: Implementing new features, adding APIs, creating ViewModels/Managers, writing tests, feature toggles, localization, or any Vortex development task.

**Full details**: See `openspec/project.md` for comprehensive documentation (580+ lines).

---

## Quick Reference

### Common Patterns
- **MVVM Architecture**: View → ViewModel (ObservableObject) → Model/Manager
- **Dependency Injection**: Use `@Dependency(\.serviceName)` via swift-dependencies
- **Error Handling**: ViewModels call `appManager.handleError(error, defaultAlert:)`
- **Reactive Data**: Use `@Published` + `AsyncStream` for observable values
- **Testing**: Mock all external dependencies, 80%+ coverage for business logic

### Project Basics
- **Language**: Swift 6.0 (100% Swift, no Objective-C)
- **UI**: SwiftUI only (no UIKit except necessary bridging)
- **Min iOS**: 18.0+
- **Concurrency**: async/await, AsyncStream, Task-based
- **Formatting**: SwiftFormat enforced (4 spaces, 180 char line width)

---

## Repository Structure & Git Operations

### CRITICAL: Two-Repo Architecture

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

**Rules**:
- ❌ DO NOT commit `openspec/` or `.claude/` in main `iOSCharmander` repo
- ✅ ALWAYS navigate to `iOSCharmander-ai-specs` first
- ✅ Specs/AI configs push directly to `main` branch
- ✅ App code uses feature branches + PRs

---

## Code Style & Formatting

### Naming Conventions
- **Types**: PascalCase (`DeviceManager`, `HomeViewModel`)
- **Properties/Methods**: camelCase (`deviceList`, `fetchDevices()`)
- **Protocols**: PascalCase, often with `-able` suffix for capabilities

### SwiftFormat Key Rules
- **Indentation**: 4 spaces (no tabs)
- **Line Width**: 180 characters max
- **Imports**: Sorted and separated by blank lines
- **Type Sugar**: Use `[Int]` over `Array<Int>`
- **Trailing Closures**: Enabled
- **Self**: Allowed when preferred (redundantSelf disabled)

**Apply formatting**: SwiftFormat runs automatically; follow existing code style.

---

## Architecture Patterns

### MVVM with Dependency Injection

**Pattern**: View → ViewModel (ObservableObject) → Model/Manager

**ViewModel Structure**:
- Conform to `ObservableObject`, use `@Published` for reactive state
- Inject dependencies via `@Dependency(\.serviceName)`
- Factory method `.make()` sets up `AppManager.shared` and other dependencies
- Handle errors via `appManager.handleError(error, defaultAlert: .failToLoad())`

**ViewModel Error Handling**:
- ✅ Call `handleError` for: Data fetching, user-facing errors
- ❌ Don't call for: Cache misses, non-critical background ops
- Always on `@MainActor`, set `isLoading = false` after errors

### Manager & Dependency Layer

**When to Create a Manager**: Multi-feature data sharing, cross-module access
**Location**: `VortexFeatures/Sources/VortexFeatures/Core/`
**Pattern**: Singleton (`.shared`), `@Published` + `AsyncStream`, `@Dependency` injection

**Manager Error Handling**:
- ❌ MUST NOT call `AppManager.handleError` (data layer, not UI)
- ✅ Throw errors to ViewModel, log for debugging

**Dependency Protocol Pattern**: Define protocol → Implement with `@Published` → Register in `DependencyValues`

---

## API Integration

**Location**: `VortexFeatures` package (`VortexRestfulApi` or `VortexApi` folder)

**Naming Conventions**:
- RESTful: HTTP method prefix (`getDeviceList()`, `postCreateUser()`)
- GraphQL: Operation name (`listMyOrganization()`, `createDevice()`)

**Response Models**:
- Location: `VortexFeatures/.../VortexBackend/Model/`
- Conform to `VortexBackendModel`
- Enums use `SafeDecodableEnum`
- GraphQL: Define reusable fragments in `VortexApiKey`

**Model Separation**: API Model (VortexBackendModel) ↔ Internal Model (in Manager/Dependency)

**Error Handling**: Convert to `VortexError` (common: `handleErrorData`, API-specific: extension)

---

## Testing Strategy

**Unit Testing** (`iOSCharmanderTests/Test/`):
- Framework: XCTest, 80%+ coverage for business logic
- Mock all external dependencies (network, device SDK)
- Use `MockAppManager` with `_handleErrorWithDefaultAlert` closure to verify error handling
- Verify: Error handled, correct error type, UI state reset (`isLoading = false`)

---

## Feature Management

**Location**: `iOSCharmander/Common/FeatureProvider/FeatureToggle.swift`

**Dark Release**: Backend controls via `MyOrganization.SupportFeature` enum
- Add feature case → Backend includes/excludes in API → FeatureToggle checks

**Three Control Methods**:

1. **`canViewTab(_ tab: HomeViewTab) -> Bool`**
   - Controls tab visibility in UI
   - Check order: Dark Release → Permissions → Other
   - Remove tab if fails

2. **`canTriggerTab(_ tab: HomeViewTab) -> Bool`**
   - Controls tab interaction (license-based)
   - Shows tab but disables interaction
   - Calls `tabCanDisable()`

3. **`tabCanDisable(_ tab: HomeViewTab) -> Bool`**
   - Which tabs can show in disabled state
   - Returns `true` for tabs like `.floorPlan`, `.message`, `.archive`

**Priority**: Dark Release → Permission → License → Feature-specific

---

## Localization

### String Key Format

**Remove special characters, replace spaces with underscores**:
```swift
"Hello, World!" → key: "Hello_World"
"Welcome to Vortex" → key: "Welcome_to_Vortex"
```

### Product Name Placeholders

**Replace product names with placeholders**:
```swift
// Swift usage
localized: "Welcome_to_\(VortexEnvironment.productNameLocalized)_with_\(deviceCount)_devices"

// Localizable.xcstrings format
// Key: "Welcome_to_%@_with_%ld_devices"
// English: "Welcome to %1$@ with %2$ld devices"
// Chinese: "歡迎使用 %1$@,共有 %2$ld 個裝置"
```

**Positional placeholders**: `%1$@`, `%2$@` (strings) or `%1$ld`, `%2$ld` (integers)

### Non-English Languages

- Initially paste English string as translation
- Mark as "需要審核" (Mark for review)
- Native translations updated later

---

## Git Workflow

### Commit Conventions

**Format**: `<type>(<project>): <description>`

**Projects**: `Vortex` or `CloudSight`
**Types**: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`

**Examples**:
```
feat(Vortex): add floor plan device selection
fix(CloudSight): resolve thread issue in video streaming
refactor(Vortex): update icon and layout
test(Vortex): add UI tests for camera selection
```

**Guidelines**:
- Reference ticket IDs when applicable (e.g., `[VOR-24280]`)
- Keep descriptions concise, focus on what changed
- Use filename only (not full path) when mentioning files
- **IMPORTANT**: Confirm project name (Vortex/CloudSight) with user if uncertain

### Branch Strategy

- **main**: Production-ready code (main branch for PRs)
- **Feature branches**: Descriptive names (e.g., `floorMap`, `feature-name`)
- Branch from `main` for new features
- Merge via pull requests with code review

---

## File Management

### Adding Files Outside VortexFeatures

**When adding to main project**:
1. Update Xcode project file to include new files
2. Build project to verify no errors
3. Files in VortexFeatures SPM package auto-included (no project file update needed)

### Modifying project.pbxproj

- Use **relative paths** (not absolute)
- Follow existing path format in project file
- Example: relative to project root or group

---

## References

**Full Documentation**: See `openspec/project.md` for:
- Detailed tech stack and dependencies
- Complete SwiftFormat rules
- Domain context (surveillance, devices, protocols)
- Performance and security constraints
- External dependencies and services

**OpenSpec Changes**: Run `openspec list` to see active proposals

**Existing Specs**: Run `openspec list --specs` to see capabilities
