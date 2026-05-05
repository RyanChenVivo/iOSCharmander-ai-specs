## Context

MoveToSiteView currently uses `SearchableTreeView` → `TreeView` with expand/collapse chevrons, an alert-based move confirmation, and no visual indicator for the device's current site. The new UX design requires six changes: always-expanded tree, section header with "Create site or area" link, "Current" label, search text highlighting, full-page move confirmation, and a bottom-fixed action button.

Key files in scope:
- `TreeView.swift` — generic tree component with `ExpandedState` binding
- `SearchableTreeView` — search wrapper with debounce and ancestor preservation
- `SiteTreeRow.swift` — individual row rendering (chevron, icon, name, checkmark)
- `MoveToSiteView.swift` — the container view with search bar and site list
- `MoveToSiteViewModel.swift` — selection logic, alert-based move confirmation
- `AlertItem.swift` — `checkToMoveDevice` alert factory

## Goals / Non-Goals

**Goals:**
- Align MoveToSiteView with new UX design mockups
- Keep TreeView generic — site-specific behavior stays in MoveToSiteView/SiteTreeRow
- Minimize blast radius — reuse existing protocols and patterns where possible

**Non-Goals:**
- Changing TreeView's generic API for other consumers (TreeView still supports expand/collapse for future use cases)
- Modifying site CRUD logic (create, edit, delete flows unchanged)
- Changing the Add Device flow's selection-then-dismiss behavior
- Multi-site picker (the checkbox UI in the mockup is illustrative only, confirmed by user)

## Decisions

### Decision 1: Optional `ExpandedState` — nil means always-expanded

Make TreeView's `expandedState` binding optional. When nil, all nodes are rendered as expanded with no chevron UI. This cleanly separates "collapsible tree" from "always-expanded tree" without extra flags.

**Why over `expandAll` + hiding chevrons:** Passing an `ExpandedState` that is always fully expanded is semantically misleading — it carries expand/collapse machinery that is never used. An optional binding makes the intent explicit: nil = no expand/collapse concept at all.

**Implementation:**
- `TreeView`: Change `@Binding var expandedState: ExpandedState<Item.ID>` to `@Binding var expandedState: ExpandedState<Item.ID>?`. In `buildFlatList`, when `expandedState == nil`, treat every node with children as expanded (always recurse into children).
- `SiteTreeRow`: When `expandedState == nil`, omit the chevron toggle area entirely — no chevron button, no spacer. The row starts directly with the site icon.
- `SearchableTreeView`: When `expandedState == nil`, skip save/restore of expand state during search. Search only filters items (with ancestor preservation) — no need to auto-expand ancestors since everything is already visible. On search clear, just restore unfiltered items.
- `MoveToSiteView`: Pass `expandedState: .constant(nil)` to SearchableTreeView. No `ExpandedState` property needed in the view at all.

### Decision 2: Section header as a view above the tree, not inside the tree

The "Select a destination" / "Create site or area" row is a static section header, not a tree node. It lives in MoveToSiteView's body above the `SearchableTreeView`.

**Why over embedding in TreeView:** It's not hierarchical data — it's a layout concern. Putting it in MoveToSiteView keeps TreeView generic and the header always visible (not scrolling away with the tree content). Based on the mockup, it appears to scroll with content, so it will sit inside the ScrollView but above the tree.

**Implementation:**
- An `HStack` with "Select a destination" (left, secondary text) and "Create site or area" (right, tappable link) placed above `SearchableTreeView` inside the scrollable area.
- Replaces the current bottom "Create site" ghost button.

### Decision 3: "Current" label passed via SiteTreeRow parameter

SiteTreeRow gets a new `isCurrent: Bool` parameter. When true, it shows "Current" text (secondary style) on the trailing side, replacing the checkmark position.

**Why over a separate overlay or modifier:** The "Current" label is row-level UI that coexists with the selection checkmark (a site can be both "current" and "selected" or just "current"). Based on the mockup, "Current" appears on the right side where the checkmark would be — but on a different row. So the trailing area shows either "Current" text, a checkmark, or nothing.

