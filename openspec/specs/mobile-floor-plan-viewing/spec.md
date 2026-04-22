# mobile-floor-plan-viewing Specification

## Purpose
TBD - created by archiving change add-mobile-floor-plan-viewing. Update Purpose after archive.
## Requirements
### Requirement: Floor Plan Tab Navigation
The iOS app SHALL provide a dedicated Floor Plan tab in the home view navigation that allows users to access floor plan viewing functionality.

#### Scenario: Floor Plan tab is visible
- **WHEN** user has at least one site with read permission
- **AND** remote config flag `feature_floor_plan` is enabled
- **AND** license is not in renewal overdue state
- **THEN** Floor Plan tab appears in home navigation

#### Scenario: Floor Plan tab is hidden
- **WHEN** user has no sites with read permission
- **OR** remote config flag `feature_floor_plan` is disabled
- **OR** license is in renewal overdue state
- **THEN** Floor Plan tab does not appear in home navigation

### Requirement: Site and Floor Plan List
The system SHALL display an expandable hierarchical list of sites with their associated floor plans, filtering out sites without floor plans. The navigation title SHALL use the `Floorplans` localization key.

#### Scenario: Display only sites with floor plans
- **WHEN** user opens Floor Plan tab
- **THEN** system displays only sites that have at least one floor plan
- **AND** sites without floor plans are filtered out from the list
- **AND** each site shows count and list of floor plans when expanded
- **AND** sites are sorted alphabetically

#### Scenario: Navigation title displays localized "Floorplans"
- **WHEN** user opens Floor Plan tab
- **THEN** navigation title SHALL use the `Floorplans` localization key
- **AND** English locale SHALL display "Floorplans"
- **AND** Traditional Chinese and Japanese locales SHALL display the same translations as the `Floor_plan` key

#### Scenario: Pull to refresh floor plans
- **WHEN** user performs pull-to-refresh gesture on floor plan list
- **THEN** system refreshes floor plan data from backend
- **AND** updates the list with latest floor plans
- **AND** re-applies filter to show only sites with floor plans

### Requirement: Floor Plan List View Modes
The system SHALL provide toggle between grid and list view modes for floor plan browsing, with user preference persisted across sessions.

#### Scenario: Toggle to grid view
- **WHEN** user taps grid icon in navigation bar
- **THEN** system switches to grid layout showing floor plan thumbnails
- **AND** saves preference to `@MyAppStorage`
- **AND** grid displays 2 columns in portrait, 3-4 in landscape

#### Scenario: Toggle to list view
- **WHEN** user taps list icon in navigation bar
- **THEN** system switches to list layout showing floor plan rows
- **AND** saves preference to `@MyAppStorage`
- **AND** each row shows thumbnail, name, and device count

#### Scenario: Restore view mode preference
- **WHEN** user reopens Floor Plan tab
- **THEN** system restores last used view mode (grid or list)
- **AND** displays appropriate toggle button state

### Requirement: Floor Plan Detail Presentation
The system SHALL present floor plan details in a full-screen modal using SheetManager when user taps a floor plan row.

#### Scenario: Open floor plan detail
- **WHEN** user taps on a floor plan row
- **THEN** system calls `sheetManager.openFloorPlanDetail(floorPlan:)`
- **AND** presents FloorPlanDetailView as full-screen modal
- **AND** supports landscape orientation

#### Scenario: Dismiss floor plan detail
- **WHEN** user swipes down or taps back button in floor plan detail
- **THEN** system dismisses modal and returns to floor plan list

### Requirement: Floor Plan Image Display
The system SHALL display floor plan images with zoom and pan capabilities using native SwiftUI gestures.

#### Scenario: Display floor plan image
- **WHEN** floor plan detail view loads
- **THEN** system displays floor plan image (JPEG or SVG format)
- **AND** image fits within screen bounds
- **AND** supports images up to 10 MB

#### Scenario: Zoom floor plan with pinch gesture
- **WHEN** user performs pinch gesture on floor plan image
- **THEN** system zooms image from 0.5x to 4.0x scale
- **AND** maintains aspect ratio

