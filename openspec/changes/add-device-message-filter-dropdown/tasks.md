## 1. Foundation Components

- [ ] 1.1 Create `FilterType` enum with cases: eventType, devices, timeFrame
- [ ] 1.2 Create `FilterChip` view with three visual states (normal, hasSelection, active)
- [ ] 1.3 Create `FilterChipsRow` view with horizontal scrolling
- [ ] 1.4 Create `FilterActionButtons` view (Clear/Confirm buttons)

## 2. Dropdown Container

- [ ] 2.1 Create `FilterDropdown` container view with overlay and animation
- [ ] 2.2 Implement max height constraint (3/4 of content area)
- [ ] 2.3 Add dimmed overlay with tap-to-close gesture

## 3. Filter Content Views

- [ ] 3.1 Create `EventTypeFilterContent` with Icon List style (search, count row, list items)
- [ ] 3.2 Create `DevicesFilterContent` with Grouped List style (search, expandable groups, device items with thumbnails)
- [ ] 3.3 Create `TimeFrameFilterContent` wrapping existing `DateFilterView`

## 4. ViewModel Integration

- [ ] 4.1 Add `activeFilter: FilterType?` property to `DeviceMessageViewModel`
- [ ] 4.2 Add temp state properties (tempEventTypes, tempDevices, tempDateFilter)
- [ ] 4.3 Implement temp state lifecycle methods (open, confirm, clear, close)
- [ ] 4.4 Wire up filter application to existing `MessageFilter` query logic

## 5. View Integration

- [ ] 5.1 Remove `FilterRow` from `DeviceMessageView`
- [ ] 5.2 Add `FilterChipsRow` below navigation bar
- [ ] 5.3 Integrate `FilterDropdown` with ZStack overlay pattern
- [ ] 5.4 Connect chip interactions to ViewModel

## 6. Polish and Validation

- [ ] 6.1 Implement chip state transition animations (0.15s easeInOut)
- [ ] 6.2 Implement dropdown open/close animations (0.2s easeInOut)
- [ ] 6.3 Build and verify no compilation errors
- [ ] 6.4 Manual testing of all filter interactions
