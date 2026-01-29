# iOS View Tab Device Management Specification

## ADDED Requirements

### Requirement: Site Count Display

The View Tab SHALL display the total number of sites in the organization at the top of the site list in a control panel.

#### Scenario: Display site count when multiple sites exist

- **GIVEN** the organization has 2 or more sites
- **WHEN** user views the View Tab
- **THEN** the total number of sites is displayed at the top of the site list in the control panel
- **AND** the format shows "X sites" (e.g., "5 sites", "12 sites")
- **AND** the text uses `.callout.color01` text style
- **AND** the text is left-aligned with 16pt leading padding

### Requirement: Control Panel Conditional Visibility

The control panel (containing site count and expand/collapse toggle) SHALL only be displayed when there are 2 or more sites in the organization.

#### Scenario: Hide control panel when no sites exist

- **GIVEN** the organization has 0 sites
- **WHEN** user views the View Tab
- **THEN** the control panel is not displayed
- **AND** `deviceManager.sites.isEmpty` returns true
- **AND** the VStack shows only the site list area

#### Scenario: Hide control panel when only one site exists

- **GIVEN** the organization has exactly 1 site
- **WHEN** user views the View Tab
- **THEN** the control panel is not displayed
- **AND** `deviceManager.sites.count == 1` evaluates to true
- **AND** the single site is displayed normally with its individual disclosure group

#### Scenario: Show control panel when multiple sites exist

- **GIVEN** the organization has 2 or more sites
- **WHEN** user views the View Tab
- **THEN** the control panel is displayed with site count and toggle button
- **AND** both elements are clearly visible within a 44pt height HStack
- **AND** the control panel appears above the site list

### Requirement: Expand/Collapse All Toggle Button

The View Tab SHALL provide a toggle button in the control panel that allows users to expand or collapse all site groups simultaneously.

#### Scenario: Toggle button displays correct icon

- **GIVEN** user is on the View Tab with 2 or more sites
- **WHEN** user views the control panel
- **THEN** the toggle button displays the correct icon based on `viewModel.defaultExpanded`:
  - When `defaultExpanded == true`: Show `iconGeneralExpandAllSolid` (Collapse All state)
  - When `defaultExpanded == false`: Show `iconGeneralCollapseAllSolid` (Expand All state)
- **AND** the button uses `RoundedIconSmallSecondaryButtonStyle`
- **AND** the button has accessibility identifier "expandCollapseAllButton"

#### Scenario: Expand all site groups

- **GIVEN** user is on the View Tab with all site groups collapsed (`defaultExpanded == false`)
- **WHEN** user taps the toggle button
- **THEN** `viewModel.toggleAll()` is called within a `withAnimation` block
- **AND** all site groups expand to show their devices
- **AND** `defaultExpanded` changes to `true`
- **AND** `siteExpandStates` dictionary is cleared via `removeAll()`
- **AND** the toggle button icon changes to show Collapse All state
- **AND** the expansion happens with smooth animation

#### Scenario: Collapse all site groups

- **GIVEN** user is on the View Tab with all site groups expanded (`defaultExpanded == true`)
- **WHEN** user taps the toggle button
- **THEN** `viewModel.toggleAll()` is called within a `withAnimation` block
- **AND** all site groups collapse to hide their devices
- **AND** `defaultExpanded` changes to `false`
- **AND** `siteExpandStates` dictionary is cleared via `removeAll()`
- **AND** the toggle button icon changes to show Expand All state
- **AND** the collapse happens with smooth animation

#### Scenario: Individual site header behavior

- **GIVEN** user is on the View Tab with any global expand/collapse state
- **WHEN** user taps an individual site header disclosure button
- **THEN** only that specific site's expand state changes
- **AND** the site's state is stored in `siteExpandStates[siteId]`
- **AND** other sites remain in their current states
- **AND** the global toggle button state remains unchanged

#### Scenario: Clear per-site overrides when toggling all

