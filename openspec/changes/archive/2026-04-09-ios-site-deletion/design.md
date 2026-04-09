## Context

The iOS app currently supports site CRUD except deletion. The backend REST API `DELETE /v1/sites/{siteId}` already exists and returns:
- **204** No Content on success
- **404** `/problems/not-found` — site doesn't exist
- **409** `/problems/cannot-delete-site-with-sub-sites` — site has child subsites
- **409** `/problems/site-has-devices` — site still contains devices
- **409** `/problems/role-name-exist` — cannot delete default site (API type name is misleading but confirmed via Apidog)
- **500** `/problems/server-error`

The existing `BackendErrorType` enum does not include these 409 error types. The `DeviceManager` already has `deleteSite(_:)` and `deleteSite(by:)` methods that call `VortexRestfulApi.deleteSite(id:)`, but currently no error differentiation — all errors are caught generically.

`FeatureProvider` already defines `canDelete(for site: SiteItem) -> Bool` for permission gating.

Site deletion is accessed from `MoveToSiteView` (in the AddDevice/move-to-site flow), where sites are listed with a context menu containing a delete option gated by `FeatureProvider.canDelete(for:)`. The existing `DeleteConfirmation` sheet handles destructive confirmations with "DELETE" text input.

## Goals / Non-Goals

**Goals:**
- Support site/subsite deletion via `DeleteConfirmation` sheet with "DELETE" text confirmation
- Convert backend 409 error types to specific `VortexError` cases in the API layer (following `siteAPIErrorHandle` pattern like `downgradeAPIErrorHandle`)
- Display localized error messages mapped from `VortexError` in the `DeleteConfirmation` error handler
- Refresh site tree after successful deletion

**Non-Goals:**
- Client-side prerequisite checks (device count, subsite count) — rely on backend 409 responses
- Batch deletion of multiple sites
- Undo/restore deleted sites
- Adding delete to ViewTab — deletion stays in MoveToSiteView context menu

## Decisions

### 1. Backend-driven error handling over client-side prerequisite checks

Rely on backend 409 responses to determine why deletion failed, rather than pre-fetching device counts and subsite counts on the client.

**Rationale**: The backend already enforces these constraints. Pre-fetching adds extra API calls, introduces race conditions, and duplicates business logic.

### 2. API-layer error conversion following `downgradeAPIErrorHandle` pattern

Add `siteAPIErrorHandle` private method in `VortexRestfulApi` (site MARK section) that converts `.restfulError(type:)` to specific `VortexError` cases. The general `convertBackendErrorTypeToVortexError` stays unchanged — only handles general errors.

**Rationale**: Follows established pattern. ViewModel layer only sees `VortexError`, never `BackendErrorType`. Future site APIs can reuse `siteAPIErrorHandle`.

### 3. Reuse existing `DeleteConfirmation` sheet with new `.site` type

Add `.site(SiteItem)` to `DeleteConfirmationType`. The `DeleteConfirmation` view already supports "DELETE" text confirmation for devices — extend it for sites. Error handling is site-specific in the delete button's catch block.

**Rationale**: Consistent UX with device deletion. No new views needed.

### 4. `MoveToSiteViewModel` opens `DeleteConfirmation` sheet

`tapDeleteSiteButton` calls `SheetManager.shared.openDeleteConfirmation(type: .site(site))` instead of deleting directly. The `DeleteConfirmationViewModel` handles the actual API call.

**Rationale**: Matches the device deletion flow. Ensures "DELETE" text confirmation before any destructive action.

## Risks / Trade-offs

- **[Risk] Backend error type string mismatch** → `/problems/role-name-exist` for "cannot delete default site" is a backend naming issue. → Mitigation: Map it explicitly in `BackendErrorType.cannotDeleteDefaultSite`.
- **[Risk] Concurrent modification** → Another user adds devices between opening delete dialog and confirming. → Mitigation: Backend 409 handles this; we show the error.
- **[Trade-off] No client-side pre-check** → User won't see "this site has 3 devices" before attempting. → Acceptable: simplifies flow, avoids extra API calls.
