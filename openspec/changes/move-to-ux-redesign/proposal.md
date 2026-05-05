## Why

The current MoveToSiteView implementation uses a TreeView with expand/collapse behavior, but the new UX design requires a simpler always-expanded tree, search text highlighting, a "Current" location indicator, and a full-page move confirmation instead of an alert dialog. Additionally, the Add Device flow currently reuses MoveToSiteView with a `source: .add` branch, coupling two conceptually different operations. The UX redesign calls for a dedicated site picker for Add Device with Cancel/Save confirmation behavior, allowing both flows to evolve independently. These changes align the iOS app's site management UX with the updated design system.

## What Changes

- Remove expand/collapse chevrons from the site tree — all nodes always visible
- Add "Select a destination" label and "Create site or area" text button as a section header row
- Add "Current" label on the row matching the device's current site/area
- Add blue-background text highlighting for search keyword matches in site/area names
- Replace the move confirmation alert dialog with a dedicated full-page confirmation view (warning icon, attention message, "Move Device" button, Cancel)
- Move the "Move device" action button to a fixed bottom position (outside scroll area)
- Create a new `SiteSelectionView` + `SiteSelectionViewModel` for the Add Device flow: navigation title "Site", Cancel/Save toolbar, search bar, "Create site or area", tree list with single-select checkmark. Save confirms selection and pops back; Cancel discards change and pops back. Presented via NavigationLink push (same as today)
- Replace `MoveToSiteView(source: .add)` references in `AddDeviceByMacView` and `AddVSSView` with the new `SiteSelectionView`
- Remove `.add` case handling from `MoveToSiteView` and `MoveToSiteViewModel`, simplifying them to move-only logic
- Clean up `AnalyticsEvent.AddDeviceGroupSource.add` if it becomes unused

## Capabilities

### New Capabilities
- `move-confirmation-page`: Full-page move device confirmation view with warning icon, attention message, and action buttons — replacing the current alert-based confirmation
- `search-text-highlighting`: Blue-background highlighting of matched keyword text in site/area names during search
- `site-selection-page`: Standalone site picker page for Add Device flow — navigation title "Site", Cancel/Save toolbar, search, create site/area, tree list with checkmark selection

### Modified Capabilities
- `site-picker-tree-view`: Remove expand/collapse behavior — tree always renders fully expanded with no chevron indicators; remove `expandedIDs` state management
- `add-device-site-selection`: Replace MoveToSiteView usage with new SiteSelectionView; update selection behavior from immediate-dismiss to Save-to-confirm; remove Add-flow references from MoveToSiteView/ViewModel
- `move-to-site`: Remove `.add` source handling from MoveToSiteView/ViewModel, simplify to move-only logic

## Impact

- **TreeView component**: The generic TreeView loses its expand/collapse feature for the site picker use case. Consider whether TreeView should support an `alwaysExpanded` mode or whether MoveToSiteView should bypass TreeView and use a simpler flat rendering of the full hierarchy.
- **MoveToSiteView**: Layout restructured — new section header, current-site indicator, bottom-fixed button. Remove all `.add` source branching, becomes move-only.
- **MoveToSiteViewModel**: Needs to accept and expose `currentSiteID` for the "Current" label. Remove `source` enum and `.add` case logic.
- **SearchableTreeView**: Needs attributed string or overlay-based text highlighting for search matches.
- **Navigation flow**: Move confirmation changes from `.alert` modifier to a pushed/presented full-page view.
- **AddDeviceByMacView / AddVSSView**: NavigationLink destination changes from `MoveToSiteView(source: .add)` to new `SiteSelectionView`.
- **Shared components**: `SiteTreeRow`, `SearchableTreeView`, `HighlightedText`, `SiteInformationView` reused as-is by the new page.
- **Analytics**: Review whether `AddDeviceGroupSource.add` is still needed or can be replaced with a new event.
- **Tests**: `MoveToSiteViewModelTest` cases for `.add` source move to new `SiteSelectionViewModelTest`.
