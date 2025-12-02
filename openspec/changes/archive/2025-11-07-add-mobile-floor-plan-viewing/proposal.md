# Add Mobile Floor Plan Viewing

## Why

iOS mobile app users need to monitor their camera deployments within the spatial context of their facilities while on the go. The web platform provides comprehensive floor plan management with editing capabilities, but mobile users primarily need read-only access for operational monitoring, security oversight, and quick camera feed access from their mobile devices. Mobile devices have different interaction patterns (touch interfaces, on-site walkthrough) and use cases (monitoring over configuration) compared to desktop.

## What Changes

This change adds **view-only** floor plan capabilities to the iOS mobile app, enabling users to:

- Browse sites and floor plans hierarchically within organizations
- View floor plan images (JPEG, SVG) with zoom and pan controls
- See multiple camera positions on floor plans with visual markers
- View pre-configured camera field-of-view (FOV) overlays
- Access live camera streams directly from floor plan interface via long-press gesture
- View camera status indicators (Online: green / Offline: red / Firmware updating: orange)
- Select cameras to view detailed information panel
- Search and filter floor plans by name

**Explicitly Excluded** (Desktop/Web Only):
- Floor plan creation, editing, or deletion
- Floor plan image upload
- Camera drag-and-drop positioning
- FOV editor (angle, direction, depth adjustment)
- Delete camera positions from floor plans

**Breaking Changes**: None - this is a new feature addition to mobile app

## Impact

**Affected specs**:
- **NEW**: `specs/mobile-floor-plan-viewing/spec.md` - Mobile view-only floor plan interface

**Affected code**:
- iOS Home tab integration:
  - `iOSCharmander/View/Home/Tab/HomeViewTab.swift` - Add `.floorPlan` case
  - `iOSCharmander/View/Home/Tab/HomeViewTabViewModel.swift` - Update default tabs
  - `iOSCharmander/Common/FeatureProvider/FeatureToggle.swift` - Add `canViewTab(.floorPlan)` logic

- iOS SheetManager integration:
  - `iOSCharmander/View/Home/Sheet/SheetManager.swift` - Add `openFloorPlanDetail()` method
  - `iOSCharmander/View/Home/Sheet/SheetManagerProtocol.swift` - Add protocol method

- iOS Floor Plan UI (new):
  - `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanTabView.swift` - Main tab view
  - `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanTabViewModel.swift` - Tab view model
  - `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanDetailView.swift` - Floor plan detail modal
  - `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanDetailViewModel.swift` - Detail view model
  - `iOSCharmander/View/Home/Tab/FloorPlanTab/Components/` - Camera markers, FOV, info panel components

- iOS Data layer (new):
  - `iOSCharmander/Common/FloorPlanManager/FloorPlanManager.swift` - Floor plan data management
  - `iOSCharmander/Model/FloorPlan/FloorPlanItem.swift` - Floor plan model
  - `iOSCharmander/Model/FloorPlan/DevicePosition.swift` - Camera position model
  - VortexAPI extensions for floor plan endpoints

**Dependencies**:
- Backend floor plan API (GET endpoints only):
  - `GET /api/v1/sites/{site_id}/floor-plans` - List floor plans
  - `GET /api/v1/floor-plans/{id}` - Get floor plan details
  - `GET /api/v1/floor-plans/{id}/device-positions` - List camera positions
- Camera API for device status and snapshots
- Live streaming service (MultipleView integration)
- Existing `DeviceManager` for camera data
- Existing `SheetManager` for modal presentation

**Technical Constraints**:
- Max 10 floor plans per site (backend enforced)
- Single concurrent live stream (platform limitation)
- Image formats: JPEG, SVG
- Max image size: 10 MB (backend enforced)
- Network dependency for real-time camera status

**Migration**: No migration required - new feature with no impact on existing mobile functionality

**Platform-Specific Considerations**:
- Use `ScrollView` with `MagnificationGesture` and `DragGesture` for zoom/pan
- SwiftUI Path/Canvas for FOV sector rendering
- Efficient image caching (AsyncImage)
- Support iPhone and iPad
- Portrait and landscape orientation support (landscape for floor plan detail)
- Offline: Display cached floor plans with "Last updated" indicator
