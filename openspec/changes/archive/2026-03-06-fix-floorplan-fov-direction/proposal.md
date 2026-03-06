## Why

Portal uses geographic coordinate system for `fovDirection` (0° = North/up, clockwise), but the iOS app's `CameraFOVShape` renders using math coordinate system (0° = East/right, counterclockwise in standard math, but clockwise visually due to SwiftUI's flipped Y-axis). This causes a 90° offset — e.g., a camera pointing North in Portal renders pointing East in the app. Redmine #59493 reports this as "Portal 新增的 Floor Plan camera 方向、覆蓋範圍與 APP 不符".

Additionally, the camera marker icon size (40pt circle) is too large compared to Android, occupying too much floor plan map area. Redmine #59497 reports "建議調整 Floor Plan camera 圖示的大小". UX specifies the marker circle should be 24pt with 20x20 internal icon.

## What Changes

- Convert `fovDirection` from geographic coordinate system (0° = North, clockwise) to SwiftUI math coordinate system (0° = East, clockwise with Y-down) before rendering the FOV shape
- The conversion formula: `mathAngle = geographicAngle - 90°`
- Reduce camera marker circle from 40pt to 24pt (internal icon remains 20x20)
- No API model changes needed — changes are at the rendering layer only
- Update unit tests to verify the coordinate conversion

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `mobile-floor-plan-viewing`: The FOV rendering requirement needs to specify the coordinate system conversion from backend geographic coordinates to SwiftUI rendering coordinates.

## Impact

- **Code**: `CameraOverlay.swift` — `CameraFOVShape` direction calculation + marker size constants
- **Tests**: `FloorPlanDetailViewModelTest.swift` or new FOV rendering tests
- **Risk**: Low — isolated UI changes to FOV direction math and marker sizing, no API or data model changes
