## Why

The Portal has adopted "Area" as the official term replacing "Subsite". The App still uses "Subsite" in UI labels, code identifiers, and specs. This inconsistency confuses users and developers. Additionally, the "Create Site" flow needs to support creating Areas with type-specific form fields.

## What Changes

- Rename all "Subsite" references to "Area" across UI labels, code identifiers, localization strings, and specs
- Rename "Create Site" button to "Create Site or Area" in Add Device and Move Device flows
- Add type selection (Site / Area) in the creation form with type-specific fields:
  - Site: Name (required) + Location (optional)
  - Area: Name (required) + Parent picker (required, selects a Site or Area)
- Enforce Area creation hierarchy limits (max 2 levels under a Site, max 10 per level)

## Capabilities

### New Capabilities

### Modified Capabilities
- `subsite-display-name`: All "Subsite" terminology replaced with "Area" in display name resolution logic and UI labels
- `add-device-site-selection`: "Create Site" renamed to "Create Site or Area" with type selection and type-specific form fields (Site: Name + Location; Area: Name + Parent picker); Area creation enforces hierarchy limits

## Impact

- **Terminology**: Global rename "Subsite" → "Area" across UI strings, code, and localization files
- **UI Components**: CreateSiteView modified to support type selection and Area-specific form
- **App Pages**: Add Device flow, Move Device flow
- **Validation**: Area creation must enforce depth (max 2 levels) and count (max 10 per level) limits
