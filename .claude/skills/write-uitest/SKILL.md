---
name: write-uitest
description: >
  Write UITest Command. Use when writing new UITests for iOS features, expanding
  UITest coverage, or when OpenSpec tasks require UITest implementation.
---

# Write UITest

Structured workflow for writing new UITests. Scope: create test files, update writing-resources.

## Entry Context

| Entry | Source | Has Context? |
|-------|--------|-------------|
| A | OpenSpec task (opsx:apply) | Yes: feature name, spec, testing criteria |
| B | Standalone ("help me write UITest for X") | Partial: only feature name |

Entry A: skip to Step 2 (you already have spec context).
Entry B: start at Step 1.

## Step 1: Understand Feature

1. Ask user which feature to test
2. Read `openspec/specs/{capability}/spec.md` — find "Testing Criteria" section
3. Search existing tests in `iOSCharmanderUITests/` for related patterns
4. Plan test scenarios: focus on **success path first**, add edge cases only if spec requires them

**STOP: Do NOT write tests for hypothetical edge cases.** Only test what the spec's Testing Criteria defines.

## Step 2: Find Accessibility IDs

**From code, NOT from guessing.**

1. **Check `uitest-automation/writing-resources/ui-identifiers.md` first** — IDs may already be documented
2. If not documented, search product code:
   ```
   Grep for: .accessibilityIdentifier
   Grep for: .accessibility(identifier:
   ```
3. Record the actual IDs found — never invent IDs

## Step 3: Check Writing Resources

Read ALL of these before writing any test code:

| File | What to look for |
|------|-----------------|
| `uitest-automation/writing-resources/ui-identifiers.md` | Known IDs for the feature |
| `uitest-automation/writing-resources/test-data.md` | Test accounts, devices, required data |
| `uitest-automation/writing-resources/timing-guidelines.md` | Recommended timeouts for similar operations |

## Step 4: Implement Test

### File Location

`iOSCharmanderUITests/{Feature}/{Feature}UITest.swift` — match existing directory structure.

### Test Structure

```swift
import XCTest

final class {Feature}UITest: XCTestCase, CommonOperation {
    var app: XCUIApplication!
    var currentFailureCount: Int = 0

    // MARK: - Test Data Configuration
    private let testData = "..."

    // MARK: - UI Element Identifiers
    private let someButtonId = "some_button"

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("-forUAT")
        app.launchArguments.append(name)
        app.launchEnvironment = ProcessInfo.processInfo.environment
        app.activate()
        app.launch()
    }

    override func tearDownWithError() throws {
        checkTestResult(testRun)
        app.terminate()
    }

    // MARK: - Tests
    func testFeature_Scenario_ExpectedOutcome() {
        signIn(.iOS)
        // test implementation
    }
}

// MARK: - Private func
extension {Feature}UITest {
    private func helperMethod() {
        // ...
    }
}
```

**Mandatory elements:**
- Inherit `CommonOperation` (or feature-specific protocol like `FloorPlanOperation`)
- `var currentFailureCount: Int = 0` property
- `checkTestResult(testRun)` in tearDown
- `-forUAT` and `name` in launch arguments
- Use `// MARK:` sections to organize code
- Private helpers in `extension` block

### Naming Convention

Pattern: `test{Feature}_{Scenario}_{ExpectedOutcome}()` or `test_{action}_{detail}()`

```swift
// GOOD
func testFloorPlanSearch_FilterByName_ShowsMatchingResults()
func testArchive_Create_ArchiveFile()
func test_addCamera_setName_setCity_setGroup()

// BAD - not descriptive
func testSearch()
func testDeleteCamera()
```

### Wait Strategy

**Always use `UATHelper` methods. Never use `sleep()` or raw `waitForExistence`.**

```swift
// GOOD — UATHelper methods
UATHelper.waitElementToAppear(element)                    // default 5s
UATHelper.waitElementToAppear(element, timeout: 15)       // override when needed
UATHelper.waitElementToDisappear(loadingIndicator)
UATHelper.waitElementToTap(button)
UATHelper.staticTextShouldBeAppear("Expected Text", app)
UATHelper.buttonShouldBeAppear("buttonId", app)
UATHelper.repeatUntilSuccess(
    element.tap(),
    expectation: nextScreen.exists,
    message: "Screen did not open"
)

// BAD — do not use these in new tests
sleep(1)                              // NEVER — not even in helper methods
sleep(3)                              // NEVER — find a proper wait condition
element.waitForExistence(timeout: 5)  // Use UATHelper instead
```

Only override the default timeout when `timing-guidelines.md` recommends it or you have empirical evidence the default is insufficient.

### Comment Style

Use `// MARK:` sections and step comments. Do NOT use GIVEN/WHEN/THEN.

