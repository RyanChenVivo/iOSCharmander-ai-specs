## Context

`FloorPlanManager.fetchAllFloorPlans()` currently fetches floor plans for every site returned by `deviceManager.allSites()`, including sites with zero devices. This is wasteful — empty sites cannot have meaningful floor plans.

Currently, the Manager internally decides which sites to query. The goal is to shift site filtering responsibility to the ViewModel layer via `FeatureProvider`, following the established pattern used by `accessibleSitesForSmartSensorMessageSearch()`.

### Current Flow
```
FloorPlanTabViewModel.fetchAll()
  -> floorPlanManager.fetchAllFloorPlans()
       -> deviceManager.allSites()          // gets ALL sites
       -> fetchBatch(sites:) for each site  // queries ALL, wastes API calls
```

### Target Flow
```
FloorPlanTabViewModel.fetchAll()
  -> featureProvider.accessibleSitesForFloorPlan()  // filtered by .live privilege
  -> floorPlanManager.fetchAllFloorPlans(sites:)    // only queries accessible sites
```

## Goals / Non-Goals

**Goals:**
- Filter out sites where the user has no device with `.live` privilege before querying floor plan API
- Follow the `accessibleSitesFor*` pattern established in `FeatureProvider` / `FeatureToggle`
- Change `FloorPlanManager.fetchAllFloorPlans()` interface to accept sites from the caller (ViewModel)

**Non-Goals:**
- No UI changes
- No new API endpoints
- No changes to floor plan detail or device position logic
- No remote config / feature toggle gating for this optimization (it is always-on)

## Decisions

### 1. Use `.live` device privilege for site filtering

**Choice:** Filter sites by checking `hasDevicePrivilege(device, .live)` on each device.

**Why:** Floor plans display camera placements — only sites with cameras the user can view (live permission) are relevant. This aligns with the upcoming `add-floor-plan-permission` model.

**Alternative considered:** Filter by device count only (any device present). Rejected because a user without `.live` privilege on any device at a site shouldn't see that site's floor plans.

### 2. ViewModel passes filtered sites to Manager (interface change)

**Choice:** Change `fetchAllFloorPlans()` to `fetchAllFloorPlans(sites: [SiteItem])`. The ViewModel calls `featureProvider.accessibleSitesForFloorPlan()` and passes the result.

**Why:** Follows the existing pattern where ViewModels use `FeatureProvider` to determine accessible sites (see `SmartSensorMessageSearchViewModel`). Keeps permission logic in `FeatureProvider`/`FeatureToggle`, not in the Manager.

**Alternative considered:** Have the Manager call `FeatureProvider` internally. Rejected because Managers in this codebase don't depend on `FeatureProvider` — that's a ViewModel-layer concern.

### 3. Add `accessibleSitesForFloorPlan()` to FeatureProvider protocol

**Choice:** New method on `FeatureProvider` protocol, implemented in `FeatureToggle` with the standard pattern:
```swift
func accessibleSitesForFloorPlan() -> [SiteItem] {
    let hasPrivilegeSiteIDs = devices
        .filter { hasDevicePrivilege($0, .live) }
        .map { $0.siteID }
        .uniqued()
    return sites.filter { hasPrivilegeSiteIDs.contains($0.id) }
}
```

**Why:** Identical structure to `accessibleSitesForSmartSensorMessageSearch()` but with `.live` instead of `.allUsers`. Consistent, testable, mockable.

## Risks / Trade-offs

- **Low risk** — This is an additive filter. The existing `fetchBatch` already filters out sites with no floor plans after the API call; this optimization reduces unnecessary API calls before they happen.
- **Behavioral change** — Sites where the user has devices but no `.live` privilege will no longer show floor plans. This is intentional and correct per the permission model.
- **No rollback concern** — No migration, no data changes. Reverting is a simple code revert.
