## Why

The Portal already implements Site/Subsite deletion with full safety mechanisms (empty-site prerequisite, "DELETE" confirmation, cannot-delete warnings). The iOS App currently lacks this capability entirely — users cannot delete Sites or Subsites from the App. To achieve feature parity with Portal and provide a complete site management experience on mobile, the App needs to support Site and Subsite deletion with the same safety constraints.

## What Changes

- Add delete option for Sites and Subsites in the iOS App
- Implement empty-site prerequisite check: block deletion when Site/Subsite still contains devices or child Subsites
- Display "Cannot Delete" alert when prerequisite not met, showing device count (including devices in child Subsites)
- Display permanent deletion confirmation alert for empty Sites/Subsites, requiring user to type "DELETE" to confirm
- Implement delete API integration to remove Site/Subsite from backend
- Refresh Site list and navigate appropriately after successful deletion
- Handle error scenarios: network failure, server error, concurrent modification (devices added during deletion)

## Capabilities

### New Capabilities

- `site-deletion`: Delete Site/Subsite with safety prerequisites (empty-site check, cannot-delete warning, "DELETE" text confirmation), API integration, post-deletion navigation, and error handling

### Modified Capabilities

- `ios-view-tab-device-management`: Site list needs to reflect deletion — when a selected Site is deleted, the view should navigate away and refresh the site tree

## Impact

- **UI**: New delete button/action in Site detail or context menu, two dialog types (cannot-delete alert, delete confirmation with text input)
- **ViewModel**: New deletion logic in Site-related ViewModel, prerequisite validation (device count + child Subsite count)
- **API**: Call existing backend delete Site/Subsite endpoint
- **Navigation**: Handle post-deletion navigation (e.g., select parent or first available Site after deletion)
- **Permissions**: Only Owner/Admin roles should see the delete option
