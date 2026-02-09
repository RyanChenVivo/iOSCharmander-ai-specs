# UITest 失敗分析報告

**日期:** {{date}}
**分析人員:** Claude AI

---

## TL;DR

**測試結果**: {{total_tests}} 測試，{{failed_count}} 失敗 ({{pass_rate}}% 通過率)

**關鍵問題與建議**:
- {{priority_1}} {{issue_1}} → **{{action_1}}** ({{timeline_1}})
- {{priority_2}} {{issue_2}} → **{{action_2}}** ({{timeline_2}})
- {{priority_3}} {{issue_3}} → **{{action_3}}** ({{timeline_3}})

---

## 執行摘要

### 測試總覽
- **總測試數:** {{total_tests}}
- **通過:** {{passed_count}}
- **失敗:** {{failed_count}}
- **通過率:** {{pass_rate}}%

### 失敗分類
| 優先級 | 失敗群組數 | 影響測試數 |
|--------|-----------|-----------|
| 🔴 High | {{high_count}} | {{high_tests}} |
| 🟡 Medium | {{medium_count}} | {{medium_tests}} |
| 🟢 Low | {{low_count}} | {{low_tests}} |

### 關鍵發現
{{key_findings}}

---

## 測試結果概況

| 群組名稱 | 失敗測試數 | 失敗率 | 嚴重程度 | 類型 |
|----------|-----------|--------|----------|------|
| {{group_name}} | {{fail_count}} | {{fail_rate}}% | {{severity}} | {{type}} |

---

## 詳細分析

### 失敗群組 1: {{group_1_name}}

**優先級:** {{group_1_priority}}
**影響測試:** {{group_1_test_count}} 個
**錯誤類型:** {{group_1_error_type}}

#### 失敗測試清單
| 測試名稱 | 錯誤訊息 | 執行時間 |
|----------|----------|----------|
| {{test_name}} | {{error_message}} | {{duration}}s |

#### 測試目的
{{test_purpose}}

#### 根本原因分析
{{root_cause_analysis}}

**證據:**
- 截圖: {{screenshot_path}}
- 程式碼位置: {{code_location}}

#### 歷史紀錄
{{historical_context}}

---

### 失敗群組 2: {{group_2_name}}

(重複上述格式)

---

## 風險評估與建議行動

### 本次建議

| 失敗群組 | 優先級 | 業務影響 | 建議處理 | 具體行動 | 預期時程 |
|----------|--------|----------|----------|----------|----------|
| {{group_name}} | {{priority}} | {{business_impact}} | {{recommendation}} | {{specific_action}} | {{timeline}} |

### 總體風險

{{overall_risk_summary}}

---

### 處理選項說明

| 處理方式 | 說明 | 適用情況 |
|----------|------|----------|
| **investigate** | 下載截圖深入分析 | 錯誤訊息不清楚，需要視覺確認 |
| **fix** | 創建 OpenSpec proposal 修復 | 根本原因明確，需要代碼變更 |
| **observe** | 記錄到 observations，等待重複 | 可能是暫時性問題 |
| **report** | 升級給管理層/外部團隊 | 需要外部協助或管理決策 |

---

## 附錄

### A. 詳細失敗測試資訊

| 測試名稱 | 錯誤訊息 | 執行時間 | 檔案位置 |
|----------|----------|----------|----------|
| {{test_name}} | {{error_message}} | {{duration}}s | {{file_location}} |

### B. 參考資料連結

- 程式碼位置: {{code_references}}
- 知識文件: {{knowledge_docs}}
- 歷史修復: {{archive_links}}

### C. 截圖證據清單

| 截圖檔案 | 說明 | 相關測試 |
|----------|------|----------|
| {{screenshot_file}} | {{description}} | {{related_test}} |

---

*報告由 Claude AI 自動生成*
*生成時間: {{timestamp}}*
