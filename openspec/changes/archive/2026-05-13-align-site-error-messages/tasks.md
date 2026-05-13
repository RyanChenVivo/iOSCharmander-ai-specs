## 0. Rename subsite → area in enum case names

- [x] 0.1 In `BackendError.swift`, rename `subsiteCountExceeded` → `areaCountExceeded` (keep rawValue `"/problems/subsite-count-exceeded"`)
- [x] 0.2 In `BackendError.swift`, rename `cannotDeleteSiteWithSubSites` → `cannotDeleteSiteWithAreas` (keep rawValue `"/problems/cannot-delete-site-with-sub-sites"`)
- [x] 0.3 In `VortexError.swift`, rename `subsiteCountExceeded` → `areaCountExceeded`
- [x] 0.4 In `VortexError.swift`, rename `cannotDeleteSiteWithSubSites` → `cannotDeleteSiteWithAreas`
- [x] 0.5 Update all references in `VortexRestfulApi.swift` (`siteAPIErrorHandle`)
- [x] 0.6 Update all references in `AlertItem.swift` (`getErrorMessage`)
- [x] 0.7 Update all references in `DeleteConfirmation.swift`
- [x] 0.8 Update all references in `SiteInformationViewModel.swift`
- [x] 0.9 Update all references in test files (`VortexRestfulApiTest.swift`, `SiteInformationViewModelTest.swift`)

## 1. Add xlite error types

- [x] 1.1 Add `xliteAreaNotAllowed = "/problems/xlite-area-not-allowed"` and `xliteSiteLimitExceeded = "/problems/xlite-site-limit-exceeded"` to `BackendErrorType` in `BackendError.swift`
- [x] 1.2 Add `xliteAreaNotAllowed` and `xliteSiteLimitExceeded` cases to `VortexError` enum
- [x] 1.3 Add mapping in `siteAPIErrorHandle` for the two new xlite error types

## 2. Add siteNotFound error handling

- [x] 2.1 Add `siteNotFound` case to `VortexError` enum
- [x] 2.2 Add `.restfulError(type: .siteNotFound)` → `VortexError.siteNotFound` mapping in `siteAPIErrorHandle`

## 3. Update AlertItem error messages (keys follow localization-guide: EN text with underscores, no punctuation)

- [x] 3.1 `.siteHasDevices` → `"Devices_must_be_moved_or_removed_first_before_deletion"`
- [x] 3.2 `.cannotDeleteSiteWithAreas` → `"All_areas_must_be_deleted_first_before_deletion"`
- [x] 3.3 `.cannotDeleteDefaultSite` → `"The_default_site_cannot_be_deleted"`
- [x] 3.4 `.siteNotFound` → `"This_site_no_longer_exists_The_site_list_will_be_refreshed"`
- [x] 3.5 `.reachSiteLimit` → `"The_organization-level_site_and_area_limit_has_been_reached"`
- [x] 3.6 `.hierarchyDepthExceeded` → `"The_maximum_area_nesting_depth_has_been_reached_You_cannot_create_a_deeper_level"`
- [x] 3.7 `.areaCountExceeded` → `"The_maximum_number_of_areas_under_this_parent_has_been_reached"`
- [x] 3.8 `.xliteAreaNotAllowed` → `"Multi-level_hierarchy_is_not_available_on_the_xLite_plan_Contact_your_reseller_to_upgrade"`
- [x] 3.9 `.xliteSiteLimitExceeded` → keeps `"Maximum_10_sites_reached_Contact_your_reseller_to_upgrade_your_service"` (no change)

## 4. Update Localizable.xcstrings

- [x] 4.1 Rename/add keys to match new AlertItem key names (EN values = the key text with proper punctuation restored)
- [x] 4.2 Remove dead keys: `Cannot_delete_site_has_devices`, `Cannot_delete_site_has_areas`, `Cannot_delete_site_has_sub_sites`, `Cannot_delete_site`, `Cannot_delete_default_site`, `Site_no_longer_exists`, `Area_hierarchy_depth_exceeded`, `Area_count_exceeded`, `Xlite_area_not_allowed`
- [x] 4.3 Add ja/zh-Hant with `state: "needs_review"`

## 5. Update tests

- [x] 5.1 Update `VortexRestfulApiTest` to add test cases for xlite error type conversion and siteNotFound conversion
- [x] 5.2 Update `SiteInformationViewModelTest` to cover xlite error alert cases

## 6. Sync main spec

- [x] 6.1 Update `openspec/specs/add-device-site-selection/spec.md` navigation title scenario to `"Create site or area"` for both create modes
- [x] 6.2 Sync `openspec/specs/site-deletion/spec.md` error message scenarios to reflect unified message
