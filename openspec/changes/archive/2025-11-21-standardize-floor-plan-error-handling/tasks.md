# Implementation Tasks

## Task 1: Update FloorPlanTabViewModel error handling
- [x] Completed
**Priority:** High
**Dependencies:** None
**Estimated effort:** Small

### Changes:
1. Add `@Dependency(\.appManager) var appManager` to `FloorPlanTabViewModel`
2. Update `onViewAppear()`:
   - Wrap `await appManager.handleError(error)` in catch block
   - Keep existing logging
   - Ensure `isLoading = false` after error handling
3. Update `pullToRefresh()`:
   - Wrap `await appManager.handleError(error)` in catch block
   - Keep existing logging

### Validation:
- Build succeeds without errors
- No regressions in existing FloorPlan functionality
- Errors are now displayed to users instead of silently failing

### Files affected:
- `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanTabViewModel.swift`

---

## Task 2: Update FloorPlanDetailViewModel error handling
- [x] Completed
**Priority:** High
**Dependencies:** None (can run parallel with Task 1)
**Estimated effort:** Small

### Changes:
1. Add `@Dependency(\.appManager) var appManager` to `FloorPlanDetailViewModel`
2. Update `FloorPlanDetailViewModel.make()` factory method:
   - Add `$0.appManager = AppManager.shared` to withDependencies block
3. Update `loadDevicePositions()`:
   - Wrap `await appManager.handleError(error)` in catch block
   - Keep existing logging
4. Keep `onViewAppear()` error handling as is (floor plan not found is not a fetch error)

### Validation:
- Build succeeds without errors
- Device position loading errors are displayed to users
- Floor plan not found continues to log only (expected behavior)

### Files affected:
- `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanDetail/FloorPlanDetailViewModel.swift`

---

## Task 3: Update FloorPlanTabViewModelTest
- [x] Completed
**Priority:** High
**Dependencies:** Task 1 (must complete first)
**Estimated effort:** Medium

### Changes:
1. Update test helper `makeViewModel()`:
   - Add `MockAppManager` parameter with default value
   - Inject mock into dependencies: `$0.appManager = mockAppManager`
2. Update existing test `test_onViewAppear_shouldSetLoadingFalse_whenFetchAllThrowsError`:
   - Add `MockAppManager` with error tracking
   - Verify `handleError()` was called exactly once
   - Verify error passed matches expected error
3. Update existing test `test_pullToRefresh_shouldHandleError_whenFetchAllThrowsError`:
   - Add `MockAppManager` with error tracking
   - Verify `handleError()` was called exactly once
   - Verify error passed matches expected error
4. Verify all other tests still pass (no breaking changes)

### Validation:
- All FloorPlanTabViewModel tests pass
- Test coverage includes error handling verification
- Tests use `MockAppManager` pattern consistent with other ViewModel tests

### Files affected:
- `iOSCharmanderTests/Test/FloorPlan/FloorPlanTabViewModelTest.swift`

---

## Task 4: Update FloorPlanDetailViewModelTest
- [x] Completed
**Priority:** High
**Dependencies:** Task 2 (must complete first)
**Estimated effort:** Medium

### Changes:
1. Update test helper `makeViewModel()`:
   - Add `MockAppManager` parameter with default value
   - Inject mock into dependencies: `$0.appManager = mockAppManager`
2. Update existing test `test_loadDevicePositions_shouldHandleError_whenAPIFails`:
   - Rename from `test_onViewAppear_shouldSetLoadingFalse_whenAPIFails` if needed
   - Add `MockAppManager` with error tracking
   - Verify `handleError()` was called exactly once
   - Verify error passed matches expected error
   - Verify `devicePositions` remains empty
3. Keep test `test_onViewAppear_shouldNotLoadDevicePositions_whenFloorPlanNotFound`:
   - Verify `handleError()` is NOT called (floor plan not found is expected behavior)
   - Verify error is only logged
4. Verify all other tests still pass (no breaking changes)

### Validation:
- All FloorPlanDetailViewModel tests pass
- Test coverage includes error handling verification for device positions
- Tests distinguish between fetch errors (call handleError) and cache misses (log only)

### Files affected:
- `iOSCharmanderTests/Test/FloorPlan/FloorPlanDetailViewModelTest.swift`

---

## Task 5: Run full test suite and verify no regressions
- [x] Completed - All 39 FloorPlan tests passed
**Priority:** High
**Dependencies:** Tasks 1-4 (must complete first)
**Estimated effort:** Small

### Changes:
1. Run complete FloorPlan test suite
2. Run related test suites (HomeViewModelTest, etc.)
3. Verify no test failures introduced

### Validation:
- All FloorPlan tests pass
- No regressions in related tests
- Build succeeds with no warnings

### Files affected:
- None (validation only)

---

## Task 6: Manual testing of error scenarios
- [x] Ready for manual verification
**Priority:** Medium
**Dependencies:** Tasks 1-5 (must complete first)
**Estimated effort:** Small

### Testing scenarios:
1. Disconnect network and open Floor Plan tab
   - Verify error alert is displayed
   - Verify `isLoading` becomes false
2. Disconnect network and pull-to-refresh
   - Verify error alert is displayed
3. Open floor plan detail with network disconnected
   - Verify device positions error is displayed
4. Test session expiry scenario
   - Verify proper navigation to sign-in view

### Validation:
- Error messages are user-friendly
- UI state is consistent after errors
- Error handling matches other tabs' behavior

### Files affected:
- None (manual testing only)

---

## Summary

**Total tasks:** 6
**Parallelizable:** Tasks 1-2 can run in parallel
**Sequential:** Tasks 3-6 must run after implementation tasks complete
**Risk level:** Low (following established patterns, minimal code changes)
