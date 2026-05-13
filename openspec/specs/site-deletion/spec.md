# site-deletion Specification

## Purpose
Covers site/area deletion functionality including permission gating, confirmation flow, API error handling, and state updates.

## Requirements

### Requirement: Delete site permission gating

The system SHALL only show the delete option for sites/areas when `FeatureProvider.canDelete(for:)` returns true for the given site.

#### Scenario: User with delete permission sees delete option

- **WHEN** user views a site in MoveToSiteView
- **AND** `FeatureProvider.canDelete(for: site)` returns true
- **THEN** a "Delete" option SHALL be visible in the site's context menu

#### Scenario: User without delete permission does not see delete option

- **WHEN** user views a site in MoveToSiteView
- **AND** `FeatureProvider.canDelete(for: site)` returns false
- **THEN** no "Delete" option SHALL be visible in the site's context menu

---

### Requirement: Delete confirmation via DeleteConfirmation sheet

The system SHALL open the `DeleteConfirmation` sheet with type `.site(SiteItem)` requiring the user to type "DELETE" before executing site deletion.

#### Scenario: User taps delete on a site

- **WHEN** user taps the delete option in a site's context menu
- **THEN** the system SHALL open `DeleteConfirmation` sheet via `SheetManager.shared.openDeleteConfirmation(type: .site(site))`
- **AND** the sheet SHALL display site-specific title, warning message, and "DELETE" text input

#### Scenario: User types DELETE and confirms

- **WHEN** user types "DELETE" (case-sensitive) in the confirmation text field
- **AND** taps the "Delete" button
- **THEN** the system SHALL call `DeviceManager.deleteSite(site)` which calls `DELETE /v1/sites/{siteId}`

#### Scenario: User cancels deletion

- **WHEN** user taps "Cancel" on the confirmation sheet
- **THEN** no API call SHALL be made
- **AND** the sheet SHALL dismiss

---

### Requirement: Successful deletion handling

The system SHALL dismiss the sheet and update state after successful deletion.

#### Scenario: Site deleted successfully

- **WHEN** the delete API returns 204 No Content
- **THEN** the sheet SHALL dismiss
- **AND** if the deleted site was the device's current site, the device's siteID SHALL be cleared

---

### Requirement: API-layer error conversion for site deletion

The `siteAPIErrorHandle` SHALL convert all site-specific `BackendErrorType` cases to `VortexError`.

#### Scenario: Site-specific error types are converted

- **WHEN** the API returns a site-specific error
- **THEN** `siteAPIErrorHandle` SHALL convert:
  - `.restfulError(type: .siteHasDevices)` → `VortexError.siteHasDevices`
  - `.restfulError(type: .cannotDeleteSiteWithAreas)` → `VortexError.cannotDeleteSiteWithAreas`
  - `.restfulError(type: .cannotDeleteDefaultSite)` → `VortexError.cannotDeleteDefaultSite`
  - `.restfulError(type: .siteNotFound)` → `VortexError.siteNotFound`
- **AND** non-site errors SHALL pass through unchanged

---

### Requirement: Site deletion error message display

The `DeleteConfirmation` SHALL display distinct localized error messages when site/area deletion fails, matching high-level spec scenario language.

#### Scenario: Site/Area has devices (409)

- **WHEN** deletion fails with `VortexError.siteHasDevices`
- **THEN** the system SHALL display alert with title `"Failed to delete"` and message `"Devices must be moved or removed first before deletion."`

#### Scenario: Site has areas (409)

- **WHEN** deletion fails with `VortexError.cannotDeleteSiteWithAreas`
- **THEN** the system SHALL display alert with title `"Failed to delete"` and message `"All areas must be deleted first before deletion."`

#### Scenario: Cannot delete default site (409)

- **WHEN** deletion fails with `VortexError.cannotDeleteDefaultSite`
- **THEN** the system SHALL display alert with title `"Failed to delete"` and message `"The default site cannot be deleted."`

#### Scenario: Site not found (404)

- **WHEN** deletion fails with `VortexError.siteNotFound`
- **THEN** the system SHALL display alert with title `"Failed to delete"` and message `"This site no longer exists."`

#### Scenario: Other errors

- **WHEN** deletion fails with any other error
- **THEN** the system SHALL display a generic "Failed to delete" message with retry guidance

---

### Requirement: Localized keys for delete errors

Each deletion error SHALL have its own localized key following the localization-guide convention (EN text with underscores, no punctuation).

#### Scenario: Localized key mapping

- **THEN** `AlertItem.getErrorMessage` SHALL return:
  - `.siteHasDevices` → `"Devices_must_be_moved_or_removed_first_before_deletion"`
  - `.cannotDeleteSiteWithAreas` → `"All_areas_must_be_deleted_first_before_deletion"`
  - `.cannotDeleteDefaultSite` → `"The_default_site_cannot_be_deleted"`
  - `.siteNotFound` → `"This_site_no_longer_exists"`

---

### Requirement: BackendErrorType for site deletion errors

The `BackendErrorType` enum SHALL include cases for site deletion-specific error types.

#### Scenario: Error type cases

- **THEN** `BackendErrorType` SHALL decode:
  - `cannotDeleteSiteWithAreas` = `/problems/cannot-delete-site-with-sub-sites`
  - `siteHasDevices` = `/problems/site-has-devices`
  - `cannotDeleteDefaultSite` = `/problems/role-name-exist`
  - `siteNotFound` = `/problems/site-not-found`

---

### Requirement: VortexError for site deletion

The `VortexError` enum SHALL include specific cases for site deletion failures.

#### Scenario: VortexError cases

- **THEN** the following `VortexError` cases SHALL be available:
  - `.cannotDeleteDefaultSite`
  - `.cannotDeleteSiteWithAreas`
  - `.siteHasDevices`
  - `.siteNotFound`
