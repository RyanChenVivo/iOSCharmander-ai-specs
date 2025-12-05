# Implementation Tasks

## 1. Fix test_changeSpeed UITest (Priority: Medium)

### 1.1 Add explicit wait for speed menu appearance
- [ ] 1.1.1 In `MultipleViewOperation.swift:switchSpeedTo()`, add wait for speed menu container to appear after tapping speed button
- [ ] 1.1.2 Use `UATHelper.waitElementToAppear()` or similar to ensure menu is fully loaded before interacting
- [ ] 1.1.3 Add timeout parameter (suggest 10 seconds for menu appearance)

### 1.2 Increase timeout for speed option selection
- [ ] 1.2.1 Modify `UATHelper.waitElementToTap(app.buttons["\(speed)x"])` to use longer timeout
- [ ] 1.2.2 Set timeout to at least 15 seconds to handle main thread busy conditions
- [ ] 1.2.3 Add diagnostic logging to track wait times for future debugging

### 1.3 Add retry logic for transient failures
- [ ] 1.3.1 Wrap speed menu interaction in retry block (2-3 attempts)
- [ ] 1.3.2 Add small delay (1-2 seconds) between retry attempts
- [ ] 1.3.3 Log retry attempts for CI diagnostics

### 1.4 Verify fix with local testing
- [ ] 1.4.1 Run `test_changeSpeed` locally 5-10 times to verify consistency
- [ ] 1.4.2 Run all `CloudPlaybackUITest` tests to ensure no regressions
- [ ] 1.4.3 Test on different simulators (iPhone 13 Pro Max matching CI environment)

### 1.5 Monitor CI results
- [ ] 1.5.1 Commit and push changes
- [ ] 1.5.2 Verify test passes in next CI run (2025-12-05)
- [ ] 1.5.3 Monitor for 3 consecutive CI runs to confirm stability
- [ ] 1.5.4 Archive this change if test passes consistently

## Proposed Code Changes

**File**: `iOSCharmanderUITests/Video/MultipleViewOperation.swift`

**Before** (lines 90-93):
```swift
func switchSpeedTo(_ speed: String) {
    UATHelper.tapEnabledButton("speedButton", app)
    UATHelper.waitElementToTap(app.buttons["\(speed)x"])
}
```

**After**:
```swift
func switchSpeedTo(_ speed: String) {
    // Tap speed button to open menu
    UATHelper.tapEnabledButton("speedButton", app)

    // Wait for speed menu to appear and stabilize
    // Note: Heavy video playback may cause main thread delays
    let speedOption = app.buttons["\(speed)x"]
    UATHelper.waitElementToAppear(speedOption, timeout: 10)

    // Tap the speed option with extended timeout for busy main thread
    UATHelper.waitElementToTap(speedOption, timeout: 15)
}
```

## Validation

- Test must pass locally 5+ times consecutively
- Test must pass in CI for 3 consecutive daily runs
- No increase in test execution time beyond 30 seconds
- No regressions in other CloudPlaybackUITest tests

## Notes

- **First-time failure**: This is the first occurrence, suggesting possible intermittent or environment-specific issue
- **CI timing**: Failure occurred during early morning run (05:00-06:00), possibly lower system resources
- **Monitoring recommended**: Track this test for patterns over next week
- **If failure persists**: Consider deeper investigation into video playback UI performance
