# Phase 3: Report

**Purpose:** Generate comprehensive Traditional Chinese report for management review.

**When:** When ready to present findings to management or need formal documentation.

---

## When to Use Phase 3

Use report generation when:
- 📋 Need to present to senior management
- 🤝 Need team/stakeholder decision
- 📊 Want formal documentation of analysis
- ✅ Analysis is complete (ideally after Phase 2 if needed)

**Best practice:**
- Complete Phase 1 (triage) first
- If unclear, complete Phase 2 (investigate) for visual confirmation
- THEN generate report with all evidence

---

## Report Format

**Filename:** `triage_report_YYYY-MM-DD.md`

**Location:** `$HOME/Downloads/UITestAnalysis/latest/`

**Language:** Traditional Chinese (繁體中文) with English technical terms

**Size:** Comprehensive (~10-15KB, ~500 lines)

---

## Report Structure

The report should include these sections:

### 0. TL;DR (開頭，標題和日期之後)
- **Purpose:** Ultra-concise summary for busy executives
- **Format:** 3-5 bullet points
- **Content:** Test pass rate, key problems with recommended actions and timeline
- **Example:**
  ```markdown
  ## TL;DR

  **測試結果**: [總數] 測試，[失敗數] 失敗 ([通過率]% 通過率)

  **關鍵問題與建議**:
  - [優先級] [問題簡述] → **[建議行動]** ([預期時程])
  - [優先級] [問題簡述] → **[建議行動]** ([預期時程])
  - [優先級] [問題簡述] → **[建議行動]** ([預期時程])
  ```

### 1. 執行摘要 (Executive Summary)
- Total test count and failure rate
- Categorization by priority (High/Medium/Low)
- Brief summary of each failure group

### 2. 測試結果概況 (Test Results Overview)
- Table showing test groups, failure counts, failure rates, severity

### 3. 詳細分析 (Detailed Analysis)
For each failure group:
- Failed test list
- Error messages
- Test purpose and steps
- Root cause analysis with evidence
- Failure type categorization
- Historical context if applicable

### 4. 風險評估與建議行動 (Risk Assessment & Recommended Actions)

**本次建議**:

| 失敗群組 | 優先級 | 業務影響 | 建議處理 | 具體行動 | 預期時程 |
|----------|--------|----------|----------|----------|----------|
| [群組名] | 🔴/🟡/🟢 | [簡述業務影響] | investigate/fix/observe/report | [具體要做什麼] | [天數] |

**總體風險**: [簡短一句話總結]

---

**處理選項說明**:

| 處理方式 | 說明 | 適用情況 |
|----------|------|----------|
| **investigate** | 下載截圖深入分析（Phase 2） | 錯誤訊息不清楚，需要視覺確認 |
| **fix** | 創建 OpenSpec proposal 修復（Phase 4） | 根本原因明確，需要代碼變更 |
| **observe** | 記錄到 observations，等待重複（Phase 4） | 可能是暫時性問題 |
| **report** | 升級給管理層/外部團隊 | 需要外部協助或管理決策 |

### 5. 附錄 (Appendix)
- A. 詳細失敗測試資訊 (tables with test names, errors, durations)
- B. 參考資料連結 (code locations, knowledge docs, archive links)
- C. 截圖證據清單 (screenshot file references with descriptions)

**Do NOT include:**
- ❌ OpenSpec proposal templates (these belong in execution phase)
- ❌ Quick decision guides (unnecessary - let readers decide how to read)
- ❌ Task checklists or TODO lists
- ❌ Meeting agendas or schedules

---

## Content Guidelines

### Professional Quality
- Suitable for senior management review
- Clear technical analysis with business context
- Evidence-based (screenshots, code references, historical data)
- Actionable recommendations with specific timelines

### Bilingual Approach
- Main content in Traditional Chinese
- Technical terms in English (e.g., "SSO", "timeout", "UITest")
- Code references and file paths in English
- Error messages in original language (usually English)

### Visual Elements
- Use emoji indicators for priority: 🔴 (High), 🟡 (Medium), 🟢 (Low)
- Use checkboxes (✅/❌/⚠️) for status indicators
- Include tables for structured data

---

## Generation Process

### Step 1: Gather All Analysis Results

Collect from previous phases:
- Phase 1: Initial triage analysis and categorization
- Phase 2: Screenshot evidence and root cause confirmation (if ran)
- Test data: metadata.json, test_failures.json

### Step 2: Structure Content

Organize failures into logical groups:
- By priority (High/Medium/Low)
- By test category (SSO/Message/License, etc.)
- By failure type (External/Timing/Bug)

### Step 3: Write in Traditional Chinese

Use clear, professional Traditional Chinese:
- Executive summary for management
- Technical details for developers
- Action plans with specific steps

### Step 4: Add Evidence References

Include links to:
- Screenshot files
- Code locations (file:line)
- Archive fixes (if similar issues occurred before)
- External dependencies docs

### Step 5: Provide Risk Assessment and Actions

Present unified assessment and recommendations:
- Risk assessment with business impact
- Recommended handling method (investigate/fix/observe/report)
- Specific actions for each failure group
- Time estimates and priorities

---

## When NOT to Generate Report

Avoid generating report prematurely when:
- ❌ Haven't completed Phase 1 triage
- ❌ Root cause still unclear (should do Phase 2 first)
- ❌ Failures are simple and don't need management decision
- ❌ Just want to record observation (use Phase 4 instead)

---

## After Report Generation

Once report is generated:

1. **Share with stakeholders**
   - Email report to management
   - Discuss in team meeting

2. **Get decision**
   - 哪個失敗群組優先處理？
   - 是否同意建議的處理方式（investigate/fix/observe/report）？

3. **Execute based on decision**
   - If investigate → proceed to Phase 2 (download screenshots)
   - If fix → proceed to Phase 4 (create OpenSpec proposal)
   - If observe → proceed to Phase 4 (record to observations)
   - If report → escalate to management/external team

---

**Next:** Based on report and management decision, proceed to Phase 4 for action.
