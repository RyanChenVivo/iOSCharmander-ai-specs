---
name: localization-guide
description: "MANDATORY before any Edit/Write to Localizable.xcstrings or any .swift file containing localized strings (LocalizedStringKey, String(localized:), VortexEnvironment.productNameLocalized). Also use when adding/changing user-facing text — promotion pages, alerts, buttons, labels. Triggers on: product names (Vortex/CloudSight) in strings, countable nouns needing pluralization, xcstrings key creation."
---

# Localization Guide

## When to Use This Skill

**You MUST use this skill when:**
- Working with `String(localized: ...)` or `VortexEnvironment.productNameLocalized`
- Editing `Localizable.xcstrings` file
- Adding any user-facing text (UI labels, buttons, alerts, errors)
- String contains countable nouns ("X items", "Y sites") → ASK user if pluralization needed
- Multiple dynamic parameters in text

---

## Core Rules

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

### 4. Pluralization

**Rule:** For countable items ("1 site" vs "2 sites"), use pluralization in Localizable.xcstrings.

**When you detect countable nouns, ASK user:** "Do you want pluralization support for '1 site' vs '2 sites'?"

#### Swift Code
```swift
String(localized: "\(siteCount)_sites")  // Key handles plural variations
```

#### Localizable.xcstrings - Use `%lld` in key

```json
{
  "%lld_sites": {
    "localizations": {
      "en": {
        "variations": {
          "plural": {
            "one": {"stringUnit": {"state": "translated", "value": "%lld site"}},
            "other": {"stringUnit": {"state": "translated", "value": "%lld sites"}}
          }
        }
      },
      "zh-Hant": {
        "variations": {
          "plural": {
            "other": {"stringUnit": {"state": "translated", "value": "%lld 個站點"}}
          }
        }
      }
    }
  }
}
```

**Language-specific rules:**
- **English:** `one` (1) and `other` (0, 2+)
- **Chinese/Japanese:** Only `other` (no singular/plural distinction)

---

### 5. Non-English Translations

**Rule:** Use English text as placeholder, set `state: "needs_review"` for non-English languages. Native speakers will translate later.

---

## Implementation Checklist

- [ ] Identify countable nouns → Ask user if pluralization needed
- [ ] Create key: Remove punctuation, replace spaces with `_`, use `%lld` for plurals
- [ ] Replace product names with `VortexEnvironment.productNameLocalized`
- [ ] Use placeholders: `%@` (string), `%lld` (int), `%1$@/%2$ld` (multiple params)
- [ ] Add to xcstrings: `extractionState: "manual"`, English `state: "translated"`
- [ ] Add other languages: English placeholder, `state: "needs_review"`
- [ ] For plurals: English needs `one` and `other`, Chinese/Japanese only `other`
- [ ] Verify: Test display, product configs, plural values (0, 1, 2, large numbers)

---

## Reference

**Real codebase examples:**
- `SignInView.userAgreement` - Product name placeholders and multiple parameters
- `Localizable.xcstrings` → Search for `%lld_sites` - Pluralization implementation
