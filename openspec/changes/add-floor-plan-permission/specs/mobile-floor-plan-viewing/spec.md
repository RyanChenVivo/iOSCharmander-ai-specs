## MODIFIED Requirements

### Requirement: Floor Plan Tab Navigation
The iOS app SHALL provide a dedicated Floor Plan tab in the home view navigation that allows users to access floor plan viewing functionality. Visibility is determined solely by Live View device privilege.

#### Scenario: Floor Plan tab is visible
- **WHEN** user has Live View privilege on at least one device
- **AND** license is not in renewal overdue state
- **THEN** Floor Plan tab appears in home navigation

#### Scenario: Floor Plan tab is hidden
- **WHEN** user has no devices with Live View privilege
- **OR** license is in renewal overdue state
- **THEN** Floor Plan tab does not appear in home navigation

## REMOVED Requirements

### Requirement: Feature Toggle Control
**Reason**: Floor plan visibility is no longer controlled by remote config `feature_floor_plan` flag or organization-level `SupportFeature`. Access is now determined by Live View device privilege, which is already the sole check in `FeatureToggle.canView(for: .floorPlan)`. The `RemoteConfigKey.feature_floor_plan` and `MyOrganization.SupportFeature.floorPlan` declarations are dead code being cleaned up.
**Migration**: No migration needed — `FeatureToggle.canView(for: .floorPlan)` already uses `hasAnyDeviceWithPrivilege(.live)` as the only check. Remove unused enum cases.
