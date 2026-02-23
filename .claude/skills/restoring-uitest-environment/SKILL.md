---
name: restoring-uitest-environment
description: Use when UITest failures need environment cleanup (organization data, MFA settings, test devices). Triggers on residual test data, polluted state, or when analyzing-uitest-failures recommends restore.
---

# Restoring UITest Environment

## Overview

Automate UITest environment restoration using configuration-driven RestoreUITest execution. Core principle: All restore actions centralized in RestoreUITest, driven by restore-config.yaml.

## When to Use

Use when:
- UITest failure caused by environment pollution (residual organization, device, MFA data)
- `analyzing-uitest-failures` recommends "Restore" action
- Need to clean up test account state before re-running tests
- Test error messages mention "not empty", "already exists", "unexpected state"

Do NOT use when:
- Test failure is code-related bug
- Need to restart external services (servers, databases)
- Production environment issues

## Core Pattern

**WRONG approach** (what agents do without this skill):
```
❌ Create CleanupNewToVortexUITest.swift for each test
❌ Write custom bash scripts for cleanup
❌ Manually assemble xcodebuild commands
❌ Create documentation files for procedures
```

**RIGHT approach** (this skill):
```
✅ Query restore-config.yaml for existing action
✅ Use centralized RestoreUITest with test methods
✅ Standard execution format with environment variables
✅ Interactive flow for missing configurations
```

## Implementation Flow

### Step 0: Environment Preparation

**CRITICAL**: Always prepare simulator environment BEFORE executing tests.

#### 0.1 Start Simulator

Use `mcp__ios-simulator__open_simulator` to launch Simulator.app:
- If already open, this will bring it to foreground
- Wait 5 seconds for startup

#### 0.2 Read Simulator Preferences

From `restore-config.yaml`, read `simulator_preferences`:
```yaml
simulator_preferences:
  ios_version: "26.0"           # Preferred iOS version
  device_pattern: "iPhone 17"   # Device name pattern (regex)
  fallback_device: "iPhone 16 Pro"  # Fallback if not found
```

#### 0.3 Query and Select Simulator

Execute `xcrun simctl list devices available --json` to get available devices.

**Selection strategy** (try in order):
1. Device matching `iOS ${ios_version}` + name contains `${device_pattern}`
2. Any iOS version device with name containing `${device_pattern}`
3. Device matching `${fallback_device}`
4. If none found → List all available devices and report error

#### 0.4 Boot Selected Simulator

If selected device is not booted:
```bash
xcrun simctl boot "<device_name>"
```

Wait 3 seconds for device to fully boot.

#### 0.5 Get UDID

Use `mcp__ios-simulator__get_booted_sim_id` to get the UDID of booted simulator.

#### 0.6 Verify

Confirm UDID obtained successfully. If not, report error with available devices.

### Step 1: Query Configuration

**CRITICAL**: Always query configuration BEFORE taking action.

```
1. Check test_overrides[full test name]
   ├─ Found → Use that config
   └─ Not found → Continue

2. Check file_defaults[test file name]
   ├─ Found → Use that config
   └─ Not found → Interactive mode

3. Interactive mode
   └─ List existing actions → User selects or adds new
```

Configuration file: `references/restore-config.yaml` (relative to this skill directory)

### Step 2: Identify Test Credential

**Automatic resolution flow**:

```
1. Check config file (test_overrides or file_defaults credential field)
   ├─ Found → Use that credential
   └─ Not found → Continue

2. Parse test code for signIn(.xxx)
   ├─ Found → Ask user to confirm
   └─ Not found → Continue

3. Ask user directly
   "Which account does this test use?
   A) iOS (benson.vivotek+iosuatadmin@gmail.com)
   B) newToVORTEX (Themy1928@rhyta.com)
   C) testMFASet (checkmfasetter@duckdocks.com)
   ..."

4. After identifying, ask: "Record this to config file? (Y/n)"
```

**Code parsing pattern**:
```typescript
// Read test file, find test method, extract signIn(.xxx)
const pattern = /signIn\(\.(\w+)\)/
```

