## 1. Remove isDefault from SiteItem

- [x] 1.1 Remove `isDefault` property from `SiteItem.swift`
- [x] 1.2 Remove `isDefault` parameter from `SiteItem.init`
- [x] 1.3 Simplify `SiteItem.Comparable.<` to pure alphanumeric sort (`lhs.name < rhs.name`)

## 2. Update DeviceManager

- [x] 2.1 Remove `isDefault: site.id == orgID` from `fetchAll()` in `DeviceManager.swift`
- [x] 2.2 Remove `findDefaultSite()` from `DeviceManager.swift`
- [x] 2.3 Refactor `moveAllDevicesToUngrouped()` to use `try await myOrganization.getID()` instead of `findDefaultSite()`, renamed to `moveAllDevicesToOrganizationSite()`
- [x] 2.4 Remove `findDefaultSite()` from `DeviceManagerProtocol.swift`
- [x] 2.5 Remove `_findDefaultSite` from `MockDeviceManager.swift`

## 3. Update App Layer

- [x] 3.1 Remove `isDefault` conditional from `SiteItem+Extension.icon` — use `iconGeneralGroupSolid` for all sites
- [x] 3.2 Remove `!site.isDefault` guard from `FeatureToggle.canDelete(for:)` — keep only `hasOrgPrivilege(.adminRestricted)`
- [x] 3.3 Remove `defaultSiteID` computed property from `AddDeviceViewModel.swift`

## 4. Update Tests

- [x] 4.1 Remove `isDefault` parameter from `TestUtility.makeSiteItem` in both test targets
- [x] 4.2 Update `DeviceManagerTest.moveAllDevicesToUngrouped` test to not rely on `isDefault`
- [x] 4.3 Update `DeviceManagerTest` fetchAll assertion (`isDefault == true`) to verify org site exists by ID instead
- [x] 4.4 Update `SiteItemTest` sorting tests if any depend on isDefault sort behavior
- [x] 4.5 Update `AddDeviceViewModelTest` to remove `_findDefaultSite` mock setup

## 5. Verify

- [x] 5.1 Build VortexFeatures package — confirm no compile errors
- [x] 5.2 Build iOSCharmander app target — confirm no compile errors
- [x] 5.3 Run VortexFeaturesTests — confirm all tests pass
- [x] 5.4 Run iOSCharmanderTests — confirm all tests pass
