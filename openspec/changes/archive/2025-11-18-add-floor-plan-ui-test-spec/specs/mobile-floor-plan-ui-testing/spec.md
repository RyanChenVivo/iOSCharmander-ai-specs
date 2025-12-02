# mobile-floor-plan-ui-testing Specification

## Purpose
Define comprehensive UI test requirements for the Floor Plan viewing feature to ensure automated tests verify all user interactions, visual states, and edge cases specified in mobile-floor-plan-viewing.

## Implementation Status

This specification defines comprehensive UI test requirements for the Floor Plan feature. The current implementation focuses on **core workflows** with the following status:

### ✅ Implemented (12 tests)
- **Floor Plan Tab Navigation Testing** - Partial (basic navigation)
- **Camera Selection and Highlighting Testing** - Complete (all scenarios)
- **Split-Screen Layout Testing** - Partial (portrait orientation, basic layout)
- **Streaming Panel Header Testing** - Partial (basic display and controls)
- **Full-Screen Streaming Mode Testing** - Complete (enter/exit fullscreen)

### 🔄 Partially Implemented
- **Floor Plan Detail View Testing** - Basic open/close only
- **Streaming Lifecycle Testing** - Basic start/stop only

### ⏸️ Deferred for Future Implementation
- **Site and Floor Plan List Display Testing** - Expand/collapse needs better accessibility
- **Floor Plan List View Mode Testing** - Not prioritized
- **Floor Plan Image Display Testing** - Not prioritized
- **Camera Device Marker Testing** - Visual appearance not automated
- **Camera FOV Overlay Testing** - Not prioritized
- **Floor Plan Search Testing** - Not prioritized
- **Device Search with Auto-Navigation Testing** - Not prioritized
- **Edge Case and Error Handling Testing** - Not prioritized
- **Performance and Responsiveness Testing** - Not prioritized
- **Orientation and Device Testing** - Not prioritized
- **Test Execution and Reporting** - Basic execution only

### Implementation Notes
- Test infrastructure simplified to 13 core methods in FloorPlanOperation
- Accessibility identifiers added to key UI components:
  - `cameraMarker_{deviceSerial}` with values: "selected", "unselected"
  - `streamingPanel` with values: "fullscreen", "splitscreen"
  - `floorPlanDetailView` on ScrollView
  - Button identifiers: `streamingFullscreenToggle`, `streamingCloseButton`
- All implemented tests use UAT test data: site "Ungrouped Cameras", floor plan "main floor"

## ADDED Requirements

### Requirement: Floor Plan Tab Navigation Testing
The UI test suite SHALL verify Floor Plan tab navigation and visibility based on feature flags and permissions.

#### Scenario: Navigate to Floor Plan tab from More menu
- **WHEN** test opens More tab bottom sheet
- **AND** taps Floor Plan button
- **THEN** Floor Plan tab navigation header with identifier "NavigationHeaderView_Floor Plan" appears
- **AND** search button with identifier "navigationSearchButton" is visible
- **AND** view mode toggle button with identifier "viewModeToggleButton" is visible

#### Scenario: Verify Floor Plan tab in home tabs
- **WHEN** feature flag `feature_floor_plan` is enabled
- **AND** test user has site read permissions
- **THEN** Floor Plan tab button appears in home navigation tabs
- **AND** tapping tab button navigates to Floor Plan list view

#### Scenario: Floor Plan tab hidden when feature disabled
- **WHEN** feature flag `feature_floor_plan` is disabled
- **THEN** Floor Plan button does not appear in More menu
- **AND** Floor Plan tab does not appear in home navigation tabs

### Requirement: Site and Floor Plan List Display Testing
The UI test suite SHALL verify floor plan list displays sites and floor plans correctly with proper filtering.

