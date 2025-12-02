# Implementation Tasks - Mobile Floor Plan Viewing

All tasks have been completed and deployed. This document serves as implementation reference.

## 1. Floor Plan Tab Navigation ✅

- [x] Add `.floorPlan` case to `HomeViewTab` enum
- [x] Add floor plan tab to `supportedHomeViewTabs()` in FeatureProvider
- [x] Implement visibility based on site permissions, remote config, and license
- [x] Add tab icon and localization strings
- [x] Configure tab in default tabs arrays

**Implementation**: `HomeViewTab.swift`, `FeatureToggle.swift`

## 2. Site and Floor Plan List ✅

- [x] Create `FloorPlanTabView.swift` with site hierarchy layout
- [x] Implement expandable disclosure groups for sites
- [x] Display floor plan count per site
- [x] Add pull-to-refresh functionality
- [x] Handle empty state ("No floor plans available")
- [x] Implement alphabetical site sorting

**Implementation**: `FloorPlanTabView.swift`, `FloorPlanSiteList.swift`, `FloorPlanSiteView.swift`

## 3. Floor Plan List View Modes ✅

- [x] Implement grid/list toggle button in navigation bar
- [x] Create grid layout (2 columns portrait, 3-4 landscape)
- [x] Create list layout with thumbnails, names, device count
- [x] Persist view mode preference with `@MyAppStorage`
- [x] Restore last used view mode on tab reappear

**Implementation**: `FloorPlanTabView.swift`, `FloorPlanRow.swift`

## 4. Floor Plan Detail Presentation ✅

- [x] Add `openFloorPlanDetail(floorPlan:)` to SheetManager
- [x] Present FloorPlanDetailView as full-screen modal
- [x] Support landscape orientation with `supportOrientation: true`
- [x] Implement swipe-down to dismiss
- [x] Add navigation title with floor plan name

**Implementation**: `SheetManager.swift`, `FloorPlanDetailView.swift`

## 5. Floor Plan Image Display ✅

- [x] Display floor plan image (JPEG/SVG, up to 10MB)
- [x] Implement pinch-to-zoom gesture (0.5x to 4.0x range)
- [x] Apply cumulative zoom scaling
- [x] Implement drag-to-pan gesture with boundary constraints
- [x] Add double-tap to reset zoom (1.0x with animation)
- [x] Reset zoom scale on each view appearance
- [x] Use GeometryReader for responsive layout

**Implementation**: `FloorPlanDetailView.swift:95-150`

## 6. Camera Device Visualization ✅

