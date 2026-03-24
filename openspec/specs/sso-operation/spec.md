## ADDED Requirements

### Requirement: System-level passkey manager sheet detection

The system SHALL detect the iOS 26 system-level passkey biometrics sheet ("Simulator requires enrolled biometrics to use passkeys.") by querying the springboard accessibility tree via `XCUIApplication(bundleIdentifier: "com.apple.springboard")`.

#### Scenario: Sheet is present on iOS 26
- **WHEN** Microsoft SSO triggers passkey setup on iOS 26
- **THEN** the system SHALL detect the "Simulator requires enrolled biometrics to use passkeys." text in the springboard accessibility tree

#### Scenario: Sheet is not present
- **WHEN** the system checks for the passkey manager sheet and it is not displayed
- **THEN** the detection SHALL return false without timeout delay

### Requirement: System-level passkey manager sheet dismissal

The system SHALL dismiss the iOS 26 system-level passkey biometrics sheet by tapping its Cancel button via the springboard accessibility tree.

#### Scenario: Dismiss sheet and continue SSO flow
- **WHEN** the system-level passkey biometrics sheet is detected
- **THEN** the system SHALL tap the Cancel button on the springboard sheet and return `.continueFlow`

#### Scenario: Backward compatibility with iOS 25
- **WHEN** the system checks for the passkey manager sheet on iOS 25 or earlier
- **THEN** the sheet SHALL not be found and the system SHALL fall through to existing page detection logic

### Requirement: SSOPage enum defines all known Microsoft SSO pages

The system SHALL define an `SSOPage` enum that includes all known Microsoft Entra SSO page variants:
- Login pages: `signIn`, `enterPassword`, `enterYourPassword`
- Passwordless pages: `getCodeToSignIn`, `verifyYourEmail`
- Passkey pages: `settingUpPasskey`, `passkeyBiometricsRequired`, `choosePasskeyManager`, `passkeyCreationFailed`, `passkeyManagerSystemSheet`
- Other pages: `signInFaster`, `staySignedIn`
- Terminal pages: `signInBlocked`, `loginComplete`

#### Scenario: Enum is exhaustive and iterable
- **WHEN** the `SSOPage` enum is accessed
- **THEN** it SHALL conform to `CaseIterable` to enable iteration over all cases

#### Scenario: Each page has a detection closure
- **WHEN** a page detector is accessed for any `SSOPage` case
- **THEN** it SHALL return a closure `(XCUIApplication) -> XCUIElement` that identifies the page

#### Scenario: System-level page uses springboard for detection
- **WHEN** a page detector is accessed for `passkeyManagerSystemSheet`
- **THEN** it SHALL query the springboard app (`com.apple.springboard`) instead of the main app

### Requirement: Page detection checks all pages simultaneously

The `detectCurrentPage` function SHALL check all known pages in parallel rather than sequentially waiting for each.

#### Scenario: Detection within timeout returns the current page
- **WHEN** a Microsoft SSO page is visible within the timeout period
- **THEN** the function SHALL return the corresponding `SSOPage` case

#### Scenario: Detection prioritizes terminal states
- **WHEN** multiple elements are visible including a terminal state (`loginComplete` or `signInBlocked`)
- **THEN** the function SHALL return the terminal state first

#### Scenario: Detection prioritizes system-level sheet over web pages
- **WHEN** the system-level passkey manager sheet is present alongside a web page
- **THEN** the function SHALL return `passkeyManagerSystemSheet` before any web page case

#### Scenario: Detection timeout returns nil
- **WHEN** no recognized page is visible within the timeout period
- **THEN** the function SHALL return `nil`

### Requirement: Page handlers process each page type

Each `SSOPage` case SHALL have a handler function that performs the appropriate action and returns `SSOPageResult`.

#### Scenario: Login page handler enters account
- **WHEN** the handler is called for `signIn` page
- **THEN** it SHALL enter the account email and tap Next, returning `.continueFlow`

