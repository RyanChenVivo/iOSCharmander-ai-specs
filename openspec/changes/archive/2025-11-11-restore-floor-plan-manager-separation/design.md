# Restore Floor Plan Manager Separation - Design Document

## Context

The floor plan feature was recently refactored to remove FloorPlanManager singleton and implement direct VortexRestfulApi dependency injection in ViewModels. While this achieved better testability, code review feedback identified architectural concerns about separation of concerns.

**Background:**
- Current architecture: ViewModels directly use `@Dependency(\.vortexRestfulApi)` for API calls
- ViewModels contain both UI logic and data transformation logic (violation of separation of concerns)
- FloorPlanItem and DevicePosition serve as both API response models and UI models (dual responsibility)
- Project uses MVVM architecture with Manager layer for data operations (DeviceManager, AppManager patterns)

**Constraints:**
- Must maintain all existing floor plan functionality
- Must keep all 39 existing unit tests passing
- Cannot change backend API contracts
- Must follow project's established patterns (DeviceManager as reference)
- iOS 17.0+ minimum deployment, Swift 6.0
- SwiftUI-only codebase with swift-dependencies for DI

**Stakeholders:**
- Code reviewers: Require proper separation of concerns
- Development team: Need maintainable, testable architecture
- End users: Should experience no behavior changes

## Goals / Non-Goals

**Goals:**
- Restore FloorPlanManager as dedicated data layer between UI and API
- Clearly separate Backend models (API layer) from UI models (Presentation layer)
- Move all API calls and data transformation from ViewModels to Manager
- Keep ViewModels focused exclusively on UI state and user interactions
- Achieve 80%+ test coverage for Manager layer
- Maintain zero regressions in existing functionality

**Non-Goals:**
- Adding new floor plan features
- Changing UI/UX design or interactions
- Modifying API endpoints or backend contracts
- Adding caching, persistence, or performance optimizations
- Changing test framework or patterns

## Architectural Layers

### Layer Overview

```
┌─────────────────────────────────────────────────┐
│              View Layer (SwiftUI)               │
│  - FloorPlanTabView                             │
│  - FloorPlanDetailView                          │
│  - Camera marker overlays                       │
└────────────────┬────────────────────────────────┘
                 │ @Published properties
                 │ User interactions
                 ▼
┌─────────────────────────────────────────────────┐
│           ViewModel Layer (UI Logic)            │
│  - FloorPlanTabViewModel                        │
│  - FloorPlanDetailViewModel                     │
│                                                  │
│  Responsibilities:                              │
│  - UI state (@Published properties)             │
│  - User interaction handlers (tap, zoom, etc)   │
│  - Navigation decisions (open detail, etc)      │
│  - SwiftUI lifecycle (onAppear, onChange)       │
└────────────────┬────────────────────────────────┘
                 │ @Dependency(\.floorPlanManager)
                 │ Uses: FloorPlanManagerProtocol
                 ▼
┌─────────────────────────────────────────────────┐
│         Manager Layer (Data Logic)              │
│  - FloorPlanManager                             │
│  - FloorPlanManagerProtocol                     │
│                                                  │
│  Responsibilities:                              │
│  - API calls via VortexRestfulApi               │
│  - Backend → UI model transformation            │
│  - Business logic (filtering, aggregation)      │
│  - Error handling and recovery                  │
└────────────────┬────────────────────────────────┘
                 │ @Dependency(\.vortexRestfulApi)
                 │ Uses: VortexRestfulApiProtocol
                 ▼
┌─────────────────────────────────────────────────┐
│           API Layer (Network)                   │
│  - VortexRestfulApi                             │
│  - Backend models (FloorPlanBackendModel)       │
│                                                  │
│  Responsibilities:                              │
│  - HTTP requests to backend                     │
│  - JSON decoding to Backend models              │
│  - Network error handling                       │
│  - Authentication headers                       │
└─────────────────────────────────────────────────┘
```

### Data Flow

**1. User opens floor plan tab:**
```
View.onAppear()
  → ViewModel.onViewAppear()
    → Manager.fetchAllFloorPlans(sites: [SiteItem]) async throws
      → API.getFloorPlans(siteID: String) async throws
        → Returns: [FloorPlanBackendModel]
      ← Transform to [FloorPlanItem] (UI models)
    ← Returns: [FloorPlanItem]
  ← Update @Published var floorPlans: [FloorPlanItem]
← View refreshes with new data
```

