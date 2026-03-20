## Why

The current permission system uses Casbin with a locally-evaluated policy model (`UserPolicy` containing model + policies + groupings). The platform is migrating to OpenFGA for centralized, relationship-based authorization. A POC is needed to validate that the iOS app can replace the Casbin evaluation engine with OpenFGA API calls while keeping the existing `PrivilegeProvider` contract intact, allowing both implementations to coexist during the transition.

## What Changes

- Add `OpenFGAPermissionService` — a class that encapsulates OpenFGA API calls (batch-check, list-objects) and manages an in-memory permission cache with two-phase loading
- Add `.openFGA` static instance of `PrivilegeProvider` — delegates to `OpenFGAPermissionService` with sync query closures
- Add `OpenFGAApi` and `OpenFGAModels` — API endpoint definitions and request/response models for OpenFGA batch-check and list-objects
- Add scope mapping from `PrivilegeOrganizationScope` / `PrivilegeDeviceScope` enums to OpenFGA relation names (e.g., `.live` → `can_live`)
- Change `PrivilegeProvider.initial` signature from `throws` to `async throws` — only 2 call sites affected (SignInViewModel, HomeViewModel), both already in async contexts
- All query methods (`canDoOrganization`, `canDoDevice`, `getUserType`) and `release()` remain **sync** — zero consumer migration needed
- Casbin implementation preserved — `.casbin` instance unchanged except `initial` closure now has async signature (sync body, valid Swift)

### Initialization (login time, two-phase loading)

**Phase 1 (blocking at login):**
1. **batch-check** (~22 checks, single request):
   - `can_all` on organization → `.owner`
   - `can_admin_restricted` on organization → `.admin`
   - else → `.regular`
   - All remaining org scope permissions → stored as `[String: Bool]`

2. **list-objects × 5** (concurrent via TaskGroup):
   - `can_live` — View tab visibility
   - `can_all_users` — Message tab visibility
   - `can_archive_read` — Archive tab visibility
   - `can_ai_search` — AI Hub tab visibility
   - `can_ai_event_insight` — AI Hub tab visibility
   - Results merged into per-device permission cache

**Phase 2 (fire-and-forget background):**
- Remaining ~15 device relations loaded in background Task after Phase 1 completes
- `can_playback`, `can_export_video`, `can_share`, `can_settings`, etc.
- If Phase 2 hasn't finished when queried, returns `false` (safe default)

### Device permission cache (per-device structure)

Cache keyed by `DeviceCompositeType` (thingName + derivant), value is the set of relations that device has:

```
DeviceCompositeType("F6A000000001-1773297117239", "none") → {"can_live", "can_all_users", "can_settings"}
DeviceCompositeType("F6A000000002-1773297673964", "none") → {"can_live", "can_all_users"}
```

### Cache lifecycle

- Populated at login (Phase 1 blocking + Phase 2 background)
- Cleared on `release()`
- No WebSocket / real-time invalidation in POC — app restart to refresh

## Capabilities

### New Capabilities

- `openfga-permission-provider`: OpenFGA-based `PrivilegeProvider` implementation with batch-check initialization, two-phase device permission loading, and per-device in-memory caching

### Modified Capabilities

(none — only `initial` signature changes from `throws` to `async throws`; all query methods stay sync, all existing permission semantics are preserved)

## Impact

- `PrivilegeProvider.swift` — `initial` becomes `async throws`, add `.openFGA` static instance
- `PrivilegeScope.swift` — add `openFGARelation` computed properties
- `VortexLogger.swift` — add `openFGAPermissionService` LogType
- `CloudSightInfo.plist` — add OpenFGA logger configuration
- `SignInViewModel.swift`, `HomeViewModel.swift` — already use `try await` for `initial`, no change needed
- New files: `OpenFGAPermissionService.swift`, `OpenFGAApi.swift`, `OpenFGAModels.swift` (all in VortexFeatures)
- **Zero consumer migration** — FeatureToggle, ViewModels, Views all untouched
- POC connects directly to CloudFront endpoint, no auth required
- No new dependencies — uses Foundation `URLSession` for HTTP calls
