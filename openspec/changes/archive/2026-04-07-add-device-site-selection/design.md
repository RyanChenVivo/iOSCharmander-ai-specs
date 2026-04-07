## Context

The Add Device flow currently pre-selects a default Site via `deviceManager.findDefaultSite()` in `AddDeviceViewModel.genDevice()`. The `MoveToSiteView` shows a searchable Site list but has no empty state handling. Site deletion uses a long-press context menu with the feature toggle check.

Key files:
- `AddDeviceViewModel.swift` — `genDevice()` sets `siteID: selectedSiteID ?? defaultSiteID`
- `AddDeviceByMacView.swift` — Add button has no site-related disabled logic
- `MoveToSiteView.swift` — Site list with context menu delete
- `MoveToSiteViewModel.swift` — Holds device as value copy, site selection/deletion logic split between View and VM
- `NoResultCover.swift` — Existing empty state component using `NoResultContent(image:description:)`

## Goals / Non-Goals

**Goals:**
- Require explicit Site selection before adding a device
- Provide clear empty state when no Sites exist in MoveToSiteView
- Move device binding and site-related logic into MoveToSiteViewModel

**Non-Goals:**
- Auto-selecting a newly created Site (user manually selects after creation)
- Changing the delete interaction (remains context menu — swipe actions don't work in ScrollView-based lists)

## Decisions

### 1. Remove default Site fallback in genDevice()

Change `siteID: selectedSiteID ?? defaultSiteID` to `siteID: selectedSiteID` (nil when no prior selection exists).

**Rationale**: Aligns with Portal spec requiring explicit Site selection. The `selectedSiteID` still carries forward between consecutive device additions in the same session, so users only need to pick a Site once if adding multiple devices sequentially.

### 2. Add button disable condition

Add `.disabled(!viewModel.canAddDevice)` to the Add button in `AddDeviceByMacView`. Introduce a computed property on `AddDeviceViewModel`:

```swift
var canAddDevice: Bool {
    addingDevice.siteID.isNotEmpty
}
```

**Rationale**: Simple empty check is sufficient because `MoveToSiteViewModel` clears `siteID` when the selected Site is deleted, so stale IDs don't persist.

**Alternative considered**: Using `findSite(id:)` — handles deleted-Site edge case at the check level, but adds unnecessary coupling since the VM already handles cleanup.

### 3. Site field placeholder

When no Site is selected, display "Select a site" in muted color (`.colorText06`) instead of "-". Applied to both `AddDeviceByMacView` and `AddVSSView` for consistency.

```swift
NavigationRow(title: "Site_name", description: viewModel.siteName ?? Text("Select_a_site").foregroundStyle(.colorText06))
```

### 4. Empty state in MoveToSiteView

Use the existing `NoResultView` shared component with a custom illustration and localized description. Display when `deviceManager.sites.isEmpty`.

```swift
if deviceManager.sites.isEmpty {
    NoResultView(coverContent: NoResultContent(image: .illustrationSearchFailed, description: "No_sites_create_one_to_get_started"))
} else {
    SearchableScrollItemListView(...)
}
```

**Rationale**: Reuses the app's established empty state pattern. No new components needed.

### 5. Move device Binding into MoveToSiteViewModel

Refactored `MoveToSiteViewModel` to hold `@Binding var device: DeviceItem` instead of a value copy. This moves all site-related logic into the VM:
- `selectedSite` computed property
- `tapSiteRow` sets `device.siteID` directly
- `tapDeleteSiteButton` clears `device.siteID` when the deleted site was selected

**Rationale**: Keeps View layer thin — View only handles navigation (dismiss/dismissAll), VM handles all data mutations.

### 6. DeviceItem.siteID type handling

Current `DeviceItem.make()` initializes `siteID` as an empty string `""`. With the default fallback removed, `siteID` remains `""` when no Site is selected. The `canAddDevice` check using `isNotEmpty` naturally handles this.

## Risks / Trade-offs

**[No pre-selection adds a required step]** → Users must now always tap into MoveToSiteView to select a Site before adding a device. This is intentional per Portal spec alignment, but adds one extra tap to the flow.

**[Context menu for delete]** → Swipe actions were considered but don't work with `SearchableScrollItemListView` (ScrollView-based, not List-based). Context menu remains as the delete interaction.
