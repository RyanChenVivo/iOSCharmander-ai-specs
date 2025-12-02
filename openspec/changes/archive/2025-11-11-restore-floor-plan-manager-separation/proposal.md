# Restore Floor Plan Manager Separation

## Summary
Restore FloorPlanManager as a proper separation layer between UI (ViewModels) and Backend (API), with clear separation of concerns where ViewModels handle View-related logic only and Manager handles data-related logic including API calls, data transformation, and UI object creation.

## Motivation
The previous refactoring (PR #7) removed FloorPlanManager and implemented direct VortexRestfulApi dependency injection in ViewModels. While this achieved the goal of removing singletons and improving testability, it violated the project's architectural principle of separation of concerns:

1. **ViewModels contain data logic**: ViewModels directly call APIs and perform data transformation, mixing View-related logic with data-related logic
2. **No clear separation layer**: Missing intermediary layer between UI and Backend leads to tight coupling
3. **UI models serve dual purpose**: Current `FloorPlanItem` and `DevicePosition` are used as both API response models and UI models, violating single responsibility principle
4. **Resource management concerns**: Direct API access in ViewModels can lead to resource waste and harder maintenance

The code review feedback explicitly requests:
- Restore FloorPlanManager as a separation layer between UI and Backend
- ViewModels should only handle View-related logic (UI state, user interactions)
- Manager should only handle data-related logic (API calls, data transformation, creating UI objects)
- Separate UI objects from Backend objects
- Add comprehensive Manager unit tests

## Goals
- Restore FloorPlanManager as a dedicated layer between ViewModels and VortexRestfulApi
- Clearly separate Backend models from UI models
- Move all data fetching and transformation logic from ViewModels to FloorPlanManager
- Keep ViewModels focused exclusively on UI state management and user interaction handling
- Achieve comprehensive test coverage for FloorPlanManager (80%+)
- Update existing ViewModel tests to reflect new architecture
- Maintain all existing floor plan functionality without regression

## Non-Goals
- Adding new floor plan features or capabilities
- Changing floor plan UI/UX design
- Modifying API contracts with backend
- Performance optimization (unless directly related to architecture)
- Changing test framework or testing patterns

## Success Metrics
- API naming follows HTTP method convention (`getFloorPlans`, `getDevicePositions`)
- Output models match API method names (`GetFloorPlansOutput`, `GetDevicePositionsOutput`)
- FloorPlanManager successfully restored with clear API interface
- 100% of API calls moved from ViewModels to Manager
- Backend models (API layer) clearly separated from UI models (Presentation layer)
- ViewModels only contain UI state properties and interaction handlers
- DevicePosition includes DeviceCompositeType (not full DeviceItem) + essential display properties
- Zero findDevice(byID:) calls in Views for marker rendering (display info pre-populated by Manager)
- DevicePosition has no dependency on full DeviceItem model (loose coupling achieved)
- Full DeviceItem lookup only when truly needed (e.g., streaming start via DeviceCompositeType)
- 80%+ code coverage for FloorPlanManager
- All existing 39 unit tests still passing after refactoring
- At least 15 new unit tests for FloorPlanManager
- Zero direct VortexRestfulApi calls in ViewModels
- Build succeeds with zero errors and zero warnings

## Design Decisions

### Update API Naming to Follow HTTP Method Convention
**Decision:** Rename floor plan API methods and output models to follow project's HTTP method naming convention.

**Rationale:**
- Project convention: API methods use HTTP method as prefix (get, post, patch, delete, put)
- Output models should match their corresponding API method names
- Improves consistency across the codebase
- Makes API contract clearer and more predictable

**Changes:**
- API Methods:
  - `listFloorPlans(siteID:)` → `getFloorPlans(siteID:)`
  - `listDevicePositions(floorPlanID:)` → `getDevicePositions(floorPlanID:)`
- Output Models:
  - `ListFloorPlansOutput` → `GetFloorPlansOutput`
  - `ListDevicePositionsOutput` → `GetDevicePositionsOutput`

**Examples from existing code:**
- `getMyPreference()` → returns `MyPreference`
- `getTokenStatus()` → returns `GetTokenStatusOutput`
- `getMyCustomizedViews()` → returns `GetMyCustomizedViewsOutput`
- `getFloorPlans()` → returns `GetFloorPlansOutput` ✅
- `getDevicePositions()` → returns `GetDevicePositionsOutput` ✅

### Restore FloorPlanManager as Separation Layer
**Decision:** Create FloorPlanManager as an intermediary layer between ViewModels and VortexRestfulApi.

**Rationale:**
- Provides clear separation of concerns: UI logic (ViewModel) vs Data logic (Manager)
- Reduces coupling between UI layer and Backend/API layer
- Enables easier testing by isolating data logic
- Allows ViewModels to remain lightweight and focused on UI state
- Follows project's architectural guidelines for reasonable use of ViewModels and Managers
- Manager can be shared across multiple ViewModels without duplication

**Responsibilities:**
- **FloorPlanManager handles:**
  - All API calls via VortexRestfulApi
  - Data transformation from Backend models to UI models
  - Business logic for floor plan operations (fetching, filtering, caching)
  - Error handling for API failures

- **ViewModels handle:**
  - UI state (@Published properties)
  - User interaction methods (tap, swipe, zoom)
  - Navigation decisions
  - SwiftUI lifecycle (onAppear, onChange)
  - Calling Manager methods and updating UI state

### Separate Backend Models from UI Models
**Decision:** Create distinct Backend models for API responses, separate from UI models used by Views.

**Rationale:**
- Backend models represent API contract and should match server response structure
- UI models represent presentation needs and can include computed properties, formatting, etc.
- Changes to API don't require changes to UI layer and vice versa
- Enables type safety and clear data flow through layers
- Follows single responsibility principle

**Implementation:**
- **Backend Models** (in VortexFeatures/Common/VortexBackend/Model/):
  - `FloorPlanBackendModel`: Raw API response structure
  - `DevicePositionBackendModel`: Raw device position from API

- **UI Models** (in VortexFeatures/Core/FloorPlanManager/):
  - `FloorPlanItem`: UI representation with computed properties
  - `DevicePosition`: UI representation with helper methods

- **Transformation** (in FloorPlanManager):
  - Convert Backend models to UI models
  - Add any UI-specific data or formatting
  - Handle nil/optional values appropriately for UI

### Use Protocol-Based Dependency Injection for Manager
**Decision:** Define FloorPlanManagerProtocol and use dependency injection for FloorPlanManager.

**Rationale:**
- Enables easy mocking in unit tests (MockFloorPlanManager)
- Makes dependencies explicit and testable
- Follows project's established pattern with DeviceManager and other managers
- Allows multiple implementations if needed (e.g., offline mode, demo mode)
- Improves code maintainability and testability

**Implementation:**
```swift
public protocol FloorPlanManagerProtocol: Sendable {
    func fetchFloorPlans(forSiteID siteID: String) async throws -> [FloorPlanItem]
    func fetchDevicePositions(forFloorPlanID floorPlanID: String) async throws -> [DevicePosition]
    func fetchAllFloorPlans(sites: [SiteItem]) async throws -> [FloorPlanItem]
}
```

### Manager Uses VortexRestfulApi Dependency
**Decision:** FloorPlanManager internally uses `@Dependency(\.vortexRestfulApi)` to access API.

**Rationale:**
- Manager is responsible for all API interactions
- ViewModels should never directly access VortexRestfulApi
- Creates clean architectural boundary: ViewModel → Manager → API
- Manager can add caching, retry logic, or other data operations without affecting ViewModels

### Pre-populate Essential Device Information with DeviceCompositeType
**Decision:** FloorPlanManager pre-populates essential device information (DeviceCompositeType, name, icon, status) in DevicePosition, avoiding storage of full DeviceItem to prevent over-coupling.

**Rationale:**
- Eliminates repeated `findDevice(byID:)` calls in View for marker rendering (significant performance improvement)
- Loose coupling: DevicePosition doesn't depend on full DeviceItem, only stores display-critical data
- Flexibility: When full DeviceItem needed (e.g., start streaming), use DeviceCompositeType to look it up
- Minimal dependencies: Only includes what's needed for marker display, not entire device model
- Manager provides UI-ready data for common operations without over-coupling models

**Current Problem:**
Views call `viewModel.findDevice(byID: position.deviceSerialNumber)?.simpleStateIcon` every render, causing:
- Multiple repeated device lookups for same device
- Unnecessary coupling between View and device lookup logic
- Potential performance issues when rendering many markers

**Why DeviceCompositeType instead of full DeviceItem:**
- ❌ Storing full `DeviceItem?` creates tight coupling between DevicePosition and DeviceItem
- ❌ DevicePosition would contain unnecessary data (DeviceItem has many properties not needed for rendering)
- ✅ DeviceCompositeType is lightweight identifier (thingName + derivant)
- ✅ Store only display-critical properties (name, icon, online, updating status)
- ✅ Full DeviceItem lookup only when truly needed (rare, e.g., starting streaming)

**Implementation:**
```swift
// DevicePosition with minimal coupling
public struct DevicePosition {
    // ... position properties
    public let deviceCompositeType: DeviceCompositeType  // For lookup if needed
    public let deviceName: String?                        // Display
    public let connectionIcon: String?                    // Display
    public let isOnline: Bool                            // Display
    public let isUpdatingFirmware: Bool                  // Display
}

// FloorPlanManager transformation
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
```

**Benefits:**
- Views simplified: `position.connectionIcon` instead of `viewModel.findDevice(byID:)?.simpleStateIcon`
- Performance: one lookup per device during transformation, not repeatedly during rendering
- Loose coupling: DevicePosition independent of DeviceItem changes
- ViewModel's findDevice() only used when full device truly needed (streaming start)
- Manager provides complete data for common operations (marker display)

### Comprehensive Manager Testing
**Decision:** Add extensive unit tests for FloorPlanManager with 80%+ coverage.

**Rationale:**
- Manager contains critical business logic and data transformation
- Testing Manager in isolation validates data layer independently from UI layer
- Enables safe future refactoring of Manager without touching ViewModels
- Ensures API error handling works correctly
- Validates Backend to UI model transformation logic

**Test Coverage Areas:**
- Floor plan fetching for single site
- Floor plan fetching for multiple sites
- Device position fetching
- Error handling (API failures, network errors)
- Empty response handling
- Backend to UI model transformation
- Concurrent request handling

## Alternative Approaches

### Alternative 1: Keep Current Architecture (Direct API in ViewModels)
**Rejected Reason:** Violates separation of concerns. Mixes UI logic with data logic. Makes ViewModels harder to test and maintain. Doesn't address reviewer's architectural concerns.

### Alternative 2: Create Repository Pattern Instead of Manager
**Rejected Reason:** Over-engineering for current needs. Repository pattern is typically used for data persistence/caching layers. Project already uses "Manager" naming convention for similar layers (DeviceManager, AppManager).

### Alternative 3: Use Single Unified Model (No Backend/UI Separation)
**Rejected Reason:** Creates tight coupling between API contract and UI representation. Makes it harder to change either layer independently. Violates single responsibility principle.

### Alternative 4: Put Business Logic in Models Instead of Manager
**Rejected Reason:** Models should be data containers, not active objects with business logic. Manager pattern provides better testability and separation.

## Dependencies
- Existing VortexRestfulApi infrastructure
- Existing DeviceManagerProtocol pattern (as reference)
- Swift Testing framework for unit tests
- Dependency injection via swift-dependencies package
- Existing Mock patterns in test target

## Migration Strategy
1. Update API naming to follow HTTP method convention
   - Rename `listFloorPlans()` to `getFloorPlans()` in protocol and implementations
   - Rename `listDevicePositions()` to `getDevicePositions()` in protocol and implementations
   - Rename `ListFloorPlansOutput` to `GetFloorPlansOutput`
   - Rename `ListDevicePositionsOutput` to `GetDevicePositionsOutput`
2. Create Backend models for API responses (FloorPlanBackendModel, DevicePositionBackendModel)
3. Update API response models to use Backend models instead of UI models
4. Create FloorPlanManagerProtocol defining Manager interface
5. Implement FloorPlanManager with API calls and model transformation logic
6. Add @Dependency registration for FloorPlanManager
7. Create MockFloorPlanManager for tests
8. Add comprehensive FloorPlanManager unit tests (15+ tests)
9. Refactor FloorPlanTabViewModel to use FloorPlanManager dependency
10. Refactor FloorPlanDetailViewModel to use FloorPlanManager dependency
11. Remove VortexRestfulApi dependency from ViewModels
12. Update existing ViewModel tests to use MockFloorPlanManager
13. Run full test suite to verify 39+ tests passing
14. Validate build with zero errors/warnings

## Risks & Mitigations

### Risk: Breaking Existing Functionality During Refactoring
**Mitigation:**
- Keep existing tests passing throughout refactoring
- Add Manager tests before refactoring ViewModels
- Refactor incrementally (one ViewModel at a time)
- Manual testing after each major step

### Risk: Over-Engineering with Too Many Layers
**Mitigation:**
- Keep Manager interface simple and focused
- Only add abstraction that serves clear purpose (separation of concerns)
- Follow project's established patterns (DeviceManager as reference)
- Avoid adding caching or other features not requested

### Risk: Test Maintenance Burden Increases
**Mitigation:**
- Use shared test helpers and fixtures
- Keep mock objects simple and reusable
- Follow established test patterns from existing tests
- Document test structure clearly

### Risk: Performance Regression from Extra Layer
**Mitigation:**
- Manager layer is lightweight (just method forwarding and transformation)
- No caching or heavy operations unless necessary
- Profile before/after if concerns arise
- async/await ensures non-blocking operations

## Open Questions
None - implementation approach follows established project patterns and reviewer's explicit requirements.
