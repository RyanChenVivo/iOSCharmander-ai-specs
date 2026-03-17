## Context

On iOS 26, when Microsoft SSO triggers passkey setup ("Setting up your passkey..."), the system automatically presents a passkey manager selection sheet ("Choose how to manage your passkeys.") via the AuthenticationServices framework. This sheet:

- Is rendered at the system level (not in the app's accessibility hierarchy)
- Has no Cancel button — only ✕ (close), "Open Settings", and "More Options"
- Overlays the web view, blocking interaction with the web Cancel button
- Causes `detectCurrentPage` to find `settingUpPasskey` but the handler fails silently (tap on blocked element)

The existing `choosePasskeyManager` case handles a different UI: an in-app native alert with a Cancel button that appeared in earlier iOS versions after passkey creation failure.

Current SSO flow in `SSOOperation.swift`:
1. `performEntraSSOSignIn` → loops `detectCurrentPage` + `handle`
2. `detectCurrentPage` checks terminal states first, then iterates `postSignInPages`
3. `settingUpPasskey` is detected → handler taps `app.webViews.buttons["Cancel"]` → blocked by system sheet → no effect → loop repeats until max iterations

## Goals / Non-Goals

**Goals:**
- Dismiss the iOS 26 system-level passkey manager sheet so SSO flow can proceed
- Maintain backward compatibility with iOS 25 (where this sheet doesn't appear)
- Minimal changes to existing SSO architecture

**Non-Goals:**
- Changing the passkey setup behavior in production code
- Handling "Open Settings" or "More Options" flows (we just want to dismiss)
- Refactoring the entire SSO page detection mechanism

## Decisions

### Decision 1: Access system sheet via springboard app

**Choice**: Use `XCUIApplication(bundleIdentifier: "com.apple.springboard")` to find and dismiss the system sheet.

**Rationale**: The sheet is not in the app's accessibility tree. Springboard is the standard way to interact with system-level UI in XCUITest. This pattern is already used in the codebase for handling system alerts (e.g., notification permission dialogs).

**Alternatives considered**:
- `addUIInterruptionMonitor` — Does not reliably catch cross-process sheets on iOS 26 simulators
- Tapping by coordinate — Fragile, breaks across device sizes

### Decision 2: Add a new `passkeyManagerSystemSheet` case to SSOPage

**Choice**: Add a new enum case rather than modifying the existing `choosePasskeyManager`.

**Rationale**: The two UIs are fundamentally different:
| | `choosePasskeyManager` (existing) | `passkeyManagerSystemSheet` (new) |
|---|---|---|
| Source | In-app native alert | System-level sheet (AuthenticationServices) |
| Accessibility tree | `app.staticTexts` | `springboard.staticTexts` or `springboard.buttons` |
| Dismiss action | `app.buttons["Cancel"]` | Springboard close button (✕) |
| Trigger | After passkey creation failure | During passkey setup (iOS 26) |

Keeping them separate preserves backward compatibility and makes the distinction clear.

### Decision 3: Check system sheet before web page detection

**Choice**: In `detectCurrentPage`, check for the system sheet early (after terminal state check, before iterating `postSignInPages`).

**Rationale**: The system sheet overlays everything. If it's present, no web element interaction will succeed. Detecting it first avoids wasted timeout cycles on web element checks.

## Risks / Trade-offs

- **[Risk] Springboard element identifiers may change across iOS versions** → Mitigation: Use text-based matching ("Choose how to manage") which is more stable than element IDs. Add to known patterns for future monitoring.
- **[Risk] System sheet may not appear on all simulator configurations** → Mitigation: The handler is additive — if the sheet isn't present, detection simply returns false and falls through to existing logic.
- **[Risk] Performance impact of checking springboard on every detection cycle** → Mitigation: Use `exists` check (no timeout) for springboard elements, only apply timeout when the element is likely present. The springboard check is a fast no-op when the sheet isn't showing.
