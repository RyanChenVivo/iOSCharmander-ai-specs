## ADDED Requirements

### Requirement: FloorPlanDetail Combined Data Structure
The system SHALL provide a `FloorPlanDetail` struct that combines a floor plan and its associated device positions as the single source of truth for the detail view.

#### Scenario: FloorPlanDetail holds floor plan and device positions together
- **WHEN** a user navigates to a floor plan detail view
- **THEN** FloorPlanManager exposes `@Published currentFloorPlanDetail: FloorPlanDetail?`
- **AND** FloorPlanDetail contains `floorPlan: FloorPlan` and `devicePositions: [DevicePosition]`
- **AND** FloorPlanDetail conforms to Sendable and Equatable
- **AND** View observes this single property for all detail data

#### Scenario: FloorPlanDetail lifecycle follows detail view navigation
- **WHEN** user enters a floor plan detail view
- **THEN** ViewModel fetches positions, fills device info, and calls `setCurrentFloorPlanDetail()` with a populated FloorPlanDetail
- **AND** WHEN user leaves the detail view
- **THEN** ViewModel calls `setCurrentFloorPlanDetail(nil)` to clear state

### Requirement: View Observes Manager Published Properties Directly
Views SHALL observe FloorPlanManager's `@Published` properties directly for data, instead of observing duplicated state on ViewModels.

#### Scenario: FloorPlanTabView reads siteFloorPlans from Manager
- **WHEN** FloorPlanTabView displays the list of floor plans
- **THEN** View observes `FloorPlanManager.shared.siteFloorPlans` directly
- **AND** View does NOT read siteFloorPlans from ViewModel
- **AND** ViewModel does NOT maintain a `@Published var siteFloorPlans` copy

#### Scenario: FloorPlanDetailView reads currentFloorPlanDetail from Manager
- **WHEN** FloorPlanDetailView displays floor plan detail
- **THEN** View observes `FloorPlanManager.shared.currentFloorPlanDetail` directly
- **AND** View does NOT read devicePositions or floorPlan from ViewModel
- **AND** ViewModel does NOT maintain `@Published var devicePositions` or `@Published var floorPlan`

### Requirement: DevicePosition Stores Parsed CompositeType
DevicePosition SHALL store `compositeType: DeviceCompositeType` as a stored property, populated by FloorPlanManager during API data transformation, so consumers do not need to parse the API serial number format.

#### Scenario: Manager parses deviceSerialNumber into compositeType during transformation
- **WHEN** FloorPlanManager transforms API DevicePositionBackendModel to DevicePosition
- **THEN** Manager parses `deviceSerialNumber` (format `"thingName:derivant"`) into `DeviceCompositeType`
- **AND** stores the result as `compositeType: DeviceCompositeType` on DevicePosition
- **AND** DevicePosition is returned with `device = nil` (not filled by Manager)

#### Scenario: Unexpected serial number format is handled gracefully
- **WHEN** deviceSerialNumber does not contain a colon separator
- **THEN** Manager creates DeviceCompositeType with the full string as thingName and empty derivant
- **AND** a warning is logged

## MODIFIED Requirements

### Requirement: Floor Plan Manager Layer Separation
The floor plan feature SHALL have a dedicated Manager layer between ViewModels and API to provide proper separation of concerns where ViewModels handle UI orchestration and Manager handles data transformation and caching only.

#### Scenario: FloorPlanManager handles all API interactions
- **WHEN** floor plan data needs to be fetched
- **THEN** FloorPlanManager makes API calls via `@Dependency(\.vortexRestfulApi)`
- **AND** FloorPlanManager calls api.getFloorPlans() and api.getDevicePositions()
- **AND** ViewModels do NOT directly access VortexRestfulApi
- **AND** FloorPlanManager exposes clean interface to ViewModels
- **AND** FloorPlanManager is registered as dependency via `@Dependency(\.floorPlanManager)`

#### Scenario: FloorPlanManager performs data transformation without cross-Manager dependencies
- **WHEN** API returns Backend models
- **THEN** FloorPlanManager transforms Backend models to UI models
- **AND** FloorPlanManager parses API-format serial numbers into DeviceCompositeType
- **AND** FloorPlanManager does NOT depend on DeviceManager or any other Manager
- **AND** FloorPlanManager returns UI models with `device = nil` (ViewModel fills device info)

#### Scenario: FloorPlanManager exposes Published properties as single source of truth
- **WHEN** FloorPlanManager caches data
- **THEN** Manager exposes `@Published siteFloorPlans: [SiteFloorPlans]`
- **AND** Manager exposes `@Published currentFloorPlanDetail: FloorPlanDetail?`
- **AND** Views observe these properties directly
- **AND** Manager does NOT expose AsyncStream methods for state observation

#### Scenario: FloorPlanManager uses protocol for testability
- **WHEN** FloorPlanManager is implemented
- **THEN** FloorPlanManagerProtocol defines Manager interface
- **AND** protocol includes: fetchAllFloorPlans, fetchDevicePositions, findFloorPlan, searchFloorPlans, setCurrentFloorPlanDetail
- **AND** protocol does NOT include fetchFloorPlans(forSiteID:) (demoted to private)
- **AND** protocol does NOT include siteFloorPlansValues() (removed)
- **AND** protocol is Sendable for Swift 6 concurrency
- **AND** protocol enables MockFloorPlanManager in tests

### Requirement: Pre-populate Complete Device Information
DevicePosition SHALL have a mutable `device: DeviceItem?` property that is populated by the ViewModel (not Manager) using DeviceManager, and is reactively updated when device status changes.

