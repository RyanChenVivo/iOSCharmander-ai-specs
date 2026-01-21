## 1. Directory Migration
- [ ] 1.1 搬移 `Tests/VortexFeaturesTests/Common/VortexBackend/` 到 `Tests/VortexFeaturesTests/Core/VortexBackend/`
- [ ] 1.2 確認 Common 目錄下的 VortexBackend 已移除
- [ ] 1.3 驗證 Package.swift 或 test target 設定正確

## 2. Add Users API Tests
- [ ] 2.1 新增 `getMyPreference` 測試
- [ ] 2.2 新增 `getMyAgreements` 測試
- [ ] 2.3 新增 `patchMyAgreements` 測試
- [ ] 2.4 新增 `getTokenStatus` 測試
- [ ] 2.5 新增 `deleteTokens` 測試

## 3. Add Device API Tests
- [ ] 3.1 新增 `patchDevice` 測試
- [ ] 3.2 新增 `getDeviceInspect` 測試

## 4. Add AI Settings API Tests
- [ ] 4.1 新增 `getAISettings` 測試
- [ ] 4.2 新增 `putAISettingAgreement` 測試
- [ ] 4.3 新增 `patchAISetting` 測試

## 5. Add AuditLog API Tests
- [ ] 5.1 新增 `postAuditLogStartLiveView` 測試
- [ ] 5.2 新增 `postAuditLogViewPlayback` 測試
- [ ] 5.3 新增 `postAuditLogArchiveDownloads` 測試

## 6. Add 3rd-party Integrations API Tests
- [ ] 6.1 新增 `getIntegrationUserPhoto` 測試
- [ ] 6.2 新增 `postRemoteUnlock` 測試

## 7. Add Organization Plan API Tests
- [ ] 7.1 新增 `postCheckDowngrade` 測試
- [ ] 7.2 新增 `postDowngrade` 測試

## 8. Add Floor Plans API Tests
- [ ] 8.1 新增 `getFloorPlans` 測試
- [ ] 8.2 新增 `getFloorPlan` 測試
- [ ] 8.3 新增 `getDevicePositions` 測試

## 9. Validation
- [ ] 9.1 執行測試確認所有測試通過
- [ ] 9.2 確認 JSON 解析正確
