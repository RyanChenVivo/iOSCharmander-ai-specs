# Proposal: iOS Implementation - View Tab Expand/Collapse All Toggle

## Why

This proposal implements the View Tab expand/collapse all functionality for the iOS Charmander app, corresponding to the web specification `add-view-page-expand-collapse-toggle`. Users currently need to manually expand or collapse each site group individually on the View Tab, which is time-consuming when managing multiple sites with many devices. A toggle button to expand/collapse all site groups simultaneously will improve user productivity and provide better control over the viewing experience. Additionally, persisting the user's preference ensures a consistent experience across sessions.

## What Changes

### UI Components
- **Control Panel**: Add a control panel at the top of the site list containing:
  - **Site Count Display**: Shows total number of sites in organization (format: "X sites")
  - **Expand/Collapse Toggle Button**: Positioned on the right side of the control panel
- **Conditional Visibility**: Control panel SHALL only be displayed when there are 2 or more sites
  - When site count is 0 or 1, the control panel SHALL be hidden
- **Button Icons**: Use appropriate icons for button states:
  - When sites are expanded: Show "Collapse All" icon (`iconGeneralExpandAllSolid`)
  - When sites are collapsed: Show "Expand All" icon (`iconGeneralCollapseAllSolid`)
- **Button Style**: Use `RoundedIconSmallSecondaryButtonStyle` for consistent styling with individual site disclosure buttons

### State Management
- Create `SiteExpandStateViewModel` with `@Observable` to manage expand/collapse state:
  - `defaultExpanded`: Boolean stored in UserDefaults for global default state
  - `siteExpandStates`: Dictionary tracking per-site expand state overrides
  - `binding(for:)`: Provides Binding for each site, falling back to `defaultExpanded` if not overridden
  - `toggleAll()`: Toggles global default and clears per-site overrides
  - `resetStates()`: Clears per-site overrides when default changes
- Modify `RoundedBackgroundDisclosureGroup` to support external binding for `isExpanded` state
- Use `@Dependency(\.userDefaults)` in ViewModel for UserDefaults access
- Views use `@ObservedObject` to observe DeviceManager directly (no intermediate observation layer)

### User Preference Persistence
- Store user preference (expanded/collapsed state) using iOS UserDefaults via `@AppStorage`
- Default state: expanded (all site groups open) - `true`
- Automatically restore preference on app launch and View Tab navigation
- Preference persists device-locally (no cross-device sync required)

### Performance
- Leverage SwiftUI's built-in lazy loading and animation system
- Handle 50+ site groups efficiently with `withAnimation` wrapper
- Non-blocking preference save operation (UserDefaults async write)

## Impact

**Affected specs:**
- `ios-view-tab-device-management` (NEW) - iOS-specific device expansion/collapse behavior

**Affected code:**
- `VortexFeatures/Sources/VortexFeatures/Common/UserDefaultsDependency/UserDefaultsKey.swift` - Add new key `view_tab_expand_all_sites`
- `iOSCharmander/View/Component/DisclosureGroup/RoundedBackgroundDisclosureGroup.swift` - Support external binding, use new ButtonStyle
- `iOSCharmander/View/Component/ButtonStyle/RoundedIconSmallSecondaryButtonStyle.swift` (NEW) - Unified ButtonStyle for expand/collapse buttons
- `iOSCharmander/View/Home/Tab/ViewTab/SiteView.swift` - Add `SiteExpandStateViewModel`, control panel UI, and per-site bindings
  - `ViewTabSiteView` - Add control panel with site count and toggle button
  - `ViewTabSiteSearchingView` - Use shared ViewModel for search scenarios
  - `SiteExpandStateViewModel` (NEW) - Manage expand state with Dependency Injection

**Technical decisions:**
- Use iOS UserDefaults (via `@Dependency(\.userDefaults)`) instead of web localStorage
  - Rationale: Native iOS persistence mechanism, better performance, Dependency Injection for testability
- Follow existing pattern: `view_tab_list_mode` as reference for UserDefaults key structure
- Use `@Observable` ViewModel (`SiteExpandStateViewModel`) for expand state logic
  - Rationale: Separation of concerns, testable business logic, reusable across ViewTabSiteView and ViewTabSiteSearchingView
- Per-site state management with global default fallback
  - Rationale: Individual site headers should work independently from "expand all" button
- Create unified `RoundedIconSmallSecondaryButtonStyle` for button consistency
  - Rationale: Expand/collapse buttons (both in control panel and individual site headers) should have identical styling
- Control panel conditional visibility based on site count
  - Rationale: Aligns with high-level spec requirement to show control panel only when ≥2 sites exist

**Architecture alignment:**
- MVVM pattern: View-layer state management with ViewModel support via Dependency Injection
- SwiftUI `@Observable` + `@AppStorage` for reactive state updates
- Component reusability: `RoundedBackgroundDisclosureGroup` remains backward compatible

**User experience impact:**
- ✅ Improved efficiency for users managing multiple site groups
- ✅ Consistent viewing experience across app sessions
- ✅ Reduced manual interaction required
- ✅ Seamless integration with existing list/grid toggle functionality

**Backward compatibility:**
- `RoundedBackgroundDisclosureGroup` maintains backward compatibility with new initializer overload
- Default behavior (all expanded) matches current user expectations
- No breaking changes to existing components using `RoundedBackgroundDisclosureGroup`
