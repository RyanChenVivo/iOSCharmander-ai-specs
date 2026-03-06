## MODIFIED Requirements

### Requirement: Site and Floor Plan List
The system SHALL display an expandable hierarchical list of sites with their associated floor plans, filtering out sites without floor plans. The navigation title SHALL use the `Floorplans` localization key.

#### Scenario: Display only sites with floor plans
- **WHEN** user opens Floor Plan tab
- **THEN** system displays only sites that have at least one floor plan
- **AND** sites without floor plans are filtered out from the list
- **AND** each site shows count and list of floor plans when expanded
- **AND** sites are sorted alphabetically

#### Scenario: Navigation title displays localized "Floorplans"
- **WHEN** user opens Floor Plan tab
- **THEN** navigation title SHALL use the `Floorplans` localization key
- **AND** English locale SHALL display "Floorplans"
- **AND** Traditional Chinese and Japanese locales SHALL display the same translations as the `Floor_plan` key

#### Scenario: Pull to refresh floor plans
- **WHEN** user performs pull-to-refresh gesture on floor plan list
- **THEN** system refreshes floor plan data from backend
- **AND** updates the list with latest floor plans
- **AND** re-applies filter to show only sites with floor plans

### Requirement: Shared Component Flexibility
The system SHALL provide flexible FloorPlanSiteGroup component that supports displaying either site names or custom names based on context, using a location mark icon for site identification.

#### Scenario: Display site group with custom name
- **WHEN** FloorPlanSiteGroup is initialized with displayName parameter
- **THEN** system displays the provided displayName in the group header
- **AND** uses `iconGeneralLocationMark` icon in the group header
- **AND** tapping header triggers onHeaderTapped callback if provided

#### Scenario: Display site group with site name (backward compatibility)
- **WHEN** FloorPlanSiteGroup is initialized with site parameter only
- **THEN** system displays site.name in the group header
- **AND** uses `iconGeneralLocationMark` icon in the group header
- **AND** maintains existing behavior for site-tapped callback

### Requirement: Floor Plan Search
The system SHALL provide search functionality to filter floor plans by name across all sites, with a localized search placeholder via the custom `searchable(text:isActive:prompt:)` extension.

#### Scenario: Search bar displays localized placeholder
- **WHEN** search bar is visible on Floor Plan tab
- **THEN** search field SHALL display placeholder text from `Search_floor_plans_or_sites` localization key
- **AND** English: "Search floor plans or sites"
- **AND** Traditional Chinese: "搜尋平面圖或站點"
- **AND** Japanese: "フロアプランまたはサイトを検索"

#### Scenario: Search bar default placeholder
- **WHEN** `searchable(text:isActive:)` is called without a `prompt` parameter
- **THEN** search field SHALL display the system default placeholder (localized "Search")

#### Scenario: Search floor plans by keyword
- **WHEN** user enters keyword in search bar
- **THEN** system filters floor plan list to show only matching floor plans
- **AND** highlights matching text in floor plan names
- **AND** shows sites containing matching floor plans

#### Scenario: Clear search results
- **WHEN** user clears search keyword
- **THEN** system restores full floor plan list
- **AND** removes highlighting
