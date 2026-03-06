## Context

The backend API returns `fovDirection` in geographic coordinate system (0° = North, clockwise). The iOS `CameraFOVShape` uses `cos()`/`sin()` with this value directly, which maps to math coordinate system (0° = East). In SwiftUI's coordinate system (Y-axis down), `sin()` produces clockwise rotation visually, matching geographic convention's rotation direction — but the origin angle is offset by 90°.

Current code in `CameraOverlay.swift:135`:
```swift
let directionRad = fovDirection * .pi / 180
```

This means a camera set to 0° (North/up) in Portal renders pointing East (right) in the app.

## Goals / Non-Goals

**Goals:**
- Fix FOV direction to match Portal's geographic coordinate rendering
- Maintain correct behavior for 360° fisheye cameras (full circle, direction irrelevant)

**Non-Goals:**
- Changing the API contract or data models
- Modifying fovDepth calculation
- Changing FOV visual styling or colors

## Decisions

### Convert direction at rendering layer only

Apply the -90° offset in `CameraFOVShape.path(in:)` where `directionRad` is calculated.

**Rationale:** The conversion is a view concern. Keeping model values as-is (matching API) avoids confusion about which coordinate system stored values use. If another feature needs the geographic direction (e.g., displaying "Camera facing North"), the original value remains available.

**Alternative considered:** Converting in `DevicePosition` init — rejected because it would make the stored value differ from the API value silently, causing confusion for debugging.

### Formula

```swift
// Geographic (0°=N, CW) → SwiftUI math (0°=E, CW with Y-down)
let directionRad = (fovDirection - 90) * .pi / 180
```

Verification:
| Portal direction | Geographic ° | After -90° | cos/sin result | Visual direction |
|---|---|---|---|---|
| North (up) | 0° | -90° | (0, -1) | Up |
| East (right) | 90° | 0° | (1, 0) | Right |
| South (down) | 180° | 90° | (0, 1) | Down |
| West (left) | 270° | 180° | (-1, 0) | Left |

## Risks / Trade-offs

- **[Low] Existing test data uses math convention** → Update test expectations to reflect geographic coordinate input values. Current test with `fovDirection: 0` meant "pointing right" in math convention but should now mean "pointing north".
