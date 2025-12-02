# mobile-floor-plan-architecture Specification

## Purpose
Define the architectural separation of concerns for the floor plan feature, establishing clear boundaries between UI layer (ViewModels), data layer (FloorPlanManager), and API layer (VortexRestfulApi) with proper model separation.

## ADDED Requirements

### Requirement: Floor Plan Manager Layer Separation
The floor plan feature SHALL have a dedicated Manager layer between ViewModels and API to provide proper separation of concerns where ViewModels handle UI logic only and Manager handles data logic.

#### Scenario: FloorPlanManager handles all API interactions
- **WHEN** floor plan data needs to be fetched
- **THEN** FloorPlanManager makes API calls via `@Dependency(\.vortexRestfulApi)`
- **AND** FloorPlanManager calls api.getFloorPlans() and api.getDevicePositions()
- **AND** ViewModels do NOT directly access VortexRestfulApi
- **AND** FloorPlanManager exposes clean interface to ViewModels
- **AND** FloorPlanManager is registered as dependency via `@Dependency(\.floorPlanManager)`

#### Scenario: FloorPlanManager performs data transformation
- **WHEN** API returns Backend models
- **THEN** FloorPlanManager transforms Backend models to UI models
- **AND** FloorPlanManager adds UI-specific data (e.g., deviceCount)
- **AND** FloorPlanManager returns fully populated UI models to ViewModels
- **AND** ViewModels receive data ready for presentation

#### Scenario: FloorPlanManager handles business logic
- **WHEN** complex data operations are needed
- **THEN** FloorPlanManager implements business logic (filtering, aggregation, etc.)
- **AND** FloorPlanManager handles error recovery and retry logic
- **AND** ViewModels only call Manager methods and update UI state
- **AND** no business logic exists in ViewModels

#### Scenario: FloorPlanManager uses protocol for testability
- **WHEN** FloorPlanManager is implemented
- **THEN** FloorPlanManagerProtocol defines Manager interface
- **AND** FloorPlanManager conforms to protocol
- **AND** protocol is Sendable for Swift 6 concurrency
- **AND** protocol enables MockFloorPlanManager in tests

### Requirement: Backend and UI Model Separation
The floor plan feature SHALL maintain separate Backend models (API layer) and UI models (Presentation layer) to ensure proper layering and independence.

#### Scenario: Backend models represent API contract
- **WHEN** API responses are decoded
- **THEN** responses decode to Backend models (FloorPlanBackendModel, DevicePositionBackendModel)
- **AND** Backend models match server response structure exactly
- **AND** Backend models are located in VortexFeatures/Common/VortexBackend/Model/FloorPlan/
- **AND** Backend models conform to VortexBackendModel protocol

#### Scenario: UI models represent presentation needs
- **WHEN** data is displayed in Views
- **THEN** Views use UI models (FloorPlanItem, DevicePosition)
- **AND** UI models include computed properties for presentation
- **AND** UI models are located in VortexFeatures/Core/FloorPlanManager/
- **AND** UI models conform to Identifiable, Equatable, Sendable

#### Scenario: FloorPlanManager transforms Backend to UI models
- **WHEN** FloorPlanManager receives Backend models from API
- **THEN** Manager transforms Backend models to UI models
- **AND** transformation happens in Manager layer only
- **AND** ViewModels never access Backend models directly
- **AND** API layer never references UI models

#### Scenario: API responses use Backend models
- **WHEN** VortexRestfulApi methods return floor plan data
- **THEN** GetFloorPlansOutput contains [FloorPlanBackendModel]
- **AND** GetDevicePositionsOutput contains [DevicePositionBackendModel]
- **AND** no UI models (FloorPlanItem, DevicePosition) exist in API response types
- **AND** API layer is independent of UI layer

### Requirement: Pre-populate Complete Device Information
The FloorPlanManager SHALL pre-populate complete device information in DevicePosition UI models by including the full DeviceItem to eliminate repeated lookups and allow access to all device extensions (including UI-layer extensions like simpleStateIcon).

#### Scenario: DevicePosition includes complete DeviceItem for simplicity
- **WHEN** FloorPlanManager transforms DevicePositionBackendModel to DevicePosition
- **THEN** Manager looks up device via DeviceManager.findDevice(bySource:)
- **AND** Manager stores complete DeviceItem in device: DeviceItem? property
- **AND** this simplifies design from 5 properties to 1 property
- **AND** allows View to access all device extensions (e.g., simpleStateIcon from iOSCharmander)
- **AND** solves module dependency issue (VortexFeatures accessing iOSCharmander extensions)
- **AND** device lookup happens once during transformation, not repeatedly in View

