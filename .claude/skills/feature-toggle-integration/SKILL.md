---
name: feature-toggle-integration
description: Implement Feature Toggle and Dark Release controls. Use when adding new features that need gradual rollout or organization-specific access control.
---

# Feature Toggle & Dark Release Integration

Use this skill when adding new features that need:
- Gradual rollout to specific organizations
- Permission-based access control
- License-based restrictions

## When to Use

- Adding a new tab/feature to the app
- Implementing organization-specific capabilities
- Adding license-gated features
- Any feature that needs controlled rollout

## Implementation Checklist

### 1. Backend Enum Definition

Add feature to `MyOrganization.SupportFeature` enum:

**Location:** `VortexFeatures/Sources/VortexFeatures/Common/VortexBackend/Model/Organization/MyOrganization.swift`

```swift
public enum SupportFeature: String, VortexBackendModel {
    case licensePlateRecognition = "LicensePlateRecognition"
    case spotOccupancy = "SpotOccupancy"
    case floorPlan = "FloorPlan"
    case yourNewFeature = "YourNewFeature"  // Add your feature
}
```

**Naming Convention:**
- Use PascalCase for the raw value
- Match the backend's feature flag name exactly

---

### 2. FeatureToggle Implementation

**Location:** `iOSCharmander/Common/FeatureProvider/FeatureToggle.swift`

Implement the three toggle methods for your feature:

#### Method 1: `canViewTab(_ tab: HomeViewTab) -> Bool`

Controls whether the tab/feature appears in the UI.

**Check Order:**
1. Dark Release (organization support)
2. Permissions
3. Other conditions

```swift
case .yourFeature:
    // Step 1: Dark Release - Check organization support
    myOrganizationSupportFeatures.contains(.yourNewFeature) &&
    // Step 2: Permissions - Check user has access to at least one site
    !sites.allSatisfy { privilegeProvider.canDo(.group(siteID: $0.id), .read) == false }
    // Step 3: Additional conditions (if needed)
```

**Result:** If `false`, tab is completely removed from UI

---

#### Method 2: `canTriggerTab(_ tab: HomeViewTab) -> Bool`

Controls whether a visible tab can be interacted with (license-based).

```swift
case .yourFeature:
    // Check license validity
    licenseManager.hasValidLicense(for: .yourFeature)
```

**Result:** If `false`, tab shows but is grayed out (disabled state)

---

#### Method 3: `tabCanDisable(_ tab: HomeViewTab) -> Bool`

Defines whether the tab can be shown in disabled state.

```swift
case .yourFeature:
    true  // Allow showing as disabled when license issues occur
```

**Common values:**
- `true` - For features like `.floorPlan`, `.message`, `.archive`
- `false` - For critical features that should be hidden when unavailable

---

### 3. Check Priority Flow

```
┌─────────────────────────┐
│ canViewTab()            │ → Dark Release + Permissions
│ (Should tab appear?)    │
└───────────┬─────────────┘
            │
            ├─ false → Tab Hidden ❌
            │
            └─ true ↓

┌─────────────────────────┐
│ canTriggerTab()         │ → License Check
│ (Can user interact?)    │
└───────────┬─────────────┘
            │
            ├─ false → Check tabCanDisable()
            │            ├─ true → Show Grayed Out 🔒
            │            └─ false → Hide ❌
            │
            └─ true → Show Active ✅
```

---

## Example: Adding Floor Plan Feature

```swift
// 1. Backend enum (MyOrganization.swift)
public enum SupportFeature: String, VortexBackendModel {
    case floorPlan = "FloorPlan"
}

// 2. FeatureToggle.swift - canViewTab
case .floorPlan:
    myOrganizationSupportFeatures.contains(.floorPlan) &&
    !sites.allSatisfy { privilegeProvider.canDo(.group(siteID: $0.id), .read) == false }

// 3. FeatureToggle.swift - canTriggerTab
case .floorPlan:
    licenseManager.hasValidLicense(for: .floorPlan)

// 4. FeatureToggle.swift - tabCanDisable
case .floorPlan:
    true  // Can show as disabled
```

---

## Testing Checklist

- [ ] Feature hidden when organization doesn't have support flag
- [ ] Feature visible when organization has support flag + user has permissions
- [ ] Feature grayed out when license invalid (if `tabCanDisable` returns true)
- [ ] Feature works normally when all conditions met
- [ ] Proper error messages shown when access denied

---

## Backend Coordination

**Required Backend Changes:**
1. Add feature flag to organization's `support` array
2. Update `listMyOrganization` API response to include new feature
3. Coordinate with backend team on feature flag name

**API Response Example:**
```json
{
  "support": ["FloorPlan", "YourNewFeature"]
}
```

---

## Common Pitfalls

❌ **Don't check license in `canViewTab`** - License checks belong in `canTriggerTab`
❌ **Don't skip Dark Release check** - Always check organization support first
❌ **Don't use wrong check order** - Follow: Dark Release → Permissions → License
✅ **Do coordinate naming** - Feature flag name must match backend exactly
✅ **Do test all states** - Hidden, visible+disabled, visible+enabled
