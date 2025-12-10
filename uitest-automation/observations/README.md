# UITest Observation Tracker

這個目錄用於追蹤「需要觀察」的 UITest 問題，避免 context rot 同時保留重要的觀察記錄。

## 🎯 設計理念

**問題：** 如果選擇「觀察明天」(C) 或「不需處理」(D)，就沒有歷史記錄，下次遇到相同問題 AI 會重複判斷。

**解決方案：** 只記錄「正在觀察」的問題，有明確的生命週期和自動清理機制。

### Context Engineering 原則

1. **Only Record Actionable** - 只記錄需要追蹤的問題
2. **Time-Bound** - 記錄有明確的過期時間
3. **Minimal Schema** - 極簡的資料結構
4. **Self-Cleaning** - 自動清理過期記錄

## 📁 檔案說明

### active.json
**用途：** 記錄正在觀察中的問題（通常 < 5 筆）

**Schema：**
```json
{
  "observations": [
    {
      "id": "LicensePhaseUITest.testGracePeriodBanner",
      "firstSeen": "2025-12-08",
      "lastSeen": "2025-12-08",
      "occurrences": 1,
      "pattern": "UI_ELEMENT_NOT_FOUND",
      "decision": "observe",
      "expiresOn": "2025-12-10"
    }
  ]
}
```

**欄位說明：**
- `id` (string) - 完整測試名稱，格式：`TestClass.testMethod`
- `firstSeen` (string) - 首次失敗日期，ISO 8601 格式
- `lastSeen` (string) - 最後一次失敗日期
- `occurrences` (number) - 累計失敗次數
- `pattern` (string) - 錯誤模式（如 `UI_ELEMENT_NOT_FOUND`, `TIMING_ISSUE`, `ASSERTION_FAILED`）
- `decision` (string) - 固定為 `"observe"`
- `expiresOn` (string) - 觀察到期日（通常是 firstSeen + 2 天）

### resolved.json
**用途：** 記錄已解決的觀察問題（保留 30 天）

**Schema：**
```json
{
  "observations": [
    {
      "id": "LicensePhaseUITest.testGracePeriodBanner",
      "firstSeen": "2025-12-08",
      "lastSeen": "2025-12-08",
      "occurrences": 1,
      "pattern": "UI_ELEMENT_NOT_FOUND",
      "decision": "observe",
      "outcome": "transient",
      "resolvedOn": "2025-12-10"
    }
  ]
}
```

**額外欄位：**
- `outcome` (string) - 結果類型：
  - `"transient"` - 暫時性問題，觀察期滿後自行恢復
  - `"fixed"` - 已修復（建立了 OpenSpec proposal 並修復）
- `resolvedOn` (string) - 解決日期

## 🔄 完整工作流程

### 第一天：問題首次出現

```
用戶執行：/analyze-uitest
測試結果：testGracePeriodBanner 失敗

AI Triage 流程：
1. 搜尋 openspec/archive/ → 沒找到類似問題
2. 搜尋 observations/active.json → 沒找到
3. 判斷：首次發生
4. 建議：C - 觀察 2 天

用戶選擇：C

AI 動作：
→ 新增到 active.json:
{
  "id": "LicensePhaseUITest.testGracePeriodBanner",
  "firstSeen": "2025-12-08",
  "lastSeen": "2025-12-08",
  "occurrences": 1,
  "pattern": "UI_ELEMENT_NOT_FOUND",
  "decision": "observe",
  "expiresOn": "2025-12-10"
}
```

### 第二天：測試通過

```
用戶執行：/analyze-uitest
測試結果：全部通過 ✅

AI 檢查：
1. 讀取 active.json
2. 發現有 1 個問題在觀察中
3. 今天測試通過，不更新 lastSeen

AI 報告：
"今天測試全部通過 ✅
 注意：有 1 個問題在觀察中（LicensePhaseUITest.testGracePeriodBanner）
 觀察期限到 2025-12-10"
```

### 第三天：觀察期滿

```
用戶執行：/analyze-uitest
測試結果：全部通過 ✅

AI 清理流程：
1. 檢查 active.json 中的過期記錄
2. "LicensePhaseUITest.testGracePeriodBanner" 觀察期滿
3. 移到 resolved.json 並標記 outcome: "transient"
4. 從 active.json 刪除

AI 報告：
"今天測試全部通過 ✅
 觀察完成：LicensePhaseUITest.testGracePeriodBanner 判定為暫時性問題 ✓"
```

### 第四天：同樣問題再次出現

