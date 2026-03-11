# Refactor Floor Plan Manager Architecture

## Summary
Refactor FloorPlanManager to be a pure data transformation and caching layer, removing DeviceManager dependency. Restructure the data flow so that Views directly observe FloorPlanManager's `@Published` properties (single source of truth), while ViewModels only orchestrate timing (fetch, sync) and hold UI-only state.

## Motivation
The current FloorPlanManager violates the team's module hierarchy principles:

1. **DeviceManager coupling**: FloorPlanManager directly depends on DeviceManager to pre-populate device information in `DevicePosition`. A Manager should only transform API data into internal models, not reach into other Managers.
2. **Duplicated state**: FloorPlanTabViewModel maintains its own `@Published var siteFloorPlans` copy, subscribed via AsyncStream from Manager. This creates unnecessary indirection when the team pattern is `View → XXXManager's Published`.
3. **ViewModel holds data it shouldn't**: FloorPlanDetailViewModel holds `@Published var devicePositions` and `@Published var floorPlan`, which should live in the Manager as the single source of truth.
4. **AsyncStream overhead**: `siteFloorPlansValues()` wraps `@Published` in an AsyncStream just so ViewModel can re-publish it. View can observe Manager directly.

The team's intended module hierarchy:
```
View → FeatureToggle → XXXManager Protocol → backend api
View → ViewModel → XXXManager Protocol → backend api
View → XXXManager's Published
```

FloorPlanManager should conform to this: a passive data store that transforms API data, holds `@Published` state for Views, and exposes write methods for ViewModels to update state at the right time.

## Goals
- Remove DeviceManager dependency from FloorPlanManager entirely
- Make FloorPlanManager a pure API-to-UI-model transformation + caching layer
- Introduce `FloorPlanDetail` struct combining floor plan + device positions as single source of truth
- Views observe FloorPlanManager's `@Published` directly (no AsyncStream intermediary)
- ViewModels become thin orchestrators: trigger fetches, sync device state from DeviceManager, write back to Manager
- FloorPlanDetailViewModel subscribes to DeviceManager changes and syncs device status reactively
- Maintain all existing floor plan functionality without regression
- Update unit tests to reflect new architecture

## Non-Goals
- Adding new floor plan features or capabilities
- Changing floor plan UI/UX design
- Modifying API contracts with backend
- Changing DeviceManager's interface or implementation
- Performance optimization beyond removing unnecessary indirection

## Success Metrics
- Zero DeviceManager references in FloorPlanManager
- Zero AsyncStream methods in FloorPlanManagerProtocol
- FloorPlanTabViewModel has no `@Published var siteFloorPlans` (View reads Manager directly)
- FloorPlanDetailViewModel has no `@Published var devicePositions` or `@Published var floorPlan` (View reads Manager directly)
- FloorPlanDetailViewModel subscribes to `deviceManager.devicesValues()` and reactively updates device info
- Device online/offline/updating status changes reflect in UI without manual refresh
- All existing unit tests updated and passing
- Build succeeds with zero errors

## Design Decisions

### Introduce FloorPlanDetail as Combined Data Structure
**Decision:** Create a new `FloorPlanDetail` struct that holds a floor plan and its associated device positions with device info.

**Rationale:**
- Single source of truth for detail view data
- View observes one `@Published` property instead of multiple scattered pieces
- Clean lifecycle: set on enter, nil on leave

**Implementation:**
```swift
public struct FloorPlanDetail: Sendable, Equatable {
    public let floorPlan: FloorPlan
    public var devicePositions: [DevicePosition]
}
```

### FloorPlanManager as Passive Data Store
**Decision:** FloorPlanManager holds `@Published` state and exposes write methods. It does not subscribe to or depend on any other Manager.

**Rationale:**
- Conforms to team pattern: Manager = API data transformation + cache
- View directly observes `@Published` properties on `FloorPlanManager.shared`
- ViewModel decides when and what to write; Manager just stores it

**Published properties:**
```swift
@Published private(set) var siteFloorPlans: [SiteFloorPlans] = []
@Published private(set) var currentFloorPlanDetail: FloorPlanDetail? = nil
```

### Remove AsyncStream from Protocol
**Decision:** Remove `siteFloorPlansValues()` from FloorPlanManagerProtocol and implementation.

