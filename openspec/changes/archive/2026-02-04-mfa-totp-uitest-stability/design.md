# MFA TOTP UITest Stability - Technical Design

## Context

**Current State:**
The UITest suite currently uses `UATMFAUtilityModifier` to automatically display TOTP codes on screen via a `Text` element with accessibility identifier `mfaVerifyCode`. This approach has several issues:
- TOTP codes refresh every 30 seconds, causing timing-dependent test failures
- Automatic display via `onAppear` has unpredictable trigger timing
- Screen-based reading depends on view hierarchy and visibility
- Tests frequently read codes that are about to expire

**Existing Pattern:**
The project already has a similar UATButton pattern in `UATUtilityView` (e.g., `changeLicensePhaseButton` #16) that uses bottom sheets for option selection. This change follows that established pattern.

**Stakeholders:**
- QA engineers running UITests
- CI/CD pipeline reliability
- Development team maintaining tests

## Goals / Non-Goals

**Goals:**
- Eliminate timing-based test failures related to TOTP code expiration
- Replace automatic display with user-triggered actions
- Provide clipboard-based TOTP retrieval for UITests
- Maintain existing MFA functionality for production users
- Follow established UATButton patterns in the codebase

**Non-Goals:**
- Changing production MFA user experience
- Modifying TOTP algorithm or security mechanisms
- Adding new MFA features beyond test stability
- Creating a general-purpose MFA testing framework
- Supporting clipboard access in production mode

## Decisions

### Decision 1: Clipboard vs. Other Approaches

**Chosen:** Use system clipboard (`UIPasteboard.general`) for TOTP transfer

**Alternatives Considered:**
1. **Environment variable:** Not accessible in iOS UITest context
2. **Shared file:** Requires file coordination and cleanup complexity
3. **XCUITest server endpoint:** Over-engineered for simple value transfer
4. **Continue screen display:** Doesn't solve timing issues

**Rationale:**
- Clipboard is native iOS mechanism available in both app and UITest
- No permissions required in Simulator environment
- Simple API: `UIPasteboard.general.string`
- Immediate availability (no polling needed)
- Already used by other features (tested pattern)

**Trade-off:** Clipboard is shared state that could be affected by other processes, but in controlled UITest environment this is acceptable.

### Decision 2: UATButton + Bottom Sheet Pattern

**Chosen:** Add `mfaUtilityButton` (button 18) with bottom sheet options

**Alternatives Considered:**
1. **Two separate buttons:** Setup MFA (#18), Copy TOTP (#19)
   - Pro: Direct action without sheet
   - Con: Uses two button slots, less scalable
2. **Context menu:** Long-press for options
   - Pro: Familiar iOS pattern
   - Con: Harder to trigger in UITests
3. **Automatic both actions:** Always setup + copy
   - Pro: Simplest for tests
   - Con: Inflexible, wasteful when only one action needed

**Rationale:**
- Matches existing `changeLicensePhaseButton` pattern (consistency)
- Allows future additions (e.g., "Clear MFA", "Debug Secret")
- Uses single button slot in increasingly crowded toolbar
- Bottom sheet has clear accessibility for UITests

### Decision 3: Complete Flow in setupMFA()

**Chosen:** `setupMFA()` executes entire MFA setup flow end-to-end

**Alternatives Considered:**
1. **Separate methods:** `getSecret()`, `storeSecret()`, `verifyCode()`, `enableMFA()`
   - Pro: More granular control
   - Con: UITests need to orchestrate multiple steps
2. **Partial setup:** Only get and store secret, verify separately
   - Pro: Matches existing ViewModel flow
   - Con: Requires UITest to navigate UI for verification

**Rationale:**
- UITests need "fast path" to enable MFA without UI navigation
- Reduces test brittleness from multi-screen flows
- All steps are required anyway (no optional steps)
- Errors propagate naturally with Swift's structured concurrency

**Trade-off:** Less flexibility, but UITest use case doesn't need flexibility.

### Decision 4: Remove Automatic Display Entirely

**Chosen:** Delete `UATMFAUtilityModifier` and all automatic display logic

**Alternatives Considered:**
1. **Keep as fallback:** Maintain both approaches
   - Pro: Backward compatibility
   - Con: Maintains broken pattern, confusing to maintain
2. **Feature flag:** Toggle between approaches
   - Pro: Easy rollback
   - Con: Added complexity, needs to maintain both code paths

**Rationale:**
- Automatic display is fundamentally flawed (timing issues)
- No use case for it once clipboard approach is implemented
- Simpler codebase with one clear pattern
- Easier to reason about test behavior

**Migration:** All affected UITests identified and updated in same change (breaking change is intentional).

### Decision 5: Manager Architecture (Not ViewModel)

**Chosen:** Keep `MFAConfigManagerForUAT` as singleton manager with injected dependencies

**Rationale:**
- No UI state to observe (clipboard write is fire-and-forget)
- Used from multiple contexts (UATUtilityView, UITest helper)
- Matches existing UAT manager patterns in codebase
- Dependencies (`authService`, `vortexApi`, `userDefaults`) properly injected via `swift-dependencies`

**Alternative:** Create ViewModel - rejected because no view to bind to, actions are fire-and-forget.

## Risks / Trade-offs

### Risk 1: Clipboard Conflicts
**Risk:** Another process or test could overwrite clipboard between copy and paste.

**Mitigation:**
- UITests run in controlled Simulator environment (low likelihood)
- 2-second wait after clipboard write ensures operation completes
- Tests fail fast with clear assertion if clipboard empty

### Risk 2: Time Synchronization
**Risk:** Simulator time drift could cause TOTP generation/verification mismatch.

**Mitigation:**
- TOTP has 30-second window (allows some drift)
- `setupMFA()` generates and immediately verifies (minimal window)
- Simulator time should match host machine time (iOS default)
- If issue occurs, backend TOTP verification will reject (clear failure mode)

### Risk 3: Migration Completeness
**Risk:** Missing UITest files that reference `mfaVerifyCode` could break CI.

**Mitigation:**
- Global search for `mfaVerifyCode` before completion
- Comprehensive list of affected files in spec (4 UITest files)
- Run full UITest suite before merge
- Failing tests will immediately reveal missing updates

### Risk 4: Sheet Animation Timing
**Risk:** Bottom sheet animations could cause race conditions in UITests.

**Mitigation:**
- `UATHelper.clickMFAUtilityOption()` explicitly waits for sheet appear/disappear
- 2-second buffer after sheet dismissal for async operations
- Uses `waitElementToAppear` / `waitElementToDisappear` patterns (proven in codebase)

### Risk 5: Secret Code Lifecycle
**Risk:** `secretCodeForUAT` stored in memory persists between tests, causing test pollution.

**Mitigation:**
- Each test that enables MFA should call `disableUserMFA` in teardown (existing pattern)
- Secret is instance property (not persisted to disk)
- App reinstall between test runs clears state
- If needed, can add `clearSecret()` method for explicit reset

## Migration Plan

**Step 1: Implementation (Atomic Change)**
1. Add `mfaUtilityButton` and `MFAOptionSheet` to `UATUtilityView`
2. Refactor `MFAConfigManagerForUAT` (new methods, remove old)
3. Remove `UATMFAUtilityModifier.swift` and all usages
4. Update `UATHelper` with `clickMFAUtilityOption()`
5. Update 4 affected UITest files to use clipboard approach

**Step 2: Verification**
1. Build both app and UITest targets (compile check)
2. Run `MFAConfigurationUITest.testMFASetting()`
3. Run `OrgForceMFAUITest` both test methods
4. Global search verification: `grep -r "mfaVerifyCode"` returns empty
5. Global search verification: `grep -r "UATMFAUtilityModifier"` returns empty

**Step 3: Rollback (If Needed)**
- Revert commit (all changes in single commit)
- Previous approach remains in git history
- No database or API changes (rollback is clean)

**Breaking Change Communication:**
- This is internal UITest infrastructure (no external API)
- QA team notification via PR description
- No production user impact

## Open Questions

None - all technical decisions have been made based on the detailed spec provided.
