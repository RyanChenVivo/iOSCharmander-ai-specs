# Standardize Floor Plan Error Handling

## Problem Statement

Currently, the FloorPlan feature has inconsistent error handling across its ViewModels and Manager layer. When data fetching fails in critical user-facing operations, errors are only logged instead of being presented to users through the app's standard error UI patterns.

**Current Issues:**
1. `FloorPlanTabViewModel.onViewAppear()` - Catches and logs errors but doesn't notify users
2. `FloorPlanTabViewModel.pullToRefresh()` - Catches and logs errors but doesn't notify users
3. `FloorPlanDetailViewModel.onViewAppear()` - Logs errors when floor plan not found
4. `FloorPlanDetailViewModel.loadDevicePositions()` - Catches and logs errors but doesn't notify users

This creates a poor user experience where:
- Users see loading indicators that complete without data
- No visual feedback when operations fail
- Users cannot distinguish between "no data" vs "error fetching data"
- Inconsistent with error handling patterns used elsewhere in the app (e.g., ArchiveTab, MessageTab)

## Proposed Solution

Standardize error handling by using `AppManager.handleError(_:)` for all data-fetching operations that impact the UI. This aligns with the established architecture pattern where AppManager serves as the centralized error handler dependency.

**Key Changes:**
1. Inject `AppManagerProtocol` dependency into FloorPlan ViewModels
2. Replace error logging with `appManager.handleError(error)` calls for user-facing errors
3. Keep logging for non-critical errors (e.g., floor plan not found in cache)
4. Update tests to verify `handleError` is called appropriately

**Benefits:**
- Consistent error presentation across the app
- Users receive actionable feedback (alerts, navigation to appropriate views)
- Handles session expiry, access denied, and other standard errors uniformly
- Maintains separation of concerns (ViewModels handle business logic, AppManager handles error UI)

## Scope

**In Scope:**
- Add `@Dependency(\.appManager)` to `FloorPlanTabViewModel` and `FloorPlanDetailViewModel`
- Update error handling in:
  - `FloorPlanTabViewModel.onViewAppear()`
  - `FloorPlanTabViewModel.pullToRefresh()`
  - `FloorPlanDetailViewModel.loadDevicePositions()`
- Update unit tests to verify `handleError` calls
- Keep `FloorPlanManager` unchanged (it's a data layer, not UI layer)

**Out of Scope:**
- Changing `FloorPlanManager` error handling (it correctly throws errors up)
- Adding new error types
- UI/UX changes to error presentation (uses existing AppManager patterns)
- Error handling for streaming or device selection (separate concerns)

## Impact Analysis

**User Impact:**
- Positive: Users will see proper error messages instead of silent failures
- No breaking changes to existing functionality

**Developer Impact:**
- Minimal: Following existing patterns used throughout the codebase
- Test updates required to mock `AppManager` dependency

**Technical Dependencies:**
- `AppManager` / `AppManagerProtocol` (already exists)
- Dependency injection framework (already in use)
- No API changes required

## Success Criteria

1. All data-fetching errors in FloorPlan ViewModels are handled via `appManager.handleError()`
2. Unit tests verify that `handleError` is called with the correct error
3. No regressions in existing FloorPlan functionality
4. Error handling is consistent with other tabs (Archive, Message, etc.)

## Related Specifications

- `mobile-floor-plan-viewing` - Requirement: Floor Plan Data Management (Scenario: Handle API failure gracefully)
- `mobile-floor-plan-code-quality` - Code quality standards for error handling
