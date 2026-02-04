# Implementation Tasks

## 1. Refactor MFAConfigManagerForUAT

- [x] 1.1 Read existing `MFAConfigManagerForUAT` in `MFAConfigurationViewModel.swift`
- [x] 1.2 Remove `@Published var verifyCode: String` property
- [x] 1.3 Remove `setSecretCode(_ code: String) async` method
- [x] 1.4 Remove `genVerifyCode()` method
- [x] 1.5 Add `secretCodeForUAT: String` private property (replaces published version)
- [x] 1.6 Add `@Dependency(\.authService) var authService` injection
- [x] 1.7 Add `@Dependency(\.vortexApi) var vortexApi` injection
- [x] 1.8 Add `@Dependency(\.userDefaults) var userDefaults` injection
- [x] 1.9 Implement `setupMFA() async throws` method with full MFA setup flow
- [x] 1.10 Implement `generateAndCopyToClipboard() throws` method
- [x] 1.11 Add nested `MFAError` enum with `secretCodeNotSet` and `failedToGenerateTOTP` cases
- [x] 1.12 Add `localizedDescription` to `MFAError` enum

## 2. Clean up MFAConfigurationViewModel

- [x] 2.1 Read `MFAConfigurationViewModel.prepareTOTP()` method
- [x] 2.2 Remove `if VortexEnvironment.isUITest` check and `MFAConfigManagerForUAT.shared.setSecretCode()` call
- [x] 2.3 Verify `prepareTOTP()` only calls `authService.getTOTPSetupDetail()` and stores result

## 3. Add MFA Utility Button to UATUtilityView

- [x] 3.1 Read `UATUtilityView.swift` to understand existing button pattern
- [x] 3.2 Add `mfaUtilityButton` computed property with `UATButtonView("18", identifier: "mfaUtilityButton")`
- [x] 3.3 Add `mfaUtilityButton` to the HStack in body (after `downgradeButton`)
- [x] 3.4 Create `MFAOptionSheet` struct in `UATUtilityView` extension
- [x] 3.5 Add `@State private var contentHeight: CGFloat = .zero` to `MFAOptionSheet`
- [x] 3.6 Add `@ObservedObject private var sheetManager = SheetManager.shared` to `MFAOptionSheet`
- [x] 3.7 Implement "Setup MFA" button with identifier "setupMFAOption" that calls `MFAConfigManagerForUAT.shared.setupMFA()`
- [x] 3.8 Implement "Copy TOTP" button with identifier "copyTOTPOption" that calls `MFAConfigManagerForUAT.shared.generateAndCopyToClipboard()`
- [x] 3.9 Add error handling with console logging for both buttons
- [x] 3.10 Add sheet identifier "MFAOptionSheet" to VStack
- [x] 3.11 Add height calculation using GeometryReader and `.presentationDetents([.height(contentHeight)])`

## 4. Remove UATMFAUtilityModifier

- [x] 4.1 Search for all usages of `.mfaUtilityView()` modifier in codebase
- [x] 4.2 Remove `.mfaUtilityView()` from `VerifyMFAView.swift` (line 38)
- [x] 4.3 Search for any other usages of `UATMFAUtilityModifier` import or usage
- [x] 4.4 Delete file `iOSCharmander/View/SideMenu/Settings/UATMFAUtilityModifier.swift`
- [x] 4.5 Remove file from Xcode project if needed

## 5. Add UITest Helper Method

- [x] 5.1 Read `iOSCharmanderUITests/Infrastructure/UATHelper.swift`
- [x] 5.2 Add `clickMFAUtilityOption(_ option: String, _ app: XCUIApplication)` static method
- [x] 5.3 Implement button tap for "mfaUtilityButton"
- [x] 5.4 Implement wait for "MFAOptionSheet" to appear
- [x] 5.5 Implement option selection logic (map "Setup MFA" → "setupMFAOption", "Copy TOTP" → "copyTOTPOption")
- [x] 5.6 Implement wait for "MFAOptionSheet" to disappear
- [x] 5.7 Add 2-second sleep for async operation completion

## 6. Update CommonOperation UITest

- [x] 6.1 Read `iOSCharmanderUITests/Infrastructure/CommonOperation.swift`
- [x] 6.2 Locate `setMFA()` method
- [x] 6.3 Remove `UATHelper.waitUntilTrue(app.staticTexts["mfaVerifyCode"].exists, ...)` line
- [x] 6.4 Replace with `UATHelper.clickMFAUtilityOption("Copy TOTP", app)`
- [x] 6.5 Add `let code = UIPasteboard.general.string ?? ""`
- [x] 6.6 Add `XCTAssertFalse(code.isEmpty, "TOTP code should not be empty")`
- [x] 6.7 Use `code` variable in `UATHelper.setText(code, to: "6-digit code", ...)`

## 7. Update MFAConfigurationUITest

- [x] 7.1 Read `iOSCharmanderUITests/MFASetting/MFAConfigurationUITest.swift`
- [x] 7.2 Locate `enterMFAVerifyCode()` private method
- [x] 7.3 Remove `UATHelper.waitElementToAppear(app.staticTexts["mfaVerifyCode"])` line
- [x] 7.4 Remove `let code = app.staticTexts["mfaVerifyCode"].label` line
- [x] 7.5 Add `UATHelper.clickMFAUtilityOption("Copy TOTP", app)`
- [x] 7.6 Add `let code = UIPasteboard.general.string ?? ""`
- [x] 7.7 Add `XCTAssertFalse(code.isEmpty, "TOTP code should not be empty")`
- [x] 7.8 Keep remaining code that uses `code` variable unchanged

## 8. Update OrgForceMFAUITest

- [x] 8.1 Read `iOSCharmanderUITests/SignIn/OrgForceMFAUITest.swift`
- [x] 8.2 Locate `testNormalSignInWithOrgForceMFA()` method
- [x] 8.3 Replace MFA setup flow with `UATHelper.clickMFAUtilityOption("Setup MFA", app)`
- [x] 8.4 Remove any code between `signIn(.testForceMFA)` and `checkIsEnterViewPage()` calls
- [x] 8.5 Locate `testSSOSignInWithOrgForceMFA()` method
- [x] 8.6 Replace MFA setup flow with `UATHelper.clickMFAUtilityOption("Setup MFA", app)`
- [x] 8.7 Remove any code between `ssoSignIn()` and `checkIsEnterViewPage()` calls

## 9. Verification and Cleanup

- [x] 9.1 Build iOSCharmander target successfully
- [x] 9.2 Build iOSCharmanderUITests target successfully
- [x] 9.3 Run global search for "mfaVerifyCode" - should find zero results
- [x] 9.4 Run global search for "UATMFAUtilityModifier" - should find zero results
- [x] 9.5 Run global search for ".mfaUtilityView()" - should find zero results
- [x] 9.6 Run `MFAConfigurationUITest.testMFASetting` - should pass
- [x] 9.7 Run `OrgForceMFAUITest.testNormalSignInWithOrgForceMFA` - should pass
- [x] 9.8 Run `OrgForceMFAUITest.testSSOSignInWithOrgForceMFA` - should pass
- [x] 9.9 Remove any unused imports from modified files
- [x] 9.10 Verify no compiler warnings in modified files
