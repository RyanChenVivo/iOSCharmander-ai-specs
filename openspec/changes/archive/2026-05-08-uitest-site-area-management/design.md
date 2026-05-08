## Context

The `feat/supportSubsite` branch redesigned site management UX:
- **MoveToSiteView**: Changed from flat list + immediate-move to tree view + select-then-confirm (select site → tap "Move_device" → DeleteConfirmation sheet)
- **SiteInformationView**: Unified create/edit for both sites and areas with type picker and parent site selector
- **SiteSelectionView**: New component for single/multi site selection with tree view

Existing UITests updated `CommonOperation` to remove group-prefix from device identifiers, but no dedicated test coverage exists for MoveToSite flow or area CRUD operations.

**Test environment**: UAT account with pre-configured site hierarchy:
```
Organization Site (default, device starts here)
├── UAT SiteA          (has device for siteHasDevices error)
├── UAT SiteB          (has sub-area for cannotDeleteSiteWithSubSites error)
│   └── UAT AreaB1
├── UAT SiteC          (empty, target for move and create area)
└── UAT SiteD          (5-level deep for hierarchyDepthExceeded error)
    └── UAT AreaD1
        └── UAT AreaD2
            └── UAT AreaD3
                └── UAT AreaD4
```

## Goals / Non-Goals

**Goals:**
- Cover MoveToSite happy path (select site in tree → confirm move)
- Cover area CRUD (create area with parent site, delete area)
- Cover error scenarios: siteHasDevices, cannotDeleteSiteWithSubSites, hierarchyDepthExceeded, subsiteCountExceeded
- Update `CommonOperation.move(device:toGroup:)` to match new UI flow
- Ensure ViewTabExpandCollapseUITest still works with `site.displayName` identifiers

**Non-Goals:**
- Testing SiteSelectionView multi-select mode (not in scope for this change)
- Testing TreeView search functionality
- Testing MoveToSite empty state (no sites scenario)

## Decisions

### 1. File organization: Site/ directory with two test files

**Choice**: `iOSCharmanderUITests/Site/MoveToSiteUITest.swift` and `SiteAreaUITest.swift`

**Rationale**: MoveToSite and Area CRUD are different entry points with different tearDown strategies. MoveToSite tearDown uses `moveAllDevicesToOrganizationSite`. Area tests only need to clean up newly created areas.

**Alternative considered**: Single `SiteManagementUITest.swift` — rejected because mixing tearDown logic would be fragile.

### 2. Device starts at Organization Site, tearDown moves back

**Choice**: Test device lives at Organization Site by default. Tests move it to target site. TearDown calls `moveAllDevicesToOrganizationSite`.

**Rationale**: Matches existing pattern (`UATHelper.moveAllDevicesToOrganizationSite`). Simple, idempotent restoration regardless of test failure point.

### 3. MoveToSite flow uses new UI pattern

**Choice**: Update `CommonOperation.move` to:
1. Tap device more button → "Move to"
2. Wait for MoveToSiteView (NavigationBar "Move to")
3. Tap target site in tree view (by staticText name)
4. Tap "Move_device" button (now separate from selection)
5. Confirm in DeleteConfirmation sheet (tap "Move_Device")

**Rationale**: New MoveToSiteView separates selection from action. User selects site first, then confirms with explicit button. DeleteConfirmation sheet shows "Move_this_device" title and requires tapping "Move_Device".

### 4. Error tests trigger real backend errors

**Choice**: Actually attempt the forbidden operation and verify the alert message appears.

**Rationale**: Tests real error handling end-to-end. UAT environment is pre-configured with the necessary site structure to trigger each error.

### 5. Area creation flow through SiteInformationView

**Choice**: Navigate to Create site or area → select "Area" type in segmented control → fill name → select parent site → tap Create.

**Rationale**: This is the actual user flow through SiteInformationView's new unified create interface.

## Risks / Trade-offs

- **[Risk] Test environment site structure drift** → Document required structure clearly; tests should fail fast with meaningful assertion if expected sites are missing
- **[Risk] MoveToSite tree view tap may not find site if tree is collapsed** → Use search or scroll to find the target site; rely on `staticTexts` matching
- **[Risk] Alert message localization may differ** → Use localization keys or partial matching for error messages
- **[Risk] DeleteConfirmation requires typing "DELETE" for site deletion but not for move** → Tests must handle both flows correctly (move = tap confirm directly, delete site = type DELETE first)
