# Known Failure Patterns

Record known failure patterns to improve triage decision consistency.

## Quick Reference

| Pattern ID | Primary Trigger | Action | Auto-Resolve? |
|------------|-----------------|--------|---------------|
| network-timeout | "timeout", "network error" | Observe | Usually yes |
| sso-new-dialog | SSO test + element not found | Investigate | No |
| credential-expired | "401", "unauthorized" | Restore | No |
| sso-microsoft-blocking | 100% SSO failure rate | Investigate | No |
| uat-cleanup-failure | UATButton execute failed | Restore | No |
| environment-state-residual | Setup stage unexpected state | Restore | No |
| timing-element-not-ready | Quick failure + no UI changes | Observe | Usually yes |
| message-user-feedback | UserFeedback button disabled | Observe | Usually yes |
| tab-label-mismatch | 100% class failure + "No matches" at navigation | Fix | No |
| opacity-hidden-element | waitElementToDisappear timeout + element visually gone | Fix | No |
| sso-ios26-passkey-system-sheet | SSO test + max iterations + iOS 26 | Fix | No |

---

## network-timeout

**Trigger Conditions:**
- Error message contains "timeout" or "network error"
- Test duration abnormally long (>60 seconds for simple operations)

**Recommended Action:** Observe

**Reason:** Network issues are usually transient. Observe 1-2 days to see if recurring.

**Historical Cases:**
- Generally recovers automatically within 24 hours
- If persists beyond observation period, check network infrastructure

---

## sso-new-dialog

**Trigger Conditions:**
- Test name matches `.*SSO.*` or `.*SignIn.*`
- Error contains "element not found" or timeout on SSO flow
- URL contains `login.microsoftonline.com` or `login.live.com`

**Recommended Action:** Investigate

**Reason:** Microsoft frequently updates SSO UI. Need screenshots to identify specific change.

**Historical Cases:**
- 2025-12-03: Native passkey dialog appeared in simulator
  - Fix: Added `handlePasskeyDialogIfNeeded()`
  - Archive: `openspec/changes/archive/fix-uitest-failures-2025-12-03/`
- 2025-12-15: Web-based passkey setup page introduced
  - Fix: Added `handlePasskeyWebPageIfNeeded()`
  - Archive: `openspec/changes/archive/2025-12-15-fix-uitest-sso-passkey-handling/`
- 2025-12-19: Passwordless auth flow changed to "Get a code to sign in"
  - Fix: Added bypass for passwordless default
  - Archive: `openspec/changes/fix-sso-passwordless-auth-flow-2025-12-19/`
- 2026-03-17: iOS 26 system-level passkey manager sheet blocks SSO flow
  - Fix: Added `passkeyManagerSystemSheet` with springboard detection/dismissal
  - Archive: `openspec/changes/archive/2026-03-17-fix-sso-ios26-passkey-manager-sheet/`

**Notes:**
- Microsoft changes are typically permanent and require code fix
- Always download screenshots to identify the specific UI change

---

## credential-expired

**Trigger Conditions:**
- Error contains "401", "unauthorized", "credential", or "auth"
- Auth-related tests failing systematically
- Multiple tests using same account fail at login

**Recommended Action:** Restore Environment

**Reason:** Test account credentials may have expired or been locked.

**Historical Cases:**
- Test account password expiration (manual credential refresh needed)
- Account locked due to too many failed attempts

---

## sso-microsoft-blocking

**Trigger Conditions:**
- All SSO tests fail simultaneously (100% failure rate)
- Error: "Stay signed in?" not exist
- Screenshot shows Microsoft security/blocking page

**Recommended Action:** Investigate (then Report if confirmed)

**Reason:** External service blocking won't self-resolve. Need screenshots to confirm, then may need IT intervention.

**Historical Cases:**
- 2025-12-10 to 2025-12-12: Microsoft blocked CI IP, required IT assistance

**Notes:**
- Non-programmable: Cannot bypass security blocking with code
- Requires human intervention (IT/Azure admin)

---

## uat-cleanup-failure

**Trigger Conditions:**
- Error contains `⚠️UATButton: [button_id] execute action failed`
- Common button IDs: `uatDeleteOrgNUMButton`, `uatDeleteTestCameraButton`
- Occurs at end of test (cleanup/teardown stage)