**2. User taps floor plan:**
```
View.onTapGesture
  → ViewModel.tapFloorPlan(FloorPlanItem)
    → SheetManager.openFloorPlanDetail(floorPlan)
      → Present FloorPlanDetailView
```

**3. Floor plan detail loads device positions:**
```
DetailView.onAppear()
  → DetailViewModel.onViewAppear()
    → Manager.fetchDevicePositions(forFloorPlanID: String) async throws
      → API.getDevicePositions(floorPlanID: String) async throws
        → Returns: [DevicePositionBackendModel]
      ← For each position:
        ← Look up device via DeviceManager.findDevice(bySource:)
        ← Transform to DevicePosition with pre-populated device info
      ← Returns: [DevicePosition] (with device, name, icon, status)
    ← Returns: [DevicePosition]
  ← Update @Published var devicePositions: [DevicePosition]
← View renders camera markers using pre-populated device info
← No need for repeated findDevice() calls
```

## Decisions

### Decision 1: Separate Backend Models from UI Models

**What:** Create distinct model types for API responses (Backend models) and UI representation (UI models).

**Why:**
- **Single Responsibility:** Backend models represent API contract; UI models represent presentation needs
- **Independence:** API changes don't require UI changes and vice versa
- **Type Safety:** Compiler enforces proper data flow through layers
- **Clarity:** Explicit transformation makes data flow obvious

**Implementation:**

**Backend Models** (VortexFeatures/Common/VortexBackend/Model/FloorPlan/):
```swift
public struct FloorPlanBackendModel: VortexBackendModel {
    public let id: String
    public let siteId: String
    public let name: String
    public let imageUrl: String?
    public let imageFormat: String
    public let imageWidth: Int
    public let imageHeight: Int
    public let createdAt: Date
    public let updatedAt: Date
    // No deviceCount - added by Manager layer
}

public struct DevicePositionBackendModel: VortexBackendModel {
    public let id: String
    public let floorPlanId: String
    public let deviceSerialNumber: String
    public let positionX: Double  // 0.0 to 1.0
    public let positionY: Double  // 0.0 to 1.0
    public let fovAngle: Double?
    public let fovDirection: Double?
    public let fovDepth: Double?
}
```

**UI Models** (VortexFeatures/Core/FloorPlanManager/):
```swift
public struct FloorPlanItem: Identifiable, Equatable, Sendable {
    public let id: String
    public let siteId: String
    public let name: String
    public let imageUrl: String?
    public let imageFormat: String
    public let imageWidth: Int
    public let imageHeight: Int
    public let createdAt: Date
    public let updatedAt: Date
    public let deviceCount: Int?  // Populated by Manager

    // UI-specific computed properties
    public var hasImage: Bool { imageUrl != nil }
    public var aspectRatio: Double { Double(imageWidth) / Double(imageHeight) }
}

public struct DevicePosition: Identifiable, Equatable, Sendable {
    public let id: String
    public let floorPlanId: String
    public let deviceSerialNumber: String
    public let positionX: Double
    public let positionY: Double
    public let fovAngle: Double?
    public let fovDirection: Double?
    public let fovDepth: Double?

    // Device information pre-populated by Manager (optimization)
    // Avoids repeated findDevice() calls in View for marker rendering
    public let deviceCompositeType: DeviceCompositeType  // For looking up full DeviceItem if needed
    public let deviceName: String?
    public let connectionIcon: String?  // simpleStateIcon for marker display
    public let isOnline: Bool
    public let isUpdatingFirmware: Bool

    // UI-specific computed properties
    public var hasFOV: Bool { fovAngle != nil && fovDirection != nil }
    public var cameraStatus: CameraOverlayStatus {
        if isUpdatingFirmware { return .updating }
        return isOnline ? .online : .offline
    }
    public func absolutePosition(imageWidth: CGFloat, imageHeight: CGFloat) -> CGPoint {
        CGPoint(x: positionX * imageWidth, y: positionY * imageHeight)
    }
}
```

