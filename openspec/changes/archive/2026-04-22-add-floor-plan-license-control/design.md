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

### Decision 3: API 423 handling — not applicable to iOS

**Conclusion:** After reviewing the high-level spec's API enforcement matrix, HTTP 423 is only returned for create/modify operations (POST/PATCH) during RenewalOverdue. The iOS app is read-only for floor plans — it only calls GET endpoints (list floor plans, get device positions), which always return 200 regardless of license phase. xLite organizations also receive 200 on all floor plan APIs; access gating is handled entirely at the frontend via `canAccess(for: .floorPlan)`.

**Decision:** No dedicated 423 error mapping or handling is needed. The existing generic error handling in `appManager.handleError` is sufficient as a safety net for any unexpected HTTP errors.

### Decision 4: Downgrade checklist uses existing `MissionType` enum

**Approach:** The backend's `postCheckDowngrade()` API returns a list of `CheckDowngradeItem` with a `mission` string. A new `MissionType` case (e.g., `.floorPlan = "FLOOR_PLAN_LIMIT"`) will be added to parse the backend's floor plan checklist item. The `title` and `content` properties on `MissionType` will provide the localized display text.

**Why:** This follows the exact same pattern as all other downgrade prerequisites (archiveLimit, caseVault, sso, etc.). The backend drives which items appear; the iOS app just needs to recognize and display the new type.

**Confirmed:** Backend mission string is `"FLOOR_PLAN_LIMIT"`. Display copy — title: "Delete floor plans", content: "You must delete all floor plan data before downgrading."

### Decision 5: Live phase transition handling via existing reactive observation

**Approach:** `FeatureToggle` already observes `licensePhaseValues()` as an AsyncStream from `OrganizationDependency`. When the phase changes to RenewalOverdue, `canTrigger(.floorPlan)` becomes `false`, which immediately disables the tab. If the user is already inside `FloorPlanDetailView` (presented via SheetManager), the sheet should be dismissed.

For paid-to-free transition, `myOrganizationIsFreePlan` updates reactively. When it becomes `true`, `canAccess(.floorPlan)` returns `false`, and `FloorPlanTabView` will re-render to show the promotion page. If the user is in the detail sheet, it should be dismissed.

**Implementation approach:** `FloorPlanTabViewModel` will observe `featureProvider.canAccess(for: .floorPlan)` changes. When access is revoked, dismiss any open floor plan detail sheet via `sheetManager.dismiss()`.

**Files affected:**
- `FloorPlanTabViewModel.swift` — add observation for access revocation and dismiss sheet

## Risks / Trade-offs

- **[Risk] Promotion page copy and image not finalized** → Track as TBD task; use placeholder text and existing image pattern. Can be swapped without code changes once finalized.
- ~~**[Risk] API 423 error body format unknown**~~ → Resolved: iOS app only calls GET endpoints which always return 200; 423 is only for create/modify during RenewalOverdue. No iOS-side handling needed.
- **[Risk] Downgrade mission string unknown** → Track as TBD task; add `MissionType` case with placeholder raw value, update when backend confirms.
- **[Trade-off] Front-end gating vs. API enforcement** → Front-end `canAccess` gating is the sole enforcement mechanism on iOS. API-side 423 only applies to create/modify endpoints which iOS does not call.
- **[Trade-off] No iOS-side floor plan data deletion** → The spec says floor plan data should be "permanently eliminated" on paid-to-free transition, but this is a backend operation. The iOS app's role is limited to showing the checklist prerequisite. If the backend doesn't handle deletion, data may persist — but this is a backend concern, not an iOS concern.

## Open Questions

1. ~~**Floor plan promotion page assets**~~ — Resolved: image asset `img_floorplan_sample` added; copy confirmed: "See the entire property at a glance. VORTEX Floor Plan turns building layouts into interactive security maps..."
2. ~~**API 423 error body format**~~ — Resolved: not applicable to iOS. 423 only applies to create/modify endpoints during RenewalOverdue; iOS only calls GET endpoints.
3. ~~**Downgrade mission string**~~ — Resolved: `"FLOOR_PLAN_LIMIT"` confirmed by API team. Display copy confirmed by PM: "Delete floor plans" / "You must delete all floor plan data before downgrading."