**Recommended Action:** Restore Environment

**Reason:** Test logic likely passed, only cleanup failed. May cause downstream test failures.

**Historical Cases:**
- 2025-12-15: newToVORTEX account had residual organization data

**Notes:**
- Check for downstream failures (Pattern: environment-state-residual)
- Manual cleanup: Login to UAT and delete test data

---

## environment-state-residual

**Trigger Conditions:**
- Multiple tests using same account fail at setup stage
- Error indicates unexpected initial state:
  - `"illustration_users" Image is not exist`
  - `"Email already exists"`
- Previous test(s) may have uat-cleanup-failure

**Recommended Action:** Restore Environment

**Reason:** Environment not clean from previous test run. NOT a code bug.

**Historical Cases:**
- 2025-12-15: newToVORTEX account had residual organization causing setup failures

---

## timing-element-not-ready

**Trigger Conditions:**
- Error: "element not found" but no UI changes in recent commits
- Test duration shorter than expected (failed quickly)
- Same test passes on retry without code changes
- Failures cluster on Monday mornings or CI heavy load periods
- Error occurs right after screen navigation or data loading

**Recommended Action:** Observe

**Reason:** Element may not be ready when test tries to interact. Often caused by:
- CI machine slower than local environment
- Backend response slower than usual (Monday mornings)
- Network latency variations
- Resource contention during parallel test runs

**Historical Cases:**
- Typically self-resolves within 24 hours
- If recurring 3+ times, may need timeout adjustment in test code

**Notes:**
- Check if error occurs at navigation/loading boundaries
- Compare test duration with normal runs
- If persists, escalate to Fix (add proper wait or increase timeout)

---

## message-user-feedback

**Trigger Conditions:**
- Test name matches `MessageUITests.*UserFeedback.*`
- Error: "sendUserFeedbackButton" Button is not enabled

**Recommended Action:** Observe

**Reason:** May be backend timing issue. VCA message data not loaded in time. More likely on Monday mornings.

**Historical Cases:**
- 2025-12-10: 4 tests failed, recovered next day

**Notes:**
- If recurring, escalate to Investigate
- Check if UAT backend is slow (Monday morning pattern)

---

## tab-label-mismatch

**Trigger Conditions:**
- Error: `No matches found for Elements matching predicate '"X" IN identifiers'`
- 100% failure rate for all tests in a specific test class
- All failures at the same navigation step (e.g., `switchTo(tab:)`)
- Available elements list shows a **similar but different** label (e.g., "Floor Plan" vs "Floorplans")

**Recommended Action:** Fix

**Reason:** Production code changed a UI element's label/identifier (often via localization key change), but test code was not updated to match. Or a previous test fix over-corrected by changing all references without verifying each one's actual source.

**Diagnosis Steps:**
1. Compare the expected identifier in test code with the actual label in the error's element list
2. Check `git log` for recent commits that modified the relevant View or localization keys
3. Verify that `VortexTab.tabButton` (More menu label) and `VortexTab.navigationHeader` may come from **different** localization sources:
   - `tabButton` label → `HomeViewTab+Extension.swift` → localized key (e.g., `"Floor_plan"`)
   - `navigationHeader` → the View's `.vortexPrimaryNavigation(navigationTitle:)` → different localized key (e.g., `"Floorplans"`)

**Historical Cases:**
- 2026-03-11: `FloorPlanTabView` navigation title changed from `"Floor_plan"` to `"Floorplans"` (commit `d270e40d8`), but `HomeViewTab+Extension` still used `"Floor_plan"` key. A fix attempt (`adeb6e873`) changed all 3 VortexTab references to `"Floorplans"`, but `tabButton` should have stayed as `"Floor Plan"`.
  - Root cause: Two different localization keys feeding different UI elements
  - Fix: `tabButton` → `"Floor Plan"`, `navigationHeader` → `"NavigationHeaderView_Floorplans"`

**Notes:**
- When fixing identifier mismatches, always trace **each** reference back to its actual production code source — don't blindly change all references to the same value
- `VortexTab` has 3 properties (`desc`, `tabButton`, `navigationHeader`) that may each correspond to different production code sources

