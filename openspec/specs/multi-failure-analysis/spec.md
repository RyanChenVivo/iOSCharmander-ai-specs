## ADDED Requirements

### Requirement: System SHALL analyze all failures when multiple tests fail

When CI data contains multiple test failures, the system SHALL analyze each failure independently using the existing Phase 1 analysis flow, then aggregate results.

#### Scenario: Multiple failures are analyzed
- **WHEN** CI data contains 5 test failures
- **THEN** system analyzes each of the 5 failures using pattern matching and history check
- **THEN** system aggregates all 5 analysis results for grouping

#### Scenario: Single failure maintains current behavior
- **WHEN** CI data contains only 1 test failure
- **THEN** system uses the existing single-failure flow without grouping

---

### Requirement: System SHALL group failures by recommended action

After analyzing all failures, the system SHALL group them by their recommended action (Observe, Investigate, Fix, Restore).

#### Scenario: Failures grouped by action
- **WHEN** analysis produces 3 Observe recommendations and 2 Investigate recommendations
- **THEN** system creates an "Observe" group with 3 items
- **THEN** system creates an "Investigate" group with 2 items

---

### Requirement: System SHALL identify same-source failures within action groups

Within each action group, the system SHALL further subdivide failures that may share the same root cause.

#### Scenario: Same pattern ID indicates same source
- **WHEN** two failures both match pattern "sso-new-dialog"
- **THEN** system groups them together as "可能同源：sso-new-dialog pattern"

#### Scenario: Same test name prefix indicates possible same source
- **WHEN** two failures have test names "SSO_Login" and "SSO_Logout" (same prefix "SSO")
- **THEN** system groups them together as "SSO 群組"

#### Scenario: Different patterns and prefixes are separate
- **WHEN** failures have different patterns and different test name prefixes
- **THEN** system keeps them in separate sub-groups within the action group

---

### Requirement: System SHALL output a summary view

The system SHALL display a formatted summary showing all groups with their failures.

#### Scenario: Summary displays group structure
- **WHEN** analysis is complete with grouped results
- **THEN** summary shows each action group with emoji indicator (🟡 Observe, 🔴 Investigate)
- **THEN** each group shows failure count and same-source reasoning
- **THEN** each failure shows test name and brief error message

#### Scenario: Summary includes processing recommendation
- **WHEN** displaying an Observe group
- **THEN** summary shows "→ 可直接批次記錄"
- **WHEN** displaying an Investigate group with possible same-source failures
- **THEN** summary shows "→ 建議一起下載截圖分析"
- **WHEN** displaying an Investigate group with unrelated failures
- **THEN** summary shows "→ 建議逐一處理"

---

### Requirement: System SHALL present action choices after summary

After displaying the summary, the system SHALL present selectable options for the user.

#### Scenario: Options match group structure
- **WHEN** summary has 1 Observe group (3 items) and 2 Investigate sub-groups (2 items each)
- **THEN** options are:
  - A) Observe 組 - 批次記錄觀察
  - B) Investigate: [群組1名稱] - 一起分析
  - C) Investigate: [群組2名稱] - 逐一分析
  - D) 產生報告 - 整合所有分析結果
