## 1. Restructure FloorPlanDetailView Body

- [x] 1.1 Replace the `if orientation.isLandscape { HStack } else { VStack }` and `if selectedDeviceID != nil && isStreamingFullScreen` conditional branches with a single fixed `ZStack` containing both `floorPlanCanvas` and `SelectedDeviceInfoPanel` as permanent children
- [x] 1.2 Add computed properties for layout calculations: canvas frame (width/height), panel frame (width/height), canvas alignment, panel alignment, canvas opacity, panel opacity — all derived from `viewModel.selectedDeviceID`, `viewModel.isStreamingFullScreen`, and `orientation.isLandscape`
- [x] 1.3 Apply `.frame()` and `.opacity()` modifiers to `floorPlanCanvas` and `SelectedDeviceInfoPanel` using the computed properties
- [x] 1.4 Preserve bottom safe area padding logic: portrait gets `safeArea().bottom`, landscape gets 0

## 2. Animation and Transitions

- [x] 2.1 Add `.animation(.easeInOut(duration: 0.3))` for `selectedDeviceID`, `isStreamingFullScreen`, and `orientation.isLandscape` value changes
- [x] 2.2 Remove the `matchedGeometryEffect` namespace (`@Namespace private var streamingNamespace`) and its usage in `SelectedDeviceInfoPanel` since the panel is now a single persistent instance — matched geometry is no longer needed for cross-branch transitions

## 3. Verification

- [x] 3.1 Build the project and verify no compilation errors
- [x] 3.2 Test: select device in portrait → rotate to landscape → streaming stays connected (no reconnect)
- [x] 3.3 Test: select device → toggle fullscreen → toggle back to split → streaming stays connected
- [x] 3.4 Test: fullscreen mode → rotate device → streaming stays connected
- [x] 3.5 Test: no device selected → rotate → floor plan displays correctly in both orientations
- [x] 3.6 Test: layout is visually correct — 50/50 split in both orientations, fullscreen fills entire screen
