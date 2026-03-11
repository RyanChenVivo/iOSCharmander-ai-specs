---
name: feature-toggle-integration
description: Use when modifying FeatureToggle.swift, FeatureProvider.swift, or MockFeatureProvider.swift. Also triggers when implementing OpenSpec tasks, bug fixes, or any feature work that involves adding/moving/editing feature toggle functions, MARK groups, or dark release checks.
---

# Feature Toggle & Dark Release Integration

## 1. When to Use

- Adding a new tab/feature with dark release or permission control
- Adding/moving/editing any function in `FeatureToggle.swift`
- Implementing OpenSpec tasks or bug fixes that touch feature toggle files
- Any change that affects `FeatureProvider.swift` protocol or `MockFeatureProvider.swift`

## 2. MARK Group Convention (Critical)

FeatureToggle uses `// MARK:` sections to organize functions by domain. **Three files must stay in sync:**

| File | Role | MARK Style |
|------|------|------------|
| `FeatureToggle.swift` | Implementation | `// MARK: - Section` as separate `extension` |
| `FeatureProvider.swift` | Protocol | `// MARK: - Section` inside protocol body |
| `MockFeatureProvider.swift` | Mock | `// MARK: - Section` in 4 places (property, init param, init body, conformance) |

### Current MARK Groups (in order)

```
Site → Device → Device Settings → Message → Message Search →
Floor Plan → Archive → AI → AI Search Result → AI Search →
VCA Features → Face Profile → Snooze Rule → Alarm Setting →
Customized View → Organization & System →
User Management & Authentication → Reseller & License →
UI & Navigation → Helper Methods (FeatureToggle only)
```

### Rules

1. **New function must go in the semantically correct MARK group.** Do NOT append to whichever section happens to be nearby.
2. **If no existing group fits, create a new `// MARK: - GroupName` section** with its own `extension` in FeatureToggle.swift, and add matching MARKs to FeatureProvider.swift and MockFeatureProvider.swift.
3. **When adding to MockFeatureProvider.swift, update all 4 locations:**
   - Property declaration (top)
   - `init` parameter with default `unimplemented(...)` value
   - `init` body assignment (`self._xxx = _xxx`)
   - Protocol conformance function
4. **Verify placement after every edit** by checking the surrounding `// MARK:` comments match the function's domain.

### Verification Checklist

After any FeatureToggle change, confirm:
- [ ] Function is under the correct `// MARK:` group in all 3 files
- [ ] MARK group order is consistent across all 3 files
- [ ] MockFeatureProvider has the property, init param, init body assignment, and conformance function
- [ ] No function is orphaned between unrelated MARK sections

---

## 3. AI Behavior Guide

Before acting on requests related to dark release or feature toggles, confirm intent:

| Trigger | AI Should Ask |
|---------|--------------|
| "delete dark release", "remove support feature", "remove dark release check" | Are you asking the backend to set this feature to "all" (full release), or do you actually want to remove this feature type from the frontend code? |
| "release to all users", "full rollout" | This should be handled by the backend setting the support feature to "all". The frontend doesn't need changes. Can you confirm? |
| "delete SupportFeature enum case" | Deleting the enum case means this feature can never be controlled via dark release again. Are you sure you want to permanently remove this feature's dark release mechanism? |

---

## 4. Dark Release Lifecycle

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

1. **Add Dark Release** -- Frontend adds `SupportFeature` enum case + `.contains()` check in `canView(for:)`; backend adds feature to specific organizations' support array.
2. **Gradual Rollout** -- Backend adds more organizations; frontend unchanged.
3. **Full Release** -- Backend sets feature to "all"; frontend unchanged; `.contains()` still returns `true`.
4. **(Optional) Remove Dark Release** -- Only with explicit user confirmation; remove `.contains()` check from frontend.

---

## 5. Implementation Checklist

### 5.1 Backend Enum Definition

**Location:** `VortexFeatures/Sources/VortexFeatures/Core/VortexBackend/Model/Organization/MyOrganization.swift`

```swift
public enum SupportFeature: String, VortexBackendModel {
    case yourNewFeature = "YourNewFeature"  // PascalCase, match backend exactly
}
```

### 5.2 `canView(for tab:)` -- Visibility

**Location:** `iOSCharmander/Common/FeatureProvider/FeatureToggle.swift`

**Check Order:** Dark Release (required) → Privilege check (optional)

```swift
// Dark release only:
case .yourFeature:
    myOrganizationSupportFeatures.contains(.yourNewFeature)

// With privilege check:
case .yourFeature:
    myOrganizationSupportFeatures.contains(.yourNewFeature) &&
    hasAnyDeviceWithPrivilege(.live)
```

**Available helpers** (already defined in FeatureToggle.swift):
```swift
private func hasAnyDeviceWithPrivilege(_ privilege: PrivilegeDeviceScope) -> Bool
private func hasDevicePrivilege(_ device: DeviceItem, _ privilege: PrivilegeDeviceScope) -> Bool
private func hasOrgPrivilege(_ privilege: PrivilegeOrganizationScope) -> Bool
```

**Privilege scopes reference:** `VortexFeatures/Sources/VortexFeatures/Core/VortexBackend/PrivilegeProvider/PrivilegeScope.swift`

### 5.3 `canAccess(for tab:)` -- Access Gating

Only add when there's a plan-level restriction:

```swift
case .yourFeature:
    !myOrganizationIsFreePlan
```

### 5.4 `canTrigger(for tab:)` -- Interaction

Default already handles most features. Only add a case if different logic is needed.

---

## 6. Check Priority Flow

```
canView(for:)      → Dark Release + Permissions  → false → Tab Hidden
       ↓ true
canAccess(for:)    → Plan/Subscription Check     → false → Show Promotion
       ↓ true
canTrigger(for:)   → License Phase Check         → false → Show Disabled
       ↓ true
                   → Show Active
```

---

## 7. Testing Checklist

- [ ] Feature hidden when organization doesn't have support flag
- [ ] Feature visible when organization has support flag
- [ ] Feature grayed out when license phase is `renewalOverdue`
- [ ] Feature works normally when all conditions met
- [ ] MARK group placement verified across all 3 files

---

## 8. Common Pitfalls

### Dark Release
- Do NOT delete `SupportFeature` enum case to "release" a feature -- full release is a backend operation.
- Do NOT remove frontend `.contains()` check to "release" a feature.

### MARK Grouping
- Do NOT place a function under the wrong MARK section just because it's nearby.
- Do NOT add a function to only FeatureToggle.swift -- update all 3 files.
- Do NOT forget MockFeatureProvider's 4 sync points (property, init param, init body, conformance).

### Permissions
- Do NOT add privilege checks to every feature -- only when role restriction is needed.
- Do NOT check license phase in `canView(for:)` -- license checks belong in `canTrigger(for:)`.