**Rationale:**
- Views observe `FloorPlanManager.shared` directly as `ObservableObject`
- AsyncStream was only needed because ViewModel re-published Manager state
- Removing it simplifies the data flow and eliminates the subscription task in ViewModel

### DevicePosition: Stored compositeType + Mutable device
**Decision:** `DevicePosition` gains `compositeType: DeviceCompositeType` as a stored property (populated by Manager), and `device: DeviceItem?` changes from `let` to `var` (filled by ViewModel).

**Rationale:**
- FloorPlanManager parses `deviceSerialNumber` → `compositeType` during transformation (API format conversion)
- ViewModel receives positions with `compositeType` ready to use for `deviceManager.findDevice(bySource:)`
- FloorPlanManager returns positions with `device = nil`; ViewModel fills and updates it reactively
- `cameraStatus` computed property continues to work based on `device` value

### ViewModel Orchestrates Device Sync via Combine/AsyncStream
**Decision:** FloorPlanDetailViewModel subscribes to `deviceManager.devicesValues()` and updates `currentFloorPlanDetail` on Manager whenever devices change.

**Rationale:**
- Keeps DeviceManager dependency out of FloorPlanManager
- ViewModel is the right layer for "orchestrating timing and data assembly"
- Reactive: device online/offline changes automatically propagate to View via Manager's `@Published`

**Flow:**
```
DeviceManager devices change
  → DetailViewModel receives via devicesValues() AsyncStream
  → DetailViewModel re-matches device info to positions
  → DetailViewModel calls Manager.setCurrentFloorPlanDetail()
  → Manager's @Published updates
  → View automatically refreshes
```

### Simplify FloorPlanManagerProtocol
**Decision:** Reduce protocol to essential methods only.

**Implementation:**
```swift
public protocol FloorPlanManagerProtocol: Sendable {
    // Batch fetch + cache update
    func fetchAllFloorPlans(sites: [SiteItem]) async throws -> [SiteFloorPlans]

    // Fetch device positions (coordinates only, no device info)
    func fetchDevicePositions(forFloorPlanID floorPlanID: String) async throws -> [DevicePosition]

    // Cache queries
    @MainActor func findFloorPlan(byID id: String) -> FloorPlan?
    @MainActor func searchFloorPlans(keyword: String) -> [SiteFloorPlans]

    // Detail view state management (ViewModel writes, View reads via @Published)
    @MainActor func setCurrentFloorPlanDetail(_ detail: FloorPlanDetail?)
}
```

**Removed from protocol:**
- `fetchFloorPlans(forSiteID:)` — demoted to private (only used internally by `fetchAllFloorPlans`)
- `siteFloorPlansValues()` — removed (View observes `@Published` directly)

### FloorPlanTabViewModel Simplification
**Decision:** Remove duplicated state and subscription logic from FloorPlanTabViewModel.

**Changes:**
- Remove `@Published var siteFloorPlans` — View reads `FloorPlanManager.shared.siteFloorPlans` directly
- Remove `subscriptionTask` and AsyncStream subscription
- Keep: `@Published var isLoading`, fetch triggering, error handling, navigation, search delegation

### FloorPlanDetailViewModel Restructuring
**Decision:** DetailViewModel gains DeviceManager dependency, loses data-holding `@Published` properties.

**Changes:**
- Remove `@Published var devicePositions` — View reads `FloorPlanManager.shared.currentFloorPlanDetail`
- Remove `@Published var floorPlan` — View reads `FloorPlanManager.shared.currentFloorPlanDetail?.floorPlan`
- Add `@Dependency(\.deviceManager) var deviceManager`
- Add `deviceSyncTask` to subscribe to `deviceManager.devicesValues()`
- Keep: `@Published var selectedDeviceID`, `@Published var zoomScale`, `@Published var viewcellControl`, `@Published var isStreamingFullScreen`, `@Published var isLoading`

**Lifecycle:**
1. `onViewAppear`: fetch positions → fill device info → `setCurrentFloorPlanDetail()` → start device sync task
2. Device change: re-match devices → `setCurrentFloorPlanDetail()` (View auto-updates)
3. `onViewDisappear`/`cleanup`: cancel sync task → `setCurrentFloorPlanDetail(nil)`

