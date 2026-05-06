## CHANGE Capability: site-selection-configuration

Refactor SiteSelectionView to use a Configuration struct for UX presentation control, unify single-select to tap-to-confirm behavior, and replace SitePickerSheet with SiteSelectionView.

### Requirement: SiteSelectionConfiguration struct

A `SiteSelectionConfiguration` struct SHALL be introduced to control UX presentation. The ViewModel SHALL use config values intersected with runtime permissions to expose computed properties.

#### Scenario: Configuration properties
- **GIVEN** `SiteSelectionConfiguration` is defined
- **THEN** it SHALL contain the following properties:
  - `navigationTitle: LocalizedStringKey` (default: `"Site"`)
  - `showCreateSite: Bool` (default: `true`)
  - `showContextMenu: Bool` (default: `true`)
  - `showToggleAll: Bool` (default: `false`)
  - `showSaveButton: Bool` (default: `false`)
  - `allowEmptySelection: Bool` (default: `false`)
  - `presentation: SiteSelectionPresentation` (default: `.push`)

#### Scenario: Presentation enum
- **GIVEN** `SiteSelectionPresentation` is defined
- **THEN** it SHALL have cases:
  - `.push` — View is inside an existing NavigationStack; dismiss uses `@Environment(\.dismiss)`
  - `.sheet` — View wraps itself in NavigationStack + ToolbarItemCancel; dismiss uses `SheetManager.shared.dismiss()`

#### Scenario: Preset factory methods
- **GIVEN** `SiteSelectionConfiguration` extension
- **THEN** it SHALL provide:
  - `.default` — full-featured (showCreateSite, showContextMenu, push)
  - `.picker(title:)` — minimal picker (no createSite, no contextMenu, sheet presentation)
  - `.multiSelect(allowEmpty:)` — checkbox mode (showToggleAll, showSaveButton, push)

### Requirement: ViewModel uses config + permission intersection

SiteSelectionViewModel computed properties SHALL combine config flags with runtime permission checks.

#### Scenario: canCreateSite
- **WHEN** `config.showCreateSite == true` AND `featureProvider.canCreateSite() == true`
- **THEN** `canCreateSite` SHALL return `true`
- **OTHERWISE** it SHALL return `false`

#### Scenario: canEditSite
- **WHEN** `config.showContextMenu == true` AND `featureProvider.canEditSite() == true`
- **THEN** `canEditSite` SHALL return `true`
- **OTHERWISE** it SHALL return `false`

#### Scenario: canDeleteSite
- **WHEN** `config.showContextMenu == true` AND `featureProvider.canDelete(for: site) == true`
- **THEN** `canDeleteSite(_:)` SHALL return `true`
- **OTHERWISE** it SHALL return `false`

#### Scenario: canSave
- **WHEN** `config.showSaveButton == false`
- **THEN** `canSave` SHALL return `false`
- **WHEN** `config.showSaveButton == true` AND mode is multi
- **THEN** `canSave` SHALL return `true` if `!selectedSites.isEmpty || config.allowEmptySelection`

### Requirement: Single-select is tap-to-confirm

In single mode, tapping a site row SHALL immediately confirm the selection and dismiss the view. No Save button SHALL be displayed.

#### Scenario: Tap row in single mode
- **WHEN** user taps a site row in single mode
- **THEN** `selectedSiteID` SHALL be updated to the tapped site's ID
- **AND** the binding SHALL be written back immediately
- **AND** the view SHALL dismiss (via presentation-appropriate method)

#### Scenario: No Save button in single mode
- **WHEN** mode is single
- **THEN** the Save toolbar button SHALL NOT be displayed (config.showSaveButton = false)

#### Scenario: Dismiss method depends on presentation
- **WHEN** `config.presentation == .push`
- **THEN** dismiss SHALL use `@Environment(\.dismiss)` (pops one level)
- **WHEN** `config.presentation == .sheet`
- **THEN** dismiss SHALL use `SheetManager.shared.dismiss()`

### Requirement: View uses config for presentation, mode for data