---

## opacity-hidden-element

**Trigger Conditions:**
- Error at `UATHelper.otherShouldBeDisappear` or `waitElementToDisappear` (line 67)
- Test duration ~60-80 seconds (timeout waiting for element to not exist)
- Screenshot shows the element is visually NOT displayed, but test says it still exists
- Recent commits changed view from `if condition { View() }` to `.opacity(condition ? 1 : 0)`

**Recommended Action:** Fix

**Reason:** SwiftUI `.opacity(0)` hides an element visually but keeps it in the accessibility hierarchy (`exists == true`). Tests using `exists == false` will always fail. This is an intentional production code pattern (avoids view recreation to preserve state like streaming connections).

**Diagnosis Steps:**
1. Check if the target view uses `.opacity()` instead of `if/else` for visibility
2. Look at git history for commits that changed from conditional rendering to opacity-based
3. Verify the screenshot confirms the element is visually hidden

**Fix Pattern:**
```swift
// Before (fails with opacity-based hiding):
UATHelper.otherShouldBeDisappear("elementId", app)

// After (works with opacity-based hiding):
let element = app.otherElements["elementId"]
XCTAssertTrue(
    element.waitForPredicate(NSPredicate(format: "isHittable == false"), timeout: 5),
    "element should not be hittable when hidden"
)
```

**Historical Cases:**
- 2026-03-11: `SelectedDeviceInfoPanel` (streamingPanel) changed from `if selectedDeviceID != nil` to `.opacity(panelOpacity)` in commit `e338f78d`. 4 FloorPlan tests failed because `verifyFullScreenFloorPlan()` used `exists == false`.
  - Fix: Changed to `isHittable == false` check in `FloorPlanOperation.swift`

**Notes:**
- `opacity(0)` → `exists == true`, `isHittable == false`
- `if false { View() }` → `exists == false`
- Production code may intentionally use opacity to preserve view state (e.g., streaming connections, scroll position)
- Do NOT suggest changing production code back to `if/else` without understanding why opacity was chosen

---

## sso-ios26-passkey-system-sheet

**Trigger Conditions:**
- All SSO tests fail with "SSO flow exceeded maximum iterations (15)"
- Running on iOS 26 simulator
- `settingUpPasskey` detected repeatedly but Cancel tap has no effect
- System-level sheet "Choose how to manage your passkeys." visible (springboard, not in-app)

**Recommended Action:** Fix

**Reason:** iOS 26 introduces a system-level passkey manager selection sheet presented by AuthenticationServices framework. This sheet is in the springboard accessibility tree, not the app's. It overlays the web view, blocking interaction with the web Cancel button. Requires accessing `XCUIApplication(bundleIdentifier: "com.apple.springboard")` to dismiss.

**Historical Cases:**
- 2026-03-17: iOS 26 simulator introduced system passkey manager sheet during Microsoft SSO
  - Fix: Added `passkeyManagerSystemSheet` case to `SSOPage` with springboard-based detection and dismissal
  - Archive: `openspec/changes/archive/2026-03-17-fix-sso-ios26-passkey-manager-sheet/`

**Notes:**
- Different from `choosePasskeyManager` (in-app native alert with Cancel button)
- System sheet has ✕ close button, "Open Settings", "More Options" — no Cancel
- Detection uses `exists` (no timeout) to avoid performance impact
- Backward compatible: sheet doesn't appear on iOS 25, check is a fast no-op

---

## Adding New Patterns

When adding a new pattern, include:

**Required:**
- **Trigger Conditions** - How to recognize this pattern
- **Recommended Action** - observe/investigate/fix/restore
- **Reason** - Why this recommendation

**Recommended:**
- **Historical Cases** - When it happened, how it was resolved
- **Notes** - Special considerations

**Template:**
```markdown
## pattern-id

**Trigger Conditions:**
- Error message contains "X" or "Y"
- Test name pattern
- Other conditions

**Recommended Action:** Observe | Investigate | Fix | Restore

**Reason:** Why this recommendation

**Historical Cases:**
- YYYY-MM-DD: What happened
- Related fix: archive link or N/A

**Notes:**
- Special considerations
```

---

**Last Updated:** 2026-03-17