**Implementation:**
- `MoveToSiteViewModel` exposes `currentSiteID: String?` (the device's current `siteID` before any move).
- `SiteTreeRow` trailing: if `isCurrent` → show "Current" label; else if `isSelected` → show checkmark; else → nothing.
- In Move flow, the current site row is tappable but selecting it is a no-op (already there). In Add flow, `currentSiteID` is nil (no device yet).

### Decision 4: Search text highlighting via `AttributedString` in SiteTreeRow

When a search keyword is active, SiteTreeRow renders the site name as an `AttributedString` with matching subranges highlighted (blue background, similar to the mockup).

**Why over overlay-based approach:** `AttributedString` is the native SwiftUI way to style text ranges. It handles RTL, dynamic type, and multi-match scenarios correctly. An overlay approach would require measuring text positions, which is fragile.

**Implementation:**
- `SiteTreeRow` accepts an optional `highlightKeyword: String?` parameter.
- When non-nil, build an `AttributedString` from the site name, find all case-insensitive occurrences of the keyword, and apply `.backgroundColor(.accentColor)` + `.foregroundColor(.white)` to matched ranges.
- When nil or empty, render plain `Text` as today.
- `MoveToSiteView` passes the current search keyword down to each `SiteTreeRow`.

### Decision 5: Full-page move confirmation as a pushed view

Replace the `AlertItem.checkToMoveDevice` alert with a dedicated `MoveDeviceConfirmationView` that is presented via navigation push or sheet.

**Why over keeping alert:** The mockup shows a full-page design with a warning icon, "Move this device" title, descriptive text, orange "ATTENTION!" section, blue "Move Device" button, and "Cancel" text button. This cannot be achieved with a system alert.

**Implementation:**
- New `MoveDeviceConfirmationView` that takes `siteName: String`, `onConfirm: () async -> Void`, and `onCancel: () -> Void`.
- Layout: centered warning icon (triangle exclamation), "Move this device" title, subtitle "The device will be moved to \"{siteName}\".", orange "ATTENTION!" label, info card with permission warning text, blue full-width "Move Device" button, "Cancel" text button below.
- Presented as a `.sheet` from MoveToSiteView (or fullScreenCover depending on mockup intent — the mockup appears to be a sheet/pushed view).
- `MoveToSiteViewModel.tapSiteRow` for `.move` source now sets a published property to trigger this view instead of calling `alertControl.showAlert`.

### Decision 6: Bottom-fixed "Move device" button in Move flow

In the `.move` flow, a "Move device" button is pinned to the bottom of the screen (outside the scroll area). It is disabled until a site is selected, and enabled with filled style when a site is selected.

**Why this layout:** The mockup clearly shows the button fixed at the bottom, not scrolling with content. This is a common iOS pattern for action confirmation.

**Implementation:**
- `MoveToSiteView` body becomes a `VStack` with the scrollable tree content on top and the "Move device" button at the bottom (outside `ScrollView`).
- Button disabled when `viewModel.selectedSite == nil` or when selected site equals current site.
- Tapping the button navigates to `MoveDeviceConfirmationView`.
- In `.add` flow, this bottom button is hidden — site selection still immediately dismisses as today.

### Decision 7: Separate SiteSelectionView for Add Device flow

Create a new `SiteSelectionView` + `SiteSelectionViewModel` instead of continuing to reuse `MoveToSiteView` with `source: .add`. The Add Device site picker has its own UX: navigation title "Site", Cancel/Save toolbar buttons, and no move-specific UI.

**Why over keeping shared MoveToSiteView:** The two flows are diverging — Move needs "Current" badge, "Select a destination", "Move device" button, confirmation page; Add Device needs Cancel/Save toolbar with deferred confirmation. Keeping them shared means every new requirement adds another `if source == .add` branch. Splitting now prevents that complexity from growing.

**Implementation:**
- New `SiteSelectionView` in `View/SideMenu/AddDevice/`, presented via NavigationLink push from `AddDeviceByMacView` and `AddVSSView` (same as today).
- Accepts `Binding<DeviceItem>` to update `device.siteID` on Save.
- Navigation title: "Site". Leading toolbar: Cancel (pops back without saving). Trailing toolbar: Save (pops back with selected site applied to binding). Save disabled when no site selected.
- Reuses `SearchableTreeView`, `SiteTreeRow`, `HighlightedText` for the tree list. No "Current" badge (new device has no current site). No "Move device" bottom button.
- "Create site or area" button (gated by `canCreateSite()`) navigates to `SiteInformationView`.
- Search bar with keyword highlighting, same as MoveToSiteView.
- `SiteSelectionViewModel`: simpler than `MoveToSiteViewModel` — holds `selectedSiteID: String?` (local state, not applied to binding until Save), `pushCreateSiteSheet`, `siteForSiteInformation`. No `source`, no `currentSiteID`, no `confirmMoveSite`.

### Decision 8: Clean up MoveToSiteView to move-only

After SiteSelectionView is created, remove all `.add` source handling from MoveToSiteView and MoveToSiteViewModel:
- Remove `source` property and the `switch viewModel.source` in the view body.
- MoveToSiteView always wraps in NavigationStack with ToolbarItemCancel (was only for `.move`).
- Remove `selectSite` function's `.add` case.
- MoveToSiteViewModel's `init` no longer needs `source` parameter; `currentSiteID` is always derived from `device.siteID`.
- Update `SheetManager.swift` call site to remove `source: .move` argument.
- If `AnalyticsEvent.AddDeviceGroupSource.add` has no remaining callers, remove the case (or keep if analytics still needs it for SiteSelectionView).

## Risks / Trade-offs

**Always-expanded performance with large site trees** → The current TreeView only renders expanded branches. With all nodes expanded, the flat list includes every node. `LazyVStack` mitigates this (only visible rows rendered), but the flat list construction walks all nodes. For typical site trees (hundreds of nodes), this is negligible. If a customer has 10K+ sites, we may need to revisit.

**AttributedString highlighting on older iOS** → `AttributedString` is available from iOS 15+. Our minimum is iOS 18, so no compatibility risk.

**SiteTreeRow parameter growth** → Adding `showExpandChevron`, `isCurrent`, `highlightKeyword` increases SiteTreeRow's parameter count. This is acceptable for a domain-specific row component. If it grows further, consider a configuration struct.

**Move confirmation as sheet vs push** → The mockup looks like a full-screen presentation. Using `.sheet` keeps it modal and prevents back-navigation confusion. If UX prefers a push, the view works either way since it's self-contained.
