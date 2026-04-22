# mobile-floor-plan-viewing — License Control Delta

## ADDED Requirements

### Requirement: Floor Plan License Tier Access Control

The system SHALL restrict floor plan tab access based on the organization's license tier. xLite (free plan) organizations SHALL be blocked from accessing floor plan content and shown a commercial promotion page instead.

#### Scenario: xLite user sees promotion page instead of floor plan content

- **WHEN** user belongs to a free plan (xLite) organization
- **AND** user navigates to the Floor Plan tab
- **THEN** system SHALL display a `FloorPlanFeaturePromotionView` instead of floor plan content
- **AND** the promotion page SHALL follow the `FeaturePromotionView` pattern used by Archive and AI Hub tabs
- **AND** the promotion page SHALL include a title, description, background image, and optional "Explore More" link
- **AND** `featureToggle.canAccess(for: .floorPlan)` SHALL return `false`

#### Scenario: Paid organization user accesses floor plan normally

- **WHEN** user belongs to a paid organization (xStd or xPro)
- **AND** organization phase is Valid, NoticePeriod, or GracePeriod
- **THEN** system SHALL grant full access to the floor plan tab content
- **AND** `featureToggle.canAccess(for: .floorPlan)` SHALL return `true`

#### Scenario: Floor plan promotion model provides tab-specific content

- **WHEN** the system needs to display a promotion page for floor plan
- **THEN** `HomeViewTab.floorPlan.promotionModel` SHALL return a `FeaturePromotionModel`
- **AND** the model SHALL include a localized title, description, and background image resource
- **AND** the promotion description SHALL read: "See the entire property at a glance. VORTEX Floor Plan turns building layouts into interactive security maps, with cameras placed at their real-world positions and coverage areas visualized on screen. To access this feature, contact your reseller for upgrade options."
- **AND** "VORTEX" in the description SHALL be replaced with the product name via `VortexEnvironment.productNameLocalized`
- **AND** the background image asset SHALL be `img_floorplan_sample` (light/dark × 1x/2x/3x)

### Requirement: Floor Plan Access During RenewalOverdue

The system SHALL disable the floor plan tab when the organization enters RenewalOverdue phase, consistent with the existing lockdown pattern applied to all feature tabs.

#### Scenario: Floor plan tab disabled during RenewalOverdue

- **WHEN** the organization license phase is RenewalOverdue
- **THEN** `featureToggle.canTrigger(for: .floorPlan)` SHALL return `false`
- **AND** the Floor Plan tab item SHALL be visually disabled (greyed out)
- **AND** tapping the disabled tab SHALL have no effect
- **AND** the tab SHALL remain visible in the tab bar (not removed)

#### Scenario: Floor plan tab re-enabled after license renewal

- **WHEN** the organization license phase transitions from RenewalOverdue back to Valid
- **THEN** `featureToggle.canTrigger(for: .floorPlan)` SHALL return `true`
- **AND** the Floor Plan tab SHALL become interactive again
- **AND** all previously saved floor plan data SHALL be accessible

### Requirement: Floor Plan Access During Grace Period and Notice Period

The system SHALL maintain full floor plan access during NoticePeriod and GracePeriod phases for paid organizations.

#### Scenario: Floor plan fully accessible during NoticePeriod

- **WHEN** the organization license phase is NoticePeriod
- **THEN** `featureToggle.canAccess(for: .floorPlan)` SHALL return `true`
- **AND** `featureToggle.canTrigger(for: .floorPlan)` SHALL return `true`
- **AND** all floor plan functionality SHALL be unrestricted

#### Scenario: Floor plan fully accessible during GracePeriod

- **WHEN** the organization license phase is GracePeriod
- **THEN** `featureToggle.canAccess(for: .floorPlan)` SHALL return `true`
- **AND** `featureToggle.canTrigger(for: .floorPlan)` SHALL return `true`
- **AND** all floor plan functionality SHALL be unrestricted

### Requirement: Floor Plan API 423 — Not Applicable to iOS

The iOS app SHALL NOT implement dedicated HTTP 423 error handling for floor plan APIs. Per the high-level spec's API enforcement matrix, HTTP 423 is only returned for create/modify operations during RenewalOverdue. The iOS app is read-only for floor plans (only calls GET list and GET device-positions) — these endpoints always return 200 regardless of license phase. The existing generic `appManager.handleError` SHALL serve as a safety net for any unexpected HTTP errors.

#### Scenario: iOS app never encounters 423 from floor plan APIs

- **WHEN** the iOS app calls floor plan GET endpoints (list floor plans, get device positions)
- **THEN** the backend SHALL always return HTTP 200 regardless of license phase
- **AND** the iOS app SHALL NOT require dedicated 423 error mapping or handling
- **AND** the existing `appManager.handleError` SHALL handle any unexpected HTTP errors as a safety net

