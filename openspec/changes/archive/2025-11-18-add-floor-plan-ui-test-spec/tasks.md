# Implementation Tasks

## 1. Specification
- [x] 1.1 Explore Floor Plan feature in iOS Simulator to understand user flows
- [x] 1.2 Document observed UI elements and interactions
- [x] 1.3 Write comprehensive UI test specification in spec.md
- [x] 1.4 Validate specification with `openspec validate add-floor-plan-ui-test-spec --strict`

## 2. Test Coverage Analysis
- [x] 2.1 Review existing FloorPlanUITest.swift implementation
- [x] 2.2 Compare existing tests with specification requirements
- [x] 2.3 Identify test coverage gaps and prioritize implementation

### 2.4 Current Test Coverage Summary

**Implemented Tests (12):**

1. **Navigation & List View**
   - ✅ testNavigateToFloorPlanTab - Verify navigation to Floor Plan tab
   - ✅ testFloorPlanListDisplay - Verify list displays with search and view mode buttons
   - ✅ testOpenFloorPlanDetail - Verify opening floor plan detail view
   - ✅ testCloseFloorPlanDetail - Verify closing floor plan detail and returning to list

2. **Camera Selection & Highlighting**
   - ✅ testSelectCameraByTappingMarker - Select camera triggers split-screen with streaming
   - ✅ testDeselectCameraByTappingMarkerAgain - Deselect by tapping selected marker
   - ✅ testDeselectCameraByTappingEmptyArea - Deselect by tapping empty floor plan area
   - ✅ testSwitchBetweenSelectedCameras - Switch between different camera selections

3. **Split-Screen & Streaming**
   - ✅ testSplitScreenLayout - Verify split-screen shows floor plan and streaming panel
   - ✅ testSplitScreenToFullScreenFloorPlan - Complete fullscreen flow:
     - Split-screen → Fullscreen streaming → Split-screen → Full floor plan
   - ✅ testStreamingPanelDisplayed - Verify streaming panel and header display
   - ✅ testCloseStreamingButton - Close streaming via header close button

**Test Infrastructure Updates:**
- ✅ FloorPlanOperation protocol cleaned up with 13 core methods
- ✅ Removed unused methods: site group operations, search operations, toggle view mode
- ✅ Added accessibility value verification helper with animation wait support
- ✅ Implemented camera marker value tracking (selected/unselected)
- ✅ Implemented streaming panel value tracking (fullscreen/splitscreen)

**Missing Test Scenarios (Future Implementation):**

1. **Site Group Interactions** (Deferred)
   - Site group expand/collapse testing deferred pending better test approach
   - Arrow button identification needs improvement
   - Will revisit with better accessibility support

2. **Search Functionality** (Not Prioritized)
   - Floor plan search by keyword
   - Device search with auto-navigation
   - Search result highlighting

3. **View Mode Toggle** (Not Prioritized)
   - Grid view mode
   - List view mode
   - View mode persistence

4. **Camera FOV Overlay** (Not Prioritized)
   - FOV sector display verification
   - Color changes based on status/selection
   - 360-degree camera FOV display

5. **Advanced Scenarios** (Not Prioritized)
   - Orientation change handling
   - Pull to refresh
   - Loading states
   - Empty states
   - Error handling

## 3. Test Implementation

### Infrastructure Implementation
- [x] 3.1 Update FloorPlanOperation protocol
  - ✅ Removed 10 unused methods
  - ✅ Kept 13 core methods for navigation, camera interaction, and streaming
  - ✅ Added `verifyElementValue` helper for accessibility value verification
  - ✅ Code reduced from ~308 lines to 188 lines

### Test Method Implementation

#### Core Navigation & Display
- [x] 3.2 testNavigateToFloorPlanTab
  - Verifies tab navigation from More menu
  - Checks navigation header and buttons

- [x] 3.3 testFloorPlanListDisplay
  - Verifies search button and view mode toggle presence

- [x] 3.4 testOpenFloorPlanDetail
  - Opens floor plan from list
  - Verifies detail view displays

