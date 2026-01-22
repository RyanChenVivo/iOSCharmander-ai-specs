## Why
VortexBackend 的源碼已經搬移到 `Sources/VortexFeatures/Core/VortexBackend`，但其對應的測試檔案仍然在 `Tests/VortexFeaturesTests/Common/VortexBackend`，需要對齊目錄結構。此外，`VortexRestfulApiTest` 目前只測試了部分 API（CustomizedView、Site、Permission、Ecosystem），還有多個 RESTful API 缺少 JSON 格式驗證測試。

## What Changes
- 搬移測試目錄：將 `Tests/VortexFeaturesTests/Common/VortexBackend/` 底下所有測試檔案搬移到 `Tests/VortexFeaturesTests/Core/VortexBackend/`
- 新增缺少的 RESTful API 測試，涵蓋以下 API 群組：
  - **Users API**: `getMyPreference`, `getMyAgreements`, `patchMyAgreements`, `getTokenStatus`, `deleteTokens`
  - **Device API**: `patchDevice`, `getDeviceInspect`
  - **AI Settings API**: `getAISettings`, `putAISettingAgreement`, `patchAISetting`
  - **AuditLog API**: `postAuditLogStartLiveView`, `postAuditLogViewPlayback`, `postAuditLogArchiveDownloads`
  - **3rd-party Integrations API**: `getIntegrationUserPhoto`, `postRemoteUnlock`
  - **Organization Plan API**: `postCheckDowngrade`, `postDowngrade`
  - **Floor Plans API**: `getFloorPlans`, `getFloorPlan`, `getDevicePositions`

## Impact
- Affected files:
  - `Tests/VortexFeaturesTests/Common/VortexBackend/` (搬移來源)
  - `Tests/VortexFeaturesTests/Core/VortexBackend/` (搬移目標)
  - `Tests/VortexFeaturesTests/Core/VortexBackend/VortexRestfulApiTest.swift` (新增測試)
- No breaking changes
- Improves test coverage and directory consistency
