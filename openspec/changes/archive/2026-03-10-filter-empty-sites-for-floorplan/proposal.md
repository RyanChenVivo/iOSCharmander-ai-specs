## Why

When fetching floor plans for all sites, `FloorPlanManager.fetchAllFloorPlans()` currently queries every site returned by `deviceManager.allSites()`, including sites that have zero devices. Querying floor plans for device-less sites is wasteful — these sites cannot have meaningful floor plan usage (no cameras to place). Filtering them out before making API calls reduces unnecessary network requests and improves load time, especially for organizations with many empty sites.

This also aligns with the upcoming floor-plan-permission model (see `add-floor-plan-permission` change) where site visibility requires Live View permission for at least one camera — sites with no devices would be hidden regardless.

## What Changes

- **Filter sites without devices before floor plan queries**: In `FloorPlanManager.fetchAllFloorPlans()`, use `DeviceManager` to check each site for devices and skip sites with zero devices before calling the floor plan API.
- No API changes, no new UI — this is a data-fetching optimization in the Manager layer.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

_(none — this is an internal optimization within `FloorPlanManager` that does not change spec-level behavior. Sites without devices would never have floor plans with placed cameras, so the observable behavior is equivalent.)_

## Impact

- **Affected code**: `FloorPlanManager.fetchAllFloorPlans()`, `FloorPlanManager.fetchBatch(sites:)`
- **Dependencies**: `DeviceManagerProtocol` — relies on existing `allDevices()` or `findDevicesOnViewTab(bySiteID:)` to determine device presence per site
- **Risk**: Low — filtering is additive (reduces API calls), and the existing "filter out sites without floor plans" logic in `fetchBatch` already handles the downstream case
