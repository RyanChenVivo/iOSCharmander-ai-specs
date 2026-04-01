## 1. Core — Path Name Resolution

- [x] 1.1 Add private `resolvePathComponents` method to `DeviceManager` that takes a `Site` and a `[String: Site]` lookup, walks the `parentId` chain with visited-set cycle protection, and returns `[String]` path components
- [x] 1.2 Update `DeviceManager.fetchAll()` to build `[String: Site]` lookup from API response, then pass path components to `SiteItem` constructor

## 2. Tests — Path Resolution (DeviceManagerTest)

- [x] 2.1 Update `TestUtility.makeSite` helper to accept optional `parentId` parameter (default `""`)
- [x] 2.2 Add `DeviceManagerTest` scenarios: top-level site keeps raw name, single-level subsite gets "Parent > Child", multi-level subsite gets full path, orphan parentId terminates gracefully, circular parentId terminates gracefully, default site sorts last regardless of path name

## 3. Compact Name — Model (SiteItem)

- [x] 3.1 Add `pathComponents: [String]` stored property to `SiteItem`. `name` is derived by joining `pathComponents` with separator in `init`. `pathComponents` is a required init parameter.
- [x] 3.2 Implement `compactName` as a computed property on `SiteItem` with budget-based algorithm: budget 18 chars, priority last > first > middle, last never truncated, first min 5 chars, middle budget equally divided — if per-middle budget < 2 collapse all to `…`, otherwise truncate each and return leftover to first.
- [x] 3.3 Refactor `compactName` into clearly named private methods: `compactTwoLayers`, `compactWithMiddles`, `compactCollapsedMiddles`, `canFitMiddles`, `budgetForMiddles`, `truncated`.

## 4. Compact Name — View (Phase 1: View tab only)

- [x] 4.1 Update `SiteRow` in `SiteView.swift` to use `site.compactName` instead of `site.name` for display text

## 5. Compact Name — Tests (SiteItemTest)

- [x] 5.1 Update `TestUtility.makeSiteItem` to accept optional `pathComponents` parameter (defaults to `[name]`)
- [x] 5.2 Add `SiteItemTest` scenarios for `compactName`: top-level equals name, 2-layer short keeps full, 2-layer long truncates first (min 5) + last full, 2-layer short first + long last keeps first intact, 3-layer with space truncates middle, 3-layer without space collapses middle to `…`, 4-layer collapses middle to `…`, exact limit keeps full, CJK characters
- [x] 5.3 Add `SiteItemTest` for `name` derivation: joins pathComponents with separator, single component equals component

## 6. Callsite Updates

- [x] 6.1 Update `DeviceManager.createSite()` to pass `[result.name]` as pathComponents
- [x] 6.2 Update `SiteItem` static constants (nvr, vss, bridge) to pass pathComponents
- [x] 6.3 Update `DeviceFilter.swift` Preview to pass pathComponents
- [x] 6.4 Update `iOSCharmanderTests/TestUtility.makeSiteItem` to pass pathComponents
