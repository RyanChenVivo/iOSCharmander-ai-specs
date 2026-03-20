## 1. OpenFGA API Layer

- [x] 1.1 Create `OpenFGAModels.swift` — Codable request/response models for batch-check and list-objects (tuple_key, correlation_id, BatchCheckRequest, BatchCheckResponse, ListObjectsRequest, ListObjectsResponse)
- [x] 1.2 Create `OpenFGAApi.swift` — URLSession-based HTTP client with `batchCheck` and `listObjects` methods, hardcoded POC endpoint/storeId/modelId

## 2. Permission Service (two-phase loading)

- [x] 2.1 Create `OpenFGAPermissionService.swift` — `final class: @unchecked Sendable` with cache state: `userType`, `orgPermissions: [String: Bool]`, `devicePermissions: [DeviceCompositeType: Set<String>]`, `loadedRelations: Set<String>`
- [x] 2.2 Implement `initialize(userId:orgId:)` Phase 1 — batch-check for all org permissions + userType, then 5 concurrent list-objects via TaskGroup for critical device relations (`can_live`, `can_all_users`, `can_archive_read`, `can_ai_search`, `can_ai_event_insight`)
- [x] 2.3 Implement `initialize` Phase 2 — fire-and-forget background Task loading remaining ~15 device relations concurrently
- [x] 2.4 Implement device ID parsing — extract `DeviceCompositeType` from `device:{orgId}/{thingName}/{derivant}` format
- [x] 2.5 Implement sync `queryDevicePermission(device:relation:)` — direct cache lookup, returns `false` for unloaded relations
- [x] 2.6 Implement sync `queryOrgPermission(relation:)` — direct cache lookup from `orgPermissions`
- [x] 2.7 Implement `release()` — cancel background task, clear all cache state

## 3. Scope Mapping

- [x] 3.1 Add `openFGARelation` computed property to `PrivilegeDeviceScope` — map all cases to OpenFGA relation names
- [x] 3.2 Add `openFGARelation` computed property to `PrivilegeOrganizationScope` — map all cases to OpenFGA relation names

## 4. Protocol & Provider Changes

- [x] 4.1 Change `PrivilegeProvider.initial` signature from `throws` to `async throws` — keep all other methods sync
- [x] 4.2 Keep `.casbin` static instance unchanged — sync body in async closure is valid Swift
- [x] 4.3 Add `.openFGA` static instance on `PrivilegeProvider` — sync query closures delegating to `OpenFGAPermissionService.shared`
- [x] 4.4 Keep `testValue` unchanged — `initial` signature matches async, rest stay sync

## 5. Logger Configuration

- [x] 5.1 Add `openFGAPermissionService` case to `VortexLogger.LogType` enum
- [x] 5.2 Add OpenFGA logger configuration to `CloudSightInfo.plist`

## 6. Integration Verification

- [x] 6.1 Wire `.openFGA` provider into DI — temporarily switch `liveValue` to `.openFGA` (or use feature toggle to switch)
- [ ] 6.2 Run app against POC environment — verify login, tab visibility, device permissions with test users (owner/admin/viewer/custom role)
- [ ] 6.3 Measure list-objects latency with 1000 devices — log timing for each phase during initialization
