# Implementation Tasks

## 1. Filter sites without floor plans in FloorPlanSiteView
**File**: `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanSiteView.swift`

- Modify `body` to filter `deviceManager.sites` to only include sites with floor plans
- Use `viewModel.findFloorPlans(bySiteID:)` to check if site has floor plans
- Apply filter: `deviceManager.sites.filter { !viewModel.findFloorPlans(bySiteID: $0.id).isEmpty }`

**Validation**:
- Build succeeds
- Floor plan tab shows only sites with floor plans
- Sites without floor plans are hidden

## 2. Remove empty floor plan display from FloorPlanSiteGroup
**File**: `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanSiteGroup.swift`

- Remove `if floorPlans.isEmpty` conditional block that shows `EmptyFloorPlanView`
- Keep only the else branch that displays floor plan grid
- Simplify body to always display `FlexibleVGrid` with floor plans

**Validation**:
- Build succeeds
- FloorPlanSiteGroup no longer shows empty state
- Sites without floor plans are not displayed (filtered at parent level)

## 3. Refactor FloorPlanSiteGroup to accept flexible display name
**File**: `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanSiteGroup.swift`

Current design:
```swift
struct FloorPlanSiteGroup: View {
    let site: SiteItem
    let floorPlans: [FloorPlan]
    ...
}
```

New design:
```swift
struct FloorPlanSiteGroup: View {
    let displayName: String
    let floorPlans: [FloorPlan]
    var style: FloorPlanSiteView.Style = .list
    var onHeaderTapped: (() -> Void)? = nil
    var onFloorPlanTapped: ((FloorPlan) -> Void)? = nil
}
```

- Replace `site: SiteItem` parameter with `displayName: String`
- Update `FloorPlanSiteGroupLabel` to accept `displayName: String` instead of `site: SiteItem`
- Remove `onSiteTapped` callback from both components
- Add `onHeaderTapped` callback for generic header tap handling
- Update label to use `displayName` instead of `site.name`
- Update accessibility identifier to use `displayName`

**Validation**:
- Build succeeds
- Component interface updated
- Callers need to be updated in next task

## 4. Update FloorPlanSiteView to use refactored FloorPlanSiteGroup
**File**: `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanSiteView.swift`

- Update `FloorPlanSiteGroup` call to pass `displayName: site.name`
- Replace `onSiteTapped` with `onHeaderTapped` if needed
- Keep `onFloorPlanTapped` unchanged

Before:
```swift
FloorPlanSiteGroup(
    site: site,
    floorPlans: floorPlans,
    style: style,
    onSiteTapped: onSiteTapped,
    onFloorPlanTapped: onFloorPlanTapped
)
```

After:
```swift
FloorPlanSiteGroup(
    displayName: site.name,
    floorPlans: floorPlans,
    style: style,
    onHeaderTapped: onSiteTapped.map { callback in { callback(site) } },
    onFloorPlanTapped: onFloorPlanTapped
)
```

**Validation**:
- Build succeeds
- Floor plan list displays correctly with site names
- Tapping site header works as before

## 5. Update FloorPlanDeviceSearchView to show floor plan name
**File**: `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanDetail/FloorPlanDeviceSearchView.swift`

Current: Uses `FloorPlanDeviceGroup` which shows site names

Change approach:
- Replace `FloorPlanDeviceGroup` with `FloorPlanSiteGroup` (reusing refactored component)
- Pass `displayName: viewModel.floorPlan.name` instead of site name
- Group devices by floor plan (all devices are on the same floor plan in this context)

Alternative simpler approach (recommended):
- Keep `FloorPlanDeviceGroup` as-is for device grouping
- But update it to accept optional `displayName` parameter to override site name
- Or create a simple wrapper that doesn't show grouping at all since all devices are from same floor plan

**Decision needed**: Should we group devices by floor plan name, or just show a flat list since they're all from the same floor plan?

Recommended: Show flat list without grouping since user is already in floor plan context.

