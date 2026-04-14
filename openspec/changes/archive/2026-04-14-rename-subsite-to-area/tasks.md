## 1. API Layer: Add parentId to AddSiteInput

- [x] 1.1 Add `parentId: String?` field to `AddSiteInput` (Site.swift)
- [x] 1.2 Update `DeviceManagerProtocol.createSite` signature to add `parentId: String? = nil`
- [x] 1.3 Update `DeviceManager.createSite` implementation to pass parentId to `VortexRestfulApi.postSite`
- [x] 1.4 Update `MockDeviceManager.createSite` to add parentId parameter
- [x] 1.5 Update `VortexRestfulApi.postSite` to pass parentId into `AddSiteInput`

## 2. Error Handling: Add three 403 error cases

- [x] 2.1 Add `siteLimitExceeded`, `hierarchyDepthExceeded`, `subsiteCountExceeded` cases to `BackendError` with corresponding `/problems/` type strings
- [x] 2.2 Add corresponding three cases to `VortexError`
- [x] 2.3 Add three error mappings in `VortexRestfulApi.siteAPIErrorHandle`
- [x] 2.4 Add three localized error message strings to `Localizable.xcstrings`

## 3. CreateSiteView: Support type selection

- [x] 3.1 Add `SiteCreationType` enum (`.site`, `.area`) and `selectedType` property to `CreateSiteViewModel`
- [x] 3.2 Add `selectedParent: SiteItem?` property to `CreateSiteViewModel`
- [x] 3.3 Update `CreateSiteViewModel.init` to generate default name based on type (Site N / Area N)
- [x] 3.4 Update `CreateSiteViewModel.canCreateSite` — Area mode requires parent to be selected
- [x] 3.5 Update `CreateSiteViewModel.createSite` — Area mode passes parentId, Site mode passes nil
- [x] 3.6 Add segmented Picker (Site / Area) to `CreateSiteView`
- [x] 3.7 Update `CreateSiteView` — Site mode shows Name + Location; Area mode shows Name + Parent picker
- [x] 3.8 Update `CreateSiteView` — navigation title changes with type (Create Site / Create Area)
- [x] 3.9 Update `CreateSiteView` — Parent field shows red "Required" indicator and red placeholder text

## 4. Terminology Rename: Subsite → Area

- [x] 4.1 Update `VortexError.cannotDeleteSiteWithSubSites` UI display text, rename "Subsite" to "Area"
- [x] 4.2 Update "Subsite" → "Area" UI text in `AlertItem.swift` and `DeleteConfirmation.swift`
- [x] 4.3 Update all "Subsite" related strings to "Area" in `Localizable.xcstrings`
- [x] 4.4 Update test names from "subsite" to "area" in `DeviceManagerTest`
