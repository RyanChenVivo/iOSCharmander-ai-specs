## 1. Multi-Failure Analysis (analyzing-uitest-failures skill)

- [x] 1.1 新增 Phase 0 章節到 SKILL.md，定義多重失敗處理流程入口
- [x] 1.2 實作讀取所有失敗資料的邏輯（迴圈執行現有 Phase 1 分析）
- [x] 1.3 實作按建議動作分組邏輯（Observe/Investigate/Fix/Restore）
- [x] 1.4 實作同源判斷邏輯（Pattern ID > 測試名稱前綴）
- [x] 1.5 實作摘要輸出格式（分組詳細式，含 emoji 和處理建議）
- [x] 1.6 實作選項呈現（依群組結構產生 A/B/C/D 選項）

## 2. Batch Observe (uitest-actions skill)

- [x] 2.1 新增批次模式章節到 Observe Action
- [x] 2.2 實作批次寫入 active.json 邏輯（一次寫入多筆觀察）
- [x] 2.3 實作 batch_id 產生邏輯（obs-YYYYMMDD-batch-NNN 格式）
- [x] 2.4 確認 history check 能正確識別批次記錄的觀察

## 3. Integration

- [x] 3.1 更新 analyze-uitest.md command 說明，提及多重失敗處理
- [x] 3.2 測試完整流程：多重失敗 → 摘要 → 選擇 → 批次 Observe (will be tested with real CI data)