#### Scenario: Pan floor plan with drag gesture
- **WHEN** user drags finger on zoomed floor plan image
- **THEN** system pans image within boundaries
- **AND** prevents panning beyond image edges

#### Scenario: Floor plan image caching with URL-based invalidation
- **WHEN** floor plan image is loaded from backend
- **THEN** system caches image using Kingfisher with cache key `floorplan_{id}_{imageUrl.hashValue}`
- **AND** cache key includes imageUrl hash to ensure cache invalidates when image changes on server
- **AND** subsequent loads for same image URL use cached version
- **AND** when Portal updates floor plan image, API returns new imageUrl (S3 presigned URL)
- **AND** new imageUrl produces different hash, causing cache miss and fresh download

#### Scenario: Floor plan image refreshes after server-side update
- **WHEN** floor plan image is updated via Portal
- **AND** user performs pull-to-refresh on floor plan list
- **THEN** system fetches updated floor plan data with new imageUrl from API
- **AND** SwiftUI `.task(id: floorPlan.imageUrl)` detects URL change and re-triggers image loading
- **AND** ThumbnailManager downloads new image due to cache key mismatch
- **AND** updated image is displayed to user

#### Scenario: Double-tap to reset zoom
- **WHEN** user double-taps floor plan
- **THEN** system resets zoom to 1.0x
- **AND** centers floor plan in viewport
- **AND** animation is smooth with easeInOut

#### Scenario: Pinch-to-zoom with cumulative scaling
- **WHEN** user performs pinch gesture on floor plan
- **THEN** system applies cumulative zoom scaling
- **AND** zoom range is 0.5x to 4.0x
- **AND** zoom is smooth and responsive
- **AND** maintains center point during zoom

#### Scenario: Zoom scale persistence within session
- **WHEN** user zooms floor plan
- **AND** navigates away then returns
- **THEN** zoom scale resets to 1.0x on each view appearance
- **AND** does not persist across views

### Requirement: Camera Device Visualization
The system SHALL display multiple camera devices on the floor plan at their configured positions with visual markers indicating device status.

#### Scenario: Display camera markers at positions
- **WHEN** floor plan detail view loads device positions
- **THEN** system displays camera marker for each device at normalized coordinates (0-1)
- **AND** each marker shows camera icon
- **AND** markers are positioned accurately on floor plan image

#### Scenario: Camera marker size
- **WHEN** displaying camera marker on floor plan
- **THEN** marker circle SHALL be 24x24 pt
- **AND** device type icon inside marker SHALL be 20x20 pt
- **AND** marker size SHALL be consistent across all device states (online, offline, updating)

