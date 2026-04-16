# Add Floor Plan License Control

## Why

The floor plan feature is currently gated by `MyOrganization.SupportFeature.floorPlan` and remote config, but lacks license tier enforcement. xLite (free plan) users can access floor plan if the backend returns it in `supportFeatures`, and there is no enforcement for RenewalOverdue lockdown or paid-to-free transition cleanup. Floor plan is a premium capability that should only be available to xStd/xPro license holders, with proper lifecycle handling aligned to the organization-license-lifecycle pattern already used by Archive and AI Hub tabs.

## What Changes

- **License tier gating**: xLite (free plan) organizations SHALL be blocked from floor plan access and shown a commercial/upgrade promotion page
- **RenewalOverdue lockdown**: Floor plan tab SHALL be disabled (greyed out) when organization enters RenewalOverdue phase, consistent with existing lockdown pattern for other tabs; floor plan data preserved
- **Grace period / Notice period handling**: Floor plan access SHALL remain fully available during NoticePeriod and GracePeriod phases (no change from current behavior for paid orgs)
- **Commercial promotion page**: xLite users attempting to access floor plan SHALL see a locked feature promotion page following the existing `FeaturePromotionView` pattern (similar to Archive and AI Hub)
- **API 423 enforcement handling**: Floor plan API calls SHALL handle HTTP 423 (Locked) responses for license-blocked scenarios (RenewalOverdue blocks create/modify; xLite blocks all)
- **Paid-to-free transition**: Floor plan data elimination on downgrade — downgrade checklist SHALL include floor plan data deletion prerequisite
- **Live transition handling**: If organization phase transitions while user is viewing floor plan, app SHALL refresh and display commercial page
- **BREAKING**: xLite users who previously had floor plan access will lose it and see a commercial page instead

## Capabilities

### New Capabilities

_(none — all changes modify existing capabilities)_

### Modified Capabilities

- `mobile-floor-plan-viewing`: Add license tier checks to tab visibility/access/trigger logic; add commercial promotion page for xLite; add RenewalOverdue disable behavior; add API 423 handling; add live transition refresh; add downgrade prerequisite checklist entry

## Impact

- **FeatureToggle.swift**: Modify `canView(for: .floorPlan)`, `canAccess(for: .floorPlan)`, `canTrigger(for: .floorPlan)` to incorporate license tier and phase checks (currently only checks `supportFeatures.contains(.floorPlan)`)
- **FeatureProvider.swift**: Update `accessibleSitesForFloorPlan()` protocol if license-level filtering needed
- **FloorPlanTabView / FloorPlanTabViewModel**: Add commercial promotion page display when `canAccess` returns false; handle live phase transition refresh
- **FeaturePromotionView.swift**: Add floor plan promotion variant (image, copy, upgrade CTA) — **TBD: exact ad copy and promotional image asset**
- **VortexRestfulApi error handling**: Handle HTTP 423 response for floor plan API calls (blocked on API field confirmation — tracked in tasks)
- **Downgrade flow**: Add floor plan data deletion as prerequisite checklist item — need to identify where downgrade checklist is rendered
- **KA org**: Not applicable — KA exemption is handled entirely by the backend; the iOS app receives already-resolved license states and does not need KA-specific logic
- **Existing specs affected**: `mobile-floor-plan-viewing` (delta spec for license control additions)