- **GIVEN** user has manually expanded/collapsed some individual sites
- **AND** `siteExpandStates` dictionary contains site-specific overrides
- **WHEN** user taps the toggle button
- **THEN** all per-site overrides are cleared via `siteExpandStates.removeAll()`
- **AND** all sites adopt the new global `defaultExpanded` state
- **AND** all sites display in a unified state (all expanded OR all collapsed)

### Requirement: User Preference Persistence

The system SHALL save the user's expand/collapse preference using iOS UserDefaults and restore it when the user launches the app or navigates to the View Tab.

#### Scenario: Save preference on toggle

- **GIVEN** user taps the expand/collapse toggle button
- **WHEN** `viewModel.toggleAll()` executes
- **THEN** the system saves the new state to UserDefaults via `userDefaults.set(newValue, forKey: .view_tab_expand_all_sites)`
- **AND** the save operation happens asynchronously without blocking UI interaction
- **AND** UserDefaults key is `.view_tab_expand_all_sites`

#### Scenario: Restore preference on app launch

- **GIVEN** user has previously set an expand/collapse preference in UserDefaults
- **WHEN** user launches the app and navigates to the View Tab
- **THEN** `SiteExpandStateViewModel` reads the preference via `userDefaults.bool(forKey: .view_tab_expand_all_sites) ?? true`
- **AND** all site groups display in the saved state (expanded or collapsed)
- **AND** the toggle button icon reflects the restored `defaultExpanded` state

#### Scenario: Restore preference on View Tab navigation

- **GIVEN** user has previously set an expand/collapse preference
- **WHEN** user navigates to the View Tab from another tab
- **THEN** the ViewModel's computed property `defaultExpanded` retrieves the value from UserDefaults
- **AND** all site groups display in the saved state
- **AND** the toggle button reflects the restored state

#### Scenario: Default preference when none exists

- **GIVEN** user has never set an expand/collapse preference
- **WHEN** user first navigates to the View Tab
- **THEN** `userDefaults.bool(forKey: .view_tab_expand_all_sites) ?? true` returns `true` (default)
- **AND** all site groups display in the expanded state
- **AND** the toggle button displays the Collapse All icon (`iconGeneralExpandAllSolid`)

#### Scenario: Preference storage mechanism

- **GIVEN** system needs to persist user preference
- **WHEN** saving or retrieving the expand/collapse state
- **THEN** the system uses `@Dependency(\.userDefaults)` for UserDefaults access
- **AND** the storage key is `UserDefaultsKey.view_tab_expand_all_sites`
- **AND** no backend API calls are required
- **AND** preference is isolated per device (iOS device-local storage)

### Requirement: State Management Architecture

The View Tab SHALL use `SiteExpandStateViewModel` with `@Observable` to manage expand/collapse state logic.

#### Scenario: ViewModel manages global default state

- **GIVEN** `SiteExpandStateViewModel` is instantiated with `@State` in ViewTabSiteView
- **WHEN** accessing or modifying the global expand state
- **THEN** the ViewModel's computed property `defaultExpanded` reads from/writes to UserDefaults
- **AND** getting the value: `userDefaults.bool(forKey: .view_tab_expand_all_sites) ?? true`
- **AND** setting the value: `userDefaults.set(newValue, forKey: .view_tab_expand_all_sites)`

#### Scenario: ViewModel provides per-site bindings

- **GIVEN** `ViewTabSiteView` iterates through `deviceManager.sites`
- **WHEN** creating a `RoundedBackgroundDisclosureGroup` for each site
- **THEN** the View calls `viewModel.binding(for: site.id)` to get a Binding<Bool>
- **AND** the binding's getter returns `siteExpandStates[siteId] ?? defaultExpanded`
- **AND** the binding's setter updates `siteExpandStates[siteId] = newValue`
- **AND** this allows individual site headers to maintain independent state

#### Scenario: ViewModel resets per-site states on default change

- **GIVEN** `ViewTabSiteView` observes `viewModel.defaultExpanded` with `.onChange`
- **WHEN** `defaultExpanded` value changes (user toggles all)
- **THEN** the onChange handler calls `viewModel.resetStates()`
- **AND** `resetStates()` executes `siteExpandStates.removeAll()`
- **AND** all sites revert to using the new `defaultExpanded` value
- **AND** SwiftUI updates the UI to reflect the unified state

