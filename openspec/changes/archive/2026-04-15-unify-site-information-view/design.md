## Context

Two views handle site/area management with overlapping responsibilities:

- `SiteInformationView` + `SiteInformationViewModel` (commit cfd2b229): Create and edit root-level sites. Accepts `SiteItem?` — nil for create, non-nil for edit. Used by `MoveToSiteView` for both create and edit navigation destinations.
- `CreateSiteView` + `CreateSiteViewModel` (branch feat/supportSubsite): Create sites and areas with type picker and parent picker. Not wired into any navigation flow.

Both share identical UI patterns (name field, location section, toolbar save/create button, loading overlay) and API calls (`deviceManager.createSite`, `deviceManager.updateSite`).

Backend API constraints:
- `POST /v1/sites`: accepts `name`, `location`, `parentId` (optional) — supports creating both sites and areas
- `PATCH /v1/sites/{siteID}`: accepts `name`, `location` only — no `parentId`, works for both sites and areas
- Site vs Area distinction: a site has no `parentId`, an area has a non-empty `parentId`

## Goals / Non-Goals

**Goals:**
- Unify `SiteInformationView` to handle all four scenarios: create site, create area, edit site, edit area
- Absorb `CreateSiteView`'s type picker and parent picker into `SiteInformationView`
- Delete `CreateSiteView` and `CreateSiteViewModel` to eliminate duplication
- Preserve existing navigation flow in `MoveToSiteView` (already uses `SiteInformationView`)

**Non-Goals:**
- Adding `parentId` to `UpdateSiteInput` / PATCH API (backend limitation, not in scope)
- Allowing type change during edit (a site cannot become an area or vice versa via edit)
- Modifying `MoveToSiteView` navigation structure
- Refactoring `DeviceManager` or `VortexRestfulApi` layer

## Decisions

### 1. Expand SiteInformationView rather than CreateSiteView

SiteInformationView is already wired into MoveToSiteView's navigation for both create (`site: nil`) and edit (`site: SiteItem`). Expanding it preserves all existing call sites. CreateSiteView is only referenced in its own Preview.

Alternative considered: Expand CreateSiteView to support edit mode. Rejected — "CreateSiteView" naming is misleading for edit operations, and rewiring MoveToSiteView navigation is unnecessary churn.

### 2. Determine site vs area by parentId, not by stored type

In edit mode, the view checks `site.parentId` to decide whether the item is a site or area. No separate "type" field is stored. In create mode, a `SiteCreationType` picker lets the user choose.

This matches the backend model where the only distinction is whether `parentId` is empty or not.

### 3. Extract NavigationPlaceholderRow to its own file

`NavigationPlaceholderRow` is defined in `CreateSiteView.swift` but used by both `SiteInformationView` and `CreateSiteView`. Before deleting `CreateSiteView.swift`, extract it to `NavigationPlaceholderRow.swift`.

### 4. Move ParentSiteSection and ParentSitePickerSheet into SiteInformationView

These two private types are small and only used by the site information form. Keep them as private structs within `SiteInformationView.swift` rather than creating separate files.

### 5. Toolbar button varies by mode

- Create mode: `NavigationCreateButton` (action text implies creation)
- Edit mode: `NavigationSaveButton` (action text implies saving changes)

This preserves the existing UX distinction between creating a new entity and saving edits.

### 6. Unified SiteInformationViewModel with mode-aware logic

The ViewModel's `init(site:)` determines behavior:
- `site == nil` → create mode, type picker visible, default name generated
- `site != nil` → edit mode, type picker hidden, fields populated from site

The `tapSaveButton()` method dispatches to `createSite()` or `updateSite()` based on mode, identical to the current pattern.

## Risks / Trade-offs

**SiteInformationView grows in complexity** → The view handles four scenarios instead of two. Mitigated by clear conditional branching on `isEditMode` and `isArea` computed properties. The view body remains straightforward with conditional sections.

**CreateSiteViewModelTest needs migration** → Existing tests for `CreateSiteViewModel` must be rewritten against `SiteInformationViewModel`. The test scenarios are the same; only the class under test changes.

**NavigationPlaceholderRow extraction touches Xcode project file** → Adding a new file requires updating `project.pbxproj`. Use the `file-management-rules` skill during implementation.
