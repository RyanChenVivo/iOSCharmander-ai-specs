# UITests Specification Delta

## MODIFIED Requirements

### Requirement: Cloud Playback Speed Control Testing
The UITest suite SHALL reliably verify playback speed control functionality in cloud playback, handling main thread busy conditions and UI loading delays that may occur during heavy video processing.

#### Scenario: Speed selection with main thread resilience
- **GIVEN** a user is viewing cloud playback
- **WHEN** changing playback speed from 1x to 2x
- **THEN** the test SHALL wait for the speed menu to fully appear before interacting
- **AND** the test SHALL use extended timeout (minimum 15 seconds) to handle main thread busy conditions
- **AND** the test SHALL verify the speed button displays the new speed value

#### Scenario: Speed menu interaction with retry logic
- **GIVEN** video playback may cause temporary main thread delays
- **WHEN** tapping the speed button to open the menu
- **THEN** the test SHALL explicitly wait for speed menu container to appear
- **AND** the test SHALL allow sufficient time for menu UI to stabilize before selecting options
- **AND** the test SHALL retry the interaction if the element becomes temporarily unavailable

## ADDED Requirements

### Requirement: UITest Timeout Configuration for Resource-Intensive Operations
UITests that interact with resource-intensive features (video playback, large data loading) SHALL use appropriately extended timeouts to prevent false failures due to temporary system delays.

#### Scenario: Video playback UI interactions
- **GIVEN** a test interacting with video playback controls
- **WHEN** the UI operation involves heavy processing (speed changes, quality changes)
- **THEN** the test SHALL use timeout values at least 10-15 seconds
- **AND** the test SHALL include diagnostic logging to track actual wait times
- **AND** the test SHALL document the reason for extended timeouts in comments

#### Scenario: Main thread busy condition handling
- **GIVEN** UI operations that may cause main thread busy conditions
- **WHEN** waiting for UI elements to become interactive
- **THEN** the test SHALL not fail immediately on timeout
- **AND** the test SHALL include retry logic for transient failures (2-3 attempts)
- **AND** the test SHALL add small delays (1-2 seconds) between retries

### Requirement: UITest Environment-Specific Behavior Documentation
UITests that exhibit different behavior based on test environment conditions (time of day, system resources, CI vs local) SHALL document these variations for maintainability.

#### Scenario: CI timing considerations
- **GIVEN** tests running in CI environment with shared resources
- **WHEN** tests execute during early morning hours (05:00-06:00)
- **THEN** test implementations SHALL account for potential resource constraints
- **AND** tests SHALL use conservative timeout values suitable for resource-limited conditions
- **AND** failures during specific time windows SHALL be documented for trend analysis

#### Scenario: First-time failure investigation
- **GIVEN** a test that fails for the first time in CI history
- **WHEN** investigating the root cause
- **THEN** the test SHALL be monitored for 2-3 consecutive CI runs before permanent fixes
- **AND** the test implementation SHALL be reviewed for timing assumptions
- **AND** environmental factors (CI timing, resource usage) SHALL be considered in root cause analysis

### Requirement: Speed Control Test Maintainability
Speed control UITests SHALL be structured to clearly separate concerns (menu opening, option selection, verification) for easier debugging and maintenance.

#### Scenario: Explicit wait steps in speed control tests
- **GIVEN** a test changing playback speed
- **WHEN** implementing the test helper methods
- **THEN** the method SHALL separate button tap from menu wait
- **AND** the method SHALL separate menu wait from option selection
- **AND** the method SHALL log each step for CI diagnostic visibility
- **AND** timeout values SHALL be documented with justification comments
