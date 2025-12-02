# Project Context

## Purpose
**VIVOTEK Vortex** is a comprehensive iOS surveillance and device management application for VIVOTEK IP cameras and network video recorders (NVR). The app provides:
- Real-time video streaming and monitoring from multiple VIVOTEK devices
- Remote device configuration and management
- Alarm and notification management with smart sensor capabilities
- Archive browsing and video export functionality
- Cloud storage integration via AWS
- VoIP/calling features for audio communication
- AI-powered search and analytics
- Multi-user/multi-organization support with reseller capabilities

## Tech Stack
### Core Technologies
- **Language:** Swift 6.0 (100% Swift codebase)
- **UI Framework:** SwiftUI (fully declarative, reactive UI)
- **Minimum Deployment:** iOS 17.0+
- **Data Persistence:** SwiftData (modern replacement for Core Data)
- **Concurrency:** Swift async/await, AsyncStream, Task-based concurrency
- **Package Manager:** Swift Package Manager (SPM)

### Key iOS Frameworks
- SwiftUI & SwiftData
- AVFoundation (audio/video handling)
- CoreLocation (location services)
- MetricKit (performance monitoring)
- UserNotifications (push notifications)
- Vision (image processing)
- Photos (photo library access)
- CoreTelephony (network detection)

### Major Dependencies
**Cloud & Backend:**
- AWS Amplify SDK (v2.51.0+) - Cloud services, storage, authentication
- Firebase (v12.3.0+) - Analytics, Crashlytics, Remote Config

**Real-time Communication:**
- WebRTC (v140.0.0+) - Video streaming
- Linphone SDK (5.4.14-novideo branch) - VoIP/calling

**Media & UI:**
- Kingfisher (v8.5.0+) - Image caching/downloading
- Lottie (v4.5.2+) - Animations
- Google Maps/Places (v10.3.0+/v10.1.0+) - Location services

**Utilities:**
- swift-dependencies (v1.10.0+) - Dependency injection framework
- swift-collections, swift-algorithms - Standard library extensions
- Mixpanel (v5.1.0+) - Analytics
- SwiftOTP (v3.0.2+) - Two-factor authentication
- CodeScanner (v2.0.0+) - QR code scanning
- ZipArchive (v2.6.0+) - Archive handling

**Internal Packages:**
- VIVOTEKiOSSDK - Proprietary VIVOTEK device communication SDK
- VortexFeatures - Modular feature library (SPM package)

## Project Conventions

### Code Style
The project uses **SwiftFormat** for automated code formatting with the following conventions:

**Formatting Rules:**
- **Indentation:** 4 spaces (no tabs)
- **Line Width:** Maximum 180 characters
- **Import Organization:** Sorted and separated by blank lines
- **Spacing:** Consistent spacing around operators, braces, brackets, comments
- **Modifiers:** Standardized order (access control, static, final, etc.)
- **Attributes:** Function and type attributes on previous line

**Enabled Features:**
- Sorted imports, declarations, and switch cases
- Trailing closures syntax
- Type sugar (`[Int]` over `Array<Int>`)
- Empty protocol syntax (`isEmpty` vs `.count == 0`)
- Conditional assignment expressions
- Doc comments over block comments

**Disabled Features:**
- `redundantSelf` - Self is allowed when preferred
- `redundantFileprivate` - Fileprivate is acceptable
- Forced wrapping of conditional bodies/loops
- Enum namespaces enforcement
- File headers

**Naming Conventions:**
- Types: PascalCase (e.g., `DeviceManager`, `HomeViewModel`)
- Properties/Methods: camelCase (e.g., `deviceList`, `fetchDevices()`)
- Constants: camelCase or UPPERCASE for global constants
- Protocols: PascalCase, often with `-able` suffix for capabilities

### Architecture Patterns

**Primary Pattern: MVVM with Dependency Injection**

The project follows a strict MVVM (Model-View-ViewModel) architecture with protocol-oriented design:

**View Layer (SwiftUI):**
- Pure SwiftUI views (no UIKit)
- Views observe ViewModels using `@StateObject` or `@ObservedObject`
- 39+ reusable component library in `View/Component/`
- View extensions for common UI patterns

