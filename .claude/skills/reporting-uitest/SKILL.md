---
name: reporting-uitest
description: >
  Use when analysis complete and formal report needed for management,
  stakeholders, or team decision. Also use when external escalation
  required (IT, vendor) or non-programmable issues need documentation.
---

# UITest Analysis Report Generation

Generate comprehensive Traditional Chinese reports for management review.

## When to Use

- Need to present findings to senior management
- Need team/stakeholder decision
- Want formal documentation of analysis
- Analysis is complete and ready to report

## Entry Context

**When invoked from `analyzing-uitest-failures`:**

| Field | Description | Required |
|-------|-------------|----------|
| test_date | Date of test run | Yes |
| all_failures | All failure test names and errors | Yes |
| analysis_results | Conclusions from analysis/investigation | Yes |
| investigation_summaries | Root cause findings (if investigated) | No |

**Expected format example:**

```json
{
  "test_date": "2025-02-10",
  "all_failures": [
    {"test_name": "SSO_Login", "error": "element not found: Stay signed in"},
    {"test_name": "SSO_Logout", "error": "timeout waiting for element"}
  ],
  "analysis_results": [
    {
      "group": "SSO 群組",
      "tests": ["SSO_Login", "SSO_Logout"],
      "conclusion": "Fix",
      "status": "✓",
      "summary": "外部服務變更：Microsoft passkey 頁面"
    },
    {
      "group": "Network 組",
      "tests": ["API_Timeout_Test"],
      "conclusion": "Observe",
      "status": "⏳",
      "summary": "待處理"
    }
  ]
}
```

**If context missing:** Gather from `$HOME/Downloads/UITestAnalysis/latest/` and ask user for any investigation conclusions.

## Report Format

**Filename:** `triage_report_YYYY-MM-DD.md`

**Location:** `$HOME/Downloads/UITestAnalysis/latest/`

**Language:** Traditional Chinese with English technical terms

Use the template in [report-template.md](references/report-template.md).

## Required Sections

### 0. TL;DR

Ultra-concise summary (3-5 bullet points):
- Test pass rate
- Key problems with recommended actions
- Timeline expectations

### 1. Executive Summary (執行摘要)

- Total test count and failure rate
- Categorization by priority (High/Medium/Low)
- Brief summary of each failure group

### 2. Test Results Overview (測試結果概況)

Table showing:
- Test groups
- Failure counts
- Failure rates
- Severity

### 3. Detailed Analysis (詳細分析)

For each failure group:
- Failed test list
- Error messages
- Test purpose and steps
- Root cause analysis with evidence
- Failure type categorization
- Historical context if applicable

### 4. Risk Assessment & Actions (風險評估與建議行動)

Table format:

| 失敗群組 | 優先級 | 業務影響 | 建議處理 | 具體行動 | 預期時程 |
|----------|--------|----------|----------|----------|----------|

Include handling options explanation:
- **investigate**: Download screenshots for visual analysis
- **fix**: Create OpenSpec proposal
- **observe**: Record and wait for recurrence
- **report**: Escalate to management/external team

### 5. Appendix (附錄)

- Detailed failure test information
- Reference links (code locations, knowledge docs)
- Screenshot evidence list

## Do NOT Include

- OpenSpec proposal templates (belongs in execution phase)
- Quick decision guides
- Task checklists or TODO lists
- Meeting agendas or schedules

## Generation Process

1. **Gather all analysis results** from previous phases
2. **Structure content** by priority and category
3. **Write in Traditional Chinese** with professional tone
4. **Add evidence references** (screenshots, code links)
5. **Provide unified risk assessment** with specific actions

## Output

Save report to:
```
$HOME/Downloads/UITestAnalysis/latest/triage_report_YYYY-MM-DD.md
```

Confirm file location to user after generation.

## After Report Generation

Guide user to:
1. Share with stakeholders
2. Get decision on handling approach
3. Execute based on decision using `uitest-actions` skill

## Return Protocol

**Report back to `analyzing-uitest-failures`:**

| Field | Value |
|-------|-------|
| processed_tests | All tests included in report |
| conclusion | Report |
| summary | Report generated: <filename> |
| report_path | Full path to generated report |

**Example:** `✓ Report - 已產生報告 (triage_report_2025-02-10.md)`
