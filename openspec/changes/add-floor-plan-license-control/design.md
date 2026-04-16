# Floor Plan License Control — Design

## Context

The floor plan feature is currently gated by two mechanisms:
1. **`canView(.floorPlan)`** — checks `myOrganizationSupportFeatures.contains(.floorPlan)` (backend-driven flag)
2. **Remote config** — `feature_floor_plan` flag

There is no license tier or phase-based enforcement. The app already has well-established patterns for license control on other tabs (Archive, AI Hub) using the three-tier check system (`canView` → `canAccess` → `canTrigger`) and `FeaturePromotionView` for locked features. The downgrade flow uses a backend-driven checklist (`postCheckDowngrade()` returning `MissionType` items).

KA organization exemption is handled entirely by the backend — the iOS app receives already-resolved license states and does not need KA-specific logic.

## Goals / Non-Goals

**Goals:**
- Gate floor plan access for xLite (free plan) organizations with a commercial promotion page
- Disable floor plan tab during RenewalOverdue, consistent with existing lockdown pattern
- Handle API 423 responses gracefully when backend enforces license on floor plan APIs
- Add floor plan data deletion to the downgrade prerequisites checklist
- Handle live license phase transitions while user is on floor plan

**Non-Goals:**
- KA organization logic on the iOS side (backend handles this)
- Floor plan data cleanup logic on the iOS side (backend handles deletion on downgrade; iOS only shows the checklist item)
- Changing floor plan API layer (read-only on iOS; no create/modify/delete floor plan APIs exist in the iOS app)
- Migration grace period handling on iOS (backend resolves this into standard phases)

## Decisions

### Decision 1: Reuse the `canAccess` + `FeaturePromotionView` pattern for xLite gating

**Approach:** Add a `case .floorPlan` branch in `FeatureToggle.canAccess(for:)` that returns `false` when `myOrganizationIsFreePlan` is true. In `FloorPlanTabView`, wrap content in an `if featureToggle.canAccess(for: .floorPlan)` / `else` block showing a `FloorPlanFeaturePromotionView`, identical to how `ArchiveTabView` works.

**Why:** This is the exact same pattern used by Archive and AI Hub tabs. No new abstractions needed.

**Alternative considered:** Adding a new FeatureProvider method specific to floor plan. Rejected because the existing three-tier system (`canView`/`canAccess`/`canTrigger`) already handles this cleanly.

**Files affected:**
- `FeatureToggle.swift` — add `case .floorPlan` in `canAccess(for:)`
- `FeatureProvider.swift` / `MockFeatureProvider.swift` — no change needed (canAccess already covers all tabs via default case)
- `FloorPlanTabView.swift` — add promotion view branch
- `FeaturePromotionView.swift` — add `FloorPlanFeaturePromotionView` and `case .floorPlan` in `promotionModel`

### Decision 2: RenewalOverdue lockdown uses existing `canTrigger` mechanism

**Approach:** The existing `canTrigger(for:)` already returns `false` for all tabs except `.view` and `.more` when `myOrganizationLicensePhase == .renewalOverdue`. Floor plan is already covered by the `default` branch. The tab item is already disabled (greyed out) via `.disabled(!featureToggle.canTrigger(for: tab))` in `HomeViewTabItems` and `HomeViewMoreTabSheet`.

**Why:** No code change needed — the existing pattern already handles floor plan correctly.

**Verification needed:** Confirm that `canView(.floorPlan)` still returns `true` during RenewalOverdue (tab stays visible but disabled), which it does since `canView` only checks `supportFeatures`.

### Decision 3: API 423 handling as a generic VortexError mapping

**Approach:** When floor plan APIs return HTTP 423, map it to a `VortexError` case (e.g., `.invalidLicense` or a new `.featureLocked` case). The ViewModel can then catch this error and show an appropriate message. The exact error type from the API response body is TBD (tracked in tasks as a pending API confirmation).

**Why:** The existing error handling infrastructure in `VortexRestfulApi` already converts backend error types to `VortexError`. Adding 423 handling is an extension of this pattern.

**Note:** Since the iOS app is read-only for floor plans (no create/modify/delete APIs), 423 will only be encountered on GET endpoints for xLite organizations. For RenewalOverdue, GET is still allowed per the spec, so 423 should only surface for xLite users calling list/detail APIs. The front-end gating via `canAccess` should prevent these calls in the first place, making 423 handling a safety net rather than the primary enforcement.

### Decision 4: Downgrade checklist uses existing `MissionType` enum

**Approach:** The backend's `postCheckDowngrade()` API returns a list of `CheckDowngradeItem` with a `mission` string. A new `MissionType` case (e.g., `.floorPlan = "FLOOR_PLAN_LIMIT"`) will be added to parse the backend's floor plan checklist item. The `title` and `content` properties on `MissionType` will provide the localized display text.

**Why:** This follows the exact same pattern as all other downgrade prerequisites (archiveLimit, caseVault, sso, etc.). The backend drives which items appear; the iOS app just needs to recognize and display the new type.

**Note:** The exact mission string from the backend is TBD — tracked in tasks as pending API confirmation. The spec mentions the message should be "Delete floor plan data you must manually delete all floor plan" but the actual localization key and final copy need confirmation.

### Decision 5: Live phase transition handling via existing reactive observation

**Approach:** `FeatureToggle` already observes `licensePhaseValues()` as an AsyncStream from `OrganizationDependency`. When the phase changes to RenewalOverdue, `canTrigger(.floorPlan)` becomes `false`, which immediately disables the tab. If the user is already inside `FloorPlanDetailView` (presented via SheetManager), the sheet should be dismissed.

For paid-to-free transition, `myOrganizationIsFreePlan` updates reactively. When it becomes `true`, `canAccess(.floorPlan)` returns `false`, and `FloorPlanTabView` will re-render to show the promotion page. If the user is in the detail sheet, it should be dismissed.

**Implementation approach:** `FloorPlanTabViewModel` will observe `featureProvider.canAccess(for: .floorPlan)` changes. When access is revoked, dismiss any open floor plan detail sheet via `sheetManager.dismiss()`.

**Files affected:**
- `FloorPlanTabViewModel.swift` — add observation for access revocation and dismiss sheet

## Risks / Trade-offs

- **[Risk] Promotion page copy and image not finalized** → Track as TBD task; use placeholder text and existing image pattern. Can be swapped without code changes once finalized.
- **[Risk] API 423 error body format unknown** → Track as TBD task; implement generic handling first, refine once API contract is confirmed.
- **[Risk] Downgrade mission string unknown** → Track as TBD task; add `MissionType` case with placeholder raw value, update when backend confirms.
- **[Trade-off] Front-end gating vs. API enforcement** → Front-end gating prevents unnecessary API calls, but 423 handling provides defense-in-depth. Both are needed.
- **[Trade-off] No iOS-side floor plan data deletion** → The spec says floor plan data should be "permanently eliminated" on paid-to-free transition, but this is a backend operation. The iOS app's role is limited to showing the checklist prerequisite. If the backend doesn't handle deletion, data may persist — but this is a backend concern, not an iOS concern.

## Open Questions

1. **Floor plan promotion page assets** — What image and copy should be used? (Waiting for UI/marketing confirmation)
2. **API 423 error body format** — What is the exact `BackendErrorType` the API returns for 423 on floor plan endpoints? (Waiting for API team confirmation)
3. **Downgrade mission string** — What is the exact `mission` string the backend sends for the floor plan checklist item? (Waiting for API team confirmation)
