# Floor Plan License Control — Tasks

## 1. Feature Toggle: xLite Access Gating

- [x] 1.1 Add `case .floorPlan` in `FeatureToggle.canAccess(for:)` returning `!myOrganizationIsFreePlan` (`FeatureToggle.swift`)
- [x] 1.2 Verify `canTrigger(for: .floorPlan)` already returns `false` during RenewalOverdue via existing `default` branch — no code change needed, add unit test to lock behavior
- [x] 1.3 Verify `canView(for: .floorPlan)` still returns `true` during RenewalOverdue (tab visible but disabled) — add unit test

## 2. Commercial Promotion Page

- [x] 2.1 Create `FloorPlanFeaturePromotionView` in `FeaturePromotionView.swift` following the `ArchiveFeaturePromotionView` pattern (placeholder copy and image for now)
- [x] ~~2.2 Add `case .floorPlan` in `HomeViewTab.promotionModel`~~ — removed; data lives directly in `FloorPlanFeaturePromotionView`, `HomeViewTab.promotionModel` extension removed (unused)
- [x] 2.3 Wrap `FloorPlanTabView` body in `if featureToggle.canAccess(for: .floorPlan)` / `else` branch showing `FloorPlanFeaturePromotionView`, following `ArchiveTabView` pattern
- [x] 2.4 Add localization keys for floor plan promotion page title and description in `Localizable.xcstrings`

## 3. Live Phase Transition Handling

- [x] 3.1 ~~In `FloorPlanTabViewModel`, add observation for `featureProvider.canAccess(for: .floorPlan)` change~~ — not needed; `HomeViewModel.handleOrganizationStateChanged` already calls `SheetManager.shared.dismissAll()` + `switchOrganization()` on both `isFreePlan` change and `licensePhase == .renewalOverdue`, covering all license transition scenarios
- [x] 3.2 Verify SwiftUI re-renders `FloorPlanTabView` automatically when `canAccess` changes (existing `@State featureProvider = FeatureToggle.shared` is already reactive)

## 4. Downgrade Checklist

- [x] 4.1 Add `MissionType.floorPlan` case with placeholder raw value (e.g., `"FLOOR_PLAN_LIMIT"`) in `DowngradeProgressViewModel.swift`
- [x] 4.2 Add `title` and `content` localized strings for `MissionType.floorPlan` — final copy confirmed by PM: "Delete floor plans" / "You must delete all floor plan data before downgrading."
- [x] 4.3 Add localization keys in `Localizable.xcstrings` for floor plan downgrade mission

## 5. ~~API 423 Error Handling~~ — Not Applicable

- [x] ~~5.1 Add 423 status code mapping~~ — not needed; per high-level spec, 423 only applies to create/modify APIs during RenewalOverdue. iOS only calls GET endpoints (always 200). xLite also gets 200 on all APIs.
- [x] ~~5.2 Ensure ViewModels handle 423 gracefully~~ — not needed; existing `appManager.handleError` covers unexpected HTTP errors as a safety net

## 6. Unit Tests

- [x] 6.1 Test `canAccess(for: .floorPlan)` returns `false` when `myOrganizationIsFreePlan == true`
- [x] 6.2 Test `canAccess(for: .floorPlan)` returns `true` when `myOrganizationIsFreePlan == false`
- [x] 6.3 Test `canTrigger(for: .floorPlan)` returns `false` when `myOrganizationLicensePhase == .renewalOverdue`
- [x] 6.4 Test `canTrigger(for: .floorPlan)` returns `true` for Valid, NoticePeriod, GracePeriod phases
- [x] 6.5 Test `MissionType.floorPlan` parses correctly from `CheckDowngradeItem`
- [x] ~~6.6 Test `HomeViewTab.floorPlan.promotionModel`~~ — removed with the extension

## 7. Pending External Confirmation (blocked)

- [x] 7.1 ~~**[Waiting for API team]** Confirm 423 BackendErrorType~~ — resolved: 423 not applicable to iOS (read-only GET endpoints). Downgrade mission string `"FLOOR_PLAN_LIMIT"` confirmed by API team and already matches `MissionType.floorPlan` raw value
- [x] 7.2a Background image asset added as `img_floorplan_sample` imageset (light/dark × 1x/2x/3x), `FloorPlanFeaturePromotionView` updated to use `.imgFloorplanSample`
- [x] 7.2b Floor plan promotion page copy confirmed by UI/Marketing. Updated `FloorPlanFeaturePromotionView` to use `Floor_plan_promotion_description` key; `Localizable.xcstrings` updated with final copy