- [x] Display camera markers at normalized coordinates (0-1)
- [x] Render markers with status-based colors (#2FBB00 green, #8F8F8F gray, #FF9600 orange)
- [x] Use white device type icons with template rendering (32x32)
- [x] Show selected state with blue background (#2986FF) and border (#154380, 4px)
- [x] Implement spring animation for selection state changes
- [x] Create `CameraOverlay.swift` component

**Implementation**: `CameraOverlay.swift`, `FloorPlanDetailView.swift:200-250`

## 7. Camera Field of View Overlay ✅

- [x] Render FOV sectors with angle, direction, depth parameters
- [x] Implement status-based colors (green/gray/orange at 0.2 opacity)
- [x] Apply blue color (#2986FF, 0.3 opacity) when selected
- [x] Handle 360-degree cameras with full circle rendering
- [x] Animate FOV depth changes with spring effect
- [x] Create FOV visualization in CameraOverlay

**Implementation**: `CameraOverlay.swift:50-120`

## 8. Camera Device Selection with Split-Screen ✅

- [x] Implement single-tap selection on camera markers
- [x] Toggle selection by tapping marker again
- [x] Deselect by tapping empty area on floor plan
- [x] Switch selected camera with cleanup delay (0.3s)
- [x] Split view 50/50 (portrait: vertical, landscape: horizontal)
- [x] Show blue outline and border on selected marker

**Implementation**: `FloorPlanDetailView.swift:180-210`, `FloorPlanDetailViewModel.swift:150-200`

## 9. Split-Screen Layout with Streaming ✅

- [x] Implement portrait layout (floor plan top 50%, streaming bottom 50%)
- [x] Implement landscape layout (floor plan left 50%, streaming right 50%)
- [x] Animate orientation changes with 0.3s easeInOut
- [x] Maintain streaming connection during orientation change
- [x] Use GeometryReader for adaptive layout

**Implementation**: `FloorPlanDetailView.swift:55-95`

## 10. Streaming Panel with Fixed Header ✅

- [x] Create `FloorPlanStreamingHeader.swift` component
- [x] Display device connection icon (white, 32x32) using `simpleStateIcon`
- [x] Show device display name (.subtitle.color09)
- [x] Add LIVE indicator (conditional on device.online)
- [x] Set header height to 36px with #121212 background
- [x] Add fullscreen toggle button (32x32 icon)
- [x] Add close button (X icon, 32x32)
- [x] Ensure panel fills allocated space without padding/borders

**Implementation**: `FloorPlanStreamingHeader.swift`, `SelectedDeviceInfoPanel.swift`

## 11. Full-Screen Streaming Mode ✅

- [x] Implement fullscreen toggle in streaming header
- [x] Transition to fullscreen with Hero animation (0.3s easeInOut)
- [x] Hide floor plan view when fullscreen
- [x] Expand streaming panel to fill entire screen
- [x] Maintain header visibility with controls
- [x] Transition back to split-screen with Hero animation

**Implementation**: `FloorPlanDetailView.swift:130-170`, `FloorPlanDetailViewModel.swift:220-240`

## 12. Streaming Lifecycle Management ✅

- [x] Create ViewcellControl on camera selection
- [x] Call `startStreaming()` async method
- [x] Wait for streaming status ready
- [x] Call `stopStreaming()` on deselection
- [x] Add 0.3s cleanup delay before releasing ViewcellControl
- [x] Stop streaming and clear selections on view dismiss

**Implementation**: `FloorPlanDetailViewModel.swift:180-250`

## 13. Streaming View Integration ✅

- [x] Integrate SimpleStreamingViewCell component
- [x] Pass ViewcellControl as environment object
- [x] Support proper aspect ratio rendering
- [x] Handle device-specific features (PTZ, fisheye)
- [x] Display loading state with black background and white progress indicator (1.5x scale)

**Implementation**: `SelectedDeviceInfoPanel.swift:40-80`

## 14. Hero Animation for Fullscreen Transition ✅

- [x] Apply `matchedGeometryEffect` to streaming view
- [x] Use "streamingContent" as effect ID
- [x] Share namespace between split and fullscreen states
- [x] Ensure smooth automatic transitions

**Implementation**: `FloorPlanDetailView.swift:140-160`, `SelectedDeviceInfoPanel.swift:50`

## 15. Connection Status Icons ✅

- [x] Add `simpleStateIcon` property to DeviceItem
- [x] Return device-type specific icons (normal, fisheye, PTZ, NVR)
- [x] Provide online vs offline variants
- [x] Implement template rendering with white foreground
- [x] Use 32x32 in streaming header, 20x20 in camera markers
- [x] Add `normalIcon` and `disconnectIcon` to CameraType

**Implementation**: `DeviceItem+Extension.swift:40-80`

## 16. Floor Plan Search ✅

- [x] Add search bar to floor plan list
- [x] Filter floor plans by name keyword
- [x] Highlight matching text in results
- [x] Show only sites containing matching floor plans
- [x] Clear search restores full list

**Implementation**: `FloorPlanTabView.swift:80-100`, `FloorPlanSiteSearchingView.swift`

## 17. Device Search with Auto-Navigation ✅

- [x] Create `FloorPlanDeviceSearchView.swift`
- [x] Add search icon to floor plan detail navigation bar
- [x] Display searchable list of devices on floor plan
- [x] Group devices by site
- [x] Filter devices by display name in real-time
- [x] Auto-select device on tap and return to floor plan
- [x] Start streaming in split-screen mode

**Implementation**: `FloorPlanDeviceSearchView.swift`, `FloorPlanDetailView.swift:35`

## 18. Floor Plan Data Management ✅

- [x] Create `FloorPlanManager.swift` singleton
- [x] Add `@Published var floorPlans` and `devicePositions` properties
- [x] Implement `fetchAll()` for all sites
- [x] Lazy load device positions on floor plan detail open
- [x] Cache floor plans and positions in memory
- [x] Handle API failures with error logging and retry support
- [x] Add loading indicators during fetch

**Implementation**: `FloorPlanManager.swift`, API integration in VortexAPI

## 19. Feature Toggle Control ✅

- [x] Add `feature_floor_plan` remote config key
- [x] Implement visibility logic in `supportedHomeViewTabs()`
- [x] Check user site read permissions
- [x] Verify license is not in renewal overdue state
- [x] Add `.floorPlan` to `tabCanDisable()`
- [x] Hide tab when feature flag is disabled

**Implementation**: `FeatureToggle.swift:417-535`

## 20. Platform Orientation Support ✅

- [x] Support portrait and landscape orientations
- [x] Adjust floor plan list layout for orientation
- [x] Scale floor plan image for landscape viewport
- [x] Reposition camera markers for landscape dimensions
- [x] Configure SheetManager with `supportOrientation: true`
- [x] Use OrientationControl.shared for orientation detection

**Implementation**: `FloorPlanDetailView.swift`, `SheetManager.swift`

## 21. Safe Area Handling for Split-Screen ✅

- [x] Apply bottom safe area padding in portrait orientation
- [x] Rely on automatic safe area handling in landscape
- [x] Avoid manual left/right padding to prevent double padding
- [x] Respect notch and Dynamic Island areas
- [x] Apply same rules for fullscreen streaming mode
- [x] Use vortexDefaultLayout for consistent behavior

**Implementation**: `FloorPlanDetailView.swift:60-75`

## Color Scheme Implementation ✅

- [x] Create `color-floorplan-icon01` (#2FBB00) - Online/Green
- [x] Create `color-floorplan-icon02` (#FF9600) - Updating/Orange
- [x] Create `color-floorplan-icon03` (#8F8F8F) - Offline/Gray
- [x] Create `color-floorplan-icon04` (#2986FF) - Selected/Blue
- [x] Create `color-floorplan-icon05` (#154380) - Selected Border/Dark Blue
- [x] Apply colors to markers and FOV overlays consistently

**Implementation**: `Assets.xcassets/Color/FloorPlan/`, `FloorPlanDetailViewModel.swift`

## REMOVED Requirements (Not Implemented)

The following features were NOT implemented in the current version:

- ~~Camera Information Panel~~ - Replaced by inline streaming header
- ~~Long-Press Gesture for Streaming~~ - Single tap used instead
- ~~Nested Modal for Streaming~~ - Split-screen design used instead
- ~~Offline Behavior with Timestamps~~ - Not implemented (future consideration)

## Testing & Validation ✅

- [x] Test floor plan tab visibility with feature toggles
- [x] Verify split-screen layouts in portrait and landscape
- [x] Test zoom/pan gestures with various floor plan sizes
- [x] Validate camera marker positioning accuracy
- [x] Test FOV rendering for different camera types
- [x] Verify streaming lifecycle (start/stop/cleanup)
- [x] Test orientation changes during active streaming
- [x] Validate device search and auto-selection
- [x] Test safe area handling on different device models
- [x] Verify color scheme consistency across all states

---

**Status**: ✅ All requirements implemented and deployed
**Last Updated**: 2025-11-07
**OpenSpec Change**: add-mobile-floor-plan-viewing
