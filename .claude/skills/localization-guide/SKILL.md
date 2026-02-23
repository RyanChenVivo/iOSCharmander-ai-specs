---
name: localization-guide
description: Use when adding user-facing text, editing Localizable.xcstrings, or writing String(localized:...) code. Triggers on countable nouns that may need pluralization.
---

# Localization Guide

## When to Use This Skill

Use this skill when you encounter any of these situations:

**Adding New User-Facing Text:**
- Creating new UI labels, buttons, alerts, or messages
- Adding text that users will see in the app
- Writing error messages or validation text

**Working with Localizable.xcstrings:**
- Adding new entries to the localization file
- Updating existing translations
- Modifying translation keys or values

**Trigger Patterns - You MUST use this skill when you see:**
- `String(localized: ...)` in Swift code
- References to `VortexEnvironment.productNameLocalized`
- Edits to `Localizable.xcstrings` file
- User requests containing: "add text", "localize", "translation", "user-facing string"
- String interpolation with parameters like `\(count)`, `\(name)`, etc.
- **Countable nouns in English text** (e.g., "X items", "Y users", "Z sites") - these may need pluralization

**Special Cases Requiring Extra Attention:**
- Strings containing product names (Vortex/CloudSight)
- Strings with multiple dynamic parameters
- **Countable items that may need plural forms** - when you see this, ASK the user if pluralization support is needed

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

**Rule:** When a string contains countable items that change based on quantity (e.g., "1 site" vs "2 sites"), use pluralization support in Localizable.xcstrings.

**When to Use:**
- English requires different forms for singular (1 item) vs plural (2+ items)
- Other languages may have different plural rules (e.g., Chinese/Japanese don't change form)

**IMPORTANT:** When you detect countable nouns in user-facing text, ASK the user:
> "This string contains a countable item. Do you want to add pluralization support so it displays '1 site' vs '2 sites' correctly in English?"

#### Swift Code Usage

```swift
// ✅ CORRECT: Use integer parameter directly
String(localized: "\(siteCount)_sites")

// The key "%lld_sites" in Localizable.xcstrings handles plural variations
```

#### Localizable.xcstrings Format

**Key pattern:** Use integer placeholder (`%lld`) in key name

```json
{
  "%lld_sites": {
    "localizations": {
      "en": {
        "variations": {
          "plural": {
            "one": {
              "stringUnit": {
                "state": "translated",
                "value": "%lld site"
              }
            },
            "other": {
              "stringUnit": {
                "state": "translated",
                "value": "%lld sites"
              }
            }
          }
        }
      },
      "zh-Hant": {
        "variations": {
          "plural": {
            "other": {
              "stringUnit": {
                "state": "translated",
                "value": "%lld 個站點"
              }
            }
          }
        }
      },
      "ja": {
        "variations": {
          "plural": {
            "other": {
              "stringUnit": {
                "state": "translated",
                "value": "%lld 件のサイト"
              }
            }
          }
        }
      }
    }
  }
}
```

**Plural Categories:**
- **English:** Uses `one` (for 1) and `other` (for 0, 2, 3, ...)
- **Chinese/Japanese:** Only needs `other` (no singular/plural distinction)
- Different languages have different plural rules (some have zero, few, many categories)

**Common Pluralization Patterns:**
- Counts: "X items", "Y users", "Z devices"
- Time units: "1 hour" vs "2 hours", "1 day" vs "3 days"
- Quantities: "1 file" vs "5 files"

---

### 5. Non-English Translations

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

## Implementation Checklist

When adding new localized strings:

- [ ] **Identify countable nouns** - If the string contains items that can be singular/plural, ask user if pluralization is needed
- [ ] **Create proper key format:**
  - Remove punctuation (`,`, `.`, `!`, `?`, `'`)
  - Replace spaces with underscores `_`
  - For plurals: use integer placeholder in key (e.g., `%lld_items`)
- [ ] **Handle product names** - Replace "Vortex"/"CloudSight" with `VortexEnvironment.productNameLocalized`
- [ ] **Use correct placeholder types:**
  - Strings: `%@` → Swift interpolation `\(stringVar)`
  - Integers: `%lld` → Swift interpolation `\(intVar)`
  - Multiple params: use positional (`%1$@`, `%2$ld`)
- [ ] **Add to Localizable.xcstrings:**
  - Set `extractionState: "manual"`
  - Add English translation with `state: "translated"`
  - For plurals: define `variations.plural` with `one` and `other` for English
- [ ] **Add other languages:**
  - Use English text as placeholder
  - Set `state: "needs_review"`
  - For plurals in Chinese/Japanese: only need `other` category
- [ ] **Verify in app:**
  - Test string appears correctly
  - Test with different product configs (Vortex vs CloudSight)
  - If plural: test with values 0, 1, 2, and large numbers

---

## Real-World Examples

### Example 1: Basic String

```swift
// "Settings"
String(localized: "Settings")
```

**Localizable.xcstrings:**
```json
{
  "Settings": {
    "extractionState": "manual",
    "localizations": {
      "en": {"stringUnit": {"state": "translated", "value": "Settings"}},
      "zh-Hant": {"stringUnit": {"state": "needs_review", "value": "Settings"}}
    }
  }
}
```

---

### Example 2: Product Name Placeholder

```swift
// "Welcome to Vortex"
// Key: "Welcome_to_%@"
String(localized: "Welcome_to_\(VortexEnvironment.productNameLocalized)")
```

**Localizable.xcstrings:**
```json
{
  "Welcome_to_%@": {
    "extractionState": "manual",
    "localizations": {
      "en": {"stringUnit": {"state": "translated", "value": "Welcome to %1$@"}},
      "zh-Hant": {"stringUnit": {"state": "needs_review", "value": "Welcome to %1$@"}}
    }
  }
}
```

---

### Example 3: Multiple Parameters

```swift
// "Connected 5 devices to Vortex"
// Key: "Connected_%ld_devices_to_%@"
String(localized: "Connected_\(deviceCount)_devices_to_\(VortexEnvironment.productNameLocalized)")
```

**Localizable.xcstrings:**
```json
{
  "Connected_%ld_devices_to_%@": {
    "extractionState": "manual",
    "localizations": {
      "en": {
        "stringUnit": {
          "state": "translated",
          "value": "Connected %1$ld devices to %2$@"
        }
      },
      "zh-Hant": {
        "stringUnit": {
          "state": "needs_review",
          "value": "Connected %1$ld devices to %2$@"
        }
      }
    }
  }
}
```

---

### Example 4: Pluralization

```swift
// "3 sites" or "1 site"
// Key: "%lld_sites"
String(localized: "\(siteCount)_sites")
```

**Localizable.xcstrings:**
```json
{
  "%lld_sites": {
    "extractionState": "manual",
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

**Testing:**
- siteCount = 0 → "0 sites"
- siteCount = 1 → "1 site" ✓
- siteCount = 2 → "2 sites" ✓

---

## Reference Implementation

See these files for real examples:
- `SignInView.userAgreement` - Product name placeholders and multiple parameters
- `Localizable.xcstrings` → Search for `%lld_sites` - Complete pluralization example
