---
name: feature-toggle-integration
description: Implement Feature Toggle and Dark Release controls. Use when adding new features that need gradual rollout or organization-specific access control.
---

# Feature Toggle & Dark Release Integration

Use this skill when adding new features that need:
- Gradual rollout to specific organizations
- Permission-based access control
- License-based restrictions

## 1. When to Use

- Adding a new tab/feature to the app
- Implementing organization-specific capabilities
- Adding license-gated features
- Any feature that needs controlled rollout

## 2. AI Behavior Guide

Before acting on requests related to dark release or feature toggles, confirm intent:

| Trigger | AI Should Ask |
|---------|--------------|
| "delete dark release", "remove support feature", "remove dark release check" | Are you asking the backend to set this feature to "all" (full release), or do you actually want to remove this feature type from the frontend code? |
| "release to all users", "full rollout" | This should be handled by the backend setting the support feature to "all". The frontend doesn't need changes. Can you confirm? |
| "delete SupportFeature enum case" | Deleting the enum case means this feature can never be controlled via dark release again. Are you sure you want to permanently remove this feature's dark release mechanism? |

## 3. Dark Release Lifecycle

**Full release does NOT mean deleting frontend code. Full release is a backend operation.**

```
Phase 1          Phase 2           Phase 3            Phase 4 (Optional)
Add Dark       Gradual            Full                Remove Dark
Release        Rollout            Release             Release
─────────── → ─────────────── → ──────────────── → ──────────────────
Frontend:      Frontend:          Frontend:           Frontend:
+ enum case    unchanged          unchanged           - .contains() check
+ .contains()                                         (only with explicit
                                                       confirmation)
Backend:       Backend:           Backend:
+ feature to   + feature to       set feature
  specific       more orgs         to "all"
  orgs
```

### Phase Details

1. **Add Dark Release** -- Frontend adds `SupportFeature` enum case + `.contains()` check in `canViewTab`; backend adds feature to specific organizations' support array.
2. **Gradual Rollout** -- Backend adds more organizations; frontend unchanged.
3. **Full Release** -- Backend sets feature to "all"; frontend unchanged; `.contains()` still returns `true`.
4. **(Optional) Remove Dark Release** -- Only with explicit user confirmation; remove `.contains()` check from frontend. This is rarely needed.

## 4. Implementation Checklist

### 4.1 Backend Enum Definition

Add feature to `MyOrganization.SupportFeature` enum:

**Location:** `VortexFeatures/Sources/VortexFeatures/Core/VortexBackend/Model/Organization/MyOrganization.swift`

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

### 4.2 FeatureToggle -- canViewTab

**Location:** `iOSCharmander/Common/FeatureProvider/FeatureToggle.swift`

Controls whether the tab/feature appears in the UI.

**Check Order:**
1. Dark Release (organization support) -- **required**
2. Privilege check -- **optional** (only when role restriction is needed)

#### Minimal example (dark release only):

```swift
case .yourFeature:
    myOrganizationSupportFeatures.contains(.yourNewFeature)
```

#### With privilege check:

```swift
case .yourFeature:
    myOrganizationSupportFeatures.contains(.yourNewFeature) &&
    hasAnyDeviceWithPrivilege(.live)
```

#### Available privilege helper methods:

```swift
// Check if any device has a specific privilege
private func hasAnyDeviceWithPrivilege(_ privilege: PrivilegeDeviceScope) -> Bool

// Check specific device privilege
private func hasDevicePrivilege(_ device: DeviceItem, _ privilege: PrivilegeDeviceScope) -> Bool

// Check organization-level privilege
private func hasOrgPrivilege(_ privilege: PrivilegeOrganizationScope) -> Bool
```

**Reference for privilege scopes:** `VortexFeatures/Sources/VortexFeatures/Core/VortexBackend/PrivilegeProvider/PrivilegeScope.swift`

**Result:** If `false`, tab is completely removed from UI.

---

### 4.3 FeatureToggle -- canTriggerTab

Controls whether a visible tab can be interacted with (license-based).

```swift
case .yourFeature:
    licenseManager.hasValidLicense(for: .yourFeature)
```

**Result:** If `false`, tab shows but is grayed out (disabled state).

---

### 4.4 FeatureToggle -- tabCanDisable

Defines whether the tab can be shown in disabled state.

```swift
case .yourFeature:
    true  // Allow showing as disabled when license issues occur
```

**Common values:**
- `true` -- For features like `.floorPlan`, `.message`, `.archive`
- `false` -- For critical features that should be hidden when unavailable

---

## 5. Check Priority Flow

```
┌─────────────────────────┐
│ canViewTab()            │ → Dark Release + Permissions
│ (Should tab appear?)    │
└───────────┬─────────────┘
            │
            ├─ false → Tab Hidden
            │
            └─ true ↓

┌─────────────────────────┐
│ canTriggerTab()         │ → License Check
│ (Can user interact?)    │
└───────────┬─────────────┘
            │
            ├─ false → Check tabCanDisable()
            │            ├─ true → Show Grayed Out
            │            └─ false → Hide
            │
            └─ true → Show Active
```

---

## 6. Example: Floor Plan Feature

```swift
// 1. Backend enum (MyOrganization.swift)
public enum SupportFeature: String, VortexBackendModel {
    case floorPlan = "FloorPlan"
}

// 2. FeatureToggle.swift - canViewTab
case .floorPlan:
    myOrganizationSupportFeatures.contains(.floorPlan)

// 3. FeatureToggle.swift - canTriggerTab
case .floorPlan:
    licenseManager.hasValidLicense(for: .floorPlan)

// 4. FeatureToggle.swift - tabCanDisable
case .floorPlan:
    true  // Can show as disabled
```

Note: Floor plan uses dark release only in `canViewTab` -- no privilege check is needed for this feature.

---

## 7. Testing Checklist

- [ ] Feature hidden when organization doesn't have support flag
- [ ] Feature visible when organization has support flag + user has permissions
- [ ] Feature grayed out when license invalid (if `tabCanDisable` returns true)
- [ ] Feature works normally when all conditions met
- [ ] Proper error messages shown when access denied

---

## 8. Backend Coordination

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

**The "all" mechanism for full release:**
- When backend sets a support feature to "all", it is equivalent to adding it to every organization's support array.
- The frontend `.contains()` check continues to work -- it returns `true` for all organizations.
- This is the standard way to fully release a dark-released feature. No frontend changes are needed.

---

## 9. Common Pitfalls

### Dark Release

- Do not delete `SupportFeature` enum case to "release" a feature -- full release is a backend operation (set to "all").
- Do not remove frontend `.contains()` check to "release" a feature -- same reason.
- Do not remove dark release mechanism without explicit user confirmation.

### Permissions

- Do not add privilege checks to every feature -- only when role restriction is needed.
- Do not check license in `canViewTab` -- license checks belong in `canTriggerTab`.
- Do not skip dark release check when the feature has one.

### General

- Feature flag name must match backend exactly (PascalCase).
- Test all states -- hidden, visible+disabled, visible+enabled.
- Coordinate with backend team on feature flag naming and support array.