#### Scenario: DevicePosition provides UI-ready computed properties
- **WHEN** View needs to display device status
- **THEN** DevicePosition provides cameraStatus computed property
- **AND** cameraStatus returns .online when device.online && !device.isUpdatingFirmware
- **AND** cameraStatus returns .updating when device.isUpdatingFirmware
- **AND** cameraStatus returns .offline when device not found or offline
- **AND** View accesses device properties directly via position.device?.property

#### Scenario: FloorPlanManager uses DeviceManager dependency
- **WHEN** FloorPlanManager needs to look up device information
- **THEN** Manager uses `@Dependency(\.deviceManager)` injection
- **AND** Manager calls deviceManager.findDevice(bySource:) for each position
- **AND** Manager provides complete UI-ready DevicePosition models to ViewModels

#### Scenario: Views use pre-populated device information for marker display
- **WHEN** View needs to display device name, icon, or status on marker
- **THEN** View accesses position.device?.name directly
- **AND** View accesses position.device?.simpleStateIcon directly (UI extension)
- **AND** View accesses position.cameraStatus computed property
- **AND** View does NOT call viewModel.findDevice(byID:) for marker rendering
- **AND** no repeated device lookups occur during marker rendering
- **AND** all display information is pre-populated by Manager

#### Scenario: Complete DeviceItem available for operations
- **WHEN** ViewModel needs DeviceItem for operations (e.g., start streaming)
- **THEN** ViewModel accesses position.device directly (already populated)
- **AND** no additional device lookup needed
- **AND** streaming can start immediately with position.device
- **AND** simplified flow eliminates redundant findDevice calls

### Requirement: ViewModel UI Logic Only
The floor plan ViewModels SHALL contain only View-related logic (UI state, user interactions) and SHALL NOT contain data-related logic (API calls, data transformation, device lookups).

#### Scenario: ViewModels manage UI state only
- **WHEN** FloorPlanTabViewModel is implemented
- **THEN** ViewModel has @Published properties for UI state (isLoading, floorPlans, selectedID, etc.)
- **AND** ViewModel has user interaction methods (tapFloorPlan, pullToRefresh, etc.)
- **AND** ViewModel has navigation methods using SheetManager
- **AND** ViewModel does NOT make API calls directly

#### Scenario: ViewModels delegate data operations to Manager
- **WHEN** ViewModel needs to fetch floor plan data
- **THEN** ViewModel calls FloorPlanManager method
- **AND** ViewModel awaits result and updates UI state
- **AND** ViewModel handles loading state (isLoading true/false)
- **AND** ViewModel does NOT transform or manipulate data

#### Scenario: ViewModels use FloorPlanManager dependency
- **WHEN** ViewModels need floor plan data
- **THEN** ViewModel uses `@Dependency(\.floorPlanManager)`
- **AND** ViewModel does NOT use `@Dependency(\.vortexRestfulApi)`
- **AND** ViewModel calls Manager protocol methods
- **AND** ViewModel receives UI models from Manager

#### Scenario: ViewModels handle SwiftUI lifecycle
- **WHEN** View appears or changes
- **THEN** ViewModel handles onAppear() lifecycle
- **AND** ViewModel handles onChange() observers
- **AND** ViewModel updates @Published properties
- **AND** ViewModel triggers Manager calls when needed

### Requirement: Floor Plan Manager Comprehensive Testing
The FloorPlanManager SHALL have comprehensive unit test coverage (80%+) to ensure data layer reliability independently from UI layer.

#### Scenario: FloorPlanManager has 80%+ test coverage
- **WHEN** FloorPlanManager is tested
- **THEN** unit tests cover at least 80% of code paths
- **AND** tests verify floor plan fetching for single site
- **AND** tests verify floor plan fetching for multiple sites
- **AND** tests verify device position fetching
- **AND** tests verify empty response handling
- **AND** tests verify API error handling
- **AND** tests verify Backend to UI model transformation

#### Scenario: Manager tests use MockVortexRestfulApi
- **WHEN** FloorPlanManager is tested
- **THEN** tests inject MockVortexRestfulApi dependency
- **AND** mock returns Backend models (not UI models)
- **AND** tests verify Manager transforms Backend to UI correctly
- **AND** tests can simulate API failures

#### Scenario: Manager tests validate business logic
- **WHEN** Manager implements business logic
- **THEN** tests verify filtering logic
- **AND** tests verify aggregation logic (e.g., deviceCount calculation)
- **AND** tests verify concurrent request handling
- **AND** tests verify data consistency

