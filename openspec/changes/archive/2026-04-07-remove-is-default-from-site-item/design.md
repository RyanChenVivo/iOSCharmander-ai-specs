## Context

`SiteItem` has an `isDefault` boolean field set when `site.id == orgID` during `fetchAll()`. This marks the organization-level site as a special "ungrouped" bucket. The field influences 4 behaviors: sort order, icon display, delete protection, and device fallback assignment.

The new Site Management specs (portal + app) replace this concept entirely:
- Unassigned devices are identified by `site_id = null`, not by a special site
- All sites are equal — no special "default" site exists
- Site deletion is governed by permissions, not by a hardcoded `isDefault` check
- Add Device requires explicit site selection (no fallback to default)

Current usages of `isDefault`:

| Location | Usage | New Behavior |
|----------|-------|-------------|
| `SiteItem.Comparable.<` | Default site sorts last | Pure alphanumeric sort |
| `SiteItem+Extension.icon` | Different icon for default | Unified icon for all sites |
| `FeatureToggle.canDelete(for:)` | Default site undeletable | All sites deletable (permission-based) |
| `DeviceManager.findDefaultSite()` | Find org site for device moves | Removed |
| `DeviceManager.moveAllDevicesToUngrouped()` | Move devices to default site | Refactored to use `myOrganization.getID()` |
| `AddDeviceViewModel.defaultSiteID` | Fallback site for new devices | Removed (dead code, explicit selection enforced) |

## Goals / Non-Goals

**Goals:**
- Remove `isDefault` field from `SiteItem` and all dependent logic
- Align codebase with Site Management spec before integration work begins
- Preserve `moveAllDevicesToUngrouped()` functionality for UAT/UITest usage

**Non-Goals:**
- Implementing the full Site Management feature (separate changes)
- Changing the `moveAllDevicesToUngrouped` API contract — only its internal implementation changes
- Modifying any backend API behavior

## Decisions

**Decision**: Refactor `moveAllDevicesToUngrouped()` to use `myOrganization.getID()` directly instead of `findDefaultSite()`.

**Rationale**: The method needs the org ID to call `postSiteDevicesMove`. Currently it gets it indirectly via `findDefaultSite()?.id`. Since `myOrganization.getID()` is already available in `DeviceManager` (used in `fetchAll()`), we can call it directly. This preserves the exact same API behavior for UAT/UITests.

**Alternative considered**: Remove `moveAllDevicesToUngrouped()` entirely — rejected because it's actively used by UITests for environment setup.

---

**Decision**: Remove `SiteItem+Extension.icon` conditional and use a single icon (`iconGeneralGroupSolid`) for all sites.

**Rationale**: The new spec treats all sites uniformly. The "ungrouped" visual distinction no longer applies. If a different icon strategy is needed for Site Management, it will be introduced in that change.

---

**Decision**: Remove `isDefault` guard from `FeatureToggle.canDelete(for:)`, leaving only the permission check.

**Rationale**: The new spec states all sites (including system-generated ones) are deletable by users with appropriate permissions. The `isDefault` protection was specific to the legacy model where the org site was permanent.

---

**Decision**: Remove `defaultSiteID` from `AddDeviceViewModel` without replacement.

**Rationale**: The `add-device-site-selection` spec already mandates explicit site selection with no pre-selection. `defaultSiteID` is dead code that was superseded but never cleaned up.

## Risks / Trade-offs

**[Risk] `moveAllDevicesToUngrouped` becomes async** → The refactored version calls `myOrganization.getID()` which is async. The method is already async, so no API change needed. Mitigation: verify UITest call sites handle this correctly (they already do — called via `try await`).

**[Risk] Sort order change visible to users** → Sites previously sorted with the org site pinned last will now sort alphabetically. Mitigation: This is intentional per the new spec's "ascending alphanumeric order by display title" requirement. Low risk since the org-named site typically sorts naturally among other sites.

**[Risk] Org site becomes deletable** → Removing the `canDelete` guard means users could delete the org-named site. Mitigation: This is correct per spec — the system-generated site is explicitly described as "editable and deletable by users". Backend should enforce its own constraints if needed.
