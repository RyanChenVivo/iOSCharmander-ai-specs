## MODIFIED Requirements

### Requirement: Site Display Name Path Resolution

The system SHALL resolve each site's display name to include the full ancestor path by walking the `parentId` chain from the API response.

#### Scenario: Top-level site (no parent)

- **GIVEN** a site with `parentId` equal to empty string or organization ID (default site)
- **WHEN** constructing `SiteItem`
- **THEN** display name SHALL be the site's raw API name (e.g., "Taipei Office")

#### Scenario: Single-level area

- **GIVEN** a site with `parentId` pointing to a top-level site
- **WHEN** constructing `SiteItem`
- **THEN** display name SHALL be "ParentName > AreaName" (e.g., "Taipei Office > 3F")

#### Scenario: Multi-level nested area

- **GIVEN** a site with `parentId` chain of depth N (e.g., A -> B -> C)
- **WHEN** constructing `SiteItem`
- **THEN** display name SHALL be the full ancestor path joined by " > " (e.g., "A > B > C")

#### Scenario: Separator format

- **WHEN** joining ancestor names into a display path
- **THEN** the separator SHALL be " > " (space, greater-than, space)

---

### Requirement: Search Matches Full Path Name

The system SHALL match search keywords against the full path display name.

#### Scenario: Search by area's own name

- **GIVEN** an area with display name "Taipei Office > 3F"
- **WHEN** user searches for "3F"
- **THEN** the area SHALL appear in search results

#### Scenario: Search by ancestor name

- **GIVEN** an area with display name "Taipei Office > 3F"
- **WHEN** user searches for "Taipei"
- **THEN** the area SHALL appear in search results

---

### Requirement: Sort Uses Full Path Name

The system SHALL sort sites alphabetically by their full path display name.

#### Scenario: Areas under same parent group together

- **GIVEN** sites: "Taipei Office", "Taipei Office > 3F", "Taipei Office > 5F", "Kaohsiung Office"
- **WHEN** sorting the site list
- **THEN** order SHALL be: "Kaohsiung Office", "Taipei Office", "Taipei Office > 3F", "Taipei Office > 5F"

#### Scenario: Default site sort exception

- **GIVEN** the default site (organization root) exists in the list
- **WHEN** sorting the site list
- **THEN** the default site SHALL sort last regardless of its path name

## RENAMED Requirements

### Requirement: Site Display Name Path Resolution
Scenario renames only — "subsite" → "area" in scenario names and descriptions. No behavioral change.
