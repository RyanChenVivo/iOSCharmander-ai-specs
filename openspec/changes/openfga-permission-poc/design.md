## Context

The current permission system uses Casbin, a locally-evaluated policy engine. On login, the backend returns a `UserPolicy` containing a model string, policy rules, and role groupings. `CasbinWrapper` builds an in-memory enforcer and evaluates permissions synchronously.

The platform is migrating to OpenFGA, a relationship-based authorization system. Instead of downloading policy rules, the iOS app will call OpenFGA APIs (batch-check, list-objects) to query permissions from a centralized server.

Current file structure:
```
PrivilegeProvider/
├── PrivilegeProvider.swift      (struct with closures, DependencyKey)
├── PrivilegeScope.swift         (PrivilegeOrganizationScope, PrivilegeDeviceScope enums)
├── PrivilegeRole.swift
└── Casbin/
    ├── CasbinWrapper.swift      (singleton, Enforcer-based evaluation)
    ├── CustomizeRoleManager.swift
    └── StringStreamAdapter.swift
```

Consumers access permissions through `PrivilegeProvider` closures injected via `swift-dependencies`. `FeatureToggle` is the primary consumer — all UI permission checks go through it.

### OpenFGA POC Environment

| Key | Value |
|-----|-------|
| API URL | `https://d29q2chqujmqlw.cloudfront.net` |
| Store ID | `01KKK6PXQT2VNN3M8QEDK7SJ5Y` |
| Model ID | `01KKX3PF6M89J5783RCQWE5K5D` |
| Auth | None required |

### OpenFGA APIs Used

- **batch-check** — up to 50 permission checks in one request. Used for org permissions + userType.
- **list-objects** — returns all objects a user has a specific relation on. Used for device permissions.

## Goals / Non-Goals

**Goals:**
- Replace Casbin evaluation with OpenFGA API calls behind the same `PrivilegeProvider` contract
- Both implementations coexist — switchable via DI (`.casbin` vs `.openFGA`)
- Validate performance with 1000 devices in test environment
- Two-phase device permission loading: critical at login, remaining in background

**Non-Goals:**
- Real-time permission change notification (WebSocket) — POC uses app restart
- Removing Casbin code — preserved for fallback
- Changing `PrivilegeProvider.initial` parameter type — still takes `UserPolicy`
- Production-ready error handling / retry logic
- OpenFGA write operations (read-only from iOS)
- Lazy-load on demand — replaced by two-phase preloading approach

## Decisions

### 1. Protocol signature: keep sync (except initial)

**Decision:** Only change `initial` from `throws` to `async throws`. All query methods (`canDoOrganization`, `canDoDevice`, `getUserType`) and `release()` stay **sync**.

**Rationale:** Making query methods async would cascade through FeatureToggle (~100 methods) into ~70+ View/ViewModel files. Many call sites can't use `await`: `@ViewBuilder` closures, boolean `&&`/`||` chains, sync initializers. The async cascade approach was prototyped and found untenable — it required restructuring fundamental UI patterns across the entire app.

**Impact:** Zero consumer migration. FeatureToggle, ViewModels, Views all remain unchanged. Only `SignInViewModel` and `HomeViewModel` call `initial`, and both are already in async contexts with `try await`.

**Trade-off:** Unloaded device permissions return `false` synchronously instead of awaiting a network call. This is acceptable because Phase 2 background loading covers all relations, and the window where permissions are stale is brief (seconds after login).

**Alternative rejected:** Async protocol (original approach). Rejected after implementation revealed ~87 files affected with many structurally incompatible call sites.

### 2. Initialization strategy: two-phase loading

**Decision:** At login, execute in two phases:

**Phase 1 (blocking, awaited at login):**
1. One batch-check (~22 checks) for all org permissions + userType determination
2. Five concurrent list-objects for critical device relations:
   - `can_live`, `can_all_users`, `can_archive_read`, `can_ai_search`, `can_ai_event_insight`

**Phase 2 (fire-and-forget background Task):**
- Remaining ~15 device relations loaded concurrently in background
- `can_playback`, `can_export_video`, `can_share`, `can_settings`, `can_event_snooze`, `can_archive_create`, `can_archive_update`, `can_archive_delete`, `can_archive_play`, `can_archive_download`, `can_archive_share`, `can_ai_search_feedback`, `can_talkdown`, `can_lock`, `can_unlock`, `can_admin_restricted`

**Rationale:** Phase 1 relations are needed immediately for Home tab rendering (`supportedHomeViewTabs()`). Phase 2 relations are for sub-pages (streaming, settings, archive detail) which the user reaches after Phase 2 completes. If Phase 2 hasn't finished, queries return `false` — a safe default for POC.

**Alternative rejected:** Pure lazy load (on-demand per relation). Required async protocol which caused the cascade problem.

### 3. Cache structure: DeviceCompositeType keyed

**Decision:** Use `DeviceCompositeType` as the device permission cache key, with a separate set tracking loaded relations.

```swift
final class OpenFGAPermissionService: @unchecked Sendable {
    var userType: PrivilegeProvider.UserType = .regular
    var orgPermissions: [String: Bool] = [:]
    var devicePermissions: [DeviceCompositeType: Set<String>] = [:]
    var loadedRelations: Set<String> = []
}
```

