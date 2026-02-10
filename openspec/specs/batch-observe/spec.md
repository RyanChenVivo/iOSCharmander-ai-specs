## ADDED Requirements

### Requirement: Observe action SHALL support batch mode

The Observe action SHALL accept multiple tests and record them in a single batch operation.

#### Scenario: Batch observe records all tests
- **WHEN** user selects "批次記錄觀察" for a group of 3 tests
- **THEN** system records all 3 tests to active.json in one operation
- **THEN** system confirms "已記錄 3 個測試的觀察"

#### Scenario: Single test maintains current behavior
- **WHEN** user observes a single test
- **THEN** system uses existing single-record flow

---

### Requirement: Batch observations SHALL share a batch ID

When recording multiple observations in batch mode, the system SHALL assign a shared batch_id for tracking.

#### Scenario: Batch ID format
- **WHEN** recording a batch observation on 2025-02-10
- **THEN** batch_id follows format "obs-YYYYMMDD-batch-NNN" (e.g., "obs-20250210-batch-001")

#### Scenario: Individual observations within batch have unique IDs
- **WHEN** batch contains 3 tests
- **THEN** each observation has unique id (e.g., "obs-20250210-001", "obs-20250210-002", "obs-20250210-003")
- **THEN** all 3 observations share the same batch_id

---

### Requirement: Batch observations SHALL use shared observation period

All observations in a batch SHALL use the same observation period (default: 2 days).

#### Scenario: Shared expiration
- **WHEN** batch observation is recorded on 2025-02-10 with default period
- **THEN** all observations in the batch have expires_at = "2025-02-12"

---

### Requirement: System SHALL handle batch observation in history check

When checking observation history, the system SHALL recognize batch-recorded observations.

#### Scenario: Recurring batch check
- **WHEN** a test was previously recorded in a batch observation
- **WHEN** the same test fails again after observation period
- **THEN** system identifies it as recurring and escalates recommendation

#### Scenario: Partial batch recurrence
- **WHEN** a batch contained tests A, B, C
- **WHEN** only test A fails again
- **THEN** system only escalates test A, not B and C
