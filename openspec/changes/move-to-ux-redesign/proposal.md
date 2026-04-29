## Why

The current MoveToSiteView implementation uses a TreeView with expand/collapse behavior, but the new UX design requires a simpler always-expanded tree, search text highlighting, a "Current" location indicator, and a full-page move confirmation instead of an alert dialog. These changes align the iOS app's site management UX with the updated design system.

## What Changes

- Remove expand/collapse chevrons from the site tree — all nodes always visible
- Add "Select a destination" label and "Create site or area" text button as a section header row
- Add "Current" label on the row matching the device's current site/area
- Add blue-background text highlighting for search keyword matches in site/area names
- Replace the move confirmation alert dialog with a dedicated full-page confirmation view (warning icon, attention message, "Move Device" button, Cancel)
- Move the "Move device" action button to a fixed bottom position (outside scroll area)

## Capabilities

### New Capabilities
- `move-confirmation-page`: Full-page move device confirmation view with warning icon, attention message, and action buttons — replacing the current alert-based confirmation
- `search-text-highlighting`: Blue-background highlighting of matched keyword text in site/area names during search

### Modified Capabilities
- `site-picker-tree-view`: Remove expand/collapse behavior — tree always renders fully expanded with no chevron indicators; remove `expandedIDs` state management
- `add-device-site-selection`: Add "Select a destination" / "Create site or area" section header; add "Current" label for the device's current site/area; move action button to fixed bottom position

## Impact

- **TreeView component**: The generic TreeView loses its expand/collapse feature for the site picker use case. Consider whether TreeView should support an `alwaysExpanded` mode or whether MoveToSiteView should bypass TreeView and use a simpler flat rendering of the full hierarchy.
- **MoveToSiteView**: Layout restructured — new section header, current-site indicator, bottom-fixed button.
- **MoveToSiteViewModel**: Needs to accept and expose `currentSiteID` for the "Current" label.
- **SearchableTreeView**: Needs attributed string or overlay-based text highlighting for search matches.
- **Navigation flow**: Move confirmation changes from `.alert` modifier to a pushed/presented full-page view.
