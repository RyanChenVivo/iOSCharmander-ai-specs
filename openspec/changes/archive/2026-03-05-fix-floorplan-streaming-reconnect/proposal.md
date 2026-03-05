## Why

When a user selects a device in FloorPlanDetailView and starts streaming, rotating the device causes the streaming to disconnect and reconnect. The same issue occurs when toggling between split view and fullscreen mode. This creates a poor user experience with visible interruptions, while the MultipleView (opened from View Tab) handles rotation seamlessly without reconnecting.

The root cause is SwiftUI's view identity mechanism: FloorPlanDetailView uses `if-else` branches to switch between `HStack` (landscape) and `VStack` (portrait), which destroys and recreates the entire view subtree — including `StreamingViewWrapper` — on every orientation change.

## What Changes

- Restructure `FloorPlanDetailView.body` to use a single fixed `ZStack` container instead of conditional `HStack`/`VStack` switching
- Keep `SelectedDeviceInfoPanel` (which contains `StreamingViewWrapper`) as a single persistent instance in the view tree
- Control layout differences (split portrait, split landscape, fullscreen, unselected) through `frame`, `alignment`, and `opacity` properties rather than conditional view branches
- This follows the same pattern already proven in `MultipleView`

## Capabilities

### New Capabilities

_None — this is a structural refactor of existing UI, no new capabilities introduced._

### Modified Capabilities

- `mobile-floor-plan-viewing`: The streaming panel layout mechanism changes from conditional view branching to persistent view with dynamic frame/opacity. No user-facing behavior change — streaming should work identically but without reconnection on rotation or fullscreen toggle.

## Impact

- **Code**: `FloorPlanDetailView.swift` — body restructure, add computed properties for frame/alignment/opacity per state
- **No API changes**: Pure UI-layer refactor
- **No dependency changes**: Uses existing SwiftUI primitives
- **Risk**: Layout positioning with `GeometryReader` + manual frames needs careful testing across device sizes and orientations
