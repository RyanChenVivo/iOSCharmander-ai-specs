# Fix Downgrade Threading Crash (2025-12-10)

## Why

The UITest `OrganizationPlanUITest/test_cantDowngrade_activeLicenseExists()` failed in the December 10, 2025 CI run with error "License expired! StaticText is not exist". Manual testing revealed this was not a simple UI timing issue, but an actual **APP crash** caused by threading violations when dismissing views from background threads.

**Critical Discovery**: When UITests fail with "element not found" errors but without clear screenshots or diagnostic information, it may indicate the app crashed rather than just a UI timing problem. Manual testing in simulator is essential to distinguish between:
- UI timing/flakiness (test framework issue)
- App crashes (production code bug)

## Diagnostic Process

### Initial Analysis (Misleading)

From CI test data alone:
- **Error message**: `failed - "License expired!" StaticText is not exist`
- **Test duration**: 55 seconds (completed normally)
- **No crash logs**: No .crash or .ips files in attachments
- **Similar tests passing**: `test_downgrade()` and `testLicenseGracePeriod()` both passed
- **Initial conclusion**: Appeared to be transient UI timing issue

### Manual Testing Revealed True Root Cause

Running the test manually in Xcode revealed:
```
Task 2648: "Modifications to the layout engine must not be performed
from a background thread after it has been accessed from the main thread."
```

**Crash location**: `DowngradeProgressViewModel.swift:75` (not the test code)

**Root cause**: `dismissAction()` (SwiftUI's `dismiss()`) was called from a background thread within alert completion handlers.

### Why CI Didn't Show the Crash

1. **UITest isolation**: UITests run in separate process; app crashes don't always propagate as "crash" signals
2. **Graceful degradation**: SwiftUI sometimes recovers from threading violations, leaving UI in broken state
3. **Test continues**: UITest framework kept waiting for UI elements, timing out naturally
4. **No crash report**: Minor threading violations may not generate .crash files

## What Changes

- **Fix `DowngradeProgressViewModel.handleError()`**: Wrap all `dismissAction()` calls with `MainActor.run` to ensure UI modifications happen on main thread
- **Update UITest triage documentation**: Add guidance for detecting crashes hidden behind "element not found" errors

## Impact

### Affected Code
- `iOSCharmander/View/Home/Downgrade/DowngradeProgressViewModel.swift:71-92`
  - Line 75-77: `downgradeLicenseExists` error handler
  - Line 87-89: Default error cancel action

### Affected Scenarios
All scenarios where users attempt to downgrade to xLite plan but fail:
1. **Downgrade with active licenses** (most common) - Triggers `VortexError.downgradeLicenseExists`
2. **Downgrade with general errors** - Triggers default error handler's cancel action

### User Impact
**HIGH** - This is a production bug affecting real users:
- When user has active licenses and tries to downgrade
- After seeing "Failed to proceed" alert
- Tapping "OK" causes app to crash
- User cannot return to previous screen
- Must force-quit and restart app

### Risk
**LOW** - Fix is minimal and safe:
- Only wraps existing calls with `MainActor.run`
- No logic changes
- Cannot introduce new bugs

## Important Lessons for UITest Triage

### When "Element Not Found" May Mean "App Crashed"

**Warning signs**:
1. Test reports "element not found" or timeout
2. No clear screenshots showing the missing element
3. Test duration seems normal (not immediately terminated)
4. No .crash files in CI attachments
5. Similar tests pass, isolating the failure to specific flow

**Recommended action**:
```
DO NOT assume it's a timing issue or transient failure.
RUN THE TEST MANUALLY in Xcode simulator to check for crashes.
```

### Manual Testing Protocol

When suspicious UITest failure occurs:
1. Open test class in Xcode
2. Run single test in simulator
3. Watch Xcode console for threading errors, crashes, or exceptions
4. If crash occurs: **Create OpenSpec proposal immediately** (it's a production bug, not test flakiness)
5. If no crash: Continue with standard triage (timing, environment, etc.)

### Update Triage Workflow

The triage workflow in `uitest-automation/README.md` should be updated to include:
- Section on "Crash Detection" before deciding to "observe tomorrow"
- Explicit step to run test manually when suspicious
- Examples of "element not found" that were actually crashes