**ViewModel Layer:**
- Conforms to `ObservableObject`
- Uses `@Published` properties for reactive state
- Handles business logic and coordinates services
- Uses `@Dependency` macro for service injection
- Examples: `HomeViewModel`, `ArchiveTabViewModel`, `SignInViewModel`

**ViewModel Error Handling Pattern:**
- ViewModels must inject `@Dependency(\.appManager) var appManager` for error handling
- Factory methods (`.make()`) must include `$0.appManager = AppManager.shared` in `withDependencies` block
- Use `appManager.handleError(error, defaultAlert:)` for user-facing data fetch errors
- `AppManager.handleError` has two overloads:
  - `handleError(_ error: Error)` - Let AppManager decide the alert
  - `handleError(_ error: Error, defaultAlert: AlertItem?)` - Provide fallback alert
- Common default alerts:
  - `AlertItem.failToLoad()` - For data loading failures
  - Pass `nil` to let AppManager handle specific errors (session expiry, access denied, etc.) without fallback
- **When to call handleError:**
  - Data fetching operations that impact UI (e.g., API calls, Manager data loading)
  - Any error that requires user notification or action
- **When to only log:**
  - Cache misses or expected "not found" scenarios
  - Non-critical background operations
  - Internal state validations
- Error handling must be done on `@MainActor` (AppManager.handleError is @MainActor)
- Always set loading states to `false` after error handling

**Model & Services Layer:**
- Domain models (plain Swift structs/classes)
- Manager classes for core functionality (e.g., `DeviceManager`, `AppManager`)
- Protocol-based abstraction for testability
- Service dependencies injected via `swift-dependencies` framework

**Modular Package Structure:**
The `VortexFeatures` SPM package separates concerns into modules:
- `AWSServices` - AWS/Amplify integration
- `HttpServices` - HTTP communication layer
- `OdysseyServices` - Backend API services (WebRTC-based)
- `CallServices` - VoIP/calling capabilities
- `VortexEnvironment` - Configuration management
- `VortexLogger` - Centralized logging
- `VortexError` - Error handling framework

**Key Architectural Principles:**
- Protocol-oriented design for testability
- Dependency injection for loose coupling
- Async/await for asynchronous operations
- Single responsibility per module/class
- Feature toggles for gradual rollouts (`FeatureProvider`)

**Manager & Dependency Layer Architecture:**

For major features that require centralized data management and cross-module usage, follow the Manager pattern:

**When to Create a Manager:**
- Feature has multiple sub-features sharing the same data structure
- Feature data/logic needs to be accessed from multiple parts of the app
- Examples: `DeviceManager`, `ArchiveFileManager`, `ResellerManager`

**Manager Implementation Guidelines:**
- **Location:** Place in `VortexFeatures/Sources/VortexFeatures/Core/` package
- **Pattern:** Singleton with `.shared` accessor
- **Dependencies:** Use `@Dependency` macro for service injection (via swift-dependencies framework)
- **Data Flow:** Provide `AsyncStream` via `xxxValues()` methods for reactive subscriptions
- **State:** Use `@Published` properties internally, convert to `AsyncStream` for external consumers
- **Error Handling:** Managers should throw errors to caller (ViewModel layer), NOT call `AppManager.handleError`
  - Managers are data layer, not UI layer
  - Let ViewModels decide how to present errors to users
  - Managers should log errors for debugging purposes
- **Example Structure:**
  ```swift
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
              logger.error("Failed to fetch data: \(error)")
              throw error  // Throw to ViewModel, don't call handleError
          }
      }

      public func dataValues() async -> AsyncStream<[Item]> {
          await Utility.createAsyncStream(from: $data)
      }
  }
  ```

**Dependency Protocol Pattern:**

For features requiring abstraction and testability, define a Dependency protocol:

- **Protocol:** Define interface in `OrganizationDependency.swift` style
- **Implementation:** Concrete class (e.g., `MyOrganizationInfo`) implements protocol
- **Registration:** Register via `DependencyValues` extension
- **Usage:** Inject via `@Dependency(\.dependencyName)` in ViewModels/Managers
- **Reactive Data:** Provide `AsyncStream<T>` methods for observable values
- **Example:**
  ```swift
  public protocol FeatureDependency {
      func valuesStream() async -> AsyncStream<[Item]>
      func getValue() async -> Item
  }

  // Implementation uses @Published + AsyncStream pattern
  final class FeatureDependencyImpl: FeatureDependency {
      @Published private var items: [Item] = []

      func valuesStream() async -> AsyncStream<[Item]> {
          await Utility.createAsyncStream(from: $items)
      }
  }
  ```

