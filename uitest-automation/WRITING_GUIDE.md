# UITest Writing Guide

## Purpose

This guide provides workflows and best practices for writing new UITests for the iOS Charmander app. It serves as a comprehensive reference for both AI assistants and developers implementing test automation.

## Target Audience

- **AI Assistants:** Primary consumers for automated test development
- **Developers:** Reference for understanding test patterns and conventions

---

## Writing New UITests Workflow

**When:** Implementing UITests for new features or expanding test coverage

### Step 1: Explore Feature (5-10 min)

1. **Understand requirements:**
   - Read `openspec/specs/{capability}/spec.md` for feature requirements
   - Identify "Testing Criteria" section

2. **Check existing tests:**
   - Search for related tests in `/Users/ryanchen/code/VIVOTEK/iOSCharmander/iOSCharmanderUITests/`
   - Review patterns from similar tests

3. **Plan test scenarios:**
   - For each Testing Criteria item, plan test scenarios
   - Consider success path, edge cases, error handling

### Step 2: Use iOS Simulator MCP for Discovery (15 min)

Use `ios-simulator-mcp` tools to discover UI elements:

**Discovery Phase:**
1. Launch app: `mcp__ios-simulator__launch_app(bundle_id: "com.vivotek.vortex")`
2. Navigate to feature: Use `ui_tap(x, y)`, `ui_type(text)`, `ui_swipe(...)`
3. Discover elements: `ui_describe_all()` - Lists all accessible UI elements with IDs
4. Screenshot states: `screenshot(output_path: "~/Downloads/step1.png")`
5. Verify interactions: `ui_describe_point(x, y)` - Check specific elements

**Discovery Pattern:**
1. Navigate to feature using simulator-mcp
2. Use `ui_describe_all()` to discover accessibility IDs
3. Screenshot key states
4. Record findings in `reference/ui-identifiers.md`
5. Implement test using discovered IDs

### Step 3: Check Knowledge Base (3 min)

Before writing tests, review existing resources:

**Check reference/ (test implementation resources):**
- `reference/ui-identifiers.md` - See if feature already has documented IDs
- `reference/test-data.md` - Identify required test accounts, devices, floor plans

**Check knowledge/ (diagnostic resources):**
- `knowledge/timing-guidelines.md` - Find recommended timeouts for similar operations
- `knowledge/external-dependencies.md` - If feature uses external services (SSO, APIs)

### Step 4: Implement Test (20 min)

**File location:** `/Users/ryanchen/code/VIVOTEK/iOSCharmander/iOSCharmanderUITests/{Feature}UITest.swift`

**Test structure:**
```swift
import XCTest

final class {Feature}UITest: XCTestCase {
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
    func test{Feature}_{Scenario}_{ExpectedOutcome}() {
        // GIVEN: Setup state
        // Navigate to feature

        // WHEN: Perform action
        // Use discovered accessibility IDs

        // THEN: Verify outcome
        // Assert expected state
    }
}
```

**Follow project conventions:**
- Use `UATHelper` methods for waits (`waitElementToAppear`, etc.)
- Use discovered accessibility identifiers
- Add clear comments for GIVEN/WHEN/THEN
- Handle loading states properly

**Test naming convention:**
- Pattern: `test{Feature}_{Scenario}_{ExpectedOutcome}()`
- Example: `testFloorPlanSearch_FilterByName_ShowsMatchingResults()`

**Wait strategy:**
- Use `UATHelper.waitElementToAppear(element)` (default 10s timeout)
- Only override timeout if empirically necessary
- Always wait before assertions

### Step 5: Update Knowledge Base (5 min)

Document your discoveries for future tests:

**Update reference/ui-identifiers.md:**
```markdown
| Element | Identifier | Type | Usage |
|---------|-----------|------|-------|
| Feature button | `feature_button` | Button | Opens feature screen |
```

**Update reference/test-data.md:**
- Document test account requirements
- Add required test devices/data
- Note any UAT environment setup needed

**Update knowledge/timing-guidelines.md (if needed):**
- Record observed wait times
- Note if default timeout was insufficient
- Document slow operations (>10 seconds)

**Update knowledge/external-dependencies.md (if applicable):**
- Document external service behaviors
- Note any quirks or workarounds
- Record service response times

---

## Knowledge Base and Reference

### reference/ - Test Implementation Use

For writing new tests:

| File | Contains | Used For |
|------|----------|----------|
| `ui-identifiers.md` | Accessibility IDs of UI elements | Writing tests, locating elements |
| `test-data.md` | Test accounts, devices, floor plans | Setting up test prerequisites |

### knowledge/ - Diagnostic Reference

For understanding test requirements:

| File | Contains | Used For |
|------|----------|----------|
| `external-dependencies.md` | External service behaviors | Understanding service dependencies |
| `timing-guidelines.md` | Wait times and timeouts | Setting appropriate timeouts |

**Why Separate?**

**`openspec/project.md`** provides **principles and patterns** (how to write tests, naming conventions, architecture)

**`reference/`** provides **concrete data** (what IDs exist, what data is available)

This separation allows:
- Project conventions to remain stable
- Environment-specific data to be updated independently
- Easy discovery of available test resources
- Knowledge accumulation from simulator exploration

---

## Best Practices

### For Writing Tests

1. **Always check reference/ first** - Avoid duplicating discovery work
2. **Use simulator-mcp** - Verify IDs exist before writing tests
3. **Document discoveries** - Update reference/ when you find new IDs
4. **Follow project.md** - Maintain consistency with established patterns

### For Maintaining Knowledge Base

1. **Keep reference/ current** - Update when UAT environment changes
2. **Remove outdated info** - Clean up obsolete IDs or test data
3. **Add context** - Explain why certain timeouts or patterns exist
4. **Cross-reference** - Link to related OpenSpec changes when relevant

---

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

---

## Integration with OpenSpec

UITest implementation is part of the OpenSpec workflow:

### During Feature Development

```
openspec/changes/{feature}/
├─ proposal.md
├─ specs/{feature}/spec.md  (includes Testing Criteria)
└─ tasks.md  (includes UITest implementation tasks)
```

### Development Flow

1. Feature Development
   - OpenSpec proposal includes Testing Criteria
   - Tasks include UITest implementation

2. UITest Implementation
   - Use ios-simulator-mcp to explore feature
   - Check reference/ for available resources
   - Implement test following openspec/project.md patterns
   - Update reference/ with discoveries

3. CI Testing
   - Tests run automatically on push
   - Use `/analyze-uitest` for failure analysis

---

## Related Commands

- **`/write-uitest`** - Guided test implementation workflow
- **`/analyze-uitest`** - Analyze test failures from CI

---

## Related Documentation

- **`openspec/project.md`** (lines 263-340) - UITest conventions and patterns
- **`UITEST_AGENT.md`** - UITest failure analysis workflows
- **`README.md`** - Quick start and usage guide
- **`SETUP.md`** - Environment setup instructions

---

**For test failure analysis, see:** `UITEST_AGENT.md` and use `/analyze-uitest` command.
