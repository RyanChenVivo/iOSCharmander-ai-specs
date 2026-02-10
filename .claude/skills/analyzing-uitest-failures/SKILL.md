---
name: analyzing-uitest-failures
description: >
  Analyze UITest failures and provide handling recommendations. Use when user
  mentions CI failures, UITest errors, or test failures. Determines whether
  further investigation is needed based on error messages and history,
  and recommends appropriate actions (observe/fix/investigate/restore).
---

# UITest Failure Analysis

Analyze UITest failures from CI and provide handling recommendations.

## Pre-check

Before analysis, verify data availability:

1. Check if `$HOME/Downloads/UITestAnalysis/latest/` exists
2. Check data date:
   - **Today** → Use directly
   - **Past date** → Ask: "Data is from YYYY-MM-DD. Download latest data? Or use this?"
   - **Not exist** → Ask: "No data found. Download now?"

If no data or user wants refresh, guide them to use `/analyze-uitest` command which handles CI data download.

3. Check failure count:
   - **No failures** → Congratulate: "🎉 所有測試通過！沒有需要分析的失敗。"
   - **Has failures** → Proceed to Analysis Flow

---

## Analysis Flow

### Step 1: Analyze Each Failure

For each failure in the CI data, determine a recommendation:

**1a. Check Known Patterns**

Query [patterns.md](references/patterns.md) for matching patterns.

- Test name matches pattern regex
- Error message contains pattern trigger text
- If matched → Use pattern's recommended action

**1b. Check History**

Query `uitest-automation/observations/active.json`:

- If test is under observation and failed again → Escalate (observe → investigate/fix)
- If first occurrence → Continue to classification

**1c. Classify by Error Characteristics**

| Error Characteristic | Recommendation |
|---------------------|----------------|
| timeout, network error | Observe |
| element not found + short duration | Observe |
| element not found + first occurrence | Investigate |
| crash, fatal error, SIGABRT | Investigate |
| credential, auth, 401 | Investigate |
| UAT cleanup failed | Restore |
| assertion failure | Investigate |

### Step 2: Group Results

Group failures by recommended action, then identify same-source failures within each group.

**Same-Source Detection (priority order):**
1. **Same Pattern ID** — Both match same pattern in patterns.md
2. **Same Test Name Prefix** — e.g., `SSO_Login` and `SSO_Logout` → "SSO 群組"

### Step 3: Output Summary

Display grouped summary:

```
📊 UITest 失敗分析結果
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
日期：YYYY-MM-DD
總失敗數：N 個
資料來源：CI Build #XXX

🟡 建議 Observe (N 個)
   <same-source reasoning>
   ┌────────────────────────────────
   │ • <test_name>
   │   錯誤：<brief error message>
   └────────────────────────────────
   → 可批次記錄觀察

🔴 建議 Investigate (N 個)

   【<group_name> 群組】N 個 — <same-source reasoning>
   ┌────────────────────────────────
   │ • <test_name>
   │   錯誤：<brief error message>
   └────────────────────────────────
   → 建議一起下載截圖分析

🟠 建議 Restore (N 個)
   ┌────────────────────────────────
   │ • <test_name>
   │   錯誤：<brief error message>
   └────────────────────────────────
   → 環境問題，需手動處理

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
請選擇要處理的項目：
A) Observe 組 - 批次記錄觀察
B) Investigate: <group_name> - 分析
C) Restore 組 - 環境修復
D) 產生報告 - 整合所有分析結果
```

### Step 4: Process User Selection

**Processing Strategy:**

| Action | Strategy | Reason |
|--------|----------|--------|
| Observe | Batch | Low cost, just recording |
| Restore | Batch | Usually same environment issue |
| Investigate | Individual | Need screenshots to confirm each cause |
| Fix | Individual | Each may need different fix |

**Route to handler:**

- **Observe** → `uitest-actions` skill (batch observe mode)
- **Investigate (same-source)** → `investigating-uitest` skill (analyze together)
- **Investigate (unrelated)** → `investigating-uitest` skill (one by one)
- **Restore** → `uitest-actions` skill (restore action)
- **Report** → `reporting-uitest` skill

---

## Related References

- **Known Patterns**: [patterns.md](references/patterns.md) - Failure patterns with triggers and recommended actions
- **External Services**: [external-dependencies.md](references/external-dependencies.md) - External service behaviors and known issues
