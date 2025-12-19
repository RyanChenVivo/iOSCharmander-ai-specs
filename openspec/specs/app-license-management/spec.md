# app-license-management Specification

## Purpose
TBD - created by archiving change fix-downgrade-threading-crash-2025-12-10. Update Purpose after archive.
## Requirements
### Requirement: UITest Failure Crash Detection
When UITests fail with "element not found" errors, teams SHALL follow a crash detection protocol before assuming the failure is a timing or flakiness issue.

#### Scenario: Suspicious UITest failure with no clear diagnostics
- **GIVEN** a UITest fails with "element not found" or timeout
- **AND** no clear screenshots show the UI state at failure
- **AND** no crash logs (.crash, .ips) are present in CI artifacts
- **AND** the test duration is normal (not immediately terminated)
- **AND** similar tests in the same class pass
- **WHEN** triaging the failure
- **THEN** the team SHALL run the test manually in Xcode simulator
- **AND** monitor the console for threading errors, crashes, or exceptions
- **AND** if a crash is detected, create an OpenSpec proposal immediately (production bug)
- **AND** if no crash is detected, proceed with standard triage (timing, environment, observation)

#### Scenario: Manual testing protocol for crash detection
- **GIVEN** a suspicious UITest failure
- **WHEN** performing manual crash detection
- **THEN** the engineer SHALL:
  1. Open the test class in Xcode
  2. Run the single failing test in simulator (not full suite)
  3. Watch the Xcode console during test execution
  4. Look for error messages containing: "thread", "main thread", "background thread", "layout engine"
  5. Verify whether app crashes or remains running
  6. Document findings in OpenSpec proposal if crash confirmed

#### Scenario: Documenting crash detection lessons
- **GIVEN** a UITest failure that appeared as timing issue but was actually a crash
- **WHEN** creating the fix proposal
- **THEN** the proposal SHALL document:
  - What the initial symptoms were (CI error message)
  - Why it initially appeared to be a timing issue
  - How manual testing revealed the true crash
  - The warning signs that should have triggered earlier crash detection
- **AND** the proposal SHALL include this as a lesson for future triage processes

### Requirement: UITest Triage Documentation
The UITest triage process SHALL include explicit guidance on detecting crashes hidden behind "element not found" errors.

#### Scenario: Triage documentation includes crash detection
- **GIVEN** the UITest triage documentation (README.md or command documentation)
- **WHEN** a developer follows the triage process
- **THEN** the documentation SHALL include a "Crash Detection" section
- **AND** the section SHALL appear before the "Observe Tomorrow" decision point
- **AND** the section SHALL list warning signs:
  - Element not found with no clear screenshot
  - Normal test duration (not immediate failure)
  - No crash logs in CI artifacts
  - Isolated failure with similar tests passing
- **AND** the section SHALL provide manual testing steps
- **AND** the section SHALL include at least one real example (e.g., test_cantDowngrade_activeLicenseExists)

#### Scenario: Triage workflow enforces manual testing for suspicious failures
- **GIVEN** a triage process for UITest failures
- **WHEN** determining whether to "observe tomorrow" or "fix immediately"
- **THEN** the process SHALL require manual testing for suspicious failures
- **AND** SHALL prevent marking failures as "transient" without crash detection
- **AND** SHALL provide clear decision criteria for when manual testing is required

