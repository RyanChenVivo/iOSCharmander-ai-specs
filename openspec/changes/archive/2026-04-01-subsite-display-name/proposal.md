## Why

The API already returns `parentId` for each site, but the app ignores it entirely — all sites display as a flat list with their raw names. When an organization has subsites (e.g., "Taipei Office > 3F > Meeting Room"), users cannot tell which site belongs to which parent, causing confusion. The simplified requirement: without changing API/response structure or UI hierarchy (keep flat list), make subsite display names include the full ancestor path.

## What Changes

- `DeviceManager.fetchAll()` resolves each site's full ancestor path via `parentId` chain, stores path components on `SiteItem.pathComponents`, and derives `SiteItem.name` by joining them (e.g., `"Taipei Office > 3F > Meeting Room"`)
- `SiteItem.compactName` is a computed property that lazily applies budget-based truncation to `pathComponents` — only computed when the view renders
- All downstream UI automatically picks up the change since they all read `SiteItem.name` — zero View-layer modifications
- Search: matches against full path name (searching "3F" hits "Taipei Office > 3F")
- Sort: alphabetical on full path name — subsites under the same parent naturally group together

## Capabilities

### New Capabilities
- `subsite-display-name`: Resolve flat site list into full ancestor-path display names using `parentId` chain

### Modified Capabilities
- `ios-view-tab-device-management`: Site names change from raw API names to full ancestor-path names, affecting site count display, search matching, and sort order

## Impact

- **Core**: `DeviceManager.fetchAll()` — path resolution via `resolvePathComponents`; `SiteItem` — stores `pathComponents`, derives `name` in init, computes `compactName` lazily
- **UI (zero changes)**: ViewTab (`SiteView`, `ViewTabSiteView`, `ViewTabSiteSearchingView`), all `makeCheckableGroups` consumers (MessageFilter, DeepSearch, ThinkSearch, EventInsight, ProfileSearch, ReSearch, CustomizedViewEditor), `MoveToSiteView`, FloorPlan site list — all read `SiteItem.name`, automatically correct
- **Tests**: `SiteItemTest` for compactName scenarios; `DeviceManagerTest` for path resolution integration; `TestUtility.makeSiteItem` accepts `pathComponents` parameter
