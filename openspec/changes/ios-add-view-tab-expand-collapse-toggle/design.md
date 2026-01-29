# Design Document: iOS View Tab Expand/Collapse Toggle

## Overview

This document describes the architectural design for implementing expand/collapse all functionality in the iOS Charmander app's View Tab, adapting the web specification to iOS platform conventions.

## Current Architecture

### View Hierarchy
```
ViewTabView (Main container)
  ├── NavigationStack
  │   ├── NoticeBanner
  │   ├── ScrollView
  │   │   ├── exportingRow
  │   │   └── sites (SiteList)
  │   │       └── ViewTabSiteView
  │   │           └── FlexibleVGrid<SiteItem>
  │   │               └── RoundedBackgroundDisclosureGroup (per site)
  │   │                   ├── SiteRow (label)
  │   │                   └── FlexibleVGrid<DeviceItem> (content)
  │   └── trailingButtons (Navigation bar)
  │       ├── Reseller hint button (conditional)
  │       ├── Search button
  │       └── List/Grid toggle button
```

### Current State Management

**Component-Level State:**
```swift
struct RoundedBackgroundDisclosureGroup<Label, Content>: View {
    @State var isExpanded = true  // ❌ Internal state, no external control
    @ViewBuilder let content: () -> Content
    @ViewBuilder let label: () -> Label
}
```

**Problem:** Each `RoundedBackgroundDisclosureGroup` manages its own state independently. No way to coordinate expansion/collapse across multiple groups.

### Existing Persistence Pattern

**Reference Implementation:** `view_tab_list_mode` (List/Grid toggle)

```swift
// In Defaults.shared (MyAppStorage.swift)
@AppStorage(UserDefaultsKey.view_tab_list_mode.rawValue)
public var view_tab_list_mode: Bool = true

// In ViewTabView.swift
@MyAppStorage(\.view_tab_list_mode) private var isListMode
```

## Proposed Design

### Design Principles

1. **Minimal Changes:** Modify only what's necessary, maintain backward compatibility
2. **Follow Existing Patterns:** Use `@MyAppStorage` like `view_tab_list_mode`
3. **SwiftUI-Native:** Leverage `@AppStorage` for automatic persistence and reactivity
4. **Performance-First:** Use SwiftUI's built-in optimizations (lazy loading, animation)

### Architecture Decisions

#### Decision 1: View-Layer vs ViewModel State Management

**Options Considered:**

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| A: View-layer `@MyAppStorage` | Simple, automatic UI sync, follows `view_tab_list_mode` pattern | Less testable, violates MVVM slightly | ✅ **Selected** |
| B: ViewModel-managed state | Better testability, cleaner MVVM | More complexity, manual sync needed | ❌ Rejected |
| C: Environment object | Centralized state | Over-engineering for simple boolean | ❌ Rejected |

**Rationale:** Option A matches existing architecture for similar UI state (`view_tab_list_mode`), requires minimal code changes, and SwiftUI handles all synchronization automatically.

#### Decision 2: DisclosureGroup State Control

**Problem:** `RoundedBackgroundDisclosureGroup` uses `@State` internally, preventing external control.

**Solution:** Support both internal `@State` and external `@Binding`:

```swift
struct RoundedBackgroundDisclosureGroup<Label, Content>: View {
    @Binding var isExpanded: Bool  // Changed from @State to @Binding
    @ViewBuilder let content: () -> Content
    @ViewBuilder let label: () -> Label

    // NEW: Primary initializer with external binding
    init(isExpanded: Binding<Bool>,
         @ViewBuilder content: @escaping () -> Content,
         @ViewBuilder label: @escaping () -> Label) {
        self._isExpanded = isExpanded
        self.content = content
        self.label = label
    }

    // NEW: Backward-compatible initializer for existing code
    init(@ViewBuilder content: @escaping () -> Content,
         @ViewBuilder label: @escaping () -> Label) {
        self._isExpanded = .constant(true)
        self.content = content
        self.label = label
    }
}
```

**Trade-offs:**
- ✅ Backward compatible (existing code continues to work)
- ✅ Enables external control for new use cases
- ⚠️ Slight API complexity (two initializers)

#### Decision 3: Unified vs Per-Site State

**Options:**

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A: Single boolean for all sites | `allExpanded: Bool` | Simple, matches spec requirement | Can't remember individual site states |
| B: Dictionary per site | `siteStates: [SiteID: Bool]` | Granular control | Complex, not required by spec |

**Selected:** Option A - Single unified boolean

