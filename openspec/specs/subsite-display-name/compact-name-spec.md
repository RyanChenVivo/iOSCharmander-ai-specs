# subsite-display-name Compact Name Specification

## Purpose
Budget-based compression algorithm for SiteItem compactName, used in width-constrained UI contexts.

## Requirements

### Requirement: Compact Display Name for Width-Constrained UI

The system SHALL provide a `compactName` on `SiteItem` that compresses the path string using a budget-based algorithm, prioritizing the most important segments so that UI tail truncation removes the least important information first.

#### Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| Budget | 18 characters | Target maximum length for compact name |
| Separator | ` > ` (3 chars) | Delimiter between path segments |
| Min first segment length | 5 characters | Minimum preserved length for first segment (or full length if shorter than 5) |
| Min truncated length | 2 characters | Minimum meaningful truncation (1 char + `...`) |
| Ellipsis | `...` (U+2026) | Single character, not `...` (three dots) |

#### Priority

Information preservation priority: **last segment > first segment > middle segments**.

#### Algorithm

**Step 0: No compression needed**
Full path <= 18 characters -> return as-is.

**Step 1: Preserve last segment (always full, never truncated)**
Last segment is always kept in full. If the result exceeds UI width, the frontend component handles final truncation (e.g., SwiftUI tail truncation).

**Step 2: Preserve first segment (minimum 5 characters)**
First segment is kept at least 5 characters. If the original is shorter than 5, keep it in full.

**Step 3: Calculate middle segment budget**
```
separatorCost = separatorLength x (totalLayers - 1)
budgetForMiddles = budget - lastLength - minFirstLength - separatorCost
budgetPerMiddle = budgetForMiddles / middleCount
```

**Step 4: Decide whether middles fit**
- `budgetPerMiddle >= 2` -> **fits**: truncate each middle segment to `budgetPerMiddle`. Return leftover space to first segment.
- `budgetPerMiddle < 2` -> **doesn't fit**: collapse ALL middle segments to `...`. Recalculate first segment budget as `max(budget - collapsedSeparatorCost - lastLength, minFirst)`.

**No middle segments (2 layers):**
Truncate first segment, keep last segment in full.

#### Truncation Rule

`truncate(segment, maxLength)`:
- If `segment.length <= maxLength` -> return as-is
- Otherwise -> take first `maxLength - 1` characters + `...`

#### Scenario: Top-level site (1 component)

- **GIVEN** a site with no parent (single path component)
- **WHEN** reading `compactName`
- **THEN** it SHALL equal `name` (no transformation)

#### Scenario: Full path within character limit

- **GIVEN** a subsite with full path <= 18 characters (e.g., `"A > B > C"` = 9 chars)
- **WHEN** reading `compactName`
- **THEN** it SHALL equal `name` (full path, no truncation)

#### Scenario: Two-level subsite exceeding character limit

- **GIVEN** a 2-layer site with full path > 18 characters (e.g., `"main building 1 > action floor 1"` = 34 chars)
- **WHEN** reading `compactName`
- **THEN** the first segment SHALL be truncated to fit within budget (minimum 5 chars)
- **AND** the last segment SHALL appear in full
- **AND** format SHALL be `"truncatedFirst > last"` (e.g., `"main... > action floor 1"`)

#### Scenario: Multi-level subsite with sufficient middle budget

- **GIVEN** a 3+ layer site with full path > 18 characters and budgetPerMiddle >= 2 (e.g., `"A > BBBBBBBBBBBBB > C"` = 21 chars)
- **WHEN** reading `compactName`
- **THEN** each middle segment SHALL be truncated to fit within its equal share of remaining budget
- **AND** leftover budget from middles SHALL be given back to first segment
- **AND** the last segment SHALL appear in full
- **AND** format SHALL be `"first > truncatedMiddle > last"` (e.g., `"A > BBBBBBBBB... > C"` = 18 chars)

#### Scenario: Multi-level subsite with insufficient middle budget

- **GIVEN** a 3+ layer site with full path > 18 characters and budgetPerMiddle < 2 (e.g., `"main building 1 > floor 1 > room 1"` = 34 chars)
- **WHEN** reading `compactName`
- **THEN** ALL middle layers SHALL be collapsed to a single `...`
- **AND** the first segment SHALL be truncated to fit within budget (minimum 5 chars)
- **AND** the last segment SHALL appear in full
- **AND** format SHALL be `"truncatedFirst > ... > last"` (e.g., `"main... > ... > room 1"` = 18 chars)

#### Scenario: Short first segment with long last segment

- **GIVEN** a 2-layer site where first segment < 5 characters (e.g., `"A > long last segment name"`)
- **WHEN** reading `compactName`
- **THEN** the first segment SHALL be kept in full (not padded or replaced)
- **AND** the last segment SHALL appear in full

#### Scenario: Last segment always preserved in full

- **GIVEN** any subsite (2+ components)
- **WHEN** reading `compactName`
- **THEN** the last path component SHALL appear in full without truncation by `compactName` logic
- **AND** only UI component tail truncation may further shorten it at render time

---

### Requirement: Path Components Stored on SiteItem

`SiteItem` SHALL store a `pathComponents: [String]` property. `DeviceManager.resolvePathComponents` resolves the ancestor chain and passes the resulting array to `SiteItem.init`. `SiteItem.name` is derived by joining `pathComponents` with the separator. `SiteItem.compactName` is a computed property that applies the budget-based algorithm to `pathComponents` on access.

#### Scenario: Components used to derive both names

- **GIVEN** a multi-level subsite A -> B -> C
- **WHEN** `DeviceManager` constructs `SiteItem` with `pathComponents: ["A", "B", "C"]`
- **THEN** `SiteItem.name` SHALL be `"A > B > C"` (joined from pathComponents)
- **AND** `SiteItem.compactName` SHALL be computed on access using budget-based algorithm

---

### Requirement: View Tab Site Row Display

The View tab `SiteRow` SHALL use `compactName` for display text instead of `name`.

#### Scenario: Subsite in View tab section header

- **GIVEN** a subsite with long full path name
- **WHEN** rendering in View tab site row (single-line, width-constrained)
- **THEN** the displayed text SHALL be `compactName`
- **AND** the row layout and truncation behavior SHALL remain unchanged (tail truncation)
