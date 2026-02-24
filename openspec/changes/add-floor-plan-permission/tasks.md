## 1. Verify Codable Resilience

- [ ] 1.1 Check `MyOrganization.SupportFeature` Codable implementation — verify it handles unknown raw values gracefully (custom `init(from:)` or will crash on unknown)
- [ ] 1.2 If fragile: add unknown-value handling before removing `floorPlan` case; if resilient: proceed to removal

## 2. Remove Dead Code

- [ ] 2.1 Remove `floorPlan` case from `MyOrganization.SupportFeature` enum in `VortexFeatures/Sources/VortexFeatures/Core/VortexBackend/Model/Organization/MyOrganization.swift`
- [ ] 2.2 Remove `feature_floor_plan` case from `RemoteConfigKey` enum in `VortexFeatures/Sources/VortexFeatures/Common/RemoteConfigProvider/RemoteConfigKey.swift`
- [ ] 2.3 Search for and remove any remaining references to `SupportFeature.floorPlan` or `feature_floor_plan` across the codebase

## 3. Verify and Test

- [ ] 3.1 Build the project and confirm no compile errors from removed enum cases
- [ ] 3.2 Verify `FeatureToggle.canView(for: .floorPlan)` still returns `hasAnyDeviceWithPrivilege(.live)` — no unintended changes
- [ ] 3.3 Run existing floor plan unit tests (`FloorPlanTabViewModelTest`, `FloorPlanDetailViewModelTest`, `FloorPlanManagerTest`) and confirm they pass
