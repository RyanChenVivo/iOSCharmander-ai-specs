## 1. Extract shared component

- [x] 1.1 ~~Extract NavigationPlaceholderRow~~ — Skipped: use existing `NavigationFieldRow` + `Button` wrapper instead

## 2. Expand SiteInformationViewModel

- [x] 2.1 Add `SiteCreationType` enum (`.site`, `.area`) and `selectedType` property with `didSet` that updates default name
- [x] 2.2 Add `selectedParent: SiteItem?` property for area creation
- [x] 2.3 Add `isArea` computed property: in edit mode checks `site.parentId` is non-empty, in create mode checks `selectedType == .area`
- [x] 2.4 Update `init(site:)` — when `site` is nil generate default name based on `selectedType`; when editing an area, populate name only (no location)
- [x] 2.5 Update `canSave` — require `selectedParent != nil` when creating an area
- [x] 2.6 Update `navigationTitle` computed property — return "Create_site", "Create_area", "Site_information", or "Area_information" based on mode and type
- [x] 2.7 Update `createSite()` — pass `selectedParent?.id` as `parentId` for area type, `nil` for site type; only pass location for site type
- [x] 2.8 Update `updateSite()` — pass `nil` location when editing an area

## 3. Expand SiteInformationView

- [x] 3.1 Add type picker (segmented Picker) shown only in create mode (`!viewModel.isEditMode`)
- [x] 3.2 Add conditional location section — show only when `!viewModel.isArea` and `featureProvider.canUpdateLocationForSite()`
- [x] 3.3 Add `ParentSitePickerSheet` (moved from `CreateSiteView.swift`) as private struct; replaced `ParentSiteSection` with `NavigationFieldRow` + `Button`
- [x] 3.4 Add parent picker section shown only in create-area mode (`!viewModel.isEditMode && viewModel.isArea`)
- [x] 3.5 Update toolbar button — use `NavigationCreateButton` in create mode, `NavigationSaveButton` in edit mode
- [x] 3.6 Update navigation title to use `viewModel.navigationTitle`

## 4. Cleanup

- [x] 4.1 Delete `CreateSiteView.swift` and remove from Xcode project
- [x] 4.2 Delete `CreateSiteViewModel.swift` and remove from Xcode project
- [x] 4.3 Verify MoveToSiteView navigation destinations still compile (`SiteInformationView(site: nil)` for create, `SiteInformationView(site: site)` for edit)

## 5. Localization

- [x] 5.1 Add `Area_information` localization key to `Localizable.xcstrings`

## 6. Tests

- [x] 6.1 Migrate `CreateSiteViewModelTest` test cases into `SiteInformationViewModelTest` — cover create-site, create-area, canSave validation
- [x] 6.2 Add test: edit area populates name only, location is nil
- [x] 6.3 Add test: edit area calls `updateSite` with nil location
- [x] 6.4 Add test: `navigationTitle` returns correct value for all four scenarios
- [x] 6.5 Delete `CreateSiteViewModelTest.swift` and remove from Xcode project
