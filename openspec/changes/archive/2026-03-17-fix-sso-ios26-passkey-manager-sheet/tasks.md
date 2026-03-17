## 1. Add new SSOPage case

- [x] 1.1 Add `passkeyManagerSystemSheet` case to `SSOPage` enum in `SSOOperation.swift`
- [x] 1.2 Add detector that queries springboard app for "Choose how to manage your passkeys." text
- [x] 1.3 Add handler that taps the close button (✕) on the springboard sheet, returning `.continueFlow`

## 2. Update detection priority

- [x] 2.1 In `detectCurrentPage`, add system-level sheet check after terminal state check and before `postSignInPages` iteration
- [x] 2.2 Ensure the springboard check uses `exists` (no timeout) to avoid performance impact when sheet is absent

## 3. Update known patterns

- [x] 3.1 Update `patterns.md` with new pattern entry for iOS 26 system-level passkey manager sheet
- [x] 3.2 Add historical case entry referencing this change
