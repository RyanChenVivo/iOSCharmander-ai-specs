## Why

All device pickers across the App use different grouping strategies — most use site-based grouping via `CheckableGroup<SiteItem, DeviceItem>`, but some use device-type grouping (NVR/VSS/Bridge as separate groups) or flat lists. Additionally, `compactName` (budget-based truncated site path) is only used in the View Tab site row, while all other pickers display the full `SiteItem.name` which can be overly long in width-constrained UI. This change unifies all device pickers to use site-only grouping and `compactName` display, ensuring a consistent cross-app experience aligned with the subsite display name architecture.

## What Changes

- Unify all device picker grouping to site-based classification only — remove NVR/VSS/Bridge independent group sections in DevicePickerView (Help & Feedback); all devices appear under their assigned Site
- Apply `compactName` to all device picker group headers where `SiteItem.name` is currently used: DeviceFilter, CustomizedViewEditorAddCamerasView, DevicePickerView, AccessControl filter, SmartSensor filter
- Ensure NVR, VSS, Bridge, and their channels all appear under their assigned Site in every picker context

## Capabilities

### New Capabilities
- `unified-site-device-picker`: Standardize all device pickers to use site-only grouping with `compactName` display — covers DeviceFilter group headers, DevicePickerView restructure, and all CheckableGroup-based pickers

### Modified Capabilities
- `subsite-display-name`: `compactName` usage expands from View Tab only to all device picker group headers app-wide

## Impact

- **DeviceFilter.swift**: Group header display changes from `site.name` to `site.compactName`
- **DevicePickerView.swift** (Help & Feedback): Remove NvrGroupView, VssGroupView, BridgeGroupView sections; restructure to site-only grouping using CheckableGroup pattern
- **CustomizedViewEditorAddCamerasView.swift**: Group header uses `compactName`
- **AccessControlMessageFilter / SmartSensorMessageFilter**: Site display uses `compactName`
- **All makeCheckableGroupsFor* functions** in FeatureProvider: No structural change needed (already site-based), only display layer affected
- **Pages affected**: Message Search, DeepSearch, ReSearch, ThinkSearch, ProfileSearch, EventInsight, CustomizedView, Help & Feedback, AccessControl, SmartSensor
