# Proposal: Refine Floor Plan UI

## Overview
Refine the Floor Plan feature UI to improve data filtering, search functionality, and component reusability based on user feedback.

## Motivation
Current Floor Plan UI has several areas that can be improved:
1. **Empty Sites Display**: Sites without floor plans are shown with empty state messages, adding visual clutter
2. **Search Confusion**: FloorPlanDetail search shows site names instead of floor plan names, causing confusion when searching for devices
3. **Search Placeholder**: Generic "Search" placeholder doesn't clearly indicate device search functionality
4. **Component Inflexibility**: FloorPlanSiteGroup is hardcoded to display site names, limiting reusability for contexts requiring floor plan names

## Scope
This change refines existing Floor Plan UI components with focused improvements:
- Filter sites without floor plans from the main tab view
- Update device search to display floor plan names instead of site names
- Improve search placeholder text clarity
- Refactor FloorPlanSiteGroup to support flexible label display

## Changes

### Affected Capabilities
- **mobile-floor-plan-viewing**: Modified to update site filtering, device search display, and shared component design

### New Files
None - all changes modify existing components

### Modified Files
- `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanTabView.swift` - Update to filter empty sites
- `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanTabViewModel.swift` - Add site filtering logic
- `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanSiteView.swift` - Filter sites without floor plans
- `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanSiteGroup.swift` - Refactor to accept flexible display name, remove empty floor plan display
- `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanDetail/FloorPlanDeviceSearchView.swift` - Update to show floor plan names and improve placeholder
- `iOSCharmander/View/Home/Tab/FloorPlanTab/EmptyFloorPlanView.swift` - May be removed if no longer needed

### Dependencies
None - self-contained UI refinements

## Risk Assessment
**Low Risk**: All changes are isolated UI improvements that don't affect data models or business logic.

- No API changes
- No data structure modifications
- Backwards compatible UI refinements
- Can be rolled back easily by reverting component changes

## Testing Strategy
- Manual testing of floor plan list filtering
- Verify sites without floor plans are hidden
- Test device search displays floor plan names correctly
- Verify search placeholder text is clear
- Test FloorPlanSiteGroup in both contexts (site name and floor plan name)
- Verify existing FloorPlanTabViewModel unit tests still pass

## Implementation Notes
- Follow existing MVVM patterns
- Use existing localization keys or add new ones with proper format
- Maintain SwiftUI reactive patterns
- Keep changes minimal and focused
