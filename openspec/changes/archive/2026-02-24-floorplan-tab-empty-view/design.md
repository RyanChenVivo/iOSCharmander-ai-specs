## Context

The Floor Plan Tab (`FloorPlanTabView`) currently shows a blank screen when no floor plans are available, providing poor user experience. The app already has a well-established empty state pattern through `NoResultBackground` modifier (defined in `NoResultCover.swift`) that centers content vertically on screen.

**Current Implementation:**
- `FloorPlanTabView` displays a `ScrollView` with sites via `FloorPlanSiteList`
- `FloorPlanTabViewModel` exposes `@Published var siteFloorPlans: [SiteFloorPlans]`
- No empty state handling when `siteFloorPlans` is empty

**Reference Pattern:**
- `NoResultBackground` modifier is used across similar tabs (DeepSearchTabView, EventInsightTabView, ReSearchView)
- Pattern: Apply `.noResultBackground(show: condition, content: NoResultContent)` to the main VStack
- `NoResultContent` structure holds image and localized text

**Constraints:**
- Must not interfere with existing pull-to-refresh functionality
- Must not display during initial loading state
- Should follow existing UI patterns for consistency

## Goals / Non-Goals

**Goals:**
- Display centered empty state when no floor plans are available
- Use consistent empty state pattern (`.noResultBackground` modifier)
- Show `.iconGeneralFloorPlanSolid` icon with localized "No floor plans" text
- Only show empty state after loading completes and data is confirmed empty

**Non-Goals:**
- Adding refresh button (pull-to-refresh already exists)
- Modifying other floor plan views (detail, site views)
- Changing FloorPlanManager or data fetching logic
- Adding empty state to search results (out of scope)

## Decisions

### Decision 1: Conditional View Replacement (Simple Approach)

**Choice:** Use conditional logic in view body to show empty state view instead of content when `siteFloorPlans` is empty.

**Rationale:**
- Simplest implementation - straightforward if/else in view body
- Clear separation: either show empty state OR show content list
- Easy to understand and maintain
- No modifier complexity or overlay layering

**Implementation Pattern:**
```swift
if !viewModel.isLoading && viewModel.siteFloorPlans.isEmpty {
    // Show centered empty state view
} else {
    // Show normal ScrollView with sites
}
```

**Alternatives Considered:**
- Use `.noResultBackground()` modifier → Rejected: More complex, overlays content unnecessarily
- Create separate empty state component → Rejected: Overkill for simple centered view

### Decision 2: Inline Empty State View

**Choice:** Create empty state view inline in FloorPlanTabView using VStack with Spacers for centering.

**Rationale:**
- Self-contained, no need for additional files or modifiers
- Follows the centering pattern from `NoResultBackground` (Spacer + content + Spacer)
- Only used in this one location
- 100x100 icon with 8pt padding matches existing empty state pattern

**Pattern:**
```swift
VStack(spacing: 0) {
    Spacer(minLength: 0)
    Image(.iconGeneralFloorPlanSolid)
        .resizable()
        .frame(width: 100, height: 100)
    Text("No_floor_plans")
        .textStyle(.title2Bold)
        .padding(.top, 8)
    Spacer(minLength: 0)
}
```

### Decision 3: Add Localization Key

**Choice:** Add single localization key "No_floor_plans" to `Localizable.xcstrings` with translations for English, Traditional Chinese, and Japanese.

**Rationale:**
- Follows existing localization pattern in the project
- `Localizable.xcstrings` is the central location for all UI strings
- No pluralization needed (simple statement)
- Consistent with other empty state messages

**Alternatives Considered:**
- Hardcode strings in code → Rejected: Violates localization standards
- Use existing "No_search_results" key → Rejected: Semantically incorrect for this context

## Risks / Trade-offs

### Risk 1: Empty State Flickers During Refresh
**Risk:** Empty state might briefly show during pull-to-refresh if data fetch is fast.

**Mitigation:** Condition includes `!viewModel.isLoading` check, which is set during both initial load and refresh operations.

### Risk 2: Icon Asset Naming Inconsistency
**Risk:** Icon name `.iconGeneralFloorPlanSolid` might not exist or have different naming.

**Mitigation:** Verify asset catalog during implementation. If not found, search for similar icons or request design team input.

### Trade-off: No Search-Specific Empty State
**Decision:** This implementation only handles "no data" empty state, not "no search results" empty state.

**Rationale:** Current requirements only specify tab-level empty state. Search functionality has different UX patterns and can be added separately if needed.

## Implementation Overview

**Files to Modify:**

1. **`FloorPlanTabView.swift`**
   - Add conditional in `body`: `if !viewModel.isLoading && viewModel.siteFloorPlans.isEmpty { ... } else { ... }`
   - Empty state: VStack with Spacers wrapping centered icon and text
   - Icon: `.iconGeneralFloorPlanSolid` (100x100)
   - Text: `"No_floor_plans"` with `.title2Bold` style, 8pt top padding

2. **`Localizable.xcstrings`**
   - Add key: `"No_floor_plans"`
   - English: "No floor plans"
   - Traditional Chinese: "沒有平面圖"
   - Japanese: "フロアプランがありません"

**No Changes Required:**
- `FloorPlanTabViewModel.swift` (already exposes necessary state)
- `NoResultCover.swift` (not using modifier approach)
- FloorPlanManager or backend logic

## Migration Plan

Not applicable - this is a pure UI addition with no data migration or breaking changes.

**Rollback Strategy:** Simply revert the view modifier addition if issues occur.

## Open Questions

None - design is straightforward using existing patterns.
