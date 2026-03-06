## Context

The floor plan list screen currently uses the localized key `Floor_plan` for its navigation title, a layout grid icon (`iconGeneralLayout4ChLine`) for site headers, and the custom `searchable(text:isActive:)` has no search placeholder support. UX design wants to refine these three elements for improved clarity and visual consistency.

Current implementation:
- `FloorPlanTabView.swift` uses `.vortexPrimaryNavigation(navigationTitle: "Floor_plan", ...)`
- `FloorPlanSiteGroup.swift` uses `generalIcon: .iconGeneralLayout4ChLine` in `RoundedBackgroundDisclosureGroupIconTextLabel`
- `.searchable(text:isActive:)` in `CustomSearchBar.swift` has no `prompt` parameter

## Goals / Non-Goals

**Goals:**
- Change the navigation title to use a new `Floorplans` localization key (EN: "Floorplans", ZH-Hant/JA: same as `Floor_plan`)
- Replace site header icon with `iconGeneralLocationMark` (location pin)
- Extend `searchable(text:isActive:)` with a `prompt: LocalizedStringKey` parameter and use `Search_floor_plans_or_sites` key

**Non-Goals:**
- Modifying the existing `Floor_plan` localization key
- Modifying any floor plan detail, streaming, or device search behavior
- Changing the site header icon in ViewTab's `SiteView` (only FloorPlanSiteGroup)

## Decisions

### 1. New localization key for navigation title
**Decision**: Add a new `Floorplans` key to `Localizable.xcstrings` with EN="Floorplans" and ZH-Hant/JA translations reusing the same values as the existing `Floor_plan` key. Use this key via `LocalizedStringKey` in `.vortexPrimaryNavigation(navigationTitle:)`.
**Rationale**: Keeps the existing `Floor_plan` key untouched for other usages (e.g. tab bar). The new key allows the navigation title to have its own English text ("Floorplans") while preserving localized translations.

### 2. Icon swap via ImageResource
**Decision**: Change the `generalIcon` parameter from `.iconGeneralLayout4ChLine` to `.iconGeneralLocationMark` in `FloorPlanSiteGroup`.
**Rationale**: Direct `ImageResource` value swap. The `RoundedBackgroundDisclosureGroupIconTextLabel` component already accepts any `ImageResource`, so no component changes are needed.

### 3. Extend custom searchable with prompt support
**Decision**: Add `prompt: LocalizedStringKey = ""` parameter to the custom `searchable(text:isActive:)` extension in `CustomSearchBar.swift`, mirroring the API style of the existing `customSearchable`. When prompt is non-empty, convert via `prompt.toString()` and set on `searchController.searchBar.placeholder`.
**Rationale**: The custom `searchable(text:isActive:)` wraps UIKit's `UISearchController` and doesn't support SwiftUI's native `prompt` parameter. Adding it at the extension level keeps the API consistent with `customSearchable` and avoids breaking existing call sites (default is empty string = system default "Search" placeholder).

## Risks / Trade-offs

- [New localization key duplicates ZH-Hant/JA values from Floor_plan] → Acceptable; keeps keys independent and avoids side effects on other usages.
- [Only 3 language translations provided] → Other locales fall back to English base, which is acceptable per UX direction.