### Testing Strategy

**Unit Testing:**
- Location: `iOSCharmanderTests/Test/` (18,093+ lines of test code)
- Framework: XCTest
- Coverage areas:
  - OdysseyClient (backend communication)
  - SnoozeRule logic
  - View models and business logic
  - Extensions and utilities
  - Feature toggles
  - Alarm, Message, Archive, Export modules
- Mock data provided in `Test/Mock/` directory
- Network mocking via `URLProtocolMock`

**Integration Testing:**
- Tests within VortexFeatures SPM packages
- `AWSServicesTests` for cloud integration
- Service layer integration tests

**UI Testing:**
- Location: `iOSCharmanderUITests/` (17 test suites)
- Framework: XCUITest
- Coverage:
  - Device management flows
  - Sign-in/authentication
  - Video capture and playback
  - User operations
  - NVR functionality
  - Organization management
  - License management
  - MFA settings
  - Floor Plan viewing and camera selection
- Separate `iOSCloudSightUITests` for cloud sight features
- Test plan: `TestPlan.xctestplan`

**UI Test Implementation Rules:**

**Basic Principles:**
- Always check if `UATHelper` provides relevant APIs before implementing test actions
- Use `UATHelper` APIs when available to ensure consistent test behavior across the test suite
- Tests typically require user authentication - consult with the user to determine which test account to use or whether to create a new test account

**File Management:**
- When adding new UI test files to `iOSCharmanderUITests/`, the Xcode project file must be updated
- After adding test files, always build the project to verify there are no errors
- Follow the same file management rules as adding files outside VortexFeatures package

**Accessibility Pattern for UI Testing:**
- Use `accessibilityIdentifier` for element location
- Use `accessibilityValue` for element state tracking (similar to UATButtonView pattern)
- Example pattern:
  ```swift
  .accessibilityIdentifier("cameraMarker_{id}")
  .accessibilityValue(isSelected ? "selected" : "unselected")
  ```
- This allows tests to verify both element existence and state

**Test Operation Abstraction:**
- Create protocol-based operation interfaces (e.g., `FloorPlanOperation: CommonOperation`)
- Define reusable test actions as protocol methods
- Implement operations in protocol extensions for code reuse
- Keep operation methods focused and single-purpose
- Example: `func selectCamera(deviceName:)`, `func verifyCameraSelected(deviceName:)`

**Wait and Verification Strategy:**
- Use `UATHelper.waitElementToAppear()` for element existence checks (use default timeout)
- Use `UATHelper.waitElementToDisappear()` for element removal verification
- Use `UATHelper.waitElementToTap()` for interactive elements
- Avoid explicit `sleep()` - prefer UATHelper wait methods with default timeout values
- Use `waitForPredicate()` with timeout for state changes (default: 10 seconds)
- Use `XCTContext.runActivity` to provide clear step names in test reports
- Always verify state using `accessibilityValue` when available, not just element presence

**Test Method Naming Conventions:**
- Test methods: `testFeatureName()` (e.g., `testSelectCameraByTappingMarker`)
- Action methods: `tapXxx()`, `selectXxx()`, `deselectXxx()`, `openXxx()`, `closeXxx()`
- Verification methods: `verifyXxx()` (e.g., `verifyCameraSelected()`)
- Helper methods: private with clear intent (e.g., `verifyElementValue()`)

**Element Location Best Practices:**
- Avoid: `app.buttons.firstMatch` (too risky, might find wrong element)
- Prefer: `app.buttons["identifier"]` (explicit identifier)
- Acceptable: `app.buttons.containing(NSPredicate(format: "label CONTAINS 'icon'"))` (specific predicate)
- Always use the most specific locator available
- Verify element type matches (e.g., use `scrollViews` for ScrollView, not `otherElements`)

