# Refactor Floor Plan Manager Architecture - Design Document

## Context

The floor plan feature currently has FloorPlanManager tightly coupled with DeviceManager for pre-populating device information into DevicePosition. This violates the team's module hierarchy principle where a Manager should only transform API data into internal models.

**Current architecture problems:**
- FloorPlanManager depends on DeviceManager (`@Dependency(\.deviceManager)`) to call `findDevice(bySource:)` during position transformation
- FloorPlanTabViewModel duplicates Manager state (`@Published var siteFloorPlans`) and subscribes via AsyncStream
- FloorPlanDetailViewModel holds `@Published var devicePositions` and `@Published var floorPlan` that should be single-sourced from Manager
- Device status changes (online/offline) are NOT reactive — positions are only populated once at fetch time

**Team module hierarchy:**
```
View → FeatureToggle → XXXManager Protocol → backend api
View → ViewModel → XXXManager Protocol → backend api
View → XXXManager's Published
```

**Constraints:**
- Must maintain all existing floor plan functionality
- Cannot change backend API contracts
- iOS 17.0+ minimum deployment, Swift 6.0
- SwiftUI-only codebase with swift-dependencies for DI
- FloorPlanManager must remain @MainActor class with @Published properties

## Goals / Non-Goals

**Goals:**
- Remove DeviceManager dependency from FloorPlanManager
- FloorPlanManager becomes pure API data transformation + caching layer
- Views observe FloorPlanManager's `@Published` directly (single source of truth)
- ViewModels become thin orchestrators (trigger fetches, sync device state, write back to Manager)
- Device status changes reactively propagate to UI
- Update unit tests to reflect new architecture

**Non-Goals:**
- Adding new floor plan features
- Changing UI/UX design
- Modifying API contracts
- Changing DeviceManager's interface
- Performance optimization beyond removing unnecessary indirection

## Architectural Layers

### Layer Overview (After Refactoring)

```
┌──────────────────────────────────────────────────────────┐
│                   View Layer (SwiftUI)                    │
│  - FloorPlanTabView                                      │
│  - FloorPlanDetailView                                   │
│                                                          │
│  Data source:                                            │
│  - Observes FloorPlanManager.shared (siteFloorPlans,     │
│    currentFloorPlanDetail) via @ObservedObject            │
│  - Observes ViewModel for UI-only state (selectedDevice, │
│    zoomScale, isLoading, viewcellControl)                 │
└─────────┬──────────────────────────────┬─────────────────┘
          │ UI-only state               │ Data (@Published)
          ▼                             │
┌─────────────────────────┐             │
│   ViewModel Layer       │             │
│                         │             │
│ FloorPlanTabViewModel:  │             │
│ - Trigger fetchAll      │             │
│ - Error handling        │             │
│ - Navigation            │             │
│                         │             │
│ FloorPlanDetailVM:      │             │
│ - Trigger fetch         │             │
│ - Sync device info      │──writes──┐  │
│ - Device selection      │          │  │
│ - Streaming control     │          │  │
│ - Subscribe DeviceMgr   │          │  │
└────────┬────────────────┘          │  │
         │ fetch/query               │  │
         ▼                           ▼  │
┌──────────────────────────────────────────────────────────┐
│              FloorPlanManager (Data Store)                │
│                                                          │
│  @Published siteFloorPlans: [SiteFloorPlans]             │
│  @Published currentFloorPlanDetail: FloorPlanDetail?     │
│                                                          │
│  Methods:                                                │
│  - fetchAllFloorPlans(sites:) → fetch + cache            │
│  - fetchDevicePositions(forFloorPlanID:) → fetch only    │
│  - findFloorPlan(byID:) → cache lookup                   │
│  - searchFloorPlans(keyword:) → cache query              │
│  - setCurrentFloorPlanDetail(_:) → write from ViewModel  │
│                                                          │
│  NO DeviceManager dependency                             │
└────────┬─────────────────────────────────────────────────┘
         │ @Dependency(\.vortexRestfulApi)
         ▼
┌──────────────────────────────────────────────────────────┐
│                   API Layer (Network)                     │
│  - VortexRestfulApi                                      │
│  - FloorPlanItem, DevicePositionItem (backend models)    │
└──────────────────────────────────────────────────────────┘
```

### Data Flow

