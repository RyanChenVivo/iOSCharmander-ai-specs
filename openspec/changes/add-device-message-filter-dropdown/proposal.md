## Why

The current Device Message filter uses a fullscreen sheet pattern, requiring users to navigate away from the message list to apply filters. This creates friction and reduces discoverability of filter options. A dropdown expand pattern provides immediate access to filters while keeping the message list visible.

## What Changes

- Replace single "Filter" button with horizontal scrollable filter chips row (Event Type, Devices, Time Frame)
- Add dropdown expand pattern that appears below chips when tapped
- Implement temp state pattern for filter changes (require Confirm to apply)
- Add overlay/dimmed background when dropdown is open
- Create three content styles: Icon List (Event Type), Grouped List (Devices), Date Picker (Time Frame)

## Impact

- Affected specs: device-message-filtering (new capability)
- Affected code:
  - `DeviceMessageView.swift` - Replace FilterRow with dropdown architecture
  - `DeviceMessageViewModel.swift` - Add activeFilter, temp state management
  - New files in `VortexMessage/Filter/` directory
- No breaking changes to existing filter data model (`MessageFilter`)
- System/Access/Sensor tabs remain unchanged (still use existing FilterRow pattern)
