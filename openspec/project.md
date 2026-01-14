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
- **Minimum Deployment:** iOS 18.0+
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

**Primary Pattern: MVVM with Dependency Injection (iOS 17+ Observation)**

The project uses iOS 17+ Observation framework. For architecture decisions (when to use ViewModel vs Manager, where logic belongs), see the `architecting-viewmodel-manager` skill.

**ViewModel Implementation:**

- **Location:** Feature-specific directories (e.g., `iOSCharmander/View/Home/Tab/FloorPlanTab/`)
- **Naming:** `XxxViewModel` (e.g., `FloorPlanTabViewModel`)

```swift
import SwiftUI
import Observation
import Dependencies

@MainActor
@Observable
final class MyFeatureViewModel {
    // MARK: - Dependencies (must use @ObservationIgnored)
    @ObservationIgnored
    @Dependency(\.myManager) private var myManager
    @ObservationIgnored
    @Dependency(\.appManager) private var appManager

    // MARK: - Observable State
    var items: [Item] = []
    var isLoading = false
    var searchText = ""

    // MARK: - Non-observed State
    @ObservationIgnored
    private var cache: [String: Any] = [:]

    // MARK: - Factory Method
    static func make() -> MyFeatureViewModel {
        withDependencies {
            $0.appManager = AppManager.shared
            $0.myManager = MyManager.shared
        } operation: {
            MyFeatureViewModel()
        }
    }

    // MARK: - Data Loading
    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            items = try await myManager.fetchItems()
        } catch {
            appManager.handleError(error, defaultAlert: .failToLoad())
        }
    }
}
```

**View with ViewModel:**

```swift
struct MyFeatureView: View {
    @State private var viewModel = MyFeatureViewModel.make()

    var body: some View {
        @Bindable var viewModel = viewModel  // Create bindable for $ bindings

        List(viewModel.items) { item in
            Text(item.name)
        }
        .searchable(text: $viewModel.searchText)
        .task { await viewModel.loadData() }
    }
}

// Child view needing bindings
struct ChildEditView: View {
    @Bindable var viewModel: MyFeatureViewModel

    var body: some View {
        TextField("Search", text: $viewModel.searchText)
    }
}

// With @Environment
struct SettingsView: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        @Bindable var settings = settings
        Toggle("Dark Mode", isOn: $settings.isDarkMode)
    }
}
```

**ViewModel Error Handling:**
- Use `appManager.handleError(error, defaultAlert:)` for user-facing errors
- Common alerts: `AlertItem.failToLoad()`, or `nil` to let AppManager decide
- Always set `isLoading = false` after error handling (use `defer`)

**Manager Implementation:**

- **Location:** `VortexFeatures/Sources/VortexFeatures/Core/XxxManager/`
- **Naming:** `XxxManager` with `.shared` singleton accessor

**Dependency Registration:**

```swift
extension DependencyValues {
    var myManager: MyManagerProtocol {
        get { self[MyManagerKey.self] }
        set { self[MyManagerKey.self] = newValue }
    }
}

private enum MyManagerKey: DependencyKey {
    static let liveValue: MyManagerProtocol = MyManager.shared
    static let testValue: MyManagerProtocol = MockMyManager()
}
```

**Modular Package Structure:**

The `VortexFeatures` SPM package separates concerns into modules:
- `AWSServices` - AWS/Amplify integration
- `HttpServices` - HTTP communication layer
- `OdysseyServices` - Backend API services (WebRTC-based)
- `CallServices` - VoIP/calling capabilities
- `VortexEnvironment` - Configuration management
- `VortexLogger` - Centralized logging
- `VortexError` - Error handling framework

### Testing Strategy

**Unit Testing:**
- Location: `iOSCharmanderTests/Test/`
- Framework: Swift Testing (`import Testing`) for all new tests
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
- Location: `iOSCharmanderUITests/`
- Framework: XCUITest
- Separate `iOSCloudSightUITests` for cloud sight features
- Test plan: `TestPlan.xctestplan`
- **Implementation Guide:** See `uitest-automation/WRITING_GUIDE.md`

**Testing Requirements:**
- All new ViewModels must have unit tests
- Critical business logic requires 80%+ coverage
- UI tests for major user flows
- Mock all external dependencies (network, device SDK)
- Use dependency injection for testability

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
  - RESTful APIs: `VortexFeatures/Sources/VortexFeatures/VortexRestfulApi/`
  - GraphQL APIs: `VortexFeatures/Sources/VortexFeatures/VortexApi/`
  - Response Models: `VortexFeatures/Sources/VortexFeatures/VortexBackend/Model/`

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
- iOS 18.0+ minimum deployment target
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