### Serial Number Parsing Stays in FloorPlanManager
**Decision:** FloorPlanManager parses `deviceSerialNumber` into `DeviceCompositeType` during data transformation. `DevicePosition` stores `compositeType` as a stored property (`let`), not a computed property.

**Rationale:**
- The API returns `deviceSerialNumber` in a format (`"thingName:derivant"`) that differs from our internal `DeviceCompositeType`. This conversion is a data transformation responsibility — it belongs in Manager.
- ViewModel receives positions with `compositeType` already resolved and can directly call `deviceManager.findDevice(bySource: position.compositeType)` without needing to know the API format.
- Keeps parsing logic centralized in Manager, not scattered across consumers.

## Alternative Approaches

### Alternative 1: Keep DeviceManager in FloorPlanManager, Just Restructure Published Properties
**Rejected Reason:** Does not address the core concern — FloorPlanManager should not depend on DeviceManager. Violates the principle that a Manager only transforms API data.

### Alternative 2: Create a New FloorPlanDeviceResolver Middleware
**Rejected Reason:** Over-engineering. The device matching logic is simple enough to live in ViewModel. Adding another layer increases complexity without clear benefit.

### Alternative 3: View Queries DeviceManager Directly for Each Position
**Rejected Reason:** Performance concern — would call `findDevice()` during every render cycle for every marker on the floor plan. Pre-filling in ViewModel and storing in Manager avoids this.

## Dependencies
- Existing VortexRestfulApi infrastructure
- Existing DeviceManagerProtocol (`devicesValues()` AsyncStream, `findDevice(bySource:)`)
- swift-dependencies package for DI
- Existing MockFloorPlanManager and MockDeviceManager for tests

## Migration Strategy
1. Create `FloorPlanDetail` struct in FloorPlanManager directory
2. Add `compositeType: DeviceCompositeType` as stored property to `DevicePosition`, change `device` from `let` to `var`
3. Update `FloorPlanManagerProtocol` — remove `fetchFloorPlans(forSiteID:)`, remove `siteFloorPlansValues()`, add `setCurrentFloorPlanDetail()`
4. Update `FloorPlanManager` — remove DeviceManager dependency, add `@Published currentFloorPlanDetail`, add `parseCompositeType(from:)` private method, demote `fetchFloorPlans` to private, implement `setCurrentFloorPlanDetail()`, update `fetchDevicePositions` to parse compositeType but not fill device info
5. Update `FloorPlanTabViewModel` — remove `@Published siteFloorPlans`, remove `subscriptionTask`, keep fetch/error/navigation logic
6. Update `FloorPlanTabView` — observe `FloorPlanManager.shared.siteFloorPlans` directly
7. Update `FloorPlanDetailViewModel` — add DeviceManager dependency, add device sync task, implement device matching logic, call `setCurrentFloorPlanDetail()` for writes
8. Update `FloorPlanDetailView` — observe `FloorPlanManager.shared.currentFloorPlanDetail` directly
9. Update `MockFloorPlanManager` to match new protocol
10. Update all unit tests (FloorPlanManagerTest, FloorPlanTabViewModelTest, FloorPlanDetailViewModelTest)
11. Run full test suite, verify build with zero errors

## Risks & Mitigations

### Risk: View Observing Manager Singleton Directly May Complicate Testing
**Mitigation:**
- Views in tests can use `withDependencies` to inject MockFloorPlanManager
- For SwiftUI previews, mock Manager can be provided
- Protocol-based DI pattern is maintained for ViewModel testing

### Risk: Device Sync Race Condition
**Mitigation:**
- `deviceSyncTask` runs on MainActor (same as ViewModel)
- `setCurrentFloorPlanDetail()` is `@MainActor`, ensuring serial access
- Cancel task before setting detail to nil on disappear

### Risk: Breaking Existing Functionality During Refactoring
**Mitigation:**
- Refactor incrementally (Manager first, then TabViewModel, then DetailViewModel)
- Keep existing tests passing at each step
- Device status display verified manually after DetailViewModel changes

## Open Questions
None - the design follows established project patterns and addresses the architectural concerns directly.
