## Why

UX design has updated the floor plan list screen with minor refinements to improve naming consistency, iconography, and search placeholder text across all supported languages.

## What Changes

- Add a new localization key `Floorplans` for the navigation title (EN: "Floorplans", ZH-Hant/JA: reuse existing `Floor_plan` translations)
- Replace the site header icon in the floor plan list from `iconGeneralLayout4ChLine` to `iconGeneralLocationMark`
- Extend the custom `searchable(text:isActive:)` to support a `prompt` parameter (`LocalizedStringKey`)
- Add a new localized search placeholder string `Search_floor_plans_or_sites` with translations for English, Traditional Chinese, and Japanese

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `mobile-floor-plan-viewing`: Navigation title uses new `Floorplans` localization key, site header icon changes to location mark, and search placeholder text is updated with new localized string

## Impact

- **UI**: `FloorPlanTabView.swift` - navigation title key and search prompt
- **UI**: `FloorPlanSiteGroup.swift` - site header icon
- **Component**: `CustomSearchBar.swift` - `searchable(text:isActive:)` extended with `prompt: LocalizedStringKey` parameter
- **Localization**: `Localizable.xcstrings` - new `Floorplans` and `Search_floor_plans_or_sites` keys
