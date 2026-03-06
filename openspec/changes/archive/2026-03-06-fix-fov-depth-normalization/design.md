## Context

The iOS app's `CameraOverlay.swift` denormalizes `fovDepth` using `min(imageSize.width, imageSize.height)`, while the Portal (web) uses the image diagonal `√(w² + h²)`. Both platforms share the same backend API that stores `fovDepth` as a normalized value (0-1). This mismatch causes the same camera's FOV to render at different sizes on each platform.

Current iOS code (`CameraOverlay.swift:22`):
```swift
position.fovDepth * min(imageSize.width, imageSize.height)
```

Portal reference (`FloorPlanHelper.js:68-71`):
```javascript
const diagonal = Math.sqrt(width * width + height * height);
return normalizedDepth * diagonal;
```

## Goals / Non-Goals

**Goals:**
- Align iOS `fovDepth` denormalization with Portal's diagonal-based formula
- Ensure consistent FOV rendering across platforms for the same normalized value

**Non-Goals:**
- Changing the Portal's normalization logic
- Changing the backend API's storage format
- Adding FOV editing capabilities to iOS

## Decisions

### Use `hypot()` for diagonal calculation

**Decision**: Use Swift's built-in `hypot(width, height)` instead of manually computing `sqrt(w*w + h*h)`.

**Rationale**: `hypot()` is numerically more stable (avoids intermediate overflow/underflow) and more readable. It produces the same result as `√(w² + h²)`.

**Change**:
```swift
// Before
position.fovDepth * min(imageSize.width, imageSize.height)

// After
position.fovDepth * hypot(imageSize.width, imageSize.height)
```

### Inline calculation (no helper function)

**Decision**: Keep the formula inline in `CameraOverlay.swift` rather than extracting a shared utility.

**Rationale**: This is the only place `fovDepth` is denormalized in iOS. A utility function adds indirection for a one-liner. If more call sites emerge in the future, extraction can happen then.

## Risks / Trade-offs

- **[Visual change]** → FOV areas will appear larger after the fix (e.g., ~2x on 16:9 images). This is the correct behavior matching Portal. No migration needed since values are backend-stored.
- **[Test updates]** → Any tests using hardcoded expected FOV depth values will need updating to use diagonal-based expectations.