**1. Floor Plan Tab — List Loading:**
```
FloorPlanTabView.onAppear()
  → TabViewModel.onViewAppear()
    → featureProvider.accessibleSitesForFloorPlan()
    → floorPlanManager.fetchAllFloorPlans(sites:)
      → API.getFloorPlans(siteID:) × N sites (batched)
      → Transform FloorPlanItem → FloorPlan (UI model)
      → Update @Published siteFloorPlans
    → FloorPlanTabView auto-refreshes (observes Manager directly)
```

**2. Floor Plan Detail — Initial Load:**
```
FloorPlanDetailView.onAppear()
  → DetailViewModel.onViewAppear()
    → floorPlanManager.findFloorPlan(byID:) → get FloorPlan from cache
    → floorPlanManager.fetchDevicePositions(forFloorPlanID:)
      → API.getDevicePositions() → [DevicePosition] (device = nil)
    → DetailViewModel fills device info using DeviceManager
    → DetailViewModel calls Manager.setCurrentFloorPlanDetail(FloorPlanDetail(...))
    → DetailViewModel starts deviceSyncTask (subscribe devicesValues())
    → FloorPlanDetailView auto-refreshes (observes Manager.currentFloorPlanDetail)
```

**3. Device Status Change — Reactive Sync:**
```
DeviceManager.devices changes (device goes offline/online/updating)
  → DetailViewModel.deviceSyncTask receives new [DeviceItem] via devicesValues()
  → DetailViewModel re-matches devices to positions
  → DetailViewModel calls Manager.setCurrentFloorPlanDetail() with updated positions
  → Manager's @Published currentFloorPlanDetail updates
  → FloorPlanDetailView auto-refreshes (camera markers update status colors)
```

**4. Leave Detail View:**
```
FloorPlanDetailView.onDisappear()
  → DetailViewModel.cleanup()
    → Cancel deviceSyncTask
    → Stop streaming
    → Manager.setCurrentFloorPlanDetail(nil)
```

## Decisions

### Decision 1: New FloorPlanDetail Combined Structure

**What:** Introduce `FloorPlanDetail` struct as the single source of truth for detail view data.

**Why:**
- View observes one `@Published` property instead of multiple scattered pieces
- Clean lifecycle: set on enter detail, nil on leave
- Combines related data that always changes together

**Implementation:**
```swift
public struct FloorPlanDetail: Sendable, Equatable {
    public let floorPlan: FloorPlan
    public var devicePositions: [DevicePosition]

    public init(floorPlan: FloorPlan, devicePositions: [DevicePosition]) {
        self.floorPlan = floorPlan
        self.devicePositions = devicePositions
    }
}
```

**Trade-offs:**
- ✅ Single source of truth for detail view
- ✅ Clean lifecycle management
- ⚠️ Entire struct re-published when any position updates (acceptable — SwiftUI diffing handles this efficiently)

### Decision 2: Remove DeviceManager from FloorPlanManager

**What:** Remove `@Dependency(\.deviceManager)` and all device lookup logic from FloorPlanManager. Manager still handles API format conversion (e.g. `deviceSerialNumber` → `DeviceCompositeType`).

**Why:**
- FloorPlanManager's role is API data → UI model transformation (including format parsing)
- Device info population is an orchestration concern (belongs in ViewModel)
- Removes cross-Manager coupling
- Parsing `deviceSerialNumber` into `DeviceCompositeType` is a data format conversion, not a device concern — it stays in Manager

**Changes in FloorPlanManager:**
```swift
// BEFORE
@Dependency(\.deviceManager) private var deviceManager

private func transformToUIPosition(_ apiPosition: DevicePositionItem) -> DevicePosition {
    let compositeType = parseCompositeType(from: apiPosition.deviceSerialNumber)
    let device = deviceManager.findDevice(bySource: compositeType)
    return DevicePosition(item: apiPosition, device: device)
}

// AFTER
// No deviceManager dependency
// Manager still parses deviceSerialNumber → compositeType (API format conversion)
// fetchDevicePositions returns positions with compositeType parsed, device = nil
public func fetchDevicePositions(forFloorPlanID floorPlanID: String) async throws -> [DevicePosition] {
    let output = try await api.getDevicePositions(floorPlanID: floorPlanID)
    return output.devicePositions.map { apiPosition in
        let compositeType = parseCompositeType(from: apiPosition.deviceSerialNumber)
        return DevicePosition(item: apiPosition, compositeType: compositeType)
    }
}

private func parseCompositeType(from serialNumber: String) -> DeviceCompositeType {
    let components = serialNumber.split(separator: ":", maxSplits: 1).map(String.init)
    if components.count == 2 {
        return DeviceCompositeType(thingName: components[0], derivant: components[1])
    }
    logger.warning("Unexpected deviceSerialNumber format: \(serialNumber)")
    return DeviceCompositeType(thingName: serialNumber, derivant: "")
}
```

