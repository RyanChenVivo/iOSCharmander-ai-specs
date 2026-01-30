# Implementation Tasks

## 1. ViewModel - State Management

- [x] 1.1 Create `SiteExpandStateViewModel` (`@Observable`)
- [x] 1.2 Add `allSiteExpanded: Bool` property (default `true`)
- [x] 1.3 Add `siteExpandStates: [String: Bool]` dictionary to store individual site states (`private(set)`)
- [x] 1.4 Implement `binding(for siteId: String) -> Binding<Bool>` method
- [x] 1.5 Implement `toggleAll()` method to toggle all site states
- [x] 1.6 Implement `checkAllSiteStatus()` to auto-sync `allSiteExpanded` state
- [x] 1.7 Add `shouldShowControlPanel` computed property
- [x] 1.8 Use `@Dependency(\.deviceManager)` for dependency injection
- [x] 1.9 Add `make()` factory method

**Verification:** ✅ ViewModel correctly tracks all site expand states

## 2. Component Layer - DisclosureGroup Enhancement

- [x] 2.1 Modify `RoundedBackgroundDisclosureGroup` to support `Binding<Bool>` parameter
- [x] 2.2 Maintain backward-compatible initializer
- [x] 2.3 Apply `roundedIconSmallSecondary` button style

**Verification:** ✅ Existing usages of `RoundedBackgroundDisclosureGroup` are unaffected

## 3. Button Style

- [x] 3.1 Create `RoundedIconSmallSecondaryButtonStyle`
- [x] 3.2 Implement button visual style (24x24pt icon, 10pt padding, 4pt corner radius)

**Verification:** ✅ Button style matches design spec

## 4. View Layer - Control Panel

- [x] 4.1 Add `@State private var viewModel` to `ViewTabSiteView`
- [x] 4.2 Add control panel View (site count + toggle button)
- [x] 4.3 Implement site count text (localization + singular/plural handling)
- [x] 4.4 Implement button icon logic (based on `allSiteExpanded` state)
- [x] 4.5 Control panel only visible when `shouldShowControlPanel` is true
- [x] 4.6 Bind each site's `RoundedBackgroundDisclosureGroup` to ViewModel
- [x] 4.7 Unify spacing between control panel and site rows

**Verification:** ✅ Control panel displays correctly, button icon changes with site states

## 5. Localization

- [x] 5.1 Add `%lld_sites` to Localizable.xcstrings
- [x] 5.2 Support English (singular/plural), Japanese, Chinese

**Verification:** ✅ Localization displays correctly

## 6. Tests

- [x] 6.1 Unit test: ViewModel state management logic
- [x] 6.2 Unit test: `shouldShowControlPanel` condition
- [x] 6.3 Unit test: `checkAllSiteStatus()` auto-sync logic
- [x] 6.4 Use `MockDeviceManager` for dependency injection in tests

**Verification:** ✅ 11 tests all passed

## Completed Files

| File | Change Type |
|------|-------------|
| `SiteExpandStateViewModel.swift` | New |
| `SiteView.swift` | Modified - `ViewTabSiteView` control panel |
| `RoundedBackgroundDisclosureGroup.swift` | Modified - Support external `Binding<Bool>` + button style |
| `RoundedIconSmallSecondaryButtonStyle.swift` | New |
| `Localizable.xcstrings` | Modified - Add `%lld_sites` |
| `SiteExpandStateViewModelTest.swift` | New |
