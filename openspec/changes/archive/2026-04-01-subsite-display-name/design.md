## Context

The API (`getSites`) returns a flat list of `Site` objects, each with an `id`, `name`, `parentId`, and optional `location`. The `parentId` field exists but is currently ignored — all `SiteItem` objects are constructed with the raw API name. Hierarchy depth is unbounded (site → subsite → subsite → ...).

`SiteItem` is a UI-layer display model, not an API model. Its `name` property is consumed by all downstream UI: ViewTab site lists, CheckableGroup-based device filters (MessageFilter, DeepSearch, ThinkSearch, EventInsight, ProfileSearch, ReSearch, CustomizedViewEditor), MoveToSiteView, and FloorPlan site lists. It also implements `Searchable` (matches on `name`) and `Comparable` (sorts on `name`).

## Goals / Non-Goals

**Goals:**
- Subsite display names include full ancestor path (e.g., "Taipei Office > 3F > Meeting Room")
- All UI surfaces automatically reflect the change with zero View-layer modifications
- Search and sort work correctly on full path names

**Non-Goals:**
- Nested/tree UI rendering (keep flat list)
- API or response structure changes
- Create/edit site flows (these operate on `Site` model directly, not `SiteItem`)
- Permission/access control changes for subsites

## Decisions

### Decision 1: Store `pathComponents` on `SiteItem`, derive `name` and `compactName` from it

**Approach:** After receiving the flat `[Site]` from API, build a `[String: Site]` lookup by `id`. For each site, `DeviceManager.resolvePathComponents` walks the `parentId` chain to root and returns `[String]` components. These are passed to `SiteItem.init` as `pathComponents`. `SiteItem.name` is derived by joining components in `init`. `SiteItem.compactName` is a computed property that applies the budget-based algorithm lazily on access.

**Why store `pathComponents` instead of pre-computing `compactName`?** With 1000+ sites, pre-computing all compact names in `fetchAll()` wastes resources. As a computed property, `compactName` is only calculated when the view actually renders a site row (e.g., visible rows in a LazyVStack).

**Why not a separate `displayName` property on `SiteItem`?** Every consumer already reads `.name` — adding `displayName` would require changing every View, `Searchable`, and `Comparable` implementation. Since `SiteItem` is a display model (not an API model), its `name` should represent what's displayed.

**Why not resolve at View layer?** Would scatter the same resolution logic across 10+ Views and require passing site lookup context everywhere.

### Decision 2: Cycle protection with visited-set

Since `parentId` chains come from external API data, a malformed response could create cycles. The resolution loop tracks visited IDs and breaks on cycle detection, falling back to whatever path was resolved so far.

### Decision 3: Separator `" > "`

Matches common breadcrumb convention. Visually distinct from site names which typically don't contain `>`.

## Risks / Trade-offs

- **[`SiteItem.name` no longer matches API raw name]** → No current consumer needs the raw name. `createSite`/`deleteSite` use `Site.id`. If a future feature needs the original name, add an `originalName` property to `SiteItem` at that time.
- **[Long path names on deeply nested sites]** → `compactName` uses budget-based algorithm (target 18 chars, priority: last > first > middle). Last segment is never truncated; UI tail truncation is the final safety net. First segment is guaranteed minimum 5 characters. Middle segments share budget equally — if per-segment budget < 2 chars, all middles collapse to `…`; otherwise each is truncated to its share and leftover returns to first.
- **[Malformed `parentId` data (cycles, orphan references)]** → Cycle protection via visited-set; orphan `parentId` (pointing to non-existent site) terminates the chain — the resolved portion becomes the display name.
