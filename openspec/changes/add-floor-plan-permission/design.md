## Context

The floor plan feature's visibility is currently guarded by three mechanisms:
1. `RemoteConfigKey.feature_floor_plan` — remote config flag (declared but unused in `FeatureToggle`)
2. `MyOrganization.SupportFeature.floorPlan` — organization-level dark release enum case (declared but unused)
3. `hasAnyDeviceWithPrivilege(.live)` — the actual runtime check in `FeatureToggle.canView(for: .floorPlan)`

Items 1 and 2 are dead code — they exist as declarations but are not referenced in any visibility logic. The platform is migrating floor plan access control to granular Live View permissions managed by the backend. The APP needs to clean up these dead declarations.

## Goals / Non-Goals

**Goals:**
- Remove `SupportFeature.floorPlan` enum case from `MyOrganization`
- Remove `RemoteConfigKey.feature_floor_plan` enum case
- Update spec to reflect that floor plan visibility depends solely on Live View device privilege
- Ensure `SupportFeature` Codable decoding handles unknown values gracefully (in case backend still sends `"FloorPlan"`)

**Non-Goals:**
- No client-side site/camera filtering (backend handles this)
- No Edit Mode permission support (APP is view-only)
- No new permission change detection (existing mechanism is sufficient)
- No changes to `FeatureToggle.canView(for: .floorPlan)` logic (already correct)

## Decisions

### Decision 1: Remove enum cases rather than deprecate

Remove `SupportFeature.floorPlan` and `RemoteConfigKey.feature_floor_plan` outright rather than marking them deprecated. These are dead code with no consumers — deprecation would be misleading.

**Alternative considered**: Keep them as deprecated. Rejected because no code references them, so deprecation warnings would never fire.

### Decision 2: Verify SupportFeature Codable resilience

Before removing `SupportFeature.floorPlan`, verify that the enum's `Codable` implementation handles unknown raw values gracefully. If the backend still sends `"FloorPlan"` in API responses after this change, a missing case could cause decode failures.

**Approach**: Check if `SupportFeature` uses a custom `init(from:)` or if it will crash on unknown values. If it crashes, the case should be kept until the backend confirms removal.

### Decision 3: No changes to FeatureToggle logic

`FeatureToggle.canView(for: .floorPlan)` already returns `hasAnyDeviceWithPrivilege(.live)` with no reference to `SupportFeature` or remote config. No logic change is needed.

## Risks / Trade-offs

- **[Codable decode failure]** → If `SupportFeature` does not handle unknown raw values and backend still sends `"FloorPlan"`, removing the case causes a runtime crash. **Mitigation**: Verify Codable implementation before removing; if fragile, keep case until backend confirms removal.
- **[Remote config cleanup timing]** → Firebase remote config may still have `feature_floor_plan` defined server-side. **Mitigation**: Removing the enum case is safe — unrecognized remote config keys are ignored by the client.
