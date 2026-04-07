## REMOVED Requirements

### Requirement: Default site fallback for new devices
**Reason**: The legacy `defaultSiteID` property in `AddDeviceViewModel` provided a fallback site (the organization-level site) when no explicit selection was made. This conflicts with the existing "No default Site pre-selection" requirement and the new Site Management spec's site-first workflow. The fallback code path is dead code since explicit site selection is already enforced.
**Migration**: No migration needed. The "No default Site pre-selection in Add Device flow" requirement already governs this behavior. Remove `defaultSiteID` computed property from `AddDeviceViewModel`.
