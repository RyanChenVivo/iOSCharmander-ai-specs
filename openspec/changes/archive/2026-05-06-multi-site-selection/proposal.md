## Why

The Message tab filters (Access Control, Smart Sensor) currently use a flat-list `MultipleSelectionView` for site selection, but sites are inherently hierarchical (sites → areas → sub-areas). The existing `SiteSelectionView` (created in `move-to-ux-redesign`) already renders sites as a tree with search and highlighting, but only supports single selection. Extending it with multi-select mode provides a consistent tree-based site picker across the app while matching the updated Figma design for message filters.

## What Changes

- Extend `SiteSelectionView` with two public inits (single-select and multi-select), using an internal `SiteSelectionMode` enum for branching
- Add a new `SiteCheckboxTreeRow` component for multi-select checkbox rendering, sharing tree layout logic with existing `SiteTreeRow`
- Update `SiteSelectionViewModel` to manage either `String?` (single) or `[SiteItem]` (multi) selection state
- In multi mode: show `ToggleAllSectionHeader` (N/M selected + Select all / Deselect all), hide "Create site or area" button and context menus
- Replace `MultipleSelectionView` usage for site selection in `AccessControlMessageSearchView` and `SmartSensorMessageSearchView` with `SiteSelectionView(selectedSites:items:)`
- Support `allowEmptySelection` parameter in multi mode to control Save button behavior

## Capabilities

### New Capabilities
- `multi-site-selection`: Multi-select mode for SiteSelectionView — tree-based site/area picker with checkboxes, select all/deselect all, count display, search with highlighting, and Save-to-confirm UX

### Modified Capabilities
- `add-device-site-selection`: SiteSelectionView API changes from `Binding<DeviceItem>` to `SiteSelectionMode.single(Binding<String?>)` — callers must adapt to the new init signature

## Impact

- **SiteSelectionView / SiteSelectionViewModel**: Major refactor — two public inits, internal mode enum for branching
- **SiteTreeRow**: Unchanged — continues to serve single-select and MoveToSite
- **SiteCheckboxTreeRow (new)**: Shares tree indentation/layout with SiteTreeRow, uses checkbox icons
- **AccessControlMessageSearchView**: `groupSection` switches from `MultipleSelectionView` to `SiteSelectionView(selectedSites:items:)`
- **SmartSensorMessageSearchView**: Same as above
- **AddDeviceByMacView / AddVSSView**: Caller update to new `SiteSelectionView(selectedSiteID:)` init
- **ToggleAllSectionHeader**: Reused as-is for multi mode control bar
- **Prerequisite**: Depends on `move-to-ux-redesign` change (SiteSelectionView, SearchableTreeViewModel, SiteTreeRow)