**Transformation** (in FloorPlanManager):
```swift
private func toUIModel(_ backend: FloorPlanBackendModel, deviceCount: Int?) -> FloorPlanItem {
    FloorPlanItem(
        id: backend.id,
        siteId: backend.siteId,
        name: backend.name,
        imageUrl: backend.imageUrl,
        imageFormat: backend.imageFormat,
        imageWidth: backend.imageWidth,
        imageHeight: backend.imageHeight,
        createdAt: backend.createdAt,
        updatedAt: backend.updatedAt,
        deviceCount: deviceCount
    )
}

private func toUIModel(_ backend: DevicePositionBackendModel, device: DeviceItem?) -> DevicePosition {
    DevicePosition(
        id: backend.id,
        floorPlanId: backend.floorPlanId,
        deviceSerialNumber: backend.deviceSerialNumber,
        positionX: backend.positionX,
        positionY: backend.positionY,
        fovAngle: backend.fovAngle,
        fovDirection: backend.fovDirection,
        fovDepth: backend.fovDepth,
        // Pre-populate only necessary device information (no full DeviceItem dependency)
        deviceCompositeType: device?.compositeType ?? DeviceCompositeType(
            thingName: backend.deviceSerialNumber,
            derivant: DeviceInfo.defaultDerivant
        ),
        deviceName: device?.name,
        connectionIcon: device?.simpleStateIcon,
        isOnline: device?.isOnline ?? false,
        isUpdatingFirmware: device?.isUpdatingFirmware ?? false
    )
}
```

**Alternatives considered:**
- **Single unified model:** Rejected - violates single responsibility, creates tight coupling
- **Typealias for Backend model:** Rejected - no type safety, doesn't prevent mixing layers
- **Inheritance (UIModel extends BackendModel):** Rejected - creates tight coupling, harder to change

**Trade-offs:**
- ✅ Pro: Clear separation of concerns, better maintainability
- ✅ Pro: API changes isolated from UI layer
- ✅ Pro: Type-safe data flow
- ⚠️ Con: Requires transformation code (minimal, clear benefit)

### Decision 2: FloorPlanManager as Protocol-Based Dependency

**What:** Define `FloorPlanManagerProtocol` and register via `@Dependency` for testability.

**Why:**
- **Testability:** Easy mocking with `MockFloorPlanManager` in unit tests
- **Flexibility:** Can provide different implementations (production, demo, offline)
- **Consistency:** Follows project's DeviceManager pattern
- **Explicit dependencies:** Makes dependencies visible and testable

**Implementation:**

**Protocol** (VortexFeatures/Core/FloorPlanManager/):
```swift
public protocol FloorPlanManagerProtocol: Sendable {
    func fetchFloorPlans(forSiteID siteID: String) async throws -> [FloorPlanItem]
    func fetchDevicePositions(forFloorPlanID floorPlanID: String) async throws -> [DevicePosition]
    func fetchAllFloorPlans(sites: [SiteItem]) async throws -> [FloorPlanItem]
}
```

**Implementation** (VortexFeatures/Core/FloorPlanManager/):
```swift
public final class FloorPlanManager: FloorPlanManagerProtocol, Sendable {
    @Dependency(\.vortexRestfulApi) private var api
    @Dependency(\.deviceManager) private var deviceManager

    public func fetchFloorPlans(forSiteID siteID: String) async throws -> [FloorPlanItem] {
        let output = try await api.getFloorPlans(siteID: siteID)
        // Transform Backend models to UI models
        return output.floorPlans.map { toUIModel($0, deviceCount: nil) }
    }

    public func fetchDevicePositions(forFloorPlanID floorPlanID: String) async throws -> [DevicePosition] {
        let output = try await api.getDevicePositions(floorPlanID: floorPlanID)

        // Transform with pre-populated device information
        return output.devicePositions.map { backendPosition in
            // Look up device once during transformation
            let device = deviceManager.findDevice(bySource: backendPosition.deviceSerialNumber)
            return toUIModel(backendPosition, device: device)
        }
    }

    public func fetchAllFloorPlans(sites: [SiteItem]) async throws -> [FloorPlanItem] {
        // Fetch floor plans for all sites
        // Fetch device counts for each floor plan
        // Combine and return
    }
}
```

