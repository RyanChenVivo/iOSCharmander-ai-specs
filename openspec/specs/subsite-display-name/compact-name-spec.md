# subsite-display-name Breadcrumb Layout Specification

## Purpose
Pixel-based truncation algorithm for BreadcrumbText, used in width-constrained UI contexts to display site path hierarchy.

## Requirements

### Requirement: Pixel-Based Breadcrumb Layout for Width-Constrained UI

The system SHALL provide a `BreadcrumbText` View that renders `pathComponents` with intelligent pixel-based truncation, prioritizing the most important segments when space is insufficient.

#### Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| Font | System 15pt Semibold | Font used for both rendering and width measurement |
| Separator | ` > ` | Delimiter between path segments |
| Min segment width | 40pt | Minimum pixel width before a segment is collapsed |
| Ellipsis | `…` (U+2026) | Single character used for truncation and collapse |

#### Priority

Information preservation priority: **last segment (current) > first segment (root) > penultimate > middle segments**.

#### Algorithm

**Step 0: No compression needed**
Total rendered width of all segments + separators <= available width → render all segments in full.

**Step 1: Build truncation order**
Segments are sacrificed in this order (least important first):
1. Middle segments (index 1..<count-2), front to back
2. Penultimate segment (index count-2)
3. First segment (index 0)

Last segment (current location) is NEVER truncated or collapsed.

**Step 2: For each segment in truncation order, attempt to recover overflow**

- If truncating to `minSegmentWidth` recovers enough space → truncate to the exact width needed
- If segment is first (index 0) → truncate to `minSegmentWidth` (never collapse)
- Otherwise → collapse to `…`; consecutive collapses merge into a single `…`

#### Truncation Rule

`truncatedToFit(text, maxWidth)`:
- If text fits within maxWidth → return as-is
- Otherwise → binary search from end: take first N characters + `…` until it fits
- Minimum result is bare `…`

#### Scenario: Top-level site (1 component)

- **GIVEN** a site with a single path component
- **WHEN** rendering BreadcrumbText
- **THEN** it SHALL display the component in full, marked as current

#### Scenario: Full path within available width

- **GIVEN** a subsite whose full rendered path fits within the container width
- **WHEN** rendering BreadcrumbText
- **THEN** all segments SHALL be displayed in full without truncation

#### Scenario: Two-level subsite exceeding available width

- **GIVEN** a 2-layer site whose full path exceeds available width
- **WHEN** rendering BreadcrumbText
- **THEN** the first segment SHALL be truncated (prefix + `…`)
- **AND** the last segment SHALL appear in full

#### Scenario: Multi-level subsite with middle segments collapsed

- **GIVEN** a 3+ layer site whose middle segments cannot fit even at minimum width
- **WHEN** rendering BreadcrumbText
- **THEN** consecutive collapsed middle segments SHALL be merged into a single `…`
- **AND** the first segment SHALL be truncated (never collapsed)
- **AND** the last segment SHALL appear in full

#### Scenario: Penultimate segment preserved before middle segments

- **GIVEN** a 4+ layer site with insufficient width for all segments
- **WHEN** middle segments are collapsed but penultimate still fits
- **THEN** the result SHALL be `first > … > penultimate > last`
- **AND** the penultimate segment is only sacrificed after all middle segments are collapsed

#### Scenario: First segment never fully collapsed

- **GIVEN** any multi-level site regardless of available width
- **WHEN** rendering BreadcrumbText
- **THEN** the first segment SHALL always show at least one character + `…`
- **AND** it SHALL never be collapsed to a bare `…`

#### Scenario: Last segment always preserved in full

- **GIVEN** any subsite (2+ components)
- **WHEN** rendering BreadcrumbText
- **THEN** the last path component SHALL appear in full without any truncation

---

### Requirement: Visual Distinction Between Current and Ancestor Segments

BreadcrumbText SHALL visually distinguish the current segment (last) from ancestor segments.

#### Scenario: Color differentiation

- **GIVEN** a multi-level path rendered in BreadcrumbText
- **WHEN** displayed
- **THEN** the last segment SHALL use primary text color (color01)
- **AND** ancestor segments and separators SHALL use secondary text color (color20)

---

### Requirement: Path Components Stored on SiteItem

`SiteItem` SHALL store a `pathComponents: [String]` property. `DeviceManager.resolvePathComponents` resolves the ancestor chain and passes the resulting array to `SiteItem.init`.

#### Scenario: Components used for display

- **GIVEN** a multi-level subsite A -> B -> C
- **WHEN** `DeviceManager` constructs `SiteItem` with `pathComponents: ["A", "B", "C"]`
- **THEN** `SiteItem.displayName` SHALL be `"A > B > C"` (joined from pathComponents)
- **AND** `BreadcrumbText` SHALL receive `pathComponents` for pixel-based rendering

---

### Requirement: Unified Breadcrumb Display Across App

All site name displays in width-constrained contexts SHALL use `BreadcrumbText` with `pathComponents`.

#### Scenario: View Tab site row

- **GIVEN** a subsite displayed in View tab site row
- **WHEN** rendering the site row header
- **THEN** it SHALL use `BreadcrumbText(pathComponents: site.pathComponents)`

#### Scenario: Device filter site header

- **GIVEN** a subsite displayed in device filter
- **WHEN** rendering the site header
- **THEN** it SHALL use `BreadcrumbText(pathComponents: site.pathComponents)`

#### Scenario: Device picker site label

- **GIVEN** a subsite displayed in device picker
- **WHEN** rendering the site disclosure group label
- **THEN** it SHALL use `BreadcrumbText(pathComponents: site.pathComponents)`
