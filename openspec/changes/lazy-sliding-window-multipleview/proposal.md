## Why

When a user taps a device on the View Tab, `MultipleViewModel` synchronously creates a `ViewcellComponent` for every device in the site — all on `@MainActor`. Each component includes a `ViewcellControl`, `TimelineViewModel`, multiple Tasks, and AsyncStreams. With 5,000 devices in a site, this takes 467 seconds, completely freezing the UI. The user only sees 1 device (1x1) or 4 devices (2x2) at a time; the rest exist solely to support swipe-to-switch navigation.

## What Changes

- Replace eager `[ViewcellComponent]` array with a lazy sliding window: `[DeviceItem]` (lightweight) + `[Int: ViewcellComponent]` (sparse, active only)
- Add `updateWindow()` method that computes a hot range (current page ±1 page), inflates missing components, and releases components outside the range
- Add `inflateComponent(at:)` and `releaseComponent(at:)` for per-component lifecycle management
- Extract per-component observer setup into `startObservingViewcellControl(at:)` and `startObservingTimeline(at:)` for incremental use
- Migrate all 24 references to `viewcellcomponents` in `MultipleViewModel` to use the new data structures
- `.customizedView` and `.device` cases keep eager init (small bounded N) — sliding window applies to `.site` case only

## Capabilities

### New Capabilities

- `multipleview-sliding-window`: Lazy sliding window initialization for MultipleViewModel that only materializes ViewcellComponents for the current page ±1 page, replacing eager full-site initialization

### Modified Capabilities

## Impact

- `MultipleViewModel.swift` — primary change target, all 24 `viewcellcomponents` references migrated
- No changes to `ViewcellComponent`, `ViewcellControl`, `TimelineViewModel`, `MultipleView`, or `MultipleViewStreamingView`
- `MultipleViewGridItem` already handles nil components (shows `ProductLogo()` placeholder) — no view changes needed
- Zero API or dependency changes
- Init time: 467s → <1s for 5000-device sites
- Resource usage: ~25,000 Tasks + 10,000 AsyncStreams → ~15 Tasks + 6 AsyncStreams (1x1 layout)
