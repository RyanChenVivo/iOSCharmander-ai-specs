## MODIFIED Requirements

### Requirement: FloorPlanManager provides centralized data access

FloorPlanManager SHALL serve as the single source of truth for floor plan data, providing fetching, caching, searching, and lookup capabilities.

#### Scenario: FloorPlanManager caches all fetched floor plans
- **WHEN** `fetchAllFloorPlans()` completes successfully
- **THEN** FloorPlanManager updates internal `siteFloorPlans` cache with all fetched data
- **AND** publishes the updated data to all subscribers

#### Scenario: FloorPlanManager provides AsyncStream for site floor plans
- **WHEN** `siteFloorPlansValues()` is called
- **THEN** FloorPlanManager returns an AsyncStream of `[SiteFloorPlans]`
- **AND** subscribers receive updates when `siteFloorPlans` changes

#### Scenario: FloorPlanManager provides floor plan lookup by ID
- **WHEN** `findFloorPlan(byID:)` is called with a valid floor plan ID
- **THEN** FloorPlanManager returns the matching FloorPlan from cache
- **AND** returns nil if the ID is not found in cache

#### Scenario: FloorPlanManager provides search functionality
- **WHEN** `searchFloorPlans(keyword:)` is called with a search keyword
- **THEN** FloorPlanManager returns filtered SiteFloorPlans where site name or floor plan name matches
- **AND** returns empty array if keyword is empty

#### Scenario: FloorPlanDetailViewModel fetches device positions
- **WHEN** `loadDevicePositions()` is called
- **THEN** FloorPlanDetailViewModel calls `floorPlanManager.fetchDevicePositions(forFloorPlanID:)` using the stored `floorPlanID`

### Requirement: FloorPlanDetailViewModel initializes with floor plan ID

FloorPlanDetailViewModel SHALL accept only a `floorPlanID` parameter and retrieve the full FloorPlan object from FloorPlanManager.

#### Scenario: FloorPlanDetailViewModel loads floor plan on appear
- **WHEN** view appears
- **THEN** FloorPlanDetailViewModel calls `floorPlanManager.findFloorPlan(byID:)` to get the FloorPlan
- **AND** updates `floorPlan` published property

#### Scenario: FloorPlanDetailViewModel handles missing floor plan
- **WHEN** `findFloorPlan(byID:)` returns nil
- **THEN** FloorPlanDetailViewModel sets appropriate error state
- **AND** does not attempt to load device positions

### Requirement: FloorPlanTabViewModel subscribes to Manager data

FloorPlanTabViewModel SHALL subscribe to FloorPlanManager's data stream instead of maintaining local state.

#### Scenario: FloorPlanTabViewModel subscribes to site floor plans
- **WHEN** view appears
- **THEN** FloorPlanTabViewModel subscribes to `floorPlanManager.siteFloorPlansValues()`
- **AND** updates its published property when Manager data changes

#### Scenario: FloorPlanTabViewModel delegates search to Manager
- **WHEN** search is performed
- **THEN** FloorPlanTabViewModel calls `floorPlanManager.searchFloorPlans(keyword:)`
- **AND** returns the filtered results

### Requirement: SheetManager opens floor plan detail with ID

SheetManager SHALL accept only a `floorPlanID` parameter when opening floor plan detail view.

#### Scenario: SheetManager opens floor plan detail
- **WHEN** `openFloorPlanDetail(floorPlanID:)` is called
- **THEN** SheetManager presents FloorPlanDetailView initialized with the provided ID
