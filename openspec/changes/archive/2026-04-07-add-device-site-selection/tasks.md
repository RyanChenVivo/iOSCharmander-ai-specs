## 1. Remove Site pre-selection

- [x] 1.1 In `AddDeviceViewModel.genDevice()`, change `siteID: selectedSiteID ?? defaultSiteID` to `siteID: selectedSiteID` to remove the default fallback
- [x] 1.2 Add computed property `canAddDevice` on `AddDeviceViewModel` that returns `addingDevice.siteID.isNotEmpty`
- [x] 1.3 Change `siteName` to `String?`, returning nil when no site selected

## 2. Add button disable logic and placeholder

- [x] 2.1 In `AddDeviceByMacView`, add `.disabled(!viewModel.canAddDevice)` to the Add button
- [x] 2.2 In `AddDeviceByMacView`, show "Select a site" placeholder in muted color when `siteName` is nil
- [x] 2.3 In `AddVSSView`, apply same placeholder for consistency
- [x] 2.4 Add localized string `Select_a_site` in `Localizable.xcstrings`

## 3. MoveToSiteView empty state

- [x] 3.1 Add empty state using shared `NoResultView` component when `deviceManager.sites.isEmpty`
- [x] 3.2 Restore site list `SearchableScrollItemListView` when sites exist (was commented out)
- [x] 3.3 Add localized string `No_sites_create_one_to_get_started` in `Localizable.xcstrings`

## 4. MoveToSiteViewModel refactor

- [x] 4.1 Change `device` from `let DeviceItem` to `@Binding var DeviceItem`
- [x] 4.2 Move `selectedSite` computed property from View into VM
- [x] 4.3 Move `device.siteID` assignment into `tapSiteRow` (both `.add` and `.move` sources)
- [x] 4.4 Clear `device.siteID` in `tapDeleteSiteButton` when deleting the selected site

## 5. Unit tests — AddDeviceViewModel

- [x] 5.1 Test `canAddDevice` returns false when siteID is empty
- [x] 5.2 Test `canAddDevice` returns true when siteID is not empty

## 6. Unit tests — MoveToSiteViewModel (new)

- [x] 6.1 Test `selectedSite` returns nil when no site selected
- [x] 6.2 Test `selectedSite` returns site when siteID matches
- [x] 6.3 Test `tapSiteRow` sets device siteID for add source
- [x] 6.4 Test `tapDeleteSiteButton` clears siteID when deleting selected site
- [x] 6.5 Test `tapDeleteSiteButton` keeps siteID when deleting different site
- [x] 6.6 Test `tapDeleteSiteButton` handles error without clearing siteID
- [x] 6.7 Test `tapCreateSiteButton` sets pushCreateSiteSheet
