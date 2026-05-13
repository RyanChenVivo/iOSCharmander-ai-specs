## Context

The iOS app handles site API errors through a chain: `BackendErrorType` (raw API type string) → `siteAPIErrorHandle` (converts to `VortexError`) → `AlertItem.getErrorMessage` (maps to localized key) → `Localizable.xcstrings` (actual display text).

Current state:
- Delete error messages don't match high-level spec scenario language
- `reachSiteLimit` and `xliteSiteLimitExceeded` both show `"Maximum 10 sites reached..."` — but `reachSiteLimit` is the general org limit (1000), not xLite's 10-site limit
- `Cannot_delete_site_has_sub_sites` key exists in xcstrings but no code references it (residual from rename-subsite-to-area)
- Two Apidog-documented errors (`xlite-area-not-allowed`, `xlite-site-limit-exceeded`) have no handling — they fall through to generic error
- `site-not-found` (404) is decoded by `BackendErrorType` but not mapped in `siteAPIErrorHandle`
- VortexError enum cases still use "subsite" naming while UI messages already say "area"

## Goals / Non-Goals

**Goals:**
- Align all site/area error messages with high-level spec scenario descriptions
- Remove dead localization keys
- Handle all Apidog-documented site API errors explicitly
- Correct reachSiteLimit vs xliteSiteLimitExceeded distinction

**Non-Goals:**
- Changing the delete confirmation flow (title, input field)
- Changing the actual numeric limits enforced by backend
- Adding site name to delete confirmation title
- Handling non-site API errors

## Decisions

1. **Separate delete messages per error type**: Each backend error maps to a distinct message using spec scenario language directly:
   - `siteHasDevices` → `"Devices must be moved or removed first before deletion."`
   - `cannotDeleteSiteWithAreas` → `"All areas must be deleted first before deletion."`
   - `cannotDeleteDefaultSite` → `"The default site cannot be deleted."`

2. **New xlite error cases**: Add `xliteAreaNotAllowed` and `xliteSiteLimitExceeded` to `BackendErrorType`. Map them to new `VortexError` cases. Messages from spec:
   - `xliteSiteLimitExceeded` → `"Maximum 10 sites reached. Contact your reseller to upgrade your service."` (keep current message, already correct for xLite)
   - `xliteAreaNotAllowed` → `"Multi-level hierarchy is not available on the xLite plan. Contact your reseller to upgrade."`
   
3. **Correct reachSiteLimit message**: The existing `reachSiteLimit` (backend: `/problems/site-limit-exceeded`) is the general organization-level limit (1000 Sites+Areas combined), not the xLite 10-site limit. Update message to: `"The organization-level site and area limit has been reached."`

4. **site-not-found handling**: Map to a generic "site not found" error that dismisses the current operation gracefully (the site was likely deleted by another user).

5. **Localized key naming**: Rename keys to match spec language:
   - `Cannot_delete_site_has_devices` → `Cannot_delete_has_devices` with value `"Devices must be moved or removed first before deletion."`
   - `Cannot_delete_site_has_areas` → `Cannot_delete_has_areas` with value `"All areas must be deleted first before deletion."`
   - Remove dead key `Cannot_delete_site_has_sub_sites`
   - Remove unified key `Cannot_delete_site` (no longer needed since messages are separate)

6. **Rename subsite → area in VortexError and BackendErrorType case names**: The `rename-subsite-to-area` change updated UI messages to say "area" but left Swift enum case names using "subsite". This change aligns them:
   - `VortexError.subsiteCountExceeded` → `VortexError.areaCountExceeded`
   - `VortexError.cannotDeleteSiteWithSubSites` → `VortexError.cannotDeleteSiteWithAreas`
   - `BackendErrorType.subsiteCountExceeded` → `BackendErrorType.areaCountExceeded` (rawValue unchanged)
   - `BackendErrorType.cannotDeleteSiteWithSubSites` → `BackendErrorType.cannotDeleteSiteWithAreas` (rawValue unchanged)
   
   Backend raw strings (`/problems/subsite-count-exceeded`, `/problems/cannot-delete-site-with-sub-sites`) remain unchanged — only the Swift identifier names are updated for readability.

## Risks / Trade-offs

- **Generic subject in delete messages**: Messages say "before deletion" without specifying "this site" or "this area" since the same backend error may apply in both contexts.
- **areaCountExceeded keeps generic wording**: Backend sends one error (`subsite-count-exceeded`) for both "10 L1 areas per site" and "10 sub-areas per area" scenarios. Message uses "under this parent" rather than specifying which level, since we cannot distinguish.
- **xlite errors may not be triggered in current app**: If the iOS app doesn't serve xlite users yet, these cases may never fire. Still worth adding for completeness and forward compatibility.