The View SHALL use `mode` to determine row type and data write-back, and ViewModel config-derived computed properties for all other UX decisions.

#### Scenario: Row rendering by mode
- **WHEN** mode is single
- **THEN** `SiteTreeRow` SHALL be rendered (tap-to-confirm)
- **WHEN** mode is multi
- **THEN** `SiteCheckboxTreeRow` SHALL be rendered (tap toggles checkbox)

#### Scenario: NavigationStack wrapping by presentation
- **WHEN** `config.presentation == .sheet`
- **THEN** SiteSelectionView SHALL wrap its content in `NavigationStack` with `ToolbarItemCancel()`
- **WHEN** `config.presentation == .push`
- **THEN** SiteSelectionView SHALL NOT wrap content in NavigationStack (external stack provides it)

#### Scenario: ControlBar visibility
- **WHEN** `viewModel.canCreateSite == true`
- **THEN** "Create site or area" button SHALL be displayed
- **WHEN** `viewModel.config.showToggleAll == true`
- **THEN** ToggleAllSectionHeader SHALL be displayed

### Requirement: SheetManager.showSitePicker uses SiteSelectionView

`SheetManager.showSitePicker` SHALL present `SiteSelectionView` with `.picker(title:)` configuration instead of `SitePickerSheet`.

#### Scenario: showSitePicker implementation
- **WHEN** `showSitePicker(selectedSiteID:navigationTitle:)` is called
- **THEN** it SHALL present `SiteSelectionView(selectedSiteID: binding, config: .picker(title: navigationTitle))`
- **AND** the presented view SHALL have no "Create site or area" button
- **AND** the presented view SHALL have no context menu on rows
- **AND** tapping a row SHALL confirm selection and dismiss the sheet

#### Scenario: SiteInformationView caller update
- **WHEN** `SiteInformationView` needs to pick a parent site
- **THEN** it SHALL call `SheetManager.shared.showSitePicker(selectedSiteID:navigationTitle:)` with binding converted to `String?`

### Requirement: Delete SitePickerSheet

`SitePickerSheet` struct SHALL be removed from `SiteInformationView.swift` as it is fully replaced by `SiteSelectionView` with picker configuration.

#### Scenario: SitePickerSheet removed
- **WHEN** all callers are migrated to SiteSelectionView
- **THEN** `struct SitePickerSheet` SHALL be deleted
- **AND** no reference to `SitePickerSheet` SHALL remain in the codebase

### Requirement: SiteSelectionView init signatures

SiteSelectionView SHALL provide init signatures that accept optional configuration.

#### Scenario: Single mode init
- **GIVEN** single mode usage
- **THEN** init SHALL be: `init(selectedSiteID: Binding<String?>, config: SiteSelectionConfiguration = .default)`

#### Scenario: Multi mode init
- **GIVEN** multi mode usage
- **THEN** init SHALL be: `init(selectedSites: Binding<[SiteItem]>, items: [SiteItem], config: SiteSelectionConfiguration = .multiSelect())`

### Requirement: SiteSelectionMode simplification

`SiteSelectionMode` SHALL be simplified by moving `allowEmptySelection` to `SiteSelectionConfiguration`.

#### Scenario: Mode enum cases
- **GIVEN** `SiteSelectionMode` is refactored
- **THEN** it SHALL have:
  - `.single(Binding<String?>)`
  - `.multi(Binding<[SiteItem]>, items: [SiteItem])`
- **AND** `allowEmptySelection` SHALL be read from `config.allowEmptySelection`

### Requirement: confirmAndDismiss unified exit

A single `confirmAndDismiss()` method in the View SHALL handle both single-tap and multi-save confirm flows.

#### Scenario: Single mode confirm
- **WHEN** `confirmAndDismiss()` is called in single mode
- **THEN** it SHALL write `selectedSiteID` back to the binding
- **AND** dismiss based on `config.presentation`

#### Scenario: Multi mode confirm
- **WHEN** `confirmAndDismiss()` is called in multi mode
- **THEN** it SHALL write `selectedSites` back to the binding
- **AND** dismiss based on `config.presentation`
