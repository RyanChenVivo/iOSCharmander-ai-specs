## 1. TreeView Optional ExpandedState

- [x] 1.1 Change TreeView's `expandedState` binding from `Binding<ExpandedState<Item.ID>>` to `Binding<ExpandedState<Item.ID>?>`. Update `buildFlatList` to treat nil as all-expanded (always recurse into children).
- [x] 1.2 Update SiteTreeRow to accept optional `expandedState` binding. When nil, omit the chevron toggle button and its spacer entirely — row starts directly with the site icon.
- [x] 1.3 Update SearchableTreeView to handle nil `expandedState`: skip save/restore of expand state during search; only filter items with ancestor preservation; on search clear, restore unfiltered items without expand state manipulation.
- [x] 1.4 Verify existing callers of TreeView that pass non-nil expandedState still compile and behave identically.

## 2. MoveToSiteView Layout Restructure

- [x] 2.1 Pass nil expandedState from MoveToSiteView to SearchableTreeView. Remove the `@State expandedState` property from the view.
- [x] 2.2 Add section header HStack above the tree: "Select a destination" (left, secondary text) and "Create site or area" (right, tappable link, gated by `canCreateSite()`). Remove the old bottom "Create site" ghost button.
- [x] 2.3 Restructure MoveToSiteView body as VStack: scrollable tree content on top, fixed "Move device" button at bottom (Move flow only). Hide bottom button in Add flow.
- [x] 2.4 Implement "Move device" button states: disabled (muted) when no site selected or selected site equals current site; enabled (filled) when a different site is selected.

## 3. Current Site Indicator

- [x] 3.1 Add `currentSiteID: String?` property to MoveToSiteViewModel, initialized from `device.siteID` at construction time (captures the original site before any move). Set to nil for Add flow.
- [x] 3.2 Add `isCurrent: Bool` parameter to SiteTreeRow. Trailing area logic: show "Current" label (secondary style) if isCurrent, else show checkmark if isSelected, else nothing.
- [x] 3.3 Wire MoveToSiteView to pass `isCurrent: site.id == viewModel.currentSiteID` to each SiteTreeRow.

## 4. Search Text Highlighting

- [x] 4.1 Add `highlightKeyword: String?` parameter to SiteTreeRow.
- [x] 4.2 Implement AttributedString-based highlighting: when highlightKeyword is non-nil, build AttributedString from site name, find all case-insensitive occurrences, apply `.backgroundColor(.accentColor)` and `.foregroundColor(.white)` to matched ranges. Render with `Text(attributedString)`.
- [x] 4.3 Pass current search keyword from MoveToSiteView through to SiteTreeRow's highlightKeyword parameter.

## 5. Move Device Confirmation Page

- [x] 5.1 Create `MoveDeviceConfirmationView` with layout: centered orange warning triangle icon, "Move this device" title, subtitle with site name, orange "ATTENTION!" label, info card with permission warning text, blue full-width "Move Device" button, "Cancel" text button.
- [x] 5.2 Add `confirmMoveSite: SiteItem?` published property to MoveToSiteViewModel. When the bottom "Move device" button is tapped, set this property to trigger the confirmation sheet.
- [x] 5.3 Present MoveDeviceConfirmationView as a `.sheet` from MoveToSiteView, bound to `viewModel.confirmMoveSite`.
- [x] 5.4 Wire confirm action: call `deviceManager.updateDevice(device, siteID:)`, dismiss all sheets on success, show error alert on failure. Wire cancel action: dismiss sheet, preserve selection.
- [x] 5.5 Remove the old `AlertItem.checkToMoveDevice` usage from MoveToSiteViewModel's `tapSiteRow` method for the Move flow.

## 6. Localization

- [x] 6.1 Add localized strings: "Select a destination", "Create site or area", "Current", "Move this device", "The device will be moved to \"%@\".", "ATTENTION!", "Moving device may change their permissions. Some functions may become unavailable.", "Move Device" (button), "Cancel".

## 7. Figma Design Alignment — SiteTreeRow Depth-Based Rendering

- [x] 7.1 Refactor SiteTreeRow to support two rendering modes based on `expandedState`:
  - **Flat mode** (`expandedState == nil`): depth 0 shows 24px location pin icon (`iconGeneralGroupSolid`) + name; depth > 0 shows `└` grey prefix + name. Row height 56px. SiteTreeRow controls its own horizontal padding (`px-16` for depth 0, `pl-56 pr-16` for depth 1, `pl = 56 + (depth-1)*24` for depth 2+).
  - **Expand mode** (`expandedState != nil`): unchanged from current behavior (chevron + 28px icon + name, row height 44px, TreeView controls padding).
- [x] 7.2 Update TreeView to accept an optional `depthIndent: CGFloat?` parameter (default 16). When `depthIndent` is 0 or nil-equivalent, skip the `.padding(.leading, CGFloat(depth) * depthIndent)` so the row content controls its own indentation. Thread this parameter through SearchableTreeView.
- [x] 7.3 Pass `depthIndent: 0` from MoveToSiteView to SearchableTreeView so SiteTreeRow handles indentation internally in flat mode.

## 8. Figma Design Alignment — Site Group Dividers

- [x] 8.1 Add `colorOutline14` top divider on depth == 0 rows in SiteTreeRow's flatContent. Each root site row gets a `Divider().overlay(.colorOutline14)` at the top of a VStack wrapper, visually separating site groups.

## 9. Figma Design Alignment — Button & Text Style Fixes

- [x] 9.1 Change "Move device" button style from `.solidLargePrimary()` to `.ghostLarge(.secondary)` to match Figma (white outline + white text).
- [x] 9.2 Change "Create site or area" text style from `.callout` to `.title3Semibold` to match Figma (17px semibold white).

## 10. ParentSitePickerSheet — Search & Highlight

- [x] 10.1 Add `@State private var keyword = ""` to `ParentSitePickerSheet`. Apply `.customSearchable(text: $keyword, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search_site")` to provide a search bar.
- [x] 10.2 Pass `highlightKeyword: keyword.isEmpty ? nil : keyword` to each `SiteTreeRow` inside `ParentSitePickerSheet`, enabling search text highlighting with `HighlightedText`.

## 11. SitePickerSheet — Migrate to SheetManager

- [x] 11.1 Rename `ParentSitePickerSheet` to `SitePickerSheet`. Change `@Binding var selectedParent` to `@Binding var selectedSite`. Add `let navigationTitle: LocalizedStringKey` parameter so callers can customize the title.
- [x] 11.2 Add `showSitePicker(selectedSite: Binding<SiteItem?>, navigationTitle:)` convenience method to `SheetManager`, using `showViewSheet` to present `SitePickerSheet`. Default title is `"Parent_site"`.
- [x] 11.3 In `SiteInformationView`, replace `.sheet(isPresented: $showParentPicker)` and `@State showParentPicker` with a call to `SheetManager.shared.showSitePicker(selectedSite: $viewModel.selectedParent)`.
- [x] 11.4 In `SitePickerSheet`, use `ToolbarItemCancel()` (SheetManager now owns the sheet, so dismiss correctly closes only this layer). Removed `@Environment(\.dismiss)`.
- [x] 11.5 In `SitePickerSheet`, site selection calls `SheetManager.shared.dismiss()` to stay consistent with the SheetManager dismiss flow.
