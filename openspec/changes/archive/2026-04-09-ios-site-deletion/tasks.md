## 1. Backend Error Type Extension

- [x] 1.1 Add `cannotDeleteSiteWithSubSites`, `siteHasDevices`, `cannotDeleteDefaultSite` cases to `BackendErrorType` in `BackendError.swift`
- [x] 1.2 Add `cannotDeleteDefaultSite`, `cannotDeleteSiteWithSubSites`, `siteHasDevices` cases to `VortexError`

## 2. VortexRestfulApi Site Error Handling

- [x] 2.1 Add `siteAPIErrorHandle` method in `VortexRestfulApi` (following `downgradeAPIErrorHandle` pattern) to convert `.restfulError(type:)` to specific `VortexError`
- [x] 2.2 Wrap `deleteSite(id:)` with `do/catch` calling `siteAPIErrorHandle`
- [x] 2.3 Add parameterized unit test for `deleteSite` verifying each 409 error type is correctly converted to `VortexError`

## 3. DeleteConfirmation Site Support

- [x] 3.1 Add `.site(SiteItem)` case to `DeleteConfirmationType`
- [x] 3.2 Add site-specific title, message, warning text, and "DELETE" text input requirement in `DeleteConfirmation` view
- [x] 3.3 Add `confirmDelete` handling for `.site` case in `DeleteConfirmationViewModel`
- [x] 3.4 Add `siteDeleteErrorAlert` in `DeleteConfirmation` to map `VortexError` to localized error alerts

## 4. MoveToSiteViewModel Integration

- [x] 4.1 Change `tapDeleteSiteButton` to open `DeleteConfirmation` sheet via `SheetManager.shared.openDeleteConfirmation(type: .site(site))` instead of deleting directly
- [x] 4.2 Clear device's siteID in the `onFinishDelete` completion when deleted site was the current site

## 5. Localization

- [x] 5.1 Add localized strings: `Delete_this_site`, `Are_you_sure_you_want_to_delete_this_site`, `The_action_CANNOT_be_undone_This_site_will_be_permanently_deleted`
- [x] 5.2 Add error localized strings: `Cannot_delete_site_has_devices`, `Cannot_delete_site_has_sub_sites`, `Cannot_delete_default_site`, `Site_not_found`
