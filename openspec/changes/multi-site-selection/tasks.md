## 1. SiteSelectionMode Enum & ViewModel Refactor

- [ ] 1.1 Create `SiteSelectionMode` enum with `.single(Binding<String?>)` and `.multi(Binding<[SiteItem]>, allowEmptySelection: Bool)` cases
- [ ] 1.2 Refactor `SiteSelectionViewModel` to accept `SiteSelectionMode`, add `selectedSites: [SiteItem]` state for multi mode
- [ ] 1.3 Make `tapSiteRow(_:)` mode-aware: single sets `selectedSiteID`, multi toggles in/out of `selectedSites`
- [ ] 1.4 Add `selectAll(sites:)` and `deselectAll()` methods for multi mode
- [ ] 1.5 Add computed `canSave: Bool` that respects mode and `allowEmptySelection`
- [ ] 1.6 Update `SiteSelectionViewModel.make()` factory to accept mode parameter

## 2. SiteCheckboxTreeRow Component

- [ ] 2.1 Extract shared tree row layout (depth indentation, `└` connector, icon at depth 0, HighlightedText) into a reusable helper or ViewBuilder
- [ ] 2.2 Create `SiteCheckboxTreeRow` using the shared layout, with trailing checkbox icon (`.iconStatusCheckboxCircleCheckedSolidNormal` / `.iconStatusCheckboxCircleUncheckedSolidNormal`)
- [ ] 2.3 Refactor `SiteTreeRow` to use the shared layout helper (verify no regression)

## 3. SiteSelectionView Multi Mode UI

- [ ] 3.1 Update `SiteSelectionView` init to accept `SiteSelectionMode` instead of `Binding<DeviceItem>`
- [ ] 3.2 Conditionally render control bar: single → "Create site or area" button; multi → `ToggleAllSectionHeader`
- [ ] 3.3 Conditionally render row: single → `SiteTreeRow`; multi → `SiteCheckboxTreeRow`
- [ ] 3.4 Conditionally show/hide context menu (only in single mode)
- [ ] 3.5 Conditionally show/hide navigationDestination for SiteInformationView (only in single mode)
- [ ] 3.6 Update Save button action: single → write siteID to binding; multi → write `[SiteItem]` to binding
- [ ] 3.7 Update Save button disabled state to use `viewModel.canSave`
- [ ] 3.8 Initialize selection state from binding on appear (single: read siteID; multi: read `[SiteItem]`)

## 4. Update Add Device Callers (Single Mode)

- [ ] 4.1 Update `AddDeviceByMacView` to use `SiteSelectionView(mode: .single(...))` with a `Binding<String?>` derived from `device.siteID`
- [ ] 4.2 Update `AddVSSView` to use `SiteSelectionView(mode: .single(...))` with a `Binding<String?>` derived from `device.siteID`
- [ ] 4.3 Verify Add Device flow works end-to-end (select site, Save, siteID applied)

## 5. Update Message Filter Callers (Multi Mode)

- [ ] 5.1 Replace `MultipleSelectionView` for site selection in `AccessControlMessageSearchView.groupSection` with `SiteSelectionView(mode: .multi($viewModel.selectedSites))`
- [ ] 5.2 Replace `MultipleSelectionView` for site selection in `SmartSensorMessageSearchView.groupSection` with `SiteSelectionView(mode: .multi($viewModel.selectedSites, allowEmptySelection: true))`
- [ ] 5.3 Verify Message filter flow works end-to-end (open picker, select/deselect sites, Save, filter applied)

## 6. Tests

- [ ] 6.1 Update `SiteSelectionViewModelTest` for single mode (existing tests adapted to new init)
- [ ] 6.2 Add `SiteSelectionViewModelTest` cases for multi mode: toggle, selectAll, deselectAll, canSave with allowEmptySelection
- [ ] 6.3 Add `SiteSelectionViewModelTest` case: initial state loaded from binding in multi mode