**Test Data Management:**
- Document test data requirements in test file comments or spec
- Use consistent test account and test data across test suite
- Define test data as constants at top of test class:
  ```swift
  private let testFloorPlanSite = "Ungrouped Cameras"
  private let testFloorPlanName = "main floor"
  private let testCamera1 = "device-serial-123"
  ```
- Coordinate with team on test account usage to avoid conflicts

**Test Infrastructure Maintenance:**
- Regularly review and remove unused test helper methods
- Keep operation protocols lean (only include actively used methods)
- Inline simple operations instead of creating single-use helper methods
- Document complex test helpers with clear comments
- Aim for <200 lines per operation protocol extension

**Assertions and Error Handling:**
- Never use `XCTExpectFailure` for actual test verification (it marks failures as expected)
- Use `XCTAssertTrue`, `XCTAssertFalse`, `XCTAssertEqual` for real assertions
- Provide clear failure messages with context:
  ```swift
  XCTAssertTrue(condition, "Expected X but got Y")
  ```
- Use `verifyElementValue()` pattern for timeout-based state verification

**Testing Requirements:**
- All new ViewModels must have unit tests
- Critical business logic requires 80%+ coverage
- UI tests for major user flows
- Mock all external dependencies (network, device SDK)
- Use dependency injection for testability

**Testing Error Handling in ViewModels:**
- Use `MockAppManager` with appropriate closure to capture error handling calls
- For `handleError(error, defaultAlert:)` use `_handleErrorWithDefaultAlert` closure
- For `handleError(error)` use `_handleError` closure
- Test pattern:
  ```swift
  var handledError: Error?
  let mockAppManager = MockAppManager(
      _handleErrorWithDefaultAlert: { error, defaultAlert in
          handledError = error
      }
  )
  // ... run test
  #expect(handledError != nil)  // Verify error was handled
  #expect((handledError as? VortexError) == .expectedError)
  ```
- Always verify error handling is called for data fetch errors
- Verify error handling is NOT called for expected scenarios (e.g., cache misses)
- Verify UI state is correct after error (e.g., `isLoading == false`)

### Git Workflow

**Branch Strategy:**
- **main** - Production-ready code (main branch for PRs)
- **Feature branches** - Named descriptively (e.g., `floorMap`, feature-specific names)
- Branch from `main` for new features
- Merge back to `main` via pull requests

**Commit Conventions:**
The project follows **Conventional Commits** format with project name prefix:
- Format: `<type>(<project>): <description>`
- Project names: `Vortex` or `CloudSight`
- Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, etc.
- Examples:
  - `feat(Vortex): add floor plan device selection`
  - `fix(CloudSight): resolve thread issue in video streaming`
  - `refactor(Vortex): update icon and layout`
- Reference ticket IDs when applicable (e.g., `[VOR-24280]`)
- Multi-line commits for complex changes
- Keep descriptions concise and focus on what changed
- When mentioning files, use filename only (not full path)
- **IMPORTANT:** Always confirm the project name (Vortex or CloudSight) with the user if uncertain

**Workflow:**
- Pull requests required for merging to main
- CI/CD via Fastlane and GitHub Actions
- Automated testing runs on CI
- Code review before merge

### Development Rules

**File Management:**
- **Adding files outside VortexFeatures package:**
  - When adding new files to the main project (not Swift Package modules), the Xcode project file must be updated to include them in the project
  - After adding any new files, always build the project to verify there are no errors
  - Files added to VortexFeatures SPM package are automatically included and don't require project file updates
- **Modifying project.pbxproj:**
  - When adding file references to project.pbxproj, use relative paths following the project's existing format
  - Do NOT use absolute/complete file paths
  - Follow the path format already established in the project file (e.g., relative to project root or group)

**API Integration:**
- **Location:** All new APIs must be added to the `VortexFeatures` package
  - RESTful APIs: Follow patterns in `VortexRestfulApi` folder
  - GraphQL APIs: Follow patterns in `VortexApi` folder
- **RESTful API Naming:**
  - Method names must start with HTTP method prefix: `getXxx()`, `postXxx()`, `putXxx()`, `deleteXxx()`
  - Example: `getDeviceList()`, `postCreateUser()`, `putUpdateDevice()`
