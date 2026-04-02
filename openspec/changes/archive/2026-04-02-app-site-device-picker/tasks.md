## 1. compactName — Device Picker Group Headers

- [x] 1.1 Update `DeviceFilter.siteView(_:)` to use `site.compactName` instead of `site.name`
- [x] 1.2 Update `CustomizedViewEditorAddCamerasView.GroupItemView.groupRow` to use `site.compactName` instead of `site.name`

## 2. DevicePickerView — Restructure to Site-Based Grouping

- [x] 2.1 Replace NvrGroupView, VssGroupView, BridgeGroupView, and SiteView sections with site-based grouping that includes all device types (NVR, VSS, Bridge, Camera, NVR Channel, VSS Channel) under their assigned Site
- [x] 2.2 Update DevicePickerView search mode to display a flat filtered list instead of device-type-separated groups
- [x] 2.3 Use `site.compactName` in site group headers for the restructured DevicePickerView
- [x] 2.4 Remove NVR/VSS/Bridge device-type grouping from `makeCheckableGroups` in FeatureToggle — all devices now grouped under their assigned Site
- [x] 2.5 Remove `SiteItem.nvr`, `SiteItem.vss`, `SiteItem.bridge` static constants and related icon switch cases

## 3. Testing

- [x] 3.1 Verify DeviceFilter compactName display across Message Search, DeepSearch, ReSearch, ThinkSearch, ProfileSearch, EventInsight
- [x] 3.2 Verify CustomizedViewEditorAddCamerasView compactName display
- [x] 3.3 Verify DevicePickerView shows all device types under sites with no separate device-type groups
- [x] 3.4 Verify DevicePickerView search returns flat filtered results
- [x] 3.5 Verify search still matches full path name (not compactName) across all pickers
