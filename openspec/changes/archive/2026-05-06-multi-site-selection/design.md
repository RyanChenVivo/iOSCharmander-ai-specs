## Context

`SiteSelectionView` was introduced in the `move-to-ux-redesign` change as a single-select site picker for the Add Device flow. It uses `SearchableTreeView` to render the site hierarchy with search and keyword highlighting. The Message tab filters (Access Control, Smart Sensor) need multi-select site filtering but currently use `MultipleSelectionView` — a flat-list picker that doesn't show tree hierarchy. The Figma design specifies a tree-based multi-select picker with checkboxes, matching the same visual structure as the existing single-select picker.

**Current state:**
- `SiteSelectionView` accepts `Binding<DeviceItem>`, renders tree, supports single selection with checkmark indicator
- `MultipleSelectionView` is a generic flat-list multi-select component used for event types and sites
- `SiteTreeRow` renders each tree row with depth indentation, `└` connector, site icon, and trailing checkmark/current indicator
- `ToggleAllSectionHeader` provides "N/M selected" + "Select all / Deselect all" toggle UI
- `AccessControlMessageSearchView` and `SmartSensorMessageSearchView` use `MultipleSelectionView` for site filter with `[SiteItem]` binding

**Prerequisite:** `move-to-ux-redesign` change (SiteSelectionView, SearchableTreeViewModel, SiteTreeRow, HighlightedText)

## Goals / Non-Goals

**Goals:**
- Extend `SiteSelectionView` to support both single and multi selection via a mode enum
- Provide tree-based site rendering for Message tab filters, matching Figma design
- Reuse existing components: `SearchableTreeView`, `ToggleAllSectionHeader`, `HighlightedText`
- Maintain backward compatibility for Add Device flow callers

**Non-Goals:**
- Modifying `MultipleSelectionView` (it continues serving event type and other flat-list multi-select)
- Adding multi-select to `MoveToSiteView` (move flow remains single-select with different UX)
- Changing site data model or API

## Decisions

### Decision 1: Separate inits with internal SiteSelectionMode enum

Public API exposes two distinct initializers — callers never see the mode enum:

```swift
// Single mode (Add Device flow)
SiteSelectionView(selectedSiteID: Binding<String?>)

// Multi mode (Message filter flow)
SiteSelectionView(selectedSites: Binding<[SiteItem]>, items: [SiteItem], allowEmptySelection: Bool = false)
```

Internally, both inits construct a `SiteSelectionMode` enum to drive view/viewModel branching:

```swift
// Internal only
enum SiteSelectionMode {
    case single(Binding<String?>)
    case multi(Binding<[SiteItem]>, items: [SiteItem], allowEmptySelection: Bool)
}
```

**Why:** Each init only exposes parameters relevant to its use case — impossible to create invalid combinations (e.g., single mode with `items`, or multi mode without `items`). Callers get clear, type-safe signatures without understanding an internal abstraction. Follows SwiftUI convention of multiple inits on a single View type.

**Alternative considered:** Single init with `SiteSelectionMode` enum as public parameter. Rejected because it exposes internal branching logic to callers and allows nonsensical parameter combinations.

### Decision 2: Separate SiteCheckboxTreeRow for multi mode

Create `SiteCheckboxTreeRow` that shares tree layout logic (depth indentation, `└` connector, icon at depth 0, HighlightedText) with `SiteTreeRow`, but renders a checkbox icon (checked/unchecked circle) instead of checkmark/current indicator.

**Why:** The trailing indicator logic is fundamentally different — `SiteTreeRow` has conditional display (checkmark OR "Current" OR nothing) while checkbox always shows (checked or unchecked). Trying to unify these with flags would complicate both. The tree layout (indentation, connector, icon) can be shared via a common internal structure or ViewBuilder.

**Shared layout approach:** Extract the row structure (HStack with depth-based padding, `└` text, HighlightedText) into a reusable internal helper that both row types call, passing their own trailing content.

### Decision 3: ViewModel mode-aware state management

`SiteSelectionViewModel` accepts the internal `SiteSelectionMode` enum and holds both state types, using only the active one:
- `selectedSiteID: String?` — active in single mode
- `selectedSites: [SiteItem]` — active in multi mode
- `mode: SiteSelectionMode` stored internally to determine behavior

`tapSiteRow(_:)` becomes mode-aware:
- Single: sets `selectedSiteID = site.id`
- Multi: toggles site in/out of `selectedSites` array

`canSave: Bool`:
- Single: `selectedSiteID != nil`
- Multi: `!selectedSites.isEmpty || allowEmptySelection`

### Decision 4: View conditional rendering by mode

`SiteSelectionView` body uses mode to choose:
- **Control bar:** Single → "Create site or area" button; Multi → `ToggleAllSectionHeader`
- **Row component:** Single → `SiteTreeRow`; Multi → `SiteCheckboxTreeRow`
- **Context menu:** Single → Site information / Delete; Multi → none
- **Save action:** Single → apply siteID to binding; Multi → apply `[SiteItem]` to binding

### Decision 5: Reuse ToggleAllSectionHeader as-is

`ToggleAllSectionHeader` accepts `Binding<[R]>` and `items: [R]`. In multi mode:
- `selected` binds to `$viewModel.selectedSites`
- `items` is the site list provided to the view (either caller-provided or `deviceManager.sites`)

No modification needed — the component already handles count display, "Select all" / "Deselect all" toggle, and the "No items selected yet" empty state.

### Decision 6: Data source determined by init (not a shared parameter)

Each init has its own data source strategy — no shared optional parameter:
- **Single init** (`selectedSiteID:`): always uses `deviceManager.sites` with `onChange` listener for live updates. This supports createSite — new sites appear immediately.
- **Multi init** (`selectedSites:items:`): always uses the caller-provided `items` array as a static snapshot. No createSite button exists in multi mode, so live updates are unnecessary.

**Why:** Single mode needs live data because it has createSite. Multi mode needs caller-filtered data because Message tab filters show feature-specific subsets (`featureProvider.accessibleSitesFor...()`). These are mutually exclusive scenarios — combining them into one optional parameter would create ambiguity and invalid states.

## Risks / Trade-offs

**ViewModel holds unused state for the inactive mode** → Acceptable trade-off for simplicity. The unused `String?` or `[SiteItem]` is negligible memory. Alternative (protocol-based polymorphism) adds indirection without meaningful benefit.

**SiteCheckboxTreeRow duplicates layout code from SiteTreeRow** → Mitigated by extracting shared tree layout into a common helper. If extraction proves awkward, acceptable duplication for 2 row types with diverging futures.

**Callers of current SiteSelectionView must update to new init** → Only 2 call sites (AddDeviceByMacView, AddVSSView). Small, mechanical change.

**`allowEmptySelection` parameter in enum associated value** → Slightly unusual Swift pattern. Clear at call site: `.multi($binding, allowEmptySelection: true)`. Alternative: separate parameter on init — rejected to keep the mode self-contained.
