## Context

FloorPlanDetailView currently uses `if orientation.isLandscape { HStack { ... } } else { VStack { ... } }` to switch between landscape and portrait layouts. In SwiftUI, `if-else` branches create different view identities — when the condition changes, the entire branch is destroyed and recreated. This causes `StreamingViewWrapper` (a `UIViewRepresentable` with `@StateObject`) to call `dismantleUIView` → `releaseStreamingObjects()`, then `makeUIView` → new streaming connection.

The same issue occurs when toggling between split-screen and fullscreen, as `SelectedDeviceInfoPanel` appears in three separate `if-else` branches.

MultipleView solves this by keeping `streamingView` in a single fixed `VStack` and using `.overlay` for orientation-specific UI, so the streaming view's identity never changes.

## Goals / Non-Goals

**Goals:**
- Eliminate streaming reconnection on device rotation in FloorPlanDetailView
- Eliminate streaming reconnection on split/fullscreen toggle
- Maintain identical visual layout behavior (50/50 split, fullscreen overlay, safe area handling)
- Follow the same pattern proven in MultipleView

**Non-Goals:**
- Changing SelectedDeviceInfoPanel internals
- Changing StreamingViewWrapper or StreamingView lifecycle
- Adding new UI features or controls to the floor plan streaming panel
- Modifying MultipleView or other streaming views

## Decisions

### Decision 1: Use fixed ZStack with GeometryReader instead of conditional HStack/VStack

**Chosen**: Single `ZStack` containing both `floorPlanCanvas` and `SelectedDeviceInfoPanel` as permanent children, with `GeometryReader` to calculate frame sizes based on state.

**Why over alternatives**:
- **Alternative A (ViewThatFits)**: Doesn't solve the identity problem — still needs conditionals for different arrangements.
- **Alternative B (AnyLayout switching)**: `AnyLayout` preserves identity when switching between `HStackLayout` and `VStackLayout`, but doesn't handle the fullscreen case where canvas should hide entirely.
- **Chosen approach**: Matches the MultipleView pattern already validated in production. Uses `frame` + `alignment` + `opacity` to position views without changing view identity.

### Decision 2: Control visibility with opacity instead of conditional rendering

**Chosen**: Use `.opacity(0)` to hide views instead of `if` conditions.

**Why**: `if condition { SomeView() }` destroys the view when condition is false. `.opacity(0)` keeps the view in the tree (preserving `@StateObject` and `UIViewRepresentable` lifecycle) while making it invisible. The streaming connection stays alive regardless of display state.

### Decision 3: Compute layout values as properties on the View

**Chosen**: Add private computed properties (`canvasFrame`, `panelFrame`, `panelAlignment`, etc.) that derive layout values from current state (`selectedDeviceID`, `isStreamingFullScreen`, `orientation.isLandscape`).

**Why**: Keeps the body clean and readable. Each property encapsulates one layout concern. Easy to test visually and reason about.

## Risks / Trade-offs

- **[Layout precision]** Manual frame calculation with GeometryReader may have subtle differences from HStack/VStack automatic layout (e.g., spacing, safe area distribution). → Mitigation: Test on multiple device sizes (iPhone SE, iPhone 16 Pro Max, iPad) in both orientations.

- **[Animation behavior]** Changing from structural view transitions (if-else) to property animations (frame/opacity) may produce different animation curves. → Mitigation: Keep the same `.animation(.easeInOut(duration: 0.3))` modifiers and verify visually.

- **[Hidden view resource usage]** An `opacity(0)` streaming panel still exists in the view tree when no device is selected, unlike the current approach where it's not rendered at all. → Mitigation: The `SelectedDeviceInfoPanel` already guards its streaming content with `if let control = viewModel.viewcellControl`, so when no device is selected, the panel is lightweight (no StreamingViewWrapper created).