**Dependency Registration** (iOSCharmander/Common/Extension/Dependencies+.swift):
```swift
extension DependencyValues {
    var floorPlanManager: FloorPlanManagerProtocol {
        get { self[FloorPlanManagerKey.self] }
        set { self[FloorPlanManagerKey.self] = newValue }
    }
}

private enum FloorPlanManagerKey: DependencyKey {
    static let liveValue: FloorPlanManagerProtocol = FloorPlanManager()
}
```

**Mock for Tests** (iOSCharmanderTests/Mock/):
```swift
struct MockFloorPlanManager: FloorPlanManagerProtocol, Sendable {
    var _fetchFloorPlans: (@Sendable (String) async throws -> [FloorPlanItem])?
    var _fetchDevicePositions: (@Sendable (String) async throws -> [DevicePosition])?
    var _fetchAllFloorPlans: (@Sendable ([SiteItem]) async throws -> [FloorPlanItem])?

    func fetchFloorPlans(forSiteID siteID: String) async throws -> [FloorPlanItem] {
        guard let fn = _fetchFloorPlans else { return [] }
        return try await fn(siteID)
    }
    // ... other methods
}
```

**Alternatives considered:**
- **Concrete class only:** Rejected - harder to test, can't inject mocks
- **Abstract class:** Rejected - Swift protocols preferred for dependency abstraction
- **Singleton without DI:** Rejected - violates testability, harder to mock

**Trade-offs:**
- ✅ Pro: Excellent testability with mock injection
- ✅ Pro: Follows established project patterns
- ✅ Pro: Flexible for future implementations
- ⚠️ Con: More boilerplate (acceptable trade-off for testability)

### Decision 3: Manager Handles All Data Transformation

**What:** FloorPlanManager is responsible for all Backend→UI model transformation, including adding deviceCount.

**Why:**
- **Single Responsibility:** Manager owns data transformation logic
- **ViewModels stay simple:** ViewModels only handle UI state, not data manipulation
- **Testability:** Transformation logic tested in Manager tests, not ViewModel tests
- **Reusability:** Multiple ViewModels can use same transformation logic

**Implementation:**

**Manager method:**
```swift
public func fetchAllFloorPlans(sites: [SiteItem]) async throws -> [FloorPlanItem] {
    var allFloorPlans: [FloorPlanItem] = []

    for site in sites {
        // Fetch floor plans for site
        let backendPlans = try await api.getFloorPlans(siteID: site.id).floorPlans

        // For each floor plan, fetch device positions to get count
        var uiPlans: [FloorPlanItem] = []
        for backendPlan in backendPlans {
            let positions = try await api.getDevicePositions(floorPlanID: backendPlan.id)
            let deviceCount = positions.devicePositions.count
            let uiPlan = toUIModel(backendPlan, deviceCount: deviceCount)
            uiPlans.append(uiPlan)
        }

        allFloorPlans.append(contentsOf: uiPlans)
    }

    return allFloorPlans
}
```

**ViewModel usage:**
```swift
class FloorPlanTabViewModel: ObservableObject {
    @Dependency(\.floorPlanManager) var floorPlanManager
    @Dependency(\.deviceManager) var deviceManager
    @Published var floorPlans: [FloorPlanItem] = []

    @MainActor
    func onViewAppear() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let sites = deviceManager.allSites()
            floorPlans = try await floorPlanManager.fetchAllFloorPlans(sites: sites)
        } catch {
            logger.error("Failed to fetch floor plans: \(error)")
        }
    }
}
```

**Alternatives considered:**
- **ViewModel does transformation:** Rejected - violates separation of concerns
- **Separate transformer class:** Rejected - over-engineering, Manager is appropriate place
- **View does transformation:** Rejected - View should be declarative only

