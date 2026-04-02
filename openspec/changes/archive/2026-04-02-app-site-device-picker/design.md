## Context

The app has multiple device picker/selector implementations across different features. Most already use site-based grouping via `CheckableGroup<SiteItem, DeviceItem>`, but two exceptions exist:

1. **DevicePickerView** (Help & Feedback): Uses four independent groups — NvrGroupView, VssGroupView, BridgeGroupView, and SiteView. NVR/VSS/Bridge devices appear in their own top-level groups, separate from the site hierarchy.

Additionally, `SiteItem.compactName` (budget-based truncated path, 18-char target) was introduced in the `subsite-display-name` change but is only used in View Tab's `SiteRow`. All other pickers display `site.name` (full path) in group headers, which can be excessively long for deeply nested subsites.

### Current site name usage in group headers

| Location | Current Display | Line |
|----------|----------------|------|
| DeviceFilter.swift | `site.name` | :57 |
| CustomizedViewEditorAddCamerasView.swift | `site.name` | :168 |
| DevicePickerView.swift | NVR/VSS/Bridge groups + SiteView | :66-70 |

## Goals / Non-Goals

**Goals:**
- All device pickers use site-only grouping — every device appears under its assigned Site/Subsite
- All site group headers display `compactName` instead of `name` for consistent, width-friendly display
- DevicePickerView restructured to site-based single-selection picker

**Non-Goals:**
- Tree/hierarchical UI (keep flat list of sites with `>` path notation)
- Changing the `makeCheckableGroupsFor*` functions in FeatureProvider (they already produce site-based groups)
- Modifying `compactName` algorithm parameters (budget, priority, etc.)
- Adding new device types or changing device type filtering logic
- Changing search behavior (already matches on `SiteItem.name` full path via `Searchable`)

## Decisions

### Decision 1: Replace `site.name` with `site.compactName` in all group headers

**Approach:** Change `Text(site.name)` to `Text(site.compactName)` in `DeviceFilter.siteView(_:)` and `CustomizedViewEditorAddCamerasView.GroupItemView.groupRow`.

**Why this is safe:** `compactName` is a computed property already available on every `SiteItem`. Search still works on `SiteItem.name` (full path) via the `Searchable` protocol — `compactName` is display-only. Sort order is unchanged (based on `Comparable` which uses `name`).

**Why not add a new display property?** `compactName` was designed exactly for this purpose — width-constrained group headers. No new abstraction needed.

### Decision 2: Restructure DevicePickerView to site-based grouping

**Approach:** Replace the four independent groups (NvrGroupView, VssGroupView, BridgeGroupView, SiteView) with a single site-based structure. Use `DeviceManager` to build `[SiteItem: [DeviceItem]]` groups where NVR, VSS, and Bridge devices are placed under their assigned Sites alongside cameras.

**Current structure (to remove):**
```
NvrGroupView (flat NVR list)
VssGroupView (flat VSS list)
BridgeGroupView (flat Bridge list)
SiteView (cameras under sites)
```

**New structure:**
```
Site A
  ├── NVR-1
  ├── Camera-1
  └── Camera-2
Site B
  ├── Bridge-1
  ├── VSS-1
  └── Camera-3
```

**Why not keep NVR/VSS/Bridge as separate groups?** The new requirement explicitly states all grouping must be site-based. Device-type grouping creates an inconsistent experience where the same NVR appears isolated from the site it belongs to.

**Search mode:** Currently search mode also separates by device type. After this change, search results should display as a flat filtered list (matching current DeviceFilter search behavior via `Searchable` protocol).

**Single-selection behavior:** DevicePickerView is a single-selection picker (tap to select and dismiss). This behavior is preserved — only the grouping changes.

## Risks / Trade-offs

- **[DevicePickerView restructure changes device discovery UX]** → Users who relied on finding NVRs/VSSes/Bridges in dedicated groups will now need to find them under their site. Search remains available as fallback. This is an intentional design alignment.
- **[compactName truncation may lose context in some cases]** → The budget-based algorithm prioritizes last segment (most specific), which is the right trade-off for site group headers. UI tail truncation is the final safety net.
