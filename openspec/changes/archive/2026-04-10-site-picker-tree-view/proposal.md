## Why

The App currently displays Site lists only in a flattened format with ">" path notation. For Site/Area selection contexts (Add Device, Move Device destination), users need a tree view to visualize the hierarchy at a glance and navigate to the correct level. A reusable tree view component with expand/collapse support is needed to replace the flat list in these contexts.

## What Changes

- Create a reusable Site Picker tree view component with expand/collapse navigation (Site → L1 Area → L2 Area)
- Hide expand indicator for Sites/Areas with no children
- Apply the tree view component to Site selection in Add Device and Move Device flows (replacing the current flat list in MoveToSiteView)

## Capabilities

### New Capabilities
- `site-picker-tree-view`: Reusable tree view component for Site/Area hierarchy selection with expand/collapse, applied in Add Device and Move Device destination contexts

### Modified Capabilities
- `add-device-site-selection`: MoveToSiteView uses tree view component instead of flat list for Site/Area selection

## Impact

- **UI Components**: New shared SitePickerTreeView component; MoveToSiteView updated to use it
- **App Pages**: Add Device flow, Move Device flow
