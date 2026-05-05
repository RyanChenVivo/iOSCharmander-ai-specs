## MODIFIED Requirements

### Requirement: MoveToSiteView is move-only
MoveToSiteView SHALL only handle the Move Device flow. The `.add` source branch SHALL be removed.

#### Scenario: No source parameter
- **WHEN** MoveToSiteView is instantiated
- **THEN** it SHALL NOT accept a `source` parameter
- **AND** it SHALL always behave as the Move flow

#### Scenario: Always wrapped in NavigationStack
- **WHEN** MoveToSiteView is displayed
- **THEN** the content SHALL always be wrapped in a NavigationStack with a ToolbarItemCancel
- **AND** the previous `switch viewModel.source` branching SHALL be removed

#### Scenario: SheetManager call site updated
- **WHEN** SheetManager presents MoveToSiteView
- **THEN** it SHALL instantiate `MoveToSiteView(device:)` without a `source` parameter

### Requirement: MoveToSiteViewModel simplified to move-only
MoveToSiteViewModel SHALL remove the `source` property and all `.add` case handling.

#### Scenario: No source property
- **WHEN** MoveToSiteViewModel is initialized
- **THEN** it SHALL NOT accept a `source` parameter
- **AND** `currentSiteID` SHALL always be derived from `device.siteID` (if non-empty)

#### Scenario: Site selection updates local state only
- **WHEN** user taps a site row in MoveToSiteView
- **THEN** `device.siteID` SHALL be updated to the selected site's ID
- **AND** the view SHALL NOT dismiss (user must tap "Move device" button to confirm)

### Requirement: AnalyticsEvent cleanup
The `.add` case of `AddDeviceGroupSource` SHALL be evaluated for removal.

#### Scenario: No remaining callers for .add
- **WHEN** MoveToSiteView no longer uses `source: .add`
- **AND** SiteSelectionView uses its own analytics tracking
- **THEN** `AddDeviceGroupSource.add` SHALL be removed if no other callers exist

#### Scenario: Analytics preserved in new view
- **WHEN** SiteSelectionView tracks a "Create site or area" tap
- **THEN** it SHALL use an appropriate analytics event (may reuse `.add` or define a new event)