**Rationale:** Spec requires "expand all" or "collapse all" - no mixed state persistence needed.

#### Decision 4: Default State

**Selected:** `view_tab_expand_all_sites: Bool = true` (expanded)

**Rationale:**
- Matches current behavior (groups start expanded)
- Spec requirement: "default to expanded state"
- Better discoverability for new users

### Data Flow

```
User taps button
    ↓
withAnimation { allExpanded.toggle() }
    ↓
@AppStorage writes to UserDefaults (async, non-blocking)
    ↓
SwiftUI detects @MyAppStorage change
    ↓
ViewTabSiteView re-renders
    ↓
All RoundedBackgroundDisclosureGroup bindings update
    ↓
Groups animate expand/collapse
```

### Component Changes

#### 1. Storage Layer

**File:** `UserDefaultsKey.swift`
```swift
public enum UserDefaultsKey: String, Sendable {
    // ... existing keys ...
    case view_tab_expand_all_sites  // ← NEW
}
```

**File:** `MyAppStorage.swift`
```swift
public final class Defaults: ObservableObject, @unchecked Sendable {
    // ... existing properties ...
    @AppStorage(UserDefaultsKey.view_tab_expand_all_sites.rawValue)
    public var view_tab_expand_all_sites: Bool = true  // ← NEW
}
```

#### 2. Component Layer

**File:** `RoundedBackgroundDisclosureGroup.swift`

**Before:**
```swift
struct RoundedBackgroundDisclosureGroup<Label, Content>: View {
    @State var isExpanded = true
    // ...
}
```

**After:**
```swift
struct RoundedBackgroundDisclosureGroup<Label, Content>: View {
    @Binding var isExpanded: Bool

    init(isExpanded: Binding<Bool>, ...) { /* new */ }
    init(@ViewBuilder content: ...) { /* backward compatible */ }
}
```

#### 3. View Layer

**File:** `ViewTabSiteView.swift`

**Before:**
```swift
struct ViewTabSiteView: View {
    var body: some View {
        VStack(spacing: 0) {
            FlexibleVGrid(items: deviceManager.sites) { site in
                RoundedBackgroundDisclosureGroup {  // ← No state control
                    // content
                } label: {
                    SiteRow(site: site, onSiteTapped: onSiteTapped)
                }
            }
        }
    }
}
```

**After:**
```swift
struct ViewTabSiteView: View {
    @MyAppStorage(\.view_tab_expand_all_sites) private var allExpanded  // ← NEW

    var body: some View {
        VStack(spacing: 0) {
            FlexibleVGrid(items: deviceManager.sites) { site in
                RoundedBackgroundDisclosureGroup(isExpanded: $allExpanded) {  // ← Bound
                    // content
                } label: {
                    SiteRow(site: site, onSiteTapped: onSiteTapped)
                }
            }
        }
    }
}
```

**File:** `ViewTabView.swift`

**Before:**
```swift
private var trailingButtons: some View {
    HStack(spacing: 0) {
        // Reseller hint button
        NavigationBarSearchButton { ... }
        NavigationBarImageButton(image: isListMode ? .iconGeneralGridSolid : .iconGeneralListSolid) { ... }
    }
}
```

**After:**
```swift
@MyAppStorage(\.view_tab_expand_all_sites) private var allExpanded  // ← NEW

private var trailingButtons: some View {
    HStack(spacing: 0) {
        // Reseller hint button
        NavigationBarSearchButton { ... }

        // ← NEW: Expand/Collapse toggle
        NavigationBarImageButton(
            image: allExpanded ? .iconGeneralArrowTopSolid : .iconGeneralArrowBottomSolid
        ) {
            withAnimation {
                allExpanded.toggle()
            }
        }
        .accessibilityIdentifier("navigationExpandCollapseButton")

        NavigationBarImageButton(image: isListMode ? .iconGeneralGridSolid : .iconGeneralListSolid) { ... }
    }
}
```

## Performance Considerations

### SwiftUI Optimizations

1. **Lazy Loading:** `FlexibleVGrid` only renders visible items
2. **Diffing:** SwiftUI re-renders only changed views
3. **Animation Batching:** `withAnimation` batches all state changes in single render pass

### Benchmarks (Expected)

| Scenario | Expected Performance |
|----------|---------------------|
| 10 sites | < 100ms, 60fps animation |
| 50 sites | < 500ms, 60fps animation |
| 100 sites | < 2s, possible frame drops |

**Mitigation for 100+ sites:** SwiftUI's lazy rendering should handle this, but if performance issues arise, can add:
- `.task` delay for animation
- Separate animation for visible vs off-screen items

