## ADDED Requirements

### Requirement: Search keyword highlighting in site tree rows
When a search keyword is active, SiteTreeRow SHALL highlight matching text within the site name using a blue background.

#### Scenario: Matching text highlighted during search
- **WHEN** user enters a keyword in the search bar
- **AND** a site name contains the keyword (case-insensitive)
- **THEN** the matching substring(s) in the site name SHALL be rendered with a blue background color and white foreground color
- **AND** non-matching portions of the name SHALL retain default styling

#### Scenario: Multiple matches within a single name
- **WHEN** a site name contains multiple occurrences of the keyword
- **THEN** all occurrences SHALL be highlighted

#### Scenario: No highlighting when search is empty
- **WHEN** the search bar is empty or has no text
- **THEN** site names SHALL render as plain text without any highlighting

#### Scenario: Highlighting removed when search cleared
- **WHEN** user clears the search keyword
- **THEN** all site name highlighting SHALL be removed immediately
- **AND** names SHALL return to plain text rendering

#### Scenario: Highlighting uses AttributedString
- **WHEN** highlighting is applied
- **THEN** the implementation SHALL use `AttributedString` with `.backgroundColor` and `.foregroundColor` attributes on matched ranges
- **AND** it SHALL handle dynamic type and accessibility text sizes correctly
