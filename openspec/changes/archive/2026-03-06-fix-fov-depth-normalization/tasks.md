## 1. Fix FOV Depth Denormalization

- [x] 1.1 Update `CameraOverlay.swift` line 22: change `position.fovDepth * min(imageSize.width, imageSize.height)` to `position.fovDepth * hypot(imageSize.width, imageSize.height)`

## 2. Verify Tests

- [x] 2.1 Run existing FloorPlanDetailViewModelTest to confirm CameraFOVShape tests still pass (they use pre-computed pixel depths, not the normalization formula)
- [x] 2.2 Run existing FloorPlanManagerTest to confirm no regressions
