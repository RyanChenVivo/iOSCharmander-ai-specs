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

The report should include these 7 sections:

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

### 4. 建議方案 (Recommended Solutions)
- Option A: Immediate investigation and fix
- Option B: Observe and wait
- Option C: Create OpenSpec proposal
- Option D: Mixed strategy (分組處理) ⭐ Recommended
- Each option includes: applicable tests, action steps, pros/cons, timeline

### 5. 風險評估 (Risk Assessment)
- Impact analysis for each failure group
- Business risk if left unfixed

### 6. 下一步行動建議 (Next Steps)
- Detailed action plan with timeline
- Clear responsibilities and decision points

### 7. 附錄 (Appendix)
- A. Detailed failure test information (tables)
- B. Reference materials (links to code, docs)
- C. Screenshot evidence (file references)
- D. Related code locations
- E. Decision checklist for management

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
- Use ⭐ to mark recommended options
- Use checkboxes (✅/❌/⚠️) for status indicators
- Include tables for structured data

---

## Example Report

See the example report created today:
- `/Users/ryanchen/Downloads/UITestAnalysis/latest/triage_report_2025-12-10.md`

This report demonstrates:
- How to group failures by category
- How to present recommendations with options
- How to include both technical and business perspectives
- How to structure for management decision-making

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

### Step 5: Provide Decision Options

Give management clear choices:
- Multiple solution options (A/B/C/D)
- Pros/cons for each
- Time estimates
- Risk assessments

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
   - Which option (A/B/C/D) to proceed?
   - Who will handle it?
   - What's the timeline?

3. **Execute based on decision**
   - If fix → proceed to Phase 4 (action)
   - If observe → proceed to Phase 4 (observe)
   - If investigate more → back to Phase 2

---

**Next:** Based on report and management decision, proceed to Phase 4 for action.
