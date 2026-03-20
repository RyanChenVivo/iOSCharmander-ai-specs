## ADDED Requirements

### Requirement: OpenFGA PrivilegeProvider initialization
The system SHALL provide an `.openFGA` static instance of `PrivilegeProvider` that can be injected via `swift-dependencies` as an alternative to `.casbin`. When `initial(userPolicy)` is called, the OpenFGA provider SHALL extract `subject` (userId) and `domain` (orgId) from the `UserPolicy` parameter and perform two-phase loading:

**Phase 1 (blocking):**
1. A single batch-check request against the organization to determine all org-level permissions and userType
2. Five concurrent list-objects requests to preload critical device relations: `can_live`, `can_all_users`, `can_archive_read`, `can_ai_search`, `can_ai_event_insight`

**Phase 2 (fire-and-forget background):**
3. Remaining ~15 device relations loaded concurrently in a background Task: `can_playback`, `can_export_video`, `can_share`, `can_settings`, `can_event_snooze`, `can_archive_create`, `can_archive_update`, `can_archive_delete`, `can_archive_play`, `can_archive_download`, `can_archive_share`, `can_ai_search_feedback`, `can_talkdown`, `can_lock`, `can_unlock`, `can_admin_restricted`

#### Scenario: Successful initialization as owner
- **WHEN** `initial(userPolicy)` is called with a userId that has `can_all` on the organization
- **THEN** `getUserType()` SHALL return `.owner`
- **AND** all org scope permissions SHALL be cached
- **AND** the 5 Phase 1 device relations SHALL be cached per device

#### Scenario: Successful initialization as admin
- **WHEN** `initial(userPolicy)` is called with a userId that has `can_admin_restricted` but not `can_all` on the organization
- **THEN** `getUserType()` SHALL return `.admin`

#### Scenario: Successful initialization as regular member
- **WHEN** `initial(userPolicy)` is called with a userId that has neither `can_all` nor `can_admin_restricted` on the organization
- **THEN** `getUserType()` SHALL return `.regular`

#### Scenario: Initialization network failure
- **WHEN** the OpenFGA API is unreachable during `initial`
- **THEN** the system SHALL throw an error
- **AND** no partial cache SHALL be retained

### Requirement: Organization permission query (sync)
The system SHALL evaluate org-level permissions **synchronously** from the cache populated at initialization. `canDoOrganization(scope)` SHALL map the `PrivilegeOrganizationScope` enum to its corresponding OpenFGA relation name and look up the cached result. No `await` is required.

#### Scenario: Query a permitted org scope
- **WHEN** `canDoOrganization(.userInvite)` is called for a user whose batch-check returned `can_user_invite: true`
- **THEN** the result SHALL be `true`

#### Scenario: Query a denied org scope
- **WHEN** `canDoOrganization(.adminRestricted)` is called for a regular member
- **THEN** the result SHALL be `false`

### Requirement: Device permission query (sync with safe default)
The system SHALL evaluate device-level permissions **synchronously** using a per-device cache keyed by `DeviceCompositeType`. When `canDoDevice(device, scope)` is called:
1. Map `PrivilegeDeviceScope` to its OpenFGA relation name
2. Look up the device in cache and check if the relation exists in its permission set
3. If the relation has not been loaded yet (Phase 2 still in progress), return `false` as a safe default

No `await` is required. No lazy loading or on-demand network calls.

#### Scenario: Query a Phase 1 device permission (always available)
- **WHEN** `canDoDevice(device, .live)` is called after initialization
- **AND** the device has `can_live` permission
- **THEN** the result SHALL be `true` without any network call

#### Scenario: Query a Phase 2 device permission (after background load completes)
- **WHEN** `canDoDevice(device, .settings)` is called after Phase 2 background loading has completed
- **AND** the device has `can_settings` permission
- **THEN** the result SHALL be `true`

#### Scenario: Query a Phase 2 device permission (before background load completes)
- **WHEN** `canDoDevice(device, .settings)` is called before Phase 2 has loaded `can_settings`
- **THEN** the result SHALL be `false` (safe default)

