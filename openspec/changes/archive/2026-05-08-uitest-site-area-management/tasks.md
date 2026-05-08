## 1. Infrastructure Updates

- [x] 1.1 Update `CommonOperation.move(device:toGroup:)` to use new MoveToSite flow (tree view → tap site → tap "Move_device" → confirm in DeleteConfirmation sheet)
- [x] 1.2 Add UAT site name constants to `UATHelper` (e.g., `siteA`, `siteB`, `siteC`, `siteD`, `areaB1`, `areaD4`)
- [x] 1.3 Create `iOSCharmanderUITests/Site/` directory and add to Xcode project

## 2. MoveToSiteUITest

- [x] 2.1 Create `MoveToSiteUITest.swift` with setUp/tearDown (sign in, tearDown calls `moveAllDevicesToOrganizationSite`)
- [x] 2.2 Implement `test_moveDevice_toSiteC` — open device more menu → Move to → select SiteC in tree → tap Move_device → confirm → verify device under SiteC
- [x] 2.3 Implement `test_deleteError_siteHasDevices` — move device to SiteA → attempt delete SiteA via context menu → type DELETE → verify error alert "Cannot_delete_site_has_devices"

## 3. SiteAreaUITest

- [x] 3.1 Create `SiteAreaUITest.swift` with setUp/tearDown (sign in, tearDown cleans up test-created areas)
- [x] 3.2 Implement `test_createArea_underSiteC` — tap Create_site_or_area → select Area type → enter name → select SiteC as parent → tap Create → verify area appears in tree
- [x] 3.3 Implement `test_deleteArea_success` — create test area → long press → Delete → type DELETE → confirm → verify area disappears
- [x] 3.4 Implement `test_deleteError_siteWithSubAreas` — long press SiteB → Delete → type DELETE → confirm → verify error alert "Cannot_delete_site_has_areas"
- [x] 3.5 Implement `test_createArea_errorHierarchyDepthExceeded` — Create area with AreaD4 as parent → verify error alert "Area_hierarchy_depth_exceeded"
- [x] 3.6 Implement `test_createArea_errorSubsiteCountExceeded` — Create area under site at subsite limit → verify error alert "Area_count_exceeded"

## 4. Existing Test Fixes

- [x] 4.1 Verify `ViewTabExpandCollapseUITest` site toggle identifiers still work with `displayName` format; update enum rawValues if needed
