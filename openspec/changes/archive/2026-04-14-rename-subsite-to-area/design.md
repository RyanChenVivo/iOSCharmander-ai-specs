## Context

The Portal has adopted "Area" as the official term replacing "Subsite". The iOS app still uses "Subsite" in UI labels, error messages, and localization strings. Additionally, CreateSiteView currently only creates top-level Sites and needs to support creating Areas (child nodes with parentId).

Current state:
- `Site` model already has `parentId` — backend supports hierarchy
- `CreateSiteView` / `CreateSiteViewModel` only create top-level sites
- `AddSiteInput` only sends `name` + `location` (no `parentId`)
- UI strings: "Subsite" appears in `BackendError.swift`, `VortexError.swift`, `AlertItem.swift`, `DeleteConfirmation.swift`
- Localization: "Create site" in `Localizable.xcstrings`

Backend API status (`POST /v1/sites`):
- Request body already supports `parentId` (optional, omit or empty string for top-level)
- Returns three 403 errors:
  - `/problems/site-limit-exceeded`: overall site count limit reached
  - `/problems/hierarchy-depth-exceeded`: hierarchy depth limit exceeded (e.g., creating a 4th level)
  - `/problems/subsite-count-exceeded`: child count per level exceeded

## Goals / Non-Goals

**Goals:**
- Replace all "Subsite" terminology with "Area" in UI strings
- Add type selection (Site / Area) to CreateSiteView, with parent picker for Area mode
- Add `parentId` to `AddSiteInput` and pass it through the API layer
- Handle three backend 403 errors with user-friendly messages

**Non-Goals:**
- Renaming `Site`, `SiteItem` model/struct names (backend still uses "site")
- Client-side hierarchy depth/count validation (backend handles this, app only handles error responses)
- Modifying tree view component (already implemented in `site-picker-tree-view`)
- Renaming `DeviceManager.createSite` method name

## Decisions

### 1. Terminology rename is UI-only

"Subsite" → "Area" only in user-facing strings and spec files. Code identifiers remain unchanged to stay consistent with backend API naming.

### 2. Add optional `parentId` to `AddSiteInput`

Add `parentId: String?` to `AddSiteInput`. Pass `nil` when creating a Site, pass the selected parent's ID when creating an Area. Impact chain: `DeviceManagerProtocol` → `DeviceManager` → `VortexRestfulApi.postSite` → `AddSiteInput`.

### 3. Add type selection to CreateSiteViewModel

New `SiteCreationType` enum (`.site`, `.area`). Site mode shows Name + Location (current behavior); Area mode shows Name + Parent picker (presented as sheet with tree view).

### 4. Reuse existing tree view for parent picker

Area parent selection presented as a sheet, reusing `MoveToSiteView`'s tree view component, consistent with the location picker presentation pattern.

### 5. No client-side validation, rely on backend error handling

Backend already validates three constraints on `POST /v1/sites` (site-limit-exceeded, hierarchy-depth-exceeded, subsite-count-exceeded), all returning 403. App does not need to pre-compute depth or count — just intercept these errors and display corresponding localized error messages.

Alternative considered: Client-side pre-filtering of invalid parent options. Rejected — adds complexity and may drift out of sync with backend limits. Relying on backend responses is more reliable.

## Risks / Trade-offs

**Backend 403 errors need new error mapping** → `BackendError` / `VortexError` need new cases for `hierarchy-depth-exceeded` and `subsite-count-exceeded`. `site-limit-exceeded` may already exist.

**Localization requires translator review** → "Subsite" → "Area" is straightforward in English, but translation team needs to update other locales. New error messages also need translation.

**UX: error only after submission** → Without client-side validation, users see errors only after submitting the form. Acceptable since these are edge cases (exceeding depth/count limits) that most users won't encounter.
