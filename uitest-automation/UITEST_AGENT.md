# UITest Failure Analysis Toolkit

> **Command:** `/analyze-uitest [action]`

## Overview

When CI UITests fail, this toolkit provides a systematic approach to analyze and handle failures.

**Design Philosophy: Toolkit, Not Pipeline**
- Not every phase is required
- Choose appropriate tools based on the situation
- Phase 1 is the decision center; others are optional tools

---

## Workflows

### Phase 1: Triage - Required Entry Point

**Purpose:** Initial analysis, grouping, and recommendations

**Execute:** `/analyze-uitest` (automatically runs Phase 1)

**Process:**
1. Download test data (JSON files, lightweight)
2. Analyze failed tests
3. Group and categorize (Environment/Service/Timing/Bug)
4. Consult existing knowledge (patterns.md, observations/, external-dependencies.md)
5. Provide recommended path

**Output:** Verbal report + next step recommendations

→ See `workflows/triage.md` for details

---

### Phase 2: Investigate - Optional Tool

**When to Use:**
- ❓ Root cause unclear
- 🖼️ Need visual confirmation (UI-related issues)
- 🔍 Need more evidence to conclude

**Execute:** `/analyze-uitest investigate`

**Process:**
1. Download screenshots and diagnostics (larger files)
2. Visual analysis of UI state
3. Compare expected vs actual screens
4. Confirm root cause

**Output:** Root cause analysis + updated recommendations

→ See `workflows/investigate.md` for details

---

### Phase 3: Report - Optional Tool

**When to Use:**
- 📋 Need to report to management
- 📊 Need formal documentation
- 🤝 Need team decision

**Execute:** `/analyze-uitest report`

**Process:**
1. Read analysis results from previous phases
2. Generate comprehensive Traditional Chinese report
3. Include: executive summary, detailed analysis, solution options, risk assessment, action plan

**Output:** `$HOME/Downloads/UITestAnalysis/latest/triage_report_YYYY-MM-DD.md`

→ See `workflows/report.md` for details

---

### Phase 4: Action - Optional Tool

**When to Use:**
- 📝 Decide to observe and wait
- 🔧 Decide to fix the issue
- 📚 Record learnings to knowledge base

**Execute:** `/analyze-uitest observe` or `/analyze-uitest fix`

**Process:**
1. **observe**: Record to `observations/active.json`, track future occurrences
2. **fix**: Prompt to use `/openspec:proposal`, record learnings
3. **learn**: Add fix experience to `knowledge/patterns.md`

**Output:** Updated observations or prepared for OpenSpec creation

→ See `workflows/action.md` for details

---

## Decision Guide

### Quick Decision Tree

```
After Phase 1 completes:

❓ Any failures?
├─ ❌ No → Done ✅
└─ ✅ Yes ↓

❓ Root cause clear?
├─ ✅ Clear and simple → Phase 4 (observe)
├─ ❓ Unclear → Phase 2 (investigate)
└─ ✅ Clear but need report → Phase 3 (report)

❓ Need to fix?
├─ ✅ Yes → Phase 4 (fix) → /openspec:proposal
└─ ❌ Observe only → Phase 4 (observe)
```

### Common Scenarios

| Scenario | Recommended Flow | Notes |
|----------|------------------|-------|
| 🎉 All tests pass | Phase 1 → Done | Report success |
| 🟢 Single simple error | Phase 1 → Phase 4 | Record observation |
| 🟡 UI-related error | Phase 1 → Phase 2 → Phase 3 | Need screenshots |
| 🔴 Complex multi-group errors | Phase 1 → Group handling | Different paths per group |
| 📋 Need management decision | Phase 1 → Phase 2 → Phase 3 | Full investigation + report |

→ More detailed decision logic in `knowledge/decision-tree.md`

---

## External Service Change Decision Logic

When test failures are caused by external service changes, use this checklist to decide between creating an OpenSpec proposal immediately or observing first.

### ✅ Create OpenSpec Proposal Immediately

Create proposal when **ALL** of the following conditions are met:

- [ ] **Deterministic**: 100% reproducible, fails every time the test runs
- [ ] **Permanent**: External service change is intentional and published (not a temporary issue)
- [ ] **Programmable**: We can adapt our test code to handle the new behavior
- [ ] **Solution known**: Clear path exists to fix the test

**Example: Microsoft adds passkey dialog (2025-12-03)**
- ✅ Deterministic: Dialog appears every time
- ✅ Permanent: Microsoft officially released this feature
- ✅ Programmable: Can add code to click "Ask later" button
- ✅ Solution known: `handlePasskeyDialogIfNeeded()` function
- **Action**: Created `fix-uitest-failures-2025-12-03` proposal ✓

### 🔄 Observe First (1-2 days)

Observe first when **ANY** of the following conditions are met:

