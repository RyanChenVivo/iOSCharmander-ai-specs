## Why

iOS app and Portal (web) use different normalization bases for `fovDepth`, causing the same camera to display different FOV coverage sizes across platforms. Portal uses image diagonal `√(w² + h²)` while iOS uses `min(w, h)`. On a 16:9 image, the iOS FOV radius is roughly 49% of what Portal shows. This must be fixed so both platforms render consistent FOV areas.

## What Changes

- Fix `fovDepth` denormalization in `CameraOverlay.swift` to use image diagonal (`√(width² + height²)`) instead of `min(width, height)`, matching Portal's `FloorPlanHelper.js` implementation.
- Update any related unit tests to reflect the corrected normalization formula.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `mobile-floor-plan-viewing`: FOV depth denormalization formula changes from `fovDepth × min(w, h)` to `fovDepth × √(w² + h²)`.

## Impact

- **Code**: `CameraOverlay.swift` (line 22) - the `fovDepth` computed property
- **Visual**: FOV areas will appear larger on iOS after the fix (matching Portal's rendering)
- **Tests**: Unit/UI tests referencing FOV depth calculations may need updates
- **APIs**: No API changes - the normalized `fovDepth` value (0-1) stored in backend remains unchanged
