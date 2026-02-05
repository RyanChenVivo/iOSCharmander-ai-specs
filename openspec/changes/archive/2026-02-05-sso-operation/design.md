## Context

The current SSO UITest implementation in `CommonOperation.swift` uses a sequential, hardcoded flow that assumes Microsoft's Entra SSO pages always appear in the same order. When Microsoft changes their flow (different password page variants, optional Passkey prompts, MFA steps), tests become flaky or fail. The existing `waitElementToAppearOptionally` pattern causes slow tests because each variant check waits for its full timeout before trying the next option.

The `FloorPlanOperation` protocol in the codebase demonstrates a successful pattern of using protocol + extension to encapsulate complex UITest operations with good readability and maintainability.

## Goals / Non-Goals

**Goals:**
- Create a robust state machine that handles any order of Microsoft SSO pages
- Enable simultaneous page detection to eliminate sequential timeout delays
- Provide clear extension points for adding new page variants
- Maintain debug visibility with step-by-step logging
- Follow existing `FloorPlanOperation` protocol pattern for consistency

**Non-Goals:**
- Supporting non-Microsoft SSO providers (SAML, Okta, etc.)
- Handling MFA code entry (requires manual intervention)
- Implementing actual Passkey authentication (design cancels Passkey prompts)
- Replacing `CommonOperation` entirely (this extends it)

## Decisions

### Decision 1: State Machine Pattern over Sequential Flow

**Choice:** Implement a detect-handle-repeat loop instead of a fixed sequence.

**Alternatives considered:**
- **Fixed sequence with more variants:** Would require exponential branching for all combinations
- **Retry-on-failure:** Doesn't address the fundamental ordering problem

**Rationale:** Microsoft's SSO flow is non-deterministic from the test's perspective. A state machine naturally handles arbitrary page order by detecting what's currently shown and handling it, regardless of how we got there.

### Decision 2: Enum-based Page Definition with CaseIterable

**Choice:** Use `SSOPage` enum conforming to `CaseIterable` for page definitions.

**Alternatives considered:**
- **Struct-based page registry:** More flexible but harder to ensure exhaustive handling
- **Protocol-based page types:** Overkill for this use case, harder to iterate

**Rationale:** Enum with `CaseIterable` enables iterating all known pages during detection and ensures the compiler enforces exhaustive handling in switch statements. Adding a new page requires adding a case, which forces handling implementation.

### Decision 3: Protocol Extension for Default Implementation

**Choice:** Provide full implementation via `SSOOperation` protocol extension, similar to `FloorPlanOperation`.

**Alternatives considered:**
- **Base class:** Swift's protocol-oriented design prefers composition over inheritance
- **Standalone helper class:** Loses the clean conformance pattern

**Rationale:** Protocol extension matches existing codebase patterns and allows test classes to gain SSO capability by simply declaring conformance to `SSOOperation`.

### Decision 4: Prioritize Terminal States in Detection

**Choice:** Check `loginComplete` and `signInBlocked` before iterating other pages.

**Rationale:** Terminal states should be recognized immediately to avoid processing pages after the flow has ended. This prevents edge cases where a success indicator appears alongside leftover UI elements.

## Risks / Trade-offs

**[Risk] Unrecognized page variant** → Detection loop times out with "unable to detect current page." **Mitigation:** Comprehensive logging shows last known state; new pages can be added by extending the enum.

**[Risk] Infinite loop if page handling doesn't advance flow** → Maximum iteration limit (20) prevents true infinite loops. **Mitigation:** Each iteration logs the detected page, making stuck states visible.

**[Risk] Passkey forced by Microsoft** → Current design cancels Passkey prompts, which may eventually fail if Microsoft removes the cancel option. **Mitigation:** This is a known limitation documented in the proposal; requires future work if Microsoft changes policy.

**[Trade-off] Polling-based detection vs. event-driven** → Polling with 0.5s intervals is simple but slightly less efficient than XCTest's built-in waiting. **Accepted** because simultaneous multi-element checking is simpler with polling and the overhead is negligible for UI tests.