- [x] 3.5 testCloseFloorPlanDetail
  - Closes detail view
  - Returns to list view

#### Camera Selection Flow
- [x] 3.6 testSelectCameraByTappingMarker
  - Taps camera marker
  - Verifies marker accessibilityValue changes to "selected"
  - Verifies split-screen appears
  - Verifies streaming panel displays

- [x] 3.7 testDeselectCameraByTappingMarkerAgain
  - Taps selected camera marker again
  - Verifies marker accessibilityValue changes to "unselected"
  - Verifies streaming panel dismisses

- [x] 3.8 testDeselectCameraByTappingEmptyArea
  - Taps floor plan at (0.95, 0.95) to avoid FOV areas
  - Verifies camera deselects
  - Verifies streaming panel dismisses

- [x] 3.9 testSwitchBetweenSelectedCameras
  - Selects camera A
  - Selects camera B
  - Verifies streaming switches to new camera

#### Split-Screen & Fullscreen
- [x] 3.10 testSplitScreenLayout
  - Verifies split-screen displays floor plan and streaming panel
  - Uses streamingPanel accessibilityValue to verify "splitscreen" mode

- [x] 3.11 testSplitScreenToFullScreenFloorPlan
  - **Step 1**: Split-screen mode (floor plan + streaming)
  - **Step 2**: Fullscreen streaming mode (streaming panel fullscreen)
  - **Step 3**: Back to split-screen
  - **Step 4**: Full floor plan (no streaming)
  - Uses streamingPanel accessibilityValue to verify "fullscreen" vs "splitscreen"

#### Streaming Controls
- [x] 3.12 testStreamingPanelDisplayed
  - Verifies streaming panel appears
  - Verifies streaming header with device name

- [x] 3.13 testCloseStreamingButton
  - Taps close button in streaming header
  - Verifies streaming panel dismisses

### Accessibility Implementation
- [x] 3.14 Add accessibility identifiers to UI components
  - ✅ CameraOverlay: `cameraMarker_{deviceSerial}` with value "selected"/"unselected"
  - ✅ SelectedDeviceInfoPanel: `streamingPanel` with value "fullscreen"/"splitscreen"
  - ✅ FloorPlanDetailView: `floorPlanDetailView` on ScrollView
  - ✅ StreamingHeader buttons: `streamingFullscreenToggle`, `streamingCloseButton`

### Test Execution
- [x] 3.15 Run tests and verify all pass
- [x] 3.16 Fix issues found during test execution
  - ✅ Fixed tapEmptyFloorPlanArea to use scrollViews instead of otherElements
  - ✅ Fixed empty area tap position to avoid FOV triangles (0.95, 0.95)
  - ✅ Fixed verifyElementValue to use XCTAssertTrue instead of XCTExpectFailure

## 4. Documentation & Validation

- [x] 4.1 Document test data requirements in spec
  - Test account with feature_floor_plan enabled
  - Test site: "Ungrouped Cameras"
  - Test floor plan: "main floor"
  - Test cameras: "0002D198B5AC-1705644338141:none", "0002D19B2074-1682069330954:none"

- [x] 4.2 Document helper methods in FloorPlanOperation
  - All public methods have clear comments
  - Private helper methods documented

- [x] 4.3 Update tasks.md with current implementation status
  - Reflects actual implemented tests
  - Documents deferred scenarios
  - Clear separation of completed vs future work

- [x] 4.4 Validate spec matches implementation
  - ✅ Added implementation status section to spec.md
  - ✅ Marked implemented vs deferred requirements
  - ✅ Updated proposal.md with accurate scope
  - ✅ Validated with `openspec validate add-floor-plan-ui-test-spec` - PASSED

## 5. Future Work

### Deferred Items
- Site group expand/collapse testing (needs better accessibility support)
- Floor plan search functionality testing
- View mode toggle testing
- FOV overlay testing
- Orientation change testing
- Pull to refresh testing
- Edge case and error handling testing

### Potential Improvements
- Add more granular camera marker state verification
- Add performance testing for large floor plans
- Add memory leak detection for streaming
- Add network condition testing
- Add iPad-specific layout testing