**Trade-offs:**
- ✅ Pro: Clear responsibility boundaries
- ✅ Pro: ViewModels remain lightweight
- ✅ Pro: Easy to test transformation logic in isolation
- ⚠️ Con: Manager more complex (acceptable, that's its purpose)

### Decision 4: Pre-populate Essential Device Information with DeviceCompositeType

**What:** FloorPlanManager pre-populates essential device information (DeviceCompositeType, name, icon, status) in DevicePosition UI model, avoiding storage of full DeviceItem to prevent over-coupling.

**Why:**
- **Performance:** Eliminates repeated `findDevice(byID:)` calls in View for marker rendering
- **Loose Coupling:** DevicePosition doesn't depend on full DeviceItem, only stores what's needed for display
- **Flexibility:** When full DeviceItem is needed (e.g., start streaming), use DeviceCompositeType to look it up
- **Minimal Dependencies:** Only includes display-critical data, not entire device model
- **Manager Responsibility:** Manager layer provides complete UI-ready data for common operations

**Problem Being Solved:**
Currently, Views call `viewModel.findDevice(byID: position.deviceSerialNumber)?.simpleStateIcon` every render, causing:
- Multiple repeated device lookups for same device
- Unnecessary coupling between View and device lookup logic
- Potential performance issues when rendering many markers

**Design Choice - DeviceCompositeType vs Full DeviceItem:**

❌ **Rejected: Store full DeviceItem**
```swift
public let device: DeviceItem?  // Too much coupling!
```
Problems:
- DevicePosition becomes tightly coupled to DeviceItem
- Changes to DeviceItem affect DevicePosition
- Stores unnecessary data (DeviceItem has many properties not needed for rendering)

✅ **Accepted: Store DeviceCompositeType + display properties**
```swift
public let deviceCompositeType: DeviceCompositeType  // Lightweight identifier
public let deviceName: String?                        // Display only
public let connectionIcon: String?                    // Display only
public let isOnline: Bool                            // Display only
public let isUpdatingFirmware: Bool                  // Display only
```
Benefits:
- Minimal coupling (only identifier, not full model)
- Only stores what's needed for marker display
- Full DeviceItem lookup only when truly needed (e.g., streaming)
- DevicePosition independent of DeviceItem changes

**Implementation:**

FloorPlanManager transformation:
```swift
public func fetchDevicePositions(forFloorPlanID floorPlanID: String) async throws -> [DevicePosition] {
    let output = try await api.getDevicePositions(floorPlanID: floorPlanID)

    return output.devicePositions.map { backendPosition in
        let device = deviceManager.findDevice(bySource: backendPosition.deviceSerialNumber)
        return DevicePosition(
            // ... position properties
            deviceCompositeType: device?.compositeType ?? DeviceCompositeType(...),
            deviceName: device?.name,
            connectionIcon: device?.simpleStateIcon,
            isOnline: device?.isOnline ?? false,
            isUpdatingFirmware: device?.isUpdatingFirmware ?? false
        )
    }
}
```

View usage:
```swift
// Marker rendering: use pre-populated properties (no lookup needed)
CameraMarkerView(
    position: position,
    icon: position.connectionIcon,       // ✅ Direct access
    status: position.cameraStatus        // ✅ Computed from isOnline/isUpdatingFirmware
)

// When full device needed (e.g., start streaming): lookup via DeviceCompositeType
if let device = deviceManager.findDevice(by: position.deviceCompositeType) {
    let control = ViewcellControl.make(device: device, playMode: .live)
}
```

**Alternatives considered:**
- **Store full DeviceItem:** Rejected - creates tight coupling, stores unnecessary data
- **Keep current approach (View calls findDevice repeatedly):** Rejected - inefficient repeated lookups
- **Cache in ViewModel:** Rejected - ViewModel shouldn't handle data aggregation
- **Store only DeviceCompositeType (no display info):** Rejected - would still require lookups for every render

**Trade-offs:**
- ✅ Pro: Significant performance improvement (one lookup during transformation vs many during rendering)
- ✅ Pro: Loose coupling (DevicePosition independent of DeviceItem)
- ✅ Pro: Simpler View code for common case (marker display)
- ✅ Pro: Full device lookup only when truly needed (rare, e.g., streaming start)
- ⚠️ Con: Device display info may become stale (acceptable, solved by refresh)
- ⚠️ Con: Need lookup for operations requiring full DeviceItem (acceptable, happens infrequently)

### Decision 5: ViewModels Only Handle UI Concerns

**What:** ViewModels exclusively manage UI state and user interactions; no API calls or data transformation.

**Why:**
- **Separation of Concerns:** UI logic separate from data logic
- **Testability:** ViewModel tests focus on UI state changes, not API mocking
- **Maintainability:** Changes to data fetching don't require ViewModel changes
- **Lightweight:** ViewModels remain simple and easy to understand

**ViewModel Responsibilities:**
- `@Published` properties for UI state (isLoading, selectedID, zoomScale, etc)
- User interaction methods (tapDevice, toggleFullScreen, zoomIn, etc)
- Navigation decisions (openFloorPlanDetail, etc)
- SwiftUI lifecycle (onViewAppear, onChange, etc)
- Calling Manager methods and updating UI state from results

**NOT ViewModel Responsibilities:**
- API calls (belongs to Manager)
- Data transformation (belongs to Manager)
- Business logic (belongs to Manager)
- Direct VortexRestfulApi usage (belongs to Manager)

**Example - FloorPlanTabViewModel:**
```swift
class FloorPlanTabViewModel: ObservableObject {
    @Dependency(\.floorPlanManager) var floorPlanManager
    @Dependency(\.sheetManager) var sheetManager
    @Published var floorPlans: [FloorPlanItem] = []
    @Published var isLoading: Bool = false

    // UI lifecycle
    @MainActor
    func onViewAppear() async {
        await fetchAll()
    }

    // User interaction
    func tapFloorPlan(_ floorPlan: FloorPlanItem) {
        sheetManager.openFloorPlanDetail(floorPlan: floorPlan)
    }

    // Data loading (delegates to Manager)
    @MainActor
    private func fetchAll() async {
        isLoading = true
        defer { isLoading = false }

        do {
            floorPlans = try await floorPlanManager.fetchAllFloorPlans(sites: deviceManager.allSites())
        } catch {
            logger.error("Failed to fetch: \(error)")
        }
    }
}
```

**Alternatives considered:**
- **ViewModels do everything:** Rejected - violates separation of concerns, as identified in code review
- **Split ViewModels into UI and Data ViewModels:** Rejected - over-engineering, Manager layer serves this purpose
- **Use interactors/use cases:** Rejected - Manager pattern is project convention

**Trade-offs:**
- ✅ Pro: ViewModels stay simple and focused
- ✅ Pro: Clear architectural boundaries
- ✅ Pro: Easier to test and maintain
- ⚠️ Con: More layers (acceptable, improves architecture)

### Decision 5: Update API Response Models to Use Backend Models

**What:** Change `ListFloorPlansOutput` and `ListDevicePositionsOutput` to return Backend models instead of UI models.

**Why:**
- **Correct layering:** API layer should not know about UI models
- **Proper dependency direction:** API → Manager → ViewModel → View
- **Type safety:** Prevents UI models from leaking into API layer

**Before:**
```swift
public struct ListFloorPlansOutput: VortexBackendModel {
    public let floorPlans: [FloorPlanItem]  // UI model!
}
```

**After:**
```swift
public struct ListFloorPlansOutput: VortexBackendModel {
    public let floorPlans: [FloorPlanBackendModel]  // Backend model
}
```

**Alternatives considered:**
- **Keep UI models in API responses:** Rejected - violates layering principles, identified in code review

**Trade-offs:**
- ✅ Pro: Proper architectural layering
- ✅ Pro: Clear separation between API and UI concerns
- ⚠️ Con: Requires changing API response models (low risk, internal)

## Testing Strategy

### Manager Tests (New)
**File:** `FloorPlanManagerTest.swift`

**Coverage:**
- Fetch floor plans for single site
- Fetch floor plans for multiple sites
- Fetch device positions for floor plan
- Fetch all floor plans with device counts
- Error handling (API failures, network errors)
- Empty response handling
- Backend to UI model transformation
- Concurrent request handling

**Target:** 80%+ code coverage

**Example test:**
```swift
@Test
func test_fetchFloorPlans_shouldTransformBackendToUI_whenSuccess() async throws {
    let mockApi = MockVortexRestfulApi(
        _listFloorPlans: { _ in
            ListFloorPlansOutput(floorPlans: [
                FloorPlanBackendModel(id: "1", siteId: "site-1", name: "Floor 1", ...)
            ])
        }
    )

    let manager = withDependencies {
        $0.vortexRestfulApi = mockApi
    } operation: {
        FloorPlanManager()
    }

    let result = try await manager.fetchFloorPlans(forSiteID: "site-1")

    #expect(result.count == 1)
    #expect(result[0].id == "1")
    #expect(result[0].name == "Floor 1")
}
```

### ViewModel Tests (Updated)
**Files:** `FloorPlanTabViewModelTest.swift`, `FloorPlanDetailViewModelTest.swift`

**Changes:**
- Replace MockVortexRestfulApi with MockFloorPlanManager
- Simplify tests to focus on UI state changes
- Remove data transformation tests (now in Manager tests)

**Example before:**
```swift
let mockApi = MockVortexRestfulApi(
    _listFloorPlans: { _ in ListFloorPlansOutput(floorPlans: [...]) },
    _listDevicePositions: { _ in ListDevicePositionsOutput(devicePositions: [...]) }
)
let viewModel = withDependencies {
    $0.vortexRestfulApi = mockApi
} operation: { ... }
```

**Example after:**
```swift
let mockManager = MockFloorPlanManager(
    _fetchAllFloorPlans: { _ in [
        FloorPlanItem(id: "1", siteId: "site-1", name: "Floor 1", ...)
    ]}
)
let viewModel = withDependencies {
    $0.floorPlanManager = mockManager
} operation: { ... }
```

**Target:** All 39 existing tests still passing

## Risks / Trade-offs

### Risk 1: More Layers Increases Complexity
**Risk:** Adding Manager layer between ViewModel and API increases architectural complexity.

**Mitigation:**
- Manager interface is simple (3-4 methods)
- Follows established project pattern (DeviceManager)
- Clear documentation of responsibilities
- Benefits (separation of concerns) outweigh costs

### Risk 2: Refactoring Could Break Existing Tests
**Risk:** Major architectural changes could cause test failures or require extensive test rewrites.

**Mitigation:**
- Refactor incrementally (Backend models → Manager → ViewModel → Tests)
- Keep tests passing at each step
- MockFloorPlanManager simplifies test setup
- All existing functionality preserved

### Risk 3: Backend/UI Model Separation Could Be Confusing
**Risk:** Developers might not understand when to use Backend vs UI models.

**Mitigation:**
- Clear naming convention (BackendModel suffix)
- Located in different directories (VortexBackend vs FloorPlanManager)
- Documented in this design doc
- Code review enforcement

### Risk 4: Performance Impact from Extra Transformation
**Risk:** Backend→UI transformation adds processing overhead.

**Mitigation:**
- Transformation is simple struct copying (O(n), very fast)
- No complex computations in transformation
- async/await prevents blocking
- Benefits of clean architecture outweigh minimal performance cost

## Migration Plan

**Phase 1: Backend Models (Day 1)**
1. Create FloorPlanBackendModel and DevicePositionBackendModel
2. Update API response models to use Backend models
3. Verify API layer still compiles

**Phase 2: Manager Layer (Day 2)**
4. Create FloorPlanManagerProtocol
5. Implement FloorPlanManager with transformation logic
6. Register FloorPlanManager dependency
7. Create MockFloorPlanManager for tests

**Phase 3: Manager Tests (Day 3)**
8. Create FloorPlanManagerTest.swift
9. Add 15+ unit tests for Manager
10. Verify 80%+ coverage
11. All Manager tests passing

**Phase 4: Refactor ViewModels (Day 4-5)**
12. Update FloorPlanTabViewModel to use FloorPlanManager
13. Update FloorPlanDetailViewModel to use FloorPlanManager
14. Remove VortexRestfulApi dependency from ViewModels
15. Update make() methods for dependency injection

**Phase 5: Update Tests (Day 6)**
16. Update FloorPlanTabViewModelTest to use MockFloorPlanManager
17. Update FloorPlanDetailViewModelTest to use MockFloorPlanManager
18. Remove MockVortexRestfulApi usage from ViewModel tests
19. Verify all 39+ tests still passing

**Phase 6: Validation (Day 7)**
20. Run full test suite (should have 54+ tests total)
21. Build project with zero errors/warnings
22. Manual testing of floor plan feature
23. Code review and validation

**Rollback Plan:**
- Keep feature behind feature flag during development
- Can revert commits if issues discovered
- Tests provide safety net for regressions

## Open Questions

None - all architectural decisions align with code review requirements and project conventions.
