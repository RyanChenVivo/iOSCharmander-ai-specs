# UITests Specification Delta

## MODIFIED Requirements

### Requirement: SSO Authentication Test Flow
The UITest suite SHALL handle variations in Microsoft Entra ID SSO authentication flow, including optional dialogs that may appear or be skipped depending on browser state and Microsoft's authentication policies.

#### Scenario: SSO signin with optional "Stay signed in?" dialog
- **GIVEN** a user is signing in via Microsoft SSO
- **WHEN** the SSO authentication completes successfully
- **THEN** the test SHALL proceed whether or not the "Stay signed in?" dialog appears
- **AND** if the dialog appears, the test SHALL tap "No" to continue
- **AND** if the dialog does not appear, the test SHALL proceed directly to verify the View page loads

#### Scenario: SSO signin dialog changes over time
- **GIVEN** Microsoft may update their SSO UI at any time
- **WHEN** optional dialogs are removed or added
- **THEN** tests SHALL remain resilient by using optional element waits
- **AND** tests SHALL not fail due to missing optional UI elements

### Requirement: Access Control Door Status Testing
The UITest suite SHALL verify door status displays correctly for various door configurations, handling different door states that may vary based on test environment configuration.

#### Scenario: DND door status verification
- **GIVEN** a test device with access control door binding
- **WHEN** viewing a DND (Do Not Disturb) door
- **THEN** the test SHALL verify the door status matches the current UAT environment configuration
- **AND** the test SHALL document the expected door status for the test environment

#### Scenario: Door status validation flexibility
- **GIVEN** UAT test environment door configurations may change
- **WHEN** running access control tests
- **THEN** tests SHALL either verify against known stable door states OR
- **AND** include test data setup to ensure doors are in expected states before testing

### Requirement: License Phase Feature Availability Testing
The UITest suite SHALL correctly validate which features are enabled or disabled during different license phases (notice, grace period, overdue).

#### Scenario: Grace period camera settings availability
- **GIVEN** an organization in license grace period
- **WHEN** viewing device settings
- **THEN** the test SHALL verify camera settings button visibility matches the actual grace period policy
- **AND** the test SHALL be consistent with notice and overdue phase tests

#### Scenario: License phase consistency validation
- **GIVEN** multiple license phase tests exist
- **WHEN** testing feature availability across phases
- **THEN** all license phase tests SHALL have consistent expectations
- **AND** tests SHALL document the expected behavior for each license phase

## ADDED Requirements

### Requirement: UITest Resilience to External Service Changes
UITests that depend on external services (SSO providers, access control systems) SHALL be designed to handle UI changes gracefully without requiring immediate test updates.

#### Scenario: Optional UI element handling
- **GIVEN** a test interacting with external service UI (SSO, web views)
- **WHEN** optional UI elements may or may not appear
- **THEN** the test SHALL use `waitElementToAppearOptionally` for non-critical UI elements
- **AND** the test SHALL only use `waitElementToAppear` for elements guaranteed to appear

#### Scenario: Test documentation for external dependencies
- **GIVEN** tests depending on external services
- **WHEN** authoring or maintaining such tests
- **THEN** tests SHALL include comments documenting known UI variations
- **AND** tests SHALL include the date of last external service UI verification