- [ ] **Uncertain**: Not clear if the change is permanent or temporary
- [ ] **First occurrence**: No historical pattern or previous record
- [ ] **Non-programmable**: Code cannot change external behavior (e.g., IP block, account lock, service outage)
- [ ] **Requires human intervention**: Need to contact IT/service provider/account admin
- [ ] **May auto-recover**: Security alerts, temporary degradation, backend slowness

**Example: Microsoft blocks CI IP (2025-12-10)**
- ✅ Uncertain: Could be temporary security flag
- ✅ First occurrence: First time seeing this specific block
- ✅ Non-programmable: Cannot bypass security blocking with code
- ✅ Requires human intervention: Need to check Azure AD logs and contact IT
- ✅ May auto-recover: Security systems often auto-unblock after investigation
- **Action**: Add to `observations/active.json`, observe until 2025-12-12 ✓

### 📊 After Observation Period

If test still fails after observation period expires:

1. **Review observation history** from `observations/active.json`
2. **Analyze failure pattern**: Consistent (every time) vs intermittent (sometimes)
3. **Create OpenSpec proposal with context**:
   - Mention observation period in proposal (e.g., "Observed 2025-12-10 to 2025-12-12, failed consistently")
   - Include failure rate and pattern
   - Reference screenshots and error messages from triage reports
   - Document attempted mitigations or investigations
4. **Update external-dependencies.md** with the new behavior pattern

### 🎯 Pattern Recognition

| Failure Type | Deterministic? | Programmable? | Action |
|--------------|----------------|---------------|--------|
| New UI element appears | ✅ Yes | ✅ Yes | Proposal |
| API endpoint changed | ✅ Yes | ✅ Yes | Proposal |
| Security/IP blocking | ❌ Uncertain | ❌ No | Observe |
| Account locked | ❌ Uncertain | ❌ No | Observe |
| Backend slow (timing) | ❌ Intermittent | ⚠️ Maybe | Observe |
| Service outage | ❌ Temporary | ❌ No | Observe |

---

## Knowledge Base

### `knowledge/patterns.md` - Failure Pattern Library

**Purpose:** Record known failure patterns to improve decision consistency

**Contents:**
- Identification triggers (test name, error message)
- Diagnostic decisions (investigate/observe/report)
- Related fixes (archive/ links)

**Maintenance:**
- Manual editing (Markdown format)
- Prompted during Phase 4
- Accumulated over time

### `knowledge/decision-tree.md` - Decision Logic

**Purpose:** Help understand what to do in which situation

### `observations/` - Observation Tracking

**Purpose:** Track temporary issues under observation

**Files:**
- `active.json` - Currently observing (2-day expiration)
- `resolved.json` - Resolved/expired (30-day retention)

---

## Usage Examples

### Example 1: No Failures
```
User: /analyze-uitest
AI: [Phase 1] 120/120 tests passed ✅ No further action needed.
```

### Example 2: Simple Error
```
User: /analyze-uitest
AI: [Phase 1]
    Found 1 failure: NetworkTimeoutTest
    Error: Network timeout
    Category: Environment (transient)
    Recommendation: observe

User: /analyze-uitest observe
AI: [Phase 4] Recorded to observations/active.json
```

### Example 3: Investigation Needed (Today's Case)
```
User: /analyze-uitest
AI: [Phase 1]
    Found 8 failures in 3 groups:
    Group 1 (SSO, 3 tests) - 🔴 Needs investigation
    Group 2 (Message, 4 tests) - 🟡 Recommend observe
    Group 3 (License, 1 test) - 🟢 Recommend observe

    Recommendation: investigate SSO group first

User: /analyze-uitest investigate
AI: [Phase 2]
    [Downloading screenshots...]
    Screenshot confirms: Microsoft blocking login
    Recommendation: generate report

User: /analyze-uitest report
AI: [Phase 3]
    Generated: triage_report_2025-12-10.md
```

---

## Advanced Features

<!-- 🔮 FUTURE ENHANCEMENT -->
### Semi-Automated Learning (Future)

**Feature:** Automatically extract patterns from OpenSpec archives

**Command:** `/analyze-uitest:learn [archive-name]`

**When:** After fix is completed and archived

**Purpose:**
- Auto-analyze proposal to find patterns
- Generate pattern draft
- Ask if should add to knowledge/patterns.md

**Status:** 🚧 To be implemented

---

## Documentation Index

- **workflows/**
  - `triage.md` - Phase 1 detailed process
  - `investigate.md` - Phase 2 detailed process
  - `report.md` - Phase 3 detailed process
  - `action.md` - Phase 4 detailed process

- **knowledge/** (AI diagnostic knowledge)
  - `patterns.md` - Failure pattern library
  - `decision-tree.md` - Decision logic
  - `external-dependencies.md` - Known external service issues
  - `timing-guidelines.md` - Timeout and wait strategies

- **reference/** (Test implementation reference)
  - `test-data.md` - Test data requirements
  - `ui-identifiers.md` - UI element accessibility IDs

- **observations/**
  - `active.json` - Current observations
  - `resolved.json` - Resolved observations

---

**Ready?** Run `/analyze-uitest` to start analyzing!
