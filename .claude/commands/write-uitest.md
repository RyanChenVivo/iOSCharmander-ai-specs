# Write UITest Command

You are helping implement a new UITest for an iOS application. Follow this structured workflow to explore the feature, discover UI elements, and write a comprehensive test.

## Context

**Main Project:** `/Users/ryanchen/code/VIVOTEK/iOSCharmander` (iOS app)
**Specs Repo:** `/Users/ryanchen/code/VIVOTEK/iOSCharmander-ai-specs` (current directory)

**Key Resources:**
- UITest conventions: `openspec/project.md` (lines 263-340)
- Writing guide: `uitest-automation/WRITING_GUIDE.md`
- UI element IDs: `uitest-automation/reference/ui-identifiers.md`
- Test data: `uitest-automation/reference/test-data.md`
- Timing patterns: `uitest-automation/knowledge/timing-guidelines.md`
- External services: `uitest-automation/knowledge/external-dependencies.md`

## Your Task

Implement a UITest following this workflow. **Track your progress using TodoWrite tool.**

### Step 1: Understand the Feature (5 min)

1. **Read the feature spec:**
   - Ask user which feature/capability to test
   - Read `openspec/specs/[capability]/spec.md` to understand requirements
   - Identify "Testing Criteria" section in spec

2. **Check existing tests:**
   - Search for related test files in `/Users/ryanchen/code/VIVOTEK/iOSCharmander/iOSCharmanderUITests/`
   - Review patterns from similar tests

3. **Plan test scenarios:**
   - For each Testing Criteria item, plan test scenarios
   - Consider success path, edge cases, error handling

### Step 2: Explore UI with Simulator (15 min)

**Use ios-simulator-mcp tools to discover UI elements:**

1. **Launch the app:**
   ```
   mcp__ios-simulator__open_simulator()
   mcp__ios-simulator__launch_app(bundle_id: "com.vivotek.vortex")
   ```

2. **Navigate to the feature:**
   - Use `ui_tap(x, y)` to tap buttons/elements
   - Use `ui_type(text)` to enter text
   - Use `ui_swipe(...)` to scroll if needed
   - Take screenshots at each step: `screenshot(output_path: "~/Downloads/step1.png")`

3. **Discover accessibility identifiers:**
   ```
   mcp__ios-simulator__ui_describe_all()
   ```
   - Look for elements with `identifier` field
   - Record element types (button, textField, cell, etc.)
   - Note element positions and hierarchy

4. **Verify element interactions:**
   - Use `ui_describe_point(x, y)` to check specific elements
   - Confirm tappable areas
   - Test text input fields

5. **Document key states:**
   - Screenshot initial state
   - Screenshot after user actions
   - Screenshot success/error states
   - Use `ui_view()` for compressed visual reference

### Step 3: Check Knowledge Base (3 min)

**Review existing resources:**

1. **Check ui-identifiers.md:**
   - See if feature already has documented IDs
   - Note what's missing

2. **Check test-data.md:**
   - Identify required test accounts
   - Check if test data exists (devices, floor plans, etc.)
   - Note what needs to be set up in UAT

3. **Check timing-guidelines.md:**
   - Find recommended timeouts for similar operations
   - Check network operation timings
   - Review external service wait times

4. **Check external-dependencies.md:**
   - If feature uses external services (SSO, APIs)
   - Note known behaviors and workarounds

### Step 4: Implement Test (20 min)

**Create test file following conventions:**

1. **File location:** `/Users/ryanchen/code/VIVOTEK/iOSCharmander/iOSCharmanderUITests/[Feature]UITest.swift`

2. **Test structure:**
   ```swift
   import XCTest

   final class [Feature]UITest: XCTestCase {
       var app: XCUIApplication!

       override func setUp() {
           super.setUp()
           continueAfterFailure = false
           app = XCUIApplication()
           app.launch()

           // Perform login or setup if needed
           UATHelper.login(app)
       }

       override func tearDown() {
           app.terminate()
           super.tearDown()
       }

       // Test methods here
       func test[Feature]_[Scenario]_[ExpectedOutcome]() {
           // GIVEN: Setup state
           // Navigate to feature

           // WHEN: Perform action
           // Use discovered accessibility IDs

           // THEN: Verify outcome
           // Assert expected state
       }
   }
   ```

3. **Follow patterns from project.md:**
   - Use `UATHelper` methods for waits (waitElementToAppear, etc.)
   - Use discovered accessibility identifiers
   - Add clear comments for GIVEN/WHEN/THEN
   - Handle loading states properly

4. **Test naming convention:**
   - Pattern: `test[Feature]_[Scenario]_[ExpectedOutcome]()`
   - Example: `testFloorPlanSearch_FilterByName_ShowsMatchingResults()`

