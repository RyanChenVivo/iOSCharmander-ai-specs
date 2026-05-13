## MODIFIED Requirements

### Requirement: SiteInformationView navigation title

SiteInformationView SHALL use a unified navigation title `"Create site or area"` for both Site and Area creation modes.

#### Scenario: Navigation title in create mode

- **WHEN** in create mode with "Site" type selected
- **THEN** the navigation title SHALL be `"Create site or area"`
- **WHEN** in create mode with "Area" type selected
- **THEN** the navigation title SHALL be `"Create site or area"`
- **WHEN** in edit mode with a site (no parentId)
- **THEN** the navigation title SHALL be `"Site information"`
- **WHEN** in edit mode with an area (has parentId)
- **THEN** the navigation title SHALL be `"Area information"`

---

### Requirement: Site creation error handling

The system SHALL handle all backend 403 errors during site/area creation and display user-friendly messages, including xlite-specific errors and the general organization-level limit.

#### Scenario: Organization-level site and area limit exceeded

- **WHEN** backend returns 403 with type `/problems/site-limit-exceeded`
- **THEN** system SHALL display error message `"The organization-level site and area limit has been reached."`

#### Scenario: Hierarchy depth exceeded

- **WHEN** backend returns 403 with type `/problems/hierarchy-depth-exceeded`
- **THEN** system SHALL display error message `"The maximum area nesting depth has been reached. You cannot create a deeper level."`

#### Scenario: Area count exceeded

- **WHEN** backend returns 403 with type `/problems/subsite-count-exceeded`
- **THEN** system SHALL display error message `"The maximum number of areas under this parent has been reached."`

#### Scenario: xlite area not allowed

- **WHEN** backend returns 403 with type `/problems/xlite-area-not-allowed`
- **THEN** system SHALL display error message `"Multi-level hierarchy is not available on the xLite plan. Contact your reseller to upgrade."`

#### Scenario: xlite site limit exceeded

- **WHEN** backend returns 403 with type `/problems/xlite-site-limit-exceeded`
- **THEN** system SHALL display error message `"Maximum 10 sites reached. Contact your reseller to upgrade your service."`

---

### Requirement: BackendErrorType extension for xlite errors

The `BackendErrorType` enum SHALL include cases for xlite-specific site creation errors.

#### Scenario: New error type cases

- **THEN** `BackendErrorType` SHALL decode:
  - `xliteAreaNotAllowed` = `/problems/xlite-area-not-allowed`
  - `xliteSiteLimitExceeded` = `/problems/xlite-site-limit-exceeded`

---

### Requirement: VortexError extension for xlite errors

The `VortexError` enum SHALL include specific cases for xlite site creation failures.

#### Scenario: New VortexError cases

- **THEN** the following `VortexError` cases SHALL be available:
  - `.xliteAreaNotAllowed`
  - `.xliteSiteLimitExceeded`

---

### Requirement: siteAPIErrorHandle mapping for xlite errors

The `siteAPIErrorHandle` SHALL convert xlite error types to their corresponding `VortexError`.

#### Scenario: xlite errors are converted

- **WHEN** the API returns an xlite-specific error
- **THEN** `siteAPIErrorHandle` SHALL convert:
  - `.restfulError(type: .xliteAreaNotAllowed)` → `VortexError.xliteAreaNotAllowed`
  - `.restfulError(type: .xliteSiteLimitExceeded)` → `VortexError.xliteSiteLimitExceeded`

---

### Requirement: Localized key convention for site creation errors

All localized keys SHALL follow the localization-guide convention (EN text with underscores, no punctuation).

#### Scenario: AlertItem key mapping for creation errors

- **THEN** `AlertItem.getErrorMessage` SHALL return:
  - `.reachSiteLimit` → `"The_organization-level_site_and_area_limit_has_been_reached"`
  - `.hierarchyDepthExceeded` → `"The_maximum_area_nesting_depth_has_been_reached_You_cannot_create_a_deeper_level"`
  - `.areaCountExceeded` → `"The_maximum_number_of_areas_under_this_parent_has_been_reached"`
  - `.xliteAreaNotAllowed` → `"Multi-level_hierarchy_is_not_available_on_the_xLite_plan_Contact_your_reseller_to_upgrade"`
  - `.xliteSiteLimitExceeded` → `"Maximum_10_sites_reached_Contact_your_reseller_to_upgrade_your_service"`