### Requirement: Floor Plan Downgrade Prerequisite

The system SHALL include floor plan data deletion as a prerequisite item in the organization downgrade checklist when transitioning from paid to free (xLite) plan.

#### Scenario: Floor plan mission appears in downgrade checklist

- **WHEN** user views the downgrade eligibility checklist via `postCheckDowngrade()` API
- **AND** the backend returns a floor plan-related `CheckDowngradeItem`
- **THEN** system SHALL parse the item into a `MissionType.floorPlan` case
- **AND** system SHALL display title: "Delete floor plans" and description: "You must delete all floor plan data before downgrading."
- **AND** the backend `mission` string is `"FLOOR_PLAN_LIMIT"`, parsed into `MissionType.floorPlan`

#### Scenario: Floor plan mission not present for organizations without floor plans

- **WHEN** user views the downgrade eligibility checklist
- **AND** the backend does NOT return a floor plan `CheckDowngradeItem`
- **THEN** system SHALL NOT display a floor plan mission item
- **AND** the downgrade flow SHALL proceed without floor plan prerequisite

### Requirement: Live License Phase Transition Handling

The system SHALL handle license phase transitions while the user is actively using the floor plan feature, dismissing floor plan detail views and updating tab state reactively.

#### Scenario: Organization transitions to RenewalOverdue while viewing floor plan detail

- **WHEN** user is viewing a floor plan detail (presented via SheetManager)
- **AND** the organization license phase transitions to RenewalOverdue
- **THEN** system SHALL dismiss the floor plan detail sheet
- **AND** the Floor Plan tab SHALL become disabled (greyed out)

#### Scenario: Organization transitions to free plan while viewing floor plan

- **WHEN** user is on the Floor Plan tab
- **AND** the organization transitions from paid to free plan
- **THEN** `FloorPlanTabView` SHALL re-render to show the promotion page
- **AND** if a floor plan detail sheet is open, system SHALL dismiss it
- **AND** no floor plan API calls SHALL be made after the transition

#### Scenario: Organization license renews while on promotion page

- **WHEN** user is viewing the floor plan promotion page (xLite)
- **AND** the organization transitions from free to paid plan
- **THEN** `FloorPlanTabView` SHALL re-render to show the normal floor plan content
- **AND** system SHALL fetch floor plan data automatically

### Requirement: Floor Plan Data Freshness

The Floor Plan tab SHALL NOT independently refresh device/site data from the backend. Site and device data may be stale relative to the latest backend state; the user is responsible for triggering a refresh (e.g., pull-to-refresh on the Home/View tab) to update shared device and site data.

#### Scenario: Floor plan tab uses existing cached site data

- **WHEN** user navigates to the Floor Plan tab
- **THEN** system SHALL use the currently cached site data from `featureProvider.accessibleSitesForFloorPlan()`
- **AND** system SHALL NOT call `deviceManager.fetchAll()` to refresh site/device data
- **AND** system SHALL only fetch floor plan data via `floorPlanManager.fetchAllFloorPlans()`

#### Scenario: User triggers floor plan refresh

- **WHEN** user performs pull-to-refresh on the Floor Plan tab
- **THEN** system SHALL re-fetch floor plan data using the currently cached site list
- **AND** system SHALL NOT trigger a full device/site data refresh
- **AND** if the user needs updated site data, they must refresh from the Home or View tab first

## MODIFIED Requirements

### Requirement: Feature Toggle Control

The system SHALL control Floor Plan tab visibility through feature toggles in FeatureProvider following existing patterns. Additionally, Floor Plan tab access SHALL be gated by license tier, and the tab SHALL be disabled (not removed) during RenewalOverdue.

#### Scenario: Feature flag enabled

- **WHEN** remote config `feature_floor_plan` is true
- **AND** user has site read permissions
- **AND** organization support features include `floorPlan`
- **THEN** Floor Plan tab appears in `supportedHomeViewTabs()`

#### Scenario: Feature flag disabled

- **WHEN** remote config `feature_floor_plan` is false
- **THEN** Floor Plan tab does not appear regardless of permissions

#### Scenario: License renewal overdue disables tab

- **WHEN** organization license phase is RenewalOverdue
- **THEN** Floor Plan tab SHALL remain visible in the tab bar
- **AND** Floor Plan tab SHALL be disabled (greyed out) via `canTrigger(for: .floorPlan)` returning `false`
- **AND** tapping the disabled tab SHALL have no effect

#### Scenario: Free plan blocks floor plan access

- **WHEN** organization is on the free plan (xLite)
- **AND** Floor Plan tab is visible (feature flag enabled, support features include floorPlan)
- **THEN** `canAccess(for: .floorPlan)` SHALL return `false`
- **AND** the tab content SHALL show a promotion page instead of floor plan data
