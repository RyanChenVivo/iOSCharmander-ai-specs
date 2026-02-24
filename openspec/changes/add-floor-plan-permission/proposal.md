## Why

The floor plan feature currently uses a `SupportFeature: FloorPlan` organization-level dark release gate and a `RemoteConfigKey.feature_floor_plan` remote config flag. The platform is migrating to granular Live View permissions for floor plan access control. The APP side needs to remove these dead feature gates since `FeatureToggle.canView(for: .floorPlan)` already solely relies on `hasAnyDeviceWithPrivilege(.live)`.

## What Changes

- Remove `SupportFeature.floorPlan` case from `MyOrganization.SupportFeature` enum (dead code)
- Remove `RemoteConfigKey.feature_floor_plan` case from remote config keys (dead code)
- Update `mobile-floor-plan-viewing` spec to reflect that visibility is controlled by Live View permission only, not by remote config or organization support features

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `mobile-floor-plan-viewing`: Floor Plan Tab Navigation requirements change — remove remote config flag `feature_floor_plan` as a visibility condition; visibility is now solely determined by Live View device privilege

## Impact

- `VortexFeatures/Sources/VortexFeatures/Core/VortexBackend/Model/Organization/MyOrganization.swift` — remove `floorPlan` case from `SupportFeature` enum
- `VortexFeatures/Sources/VortexFeatures/Common/RemoteConfigProvider/RemoteConfigKey.swift` — remove `feature_floor_plan` case
- `mobile-floor-plan-viewing` spec scenarios referencing `feature_floor_plan` remote config flag need updating
- Risk: `SupportFeature` is a `Codable` enum — must verify unknown value handling if backend still sends `"FloorPlan"`