- **GraphQL API Naming:**
  - Method names should match the GraphQL operation name
  - Example: `listMyOrganization()`, `createDevice()`, `queryMessage()`
  - No HTTP method prefix needed for GraphQL
- **API Response Models:**
  - All API response models must conform to `VortexBackendModel` protocol
  - Place models in `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/` directory
  - Organize by domain (e.g., `Organization/`, `Device/`, `Message/`)
  - API enums should conform to `SafeDecodableEnum` for safe decoding of unknown values
- **GraphQL Response Keys:**
  - Define reusable GraphQL response field fragments in `VortexApiKey` struct
  - Example: `myOrganizationColumns`, `deviceInfo`, `message`
  - Reuse fragments across queries for consistency
- **Model Layer Separation:**
  - Separate API models from internal domain models for flexibility
  - API Model (VortexBackendModel) ↔ Internal Model conversion in Manager/Dependency layer
  - Exception: Simple display-only data can use API models directly in UI
  - This separation allows API changes without affecting UI layer
- **Error Handling:**
  - All backend errors must be converted to the project's unified `VortexError` type
  - Common/shared errors should be added to the `handleErrorData` method
  - API-specific errors should be handled in a dedicated extension for that API module
- **Structure:** Follow existing API service patterns for consistency

**Feature Toggles & Dark Release:**

The project uses `FeatureToggle` (conforming to `FeatureProvider` protocol) for centralized feature control:

**Dark Release Control:**
- **Purpose:** Gradually roll out features to specific organizations
- **Implementation:** Backend controls via `MyOrganization.SupportFeature` enum
- **Location:**
  - Enum definition: `VortexFeatures/Common/VortexBackend/Model/Organization/MyOrganization.swift`
  - Usage: `iOSCharmander/Common/FeatureProvider/FeatureToggle.swift`
- **How it works:**
  1. Add new feature to `MyOrganization.SupportFeature` enum (e.g., `case floorPlan = "FloorPlan"`)
  2. Backend includes/excludes feature in `listMyOrganization` API response's `support` field
  3. `FeatureToggle` checks `myOrganizationSupportFeatures.contains(.featureName)` before showing feature
- **Example:**
  ```swift
  // In MyOrganization.swift
  public enum SupportFeature: String, VortexBackendModel {
      case licensePlateRecognition = "LicensePlateRecognition"
      case spotOccupancy = "SpotOccupancy"
      case floorPlan = "FloorPlan"  // New feature
  }

  // In FeatureToggle.swift
  case .floorPlan:
      myOrganizationSupportFeatures.contains(.floorPlan) &&
      !sites.allSatisfy { privilegeProvider.canDo(.group(siteID: $0.id), .read) == false }
  ```

**Feature Toggle Method Patterns:**

Three distinct methods control different aspects of feature availability:

1. **`canViewTab(_ tab: HomeViewTab) -> Bool`**
   - Controls whether a tab/feature appears in the UI
   - Check order: Dark Release → Permissions → Other conditions
   - Remove tab completely if checks fail

2. **`canTriggerTab(_ tab: HomeViewTab) -> Bool`**
   - Controls whether a visible tab can be interacted with
   - Used for license-based restrictions
   - Shows tab but disables interaction (grayed out state)
   - Calls `tabCanDisable()` to check if tab supports disabled state

3. **`tabCanDisable(_ tab: HomeViewTab) -> Bool`**
   - Defines which tabs can be shown in disabled state during license issues
   - Tabs like `.floorPlan`, `.message`, `.archive` return `true`
   - Allows users to see features exist but cannot use due to license

**Check Priority:**
```
Dark Release Check → Permission Check → License Check → Feature-specific Logic
     (canViewTab)      (canViewTab)    (canTriggerTab)
```

**Localization & Translations:**
- **String Key Format:**
  - Remove special characters, punctuation, and spaces from localization keys
  - Replace spaces with underscores (`_`)
  - Example: `"Hello, World!"` → key: `Hello_World`
- **Non-English Languages:**
  - For languages like Chinese (中文) and Japanese (日本語), initially paste the English string as the translation
  - Mark the translation status as "Mark for review" (需要審核)
  - Native translations will be reviewed and updated later
