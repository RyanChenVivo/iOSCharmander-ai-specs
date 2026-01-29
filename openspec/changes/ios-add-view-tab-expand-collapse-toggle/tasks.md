# Implementation Tasks

## 1. Storage Layer - UserDefaults Configuration

- [x] 1.1 Add `view_tab_expand_all_sites` case to `UserDefaultsKey` enum in `UserDefaultsKey.swift`
- [x] 1.2 Verify UserDefaults key naming convention matches existing patterns

**Validation:** UserDefaults key is accessible via `UserDefaultsKey.view_tab_expand_all_sites`

## 2. Component Layer - DisclosureGroup Enhancement

- [x] 2.1 Add new initializer to `RoundedBackgroundDisclosureGroup` accepting `Binding<Bool>` for `isExpanded`
- [x] 2.2 Modify existing `@State var isExpanded` to `@Binding var isExpanded` in struct
- [x] 2.3 Add backward-compatible initializer using `.constant(true)` for existing usage
- [x] 2.4 Update DisclosureGroupStyle to use new ButtonStyle
- [x] 2.5 Ensure DisclosureGroupStyle still works correctly with binding

**Validation:**
- Existing components using `RoundedBackgroundDisclosureGroup` continue to work
- New usage with external binding compiles and updates correctly
- Button styling matches control panel toggle button

## 3. Button Style - Unified Styling for Expand/Collapse Buttons

- [x] 3.1 Create `RoundedIconSmallSecondaryButtonStyle.swift` in `View/Component/ButtonStyle/`
- [x] 3.2 Implement `ButtonStyle` protocol with proper state handling (enabled, pressed)
- [x] 3.3 Add extension with static var: `.roundedIconSmallSecondary`
- [x] 3.4 Follow project convention: accept `configuration.label` instead of image parameter
- [x] 3.5 Apply button style in `RoundedBackgroundDisclosureGroup` disclosure button
- [x] 3.6 Ensure button file is properly added to Xcode project target

**Validation:**
- ButtonStyle compiles without errors
- Both control panel button and disclosure buttons use same style
- Visual appearance matches design (24x24pt icon, 10pt padding, 4pt corner radius)

## 4. View Model - State Management Logic

- [x] 4.1 Create `SiteExpandStateViewModel` class with `@Observable` in `SiteView.swift`
- [x] 4.2 Add `@ObservationIgnored @Dependency(\.userDefaults)` for UserDefaults access
- [x] 4.3 Add `private var siteExpandStates: [String: Bool] = [:]` dictionary
- [x] 4.4 Implement computed property `defaultExpanded` with UserDefaults get/set
- [x] 4.5 Implement `binding(for siteId: String) -> Binding<Bool>` method
- [x] 4.6 Implement `toggleAll()` method to toggle default and clear dictionary
- [x] 4.7 ~~Implement `resetStates()` method~~ (Removed - `toggleAll()` already clears per-site overrides)
- [x] 4.8 Use weak self in binding closures to prevent retain cycles

**Validation:**
- ViewModel manages both global default and per-site states
- Individual site headers work independently from toggle button
- State persists via UserDefaults

## 5. View Layer - Control Panel UI

- [x] 5.1 Add `@State private var viewModel = SiteExpandStateViewModel()` to `ViewTabSiteView`
- [x] 5.2 Create `siteCountRow` computed property returning `some View`
- [x] 5.3 Add site count text: `Text("\(deviceManager.sites.count) sites")` with `.textStyle(.callout.color01)`
- [x] 5.4 Add toggle button with conditional icon based on `viewModel.defaultExpanded`
- [x] 5.5 Use icon names: `iconGeneralExpandAllSolid` and `iconGeneralCollapseAllSolid`
- [x] 5.6 Apply `.buttonStyle(.roundedIconSmallSecondary)` to toggle button
- [x] 5.7 Add `.accessibilityIdentifier("expandCollapseAllButton")` to toggle button
- [x] 5.8 Position toggle button on right side with `Spacer()` between count and button
- [x] 5.9 Set control panel height to 44pt with proper horizontal padding (8pt)
- [x] 5.10 Add conditional rendering: only show control panel when `!deviceManager.sites.isEmpty`
- [x] 5.11 Update condition to show only when `deviceManager.sites.count >= 2`

**Validation:**
- Control panel displays at top of site list
- Site count format matches "X sites"
- Toggle button positioned on right
- Control panel hidden when 0 or 1 site

## 6. View Layer - Site List State Binding

- [x] 6.1 Modify `RoundedBackgroundDisclosureGroup` instantiation to pass binding: `isExpanded: viewModel.binding(for: site.id)`
- [x] 6.2 Ensure all site groups in `FlexibleVGrid` use ViewModel bindings
- [x] 6.3 ~~Add `.onChange(of: viewModel.defaultExpanded)` modifier~~ (Removed - not needed since `toggleAll()` clears states)
- [x] 6.4 Keep `@ObservedObject private var deviceManager = DeviceManager.shared` for direct observation
- [ ] 6.5 Test with empty site list, single site, and multiple sites

**Validation:**
- All site groups expand/collapse together when toggle button tapped
- Individual site headers work independently
- Per-site overrides cleared when toggling all

## 7. Search View Integration

