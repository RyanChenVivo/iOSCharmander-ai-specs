## 1. Fix FOV Direction Rendering

- [x] 1.1 In `CameraOverlay.swift` `CameraFOVShape.path(in:)`, change `let directionRad = fovDirection * .pi / 180` to `let directionRad = (fovDirection - 90) * .pi / 180` to convert geographic coordinates to SwiftUI rendering coordinates

## 2. Reduce Camera Marker Size

- [x] 2.1 In `CameraOverlay.swift`, change `markerSize` from 40 to 24 (internal icon 20x20 remains unchanged)

## 3. Update Tests

- [x] 3.1 Update existing FOV-related test expectations in `FloorPlanDetailViewModelTest.swift` to reflect geographic coordinate semantics (fovDirection 0 = North/up, not East/right)
- [x] 3.2 Add test cases verifying FOV direction conversion for cardinal directions (0°→up, 90°→right, 180°→down, 270°→left)

## 4. Verification

- [x] 4.1 Build project and run existing unit tests to confirm no regressions
- [x] 4.2 Manual verification on simulator: confirm FOV direction and marker size match Portal