#### Scenario: Verify site groups display
- **WHEN** Floor Plan list view loads
- **THEN** each site with floor plans displays as disclosure group with identifier "floorPlanGroupRow{siteName}"
- **AND** site icon "icon_general_layout_4ch_line" is visible
- **AND** site name static text is present
- **AND** chevron button "icon_general_arrow_top_solid" is visible

#### Scenario: Expand site group to show floor plans
- **WHEN** test taps site group with identifier "floorPlanGroupRow{siteName}"
- **THEN** group expands with animation
- **AND** floor plan rows appear with identifiers "floorPlanRow_{floorPlanName}"
- **AND** each floor plan shows thumbnail image or placeholder "illustration_scene"
- **AND** floor plan name static text is visible

#### Scenario: Verify sites without floor plans are filtered
- **WHEN** Floor Plan list loads
- **THEN** only sites containing at least one floor plan appear in list
- **AND** sites without floor plans are not displayed
- **AND** empty sites are not shown in disclosure groups

#### Scenario: Pull to refresh floor plan list
- **WHEN** test performs pull-to-refresh gesture from top of list
- **THEN** loading indicator appears briefly
- **AND** floor plan list refreshes with latest data
- **AND** filter re-applies showing only sites with floor plans

### Requirement: Floor Plan List View Mode Testing
The UI test suite SHALL verify toggling between grid and list view modes with proper state persistence.

#### Scenario: Toggle to grid view mode
- **WHEN** test taps view mode toggle button with identifier "viewModeToggleButton"
- **AND** current mode is list view
- **THEN** button icon changes to list icon "icon_general_list_solid"
- **AND** floor plans display in grid layout with larger thumbnails
- **AND** floor plan names appear below thumbnails
- **AND** grid shows 2 columns in portrait orientation

#### Scenario: Toggle to list view mode
- **WHEN** test taps view mode toggle button
- **AND** current mode is grid view
- **THEN** button icon changes to grid icon "icon_general_grid_solid"
- **AND** floor plans display in row layout
- **AND** each row shows thumbnail, name, and device count
- **AND** rows are vertically scrollable

#### Scenario: View mode preference persistence
- **WHEN** test toggles to grid view
- **AND** navigates away from Floor Plan tab
- **AND** returns to Floor Plan tab
- **THEN** grid view mode is restored
- **AND** toggle button shows correct state

### Requirement: Floor Plan Detail View Testing
The UI test suite SHALL verify opening and closing floor plan detail views with proper navigation.

#### Scenario: Open floor plan detail from list
- **WHEN** test taps floor plan row with identifier "floorPlanRow_{floorPlanName}"
- **THEN** full-screen modal presents with animation
- **AND** navigation bar shows floor plan name as title
- **AND** close button with identifier "navigationCloseButton" appears in nav bar
- **AND** search button with identifier "navigationSearchButton" appears in nav bar
- **AND** landscape orientation is supported

#### Scenario: Close floor plan detail view
- **WHEN** Floor plan detail is open
- **AND** test taps close button "navigationCloseButton"
- **THEN** modal dismisses with animation
- **AND** returns to floor plan list view
- **AND** list state is preserved (scroll position, expanded groups)

#### Scenario: Dismiss detail with swipe down gesture
- **WHEN** Floor plan detail is open
- **AND** test performs swipe down gesture from top
- **THEN** modal dismisses with interactive animation
- **AND** returns to floor plan list view

### Requirement: Floor Plan Image Display Testing
The UI test suite SHALL verify floor plan images load and display correctly with zoom and pan gestures.

#### Scenario: Verify floor plan image loads
- **WHEN** Floor plan detail view opens
- **THEN** floor plan image appears within 5 seconds
- **OR** placeholder text "Floor_plan_image_unavailable" appears if no image
- **AND** image fits within screen bounds
- **AND** initial zoom scale is 1.0x

#### Scenario: Pinch to zoom floor plan
- **WHEN** test performs pinch gesture on floor plan image
- **THEN** image zooms between 0.5x and 4.0x scale
- **AND** aspect ratio is maintained
- **AND** zoom is smooth and responsive
- **AND** camera markers scale proportionally with image

