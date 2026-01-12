---
name: implement-vortex-feature
description: Implements Vortex iOS features following MVVM, API integration, testing, localization, and git conventions. Auto-triggers for ViewModels, APIs, tests, feature toggles, and commits.
---

# Vortex Feature Implementation Guide

This skill provides essential conventions and patterns for implementing features in the VIVOTEK Vortex iOS app.

**When to use this guide**: Implementing new features, adding APIs, creating ViewModels/Managers, writing tests, feature toggles, localization, or any Vortex development task.

**Supporting Documentation**:
- **Detailed guides**: See supporting files in this skill directory
- **Full project context**: `openspec/project.md` (580+ lines)

---

## Quick Reference

### Common Patterns
- **MVVM Architecture**: View → ViewModel (ObservableObject) → Model/Manager
- **Dependency Injection**: Use `@Dependency(\.serviceName)` via swift-dependencies
- **Error Handling**: ViewModels call `appManager.handleError(error, defaultAlert:)`
- **Reactive Data**: Use `@Published` + `AsyncStream` for observable values
- **Testing**: Use Swift Testing (`import Testing`), mock all dependencies, 80%+ coverage

### Project Basics
- **Language**: Swift 6.0 (100% Swift, no Objective-C)
- **UI**: SwiftUI only (no UIKit except necessary bridging)
- **Min iOS**: 18.0+
- **Concurrency**: async/await, AsyncStream, Task-based
- **Formatting**: SwiftFormat enforced (4 spaces, 180 char line width)

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

**Full details**: See `openspec/project.md` lines 155-225

---

## API Integration

**Quick Guide**:
- **Location**: `VortexFeatures` package (`VortexRestfulApi` or `VortexApi` folder)
- **RESTful APIs**: HTTP method prefix (`getDeviceList()`, `postCreateUser()`)
- **GraphQL APIs**: Operation name (`listMyOrganization()`, `createDevice()`)
- **Response Models**: Conform to `VortexBackendModel`, place in `VortexBackend/Model/`
- **Model Separation**: API Model ↔ Internal Model (in Manager/Dependency)
- **Error Handling**: Convert to `VortexError`

**Full details**: See `api-patterns.md` in this skill directory

---

## Testing Strategy

**Unit Testing** (`iOSCharmanderTests/Test/`):
- **Framework**: Swift Testing (`import Testing`) - Use for all new tests
- **Coverage**: 80%+ for business logic
- **Mocking**: Mock all external dependencies (network, device SDK)
- **Error Testing**: Use `MockAppManager` with `_handleErrorWithDefaultAlert` closure
- **Full details**: See `testing-guide.md` in this skill directory

**UI Testing** (`iOSCharmanderUITests/`):
- **Framework**: XCUITest
- **Writing new tests**: Use `/write-uitest` command for guided workflow
- **Patterns & conventions**: See `uitest-patterns.md` in this skill directory

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

## Git Workflow & Repository Structure

### ⚠️ CRITICAL: Two-Repo Architecture

**Main Repo** (`iOSCharmander`): iOS app source code
**AI Specs Repo** (`iOSCharmander-ai-specs`): OpenSpec docs + AI configurations

**When modifying `openspec/` or `.claude/`**:
- ❌ **NEVER** commit in main `iOSCharmander` repo
- ✅ **ALWAYS** use `iOSCharmander-ai-specs` repo

### Commit Format

`<type>(<project>): <description>`

**Projects**: `Vortex` or `CloudSight`
**Types**: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`

**Example**: `feat(Vortex): add floor plan device selection`

**Full details**: See `git-workflow.md` in this skill directory

---

## File Management

**Adding files outside VortexFeatures**:
1. Update Xcode project file to include new files
2. Build project to verify no errors
3. Files in VortexFeatures SPM package auto-included (no project file update needed)

**Modifying project.pbxproj**: Use **relative paths** (not absolute)

---

## References

**Supporting Files** (in this skill directory):
- `api-patterns.md` - API integration patterns and conventions
- `git-workflow.md` - Git operations and two-repo architecture
- `testing-guide.md` - Unit testing with Swift Testing framework

**Full Documentation**: See `openspec/project.md` for:
- Detailed tech stack and dependencies
- Complete SwiftFormat rules
- Domain context (surveillance, devices, protocols)
- Performance and security constraints

**OpenSpec Commands**:
- `openspec list` - See active proposals
- `openspec list --specs` - See existing capabilities
