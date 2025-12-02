# Refactor Floor Plan Code Quality

## Summary
Refactor floor plan implementation to address code review feedback by removing mock data, eliminating singleton pattern in FloorPlanManager, adding comprehensive unit tests, and standardizing SwiftUI background modifier usage.

## Motivation
The initial floor plan implementation (PR #7) received code review feedback highlighting several areas for improvement:
1. Mock data exists in production code and should be removed
2. FloorPlanManager uses singleton pattern unnecessarily when dependency injection is more appropriate
3. Missing unit tests for ViewModels and business logic objects
4. Inconsistent SwiftUI background modifier usage

These issues impact code maintainability, testability, and production readiness. This refactoring addresses all review comments to bring the floor plan feature to production quality standards.

## Goals
- Remove all mock/fake data from FloorPlanManager and related components
- Refactor FloorPlanManager from singleton to dependency-injected API service
- Achieve 80%+ unit test coverage for floor plan ViewModels and business logic
- Standardize all background modifiers to use `.background(_:in:fillStyle:)` pattern
- Maintain existing floor plan functionality without regression

## Non-Goals
- Adding new floor plan features or capabilities
- Changing floor plan UI/UX design
- Modifying API contracts or backend integration
- Performance optimization (unless directly related to refactoring)

## Success Metrics
- Zero mock data references in production code
- FloorPlanManager replaced with dependency-injected VortexRestfulApi usage
- DeviceManager.shared replaced with dependency injection in floor plan ViewModels
- 80%+ code coverage for FloorPlanTabViewModel and FloorPlanDetailViewModel
- 100% of background modifiers follow standardized pattern
- All existing floor plan tests pass without modification
- At least 39 unit tests passing for floor plan functionality

## Design Decisions

### Remove Mock Data
**Decision:** Remove all mock data toggle logic and fake data generation from production code.

**Rationale:** Mock data should only exist in test targets. Having conditional mock data in production code:
- Increases risk of accidentally shipping test data to users
- Adds unnecessary code complexity and maintenance burden
- Violates separation of concerns between production and test code

**Implementation:**
- Remove `useMockData` flags and related conditional logic
- Keep API integration code only
- Move mock data to test fixtures in `iOSCharmanderTests/Test/Mock/`

### Refactor FloorPlanManager Architecture
**Decision:** Replace FloorPlanManager singleton with direct VortexRestfulApi dependency injection in ViewModels.

**Rationale:**
- FloorPlanManager currently only wraps API calls without additional business logic
- Singleton pattern is discouraged in the project (only used for truly global managers like DeviceManager, AppManager)
- Dependency injection via `@Dependency` macro provides better testability and follows MVVM architecture
- Aligns with project conventions in `openspec/project.md` (Architecture Patterns section)

**Implementation:**
- Remove FloorPlanManager singleton
- Add floor plan API methods directly to VortexRestfulApi extensions
- Inject `@Dependency(\.vortexRestfulApi)` in floor plan ViewModels
- Update all call sites to use injected dependency

### Use DeviceManager Dependency Injection
**Decision:** Replace direct `DeviceManager.shared` access with dependency injection in floor plan ViewModels.

**Rationale:**
- Follows established pattern in HomeViewModel and other ViewModels in the project
- Improves testability by allowing MockDeviceManager injection in unit tests
- Enables proper test isolation without relying on shared global state
- Makes dependencies explicit and easier to understand

**Implementation:**
- Add `@Dependency(\.deviceManager)` to FloorPlanTabViewModel
- Add `@Dependency(\.deviceManager)` to FloorPlanDetailViewModel
- Update both ViewModels' `make()` methods to inject DeviceManager
- Use MockDeviceManager in tests with predefined test sites
- Replace `deviceManager.sites` with `deviceManager.allSites()`

### Comprehensive Unit Test Coverage
**Decision:** Add unit tests for FloorPlanTabViewModel, FloorPlanDetailViewModel, and related business logic with 80%+ coverage.

**Rationale:**
- Project testing requirements mandate unit tests for all new ViewModels
- Current floor plan implementation lacks ViewModel tests (only partial FloorPlanDeviceSearchViewModelTests exists)
- High test coverage ensures reliability and prevents regressions
- Enables safe future refactoring

**Test Coverage Areas:**
- FloorPlanTabViewModel: site filtering, view mode toggle, search, pull-to-refresh
- FloorPlanDetailViewModel: device selection, streaming lifecycle, zoom/pan state, device status updates
- API integration: mock API responses for floor plan and device position fetching
- Edge cases: empty states, API failures, permission changes

### Standardize Background Modifiers
**Decision:** Replace all `.background { Shape() }` patterns with `.background(_:in:fillStyle:)` modifier.

**Rationale:**
- Project code review standards require specific background modifier signature
- More concise and consistent with SwiftUI best practices
- Example: `.background(.colorOverVideoSurface01, in: .rect(cornerRadius: 8))`

**Files to Update:**
- SelectedDeviceInfoPanel.swift
- Any other floor plan views using custom background shapes

## Alternative Approaches

### Alternative 1: Keep FloorPlanManager with Protocol Abstraction
**Rejected Reason:** Adds unnecessary abstraction layer when direct API dependency is sufficient. Over-engineering for simple API call wrapper.

### Alternative 2: Partial Mock Data Removal (Keep Toggle for Development)
**Rejected Reason:** Violates clean separation between production and test code. Development mock data should use test targets or environment-specific builds, not runtime flags.

### Alternative 3: Lower Test Coverage Target (50-60%)
**Rejected Reason:** Project standards require 80%+ coverage for critical business logic. Floor plan is a major feature warranting high test coverage.

## Dependencies
- Existing VortexRestfulApi infrastructure
- Existing DeviceManagerProtocol and MockDeviceManager
- Swift Testing framework for unit tests
- Mock data patterns from `iOSCharmanderTests/Test/`
- Dependency injection via `swift-dependencies` package

## Migration Strategy
1. Create mock API helpers in test files (enables safe refactoring)
2. Add comprehensive unit tests for both ViewModels
3. Refactor FloorPlanManager to VortexRestfulApi extension
4. Update ViewModels to use injected VortexRestfulApi dependency
5. Refactor ViewModels to use injected DeviceManager dependency
6. Update tests to use MockDeviceManager with test sites
7. Remove mock data and toggles from production code
8. Standardize background modifiers across all views
9. Run full test suite to verify no regressions (39 tests passing)

## Risks & Mitigations

### Risk: Breaking Changes During Refactoring
**Mitigation:** Add comprehensive unit tests before refactoring. Use test-driven approach to ensure behavior preservation.

### Risk: Missing Mock Data in Tests
**Mitigation:** Create proper test fixtures in Mock/ directory before removing production mock data. Verify all tests pass.

### Risk: Performance Regression
**Mitigation:** Profile before/after refactoring. Dependency injection should have negligible performance impact.

## Open Questions
None - all implementation details are well-defined by existing project patterns and review feedback.
