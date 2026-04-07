## Why

The `SiteItem.isDefault` field represents a legacy concept where the organization itself acts as a "default site" for ungrouped devices. The new Site Management specs (both Portal and App) eliminate this concept entirely — unassigned devices are identified by `site_id = null`, not by belonging to a special "default" site. The field currently drives sorting, icon display, delete protection, and device fallback logic that all conflict with the new Site Management model. Removing it now aligns the codebase with the spec before Site Management integration begins.

## What Changes

- **BREAKING**: Remove `isDefault` property from `SiteItem`
- **BREAKING**: Remove `findDefaultSite()` from `DeviceManagerProtocol` and all implementations
- Refactor `moveAllDevicesToUngrouped()` to no longer depend on `findDefaultSite()` / `isDefault` (used by UAT utility and UITests — must preserve functionality)
- Simplify `SiteItem.Comparable` to pure alphanumeric sort (no special last-position for default site)
- Remove `SiteItem+Extension.icon` conditional logic (unified icon for all sites)
- Remove `isDefault` guard from `FeatureToggle.canDelete(for:)` — all sites become deletable per new spec
- Remove `defaultSiteID` from `AddDeviceViewModel` — already replaced by explicit site selection per `add-device-site-selection` spec

## Capabilities

### New Capabilities

_None — this is a removal/cleanup change._

### Modified Capabilities

- `add-device-site-selection`: Remove reference to default site fallback. Already specifies "no default Site pre-selection" but implementation still has `defaultSiteID` as dead code path.

## Impact

- **VortexFeatures/Core/DeviceManager**: `SiteItem.swift`, `DeviceManager.swift`, `DeviceManagerProtocol.swift`, `MockDeviceManager.swift`
- **iOSCharmander**: `SiteItem+Extension.swift`, `FeatureToggle.swift`, `AddDeviceViewModel.swift`
- **Unit Tests**: `DeviceManagerTest.swift`, `SiteItemTest.swift` (sorting tests), `AddDeviceViewModelTest.swift`, `TestUtility.swift` (both test targets)
