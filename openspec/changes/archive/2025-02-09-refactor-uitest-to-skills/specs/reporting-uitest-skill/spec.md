# reporting-uitest-skill

## Overview

Report generation skill for UITest failure analysis. This skill handles Phase 3: generating comprehensive Traditional Chinese reports for management or team communication.

## Files to Create

### `.claude/skills/reporting-uitest/SKILL.md`

```yaml
---
name: reporting-uitest
description: >
  Generate UITest failure analysis report. Use when formal report is needed
  for management or team. Report is in Traditional Chinese, includes summary,
  detailed analysis, risk assessment, and recommended actions.
---
```

**Content Structure:**

1. **Report Format Section**
   - Reference to template: `references/report-template.md`
   - Output language: Traditional Chinese

2. **Report Content Requirements**

   - **Required Sections:**
     1. **TL;DR** — One sentence summary
     2. **Executive Summary** — Key findings and recommendations
     3. **Failure Analysis** — Detailed analysis of each failure group
     4. **Risk Assessment** — Impact level and urgency
     5. **Recommended Actions** — Specific next steps

3. **Output Section**
   - Save to: `$HOME/Downloads/UITestAnalysis/latest/triage_report_YYYY-MM-DD.md`
   - Confirm file location to user

**Estimated Lines:** ~50

### `.claude/skills/reporting-uitest/references/report-template.md`

Traditional Chinese report template with placeholders:

```markdown
# UITest 失敗分析報告

**日期:** {{date}}
**分析人員:** Claude AI

---

## TL;DR

{{one_sentence_summary}}

---

## 執行摘要

### 關鍵發現
{{key_findings}}

### 建議行動
{{recommended_actions}}

---

## 失敗分析

### 失敗群組 1: {{group_name}}
- **影響測試:** {{test_count}} 個
- **錯誤類型:** {{error_type}}
- **根本原因:** {{root_cause}}
- **建議處理:** {{recommendation}}

{{repeat_for_each_group}}

---

## 風險評估

| 風險項目 | 影響程度 | 緊急性 | 備註 |
|---------|---------|--------|------|
| {{risk}} | {{impact}} | {{urgency}} | {{notes}} |

---

## 行動計畫

1. {{action_1}}
2. {{action_2}}
3. {{action_3}}

---

*報告由 Claude AI 自動生成*
```

## Acceptance Criteria

- [ ] SKILL.md follows YAML frontmatter format
- [ ] Description contains trigger keywords (report, management, formal)
- [ ] Template is in Traditional Chinese
- [ ] All required sections are documented
- [ ] Output path is clearly specified
- [ ] Total SKILL.md under 500 lines
- [ ] SKILL.md content in English (template in Chinese)

## Dependencies

- Typically invoked after `analyzing-uitest-failures` or `investigating-uitest`
- Requires analysis results from previous phases

## Testing

1. Invoke skill after completing analysis
2. Verify report template is used correctly
3. Verify output file is created at correct path
4. Verify all sections are populated
5. Verify Traditional Chinese formatting is correct