5. **Wait strategy:**
   - Use `UATHelper.waitElementToAppear(element)` (default 10s timeout)
   - Only override timeout if empirically necessary
   - Always wait before assertions

### Step 5: Update Knowledge Base (5 min)

**Document your discoveries:**

1. **Update ui-identifiers.md:**
   - Add table entries for newly discovered IDs:
     ```markdown
     | Element | Identifier | Type | Usage |
     |---------|-----------|------|-------|
     | Feature button | `feature_button` | Button | Opens feature screen |
     ```

2. **Update test-data.md:**
   - Document test account requirements
   - Add required test devices/data
   - Note any UAT environment setup needed

3. **Update timing-guidelines.md:**
   - Record observed wait times
   - Note if default timeout was insufficient
   - Document slow operations (>10 seconds)

4. **Update external-dependencies.md (if applicable):**
   - Document external service behaviors
   - Note any quirks or workarounds
   - Record service response times

### Step 6: Verify and Document (5 min)

1. **Build the test:**
   ```bash
   cd /Users/ryanchen/code/VIVOTEK/iOSCharmander
   xcodebuild test -scheme iOSCharmander \
     -destination 'platform=iOS Simulator,name=iPhone 13 Pro Max' \
     -only-testing:iOSCharmanderUITests/[Feature]UITest
   ```

2. **Review test quality:**
   - [ ] Test follows naming convention
   - [ ] Uses UATHelper methods for waits
   - [ ] Uses documented accessibility IDs
   - [ ] Has clear GIVEN/WHEN/THEN structure
   - [ ] Handles loading states
   - [ ] Verifies success criteria from spec

3. **Update knowledge base:**
   - All discoveries documented
   - Screenshots saved for reference
   - Cross-references added

## Output Format

Provide the user with:

1. **Test Implementation Summary:**
   - Test file location
   - Test scenarios implemented
   - Key accessibility IDs used

2. **Knowledge Base Updates:**
   - List of files updated
   - New IDs discovered
   - Timing observations

3. **Build/Run Status:**
   - Whether test compiles
   - Any issues encountered
   - Next steps (if any)

4. **Screenshots Reference:**
   - Key UI states captured
   - Where screenshots are saved

## Common Patterns

### Navigation Pattern
```swift
// Switch to tab
app.tabBars.buttons["Floor Plan"].tap()

// Wait for content
let content = app.otherElements["floor_plan_view"]
UATHelper.waitElementToAppear(content)
```

### Search Pattern
```swift
// Enter search text
let searchField = app.searchFields["floor_plan_search"]
UATHelper.waitElementToAppear(searchField)
searchField.tap()
searchField.typeText("Office")

// Wait for results
let result = app.cells["floor_plan_office_1f"]
UATHelper.waitElementToAppear(result)
```

### External Service Pattern (SSO)
```swift
// Trigger SSO
app.buttons["sign_in_sso_button"].tap()

// Handle optional passkey dialog
Thread.sleep(forTimeInterval: 1.0)
if app.alerts["Sign In"].exists {
    app.buttons["Other Options"].tap()
}

// Wait for SSO page
let webView = app.webViews.firstMatch
UATHelper.waitElementToAppear(webView)
```

### State Verification Pattern
```swift
// Wait for state change
let marker = app.otherElements["cameraMarker_IB9365-001"]
let predicate = NSPredicate(format: "value == 'selected'")
let expectation = XCTNSPredicateExpectation(predicate: predicate, object: marker)
let result = XCTWaiter().wait(for: [expectation], timeout: 10.0)
XCTAssertEqual(result, .completed)
```

## Error Handling

If you encounter issues:

1. **Element not found:**
   - Run `ui_describe_all()` again to verify ID
   - Check if element is in a scroll view (may need to scroll)
   - Verify element actually exists in current state

2. **Timeout waiting for element:**
   - Check timing-guidelines.md for recommended timeout
   - Verify navigation actually occurred
   - Check for loading indicators that need to disappear first

3. **Test data missing:**
   - Check test-data.md for requirements
   - Coordinate with team to set up UAT environment
   - Document required data in test-data.md

4. **Build errors:**
   - Verify file is in correct target
   - Check for syntax errors
   - Ensure imports are correct

## Remember

- **Always use TodoWrite** to track your progress through these steps
- **Take screenshots** at key states for documentation
- **Document discoveries** - Future tests will benefit
- **Follow conventions** - Consistency makes maintenance easier
- **Ask for clarification** if spec or feature behavior is unclear

Start by asking the user which feature they want to test, then proceed through the steps systematically.