#### Scenario: DevicePosition is returned from Manager without device info
- **WHEN** FloorPlanManager transforms DevicePositionBackendModel to DevicePosition
- **THEN** Manager populates coordinate properties and compositeType
- **AND** Manager sets `device = nil`
- **AND** Manager does NOT call DeviceManager.findDevice()
- **AND** Manager does NOT have a DeviceManager dependency

#### Scenario: ViewModel fills device info after fetching positions
- **WHEN** FloorPlanDetailViewModel receives positions from Manager
- **THEN** ViewModel iterates positions and calls `deviceManager.findDevice(bySource: position.compositeType)`
- **AND** ViewModel sets `position.device` to the found DeviceItem
- **AND** ViewModel writes the completed FloorPlanDetail to Manager via `setCurrentFloorPlanDetail()`

#### Scenario: DevicePosition provides UI-ready computed properties
- **WHEN** View needs to display device status
- **THEN** DevicePosition provides cameraStatus computed property
- **AND** cameraStatus returns .online when device.online && !device.isUpdatingFirmware
- **AND** cameraStatus returns .updating when device.isUpdatingFirmware
- **AND** cameraStatus returns .offline when device not found or offline
- **AND** View accesses device properties directly via position.device?.property

#### Scenario: Device status changes propagate reactively to View
- **WHEN** a device goes online, offline, or starts firmware update
- **THEN** FloorPlanDetailViewModel receives the change via `deviceManager.devicesValues()` AsyncStream
- **AND** ViewModel re-matches device info to all positions
- **AND** ViewModel calls `setCurrentFloorPlanDetail()` with updated positions
- **AND** Manager's `@Published currentFloorPlanDetail` updates
- **AND** View automatically refreshes device markers with new status

### Requirement: ViewModel UI Logic Only
The floor plan ViewModels SHALL contain UI state management and orchestration logic (triggering fetches, syncing cross-Manager data, writing assembled data back to Manager) but SHALL NOT contain data transformation logic.

#### Scenario: FloorPlanTabViewModel manages fetch orchestration and UI state
- **WHEN** FloorPlanTabViewModel is implemented
- **THEN** ViewModel has `@Published var isLoading` for UI state
- **AND** ViewModel triggers `floorPlanManager.fetchAllFloorPlans()` on appear and pull-to-refresh
- **AND** ViewModel delegates search to `floorPlanManager.searchFloorPlans()`
- **AND** ViewModel handles navigation via SheetManager
- **AND** ViewModel does NOT maintain `@Published var siteFloorPlans` (View reads Manager directly)
- **AND** ViewModel does NOT subscribe to AsyncStream from Manager

#### Scenario: FloorPlanDetailViewModel orchestrates device sync
- **WHEN** FloorPlanDetailViewModel is implemented
- **THEN** ViewModel has `@Dependency(\.deviceManager)` for device info lookup
- **AND** ViewModel has `@Dependency(\.floorPlanManager)` for data operations
- **AND** ViewModel fetches positions, fills device info, and writes FloorPlanDetail to Manager
- **AND** ViewModel starts a deviceSyncTask subscribing to `deviceManager.devicesValues()`
- **AND** ViewModel re-matches devices and updates Manager on each emission
- **AND** ViewModel keeps UI-only state: selectedDeviceID, zoomScale, viewcellControl, isStreamingFullScreen, isLoading

#### Scenario: FloorPlanDetailViewModel manages lifecycle correctly
- **WHEN** detail view appears
- **THEN** ViewModel fetches positions, fills device info, sets FloorPlanDetail, starts device sync
- **AND** WHEN detail view disappears
- **THEN** ViewModel cancels deviceSyncTask, stops streaming, calls setCurrentFloorPlanDetail(nil)

### Requirement: Floor Plan Manager Comprehensive Testing
The FloorPlanManager SHALL have comprehensive unit test coverage (80%+) to ensure data layer reliability independently from UI layer, reflecting the new architecture where Manager has no DeviceManager dependency.

#### Scenario: FloorPlanManager tests verify data transformation without device info
- **WHEN** FloorPlanManager is tested
- **THEN** tests verify fetchDevicePositions returns positions with `device = nil`
- **AND** tests verify compositeType is correctly parsed from deviceSerialNumber
- **AND** tests verify unexpected serial number format handling
- **AND** tests do NOT inject or assert on DeviceManager

#### Scenario: FloorPlanManager tests verify currentFloorPlanDetail state management
- **WHEN** FloorPlanManager is tested
- **THEN** tests verify setCurrentFloorPlanDetail stores and publishes the detail
- **AND** tests verify setCurrentFloorPlanDetail(nil) clears the detail
- **AND** tests verify currentFloorPlanDetail is initially nil

#### Scenario: FloorPlanDetailViewModel tests verify device sync
- **WHEN** FloorPlanDetailViewModel is tested
- **THEN** tests inject MockDeviceManager and MockFloorPlanManager
- **AND** tests verify device info is filled after fetching positions
- **AND** tests verify deviceSyncTask updates positions when devices change
- **AND** tests verify cleanup sets detail to nil and cancels sync task

#### Scenario: Manager tests use MockVortexRestfulApi
- **WHEN** FloorPlanManager is tested
- **THEN** tests inject MockVortexRestfulApi dependency
- **AND** mock returns Backend models (not UI models)
- **AND** tests verify Manager transforms Backend to UI correctly
- **AND** tests can simulate API failures