## 1. Add Sliding Window Data Structures

- [ ] 1.1 Replace `viewcellcomponents: [ViewcellComponent]` with `allDevices: [DeviceItem]` + `activeComponents: [Int: ViewcellComponent]` in MultipleViewModel property declarations. Update `currentViewcellComponent` computed property to use `activeComponents[currentViewcellIndex]`.
- [ ] 1.2 Add `hotRange() -> ClosedRange<Int>?` method that computes `currentPage * layoutCount ± layoutCount`, clamped to `allDevices` bounds. Returns nil when `allDevices` is empty.
- [ ] 1.3 Add `updateWindow()` method that computes hot range, inflates missing components, and releases components outside the range.
- [ ] 1.4 Add `inflateComponent(at:)` that builds `ViewcellComponent.makeViewItemSite(device:)`, stores in `activeComponents`, and starts observer tasks.
- [ ] 1.5 Add `releaseComponent(at:)` that cancels observer tasks, stops streaming, and removes from `activeComponents`.
- [ ] 1.6 Add `startObservingViewcellControl(at:component:)` and `startObservingTimeline(at:component:)` extracted from existing observer methods for per-component incremental use.

## 2. Migrate Init Cases

- [ ] 2.1 Migrate `.site` init case: store devices in `allDevices`, call `changeLayout` then `updateWindow()`. Remove eager `devices.map { ViewcellComponent.makeViewItemSite }`. Keep `=> built` log using `activeComponents.count`.
- [ ] 2.2 Migrate `.device` init case: store single device in `allDevices`, create component directly in `activeComponents[0]`.
- [ ] 2.3 Migrate `.customizedView` init case: store devices in `allDevices`, eagerly create all components in `activeComponents` with cell association preserved.
- [ ] 2.4 Guard observer calls in init: skip `observeViewcellControlStreamingDates()` and `observeTimelineViewModelStates()` for `.site` case (handled by `inflateComponent`), keep for `.device` and `.customizedView`.

## 3. Migrate Observer Methods

- [ ] 3.1 Rewrite `observeViewcellControlStreamingDates()` to iterate `activeComponents` instead of `viewcellcomponents.indices`.
- [ ] 3.2 Rewrite `observeTimelineViewModelStates()` to iterate `activeComponents` instead of `viewcellcomponents.indices`.

## 4. Migrate Accessors and Streaming Control

- [ ] 4.1 Migrate `getViewcellControl(by:)` and `getTimelineViewModel(by:)` to use `activeComponents[cellIndex]`.
- [ ] 4.2 Migrate `getCurrentPTZController()`, `getCurrentRemoteAccessControlViewModel()`, `getCurrentInstantAudioMessageViewModel()` to use `activeComponents[currentViewcellIndex]`.
- [ ] 4.3 Migrate `stopAllStreaming()` to iterate `activeComponents.values`.
- [ ] 4.4 Migrate `controlViewcellControls()` to iterate `activeComponents` instead of `viewcellcomponents.enumerated()`.

## 5. Migrate View Control and Layout

- [ ] 5.1 Migrate `pageDidChange()`: replace `viewcellcomponents.count` with `allDevices.count`, add `updateWindow()` call before `controlViewcellControls()`.
- [ ] 5.2 Migrate `changeFocus(to:)`: replace `viewcellcomponents.count` guard and `viewcellcomponents[safe:]` access with `allDevices.count` and `activeComponents[]`.
- [ ] 5.3 Migrate `tapStreamingViewCell(index:)` and `doubleTapStreamingViewCell(index:)`: replace `viewcellcomponents.count` guard with `allDevices.count`.
- [ ] 5.4 Migrate `changeLayout(to:)`: use `allDevices.count` for `totalPage` calculation, add `updateWindow()` call at end.

## 6. Cleanup

- [ ] 6.1 Verify zero remaining references to `viewcellcomponents` in MultipleViewModel.swift.
- [ ] 6.2 Remove diagnostic `=> observeViewcellControlStreamingDates` and `=> observeTimelineViewModelStates` log lines (added during investigation).
- [ ] 6.3 Build and verify no compiler errors.

## 7. Smoke Test

- [ ] 7.1 Test with 5000-device site: tap device, verify streaming opens in <2s, check log shows `=> built 3 ViewcellComponents`.
- [ ] 7.2 Test swipe navigation: swipe left/right, verify streaming loads on new device.
- [ ] 7.3 Test layout switch: 1x1→2x2 and back, verify devices render correctly.
- [ ] 7.4 Test small site (<12 devices): verify identical behavior to before.
- [ ] 7.5 Test customized view: verify all cells render correctly with eager init.