#### Scenario: Query a loaded relation for a device without permission
- **WHEN** `canDoDevice(device, .playback)` is called after `can_playback` has been loaded
- **AND** the device does NOT have `can_playback` permission
- **THEN** the result SHALL be `false`

### Requirement: Device ID parsing from list-objects response
The system SHALL parse device object IDs from `list-objects` responses in the format `device:{orgId}/{thingName}/{derivant}` and construct a `DeviceCompositeType` as the cache key.

#### Scenario: Parse standard device ID
- **WHEN** `list-objects` returns `"device:da7df6be-9360-40ad-a96c-85437c208d54/F6A000000001-1773297117239/none"`
- **THEN** the cache key SHALL be `DeviceCompositeType(thingName: "F6A000000001-1773297117239", derivant: "none")`

#### Scenario: Parse device ID with non-none derivant
- **WHEN** `list-objects` returns `"device:da7df6be-9360-40ad-a96c-85437c208d54/0002D1A9600D-1708586038820/ch1"`
- **THEN** the cache key SHALL be `DeviceCompositeType(thingName: "0002D1A9600D-1708586038820", derivant: "ch1")`

### Requirement: Scope mapping
The system SHALL map every case of `PrivilegeOrganizationScope` and `PrivilegeDeviceScope` to a corresponding OpenFGA relation name via an `openFGARelation` computed property.

#### Scenario: Device scope mapping
- **WHEN** `PrivilegeDeviceScope.live.openFGARelation` is accessed
- **THEN** the value SHALL be `"can_live"`

#### Scenario: Organization scope mapping
- **WHEN** `PrivilegeOrganizationScope.adminRestricted.openFGARelation` is accessed
- **THEN** the value SHALL be `"can_admin_restricted"`

### Requirement: Cache lifecycle
The system SHALL clear all cached data (org permissions, device permissions, loaded relations, userType) and cancel any background loading task when `release()` is called. After `release()`, any query SHALL return `false` / `.regular`.

#### Scenario: Release clears cache
- **WHEN** `release()` is called
- **THEN** `orgPermissions`, `devicePermissions`, `loadedRelations` SHALL all be empty
- **AND** the Phase 2 background task SHALL be cancelled
- **AND** subsequent `canDoDevice` or `canDoOrganization` calls SHALL return `false`

### Requirement: Sync protocol compatibility
`PrivilegeProvider.initial` SHALL be declared as `async throws`. All other methods (`canDoOrganization`, `canDoDevice`, `getUserType`, `release`) SHALL remain **sync**. The existing Casbin implementation SHALL conform without any behavior change (sync body in async closure is valid Swift).

#### Scenario: Casbin provider still works with async initial
- **WHEN** the `.casbin` provider's `initial` is called with `await`
- **THEN** it SHALL return the same result as the previous sync implementation

#### Scenario: Zero consumer migration
- **WHEN** FeatureToggle calls `canDoOrganization` or `canDoDevice`
- **THEN** no `await` SHALL be required
- **AND** no consumer code SHALL need modification

### Requirement: OpenFGA API layer
The system SHALL communicate with the OpenFGA server using `URLSession`. The API layer SHALL support two operations: `batch-check` and `list-objects`. All requests SHALL include `store_id` in the URL path and `authorization_model_id` in the request body.

#### Scenario: Batch-check request
- **WHEN** a batch-check is sent with N check tuples
- **THEN** the request SHALL be `POST /stores/{storeId}/batch-check` with a JSON body containing `checks` array and `authorization_model_id`
- **AND** each check SHALL have a `tuple_key` with `user`, `relation`, `object` and a unique `correlation_id`

#### Scenario: List-objects request
- **WHEN** a list-objects request is sent for relation `can_live` and type `device`
- **THEN** the request SHALL be `POST /stores/{storeId}/list-objects` with a JSON body containing `user`, `relation`, `type`, and `authorization_model_id`
- **AND** the response `objects` array SHALL be parsed into device cache entries
