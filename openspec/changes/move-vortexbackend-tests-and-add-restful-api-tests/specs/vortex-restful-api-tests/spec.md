## ADDED Requirements

### Requirement: Users API JSON Format Tests
系統 SHALL 對 Users 相關的 RESTful API 進行 JSON 格式驗證測試。

#### Scenario: getMyPreference 成功解析
- **WHEN** API 回傳使用者偏好 JSON
- **THEN** 成功解析為 `MyPreference` 物件

#### Scenario: getMyAgreements 成功解析
- **WHEN** API 回傳使用者協議 JSON
- **THEN** 成功解析為 `MyAgreements` 物件

#### Scenario: patchMyAgreements 成功執行
- **WHEN** 發送更新使用者協議請求
- **THEN** API 回傳 204 No Content

#### Scenario: getTokenStatus 成功解析
- **WHEN** API 回傳 token 狀態 JSON
- **THEN** 成功解析為 `GetTokenStatusOutput` 物件

#### Scenario: deleteTokens 成功執行
- **WHEN** 發送刪除 tokens 請求
- **THEN** API 回傳 204 No Content

### Requirement: Device API JSON Format Tests
系統 SHALL 對 Device 相關的 RESTful API 進行 JSON 格式驗證測試。

#### Scenario: patchDevice 成功執行
- **WHEN** 發送更新裝置請求
- **THEN** API 回傳 204 No Content

#### Scenario: getDeviceInspect 成功解析
- **WHEN** API 回傳裝置檢查結果 JSON
- **THEN** 成功解析為 `GetDeviceIdInspectOutput` 物件

### Requirement: AI Settings API JSON Format Tests
系統 SHALL 對 AI Settings 相關的 RESTful API 進行 JSON 格式驗證測試。

#### Scenario: getAISettings 成功解析
- **WHEN** API 回傳 AI 控制設定 JSON
- **THEN** 成功解析為 `AIControlSetting` 物件

#### Scenario: putAISettingAgreement 成功解析
- **WHEN** 發送更新 AI 協議請求並收到回應
- **THEN** 成功解析為 `AIControlSetting` 物件

#### Scenario: patchAISetting 成功解析
- **WHEN** 發送更新 AI 設定請求並收到回應
- **THEN** 成功解析為 `AIControlSetting` 物件

### Requirement: AuditLog API JSON Format Tests
系統 SHALL 對 AuditLog 相關的 RESTful API 進行 JSON 格式驗證測試。

#### Scenario: postAuditLogStartLiveView 成功執行
- **WHEN** 發送開始直播審計日誌請求
- **THEN** API 回傳 204 No Content

#### Scenario: postAuditLogViewPlayback 成功執行
- **WHEN** 發送回放審計日誌請求
- **THEN** API 回傳 204 No Content

#### Scenario: postAuditLogArchiveDownloads 成功執行
- **WHEN** 發送存檔下載審計日誌請求
- **THEN** API 回傳 204 No Content

### Requirement: 3rd-party Integrations API JSON Format Tests
系統 SHALL 對 3rd-party Integrations 相關的 RESTful API 進行 JSON 格式驗證測試。

#### Scenario: getIntegrationUserPhoto 成功解析
- **WHEN** API 回傳整合使用者照片 JSON
- **THEN** 成功解析為 `GetIntegrationUserPhotoOutput` 物件

#### Scenario: postRemoteUnlock 成功執行
- **WHEN** 發送遠端解鎖請求
- **THEN** API 回傳 204 No Content

### Requirement: Organization Plan API JSON Format Tests
系統 SHALL 對 Organization Plan 相關的 RESTful API 進行 JSON 格式驗證測試。

#### Scenario: postCheckDowngrade 成功解析
- **WHEN** API 回傳降級檢查結果 JSON
- **THEN** 成功解析為 `CheckDowngradeOutput` 物件

#### Scenario: postDowngrade 成功執行
- **WHEN** 發送降級請求
- **THEN** API 回傳 204 No Content

### Requirement: Floor Plans API JSON Format Tests
系統 SHALL 對 Floor Plans 相關的 RESTful API 進行 JSON 格式驗證測試。

#### Scenario: getFloorPlans 成功解析
- **WHEN** API 回傳樓層平面圖列表 JSON
- **THEN** 成功解析為 `GetFloorPlansOutput` 物件

#### Scenario: getFloorPlan 成功解析
- **WHEN** API 回傳單一樓層平面圖 JSON
- **THEN** 成功解析為 `FloorPlanItem` 物件

#### Scenario: getDevicePositions 成功解析
- **WHEN** API 回傳裝置位置列表 JSON
- **THEN** 成功解析為 `GetDevicePositionsOutput` 物件

### Requirement: Test Directory Structure Alignment
系統 SHALL 將 VortexBackend 測試檔案與源碼目錄結構保持一致。

#### Scenario: 測試目錄與源碼目錄對齊
- **WHEN** VortexBackend 源碼位於 `Sources/VortexFeatures/Core/VortexBackend`
- **THEN** VortexBackend 測試 SHALL 位於 `Tests/VortexFeaturesTests/Core/VortexBackend`