#### Scenario: Online device marker
- **WHEN** device status is online
- **THEN** marker circle displays green background (#2FBB00)
- **AND** device type icon displays in white (template mode)

#### Scenario: Offline device marker
- **WHEN** device status is offline
- **THEN** marker circle displays gray background (#8F8F8F)
- **AND** device type icon displays in white (template mode)

#### Scenario: Updating device marker
- **WHEN** device is updating firmware
- **THEN** marker circle displays orange background (#FF9600)
- **AND** device type icon displays in white (template mode)

#### Scenario: Selected device marker highlight
- **WHEN** device is selected
- **THEN** marker displays blue background (#2986FF)
- **AND** marker displays blue border (#154380, 4px stroke)
- **AND** device type icon remains white
- **AND** animation uses spring effect

### Requirement: Camera Field of View Overlay
The system SHALL display pre-configured camera field-of-view (FOV) sectors on the floor plan with unified color scheme based on device status and selection state.

#### Scenario: Display FOV sector for camera
- **WHEN** camera has FOV configuration (angle, direction, depth)
- **THEN** system renders FOV sector overlay
- **AND** sector originates from camera marker position
- **AND** sector displays configured angle, direction, and depth

#### Scenario: FOV depth denormalization uses image diagonal
- **WHEN** system converts normalized `fovDepth` (0-1) to pixel radius for rendering
- **THEN** system SHALL compute the image diagonal as `hypot(imageWidth, imageHeight)` (equivalent to `√(width² + height²)`)
- **AND** the pixel radius SHALL be `fovDepth × diagonal`
- **AND** this formula SHALL match the Portal (web) platform's denormalization to ensure cross-platform consistency

#### Scenario: FOV direction uses geographic-to-SwiftUI coordinate conversion
- **WHEN** system renders FOV sector direction
- **THEN** system SHALL convert `fovDirection` from geographic coordinate system (0° = North, clockwise) to SwiftUI rendering coordinate system (0° = East, clockwise with Y-axis down)
- **AND** the conversion formula SHALL be: `renderAngle = fovDirection - 90°`
- **AND** a `fovDirection` of 0° (North) SHALL render the FOV sector pointing upward on screen
- **AND** a `fovDirection` of 90° (East) SHALL render the FOV sector pointing right on screen
- **AND** a `fovDirection` of 180° (South) SHALL render the FOV sector pointing downward on screen
- **AND** a `fovDirection` of 270° (West) SHALL render the FOV sector pointing left on screen

#### Scenario: Online device FOV color
- **WHEN** device status is online
- **AND** device is not selected
- **THEN** FOV sector displays in green (#2FBB00) at 0.2 opacity

#### Scenario: Offline device FOV color
- **WHEN** device status is offline
- **AND** device is not selected
- **THEN** FOV sector displays in gray (#8F8F8F) at 0.2 opacity

#### Scenario: Updating device FOV color
- **WHEN** device is updating firmware
- **AND** device is not selected
- **THEN** FOV sector displays in orange (#FF9600) at 0.2 opacity

#### Scenario: Selected device FOV color
- **WHEN** device is selected
- **THEN** FOV sector displays in blue (#2986FF) at 0.3 opacity
- **AND** blue color overrides status-based color

#### Scenario: 360-degree camera FOV
- **WHEN** device FOV angle is 360 degrees
- **THEN** system renders full circle instead of cone sector
- **AND** circle is centered at camera marker position
- **AND** color follows same status/selection rules

#### Scenario: FOV depth animation
- **WHEN** device selection state changes
- **THEN** FOV depth animates smoothly with spring animation
- **AND** selected device FOV extends slightly for emphasis

### Requirement: Camera Device Selection with Split-Screen
The system SHALL allow users to tap camera markers to select them and immediately display split-screen view with live streaming panel.

#### Scenario: Select camera with single tap
- **WHEN** user taps camera marker
- **AND** camera is not currently selected
- **THEN** system selects camera
- **AND** displays blue outline and border around marker
- **AND** splits view 50/50 between floor plan and streaming panel
- **AND** orientation determines split direction (portrait: vertical, landscape: horizontal)

#### Scenario: Deselect camera by tapping marker again
- **WHEN** user taps already selected camera marker
- **THEN** system deselects camera
- **AND** removes blue outline
- **AND** dismisses streaming panel
- **AND** returns to full-screen floor plan view

#### Scenario: Deselect camera by tapping empty area
- **WHEN** camera is selected
- **AND** user taps empty area on floor plan
- **THEN** system deselects camera
- **AND** dismisses streaming panel

#### Scenario: Switch selected camera
- **WHEN** user taps different camera marker while another is selected
- **THEN** system stops streaming from previous camera
- **AND** waits 0.3 seconds for cleanup
- **AND** selects new camera
- **AND** starts streaming from new camera

### Requirement: Split-Screen Layout with Streaming
The system SHALL display floor plan and live streaming in adaptive split-screen layout based on device orientation, using a persistent view structure that preserves streaming connection across layout changes.

#### Scenario: Portrait split-screen layout
- **WHEN** device is in portrait orientation
- **AND** camera is selected
- **THEN** system displays floor plan in top half
- **AND** displays streaming panel in bottom half
- **AND** each section occupies 50% of screen height

#### Scenario: Landscape split-screen layout
- **WHEN** device is in landscape orientation
- **AND** camera is selected
- **THEN** system displays floor plan in left half
- **AND** displays streaming panel in right half
- **AND** each section occupies 50% of screen width

#### Scenario: Orientation change with active streaming
- **WHEN** device orientation changes
- **AND** streaming is active
- **THEN** system animates layout transition with 0.3s easeInOut
- **AND** streaming connection SHALL NOT be interrupted or reconnected
- **AND** adapts split direction to new orientation
- **AND** StreamingViewWrapper identity SHALL remain unchanged across orientation transitions

#### Scenario: Streaming panel view identity persistence
- **WHEN** layout changes due to orientation change or fullscreen toggle
- **THEN** SelectedDeviceInfoPanel SHALL be a single persistent instance in the view tree
- **AND** system SHALL NOT use conditional view branches (if-else) that create different SwiftUI view identities for the streaming panel
- **AND** layout differences SHALL be achieved through frame, alignment, and opacity properties

### Requirement: Streaming Panel with Fixed Header
The system SHALL display a fixed header above the streaming view containing device information and control buttons.

#### Scenario: Display streaming header
- **WHEN** camera is selected and streaming starts
- **THEN** system displays fixed header at top of streaming panel
- **AND** header shows device connection icon (white, 32x32)
- **AND** header shows device display name (.subtitle.color09)
- **AND** header shows LIVE indicator when streaming is active
- **AND** header height is 36px
- **AND** header background is #121212

#### Scenario: Full-screen toggle button
- **WHEN** streaming header is visible
- **THEN** header displays fullscreen toggle button (32x32 icon)
- **AND** button shows expand icon when not fullscreen
- **AND** button shows collapse icon when fullscreen
- **AND** tapping button toggles fullscreen mode with animation

#### Scenario: Close streaming button
- **WHEN** streaming header is visible
- **THEN** header displays close button (X icon, 32x32)
- **AND** tapping button deselects camera
- **AND** dismisses streaming panel
- **AND** returns to full-screen floor plan view

#### Scenario: Streaming panel occupies full area
- **WHEN** streaming panel is displayed (split or fullscreen)
- **THEN** panel fills entire allocated space without padding or borders
- **AND** header spans full width
- **AND** streaming view fills remaining space below header

### Requirement: Full-Screen Streaming Mode
The system SHALL provide full-screen streaming mode with smooth transitions that preserve streaming connection.

#### Scenario: Enter full-screen streaming
- **WHEN** user taps fullscreen button in streaming header
- **THEN** system transitions to full-screen mode
- **AND** floor plan view hides (opacity 0)
- **AND** streaming panel expands to fill entire screen
- **AND** header remains visible with controls
- **AND** animation duration is 0.3s easeInOut
- **AND** streaming connection SHALL NOT be interrupted

#### Scenario: Exit full-screen streaming
- **WHEN** user taps minimize button in full-screen mode
- **THEN** system transitions back to split-screen
- **AND** floor plan view reappears (opacity 1)
- **AND** streaming panel returns to 50% size
- **AND** animation duration is 0.3s easeInOut
- **AND** streaming connection SHALL NOT be interrupted

#### Scenario: Orientation change during full-screen streaming
- **WHEN** device orientation changes during full-screen streaming mode
- **THEN** streaming panel remains full-screen
- **AND** streaming connection SHALL NOT be interrupted
- **AND** safe area handling adapts to new orientation

### Requirement: Streaming Lifecycle Management
The system SHALL manage streaming lifecycle automatically based on device selection state.

#### Scenario: Start streaming on selection
- **WHEN** camera is selected
- **THEN** system creates ViewcellControl for device
- **AND** calls `startStreaming()` async method
- **AND** waits for streaming status to be ready

#### Scenario: Stop streaming on deselection
- **WHEN** camera is deselected
- **THEN** system calls `stopStreaming()` async method
- **AND** waits 0.3 seconds for cleanup
- **AND** releases ViewcellControl
- **AND** transitions view back to full-screen floor plan

#### Scenario: Cleanup on view dismiss
- **WHEN** floor plan detail view is dismissed
- **THEN** system stops any active streaming
- **AND** clears all selections
- **AND** releases resources

### Requirement: Streaming View Integration
The system SHALL integrate SimpleStreamingViewCell component for video rendering within streaming panel.

#### Scenario: Display streaming view
- **WHEN** ViewcellControl is ready
- **THEN** system displays SimpleStreamingViewCell
- **AND** passes ViewcellControl as environment object
- **AND** video renders in proper aspect ratio
- **AND** supports device-specific features (PTZ, fisheye)

#### Scenario: Streaming loading state
- **WHEN** streaming is initializing
- **THEN** system displays black background with loading indicator
- **AND** progress view is white and scaled 1.5x

### Requirement: Hero Animation for Fullscreen Transition
The system SHALL use matched geometry effects for smooth fullscreen transitions.

#### Scenario: Matched geometry effect on streaming content
- **WHEN** user toggles fullscreen mode
- **THEN** system applies `matchedGeometryEffect` to streaming view
- **AND** id is "streamingContent"
- **AND** namespace is shared between split and fullscreen states
- **AND** transition is automatic and smooth

### Requirement: Connection Status Icons
The system SHALL display device-specific connection status icons that reflect online/offline state only.

#### Scenario: Use simpleStateIcon for connection status
- **WHEN** displaying camera marker or streaming header
- **THEN** system uses `device.simpleStateIcon` property
- **AND** icon reflects device type (normal camera, fisheye, PTZ, NVR, etc.)
- **AND** icon has online vs offline variant
- **AND** icon does not show recording or updating states (simplified)

#### Scenario: Render icons in template mode
- **WHEN** displaying connection status icons
- **THEN** system uses `.renderingMode(.template)`
- **AND** applies `.foregroundColor(.white)` for consistent white icons
- **AND** icon size is 32x32 in streaming header, 20x20 in camera markers

### Requirement: Floor Plan Search
The system SHALL provide search functionality to filter floor plans by name across all sites, with a localized search placeholder via the custom `searchable(text:isActive:prompt:)` extension.

#### Scenario: Search bar displays localized placeholder
- **WHEN** search bar is visible on Floor Plan tab
- **THEN** search field SHALL display placeholder text from `Search_floor_plans_or_sites` localization key
- **AND** English: "Search floor plans or sites"
- **AND** Traditional Chinese: "搜尋平面圖或站點"
- **AND** Japanese: "フロアプランまたはサイトを検索"

#### Scenario: Search bar default placeholder
- **WHEN** `searchable(text:isActive:)` is called without a `prompt` parameter
- **THEN** search field SHALL display the system default placeholder (localized "Search")

#### Scenario: Search floor plans by keyword
- **WHEN** user enters keyword in search bar
- **THEN** system filters floor plan list to show only matching floor plans
- **AND** highlights matching text in floor plan names
- **AND** shows sites containing matching floor plans

#### Scenario: Clear search results
- **WHEN** user clears search keyword
- **THEN** system restores full floor plan list
- **AND** removes highlighting

### Requirement: Device Search with Auto-Navigation
The system SHALL provide dedicated device search view that automatically navigates to floor plan with selected device.

#### Scenario: Open device search
- **WHEN** user taps search icon in floor plan detail navigation bar
- **THEN** system pushes FloorPlanDeviceSearchView
- **AND** displays searchable list of all devices on floor plan
- **AND** devices are grouped by site

#### Scenario: Select device from search
- **WHEN** user taps device in search results
- **THEN** system navigates back to floor plan detail
- **AND** automatically selects tapped device
- **AND** starts streaming in split-screen mode

#### Scenario: Search filtering
- **WHEN** user types in search field
- **THEN** system filters devices by display name in real-time
- **AND** maintains site grouping in results
- **AND** highlights matching text

### Requirement: Floor Plan Data Management
The system SHALL manage floor plan data through a dedicated FloorPlanManager following the singleton pattern used by DeviceManager.

#### Scenario: Fetch floor plans on tab appear
- **WHEN** user opens Floor Plan tab
- **THEN** system calls `FloorPlanManager.fetchAll()`
- **AND** fetches floor plans for all accessible sites via API
- **AND** displays loading indicator during fetch
- **AND** caches floor plans in memory

#### Scenario: Lazy load device positions
- **WHEN** user opens floor plan detail view
- **THEN** system fetches device positions for specific floor plan
- **AND** displays camera markers only after positions are loaded
- **AND** shows loading state if positions are not yet cached

#### Scenario: Handle API failure gracefully
- **WHEN** floor plan API request fails
- **THEN** system logs error
- **AND** displays error message to user
- **AND** allows retry via pull-to-refresh

### Requirement: Feature Toggle Control

The system SHALL control Floor Plan tab visibility through feature toggles in FeatureProvider following existing patterns. Additionally, Floor Plan tab access SHALL be gated by license tier, and the tab SHALL be disabled (not removed) during RenewalOverdue.

#### Scenario: Feature flag enabled

- **WHEN** remote config `feature_floor_plan` is true
- **AND** user has site read permissions
- **AND** organization support features include `floorPlan`
- **THEN** Floor Plan tab appears in `supportedHomeViewTabs()`

#### Scenario: Feature flag disabled

- **WHEN** remote config `feature_floor_plan` is false
- **THEN** Floor Plan tab does not appear regardless of permissions

#### Scenario: License renewal overdue disables tab

- **WHEN** organization license phase is RenewalOverdue
- **THEN** Floor Plan tab SHALL remain visible in the tab bar
- **AND** Floor Plan tab SHALL be disabled (greyed out) via `canTrigger(for: .floorPlan)` returning `false`
- **AND** tapping the disabled tab SHALL have no effect

#### Scenario: Free plan blocks floor plan access

- **WHEN** organization is on the free plan (xLite)
- **AND** Floor Plan tab is visible (feature flag enabled, support features include floorPlan)
- **THEN** `canAccess(for: .floorPlan)` SHALL return `false`
- **AND** the tab content SHALL show a promotion page instead of floor plan data

### Requirement: Platform Orientation Support
The system SHALL support both portrait and landscape orientations with appropriate layout adjustments.

#### Scenario: Floor plan list in portrait
- **WHEN** device is in portrait orientation
- **THEN** floor plan list displays in single column
- **AND** site disclosure groups expand vertically

#### Scenario: Floor plan detail in landscape
- **WHEN** user opens floor plan detail
- **AND** device rotates to landscape
- **THEN** floor plan image scales to utilize landscape viewport
- **AND** camera markers reposition according to landscape dimensions
- **AND** zoom controls remain accessible

#### Scenario: SheetManager orientation support
- **WHEN** SheetManager presents FloorPlanDetailView
- **THEN** presentation includes `supportOrientation: true` parameter
- **AND** view supports .all orientation mask

### Requirement: Safe Area Handling for Split-Screen
The system SHALL properly handle safe areas in both portrait and landscape orientations for split-screen layout.

#### Scenario: Portrait safe area handling
- **WHEN** device is in portrait orientation
- **THEN** system applies bottom safe area padding to split-screen container
- **AND** content does not extend under home indicator
- **AND** left/right safe areas handled by system automatically

#### Scenario: Landscape safe area handling
- **WHEN** device is in landscape orientation
- **THEN** system relies on automatic safe area handling for left/right edges
- **AND** does not apply manual padding (prevents double padding)
- **AND** content respects notch and Dynamic Island areas

#### Scenario: Full-screen streaming safe area
- **WHEN** streaming is in full-screen mode
- **THEN** same safe area rules apply based on orientation
- **AND** header extends to screen edges with safe area padding only for content

### Requirement: Shared Component Flexibility
The system SHALL provide flexible FloorPlanSiteGroup component that supports displaying either site names or custom names based on context, using a location mark icon for site identification.

#### Scenario: Display site group with custom name
- **WHEN** FloorPlanSiteGroup is initialized with displayName parameter
- **THEN** system displays the provided displayName in the group header
- **AND** uses `iconGeneralLocationMark` icon in the group header
- **AND** tapping header triggers onHeaderTapped callback if provided

#### Scenario: Display site group with site name (backward compatibility)
- **WHEN** FloorPlanSiteGroup is initialized with site parameter only
- **THEN** system displays site.name in the group header
- **AND** uses `iconGeneralLocationMark` icon in the group header
- **AND** maintains existing behavior for site-tapped callback

### Requirement: Device Search Display and Clarity
The system SHALL display floor plan names instead of site names in device search results and provide clear search placeholder text.

#### Scenario: Device search shows floor plan name
- **WHEN** user opens device search from floor plan detail
- **AND** search results are displayed
- **THEN** system groups devices under floor plan name instead of site name
- **AND** displays floor plan name in group header
- **AND** uses FloorPlanSiteGroup with custom displayName

#### Scenario: Device search placeholder clarity
- **WHEN** device search view is displayed
- **THEN** search field placeholder shows "Device_search" localized text
- **AND** clearly indicates the search is for devices, not sites or floor plans

### Requirement: Floor Plan License Tier Access Control

The system SHALL restrict floor plan tab access based on the organization's license tier. xLite (free plan) organizations SHALL be blocked from accessing floor plan content and shown a commercial promotion page instead.

#### Scenario: xLite user sees promotion page instead of floor plan content

- **WHEN** user belongs to a free plan (xLite) organization
- **AND** user navigates to the Floor Plan tab
- **THEN** system SHALL display a `FloorPlanFeaturePromotionView` instead of floor plan content
- **AND** the promotion page SHALL follow the `FeaturePromotionView` pattern used by Archive and AI Hub tabs
- **AND** the promotion page SHALL include a title, description, background image, and optional "Explore More" link
- **AND** `featureToggle.canAccess(for: .floorPlan)` SHALL return `false`

#### Scenario: Paid organization user accesses floor plan normally

- **WHEN** user belongs to a paid organization (xStd or xPro)
- **AND** organization phase is Valid, NoticePeriod, or GracePeriod
- **THEN** system SHALL grant full access to the floor plan tab content
- **AND** `featureToggle.canAccess(for: .floorPlan)` SHALL return `true`

#### Scenario: Floor plan promotion model provides tab-specific content

- **WHEN** the system needs to display a promotion page for floor plan
- **THEN** `HomeViewTab.floorPlan.promotionModel` SHALL return a `FeaturePromotionModel`
- **AND** the model SHALL include a localized title, description, and background image resource
- **AND** the promotion description SHALL read: "See the entire property at a glance. VORTEX Floor Plan turns building layouts into interactive security maps, with cameras placed at their real-world positions and coverage areas visualized on screen. To access this feature, contact your reseller for upgrade options."
- **AND** "VORTEX" in the description SHALL be replaced with the product name via `VortexEnvironment.productNameLocalized`
- **AND** the background image asset SHALL be `img_floorplan_sample` (light/dark × 1x/2x/3x)

### Requirement: Floor Plan Access During RenewalOverdue

The system SHALL disable the floor plan tab when the organization enters RenewalOverdue phase, consistent with the existing lockdown pattern applied to all feature tabs.

#### Scenario: Floor plan tab disabled during RenewalOverdue

- **WHEN** the organization license phase is RenewalOverdue
- **THEN** `featureToggle.canTrigger(for: .floorPlan)` SHALL return `false`
- **AND** the Floor Plan tab item SHALL be visually disabled (greyed out)
- **AND** tapping the disabled tab SHALL have no effect
- **AND** the tab SHALL remain visible in the tab bar (not removed)

#### Scenario: Floor plan tab re-enabled after license renewal

- **WHEN** the organization license phase transitions from RenewalOverdue back to Valid
- **THEN** `featureToggle.canTrigger(for: .floorPlan)` SHALL return `true`
- **AND** the Floor Plan tab SHALL become interactive again
- **AND** all previously saved floor plan data SHALL be accessible

### Requirement: Floor Plan Access During Grace Period and Notice Period

The system SHALL maintain full floor plan access during NoticePeriod and GracePeriod phases for paid organizations.

#### Scenario: Floor plan fully accessible during NoticePeriod

- **WHEN** the organization license phase is NoticePeriod
- **THEN** `featureToggle.canAccess(for: .floorPlan)` SHALL return `true`
- **AND** `featureToggle.canTrigger(for: .floorPlan)` SHALL return `true`
- **AND** all floor plan functionality SHALL be unrestricted

#### Scenario: Floor plan fully accessible during GracePeriod

- **WHEN** the organization license phase is GracePeriod
- **THEN** `featureToggle.canAccess(for: .floorPlan)` SHALL return `true`
- **AND** `featureToggle.canTrigger(for: .floorPlan)` SHALL return `true`
- **AND** all floor plan functionality SHALL be unrestricted

### Requirement: Floor Plan API 423 — Not Applicable to iOS

The iOS app SHALL NOT implement dedicated HTTP 423 error handling for floor plan APIs. Per the high-level spec's API enforcement matrix, HTTP 423 is only returned for create/modify operations during RenewalOverdue. The iOS app is read-only for floor plans (only calls GET list and GET device-positions) — these endpoints always return 200 regardless of license phase. The existing generic `appManager.handleError` SHALL serve as a safety net for any unexpected HTTP errors.

#### Scenario: iOS app never encounters 423 from floor plan APIs

- **WHEN** the iOS app calls floor plan GET endpoints (list floor plans, get device positions)
- **THEN** the backend SHALL always return HTTP 200 regardless of license phase
- **AND** the iOS app SHALL NOT require dedicated 423 error mapping or handling
- **AND** the existing `appManager.handleError` SHALL handle any unexpected HTTP errors as a safety net

### Requirement: Floor Plan Downgrade Prerequisite

The system SHALL include floor plan data deletion as a prerequisite item in the organization downgrade checklist when transitioning from paid to free (xLite) plan.

#### Scenario: Floor plan mission appears in downgrade checklist

- **WHEN** user views the downgrade eligibility checklist via `postCheckDowngrade()` API
- **AND** the backend returns a floor plan-related `CheckDowngradeItem`
- **THEN** system SHALL parse the item into a `MissionType.floorPlan` case
- **AND** system SHALL display title: "Delete floor plans" and description: "You must delete all floor plan data before downgrading."
- **AND** the backend `mission` string is `"FLOOR_PLAN_LIMIT"`, parsed into `MissionType.floorPlan`

#### Scenario: Floor plan mission not present for organizations without floor plans

- **WHEN** user views the downgrade eligibility checklist
- **AND** the backend does NOT return a floor plan `CheckDowngradeItem`
- **THEN** system SHALL NOT display a floor plan mission item
- **AND** the downgrade flow SHALL proceed without floor plan prerequisite

### Requirement: Live License Phase Transition Handling

The system SHALL handle license phase transitions while the user is actively using the floor plan feature, dismissing floor plan detail views and updating tab state reactively.

#### Scenario: Organization transitions to RenewalOverdue while viewing floor plan detail

- **WHEN** user is viewing a floor plan detail (presented via SheetManager)
- **AND** the organization license phase transitions to RenewalOverdue
- **THEN** system SHALL dismiss the floor plan detail sheet
- **AND** the Floor Plan tab SHALL become disabled (greyed out)

#### Scenario: Organization transitions to free plan while viewing floor plan

- **WHEN** user is on the Floor Plan tab
- **AND** the organization transitions from paid to free plan
- **THEN** `FloorPlanTabView` SHALL re-render to show the promotion page
- **AND** if a floor plan detail sheet is open, system SHALL dismiss it
- **AND** no floor plan API calls SHALL be made after the transition

#### Scenario: Organization license renews while on promotion page

- **WHEN** user is viewing the floor plan promotion page (xLite)
- **AND** the organization transitions from free to paid plan
- **THEN** `FloorPlanTabView` SHALL re-render to show the normal floor plan content
- **AND** system SHALL fetch floor plan data automatically

### Requirement: Floor Plan Data Freshness

The Floor Plan tab SHALL NOT independently refresh device/site data from the backend. Site and device data may be stale relative to the latest backend state; the user is responsible for triggering a refresh (e.g., pull-to-refresh on the Home/View tab) to update shared device and site data.

#### Scenario: Floor plan tab uses existing cached site data

- **WHEN** user navigates to the Floor Plan tab
- **THEN** system SHALL use the currently cached site data from `featureProvider.accessibleSitesForFloorPlan()`
- **AND** system SHALL NOT call `deviceManager.fetchAll()` to refresh site/device data
- **AND** system SHALL only fetch floor plan data via `floorPlanManager.fetchAllFloorPlans()`

#### Scenario: User triggers floor plan refresh

- **WHEN** user performs pull-to-refresh on the Floor Plan tab
- **THEN** system SHALL re-fetch floor plan data using the currently cached site list
- **AND** system SHALL NOT trigger a full device/site data refresh
- **AND** if the user needs updated site data, they must refresh from the Home or View tab first