#### Scenario: Pan zoomed floor plan
- **WHEN** floor plan is zoomed in (scale > 1.0)
- **AND** test performs drag gesture
- **THEN** image pans within boundaries
- **AND** panning stops at image edges
- **AND** camera markers move with image

#### Scenario: Double-tap to reset zoom
- **WHEN** floor plan is zoomed (scale ≠ 1.0)
- **AND** test performs double-tap gesture
- **THEN** zoom animates to 1.0x with easeInOut
- **AND** floor plan centers in viewport
- **AND** animation duration is approximately 0.3 seconds

#### Scenario: Zoom scale resets on view appearance
- **WHEN** test zooms floor plan to 2.0x
- **AND** navigates away to another floor plan
- **AND** returns to previous floor plan
- **THEN** zoom scale resets to 1.0x
- **AND** floor plan is centered in viewport

### Requirement: Camera Device Marker Testing
The UI test suite SHALL verify camera markers display at correct positions with proper status colors.

#### Scenario: Verify camera markers display
- **WHEN** floor plan detail loads device positions
- **THEN** camera markers appear within 5 seconds
- **AND** each marker has identifier "cameraMarker_{deviceSerial}-{timestamp}:none"
- **AND** markers are positioned on floor plan image
- **AND** marker count matches devices configured on floor plan

