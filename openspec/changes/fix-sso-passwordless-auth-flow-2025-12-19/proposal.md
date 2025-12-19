# Fix SSO Passwordless Authentication Flow (2025-12-19)

## Why

Three SSO-related UITests have been failing consistently since December 10, 2025 (9 days, 8 consecutive failures). The December 19 CI run with visual analysis (screenshots) revealed the root cause: Microsoft Entra ID changed the default authentication flow to **passwordless authentication**, showing a "Get a code to sign in" page that differs from the previously handled "Verify your email" flow.

### Failure Analysis

#### Affected Tests
1. `SigninWithSSO/testSignInWithSSO_ShouldFailed_whenTypeDifferentEmailOnMicrosoftPage()`
2. `SigninWithSSO/testSignInWithSSO_Success()`
3. `OrgForceMFAUITest/testSSOSignInWithOrgForceMFA()`

#### Error Message
```
failed - "Stay signed in?" StaticText is not exist
```

#### Screenshot Evidence
- **File**: `A2153BA8-0211-405E-8781-D67509DFA79F.png` (2025-12-19)
- **URL**: `login.live.com`
- **Email**: `charmandersso3@dropmeon.com`
- **Heading**: "Get a code to sign in" (NEW - different from "Verify your email")
- **Message**: "We'll send a code to charmandersso3@dropmeon.com to sign you in."
- **Buttons**: "Send code" (primary), "Use your password" (link)

#### Root Cause
Microsoft Entra ID changed the default authentication method from password-based to **passwordless authentication**:

**New Flow (Current):**
1. User enters email
2. **NEW**: Microsoft shows "Get a code to sign in" page (default passwordless flow)
3. User must click "Use your password" link to bypass passwordless
4. Then enters password
5. Proceeds to "Stay signed in?" dialog

**What Test Expects:**
1. User enters email
2. **EXPECTED**: Direct password entry OR "Verify your email" heading
3. "Stay signed in?" dialog

**Why Tests Fail:**
The current code at `CommonOperation.swift:189-197` handles the "Verify your email" passwordless page but doesn't recognize the new "Get a code to sign in" heading. The test never reaches "Stay signed in?" because it's stuck waiting at the unrecognized passwordless page.

#### Diagnostic History
- **2025-12-10 to 2025-12-15**: Tests failed, suspected Microsoft blocking or passkey issues
- **2025-12-15**: Added `handlePasskeyWebPageIfNeeded()` to handle "Setting up your passkey..." page - only temporary fix
- **2025-12-16 to 2025-12-18**: Tests continued failing - previous fix didn't address root cause
- **2025-12-19**: Visual analysis with screenshots confirmed Microsoft changed to "Get a code to sign in" passwordless flow

#### Previous Related Fixes
- **2025-12-03**: `fix-uitest-failures-2025-12-03` - Added `handlePasskeyDialogIfNeeded()` for native passkey dialog
- **2025-12-15**: `2025-12-15-fix-uitest-sso-passkey-handling` - Added `handlePasskeyWebPageIfNeeded()` for web-based passkey page
- **Current**: Microsoft changed passwordless flow heading from "Verify your email" to "Get a code to sign in"

## What Changes

Update the passwordless authentication detection in `entraWebSSOSignIn()` to recognize Microsoft's new "Get a code to sign in" page heading:

- **Update existing function**: Modify `enterPassword()` function (lines 178-198) to detect both:
  - "Verify your email" (old heading - keep for backward compatibility)
  - "Get a code to sign in" (new heading - add support)
- **Location**: `iOSCharmanderUITests/Infrastructure/CommonOperation.swift:189`
- **Logic**:
  - Detect either passwordless heading ("Get a code to sign in" OR "Verify your email")
  - Scroll down if needed to reveal "Use your password" link
  - Click "Other ways to sign in" if it appears
  - Click "Use your password" link
  - Enter password
  - Click "Next" button
  - Continue to existing flow (passkey handlers → "Stay signed in?")

**Technical Implementation:**
Replace single heading check with multiple heading detection using `waitElementToAppearOptionally` for both headings, ensuring the existing password bypass logic works with both flows.

## Impact

- **Affected specs**: `mobile-floor-plan-ui-testing` (UI test reliability)
- **Affected code**:
  - `iOSCharmanderUITests/Infrastructure/CommonOperation.swift:172-227` (entraWebSSOSignIn function)
- **Risk**: Low - test-only changes with no production code impact
- **User impact**: None (test infrastructure only)
- **CI Impact**: Fixes 3 consistently failing tests (4.2% failure rate → 0%)
- **Test Environment**: No environment changes required (pure code fix)
- **Backward Compatibility**: Maintains support for "Verify your email" flow in case Microsoft reverts or shows different flows to different accounts

## Related

- **Previous fixes**:
  - `fix-uitest-failures-2025-12-03` - handled native passkey dialog
  - `2025-12-15-fix-uitest-sso-passkey-handling` - handled web-based passkey page
- **Triage analysis**: Phase 1 & 2 analysis from `/analyze-uitest` workflow (2025-12-19)
- **Screenshot evidence**: `$HOME/Downloads/UITestAnalysis/latest/attachments/A2153BA8-0211-405E-8781-D67509DFA79F.png`
- **Observations**: Updated in `uitest-automation/observations/active.json` (occurrences: 8, decision: escalate_to_fix)
- **Pattern library**: Updated in `uitest-automation/knowledge/patterns.md` (pattern: EXTERNAL_SERVICE_CHANGE)
