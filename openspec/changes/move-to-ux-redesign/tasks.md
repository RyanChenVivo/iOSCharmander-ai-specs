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

## 12. SiteSelectionView — New Page for Add Device Flow

- [x] 12.1 Create `SiteSelectionViewModel` (`@Observable`, `@MainActor`): holds `selectedSiteID: String?` (local state, initialized from `device.siteID`), `pushCreateSiteSheet: Bool`, `siteForSiteInformation: SiteItem?`. Dependencies: `deviceManager`, `appManager`, `analyticsService`, `featureProvider`. Computed `selectedSite: SiteItem?` via `deviceManager.findSite(id:)`. Method `onSiteDeleted(_:)` clears selection if deleted site matches.
- [x] 12.2 Create `SiteSelectionView` in `View/SideMenu/AddDevice/`. Accepts `Binding<DeviceItem>`. Navigation title "Site". Leading toolbar: Cancel button (dismiss without saving). Trailing toolbar: Save button (apply `selectedSiteID` to `device.siteID`, then dismiss). Save disabled when `selectedSiteID` is nil.
- [x] 12.3 Wire site tree: reuse `SearchableTreeView` with `expandedState: .constant(nil)` and `depthIndent: 0`. Render `SiteTreeRow` for each site with `isSelected`, `isCurrent: false`, `highlightKeyword`. Tap selects site locally (updates `selectedSiteID`), does NOT dismiss.
- [x] 12.4 Add "Create site or area" button above tree (gated by `canCreateSite()`), wired to `pushCreateSiteSheet`. NavigationDestination to `SiteInformationView(site: nil)`.
- [x] 12.5 Add search bar via `.customSearchable(text: $keyword, …, prompt: "Search_site")`.
- [x] 12.6 Add context menu on site rows: "Site information" (gated by `canEditSite()`) and "Delete" (gated by `canDelete(for:)`), same pattern as MoveToSiteView.
- [x] 12.7 Add empty state: when `deviceManager.sites.isEmpty`, show `NoResultContentView`.
- [x] 12.8 Add dividers between site groups: depth 0 rows (except first) get `Divider.outline14` above.

## 13. Switch AddDevice to SiteSelectionView

- [x] 13.1 In `AddDeviceByMacView`, change NavigationLink destination from `MoveToSiteView(device:, source: .add)` to `SiteSelectionView(device:)`.
- [x] 13.2 In `AddVSSView`, change NavigationLink destination from `MoveToSiteView(device:, source: .add)` to `SiteSelectionView(device:)`.

## 14. Clean Up MoveToSiteView — Remove .add Source

- [x] 14.1 Remove `source` parameter from `MoveToSiteViewModel.init` and `.make`. Remove `source` stored property. `currentSiteID` always derived from `device.siteID` (non-empty check only).
- [x] 14.2 Remove `source` parameter from `MoveToSiteView.init`. Remove `switch viewModel.source` in body — always wrap content in NavigationStack with ToolbarItemCancel.
- [x] 14.3 Remove `selectSite` function's `.add` case. Site tap always updates `viewModel.device.siteID` (move behavior).
- [x] 14.4 Remove "Select a destination" conditional on `viewModel.source == .move` — always show it. Remove "Move device" button conditional on `viewModel.source == .move` — always show it.
- [x] 14.5 Update `SheetManager.swift` call site: change `MoveToSiteView(device: .constant(device), source: .move)` to `MoveToSiteView(device: .constant(device))`.
- [x] 14.6 Evaluate `AnalyticsEvent.AddDeviceGroupSource.add`: still used by SiteSelectionViewModel and SiteInformationViewModel — kept.

## 15. Tests

- [x] 15.1 Create `SiteSelectionViewModelTest`: test `selectedSite` computation, tap site row updates local selection, Save applies to device binding, Cancel preserves original siteID, `onSiteDeleted` clears selection, `tapCreateSiteButton` sets flag.
- [x] 15.2 Update `MoveToSiteViewModelTest`: remove all `.add` source test cases. Update remaining tests to not pass `source` parameter.

## 16. Localization

- [x] 16.1 All localized strings reused from existing keys: "Site", "Save", "Cancel", "Search_site", "Create_site_or_area", "Site_information", "Delete", "No_sites_create_one_to_get_started".

## 17. SiteSelectionConfiguration Refactor

- [x] 17.1 Add `SiteSelectionPresentation` enum (`.push`, `.sheet`) and `SiteSelectionConfiguration` struct with properties: `navigationTitle`, `showCreateSite`, `showContextMenu`, `showToggleAll`, `showSaveButton`, `allowEmptySelection`, `presentation`. Add preset factory methods: `.default`, `.picker(title:)`, `.multiSelect(allowEmpty:)`.
- [x] 17.2 Refactor `SiteSelectionMode`: remove `allowEmptySelection` from `.multi` case (moved to config).
- [x] 17.3 Refactor `SiteSelectionViewModel.init` to accept `config: SiteSelectionConfiguration`. Replace `isSingleMode`-based computed properties with config + permission intersection (`canCreateSite`, `canEditSite`, `canDeleteSite`). Remove `isSingleMode` property.
- [x] 17.4 Refactor `SiteSelectionView` single mode: tap row → write binding + dismiss (tap-to-confirm). Remove Save button for single mode. Add `confirmAndDismiss()` method that handles dismiss based on `config.presentation`.
- [x] 17.5 Refactor `SiteSelectionView` presentation: when `.sheet`, wrap in NavigationStack + ToolbarItemCancel; when `.push`, no wrapping.
- [x] 17.6 Update `SiteSelectionView` init signatures: `init(selectedSiteID:config:)` default `.default`; `init(selectedSites:items:config:)` default `.multiSelect()`.
- [x] 17.7 Update `SheetManager.showSitePicker` to present `SiteSelectionView(selectedSiteID:config: .picker(title:))`. Update `SiteInformationView` caller to pass `Binding<String?>` instead of `Binding<SiteItem?>`.
- [x] 17.8 Delete `SitePickerSheet` from `SiteInformationView.swift`.
- [x] 17.9 Update `AddDeviceByMacView` and `AddVSSView` call sites to use new init signature (config default is `.default`, no change needed unless explicit).
- [x] 17.10 Update `SiteSelectionViewModelTest`: test config + permission intersection, test tap-to-confirm in single mode, test multi mode unchanged.
- [x] 17.11 Build and verify no compilation errors. Manual test single mode (AddDevice + showSitePicker) and multi mode.
