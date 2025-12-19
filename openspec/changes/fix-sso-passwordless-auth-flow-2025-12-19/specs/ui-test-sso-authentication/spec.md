# UI Test SSO Authentication

## Purpose
Provides UITest infrastructure for automated Microsoft Entra ID (Azure AD) SSO authentication flows, handling various Microsoft authentication pages and dialogs that may appear during the sign-in process.

## MODIFIED Requirements

### Requirement: Microsoft Passwordless Authentication Flow Handling
The `entraWebSSOSignIn()` test helper function SHALL handle Microsoft Entra ID's passwordless authentication flow by detecting and bypassing the "Get a code to sign in" page.

#### Scenario: Detect "Get a code to sign in" passwordless page
- **GIVEN** Microsoft Entra ID presents passwordless authentication as default
- **WHEN** user enters email address
- **AND** Microsoft shows "Get a code to sign in" page heading
- **THEN** test detects the passwordless page via web view static text
- **AND** test proceeds to bypass passwordless flow

#### Scenario: Click "Use your password" link on "Get a code to sign in" page
- **GIVEN** "Get a code to sign in" page is detected
- **WHEN** "Use your password" link is visible
- **THEN** test scrolls down if needed to reveal the link
- **AND** test optionally clicks "Other ways to sign in" button if it appears
- **AND** test clicks "Use your password" link
- **AND** password entry field appears

#### Scenario: Backward compatibility with "Verify your email" flow
- **GIVEN** Microsoft may show "Verify your email" heading instead of "Get a code to sign in"
- **WHEN** "Verify your email" page appears
- **THEN** test detects this alternate passwordless page
- **AND** test uses same password bypass logic (scroll, click "Use your password")
- **AND** both headings are supported for backward compatibility

#### Scenario: Complete password-based authentication after bypass
- **GIVEN** passwordless flow was bypassed
- **WHEN** password entry field appears
- **THEN** test enters password using `typeTextOnWeb()`
- **AND** test clicks "Next" button
- **AND** authentication continues to passkey handlers and "Stay signed in?" dialog

#### Scenario: Integration with existing authentication flow
- **GIVEN** password bypass completes successfully
- **WHEN** authentication proceeds
- **THEN** test calls `otherCheckIfNeeded()` to handle "Sign in faster" dialog
- **AND** test calls `handlePasskeyWebPageIfNeeded()` to handle "Setting up your passkey..." page
- **AND** test calls `handlePasskeyDialogIfNeeded()` to handle native passkey dialog
- **AND** test calls `ssoConfirmToEnterApp()` to handle "Stay signed in?" dialog
- **AND** authentication flow completes successfully