### Step 3: Execute Restore

**Standard execution format**:

```bash
RESTORE_ENABLED=true \
RESTORE_CREDENTIAL={credential} \
xcodebuild test \
  -scheme iOSCharmander \
  -destination 'platform=iOS Simulator,id={UDID}' \
  -only-testing:iOSCharmanderUITests/RestoreUITest/test_restore_{action}
```

**Key points**:
- RESTORE_ENABLED=true: Required to bypass XCTSkipIf
- RESTORE_CREDENTIAL: Specifies which test account to use
- -destination: Use UDID from Step 0 (NOT hardcoded device name)
- -only-testing: Targets specific restore action

**IMPORTANT**: Always use `id={UDID}` obtained from Step 0, never hardcode device names like "iPhone 16 Pro Max".

### Step 4: Verify and Report

After execution:
1. Check xcodebuild exit code
2. Verify restore completed successfully
3. Return result summary

## Adding New Restore Actions

When existing actions don't match the need, follow interactive flow:

### Questions to Ask (in order):

1. **Action name**
   ```
   "What should this restore action be called? (e.g., resetLicensePhase)"
   ```

2. **Description**
   ```
   "Describe what this restore does"
   ```

3. **Execution type**
   ```
   "Can this be automated?
   A) Automatic - Has existing UATHelper method
   B) Manual - Requires UI interaction or external steps"
   ```

4. **UATHelper method** (if automatic)
   ```
   "Which UATHelper method? (e.g., UATHelper.changeLicensePhase)"
   ```

5. **Related tests**
   ```
   "Which other tests need this restore? (optional, comma-separated)"
   ```

6. **Confirmation**
   ```
   "About to add restore action:
   Name: resetLicensePhase
   Description: Reset license to default state
   Method: RestoreUITest/test_restore_resetLicensePhase
   Related: LicenseUITest.test_checkNotice, LicenseUITest.test_checkGracePeriod

   Confirm? (Y/n)"
   ```

### Implementation Steps

After confirmation:

1. **Update restore-config.yaml**
   ```yaml
   restore_actions:
     resetLicensePhase:  # New action
       description: Reset license to default state
       test_method: RestoreUITest/test_restore_resetLicensePhase
       execution_type: uitest
   ```

2. **Update RestoreUITest.swift**
   Add new test method:
   ```swift
   func test_restore_resetLicensePhase() {
       UATHelper.changeLicensePhase(app)
   }
   ```

3. **Update config for related tests**
   ```yaml
   file_defaults:
     LicenseUITest:
       actions: [resetLicensePhase]
       credential: iOS
   ```

4. **Verify**
   Run the new restore action to ensure it works

## Configuration Reference

### restore-config.yaml Structure

```yaml
# Available restore actions (building blocks)
restore_actions:
  deleteOrganization:
    description: Delete all organizations from test account
    test_method: RestoreUITest/test_restore_deleteOrganization
    execution_type: uitest

  resetMFA:
    description: Reset MFA settings
    test_method: RestoreUITest/test_restore_resetMFA
    execution_type: uitest

# Default restore for test files
file_defaults:
  SigninUITest:
    actions: [deleteOrganization]
    credential: iOS

  MFAUITest:
    actions: [resetMFA, deleteOrganization]
    credential: testMFASet

# Special test overrides
test_overrides:
  "SigninUITest.test_newToVortex":
    actions: [deleteOrganization]
    credential: newToVORTEX
```

## RestoreUITest Structure

Location: `iOSCharmanderUITests/Restore/RestoreUITest.swift`

**Key components**:

```swift
final class RestoreUITest: XCTestCase, CommonOperation {
    override func setUpWithError() throws {
        // Skip unless explicitly enabled
        let shouldRestore = ProcessInfo.processInfo.environment["RESTORE_ENABLED"] == "true"
        try XCTSkipIf(!shouldRestore, "Restore tests are manual only")

        // Sign in with specified credential
        let credentialName = ProcessInfo.processInfo.environment["RESTORE_CREDENTIAL"] ?? "iOS"
        let credential = parseCredential(credentialName)
        signIn(credential)
    }

    // Each restore action is a test method
    func test_restore_deleteOrganization() {
        UATHelper.deleteTestOrganization(app)
    }

    func test_restore_resetMFA() {
        UATHelper.disableUserMFA(app)
    }
}
```

