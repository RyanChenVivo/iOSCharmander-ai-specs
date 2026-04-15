## Why

Two overlapping views handle site creation and editing: `SiteInformationView` (supports create + edit for root sites only) and `CreateSiteView` (supports create for both sites and areas but cannot edit). Neither covers the full use case. MoveToSiteView currently navigates to `SiteInformationView` for both create and edit, but it lacks area awareness. `CreateSiteView` is not wired into any navigation flow outside its Preview.

## What Changes

- Expand `SiteInformationView` / `SiteInformationViewModel` to absorb `CreateSiteView`'s area creation capabilities (type picker, parent picker)
- Support editing areas (name-only, per API constraint: `UpdateSiteInput` has no `parentId`)
- Delete `CreateSiteView.swift` and `CreateSiteViewModel.swift` after merging their logic
- Extract `NavigationPlaceholderRow` (currently defined in `CreateSiteView.swift`) to its own file since it's shared
- Add "Area_information" localization key for edit-area navigation title
- Update `CreateSiteViewModelTest` to test the unified `SiteInformationViewModel`

## Capabilities

### New Capabilities

### Modified Capabilities
- `add-device-site-selection`: Replace `CreateSiteView` references with `SiteInformationView`. Add edit support for areas (name-only). Unify create/edit into a single view handling four scenarios: create site, create area, edit site, edit area.

## Impact

- **UI Components**: `SiteInformationView`, `SiteInformationViewModel` expanded; `CreateSiteView`, `CreateSiteViewModel` deleted; `NavigationPlaceholderRow` extracted
- **App Pages**: MoveToSiteView navigation unchanged (already points to `SiteInformationView`)
- **Tests**: `CreateSiteViewModelTest` renamed/refactored to `SiteInformationViewModelTest`; existing `SiteInformationViewModel` tests extended for area scenarios
- **Localization**: New key `Area_information` added
