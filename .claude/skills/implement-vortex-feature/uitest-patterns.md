# UI Testing Patterns

## Overview

**Framework**: XCUITest

**Location**: `iOSCharmanderUITests/`, `iOSCloudSightUITests`

**For writing new tests**: Use `/write-uitest` command

**Full conventions**: `openspec/project.md` lines 263-340

---

## Naming Conventions

**Test methods**: `test{Feature}_{Scenario}_{ExpectedOutcome}()`
```swift
testFloorPlanSearch_FilterByName_ShowsMatchingResults()
testSelectCameraByTappingMarker()
```

**Action methods**: `tapXxx()`, `selectXxx()`, `openXxx()`, `closeXxx()`

**Verification methods**: `verifyXxx()`

---

## Accessibility Patterns

### Identifier for Location

```swift
// In View
.accessibilityIdentifier("save_button")

// In Test
app.buttons["save_button"]
```

### Value for State Tracking

```swift
// In View
.accessibilityIdentifier("cameraMarker_\(id)")
.accessibilityValue(isSelected ? "selected" : "unselected")

// In Test - Verify state
let marker = app.otherElements["cameraMarker_IB9365-001"]
let predicate = NSPredicate(format: "value == 'selected'")
let expectation = XCTNSPredicateExpectation(predicate: predicate, object: marker)
XCTAssertEqual(XCTWaiter().wait(for: [expectation], timeout: 10.0), .completed)
```

---

## Wait Strategies

**Use UATHelper methods** (default 10s timeout):
```swift
UATHelper.waitElementToAppear(element)
UATHelper.waitElementToDisappear(element)
UATHelper.waitElementToTap(element)
```

**For state changes**:
```swift
let predicate = NSPredicate(format: "value == 'expected'")
let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
XCTWaiter().wait(for: [expectation], timeout: 10.0)
```

**Rules**:
- ✅ Use UATHelper methods first
- ✅ Always wait before assertions
- ❌ Avoid explicit `sleep()`

---

## Common Patterns

### Navigation
```swift
app.tabBars.buttons["Floor Plan"].tap()
let content = app.otherElements["floor_plan_view"]
UATHelper.waitElementToAppear(content)
```

### Search
```swift
let searchField = app.searchFields["floor_plan_search"]
UATHelper.waitElementToAppear(searchField)
searchField.tap()
searchField.typeText("Office")
```

### External Service (SSO)
```swift
app.buttons["sign_in_sso_button"].tap()

// Handle optional passkey dialog
Thread.sleep(forTimeInterval: 1.0)
if app.alerts["Sign In"].exists {
    app.buttons["Other Options"].tap()
}

let webView = app.webViews.firstMatch
UATHelper.waitElementToAppear(webView)
```

---

## Element Location

**Preferred**:
```swift
✅ app.buttons["explicit_identifier"]
✅ app.buttons.containing(NSPredicate(format: "label CONTAINS 'Save'"))
```

**Avoid**:
```swift
❌ app.buttons.firstMatch  // Too risky
❌ app.otherElements["scroll_view"]  // Wrong type, use scrollViews
```

---

## Best Practices

**Structure**:
- ✅ Use GIVEN-WHEN-THEN comments
- ✅ Check UATHelper APIs first
- ✅ Define test data as constants

**Assertions**:
- ✅ Use `XCTAssertTrue/False/Equal` with clear messages
- ❌ Never use `XCTExpectFailure` for verification

**Test Data**:
```swift
private let testFloorPlanSite = "Ungrouped Cameras"
private let testCamera1 = "IB9365-001"
```

**File Management**:
- Update Xcode project file when adding new test files
- Build project to verify no errors

---

## Test Operation Abstraction

**Create protocol-based operations**:
```swift
protocol FloorPlanOperation: CommonOperation {
    func selectFloorPlan(name: String)
    func verifyCameraSelected(deviceID: String)
}

extension FloorPlanOperation {
    func selectFloorPlan(name: String) {
        let cell = app.cells["floor_plan_\(name)"]
        UATHelper.waitElementToTap(cell)
    }
}
```

**Guidelines**:
- ✅ Reusable test actions as protocol methods
- ✅ Single-purpose operations
- ✅ Aim for <200 lines per protocol extension

---

## Quick Checklist

When writing UITests:
- [ ] Test follows naming convention
- [ ] Uses UATHelper methods for waits
- [ ] Uses explicit accessibility identifiers
- [ ] Has GIVEN-WHEN-THEN structure
- [ ] Handles loading states
- [ ] Assertions have clear messages
- [ ] Test data defined as constants
- [ ] File added to Xcode project

---

## Resources

**Knowledge Base** (in `uitest-automation/`):
- `reference/ui-identifiers.md` - Known accessibility IDs
- `reference/test-data.md` - Test accounts and data
- `knowledge/timing-guidelines.md` - Timeout recommendations
- `knowledge/external-dependencies.md` - Service behaviors

**Commands**:
- `/write-uitest` - Guided test implementation workflow
- `/analyze-uitest` - Test failure analysis
