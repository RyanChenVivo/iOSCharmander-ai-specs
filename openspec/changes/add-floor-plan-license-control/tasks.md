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

- [x] 3.1 In `FloorPlanTabViewModel`, add observation for `featureProvider.canAccess(for: .floorPlan)` change — when access is revoked, call `sheetManager.dismiss()` to close any open floor plan detail sheet
- [x] 3.2 Verify SwiftUI re-renders `FloorPlanTabView` automatically when `canAccess` changes (existing `@State featureProvider = FeatureToggle.shared` is already reactive)

## 4. Downgrade Checklist

- [x] 4.1 Add `MissionType.floorPlan` case with placeholder raw value (e.g., `"FLOOR_PLAN_LIMIT"`) in `DowngradeProgressViewModel.swift`
- [x] 4.2 Add `title` and `content` localized strings for `MissionType.floorPlan` — placeholder copy based on spec: "Delete floor plan data" / "You must manually delete all floor plan data"
- [x] 4.3 Add localization keys in `Localizable.xcstrings` for floor plan downgrade mission

## 5. API 423 Error Handling

- [x] 5.1 Add 423 status code mapping in `VortexRestfulApi` error handling (map to `VortexError.invalidLicense` or new `.featureLocked` — depends on API confirmation)
- [x] 5.2 Ensure `FloorPlanTabViewModel` and `FloorPlanDetailViewModel` handle this error gracefully (show message, don't crash)

## 6. Unit Tests

- [x] 6.1 Test `canAccess(for: .floorPlan)` returns `false` when `myOrganizationIsFreePlan == true`
- [x] 6.2 Test `canAccess(for: .floorPlan)` returns `true` when `myOrganizationIsFreePlan == false`
- [x] 6.3 Test `canTrigger(for: .floorPlan)` returns `false` when `myOrganizationLicensePhase == .renewalOverdue`
- [x] 6.4 Test `canTrigger(for: .floorPlan)` returns `true` for Valid, NoticePeriod, GracePeriod phases
- [x] 6.5 Test `MissionType.floorPlan` parses correctly from `CheckDowngradeItem`
- [x] ~~6.6 Test `HomeViewTab.floorPlan.promotionModel`~~ — removed with the extension

## 7. Pending External Confirmation (blocked)

- [ ] 7.1 **[Waiting for API team]** Confirm the `BackendErrorType` value returned by API for HTTP 423 on floor plan endpoints; confirm license check behavior per endpoint; confirm the downgrade checklist `mission` string (e.g., `"FLOOR_PLAN_LIMIT"`) — once confirmed, update 5.1 error mapping and 4.1 raw value
- [x] 7.2a Background image asset added as `img_floorplan_sample` imageset (light/dark × 1x/2x/3x), `FloorPlanFeaturePromotionView` updated to use `.imgFloorplanSample`
- [ ] 7.2b **[Waiting for UI/Marketing]** Confirm final floor plan promotion page copy (title, description, CTA) — once confirmed, update placeholder text in `FloorPlanFeaturePromotionView` and `Localizable.xcstrings`
