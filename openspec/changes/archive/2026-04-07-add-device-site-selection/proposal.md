## Why

The current Add Device flow automatically pre-selects a default Site, which doesn't align with Portal's spec requiring explicit Site selection. Additionally, the MoveToSiteView lacks an empty state when no Sites exist, and the delete Site interaction uses a hidden context menu (long-press) instead of a discoverable swipe action.

## What Changes

- **Remove Site pre-selection**: The Add Device configuration screen no longer pre-selects a default Site. The Site field displays "-" until the user explicitly selects one.
- **Disable Add button without Site**: The Add button is disabled when no valid Site is selected (either never selected, or selected Site was deleted).
- **Empty state for MoveToSiteView**: When no Sites exist, display an empty state illustration with a message prompting the user to create a Site, along with a Create Site button. Note: since `canAddDevice` and `canCreateSite` share the same `adminRestricted` privilege, users who can add devices can always create Sites — no dead-end scenario exists.
- **Delete Site: context menu → swipe action**: Replace the long-press context menu with a swipe-to-delete action for better discoverability.
- **Restore delete Site feature toggle**: Re-enable the `canDelete(for: site)` feature toggle check that was commented out, so only admin users see the delete option.

## Capabilities

### New Capabilities
- `add-device-site-selection`: Site selection behavior in Add Device flow — no pre-selection, Add button disabled without valid Site, empty state UI in MoveToSiteView, and swipe-to-delete with restored feature toggle

### Modified Capabilities
None

## Impact

- **AddDeviceViewModel**: Remove `defaultSiteID` fallback in `genDevice()`
- **AddDeviceByMacView**: Add disabled state to Add button based on `siteID` validity
- **MoveToSiteView**: Add empty state view; replace `.contextMenu` with `.swipeActions`; restore `featureProvider.canDelete(for: site)` guard
- **Localization**: New strings for empty state message
