# mobile-floor-plan-viewing Spec Delta

## MODIFIED Requirements

### Requirement: Site and Floor Plan List
The system SHALL display an expandable hierarchical list of sites with their associated floor plans, filtering out sites without floor plans.

#### Scenario: Display only sites with floor plans
- **WHEN** user opens Floor Plan tab
- **THEN** system displays only sites that have at least one floor plan
- **AND** sites without floor plans are filtered out from the list
- **AND** each site shows count and list of floor plans when expanded
- **AND** sites are sorted alphabetically

#### Scenario: Pull to refresh floor plans
- **WHEN** user performs pull-to-refresh gesture on floor plan list
- **THEN** system refreshes floor plan data from backend
- **AND** updates the list with latest floor plans
- **AND** re-applies filter to show only sites with floor plans

### Requirement: Shared Component Flexibility
The system SHALL provide flexible FloorPlanSiteGroup component that supports displaying either site names or custom names based on context.

#### Scenario: Display site group with custom name
- **WHEN** FloorPlanSiteGroup is initialized with displayName parameter
- **THEN** system displays the provided displayName in the group header
- **AND** uses same icon and layout as site-based display
- **AND** tapping header triggers onHeaderTapped callback if provided

#### Scenario: Display site group with site name (backward compatibility)
- **WHEN** FloorPlanSiteGroup is initialized with site parameter only
- **THEN** system displays site.name in the group header
- **AND** maintains existing behavior for site-tapped callback

### Requirement: Device Search Display and Clarity
The system SHALL display floor plan names instead of site names in device search results and provide clear search placeholder text.

#### Scenario: Device search shows floor plan name
- **WHEN** user opens device search from floor plan detail
- **AND** search results are displayed
- **THEN** system groups devices under floor plan name instead of site name
- **AND** displays floor plan name in group header
- **AND** uses FloorPlanSiteGroup with custom displayName

#### Scenario: Device search placeholder clarity
- **WHEN** device search view is displayed
- **THEN** search field placeholder shows "Device_search" localized text
- **AND** clearly indicates the search is for devices, not sites or floor plans

## REMOVED Requirements

### Requirement: Empty Site Display (Removed)
~~The system SHALL display empty state message when site has no floor plans.~~

#### Scenario: Empty site with no floor plans (Removed)
- ~~**WHEN** user expands a site with no floor plans~~
- ~~**THEN** system displays "No floor plans available" message~~

**Rationale**: Sites without floor plans are now filtered out entirely, making the empty state display unnecessary.

## Notes
- All changes maintain backward compatibility with existing floor plan viewing functionality
- Component refactoring follows existing SwiftUI patterns used in the codebase
- No API or data model changes required
- Localization keys follow project conventions (underscore-separated, no special characters)