- Remove site grouping from device search results
- Display devices in simple scrollable list without disclosure groups
- Keep existing device row design

**Validation**:
- Build succeeds
- Device search shows devices without site grouping
- Tapping device navigates back and selects it

## 6. Update device search placeholder text
**File**: `iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanDetail/FloorPlanDeviceSearchView.swift`

- Change placeholder from `"Search"` to `"Device_search"`
- Add localization key `"Device_search"` to Localizable.xcstrings with English value "Device search"
- Follow project localization conventions (paste English for other languages, mark for review)

Before:
```swift
.customSearchable(text: $keyword, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
```

After:
```swift
.customSearchable(text: $keyword, placement: .navigationBarDrawer(displayMode: .always), prompt: "Device_search")
```

**Validation**:
- Build succeeds
- Search placeholder shows "Device search" in English
- Localization strings file includes new key

## 7. Add or update localization strings
**File**: `iOSCharmander/Localizable.xcstrings`

Add new key if needed:
- `Device_search` = "Device search"

Follow project conventions:
- English: "Device search"
- Other languages: Initially paste English, mark for review

**Validation**:
- Localization file is valid JSON
- New keys appear in Xcode string catalog

## 8. Clean up EmptyFloorPlanView if unused
**File**: `iOSCharmander/View/Home/Tab/FloorPlanTab/EmptyFloorPlanView.swift`

- Check if `EmptyFloorPlanView` is still used anywhere after removing from `FloorPlanSiteGroup`
- If not used, remove the file
- Update Xcode project to remove file reference if deleted

Use grep to verify:
```bash
rg "EmptyFloorPlanView" --type swift
```

**Validation**:
- Build succeeds
- No references to EmptyFloorPlanView remain if file is deleted

## 9. Run and verify tests
**Files**:
- `iOSCharmanderTests/Test/FloorPlan/FloorPlanTabViewModelTest.swift`
- `iOSCharmanderTests/Test/FloorPlan/FloorPlanDetailViewModelTest.swift`
- `iOSCharmanderTests/Test/FloorPlan/FloorPlanManagerTest.swift`

- [x] Run existing unit tests
- [x] Verify all tests pass
- [x] Reorganized test files into FloorPlan subfolder
- [x] Moved helper methods to bottom of test files for better readability
- [x] Updated tests for new SiteFloorPlans architecture

**Validation**:
- All existing tests pass (manually verified)
- Test coverage maintained
- Test structure improved for better readability

## 10. Manual testing checklist
- [x] Floor plan tab shows only sites with floor plans
- [x] Sites without floor plans are hidden from list
- [x] Pull-to-refresh updates filtered list correctly
- [x] Tapping floor plan opens detail view
- [x] Device search shows clear "Device search" placeholder
- [x] Device search displays results without site grouping
- [x] Selecting device from search navigates back and selects device
- [x] Grid/list toggle works correctly
- [x] Landscape orientation works properly
- [x] No empty state messages appear in floor plan list
- [x] FloorPlanRow no longer displays device count

## Additional Tasks Completed
- Fixed FloorPlanSiteSearchingView to use new FloorPlanSiteGroup interface
- Fixed FloorPlanDeviceGroup to use new FloorPlanSiteGroupLabel interface
- Removed device count display from FloorPlanRow
- Applied FloorPlanDeviceGroup component in device search view with floor plan name as header
- Updated icon for FloorPlanDeviceGroup to use iconGengralFileSolid
- Reorganized test files into FloorPlan subfolder for better structure
- Moved test helper methods to bottom of test files for improved readability
- Build succeeds with no errors

## Summary
All tasks (1-10) have been completed successfully:
- ✅ Tasks 1-8: Implementation completed and committed
- ✅ Task 9: Tests verified and reorganized
- ✅ Task 10: Manual testing checklist completed

## Dependencies
- Tasks 1-2 can be done in parallel
- Task 3 must complete before tasks 4-5
- Tasks 6-7 can be done in parallel with others
- Task 8 should be done after task 2
- Tasks 9-10 should be done last
