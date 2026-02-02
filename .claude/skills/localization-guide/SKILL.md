---
name: localization-guide
description: Add localized strings following project conventions. Use when adding user-facing text, creating new strings, or updating Localizable.xcstrings.
---

# Localization Guide

Use this skill when:
- Adding new user-facing strings
- Updating existing translations
- Handling product name placeholders
- Working with Localizable.xcstrings

## String Key Format Rules

### 1. Key Naming Convention

**Rule:** Remove special characters, punctuation, and spaces. Replace spaces with underscores.

```swift
// ✅ CORRECT
"Hello, World!" → Key: "Hello_World"
"User's Profile" → Key: "Users_Profile"
"Are you sure?" → Key: "Are_you_sure"
"Save & Continue" → Key: "Save_Continue"

// ❌ WRONG
"Hello, World!" → Key: "Hello, World!"  // Don't keep punctuation
"Hello, World!" → Key: "HelloWorld"     // Don't remove all spaces
```

**Character Handling:**
- Spaces → `_` (underscore)
- Punctuation (`,`, `.`, `!`, `?`, `'`) → Remove
- Special chars (`&`, `@`, `#`) → Remove
- Parentheses `()` → Remove

---

### 2. Product Name Placeholders

**Rule:** Replace product names ("Vortex" or "CloudSight") with placeholders.

#### Swift Code Usage

```swift
// ✅ CORRECT: Use VortexEnvironment.productNameLocalized
String(localized: "Welcome_to_\(VortexEnvironment.productNameLocalized)")

// ❌ WRONG: Hardcoded product name
String(localized: "Welcome to Vortex")
```

#### Localizable.xcstrings Format

**Key pattern:** Use `%@` for string placeholders

```json
{
  "Welcome_to_%@": {
    "extractionState": "manual",
    "localizations": {
      "en": {
        "stringUnit": {
          "state": "translated",
          "value": "Welcome to %1$@"
        }
      },
      "zh-Hant": {
        "stringUnit": {
          "state": "translated",
          "value": "歡迎使用 %1$@"
        }
      }
    }
  }
}
```

---

### 3. Multiple Parameters

**Rule:** Use positional placeholders: `%1$@`, `%2$@`, `%3$@` (strings) or `%1$ld`, `%2$ld` (integers)

#### Swift Code

```swift
// Multiple parameters
String(localized: "Welcome_to_\(VortexEnvironment.productNameLocalized)_with_\(deviceCount)_devices")
```

#### Localizable.xcstrings

**Key:** `"Welcome_to_%@_with_%ld_devices"`

```json
{
  "Welcome_to_%@_with_%ld_devices": {
    "localizations": {
      "en": {
        "stringUnit": {
          "value": "Welcome to %1$@ with %2$ld devices"
        }
      },
      "zh-Hant": {
        "stringUnit": {
          "value": "歡迎使用 %1$@，共有 %2$ld 個裝置"
        }
      }
    }
  }
}
```

**Parameter Types:**
- `%1$@`, `%2$@` - String parameters
- `%1$ld`, `%2$ld` - Integer/Long parameters
- `%1$f`, `%2$f` - Float parameters

---

### 4. Non-English Translations

**Rule:** Initially use English text, mark for review.

**Process:**
1. Add English string to all language versions
2. Mark translation status as **"Mark for review"** (需要審核)
3. Native speakers will review and update later

**Example in Localizable.xcstrings:**

```json
{
  "Your_New_Feature": {
    "extractionState": "manual",
    "localizations": {
      "en": {
        "stringUnit": {
          "state": "translated",
          "value": "Your New Feature"
        }
      },
      "zh-Hant": {
        "stringUnit": {
          "state": "needs_review",
          "value": "Your New Feature"  // English placeholder
        }
      },
      "ja": {
        "stringUnit": {
          "state": "needs_review",
          "value": "Your New Feature"  // English placeholder
        }
      }
    }
  }
}
```

---

## Quick Reference Examples

### Basic String

```swift
// English: "Settings"
// Key: "Settings"

String(localized: "Settings")
```

### String with Product Name

```swift
// English: "Sign in to Vortex"
// Key: "Sign_in_to_%@"

String(localized: "Sign_in_to_\(VortexEnvironment.productNameLocalized)")
```

### String with Multiple Parameters

```swift
// English: "You have 5 new alerts in Vortex"
// Key: "You_have_%ld_new_alerts_in_%@"

String(localized: "You_have_\(alertCount)_new_alerts_in_\(VortexEnvironment.productNameLocalized)")
```

---

## Implementation Checklist

When adding new localized strings:

- [ ] Create key by removing punctuation and replacing spaces with `_`
- [ ] Replace "Vortex"/"CloudSight" with `VortexEnvironment.productNameLocalized`
- [ ] Use positional placeholders (`%1$@`, `%2$ld`) for multiple parameters
- [ ] Add English translation with `state: "translated"`
- [ ] Add other languages with English text and `state: "needs_review"`
- [ ] Verify string appears correctly in app
- [ ] Test with different product configurations (Vortex vs CloudSight)

---

## Real-World Example: User Agreement

**Original English:** "By signing in, you agree to the Vortex Terms of Service and Privacy Policy"

### Step 1: Create Key
Remove punctuation, replace spaces:
```
Key: "By_signing_in_you_agree_to_the_%@_Terms_of_Service_and_Privacy_Policy"
```

### Step 2: Swift Code
```swift
String(localized: "By_signing_in_you_agree_to_the_\(VortexEnvironment.productNameLocalized)_Terms_of_Service_and_Privacy_Policy")
```

### Step 3: Localizable.xcstrings
```json
{
  "By_signing_in_you_agree_to_the_%@_Terms_of_Service_and_Privacy_Policy": {
    "extractionState": "manual",
    "localizations": {
      "en": {
        "stringUnit": {
          "state": "translated",
          "value": "By signing in, you agree to the %1$@ Terms of Service and Privacy Policy"
        }
      },
      "zh-Hant": {
        "stringUnit": {
          "state": "needs_review",
          "value": "By signing in, you agree to the %1$@ Terms of Service and Privacy Policy"
        }
      }
    }
  }
}
```

---

## Reference Implementation

See `SignInView.userAgreement` for a complete example of:
- Product name placeholder usage
- Multiple parameter handling
- Proper key naming