```
用戶執行：/analyze-uitest
測試結果：testGracePeriodBanner 再次失敗

AI Triage 流程：
1. 搜尋 openspec/archive/ → 沒找到
2. 搜尋 active.json → 沒找到
3. 搜尋 resolved.json → ✓ 找到！

AI 分析：
"⚠️ 重要發現：
 這個問題之前在 2025-12-08 出現過，觀察 2 天後自行恢復
 但現在又再次出現 → 不是偶發問題！

 建議：A - 建立 OpenSpec proposal（重複問題需要修復）"

用戶選擇：A

AI 動作：
→ 建立 OpenSpec proposal
→ 在 proposal 中引用：
   "Previously observed: 2025-12-08 (resolved as transient, but recurred)"
→ 從 resolved.json 刪除
→ 標記問題已升級處理
```

## 🧹 自動清理規則

### Active 清理（每次 triage 時執行）
- 觀察期滿（`expiresOn < today`）→ 移到 `resolved.json`，標記 `outcome: "transient"`

### Resolved 清理（每次 triage 時執行）
- 超過 30 天（`resolvedOn < today - 30`）→ 永久刪除

## 📊 Context Efficiency

| 指標 | 傳統 Log | Active Tracker |
|------|---------|----------------|
| 每筆記錄 | ~180 tokens | ~50 tokens |
| 100 筆累積 | ~18K tokens | ~500-1K tokens |
| 搜尋效率 | O(n) 線性搜尋 | O(n) 但 n < 5 |
| 維護成本 | 手動清理 | 自動清理 |

**Token 節省：95%+**

## 🔧 AI 實作參考

```javascript
// AI 在 triage 分析時執行
async function checkObservations(testName, today) {
  const active = await readJSON('observations/active.json');
  const resolved = await readJSON('observations/resolved.json');

  // 1. 檢查是否在觀察中
  const existing = active.observations.find(obs => obs.id === testName);
  if (existing) {
    return {
      status: 'observing',
      observation: existing,
      message: `此問題正在觀察中（首次發生: ${existing.firstSeen}，已發生 ${existing.occurrences} 次）`
    };
  }

  // 2. 檢查是否曾經解決
  const previous = resolved.observations.find(obs => obs.id === testName);
  if (previous) {
    return {
      status: 'recurred',
      observation: previous,
      message: `⚠️ 此問題之前在 ${previous.firstSeen} 出現過，當時判定為暫時性問題，但現在又重複發生！`
    };
  }

  // 3. 首次發現
  return {
    status: 'new',
    message: '首次發現此問題'
  };
}

// 用戶選擇 C 時
async function recordObservation(testName, pattern, today) {
  const active = await readJSON('observations/active.json');

  active.observations.push({
    id: testName,
    firstSeen: today,
    lastSeen: today,
    occurrences: 1,
    pattern: pattern,
    decision: "observe",
    expiresOn: addDays(today, 2)
  });

  await writeJSON('observations/active.json', active);
}

// 每次 triage 時清理
async function cleanupObservations(today) {
  const active = await readJSON('observations/active.json');
  const resolved = await readJSON('observations/resolved.json');

  // 清理過期的觀察
  const expired = active.observations.filter(obs => obs.expiresOn < today);
  active.observations = active.observations.filter(obs => obs.expiresOn >= today);

  // 移到 resolved
  expired.forEach(obs => {
    resolved.observations.push({
      ...obs,
      outcome: "transient",
      resolvedOn: today
    });
  });

  // 清理 30 天前的 resolved
  const thirtyDaysAgo = addDays(today, -30);
  resolved.observations = resolved.observations.filter(obs => obs.resolvedOn > thirtyDaysAgo);

  await writeJSON('observations/active.json', active);
  await writeJSON('observations/resolved.json', resolved);
}
```

## ❓ 常見問題

### Q: 為什麼不記錄所有 triage 決策？
**A:** 避免 context rot。只記錄需要追蹤的問題，大幅減少 token 使用。

### Q: 觀察期 2 天是否合適？
**A:** 可根據實際情況調整。一般來說：
- 平日測試：2-3 天
- 週末前測試：考慮跨週末，可能需要 4-5 天

### Q: 如果問題在觀察期內重複發生？
**A:** AI 會更新 `lastSeen` 和 `occurrences`，並建議立即修復（不等到觀察期滿）。

### Q: resolved.json 為什麼保留 30 天？
**A:**
1. 捕捉週期性問題（如每月第一天才會出現的問題）
2. 30 天後如果沒再發生，可確定已真正解決
3. 避免無限累積造成 context bloat

## 📝 相關文件

- [README.md](../README.md) - UITest 自動化分析總覽
- [WRITING_GUIDE.md](../WRITING_GUIDE.md) - UITest 編寫指南
- [external-dependencies.md](../knowledge/external-dependencies.md) - 已知外部依賴問題