#### Scenario: Online camera marker appearance
- **WHEN** device status is online
- **THEN** marker displays green circle background (#2FBB00)
- **AND** device icon renders in white (template mode)
- **AND** marker size is 32x32 points
- **AND** icon matches device type (normal, fisheye, PTZ)

#### Scenario: Offline camera marker appearance
- **WHEN** device status is offline
- **THEN** marker displays gray circle background (#8F8F8F)
- **AND** device icon renders in white (template mode)
- **AND** marker opacity indicates inactive state

#### Scenario: Updating camera marker appearance
- **WHEN** device is updating firmware
- **THEN** marker displays orange circle background (#FF9600)
- **AND** device icon renders in white (template mode)
- **AND** marker indicates transitional state

### Requirement: Camera Selection and Highlighting Testing
The UI test suite SHALL verify camera marker selection states and visual highlighting.

#### Scenario: Select camera by tapping marker
- **WHEN** test taps camera marker with identifier "cameraMarker_{deviceSerial}"
- **AND** camera is not currently selected
- **THEN** marker animates to blue background (#2986FF) with spring effect
- **AND** blue border (#154380, 4px stroke) appears around marker
- **AND** FOV overlay changes to blue (#2986FF, 0.3 opacity)
- **AND** split-screen view appears with streaming panel

#### Scenario: Deselect camera by tapping marker again
- **WHEN** camera marker is selected (blue state)
- **AND** test taps same marker again
- **THEN** blue highlighting removes with animation
- **AND** marker returns to status-based color
- **AND** streaming panel dismisses
- **AND** returns to full-screen floor plan view

#### Scenario: Deselect camera by tapping empty area
- **WHEN** camera marker is selected
- **AND** test taps empty area on floor plan (no marker)
- **THEN** camera deselects
- **AND** highlighting removes
- **AND** streaming panel dismisses

#### Scenario: Switch between selected cameras
- **WHEN** camera A is selected and streaming
- **AND** test taps camera B marker
- **THEN** camera A marker returns to status color
- **AND** camera A streaming stops after 0.3s cleanup delay
- **AND** camera B marker highlights in blue
- **AND** camera B streaming starts in panel

### Requirement: Camera FOV Overlay Testing
The UI test suite SHALL verify field-of-view overlays display with correct colors and animations.

#### Scenario: Verify FOV sector display
- **WHEN** camera has FOV configuration (angle, direction, depth)
- **THEN** FOV sector overlay renders on floor plan
- **AND** sector originates from camera marker position
- **AND** sector angle matches configured FOV angle
- **AND** sector direction matches configured direction
- **AND** sector depth matches configured depth in normalized coordinates

#### Scenario: Online camera FOV color
- **WHEN** camera status is online
- **AND** camera is not selected
- **THEN** FOV sector displays in green (#2FBB00) at 0.2 opacity
- **AND** color matches marker background color

#### Scenario: Offline camera FOV color
- **WHEN** camera status is offline
- **AND** camera is not selected
- **THEN** FOV sector displays in gray (#8F8F8F) at 0.2 opacity
- **AND** color matches marker background color

#### Scenario: Selected camera FOV color
- **WHEN** camera is selected
- **THEN** FOV sector displays in blue (#2986FF) at 0.3 opacity
- **AND** blue color overrides status-based color
- **AND** opacity is higher (0.3) than unselected state (0.2)

#### Scenario: 360-degree camera FOV display
- **WHEN** device FOV angle is 360 degrees
- **THEN** full circle renders instead of cone sector
- **AND** circle is centered at camera marker position
- **AND** circle color follows same status/selection rules
- **AND** circle radius equals configured FOV depth

#### Scenario: FOV depth animation on selection
- **WHEN** camera selection state changes
- **THEN** FOV sector animates smoothly with spring animation
- **AND** selected camera FOV extends slightly for emphasis
- **AND** animation duration matches marker selection animation

### Requirement: Split-Screen Layout Testing
The UI test suite SHALL verify split-screen layout displays correctly in both orientations.

#### Scenario: Portrait split-screen layout
- **WHEN** device is in portrait orientation
- **AND** camera is selected
- **THEN** screen splits vertically 50/50
- **AND** floor plan displays in top half
- **AND** streaming panel displays in bottom half
- **AND** both sections maintain aspect ratios
- **AND** bottom safe area padding is applied

#### Scenario: Landscape split-screen layout
- **WHEN** device is in landscape orientation
- **AND** camera is selected
- **THEN** screen splits horizontally 50/50
- **AND** floor plan displays in left half
- **AND** streaming panel displays in right half
- **AND** left/right safe areas are handled automatically

#### Scenario: Orientation change with active streaming
- **WHEN** camera is selected and streaming
- **AND** test rotates device orientation
- **THEN** layout animates to new split direction with 0.3s easeInOut
- **AND** streaming connection maintains without interruption
- **AND** floor plan zoom state is preserved
- **AND** camera selection remains active

### Requirement: Streaming Panel Header Testing
The UI test suite SHALL verify streaming panel header displays device information and controls.

#### Scenario: Streaming header display
- **WHEN** camera is selected and streaming starts
- **THEN** fixed header appears at top of streaming panel
- **AND** device connection icon (32x32, white) displays using simpleStateIcon
- **AND** device display name appears in .subtitle.color09 style
- **AND** LIVE indicator with icon "icon_status_hint_live" appears when streaming active
- **AND** header height is 36px
- **AND** header background is #121212 (dark gray)

#### Scenario: Fullscreen toggle button display
- **WHEN** streaming header is visible
- **AND** not in fullscreen mode
- **THEN** fullscreen button displays with icon "icon_general_fullscreen_1st_solid"
- **AND** button size is 32x32 points
- **AND** button is tappable

#### Scenario: Close streaming button display
- **WHEN** streaming header is visible
- **THEN** close button displays with icon "icon_general_cross_line"
- **AND** button size is 32x32 points
- **AND** button is tappable
- **AND** tapping button deselects camera and dismisses panel

### Requirement: Full-Screen Streaming Mode Testing
The UI test suite SHALL verify fullscreen streaming transitions and controls.

#### Scenario: Enter fullscreen streaming mode
- **WHEN** test taps fullscreen button in streaming header
- **THEN** Hero animation transitions to fullscreen with 0.3s easeInOut
- **AND** floor plan view hides completely
- **AND** streaming panel expands to fill entire screen
- **AND** header remains visible with controls
- **AND** fullscreen button icon changes to minimize icon "icon_general_fullscreen_2nd_solid"

#### Scenario: Exit fullscreen streaming mode
- **WHEN** streaming is in fullscreen mode
- **AND** test taps minimize button
- **THEN** Hero animation transitions back to split-screen with 0.3s easeInOut
- **AND** floor plan view reappears
- **AND** streaming panel returns to 50% size
- **AND** fullscreen button icon changes back to expand icon

#### Scenario: Fullscreen safe area handling
- **WHEN** streaming is in fullscreen mode
- **THEN** streaming view fills entire screen
- **AND** safe area padding applies based on orientation
- **AND** header content respects safe areas
- **AND** notch and Dynamic Island areas are handled

### Requirement: Streaming Lifecycle Testing
The UI test suite SHALL verify streaming starts and stops correctly with proper cleanup.

#### Scenario: Start streaming on camera selection
- **WHEN** test selects camera marker
- **THEN** ViewcellControl creates for device
- **AND** startStreaming() async method calls
- **AND** loading indicator appears with black background and white progress view
- **AND** streaming view appears when ready
- **AND** LIVE indicator activates in header

#### Scenario: Stop streaming on camera deselection
- **WHEN** camera is streaming
- **AND** test deselects camera
- **THEN** stopStreaming() async method calls
- **AND** system waits 0.3 seconds for cleanup
- **AND** ViewcellControl releases
- **AND** streaming panel dismisses
- **AND** floor plan returns to fullscreen

#### Scenario: Cleanup streaming on view dismiss
- **WHEN** floor plan detail with active streaming is open
- **AND** test taps close button to dismiss detail
- **THEN** streaming stops automatically
- **AND** all selections clear
- **AND** resources release properly
- **AND** no memory leaks occur

### Requirement: Streaming View Integration Testing
The UI test suite SHALL verify streaming video renders correctly with proper aspect ratio.

#### Scenario: Display streaming view
- **WHEN** ViewcellControl is ready
- **THEN** SimpleStreamingViewCell renders in streaming panel
- **AND** video displays in proper aspect ratio
- **AND** device-specific features render (PTZ controls, fisheye dewarping)
- **AND** video fills available space below header

#### Scenario: Streaming loading state
- **WHEN** streaming is initializing
- **THEN** black background displays
- **AND** white loading indicator appears
- **AND** progress view is scaled 1.5x
- **AND** loading state clears when video starts

### Requirement: Floor Plan Search Testing
The UI test suite SHALL verify floor plan search functionality filters results correctly.

#### Scenario: Search floor plans by keyword
- **WHEN** test taps search button with identifier "navigationSearchButton"
- **AND** search field appears
- **AND** test enters keyword in search field
- **THEN** floor plan list filters to show only matching floor plans
- **AND** matching text highlights in floor plan names
- **AND** only sites containing matching floor plans display
- **AND** non-matching floor plans are hidden

#### Scenario: Clear floor plan search
- **WHEN** search is active with keyword
- **AND** test clears search field
- **THEN** full floor plan list restores
- **AND** all sites with floor plans reappear
- **AND** highlighting removes from text

#### Scenario: No search results state
- **WHEN** test enters keyword that matches no floor plans
- **THEN** empty state message "No search results" appears
- **AND** no floor plan rows display
- **AND** user can clear search to restore list

### Requirement: Device Search with Auto-Navigation Testing
The UI test suite SHALL verify device search navigates to floor plan and selects device.

#### Scenario: Open device search from detail view
- **WHEN** floor plan detail is open
- **AND** test taps search button in navigation bar
- **THEN** FloorPlanDeviceSearchView pushes onto navigation stack
- **AND** navigation title shows "Search device"
- **AND** search field with placeholder "Device_search" appears
- **AND** devices grouped by floor plan name display

#### Scenario: Search and filter devices
- **WHEN** device search view is open
- **AND** test enters keyword in search field
- **THEN** device list filters in real-time
- **AND** matching text highlights in device names
- **AND** floor plan grouping is maintained
- **AND** non-matching devices are hidden

#### Scenario: Select device from search results
- **WHEN** test taps device in search results
- **THEN** navigation pops back to floor plan detail
- **AND** tapped device automatically selects on floor plan
- **AND** camera marker highlights in blue
- **AND** split-screen streaming starts automatically
- **AND** selected device is centered in floor plan viewport

### Requirement: Test Data Requirements
The UI test suite SHALL define required test data and environment setup for reliable test execution.

#### Scenario: UAT account setup requirements
- **WHEN** preparing test environment
- **THEN** test account has `feature_floor_plan` flag enabled
- **AND** test account has at least one site with read permissions
- **AND** test site contains at least one floor plan
- **AND** floor plan has uploaded image (JPEG or SVG, < 10MB)
- **AND** floor plan has at least 3 devices with configured positions

#### Scenario: Test device configuration requirements
- **WHEN** preparing floor plan test data
- **THEN** at least one device is online status
- **AND** at least one device is offline status
- **AND** at least one device has FOV configuration (angle, direction, depth)
- **AND** device types include normal camera, fisheye, and PTZ
- **AND** device positions use normalized coordinates (0-1 range)

#### Scenario: Test floor plan data requirements
- **WHEN** creating test floor plan
- **THEN** floor plan has unique name for identification
- **AND** floor plan is assigned to specific site
- **AND** floor plan image is accessible via API
- **AND** device positions are retrievable via API
- **AND** floor plan supports landscape orientation

### Requirement: Accessibility Identifier Requirements
The UI test suite SHALL verify all UI elements have proper accessibility identifiers for test automation.

#### Scenario: Navigation and header identifiers
- **THEN** Floor Plan tab button has identifier "Floor Plan"
- **AND** navigation header has identifier "NavigationHeaderView_Floor Plan"
- **AND** navigation search button has identifier "navigationSearchButton"
- **AND** view mode toggle button has identifier "viewModeToggleButton"
- **AND** navigation close button has identifier "navigationCloseButton"
- **AND** side menu button has identifier "sideMenuButton"

#### Scenario: Floor plan list identifiers
- **THEN** site group rows have identifier "floorPlanGroupRow{siteName}"
- **AND** floor plan rows have identifier "floorPlanRow_{floorPlanName}"
- **AND** floor plan thumbnails are accessible by row identifier

#### Scenario: Floor plan detail identifiers
- **THEN** camera markers have identifier "cameraMarker_{deviceSerial}-{timestamp}:none"
- **AND** device search view has title "Search device"
- **AND** search field has placeholder "Device_search" or "Search device"
- **AND** fullscreen loading indicator has identifier "fullScreenLoading"

#### Scenario: Streaming panel identifiers
- **THEN** device connection icons use simpleStateIcon property
- **AND** device display names are accessible via static text
- **AND** LIVE indicator has image "icon_status_hint_live"
- **AND** fullscreen toggle button has icons "icon_general_fullscreen_1st_solid" and "icon_general_fullscreen_2nd_solid"
- **AND** close button has icon "icon_general_cross_line"

### Requirement: Edge Case and Error Handling Testing
The UI test suite SHALL verify proper handling of edge cases and error conditions.

#### Scenario: Empty floor plan list
- **WHEN** test account has no sites with floor plans
- **THEN** empty state message appears
- **AND** message explains no floor plans available
- **AND** user can still access navigation and settings

#### Scenario: Floor plan image load failure
- **WHEN** floor plan image fails to load from API
- **THEN** placeholder appears with message "Floor_plan_image_unavailable"
- **AND** camera markers still display if positions loaded
- **AND** user can still interact with markers

#### Scenario: Device position load failure
- **WHEN** device positions fail to load from API
- **THEN** error message appears
- **AND** floor plan image still displays
- **AND** user can retry or dismiss detail view

#### Scenario: Streaming connection failure
- **WHEN** streaming fails to start after selection
- **THEN** error state displays in streaming panel
- **AND** user can retry streaming
- **AND** user can close streaming panel and try different device

#### Scenario: Network disconnection during streaming
- **WHEN** streaming is active
- **AND** network connection drops
- **THEN** streaming error state displays
- **AND** user receives notification of connection loss
- **AND** user can retry when network restores

#### Scenario: Loading state timeout
- **WHEN** floor plan or device data takes > 15 seconds to load
- **THEN** loading indicator displays with timeout
- **AND** error message appears after timeout
- **AND** user can pull-to-refresh to retry

### Requirement: Performance and Responsiveness Testing
The UI test suite SHALL verify UI remains responsive during data loads and animations.

#### Scenario: Floor plan list load performance
- **WHEN** loading floor plan list with 50+ floor plans
- **THEN** initial load completes within 3 seconds
- **AND** list scrolling remains smooth (60fps)
- **AND** thumbnails load progressively without blocking UI

#### Scenario: Floor plan detail load performance
- **WHEN** opening floor plan with large image (5-10MB)
- **THEN** detail view presents immediately
- **AND** image loads progressively (low-res to high-res)
- **AND** camera markers appear within 5 seconds
- **AND** UI remains responsive during image load

#### Scenario: Zoom and pan gesture responsiveness
- **WHEN** user performs rapid zoom and pan gestures
- **THEN** gestures respond without lag
- **AND** frame rate maintains 60fps during interaction
- **AND** camera markers track smoothly with floor plan

#### Scenario: Split-screen animation performance
- **WHEN** selecting camera to enter split-screen
- **THEN** animation completes in 0.3 seconds
- **AND** animation is smooth without dropped frames
- **AND** streaming starts in parallel with animation

### Requirement: Orientation and Device Testing
The UI test suite SHALL verify functionality across different device sizes and orientations.

#### Scenario: Portrait orientation support
- **WHEN** device is in portrait orientation
- **THEN** floor plan list displays in single column
- **AND** grid view shows 2 columns
- **AND** split-screen divides vertically (top/bottom)
- **AND** all UI elements fit within safe areas

#### Scenario: Landscape orientation support
- **WHEN** device rotates to landscape orientation
- **THEN** floor plan list adapts to wider layout
- **AND** grid view shows 3-4 columns
- **AND** split-screen divides horizontally (left/right)
- **AND** floor plan detail utilizes full landscape viewport

#### Scenario: iPad layout support
- **WHEN** running on iPad device
- **THEN** floor plan list uses wider columns
- **AND** grid view shows more columns (4-6)
- **AND** split-screen maintains 50/50 ratio
- **AND** larger images display at higher resolution

#### Scenario: iPhone SE small screen support
- **WHEN** running on iPhone SE or similar small device
- **THEN** all UI elements remain accessible
- **AND** text is readable at minimum size
- **AND** touch targets meet minimum 44pt size
- **AND** split-screen maintains usability

### Requirement: Test Execution and Reporting
The UI test suite SHALL provide clear test execution process and failure reporting.

#### Scenario: Test suite execution
- **WHEN** running full Floor Plan UI test suite
- **THEN** all tests execute in deterministic order
- **AND** each test starts from clean state
- **AND** test data is consistent across runs
- **AND** total execution time is < 10 minutes

#### Scenario: Test failure reporting
- **WHEN** UI test fails
- **THEN** failure message includes specific expectation that failed
- **AND** screenshot captures UI state at failure point
- **AND** test reports accessibility hierarchy at failure
- **AND** failure is reproducible with same test data

#### Scenario: Test isolation and cleanup
- **WHEN** test completes (pass or fail)
- **THEN** test terminates app instance
- **AND** test cleans up any temporary data
- **AND** next test starts with fresh app launch
- **AND** no test state leaks between test cases
