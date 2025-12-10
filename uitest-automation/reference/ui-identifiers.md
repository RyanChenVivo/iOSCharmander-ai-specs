# UI Element Accessibility Identifiers

## Purpose

This document catalogs accessibility identifiers used in the Vortex app for UITest automation. These IDs allow UITests to reliably locate and interact with UI elements.

**Why This Document Exists:**
- UITest code relies on `accessibilityIdentifier` to find elements
- These IDs are **test implementation details**, not product specifications
- Centralizing them prevents duplicate discovery work
- Enables AI assistants to write tests without guessing IDs

## How to Use

### For Writing Tests:
1. Search this document for relevant feature/screen
2. Use documented IDs in test code: `app.buttons["add_camera"]`
3. If ID missing, use `ios-simulator-mcp` to discover it
4. Add newly discovered IDs back to this document

### For Adding New IDs:
```swift
// In app code:
Button("Add Camera") {
    // action
}
.accessibilityIdentifier("add_camera")

// Then document here:
## Device Management
- Add camera button: `add_camera`
```

## Naming Conventions

Follow these patterns when creating new accessibility IDs:

**Pattern:** `{feature}_{element_type}[_{descriptor}]`

**Examples:**
- `floor_plan_search` - Floor Plan feature, search field
- `camera_list_item` - Camera list, cell/item
- `sign_in_sso_button` - Sign in screen, SSO button

**Guidelines:**
- Use lowercase with underscores (snake_case)
- Be descriptive but concise
- Include feature context for clarity
- Avoid generic names like `button1` or `view`

## UI Identifiers by Feature

### Authentication & Sign In

| Element | Identifier | Type | Usage |
|---------|-----------|------|-------|
| SSO sign-in button | `sign_in_sso_button` | Button | Trigger SSO authentication flow |
| Email input field | `sign_in_email` | TextField | Enter email address |
| Password input field | `sign_in_password` | SecureField | Enter password |
| Sign in button | `sign_in_submit` | Button | Submit credentials |

**Notes:**
- SSO flow may show Microsoft/Google authentication pages (external, not our IDs)
- Microsoft may show passkey dialog - handle via `app.alerts["Sign In"]`

### Floor Plan

| Element | Identifier | Type | Usage |
|---------|-----------|------|-------|
| Search field | `floor_plan_search` | SearchField | Filter floor plans by name |
| Floor plan cell | `floor_plan_{id}` | Cell | Individual floor plan item (ID = backend floor plan ID) |
| Camera marker | `cameraMarker_{id}` | Custom | Camera location marker on floor plan (ID = device ID) |
| Site picker | `floor_plan_site_picker` | Picker | Select which site's floor plans to view |

**Example:**
```swift
// Select floor plan with ID "office_1f"
app.cells["floor_plan_office_1f"].tap()

// Tap camera marker for device "IB9365-001"
app.otherElements["cameraMarker_IB9365-001"].tap()
```

**State Tracking:**
- Camera markers use `accessibilityValue` to indicate selection state
- Check value: `app.otherElements["cameraMarker_{id}"].value as? String == "selected"`

### Device Management

| Element | Identifier | Type | Usage |
|---------|-----------|------|-------|
| Add camera button | `add_camera` | Button | Open add camera flow |
| Camera list item | `camera_list_item` | Cell | Camera in device list (use `.element(boundBy: index)`) |
| Device cell | `device_camera_{model}` | Cell | Specific device by model (e.g., `device_camera_IB9365`) |

**Notes:**
- Camera list items may not have unique IDs - use index-based selection when necessary
- After adding camera, verify appearance using model-specific ID

### Home Screen

| Element | Identifier | Type | Usage |
|---------|-----------|------|-------|
| Floor Plan tab | (Tab bar button) | TabBarButton | Switch to Floor Plan view |
| Message tab | (Tab bar button) | TabBarButton | Switch to Message view |
| Archive tab | (Tab bar button) | TabBarButton | Switch to Archive view |

**Note:** Tab bar buttons use default iOS accessibility - reference by label, not custom ID.

## Accessibility Value Pattern

Some elements use `accessibilityValue` to expose state information for testing:

### Pattern:
```swift
// In app code:
.accessibilityIdentifier("element_id")
.accessibilityValue(isActive ? "active" : "inactive")

// In test code:
let element = app.otherElements["element_id"]
XCTAssertEqual(element.value as? String, "active")
```

### Known Elements Using Value:

| Element | Identifier | Possible Values | Meaning |
|---------|-----------|----------------|---------|
| Camera marker | `cameraMarker_{id}` | `"selected"`, `"unselected"` | Whether camera is currently selected |
| [Add more as discovered] | | | |

## Discovery Workflow

When writing a new test and needing to find UI element IDs:

### Step 1: Check This Document
Search for the feature/screen you're testing.

### Step 2: Use ios-simulator-mcp
If ID not found, use simulator to discover it:

```
# Launch app and navigate to feature
mcp__ios-simulator__launch_app(bundle_id: "com.vivotek.vortex")

# Navigate to the screen (use ui_tap, ui_type, etc.)

# Discover all elements
mcp__ios-simulator__ui_describe_all()
```

Look for elements with `identifier` field in the output.

### Step 3: Verify in App Code
Check the SwiftUI view to confirm the ID:

```swift
// Search in app code:
.accessibilityIdentifier("discovered_id")
```

### Step 4: Document Here
Add the newly discovered ID to this document under appropriate feature section.

### Step 5: Use in Test
```swift
let element = app.buttons["discovered_id"]
UATHelper.waitElementToTap(element)
```

## Missing IDs - Action Required

If you need to test an element but it lacks an accessibility identifier:

1. **Identify the UI element** in app code (SwiftUI view)
2. **Add accessibility identifier:**
   ```swift
   .accessibilityIdentifier("descriptive_id")
   ```
3. **Rebuild the app** for testing
4. **Document the ID here** so others can use it
5. **Update test code** to use the new ID

**Important:** Always add accessibility IDs in app code, don't rely on default iOS accessibility.

## Maintenance

### When to Update:
- New feature added → Add its UI element IDs
- UI refactoring → Update changed IDs
- Element removed → Remove from this list (add note in git commit)

### When to Clean Up:
- Quarterly review of obsolete IDs
- Remove IDs for deprecated features
- Consolidate duplicate or redundant entries

### Version Tracking:
This document reflects IDs as of:
- **App Version:** iOS 17.0+ (current development)
- **Last Updated:** 2025-12-03
- **Major Changes:** Initial creation

---

## Quick Reference

Common ID patterns for quick lookup:

```
Authentication:    sign_in_{element}
Floor Plan:        floor_plan_{element}
                  cameraMarker_{deviceId}
Device:           add_camera
                  device_camera_{model}
Messages:         [To be documented]
Archive:          [To be documented]
Settings:         [To be documented]
```

## Future Work

Sections to be populated as features are tested:

- [ ] Messages & Notifications
- [ ] Archive & Video Playback
- [ ] User Settings
- [ ] Organization Management
- [ ] License Management
- [ ] NVR Functionality
- [ ] MFA Settings

## Contributing

When adding new IDs:
1. Use the table format shown above
2. Include element type (Button, TextField, Cell, etc.)
3. Describe usage/purpose
4. Add notes for complex behaviors
5. Group by feature/screen