#### Scenario: Password page handler enters password
- **WHEN** the handler is called for `enterPassword` or `enterYourPassword` page
- **THEN** it SHALL enter the password and tap the appropriate submit button, returning `.continueFlow`

#### Scenario: Passwordless page handler switches to password mode
- **WHEN** the handler is called for `getCodeToSignIn` or `verifyYourEmail` page
- **THEN** it SHALL navigate to password entry mode by tapping "Use your password", returning `.continueFlow`

#### Scenario: Passkey page handler cancels passkey flow
- **WHEN** the handler is called for any passkey-related page
- **THEN** it SHALL tap Cancel to dismiss the passkey prompt, returning `.continueFlow`

#### Scenario: System-level passkey manager sheet handler dismisses via springboard
- **WHEN** the handler is called for `passkeyManagerSystemSheet`
- **THEN** it SHALL tap the Cancel button on the springboard sheet, returning `.continueFlow`

#### Scenario: Stay signed in handler declines
- **WHEN** the handler is called for `staySignedIn` page
- **THEN** it SHALL tap "No", returning `.continueFlow`

#### Scenario: Login complete handler returns success
- **WHEN** the handler is called for `loginComplete` page
- **THEN** it SHALL return `.success`

#### Scenario: Sign in blocked handler returns failure
- **WHEN** the handler is called for `signInBlocked` page
- **THEN** it SHALL return `.failure` with an appropriate error message

### Requirement: SSOPageResult enum controls flow continuation

The system SHALL define an `SSOPageResult` enum with cases:
- `.continueFlow` - continue detecting and handling pages
- `.success` - login completed successfully
- `.failure(String)` - login failed with reason

#### Scenario: Result types are exhaustive
- **WHEN** a handler completes
- **THEN** it SHALL return exactly one of the three result types

### Requirement: Main loop executes state machine

The `performEntraSSOSignIn` function SHALL implement a detect-handle-repeat loop.

#### Scenario: Loop detects and handles pages until terminal
- **WHEN** `performEntraSSOSignIn` is called with account and password
- **THEN** it SHALL repeatedly call `detectCurrentPage` and the page's handler until a terminal result is returned

#### Scenario: Loop logs each step
- **WHEN** a page is detected and handled
- **THEN** the function SHALL print a log message indicating the step number and page type

#### Scenario: Loop enforces maximum iterations
- **WHEN** the loop exceeds 20 iterations without reaching a terminal state
- **THEN** it SHALL call `XCTFail` with an appropriate error message

#### Scenario: Loop fails on detection timeout
- **WHEN** `detectCurrentPage` returns `nil`
- **THEN** the function SHALL call `XCTFail` indicating the flow is stuck

### Requirement: SSOOperation protocol extends CommonOperation

The `SSOOperation` protocol SHALL inherit from `CommonOperation` and provide default implementations via protocol extension.

#### Scenario: Test class gains SSO capability through conformance
- **WHEN** a test class declares conformance to `SSOOperation`
- **THEN** it SHALL automatically have access to `performEntraSSOSignIn` and `detectCurrentPage` methods

#### Scenario: Protocol requires app property
- **WHEN** a test class conforms to `SSOOperation`
- **THEN** it SHALL provide the `app: XCUIApplication` property from `CommonOperation`

### Requirement: Adding new page variants requires minimal changes

The architecture SHALL support adding new Microsoft page variants with minimal code changes.

#### Scenario: New page variant addition
- **WHEN** a new Microsoft SSO page variant is discovered
- **THEN** it SHALL be addable by: (1) adding a case to `SSOPage` enum, (2) adding detector closure, (3) adding handler case

#### Scenario: Compiler enforces exhaustive handling
- **WHEN** a new case is added to `SSOPage` enum
- **THEN** the Swift compiler SHALL require handling in all switch statements