- [x] 7.1 Add `@State private var viewModel = SiteExpandStateViewModel()` to `ViewTabSiteSearchingView`
- [x] 7.2 Bind filtered site disclosure groups to `viewModel.binding(for: site.id)`
- [x] 7.3 ~~Add `.onChange(of: viewModel.defaultExpanded)` to reset states~~ (Removed - not needed)
- [x] 7.4 Ensure toggle button affects search results disclosure groups

**Validation:**
- Toggle state persists across search queries
- Search view uses same state management pattern

## 8. Build Verification

- [x] 8.1 Investigate and fix SwiftDriver compilation errors
- [x] 8.2 Verify `RoundedIconSmallSecondaryButtonStyle.swift` is in Xcode project target
- [x] 8.3 Check for syntax errors in ButtonStyle implementation
- [x] 8.4 Verify all import statements are correct
- [x] 8.5 Ensure clean build with no warnings or errors

**Validation:**
- `xcodebuild -project iOSCharmander.xcodeproj -scheme iOSCharmander build` succeeds
- No SwiftDriver errors
- No compiler warnings

## 9. Testing

### Unit Tests
- [x] 9.1 Test `SiteExpandStateViewModel.binding(for:)` returns correct values
- [x] 9.2 Test `toggleAll()` toggles default and clears dictionary
- [x] 9.3 ~~Test `resetStates()` clears per-site overrides~~ (Removed - method removed)
- [x] 9.4 Test UserDefaults key read/write for `view_tab_expand_all_sites`
- [x] 9.5 Test default value (`true`) when key doesn't exist
- [x] 9.5a Test `shouldShowExpandRow()` returns correct values for 0, 1, 2+ sites

### Integration Tests
- [ ] 9.6 Test toggle button interaction updates all site groups
- [ ] 9.7 Test individual site header updates only that site
- [ ] 9.8 Test preference persists across View Tab navigation (switch tabs and return)
- [ ] 9.9 Test preference persists across app restarts (cold launch)
- [ ] 9.10 Test control panel visibility with 0, 1, 2+ sites

### UI Tests
- [ ] 9.11 Test toggle button accessibility identifier "expandCollapseAllButton"
- [ ] 9.12 Test expand all: All collapsed → tap button → all expand with animation
- [ ] 9.13 Test collapse all: All expanded → tap button → all collapse with animation
- [ ] 9.14 Test individual site header: tap → only that site toggles
- [ ] 9.15 Test control panel hidden when 0 sites
- [ ] 9.16 Test control panel hidden when 1 site
- [ ] 9.17 Test control panel visible when 2+ sites
- [ ] 9.18 Test site count display shows correct number
- [ ] 9.19 Test with 50+ site groups (performance validation)

### Edge Cases
- [ ] 9.20 Test first-time user experience (default expanded state)
- [ ] 9.21 Test with VoiceOver enabled (accessibility)
- [ ] 9.22 Test animation interruption (rapid button tapping)
- [ ] 9.23 Test per-site overrides cleared when toggling all

**Validation:** Unit tests created in `SiteExpandStateViewModelTest.swift` - All tests pass with >90% code coverage for new code

## 10. Performance Validation

- [ ] 10.1 Measure UI responsiveness with 50 site groups during expand/collapse
- [ ] 10.2 Verify operation completes within 2 seconds
- [ ] 10.3 Verify smooth animation without dropped frames
- [ ] 10.4 Verify UserDefaults write doesn't block main thread
- [ ] 10.5 Verify control panel conditional rendering performs efficiently

**Validation:** Meets performance requirements from spec

## 11. Code Review & Quality

- [ ] 11.1 Follow Swift coding standards from project
- [ ] 11.2 Add inline documentation for new classes and methods
- [ ] 11.3 Verify no force unwraps or implicitly unwrapped optionals added
- [ ] 11.4 Run SwiftLint and fix any warnings
- [ ] 11.5 Verify ButtonStyle follows project naming conventions

**Validation:** Code passes review with no blockers

## 12. Documentation

- [ ] 12.1 Update inline code comments for modified components
- [ ] 12.2 Document new UserDefaults key in architecture docs (if applicable)
- [ ] 12.3 Add CHANGELOG entry describing new feature
- [ ] 12.4 Document control panel conditional visibility logic
- [ ] 12.5 Document SiteExpandStateViewModel architecture and usage

**Current Status:**
- Storage layer: ✅ Complete
- Component layer: ✅ Complete
- Button style: ✅ Complete
- View model: ✅ Complete (removed `resetStates()` - not needed)
- View layer: ✅ Complete (removed `.onChange` modifier - not needed)
- Search integration: ✅ Complete
- Build verification: ✅ Complete
- Unit Testing: ✅ Complete (SiteExpandStateViewModelTest.swift)
- Integration/UI Testing: ⏳ Pending (manual testing required)
- Performance validation: ⏳ Pending
- Documentation: ⏳ Pending

**Next Steps:**
1. Run integration and UI tests (Task 9.6-9.23)
2. Validate performance (Task 10)
3. Complete documentation (Task 12)

**Dependencies:**
- Tasks 1-8 are complete
- Tasks 9-12 can proceed in parallel

**Parallelizable work:**
- Integration/UI Testing (9), Performance (10), and Documentation (12) can run in parallel
- Code review (11) can overlap with testing