```swift
// MARK: - Camera Selection Tests

func testFloorPlan_SelectCamera_ShowsSplitScreen() {
    signIn(.iOS)
    navigateToFloorPlanTab()

    // Step 1: Open floor plan
    openFloorPlan(named: testFloorPlanName, inSite: testSite)

    // Step 2: Select camera
    selectCamera(deviceName: testCamera)

    // Step 3: Verify split screen
    verifySplitScreenDisplayed()
}
```

### Available Operation Protocols

Choose the appropriate protocol for your test:

| Protocol | Inherits | Use for |
|----------|----------|---------|
| `CommonOperation` | — | General tests (sign-in, navigation, device) |
| `FloorPlanOperation` | `CommonOperation` | Floor plan related tests |
| `MultipleViewOperation` | `CommonOperation` | Video/multiple view tests |

Key methods from `CommonOperation`:
- `signIn(_ credential: SigninCredential)` — sign in with test account
- `switchTo(tab: VortexTab)` — switch tab bar
- `tapDevice(deviceName:groupName:isLive:)` — tap a device
- `openSideMenu(orgNameShouldBe:)` — open side menu
- `relaunch()` — relaunch app
- `screenshot(name:)` — take screenshot

### Key Enums

- `SigninCredential` — `.iOS`, `.viewer`, `.testMFASet`, `.testSSO` etc.
- `VortexTab` — `.view`, `.floorPlan`, `.archive`, `.message` etc.

## Step 5: Update Writing Resources

After implementing tests, update these files with new discoveries:

1. **`uitest-automation/writing-resources/ui-identifiers.md`** — add newly discovered IDs:
   ```markdown
   | Element | Identifier | Type | Usage |
   |---------|-----------|------|-------|
   | Search field | `floor_plan_search` | SearchField | Floor plan search input |
   ```

2. **`uitest-automation/writing-resources/test-data.md`** — add any new test data requirements

3. **`uitest-automation/writing-resources/timing-guidelines.md`** — record if default timeout was insufficient

**This step is NOT optional.** Future tests depend on accumulated knowledge.

## Step 6: Build Verification

Build the test to confirm it compiles:

```bash
xcodebuild build-for-testing \
  -scheme iOSCharmander \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max'
```

If build fails → fix until it passes. Do NOT skip.

### Quality Checklist

- [ ] Inherits correct Operation protocol (`CommonOperation` or feature-specific)
- [ ] Has `currentFailureCount` property and `checkTestResult(testRun)` in tearDown
- [ ] Uses `setUpWithError`/`tearDownWithError` with `-forUAT` launch arguments
- [ ] Test naming follows `test{Feature}_{Scenario}_{Outcome}` pattern
- [ ] Uses `UATHelper` methods for ALL waits (no `sleep`, no raw `waitForExistence`)
- [ ] Uses actual accessibility IDs from code (not guessed)
- [ ] Uses `// MARK:` sections and step comments (not GIVEN/WHEN/THEN)
- [ ] Private helpers in `extension` block
- [ ] Test data matches `test-data.md`
- [ ] writing-resources/ updated with discoveries

## Common Patterns

### Navigation
```swift
signIn(.iOS)
switchTo(tab: .floorPlan)
UATHelper.waitElementToAppear(VortexTab.floorPlan.navigationHeader(app))
```

### Search
```swift
UATHelper.tapButton(navigationSearchButtonId, app)
let searchField = app.searchFields.firstMatch
UATHelper.waitElementToAppear(searchField)
searchField.tap()
searchField.typeText("Office")

UATHelper.staticTextShouldBeAppear("Office 1F", app)
```

### State Verification with Predicate
```swift
let marker = app.otherElements["cameraMarker_IB9365-001"]
let predicate = NSPredicate(format: "value == 'selected'")
let expectation = XCTNSPredicateExpectation(predicate: predicate, object: marker)
let result = XCTWaiter().wait(for: [expectation], timeout: 10.0)
XCTAssertEqual(result, .completed)
```

### Retry Until Success
```swift
UATHelper.repeatUntilSuccess(
    app.staticTexts[floorPlanId].firstMatch.tap(),
    expectation: app.navigationBars[floorPlanName].exists,
    message: "Floor plan detail view did not open"
)
```

## Red Flags — STOP

| Rationalization | Reality |
|-----------------|---------|
| "I'll guess the accessibility ID" | Search product code. IDs must be real. |
| "Just one quick sleep(1)" | Use UATHelper. Always. Not even in helper methods. |
| "I'll hide sleep() in a helper" | sleep() is banned everywhere — test methods AND helpers. |
| "I'll add edge case tests for robustness" | Only test what spec requires. YAGNI. |
| "I know the ID naming pattern" | Check ui-identifiers.md and product code. Don't assume. |
| "I'll update writing-resources later" | Do it now. Step 5 is not optional. |
| "waitForExistence is the same thing" | Use UATHelper for consistency across all tests. |
| "I don't need an Operation protocol" | Every test class inherits one. Check which fits. |
| "setUp/tearDown is simple, I'll freestyle" | Copy the exact pattern. Launch args and checkTestResult matter. |
