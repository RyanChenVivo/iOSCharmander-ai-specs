## MODIFIED Requirements

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

### Requirement: API-layer error conversion for site deletion

The `siteAPIErrorHandle` SHALL convert all site-specific `BackendErrorType` cases to `VortexError`.

#### Scenario: Site-specific error types are converted

- **WHEN** the API returns a site-specific error
- **THEN** `siteAPIErrorHandle` SHALL convert:
  - `.restfulError(type: .siteHasDevices)` → `VortexError.siteHasDevices`
  - `.restfulError(type: .cannotDeleteSiteWithAreas)` → `VortexError.cannotDeleteSiteWithAreas`
  - `.restfulError(type: .cannotDeleteDefaultSite)` → `VortexError.cannotDeleteDefaultSite`
  - `.restfulError(type: .siteNotFound)` → `VortexError.siteNotFound`

---

### Requirement: Localized keys for delete errors

Each deletion error SHALL have its own localized key following the localization-guide convention (EN text with underscores, no punctuation).

#### Scenario: Localized key mapping

- **THEN** `AlertItem.getErrorMessage` SHALL return:
  - `.siteHasDevices` → `"Devices_must_be_moved_or_removed_first_before_deletion"`
  - `.cannotDeleteSiteWithAreas` → `"All_areas_must_be_deleted_first_before_deletion"`
  - `.cannotDeleteDefaultSite` → `"The_default_site_cannot_be_deleted"`
  - `.siteNotFound` → `"This_site_no_longer_exists"`
