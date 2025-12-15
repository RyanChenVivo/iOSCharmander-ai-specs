# Analyze UITest Failures

> **Command:** `/analyze-uitest`

Analyze UITest failures from CI using a modular toolkit approach. This command provides flexible workflows for triage, investigation, reporting, and action.

---

## Quick Start

This command starts **Phase 1: Triage** - the required entry point for failure analysis.

**What it does:**
1. Downloads test data from CI (lightweight JSON files only, ~100KB)
2. Performs AI-powered triage analysis
3. Presents findings and asks what you want to do next
4. Executes your chosen action (investigate/report/observe/fix)

---

## Complete Documentation

**📖 Read this first:** `@/uitest-automation/UITEST_AGENT.md`

The UITEST_AGENT.md file contains:
- **Overview** - Toolkit design philosophy and workflow structure
- **4 Phase Workflows** - Triage, Investigate, Report, Action
- **Knowledge Base** - Patterns library and decision tree
- **Common Scenarios** - Recommended flows for different situations

---

## Design Philosophy: Toolkit, Not Pipeline

This is a **non-linear workflow**:
- ✅ Phase 1 (Triage) is **required** - always the entry point
- ✅ Other phases are **optional tools** - use as needed
- ✅ You can skip phases or use them in different orders
- ✅ Different failure groups can use different paths

**Example:** You might investigate SSO failures (Phase 2) while observing message failures (Phase 4) - all from the same triage analysis (Phase 1).

---

## The 4 Phases

### Phase 1: Triage (Required Entry Point)
**File:** `uitest-automation/workflows/triage.md`

- Download test data from CI
- Analyze failures using multiple sources:
  - Test failure data and source code
  - External dependencies knowledge
  - Historical fixes and observations
  - Failure pattern library and decision tree
- Present findings verbally
- Ask user to choose next action (A/B/C/D/E)

### Phase 2: Investigate (Optional Tool)
**File:** `uitest-automation/workflows/investigate.md`

**When to use:** UI-related errors, unclear root cause, need visual confirmation

- Download screenshots and diagnostics
- Perform visual analysis
- Confirm root cause with evidence
- Update recommendations based on findings

### Phase 3: Report (Optional Tool)
**File:** `uitest-automation/workflows/report.md`

**When to use:** Need management decision, formal documentation

- Generate comprehensive Traditional Chinese report
- Include TL;DR, executive summary, detailed analysis
- Provide unified risk assessment with actionable recommendations
- Save as `triage_report_YYYY-MM-DD.md`

### Phase 4: Action (Optional Tool)
**File:** `uitest-automation/workflows/action.md`

**Three action types:**
1. **Observe** - Record to `observations/active.json` and wait
2. **Fix** - Prompt for `/openspec:proposal` to create fix
3. **Learn** - Record pattern to `knowledge/patterns.md` for future reference

---

## Knowledge Base

### Failure Pattern Library
**File:** `uitest-automation/knowledge/patterns.md`

Records known failure patterns for consistent triage decisions:
- AI checks patterns **before** general reasoning
- If failure matches pattern → use pattern's recommended decision
- Patterns continuously updated as recurring issues are discovered
- Each pattern includes identification triggers and recommended actions

### Decision Tree
**File:** `uitest-automation/knowledge/decision-tree.md`

Structured decision logic for failure scenarios when no pattern matches:
- Considers failure count, error type, test history, timing context
- Provides decision matrix and guidance for new failure types

---

## Typical Workflows

| Scenario | Flow | Notes |
|----------|------|-------|
| 🎉 All tests pass | Phase 1 → Done | Report success |
| 🟢 Single simple error | Phase 1 → Phase 4 (observe) | Record and wait |
| 🟡 UI-related error | Phase 1 → Phase 2 (investigate) → Phase 3 (report) | Need screenshots |
| 🔴 Complex errors | Phase 1 → Group handling | Different paths per group |
| 📋 Management review | Phase 1 → Phase 2 (investigate) → Phase 3 (report) | Full analysis first |

---

## What You'll Be Asked

After Phase 1 triage, you'll choose:

```
A) Create OpenSpec proposal to track and fix
B) Download screenshots for visual analysis
C) Observe tomorrow (wait to see if it repeats)
D) No action needed
E) Generate detailed triage report for management
```

You can also mix approaches for different failure groups.

---

## Key Features

### Pattern Matching
- AI checks `knowledge/patterns.md` for known failure patterns
- Ensures consistent decisions for recurring issues
- Patterns link to archived fixes for context

### Historical Context
- Checks `observations/active.json` for ongoing observations
- Checks `observations/resolved.json` for previously resolved issues
- If issue recurred → escalate from "observe" to "fix"

### Flexible Workflows
- Not every phase is required
- Choose appropriate tools based on situation
- Phase 1 acts as decision center

### Knowledge Accumulation
- Patterns improve over time
- Historical fixes provide context
- Observations track transient vs persistent issues

---

## Files and Locations

**Toolkit Documentation:**
- `/uitest-automation/UITEST_AGENT.md` - Main entry point guide
- `/uitest-automation/workflows/triage.md` - Phase 1 process
- `/uitest-automation/workflows/investigate.md` - Phase 2 process
- `/uitest-automation/workflows/report.md` - Phase 3 process
- `/uitest-automation/workflows/action.md` - Phase 4 process

**Knowledge Base:**
- `/uitest-automation/knowledge/patterns.md` - Known failure patterns
- `/uitest-automation/knowledge/decision-tree.md` - Decision logic for new failures
- `/uitest-automation/knowledge/external-dependencies.md` - External service behaviors
- `/uitest-automation/knowledge/timing-guidelines.md` - Timing and wait strategies

**Data Files:**
- `/uitest-automation/observations/active.json` - Currently observing
- `/uitest-automation/observations/resolved.json` - Recently resolved (30-day retention)

**Test Data (Downloaded):**
- `$HOME/Downloads/UITestAnalysis/latest/` - CI test results
- `openspec/changes/archive/` - Historical fixes

---

## Getting Started

1. **First time?** Read `@/uitest-automation/UITEST_AGENT.md` for complete overview
2. **Run the command:** `/analyze-uitest` starts Phase 1 (Triage)
3. **Follow the prompts:** AI will guide you through the analysis
4. **Choose your path:** Select appropriate phases based on situation

---

**For detailed workflows, decision logic, and examples, see:** `@/uitest-automation/UITEST_AGENT.md`
