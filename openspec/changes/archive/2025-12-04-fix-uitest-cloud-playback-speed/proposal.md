# Fix UITest Cloud Playback Speed Test Failure (2025-12-04)

## Why

The `test_changeSpeed` UITest in `CloudPlaybackUITest` failed in the December 4, 2025 CI run with a main thread timeout error. This is the first recorded failure of this test, indicating a potential timing issue, UI responsiveness problem, or environment-specific constraint that needs investigation and resolution.

## Diagnostic Process

### Sources of Information
1. **Error text from test_failures.json**: `"Failed to get matching snapshots: Unable to perform work on main run loop, process main thread busy for 30.0s"`
2. **Failure screenshot**: Shows playback screen with speed button displaying "1x", indicating test failed before speed menu could open
3. **Test source code**: `CloudPlaybackUITest.swift:48-52` and `MultipleViewOperation.swift:90-97`
4. **CI test timing**: Failed at 05:00-06:00 AM on 2025-12-04
5. **Historical context**: First-time failure (no previous occurrences in CI history)

### Failure Analysis

#### test_changeSpeed (CloudPlaybackUITest)
- **Error message**: `Failed to get matching snapshots: Unable to perform work on main run loop, process main thread busy for 30.0s`
- **Test flow**:
  1. `openSingleChannelPlaybackPage()` - Sign in and open camera playback
  2. `switchSpeedTo("2")` - Tap speed button, then select "2x" option
  3. `speedShouldBe("2")` - Verify speed button shows "2x"
- **Failure point**: During `switchSpeedTo("2")` execution, specifically at `waitElementToTap(app.buttons["2x"])`
- **Screenshot evidence**: Playback screen showing fisheye camera with speed button at "1x", menu not yet opened
- **Root cause analysis**:
  1. **Primary**: Main thread becomes unresponsive during speed menu interaction
  2. **Possible triggers**:
     - Heavy video decoding/rendering blocking main thread
     - Speed menu UI loading is resource-intensive
     - Insufficient wait/retry logic in test implementation
     - CI environment resource constraints during test run time (early morning)
- **Severity**: Medium - Could be intermittent or environment-specific
- **Impact**: Blocks verification of critical playback speed control functionality

### Current Implementation Issues

**In `MultipleViewOperation.swift:90-93`**:
```swift
func switchSpeedTo(_ speed: String) {
    UATHelper.tapEnabledButton("speedButton", app)
    UATHelper.waitElementToTap(app.buttons["\(speed)x"])  // ⚠️ Fails here
}
```

**Problems identified**:
1. No explicit wait for speed menu to appear after tapping speed button
2. No timeout configuration for heavy UI operations
3. No retry logic for transient failures
4. Assumes immediate menu availability after button tap

## What Changes

- **Fix test_changeSpeed**: Add robust wait logic, increase timeout, and improve error handling for speed menu interactions
- **Improve MultipleViewOperation**: Add explicit wait for menu appearance before interacting with options
- **Add retry logic**: Handle transient main thread busy conditions gracefully

## Impact

- **Affected specs**: `uitests` (UI test reliability for video playback controls)
- **Affected code**:
  - `iOSCharmanderUITests/Video/CloudPlaybackUITest.swift:48-52` (test implementation)
  - `iOSCharmanderUITests/Video/MultipleViewOperation.swift:90-97` (helper method)
  - `iOSCharmanderUITests/Infrastructure/UATHelper.swift` (if timeout adjustments needed)
- **Risk**: Low - test-only changes with no production code impact
- **User impact**: None (test infrastructure only)
- **Dependencies**: None - independent test fix
- **Follow-up monitoring**: Track test for next 2-3 CI runs to verify fix stability

## Success Criteria

1. `test_changeSpeed` passes consistently in CI runs for 3 consecutive days
2. No timeout errors related to speed menu interactions
3. Test execution time remains reasonable (<30 seconds total)
4. Other speed-related tests remain unaffected