### UserDefaults Write Performance

- **UserDefaults.set()** is asynchronous - writes to disk don't block UI
- `@AppStorage` batches writes automatically
- No manual optimization needed

## Error Handling

### UserDefaults Read Failure
- **Scenario:** Key doesn't exist (first launch)
- **Handling:** Default value `true` automatically applied by `@AppStorage`

### UserDefaults Write Failure
- **Scenario:** Disk full, permissions issue (extremely rare on iOS)
- **Handling:** Silent failure is acceptable - user sees immediate UI feedback regardless

### Animation Interruption
- **Scenario:** User rapidly taps toggle button
- **Handling:** SwiftUI's `withAnimation` automatically cancels previous animation and starts new one

## Testing Strategy

### Unit Tests
```swift
class RoundedBackgroundDisclosureGroupTests: XCTestCase {
    func testExternalBinding() {
        let binding = Binding<Bool>(get: { true }, set: { _ in })
        let group = RoundedBackgroundDisclosureGroup(isExpanded: binding) {
            Text("Content")
        } label: {
            Text("Label")
        }
        // Assert binding works
    }

    func testBackwardCompatibility() {
        let group = RoundedBackgroundDisclosureGroup {
            Text("Content")
        } label: {
            Text("Label")
        }
        // Assert still works without binding
    }
}
```

### Integration Tests
```swift
class ViewTabExpandCollapseTests: XCTestCase {
    func testToggleAffectsAllSites() async {
        let viewModel = ViewTabViewModel.make()
        let view = ViewTabView(viewModel: viewModel, showSearchBar: .constant(false))

        // Simulate button tap
        // Assert all disclosure groups change state
    }
}
```

### UI Tests
```swift
class ViewTabUITests: XCTestCase {
    func testExpandCollapseButton() {
        let app = XCUIApplication()
        app.launch()

        let expandButton = app.buttons["navigationExpandCollapseButton"]
        XCTAssertTrue(expandButton.exists)

        expandButton.tap()
        // Assert all groups collapsed

        expandButton.tap()
        // Assert all groups expanded
    }
}
```

## Migration Strategy

### Phase 1: Storage + Component (Non-Breaking)
- Add UserDefaults key
- Modify `RoundedBackgroundDisclosureGroup` with backward-compatible API
- **Risk:** Low - backward compatible changes only

### Phase 2: View Layer Integration
- Update `ViewTabSiteView` to use binding
- **Risk:** Low - isolated to View Tab

### Phase 3: UI Button
- Add toggle button to navigation bar
- **Risk:** Low - additive change only

### Rollback Plan
If issues arise:
1. Remove toggle button from UI (revert Phase 3)
2. Revert `ViewTabSiteView` binding (revert Phase 2)
3. DisclosureGroup changes remain (backward compatible, no harm)

## Open Questions

### Q1: Should toggle button be disabled when no sites exist?
**Answer:** No - keep button enabled for consistency. Clicking has no visual effect, which is acceptable.

### Q2: Icon choice - use existing or create new?
**Recommendation:** Start with existing icons (`.iconGeneralArrowTopSolid` / `.iconGeneralArrowBottomSolid`). If UX feedback suggests need for custom icons (e.g., expand/collapse-specific), create new assets in Phase 2.

### Q3: Should search results respect the toggle?
**Answer:** Yes - `ViewTabSiteSearchingView` should use same binding for consistency.

### Q4: Animation duration?
**Answer:** Use SwiftUI default (`.snappy` is already used in `RoundedBackgroundDisclosureGroupStyle`). No custom duration needed.

## Success Criteria

1. ✅ Toggle button appears in View Tab navigation bar
2. ✅ Clicking button expands/collapses all site groups with animation
3. ✅ State persists across app launches
4. ✅ Default state is "expanded" for new users
5. ✅ No breaking changes to existing components
6. ✅ Performance meets spec: < 2s for 50+ sites
7. ✅ All tests pass (unit + integration + UI)
8. ✅ Accessibility: VoiceOver reads button state correctly

## References

- Web Spec: `/Users/ryanchen/code/VIVOTEK/agentic-development-alignment-taskforce/docs/openspec/changes/add-view-page-expand-collapse-toggle`
- Similar Implementation: `view_tab_list_mode` in `ViewTabView.swift`
- SwiftUI Documentation: [@AppStorage](https://developer.apple.com/documentation/swiftui/appstorage)
- iOS UserDefaults: [UserDefaults Documentation](https://developer.apple.com/documentation/foundation/userdefaults)
