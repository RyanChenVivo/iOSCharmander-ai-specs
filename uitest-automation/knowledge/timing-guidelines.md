# UITest Timing Guidelines

## Purpose

UITest failures are often caused by timing issues - tests run faster than the app can respond. This document provides empirically tested timeout values and wait strategies.

**Why This Matters:**
- Too short → Flaky tests that fail randomly
- Too long → Slow test suite execution
- Inconsistent → Different failures on CI vs local

## General Principles

### Use UATHelper Methods

**Always prefer UATHelper wait methods over explicit sleeps:**

```swift
// ✅ GOOD: Uses UATHelper with timeout
UATHelper.waitElementToAppear(element)  // Default: 10 seconds

// ❌ BAD: Explicit sleep
Thread.sleep(forTimeInterval: 2.0)  // Wastes time, may still fail
```

**Available UATHelper Methods:**
- `waitElementToAppear(element, timeout:)` - Wait for element to exist
- `waitElementToDisappear(element, timeout:)` - Wait for element to be removed
- `waitElementToTap(element, timeout:)` - Wait until element is tappable

### Default Timeout Values

UATHelper methods use these defaults (defined in UATHelper):

| Method | Default Timeout | Use Case |
|--------|----------------|----------|
| `waitElementToAppear()` | 10 seconds | Element appearance after navigation |
| `waitElementToDisappear()` | 10 seconds | Loading indicators, modals |
| `waitElementToTap()` | 10 seconds | Interactive elements |

**When to override:** Only when empirical testing shows the default is insufficient.

## Operation-Specific Guidelines

### Screen Transitions

| Operation | Recommended Wait | Method | Notes |
|-----------|-----------------|---------|-------|
| Tab switch | UATHelper default (10s) | `waitElementToAppear()` | Wait for new tab content |
| Modal appear | UATHelper default (10s) | `waitElementToAppear()` | Wait for modal element |
| Modal dismiss | UATHelper default (10s) | `waitElementToDisappear()` | Wait for modal to be gone |
| Navigation push | UATHelper default (10s) | `waitElementToAppear()` | Wait for navigation bar title |
| Navigation pop | UATHelper default (10s) | `waitElementToDisappear()` | Wait for previous screen |

**Example:**
```swift
// Switch to Floor Plan tab
app.tabBars.buttons["Floor Plan"].tap()

// Wait for floor plan content (uses default 10s)
let floorPlanView = app.otherElements["floor_plan_container"]
UATHelper.waitElementToAppear(floorPlanView)
```

### Network Operations

| Operation | Recommended Wait | Method | Notes |
|-----------|-----------------|---------|-------|
| API call | UATHelper default (10s) | `waitElementToAppear()` | Wait for data to load |
| Image load | UATHelper default (10s) | `waitElementToAppear()` | Wait for image element |
| Video stream | 15 seconds | Custom predicate | WebRTC connection time |
| File upload | 20 seconds | Custom predicate | Depends on file size |

**Example:**
```swift
// Wait for camera list to load after API call
let firstCamera = app.cells.element(boundBy: 0)
UATHelper.waitElementToAppear(firstCamera)
// Uses default 10s, sufficient for normal API response
```

### External Services

| Service | Recommended Wait | Method | Notes |
|---------|-----------------|---------|-------|
| Microsoft SSO page | 10 seconds | `waitElementToAppear()` | WebView loading |
| Google SSO page | 10 seconds | `waitElementToAppear()` | WebView loading |
| OAuth redirect | 15 seconds | `waitElementToAppear()` | Back to app after auth |

**Example:**
```swift
// Tap SSO button
app.buttons["sign_in_sso_button"].tap()

// Wait for Microsoft page (may take up to 10 seconds)
let webView = app.webViews.firstMatch
UATHelper.waitElementToAppear(webView)
```

**Known Issues:**
- Microsoft SSO can occasionally take 12-15 seconds (Monday mornings, backend maintenance)
- If seeing flaky failures, check external-dependencies.md for known service issues

### User Interactions

| Interaction | Recommended Wait | Method | Notes |
|-------------|-----------------|---------|-------|
| Button tap response | 1 second | `waitElementToAppear()` | Immediate UI update |
| Search input | Immediate | No wait | Real-time filtering |
| Form submission | 5 seconds | `waitElementToAppear()` | Backend validation |
| Image picker | 3 seconds | `waitElementToAppear()` | System UI appearance |

**Example:**
```swift
// Search is real-time, no wait needed
searchField.typeText("Office")
// Results filter immediately

// But wait for results to exist
let result = app.cells["floor_plan_office_1f"]
UATHelper.waitElementToAppear(result)  // May need brief time
```

### Device-Specific Operations

| Operation | Recommended Wait | Method | Notes |
|-----------|-----------------|---------|-------|
| Camera discovery | 20 seconds | Custom predicate | Network scan |
| Camera connection | 15 seconds | `waitElementToAppear()` | RTSP stream |
| PTZ control | 3 seconds | Custom predicate | Motor movement |
| Snapshot capture | 5 seconds | `waitElementToAppear()` | Image generation |

## State Verification Patterns

### Wait for State Change

Use `XCUIApplication.wait(for:timeout:)` for complex state checks:

```swift
// Wait for camera marker to become selected
let marker = app.otherElements["cameraMarker_IB9365-001"]
let predicate = NSPredicate(format: "value == 'selected'")
let expectation = XCTNSPredicateExpectation(predicate: predicate, object: marker)
let result = XCTWaiter().wait(for: [expectation], timeout: 10.0)
XCTAssertEqual(result, .completed, "Camera marker should be selected")
```

**Timeout:** Default 10 seconds for state changes.

### Loading Indicators

Always wait for loading indicators to disappear:

```swift
// Wait for loading spinner to disappear
let loadingSpinner = app.activityIndicators.firstMatch
UATHelper.waitElementToDisappear(loadingSpinner)
// Now safe to verify loaded content
```

## Common Timing Patterns

### Pattern 1: Navigate and Verify

```swift
func navigateToFloorPlan() {
    // Tap tab
    app.tabBars.buttons["Floor Plan"].tap()

    // Wait for content (default 10s)
    let floorPlanView = app.otherElements["floor_plan_view"]
    UATHelper.waitElementToAppear(floorPlanView)

    // Wait for data load (default 10s)
    let firstFloorPlan = app.cells.element(boundBy: 0)
    UATHelper.waitElementToAppear(firstFloorPlan)
}
```

### Pattern 2: Wait for Multiple Elements

```swift
// Wait for all necessary elements before proceeding
UATHelper.waitElementToAppear(element1)
UATHelper.waitElementToAppear(element2)
UATHelper.waitElementToAppear(element3)
// All elements now guaranteed to exist
```

### Pattern 3: Handle Optional Dialogs

```swift
// Microsoft may show passkey dialog
app.buttons["sign_in_sso_button"].tap()

// Wait a moment for dialog to appear if it will
Thread.sleep(forTimeInterval: 1.0)  // Brief wait for dialog

// Handle dialog if present
if app.alerts["Sign In"].exists {
    app.buttons["Other Options"].tap()
}

// Continue with main flow
```

**Note:** This is one of few acceptable uses of `sleep()` - giving optional UI time to appear.

## Flaky Test Detection

If a test fails intermittently, likely causes:

### Timing Too Short

**Symptom:** "Element not found" errors that succeed on retry

**Fix:** Increase timeout or verify element actually exists
```swift
// Before:
element.tap()  // Fails if element not ready

// After:
UATHelper.waitElementToTap(element)
element.tap()
```

### Race Conditions

**Symptom:** Test sometimes passes, sometimes fails

**Fix:** Add explicit wait for expected state
```swift
// Ensure loading finished before checking data
UATHelper.waitElementToDisappear(loadingIndicator)
XCTAssertTrue(dataElement.exists)
```

### External Service Delays

**Symptom:** Failures on certain days/times (Monday mornings, etc.)

**Fix:** Check external-dependencies.md and increase timeout if needed

## Test Suite Performance

### Optimization Guidelines:

**DO:**
- ✅ Use appropriate timeouts (don't always max out)
- ✅ Verify elements exist before interacting
- ✅ Use UATHelper methods (they're optimized)

**DON'T:**
- ❌ Add `sleep()` everywhere "to be safe"
- ❌ Use excessive timeouts (60+ seconds)
- ❌ Poll in loops instead of using UATHelper

### Typical Test Durations:

| Test Type | Expected Duration | Threshold |
|-----------|------------------|-----------|
| Simple interaction | 5-10 seconds | < 15 seconds |
| API data fetch | 10-20 seconds | < 30 seconds |
| External auth (SSO) | 15-30 seconds | < 45 seconds |
| Full user flow | 30-60 seconds | < 90 seconds |

If tests exceed thresholds, investigate why.

## Troubleshooting

### Test Timeout on CI but Passes Locally

**Possible Causes:**
1. CI machine slower than dev machine
2. CI network slower
3. CI running multiple tests in parallel (resource contention)

**Solution:**
- Increase timeout slightly (10s → 15s)
- Check CI machine load during test run
- Consider if test can be optimized

### Intermittent Failures on Specific Operations

**Document Here:**

| Operation | Normal Time | Max Observed | Notes |
|-----------|------------|--------------|-------|
| Microsoft SSO | 5-8 seconds | 15 seconds | Slow on Monday mornings |
| Camera discovery | 10-15 seconds | 25 seconds | Network scan varies |
| [Add as discovered] | | | |

## Maintenance

### When to Update:

**Add new timing guideline:**
- New feature tested
- New external service integrated
- New operation pattern discovered

**Adjust existing guideline:**
- Consistent timeout failures
- External service behavior changed
- App performance improved/degraded

### Review Process:

**Monthly:** Review flaky test reports
- Identify timing-related failures
- Update guidelines based on data

**After Major Changes:**
- Backend API changes → Review network operation times
- External service updates → Review SSO/auth times
- App performance work → Review interaction times

## Future Work

Timing data to collect:

- [ ] Message loading times
- [ ] Archive video streaming times
- [ ] NVR connection times
- [ ] Organization switching times
- [ ] License validation times

## Reference

For more timing strategies, see:
- `openspec/project.md` - UI Test Implementation Rules (lines 293-299)
- `UATHelper.swift` - Helper method implementations
- `external-dependencies.md` - Known slow external services
