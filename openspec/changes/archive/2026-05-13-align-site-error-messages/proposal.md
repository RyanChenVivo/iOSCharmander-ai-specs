## Why

Site deletion error messages in the iOS app are inconsistent with the Portal high-level spec. The Portal defines a unified message for all "cannot delete" scenarios, while iOS currently shows different messages per error type. Additionally, there are residual localization keys from the pre-rename-subsite-to-area era, and two API error types from Apidog (`xlite-area-not-allowed`, `xlite-site-limit-exceeded`) are not handled in the codebase.

## What Changes

- Unify `Cannot_delete_site_has_devices` and `Cannot_delete_site_has_areas` localized values to a single message: `"Remove all areas, floor plans, and devices before deleting this site."`
- Remove residual `Cannot_delete_site_has_sub_sites` key from `Localizable.xcstrings` (no code references it)
- Add `BackendErrorType` cases for `xliteAreaNotAllowed` and `xliteSiteLimitExceeded`
- Add `VortexError` cases and `siteAPIErrorHandle` mapping for the new xlite errors
- Add localized error messages for the new xlite error cases
- Sync main spec `add-device-site-selection` to reflect the unified navigation title `"Create site or area"` (already implemented, spec outdated)

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `site-deletion`: Update error message display requirement — all "cannot delete" scenarios use unified message; add handling for `site-not-found` 404 error
- `add-device-site-selection`: Sync navigation title scenario to match current implementation (`"Create site or area"` for both create modes); add xlite-specific error handling for site creation

## Impact

- `VortexFeatures/Sources/VortexError/BackendError.swift` — add 2 new `BackendErrorType` cases
- `VortexFeatures/Sources/VortexError/VortexError.swift` — add 2 new error cases
- `VortexFeatures/Sources/VortexFeatures/Core/VortexBackend/Api/VortexRestfulApi/VortexRestfulApi.swift` — extend `siteAPIErrorHandle`
- `iOSCharmander/View/Component/ViewModiier/AlertItem.swift` — update `getErrorMessage` mapping, add new cases
- `Localizable.xcstrings` — modify 2 values, remove 1 key, add 2 new keys
- `VortexFeatures/Tests/` — update existing tests, add tests for new error mappings