**Trade-offs:**
- ✅ Clean separation of concerns
- ✅ FloorPlanManager has no cross-Manager dependencies
- ✅ API format parsing stays in Manager (where data transformation belongs)
- ⚠️ Device info fill-in logic moves to ViewModel (acceptable — that's where orchestration belongs)

### Decision 3: DevicePosition with Stored compositeType and Mutable device

**What:**
- Add `compositeType: DeviceCompositeType` as a **stored property**, populated by Manager during API data transformation
- Change `device: DeviceItem?` from `let` to `var`, initialized as nil by Manager, filled by ViewModel

**Why:**
- `deviceSerialNumber` from API uses a different format (`"thingName:derivant"`) than our internal `DeviceCompositeType` — this parsing is data transformation and belongs in Manager
- ViewModel receives positions with `compositeType` already resolved, can directly call `deviceManager.findDevice(bySource: position.compositeType)` without parsing
- `device` is filled by ViewModel and can be updated reactively when devices change
- `cameraStatus` computed property continues to work based on `device` value

**Implementation:**
```swift
public struct DevicePosition: Sendable, Identifiable, Hashable {
    // ... existing coordinate properties ...

    // Stored property: Manager parses deviceSerialNumber → compositeType during transformation
    public let compositeType: DeviceCompositeType

    // Changed from let to var, initialized as nil by Manager, filled by ViewModel
    public var device: DeviceItem?

    // Init from API + parsed compositeType (Manager uses this)
    public init(item: DevicePositionItem, compositeType: DeviceCompositeType) {
        self.id = item.id
        self.floorPlanId = item.floorPlanId
        self.deviceSerialNumber = item.deviceSerialNumber
        self.positionX = item.positionX
        self.positionY = item.positionY
        self.fovAngle = item.fovAngle
        self.fovDirection = item.fovDirection
        self.fovDepth = item.fovDepth
        self.compositeType = compositeType
        self.device = nil
    }

    // Existing computed property, unchanged
    public var cameraStatus: CameraOverlayStatus {
        guard let device = device else { return .offline }
        if device.isUpdatingFirmware { return .updating }
        return device.online ? .online : .offline
    }
}
```

**Trade-offs:**
- ✅ Simple — keeps existing DeviceItem? pattern, minimal changes needed
- ✅ cameraStatus logic unchanged
- ✅ compositeType already parsed by Manager — ViewModel doesn't need to know API format
- ✅ ViewModel can directly use `position.compositeType` for device lookup
- ⚠️ device is mutable on a Sendable struct — acceptable since updates happen on MainActor

### Decision 4: Remove AsyncStream, View Observes Manager Directly

**What:** Remove `siteFloorPlansValues()` AsyncStream. Views observe `FloorPlanManager.shared` as `ObservableObject`.

**Why:**
- AsyncStream was only bridging `@Published` to ViewModel, which re-published the same data
- Direct observation removes one layer of indirection
- Follows team pattern: `View → XXXManager's Published`

**FloorPlanTabView change:**
```swift
// BEFORE: View observes ViewModel's copy
@StateObject var viewModel = FloorPlanTabViewModel.make()
// Uses: viewModel.siteFloorPlans

// AFTER: View observes Manager directly for data
@StateObject var viewModel = FloorPlanTabViewModel.make()
@ObservedObject var floorPlanManager = FloorPlanManager.shared
// Uses: floorPlanManager.siteFloorPlans (data)
// Uses: viewModel.isLoading (UI state)
```

**Trade-offs:**
- ✅ Simpler data flow, no AsyncStream subscription management
- ✅ Removes duplicated state in ViewModel
- ⚠️ View now depends on concrete Manager.shared for data observation (acceptable — protocol still used by ViewModel for operations)

### Decision 5: FloorPlanDetailViewModel Syncs Device State Reactively

**What:** DetailViewModel subscribes to `deviceManager.devicesValues()` and updates Manager's `currentFloorPlanDetail` when devices change.

**Why:**
- Enables reactive device status updates (online/offline/updating) without manual refresh
- Keeps DeviceManager dependency out of FloorPlanManager
- ViewModel is the right layer for orchestrating cross-Manager data assembly

**Implementation:**
```swift
@MainActor
final class FloorPlanDetailViewModel: ObservableObject {
    @Dependency(\.floorPlanManager) var floorPlanManager
    @Dependency(\.deviceManager) var deviceManager

    private var deviceSyncTask: Task<Void, Never>?

    func onViewAppear() async {
        isLoading = true

        // 1. Get floor plan from cache
        guard let floorPlan = floorPlanManager.findFloorPlan(byID: floorPlanID) else {
            isLoading = false
            return
        }

        // 2. Fetch positions (device = nil)
        do {
            var positions = try await floorPlanManager.fetchDevicePositions(forFloorPlanID: floorPlanID)

            // 3. Fill device info
            fillDeviceInfo(&positions)

            // 4. Write to Manager (View observes this)
            floorPlanManager.setCurrentFloorPlanDetail(
                FloorPlanDetail(floorPlan: floorPlan, devicePositions: positions)
            )
        } catch {
            appManager.handleError(error, defaultAlert: AlertItem.failToLoad())
        }

        isLoading = false

        // 5. Start reactive device sync
        startDeviceSync()
    }

    private func fillDeviceInfo(_ positions: inout [DevicePosition]) {
        for i in positions.indices {
            positions[i].device = deviceManager.findDevice(bySource: positions[i].compositeType)
        }
    }

    private func startDeviceSync() {
        deviceSyncTask = Task {
            for await _ in await deviceManager.devicesValues() {
                guard var detail = floorPlanManager.currentFloorPlanDetail else { continue }
                fillDeviceInfo(&detail.devicePositions)
                floorPlanManager.setCurrentFloorPlanDetail(detail)
            }
        }
    }

    func cleanup() {
        deviceSyncTask?.cancel()
        deviceSyncTask = nil
        floorPlanManager.setCurrentFloorPlanDetail(nil)
        // ... stop streaming ...
    }
}
```

**Trade-offs:**
- ✅ Device status changes automatically propagate to View
- ✅ Clear separation: Manager stores, ViewModel orchestrates
- ⚠️ Each devicesValues() emission re-matches all positions (acceptable — typically < 50 positions)

### Decision 6: Simplified FloorPlanManagerProtocol

**What:** Reduce protocol to 5 essential methods.

**Implementation:**
```swift
public protocol FloorPlanManagerProtocol: Sendable {
    func fetchAllFloorPlans(sites: [SiteItem]) async throws -> [SiteFloorPlans]
    func fetchDevicePositions(forFloorPlanID floorPlanID: String) async throws -> [DevicePosition]
    @MainActor func findFloorPlan(byID id: String) -> FloorPlan?
    @MainActor func searchFloorPlans(keyword: String) -> [SiteFloorPlans]
    @MainActor func setCurrentFloorPlanDetail(_ detail: FloorPlanDetail?)
}
```

**Removed:**
- `fetchFloorPlans(forSiteID:)` — demoted to private (only used internally)
- `siteFloorPlansValues()` — removed (View observes @Published directly)

**Added:**
- `setCurrentFloorPlanDetail(_:)` — ViewModel writes detail state to Manager

**Trade-offs:**
- ✅ Minimal API surface
- ✅ Clear intent for each method
- ⚠️ `@Published` properties not in protocol (acceptable — View observes concrete Manager.shared)

### Decision 7: FloorPlanTabViewModel Simplification

**What:** Remove duplicated state and subscription from TabViewModel.

**Changes:**
```swift
// REMOVED
@Published var siteFloorPlans: [SiteFloorPlans]  // View reads Manager directly
private var subscriptionTask: Task<Void, Never>?   // No more AsyncStream

// KEPT
@Published var isLoading: Bool
func onViewAppear() async    // Triggers fetchAll
func pullToRefresh() async   // Triggers fetchAll
func searchFloorPlans(with:) // Delegates to Manager
func tapFloorPlan(_:)        // Navigation
```

**Trade-offs:**
- ✅ ViewModel is thin — only orchestration and UI state
- ✅ No duplicated data
- ✅ No subscription management code

## Testing Strategy

### FloorPlanManager Tests (Updated)
- Remove device-related assertions from `fetchDevicePositions` tests
- Add tests for `setCurrentFloorPlanDetail` / read `currentFloorPlanDetail`
- Verify `fetchDevicePositions` returns positions with `device = nil`

### FloorPlanTabViewModel Tests (Updated)
- Remove `siteFloorPlans` state assertions (no longer on ViewModel)
- Focus on: `isLoading` state, error handling, fetch triggering
- Mock FloorPlanManager via protocol

### FloorPlanDetailViewModel Tests (Updated)
- Add MockDeviceManager dependency
- Test device info fill-in logic
- Test device sync task (mock devicesValues() stream)
- Test `setCurrentFloorPlanDetail` calls with correct data
- Test cleanup (nil detail, cancel task)
- Remove `devicePositions` / `floorPlan` state assertions (no longer on ViewModel)

### New Test Cases
- `test_deviceSync_shouldUpdatePositions_whenDeviceGoesOffline`
- `test_deviceSync_shouldUpdatePositions_whenDeviceGoesOnline`
- `test_onViewAppear_shouldFillDeviceInfo_afterFetchPositions`
- `test_cleanup_shouldSetDetailNil_andCancelSyncTask`
- `test_fetchDevicePositions_shouldParseCompositeType_fromSerialNumber`
- `test_fetchDevicePositions_shouldHandleUnexpectedSerialNumberFormat`

## Risks / Trade-offs

### Risk 1: View Observing Manager Singleton Complicates Testing
**Mitigation:** Views use `@ObservedObject` with `FloorPlanManager.shared`. In tests, `withDependencies` can override the Manager. SwiftUI previews can use a mock instance.

### Risk 2: Device Sync Race Condition
**Mitigation:** Both `setCurrentFloorPlanDetail()` and `fillDeviceInfo()` run on `@MainActor`. The sync task also runs on MainActor. No concurrent mutation possible.

### Risk 3: devicesValues() Emits Too Frequently
**Mitigation:** The re-matching logic is O(n) where n = number of positions (typically < 50). Even frequent emissions won't cause performance issues. Can add debouncing later if needed.

### Risk 4: Breaking Existing Functionality
**Mitigation:**
- Refactor incrementally (Manager → TabVM → DetailVM → Views → Tests)
- Keep builds passing at each step
- Manual test floor plan feature after completion

## Migration Plan

**Phase 1: Model Changes**
1. Create `FloorPlanDetail` struct
2. Add `compositeType: DeviceCompositeType` as stored property to `DevicePosition`
3. Change `DevicePosition.device` from `let` to `var`
4. Add `init(item:compositeType:)` to `DevicePosition` (Manager provides parsed compositeType)

**Phase 2: FloorPlanManager Changes**
5. Update `FloorPlanManagerProtocol` (remove, add, modify methods)
6. Remove `@Dependency(\.deviceManager)` from FloorPlanManager
7. Add `@Published var currentFloorPlanDetail`
8. Remove `siteFloorPlansValues()` and related AsyncStream
9. Implement `setCurrentFloorPlanDetail()`
10. Update `fetchDevicePositions` to not fill device info
11. Demote `fetchFloorPlans(forSiteID:)` to private

**Phase 3: ViewModel Changes**
12. Simplify FloorPlanTabViewModel (remove siteFloorPlans, subscriptionTask)
13. Restructure FloorPlanDetailViewModel (add DeviceManager, device sync, setCurrentFloorPlanDetail calls)

**Phase 4: View Changes**
14. FloorPlanTabView observes `FloorPlanManager.shared.siteFloorPlans`
15. FloorPlanDetailView observes `FloorPlanManager.shared.currentFloorPlanDetail`

**Phase 5: Test + Mock Changes**
16. Update MockFloorPlanManager to match new protocol
17. Update FloorPlanManagerTest
18. Update FloorPlanTabViewModelTest
19. Update FloorPlanDetailViewModelTest (add DeviceManager mock, sync tests)

**Phase 6: Validation**
20. Run full test suite
21. Build with zero errors
22. Manual test floor plan feature end-to-end

## Open Questions

None — the design follows the team's established module hierarchy and addresses the architectural concerns directly.