**Query logic:**
```
queryDevicePermission(device, relation):
  return devicePermissions[device]?.contains(relation) ?? false
```

**Rationale:** `DeviceCompositeType` is already `Hashable` and is the type used throughout the codebase for device identification. Using it directly avoids string key construction and ensures type-safe lookups. `loadedRelations` tracks which relations have been fetched (distinguishes "no permission" from "not yet loaded").

### 4. OpenFGAPermissionService: @unchecked Sendable class (not actor)

**Decision:** Use `final class: @unchecked Sendable` instead of `actor` or `@MainActor` class.

**Rationale:** `PrivilegeProvider` closures are `@Sendable`, which cannot call `@MainActor`-isolated methods synchronously. Using `actor` would require `await` for all method calls (same problem as async protocol). `@unchecked Sendable` allows sync access from `@Sendable` closures while acknowledging we manage thread safety ourselves.

**Thread safety for POC:** All Phase 1 writes complete before `initialize` returns (awaited). Phase 2 background writes are additive (insert into sets/dictionaries). Main thread reads happen after Phase 1. The only race is Phase 2 writes vs reads — benign because worst case is a query returns `false` for a permission being loaded (user navigates deeper and it works).

**Alternative rejected:** `@MainActor` class. Compile error: `@Sendable` closures in `PrivilegeProvider` can't reference `@MainActor`-isolated properties/methods.

### 5. Device ID parsing

**Decision:** Parse `list-objects` response to extract `DeviceCompositeType` as cache key.

```
Input:  "device:da7df6be-9360-40ad-a96c-85437c208d54/F6A000000001-1773297117239/none"
Parse:  split by "/" after removing "device:" prefix
        [0] = orgId (discard)
        [1] = thingName = "F6A000000001-1773297117239"
        [2] = derivant = "none"
Output: DeviceCompositeType(thingName: "F6A000000001-1773297117239", derivant: "none")
```

### 6. getUserType via org-level batch-check

**Decision:** Determine userType from organization-level checks:

```
check(user, can_all, organization:{orgId})             → true → .owner
check(user, can_admin_restricted, organization:{orgId}) → true → .admin
else → .regular
```

**Rationale:** Matches Casbin behavior. `can_all` is owner-exclusive. `can_admin_restricted` is admin+ (owner also has it, but owner is checked first).

### 7. Scope mapping: enum → OpenFGA relation name

**Decision:** Add `openFGARelation` computed properties on `PrivilegeOrganizationScope` and `PrivilegeDeviceScope`.

### 8. File structure

```
PrivilegeProvider/
├── PrivilegeProvider.swift          (modified: initial → async throws, add .openFGA)
├── PrivilegeScope.swift             (modified: add openFGARelation)
├── PrivilegeRole.swift              (unchanged)
├── Casbin/                          (unchanged)
│   ├── CasbinWrapper.swift
│   ├── CustomizeRoleManager.swift
│   └── StringStreamAdapter.swift
└── OpenFGA/
    ├── OpenFGAPermissionService.swift   (class: two-phase loading + sync cache reads)
    ├── OpenFGAApi.swift                 (URLSession HTTP layer)
    └── OpenFGAModels.swift              (request/response Codable models)
```

### 9. PrivilegeProvider.initial keeps UserPolicy parameter

**Decision:** OpenFGA implementation receives `UserPolicy` but only uses `subject` (userId) and `domain` (orgId).

**Rationale:** Avoids changing the protocol signature and all call sites. The backend still returns `UserPolicy` for Casbin; OpenFGA just ignores the Casbin-specific fields.

## Risks / Trade-offs

**[Login time increase]** → 1 batch-check + 5 concurrent list-objects adds network latency at login. Mitigation: list-objects run concurrently via TaskGroup; monitor actual latency in POC.

**[Phase 2 race window]** → Between Phase 1 completion and Phase 2 completion (~seconds), some device permissions return `false`. Mitigation: Phase 2 covers relations only needed in sub-pages (streaming, settings); user navigates there after Phase 2 finishes.

**[Stale cache]** → Permissions changed server-side won't reflect until app restart. Mitigation: Acceptable for POC; production version will use WebSocket notifications.

**[list-objects response size]** → 1000 devices per relation. Mitigation: Each device ID string ~50 bytes; 1000 devices × 20 relations ≈ 1MB total — acceptable for mobile.

**[@unchecked Sendable thread safety]** → Manual thread safety management. Mitigation: Phase 1 writes are awaited; Phase 2 writes are additive; reads happen on main thread after Phase 1.

## Open Questions

| # | Question | Status |
|---|----------|--------|
| 1 | What is the actual latency of `list-objects` with 1000 devices in POC environment? | To measure during POC |
| 2 | Are all `PrivilegeDeviceScope` → OpenFGA relation mappings correct? Some (e.g., `lock`, `unlock`, `aiSearchFeedback`) need backend confirmation | To verify |
| 3 | Does `list-objects` paginate or return all results in one response? If paginated, need to handle continuation token | To verify during POC |
