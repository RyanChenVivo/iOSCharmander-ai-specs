## ADDED Requirements

### Requirement: Delete site permission gating

The system SHALL only show the delete option for sites/subsites when `FeatureProvider.canDelete(for:)` returns true for the given site.

#### Scenario: User with delete permission sees delete option

- **WHEN** user views a site in MoveToSiteView
- **AND** `FeatureProvider.canDelete(for: site)` returns true
- **THEN** a "Delete" option SHALL be visible in the site's context menu

#### Scenario: User without delete permission does not see delete option

- **WHEN** user views a site in MoveToSiteView
- **AND** `FeatureProvider.canDelete(for: site)` returns false
- **THEN** no "Delete" option SHALL be visible in the site's context menu

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

### Requirement: Successful deletion handling

The system SHALL dismiss the sheet and update state after successful deletion.

#### Scenario: Site deleted successfully

- **WHEN** the delete API returns 204 No Content
- **THEN** the sheet SHALL dismiss
- **AND** if the deleted site was the device's current site, the device's siteID SHALL be cleared

### Requirement: API-layer error conversion for site deletion

The `VortexRestfulApi` SHALL convert site-specific `BackendErrorType` to `VortexError` using a `siteAPIErrorHandle` method (following the `downgradeAPIErrorHandle` pattern).

#### Scenario: Site-specific error types are converted

- **WHEN** the delete API returns a site-specific error
- **THEN** `siteAPIErrorHandle` SHALL convert:
  - `.restfulError(type: .siteHasDevices)` → `VortexError.siteHasDevices`
  - `.restfulError(type: .cannotDeleteSiteWithSubSites)` → `VortexError.cannotDeleteSiteWithSubSites`
  - `.restfulError(type: .cannotDeleteDefaultSite)` → `VortexError.cannotDeleteDefaultSite`
- **AND** non-site errors SHALL pass through unchanged

### Requirement: Site deletion error message display

The `DeleteConfirmation` SHALL display localized error messages corresponding to the specific `VortexError` when site deletion fails.

#### Scenario: Site has devices (409)

- **WHEN** deletion fails with `VortexError.siteHasDevices`
- **THEN** the system SHALL display a localized message indicating the site cannot be deleted because it still contains devices

#### Scenario: Site has sub-sites (409)

- **WHEN** deletion fails with `VortexError.cannotDeleteSiteWithSubSites`
- **THEN** the system SHALL display a localized message indicating the site cannot be deleted because it has child subsites

#### Scenario: Cannot delete default site (409)

- **WHEN** deletion fails with `VortexError.cannotDeleteDefaultSite`
- **THEN** the system SHALL display a localized message indicating the default site cannot be deleted

#### Scenario: Other errors

- **WHEN** deletion fails with any other error
- **THEN** the system SHALL display a generic "Failed to delete" message

### Requirement: BackendErrorType extension for site deletion errors

The `BackendErrorType` enum SHALL include cases for site deletion-specific error types.

#### Scenario: New error type cases

- **WHEN** the backend returns a site deletion error
- **THEN** `BackendErrorType` SHALL decode the following types:
  - `cannotDeleteSiteWithSubSites` = `/problems/cannot-delete-site-with-sub-sites`
  - `siteHasDevices` = `/problems/site-has-devices`
  - `cannotDeleteDefaultSite` = `/problems/role-name-exist`

### Requirement: VortexError extension for site deletion

The `VortexError` enum SHALL include specific cases for site deletion failures.

#### Scenario: New VortexError cases

- **WHEN** site deletion fails with a known reason
- **THEN** the following `VortexError` cases SHALL be available:
  - `.cannotDeleteDefaultSite`
  - `.cannotDeleteSiteWithSubSites`
  - `.siteHasDevices`
