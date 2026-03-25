## Context

`MultipleViewModel` currently creates a `ViewcellComponent` for every device in a site during `init`. Each component includes a `ViewcellControl` (~15 dependency injections, Tasks, AsyncStreams), a `TimelineViewModel`, and conditional sub-viewmodels (PTZ, network speaker, door control). With 5,000 devices, this takes 467 seconds on `@MainActor`, freezing the UI completely. The user only sees 1–4 devices at a time.

The existing `MultipleViewGridItem` already handles nil components gracefully (falls through to `ProductLogo()` placeholder), and `controlViewcellControls()` already only starts streaming for the current page. The infrastructure for partial rendering exists — only the initialization is eager.

## Goals / Non-Goals

**Goals:**
- Reduce MultipleView init time from 467s to <2s for 5000-device sites
- Maintain swipe-to-switch navigation between devices in a site
- Keep `.device` and `.customizedView` cases unchanged
- Zero changes to View layer, ViewcellComponent, ViewcellControl, or TimelineViewModel

**Non-Goals:**
- Optimizing individual ViewcellComponent creation time (~93ms each)
- Adding debounce for rapid swiping (not needed at ~93ms per inflate)
- Background/off-MainActor initialization (adds complexity, not needed with small window)
- Prefetching beyond ±1 page

## Decisions

### Decision 1: Sliding window with ±1 page buffer

**Choice:** Hot range = current page ±1 page (3 components for 1x1, 12 for 2x2).

**Alternatives considered:**
- ±0 (current page only): Swipe would always show placeholder briefly. Rejected — poor UX.
- ±2 pages: Marginal benefit, doubles init cost for 2x2 (24 vs 12 components).
- Fixed count (e.g., always 8): Doesn't adapt to layout. 8 is too many for 1x1, too few for 2x2.

**Rationale:** ±1 page is the minimum that ensures the next swipe target is pre-built. Single inflate (~93ms) happens during swipe animation, invisible to user.

### Decision 2: `[Int: ViewcellComponent]` dictionary instead of sparse array

**Choice:** Use `activeComponents: [Int: ViewcellComponent]` keyed by index into `allDevices`.

**Alternatives considered:**
- Sparse array with nil slots: Requires `[ViewcellComponent?]` of size N, wastes memory for 5000 nil entries.
- Separate window array with offset tracking: Complex index math, error-prone.

**Rationale:** Dictionary gives O(1) lookup by index, natural nil semantics (missing key = not inflated), and only stores active components.

### Decision 3: Uniform `updateWindow()` for both swipe and layout change

**Choice:** Same `updateWindow()` logic for page changes and layout switches. No priority loading.

**Alternatives considered:**
- Priority loading for layout switch (inflate current page first, buffer in background): Adds complexity with Task scheduling. 1x1→2x2 inflates up to 9 components (~0.84s), partially masked by layout animation.

**Rationale:** Simpler, consistent code path. Layout switching is infrequent. If 0.84s becomes a problem, priority loading can be added later without architectural changes.

### Decision 4: `.site` case only — `.device` and `.customizedView` keep eager init

**Choice:** Sliding window applies only to `.site` init case.

**Rationale:** `.device` always has 1 component. `.customizedView` has a small user-defined count. Neither has the scaling problem. Applying sliding window to them adds complexity with no benefit.

### Decision 5: `inflateComponent` sets up observers immediately

**Choice:** `inflateComponent(at:)` calls `startObservingViewcellControl` and `startObservingTimeline` inline, rather than deferring to a batch observer setup.

**Rationale:** Incremental observer setup is needed for the sliding window — new components are inflated one at a time during swipe. Batch setup (`observeViewcellControlStreamingDates`) is only used for `.device` and `.customizedView` cases during init.

## Risks / Trade-offs

- **[~93ms swipe latency]** → Each swipe inflates 1 component on MainActor. Masked by swipe animation. Monitor with existing `=> built` log. If problematic, can move inflate to background Task.
- **[~0.84s layout switch 1x1→2x2]** → Inflates up to 9 components. Partially masked by animation. Can add priority loading later if needed.
- **[Accessor migration risk]** → 24 references to `viewcellcomponents` must be migrated. Mitigated by type change from `[ViewcellComponent]` to `[Int: ViewcellComponent]` — compiler catches all mismatches.
- **[deinit cannot call async]** → Swift 6 `deinit` is non-isolated. Cannot call `stopStreaming()`. Mitigated by: `tapCloseButton()` already calls `stopAllStreaming()` before dismiss, and ARC handles object deallocation.