#### Scenario: View observes DeviceManager directly

- **GIVEN** `ViewTabSiteView` needs to display sites and devices
- **WHEN** DeviceManager's `sites` or devices change
- **THEN** the View uses `@ObservedObject private var deviceManager = DeviceManager.shared`
- **AND** SwiftUI automatically updates the View when DeviceManager publishes changes
- **AND** no intermediate AsyncStream observation layer is used
- **AND** this follows SwiftUI's built-in observation pattern

### Requirement: Unified Button Styling

The expand/collapse buttons (both in control panel and individual site headers) SHALL use a unified `RoundedIconSmallSecondaryButtonStyle`.

#### Scenario: Control panel toggle button styling

- **GIVEN** control panel displays the expand/collapse toggle button
- **WHEN** rendering the button
- **THEN** the button uses `.buttonStyle(.roundedIconSmallSecondary)`
- **AND** the label contains an `Image` with `.resizable()` modifier
- **AND** the image is sized to 24x24pt within the ButtonStyle
- **AND** the button has 10pt padding around the icon
- **AND** the button has a 4pt corner radius
- **AND** background color is `.colorSurface03` (or `.colorSurface04` when pressed)

#### Scenario: Individual site disclosure button styling

- **GIVEN** `RoundedBackgroundDisclosureGroup` displays a disclosure button
- **WHEN** rendering the button in `RoundedBackgroundDisclosureGroupStyle`
- **THEN** the button uses `.buttonStyle(.roundedIconSmallSecondary)`
- **AND** the label contains an Image showing arrow up/down icon
- **AND** the styling matches the control panel toggle button exactly
- **AND** both buttons have consistent visual appearance and interaction behavior

### Requirement: Search View Integration

The ViewTabSiteSearchingView SHALL use the same `SiteExpandStateViewModel` to manage expand/collapse state during search.

#### Scenario: Search view with expand state

- **GIVEN** user is searching in the View Tab
- **WHEN** `ViewTabSiteSearchingView` displays filtered sites
- **THEN** the View instantiates its own `@State private var viewModel = SiteExpandStateViewModel()`
- **AND** filtered sites with devices use `RoundedBackgroundDisclosureGroup(isExpanded: viewModel.binding(for: site.id))`
- **AND** the expand state persists across search queries
- **AND** the View observes `viewModel.defaultExpanded` with `.onChange` to reset per-site states

### Requirement: Performance

The expand/collapse all operation SHALL perform efficiently even with large numbers of site groups and devices.

#### Scenario: Handle many site groups efficiently

- **GIVEN** View Tab displays 50 or more site groups
- **WHEN** user taps expand all or collapse all
- **THEN** SwiftUI's `withAnimation` wrapper provides optimized batch updates
- **AND** the operation completes smoothly without noticeable lag
- **AND** the UI remains responsive during the operation
- **AND** `FlexibleVGrid` handles lazy loading of devices automatically

#### Scenario: Non-blocking preference save

- **GIVEN** user taps the toggle button
- **WHEN** the preference save operation executes via `userDefaults.set()`
- **THEN** UserDefaults writes asynchronously to disk
- **AND** the UI remains responsive and interactive immediately
- **AND** subsequent toggle taps are processed correctly without waiting for previous saves
- **AND** no explicit async/await handling is required (UserDefaults handles this internally)

### Requirement: Accessibility

The expand/collapse toggle button SHALL be accessible and identifiable for UI testing.

#### Scenario: Accessibility identifier for toggle button

- **GIVEN** control panel displays the expand/collapse toggle button
- **WHEN** UI tests or accessibility tools query the button
- **THEN** the button has `.accessibilityIdentifier("expandCollapseAllButton")`
- **AND** UI tests can reliably find and interact with the button using this identifier

#### Scenario: Individual site group accessibility

- **GIVEN** `RoundedBackgroundDisclosureGroup` displays a site group
- **WHEN** rendering the site row
- **THEN** the label has `.accessibilityIdentifier("groupRow\(site.name)")`
- **AND** UI tests can identify and interact with individual site groups