- **Product Name Placeholders:**
  - When strings contain product names ("Vortex" or "CloudSight"), replace them with placeholders
  - Use `VortexEnvironment.productNameLocalized` to provide the actual product name at runtime
  - For multiple parameters, use positional placeholders: `%1$@`, `%2$@`, `%3$@` (strings) or `%1$ld`, `%2$ld` (integers)
  - Example: See `SignInView.userAgreement` implementation
  - Swift usage:
    ```swift
    localized: "Welcome_to_\(VortexEnvironment.productNameLocalized)_with_\(deviceCount)_devices"
    ```
  - Localizable.xcstrings format:
    - Key: `"Welcome_to_%@_with_%ld_devices"`
    - English: `"Welcome to %1$@ with %2$ld devices"`
    - Chinese: `"歡迎使用 %1$@，共有 %2$ld 個裝置"`

## Domain Context

**Surveillance & Device Management Domain:**

**VIVOTEK Devices:**
- IP cameras (network cameras with various PTZ capabilities)
- NVR (Network Video Recorders) for centralized recording
- Fisheye cameras with dewarping capabilities
- Smart sensors with AI capabilities

**Core Concepts:**
- **Channels:** Video streams from devices (cameras can have multiple channels)
- **Archives:** Recorded video segments stored on device or cloud
- **Events/Alarms:** Motion detection, sensor triggers, AI-detected events
- **Snapshots/Thumbnails:** Still images from video streams
- **Customized Views:** User-defined layouts for monitoring multiple cameras
- **Snooze Rules:** Flexible rules to temporarily silence alarms
- **Licenses:** Device activation and feature licensing
- **Organizations/Resellers:** Multi-tenant support for different organizations

**Communication Protocols:**
- WebRTC for real-time video streaming
- RTSP/HTTP for device communication
- AWS for cloud storage and services
- Push notifications for alerts

**User Roles:**
- End users (home/business monitoring)
- Administrators (device and user management)
- Resellers (multi-organization management)

## Important Constraints

**Technical Constraints:**
- iOS 17.0+ minimum deployment target
- Must support iPhone and iPad (universal app)
- Real-time video streaming requires stable network connection
- Background task limitations (iOS background execution constraints)
- SwiftUI-only codebase (no UIKit except for necessary bridging)
- Must handle offline scenarios gracefully

**Performance Constraints:**
- Smooth video playback (30fps target)
- Low latency for real-time streaming
- Efficient memory usage for multiple video streams
- Battery-efficient background operation
- Thumbnail caching for performance

**Security & Privacy:**
- Privacy manifest required (`PrivacyInfo.xcprivacy`)
- Secure credential storage
- Two-factor authentication support
- Encrypted video streaming
- Compliance with App Store privacy requirements
- No data collection without user consent

**Business Constraints:**
- VIVOTEK device compatibility required
- License validation for premium features
- Support for legacy device firmware versions
- Multi-language support (extensive localization)

**Regulatory:**
- App Store guidelines compliance
- GDPR/privacy regulation compliance
- Location services privacy requirements
- Camera/microphone permission handling

## External Dependencies

**Cloud Services:**
- **AWS Amplify:** User authentication, cloud storage, API Gateway
- **Firebase:** Analytics, crash reporting, remote configuration, A/B testing
- **Mixpanel:** User analytics and behavior tracking

**Real-time Communication:**
- **WebRTC:** Peer-to-peer video streaming infrastructure
- **Linphone:** SIP-based VoIP calling

**Maps & Location:**
- **Google Maps SDK:** Map display and interaction
- **Google Places SDK:** Location search and autocomplete
- **CoreLocation:** Device location services

**Backend Systems:**
- **Odyssey Backend:** VIVOTEK's proprietary backend for device management
- **VIVOTEK Device API:** Direct device communication (via VIVOTEKiOSSDK)
- **Cloud Storage:** S3 for archived video storage

**Third-party Services:**
- **Push Notification Service:** Apple Push Notification service (APNs)
- **Certificate Authority:** For SSL/TLS certificate validation

**Development & CI/CD:**
- **Fastlane:** Build automation and deployment
- **GitHub Actions:** Continuous integration
- **SwiftFormat:** Code formatting automation
- **XCTest:** Testing framework (built-in)
