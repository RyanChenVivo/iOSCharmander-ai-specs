# subsite-display-name Specification

## Purpose
Site path resolution logic - resolving full ancestor paths via parentId chain for subsite display names.

## Requirements

### Requirement: Site Display Name Path Resolution

The system SHALL resolve each site's display name to include the full ancestor path by walking the `parentId` chain from the API response.

#### Scenario: Top-level site (no parent)

- **GIVEN** a site with `parentId` equal to empty string or organization ID (default site)
- **WHEN** constructing `SiteItem`
- **THEN** display name SHALL be the site's raw API name (e.g., "Taipei Office")

#### Scenario: Single-level subsite

- **GIVEN** a site with `parentId` pointing to a top-level site
- **WHEN** constructing `SiteItem`
- **THEN** display name SHALL be "ParentName > SubsiteName" (e.g., "Taipei Office > 3F")

#### Scenario: Multi-level nested subsite

- **GIVEN** a site with `parentId` chain of depth N (e.g., A -> B -> C)
- **WHEN** constructing `SiteItem`
- **THEN** display name SHALL be the full ancestor path joined by " > " (e.g., "A > B > C")

#### Scenario: Separator format

- **WHEN** joining ancestor names into a display path
- **THEN** the separator SHALL be " > " (space, greater-than, space)

---

### Requirement: Path Resolution Robustness

The system SHALL handle malformed `parentId` data gracefully without crashing.

#### Scenario: Orphan parentId (references non-existent site)

- **GIVEN** a site whose `parentId` points to an ID not present in the site list
- **WHEN** constructing `SiteItem`
- **THEN** the path resolution SHALL terminate at the orphan point
- **AND** display name SHALL include only the resolvable portion of the chain

#### Scenario: Circular parentId reference

- **GIVEN** a site whose `parentId` chain forms a cycle (e.g., A -> B -> A)
- **WHEN** constructing `SiteItem`
- **THEN** the path resolution SHALL detect the cycle via visited-set
- **AND** display name SHALL include only the portion resolved before cycle detection

---

### Requirement: Search Matches Full Path Name

The system SHALL match search keywords against the full path display name.

#### Scenario: Search by subsite's own name

- **GIVEN** a subsite with display name "Taipei Office > 3F"
- **WHEN** user searches for "3F"
- **THEN** the subsite SHALL appear in search results

#### Scenario: Search by ancestor name

- **GIVEN** a subsite with display name "Taipei Office > 3F"
- **WHEN** user searches for "Taipei"
- **THEN** the subsite SHALL appear in search results

---

### Requirement: Sort Uses Full Path Name

The system SHALL sort sites alphabetically by their full path display name.

#### Scenario: Subsites under same parent group together

- **GIVEN** sites: "Taipei Office", "Taipei Office > 3F", "Taipei Office > 5F", "Kaohsiung Office"
- **WHEN** sorting the site list
- **THEN** order SHALL be: "Kaohsiung Office", "Taipei Office", "Taipei Office > 3F", "Taipei Office > 5F"

#### Scenario: Default site sort exception

- **GIVEN** the default site (organization root) exists in the list
- **WHEN** sorting the site list
- **THEN** the default site SHALL sort last regardless of its path name