## Common Mistakes

### ❌ Skipping Environment Preparation

**Wrong**:
```bash
# Directly execute xcodebuild without checking simulator
RESTORE_ENABLED=true RESTORE_CREDENTIAL=iOS \
xcodebuild test -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' ...
```

**Right**:
```
1. Open simulator (mcp__ios-simulator__open_simulator)
2. Read simulator preferences from config
3. Query available devices
4. Select and boot appropriate device
5. Get UDID
6. Execute xcodebuild with -destination 'id={UDID}'
```

**Why it matters**: Hardcoded device names fail when device doesn't exist. Skipping environment prep causes "Unable to boot simulator" errors.

### ❌ Creating Separate Cleanup Test for Each Case

**Wrong**:
```swift
// CleanupNewToVortexUITest.swift
// CleanupMFAUITest.swift
// CleanupDeviceUITest.swift
```

**Right**:
```swift
// RestoreUITest.swift with multiple test methods
func test_restore_deleteOrganization() { ... }
func test_restore_resetMFA() { ... }
func test_restore_deleteDevices() { ... }
```

### ❌ Not Checking Configuration First

**Wrong**:
```
User: "SigninUITest.test_newToVortex needs restore"
Agent: [Creates new cleanup solution]
```

**Right**:
```
Agent: [Reads restore-config.yaml]
Found: test_overrides["SigninUITest.test_newToVortex"]
Using: actions=[deleteOrganization], credential=newToVORTEX
```

### ❌ Proposing Without Executing

**Wrong**:
```
"I suggest updating restore-config.yaml with..."
"We should create a new test method..."
"The workflow would be..."
```

**Right**:
```
[Actually updates restore-config.yaml]
[Actually adds test method to RestoreUITest.swift]
[Actually runs xcodebuild test to verify]
"✅ Added new restore action and verified it works"
```

### ❌ Assuming Credential Without Confirmation

**Wrong**:
```
[Analyzes code]
"This test uses .iOS credential"
[Executes restore with iOS]
```

**Right**:
```
[Parses code, finds signIn(.iOS)]
"Auto-detected credential: iOS (benson.vivotek+iosuatadmin@gmail.com)"
"Confirm using this account? (Y/n)"
[Waits for confirmation]
```

### ❌ Not Recording Identified Information

**Wrong**:
```
[Figures out test uses newToVORTEX credential]
[Runs restore]
[Done - information lost]
```

**Right**:
```
[Figures out test uses newToVORTEX credential]
[Runs restore]
"Record this credential to config file? (Y/n)"
[Updates restore-config.yaml if confirmed]
```

## Red Flags - STOP

If you catch yourself doing any of these, STOP and follow this skill:

- Skipping Step 0 (Environment Preparation)
- Executing xcodebuild without checking simulator status
- Hardcoding device names like "iPhone 16 Pro Max"
- Creating a new cleanup test file
- Writing a bash script for restore operations
- Manually assembling xcodebuild commands each time
- Proposing solutions without executing them
- Skipping configuration file checks
- Not asking for confirmation on auto-detected values
- Assuming "this test is special, doesn't fit the pattern"
- Assuming "simulator will auto-start, no need to prepare"

**All of these mean**: Use the configuration-driven flow defined in this skill, starting with Step 0.

## Real-World Impact

**Before this skill**:
- Agent creates CleanupNewToVortexUITest.swift + bash script + 2 docs = 4 files
- Each restore case requires new analysis
- No accumulated knowledge across restores
- Inconsistent execution patterns

**After this skill**:
- One RestoreUITest.swift with multiple test methods
- One restore-config.yaml for all configurations
- Automatic resolution using past decisions
- Standard execution format every time

**Time savings**: ~15 minutes per restore case (no re-analysis, immediate execution)
