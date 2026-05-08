## Why

The `feat/supportSubsite` branch introduced major changes to site management: MoveToSiteView was redesigned with tree view + select-then-confirm flow, SiteInformationView gained area (subsite) support, and SiteSelectionView was added as a new component. Existing UITests were updated to reflect naming changes (removing group prefix from device display), but no UITests exist for the new MoveToSite flow or the area CRUD operations. We need coverage before merging to ensure these core workflows don't regress.

## What Changes

- Add `MoveToSiteUITest.swift` — tests the redesigned MoveToSite flow (tree view navigation, site selection, move confirmation) and delete-site error when site has devices
- Add `SiteAreaUITest.swift` — tests area CRUD (create area under a site, delete area) and error scenarios (hierarchy depth exceeded, cannot delete site with sub-areas, subsite count exceeded)
- Update `CommonOperation.move(device:toGroup:)` — align with new MoveToSite UI (select site in tree → tap "Move_device" button → confirm in DeleteConfirmation sheet)
- Update `ViewTabExpandCollapseUITest` — adjust `siteToggle_` identifier matching if needed (now uses `site.displayName`)

## Capabilities

### New Capabilities
- `uitest-move-to-site`: UITest coverage for MoveToSite flow including tree-based site selection, move confirmation, and error handling (siteHasDevices)
- `uitest-site-area-crud`: UITest coverage for area creation, area deletion, and error scenarios (hierarchyDepthExceeded, cannotDeleteSiteWithSubSites, subsiteCountExceeded)

### Modified Capabilities
<!-- No existing spec-level requirement changes, only test additions -->

## Impact

- **New files**: `iOSCharmanderUITests/Site/MoveToSiteUITest.swift`, `iOSCharmanderUITests/Site/SiteAreaUITest.swift`
- **Modified files**: `iOSCharmanderUITests/Infrastructure/CommonOperation.swift`, possibly `ViewTabExpandCollapseUITest.swift`
- **Test environment requirement**: UAT account needs pre-configured site hierarchy (SiteA with device, SiteB with sub-area, SiteC empty, SiteD at max depth 5 levels)
- **Dependencies**: Existing `UATUtilityView` buttons (`moveAllDevicesToOrganizationSite`, `deleteTestDeviceGroup`) for tearDown operations
