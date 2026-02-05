## 1. Core Types

- [x] 1.1 Create `SSOOperation.swift` file in `iOSCharmanderUITests/Infrastructure/`
- [x] 1.2 Define `SSOPage` enum with all known page cases (signIn, enterPassword, enterYourPassword, getCodeToSignIn, verifyYourEmail, settingUpPasskey, passkeyBiometricsRequired, choosePasskeyManager, passkeyCreationFailed, signInFaster, staySignedIn, signInBlocked, loginComplete)
- [x] 1.3 Add `CaseIterable` conformance to `SSOPage`
- [x] 1.4 Define `SSOPageResult` enum with cases: `.continueFlow`, `.success`, `.failure(String)`

## 2. Page Detection

- [x] 2.1 Add `detector` computed property to `SSOPage` returning `(XCUIApplication) -> XCUIElement` closure for each case
- [x] 2.2 Add `exists(in:)` method to `SSOPage` that checks if the detector element exists
- [x] 2.3 Add `isTerminal` computed property to `SSOPage` returning true for `loginComplete` and `signInBlocked`

## 3. Page Handlers

- [x] 3.1 Add `handle(app:account:password:)` method to `SSOPage` with switch for all cases
- [x] 3.2 Implement `signIn` handler: enter account, tap Next, return `.continueFlow`
- [x] 3.3 Implement `enterPassword`/`enterYourPassword` handlers: enter password, tap Sign in/Next, return `.continueFlow`
- [x] 3.4 Implement `getCodeToSignIn`/`verifyYourEmail` handlers: navigate to password mode, enter password, return `.continueFlow`
- [x] 3.5 Implement passkey handlers (`settingUpPasskey`, `passkeyBiometricsRequired`, `choosePasskeyManager`, `passkeyCreationFailed`): tap Cancel, return `.continueFlow`
- [x] 3.6 Implement `signInFaster` handler: tap "Skip for now", return `.continueFlow`
- [x] 3.7 Implement `staySignedIn` handler: tap "No", return `.continueFlow`
- [x] 3.8 Implement `loginComplete` handler: return `.success`
- [x] 3.9 Implement `signInBlocked` handler: return `.failure` with error message

## 4. Protocol and State Machine

- [x] 4.1 Define `SSOOperation` protocol inheriting from `CommonOperation`
- [x] 4.2 Add `detectCurrentPage(app:timeout:)` function signature to protocol
- [x] 4.3 Add `performEntraSSOSignIn(account:password:)` function signature to protocol
- [x] 4.4 Implement `detectCurrentPage` in protocol extension: priority check for terminal states, then iterate all non-terminal pages with polling
- [x] 4.5 Implement `performEntraSSOSignIn` in protocol extension: detect-handle loop with logging, max 20 iterations, XCTFail on timeout or exceeded iterations

## 5. Test Migration

- [x] 5.1 Update `SigninWithSSOUITest.swift` to conform to `SSOOperation` instead of only `CommonOperation`
- [x] 5.2 Replace `entraWebSSOSignIn` calls with `performEntraSSOSignIn` in `SigninWithSSOUITest`
- [x] 5.3 Update `OrgForceMFAUITest.swift` to conform to `SSOOperation`
- [x] 5.4 Replace `entraWebSSOSignIn` calls with `performEntraSSOSignIn` in `OrgForceMFAUITest`

## 6. Verification

- [x] 6.1 Build UITest target to verify compilation
- [x] 6.2 Run SSO-related UITests locally to verify functionality
