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

**View Layer (SwiftUI)**:
```swift
struct MyView: View {
    @StateObject var viewModel = MyViewModel.make()

    var body: some View {
        // Pure SwiftUI, observe ViewModel via @Published
    }
}
```

**ViewModel Layer**:
```swift
class MyViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false

    @Dependency(\.appManager) var appManager
    @Dependency(\.apiClient) var apiClient

    static func make() -> MyViewModel {
        withDependencies {
            $0.appManager = AppManager.shared
        } operation: {
            MyViewModel()
        }
    }

    @MainActor
    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            items = try await apiClient.fetchItems()
        } catch {
            appManager.handleError(error, defaultAlert: .failToLoad())
        }
    }
}
```

**Key Points**:
- ViewModels conform to `ObservableObject`
- Use `@Published` for reactive state
- Inject dependencies via `@Dependency` macro
- Factory method `.make()` sets up dependencies
- Handle errors via `appManager.handleError()`

### ViewModel Error Handling Pattern

**MUST inject AppManager**:
```swift
@Dependency(\.appManager) var appManager
```

**Factory method includes AppManager**:
```swift
static func make() -> MyViewModel {
    withDependencies {
        $0.appManager = AppManager.shared
    } operation: {
        MyViewModel()
    }
}
```

**When to call handleError**:
- ✅ Data fetching that impacts UI (API calls, Manager loading)
- ✅ Any error requiring user notification/action
- ❌ Cache misses or expected "not found" scenarios
- ❌ Non-critical background operations

**Error Handling Methods**:
```swift
// Let AppManager decide the alert
appManager.handleError(error)

// Provide fallback alert for generic errors
appManager.handleError(error, defaultAlert: .failToLoad())
```

**Always**:
- Call on `@MainActor` (AppManager.handleError is @MainActor)
- Set loading states to `false` after error handling

### Manager & Dependency Layer

**When to Create a Manager**:
- Feature has multiple sub-features sharing data
- Data/logic accessed from multiple app parts
- Examples: `DeviceManager`, `ArchiveFileManager`, `ResellerManager`

**Manager Pattern**:
```swift
// Location: VortexFeatures/Sources/VortexFeatures/Core/
public final class FeatureManager: ObservableObject {
    public static let shared = FeatureManager()
    @Published private var data: [Item] = []

    @Dependency(\.apiClient) var apiClient
    private let logger = VortexLogger.make(type: .featureManager)

    public func fetchData() async throws -> [Item] {
        logger.trace("Fetching data")
        do {
            let items = try await apiClient.fetchItems()
            await MainActor.run { self.data = items }
            return items
        } catch {
            logger.error("Failed: \(error)")
            throw error  // Throw to ViewModel, DON'T call handleError
        }
    }

    public func dataValues() async -> AsyncStream<[Item]> {
        await Utility.createAsyncStream(from: $data)
    }
}
```

**Manager Error Handling**:
- ❌ Managers MUST NOT call `AppManager.handleError`
- ✅ Throw errors to caller (ViewModel layer)
- ✅ Log errors for debugging
- Managers are data layer, not UI layer

**Dependency Protocol Pattern**:
```swift
// Define protocol
public protocol FeatureDependency {
    func valuesStream() async -> AsyncStream<[Item]>
    func getValue() async -> Item
}

// Implementation uses @Published + AsyncStream
final class FeatureDependencyImpl: FeatureDependency {
    @Published private var items: [Item] = []

    func valuesStream() async -> AsyncStream<[Item]> {
        await Utility.createAsyncStream(from: $items)
    }
}

// Register in DependencyValues extension
extension DependencyValues {
    var featureDependency: FeatureDependency {
        get { self[FeatureDependencyKey.self] }
        set { self[FeatureDependencyKey.self] = newValue }
    }
}
```

---

## API Integration

### Location & Naming

**Location**: All new APIs in `VortexFeatures` package
- RESTful APIs: Follow `VortexRestfulApi` folder patterns
- GraphQL APIs: Follow `VortexApi` folder patterns

**RESTful API Naming** (HTTP method prefix):
```swift
func getDeviceList() async throws -> [Device]
func postCreateUser(name: String) async throws -> User
func putUpdateDevice(id: String) async throws -> Device
func deleteDevice(id: String) async throws
```

**GraphQL API Naming** (operation name):
```swift
func listMyOrganization() async throws -> [Organization]
func createDevice(input: DeviceInput) async throws -> Device
func queryMessage(id: String) async throws -> Message
```

### API Response Models

**Must conform to `VortexBackendModel`**:
```swift
// Location: VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/
struct DeviceResponse: VortexBackendModel {
    let id: String
    let name: String
    let status: DeviceStatus
}

// Enums should conform to SafeDecodableEnum
enum DeviceStatus: String, SafeDecodableEnum {
    case online = "online"
    case offline = "offline"
    case unknown = "unknown"
}
```

**GraphQL Response Keys**:
Define reusable fragments in `VortexApiKey`:
```swift
extension VortexApiKey {
    static let deviceInfo = """
        id
        name
        status
        """
}
```

### Model Layer Separation

**Separate API models from internal models**:
- API Model (VortexBackendModel) ↔ Internal Model conversion in Manager/Dependency
- Exception: Simple display-only data can use API models directly
- Benefits: API changes don't affect UI layer

### Error Handling

**Convert to VortexError**:
- Common/shared errors: Add to `handleErrorData` method
- API-specific errors: Handle in dedicated extension

---

## Testing Strategy

### Unit Testing

**Location**: `iOSCharmanderTests/Test/`
- Framework: XCTest
- Coverage: 80%+ for business logic
- Mock all external dependencies (network, device SDK)

**Testing ViewModel Error Handling**:
```swift
func testLoadDataHandlesError() async {
    var handledError: Error?
    let mockAppManager = MockAppManager(
        _handleErrorWithDefaultAlert: { error, defaultAlert in
            handledError = error
        }
    )

    let viewModel = MyViewModel()
    // ... trigger error

    #expect(handledError != nil)
    #expect((handledError as? VortexError) == .expectedError)
    #expect(viewModel.isLoading == false)
}
```

---

## Feature Management

### Feature Toggles & Dark Release

**Location**: `iOSCharmander/Common/FeatureProvider/FeatureToggle.swift`

**Backend Control via MyOrganization.SupportFeature**:
```swift
// VortexFeatures/Common/VortexBackend/Model/Organization/MyOrganization.swift
public enum SupportFeature: String, VortexBackendModel {
    case licensePlateRecognition = "LicensePlateRecognition"
    case spotOccupancy = "SpotOccupancy"
    case floorPlan = "FloorPlan"  // Add new feature here
}

// FeatureToggle.swift
case .floorPlan:
    myOrganizationSupportFeatures.contains(.floorPlan) &&
    !sites.allSatisfy { privilegeProvider.canDo(.group(siteID: $0.id), .read) == false }
```

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
