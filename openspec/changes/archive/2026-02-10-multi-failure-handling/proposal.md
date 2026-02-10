## Why

目前 `analyze-uitest` 流程沒有定義多重失敗的處理方式。當 CI 出現多個測試失敗時，無法快速掌握全貌，也無法有效率地批次處理相同類型的問題。

## What Changes

- 新增多重失敗摘要視圖，按建議動作分組呈現
- 新增同源判斷邏輯，識別可能是同一根本原因的失敗
- 新增批次處理機制，低風險動作（Observe、Restore）可一次處理多個測試
- 調整處理流程，高風險動作（Investigate、Fix）建議逐一確認

## Capabilities

### New Capabilities

- `multi-failure-analysis`: 多重失敗分析與分組邏輯，包含同源判斷規則和摘要輸出格式
- `batch-observe`: Observe action 的批次處理模式，支援一次記錄多個測試的觀察

### Modified Capabilities

（無需修改現有 specs）

## Impact

- `.claude/skills/analyzing-uitest-failures/SKILL.md` - 新增 Phase 0 多重失敗處理章節
- `.claude/skills/uitest-actions/SKILL.md` - Observe Action 新增批次模式
- `uitest-automation/observations/active.json` - 新增 batch_id 欄位（optional）
