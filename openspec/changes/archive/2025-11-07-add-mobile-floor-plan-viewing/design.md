# Mobile Floor Plan Viewing - Design Document

## Context

The iOS mobile app needs to add floor plan viewing capabilities that complement the existing web-based floor plan management system. This feature enables mobile users (security operators, facility managers) to monitor camera deployments within the spatial context of their facilities while on the go.

**Background:**
- Web platform provides full floor plan CRUD operations with editing capabilities
- Mobile users need read-only monitoring, not configuration
- Existing app has established patterns for tab navigation, modal presentation, and data management
- Device management infrastructure already exists via `DeviceManager`

**Constraints:**
- iOS 17.0+ minimum deployment
- SwiftUI-only codebase (no UIKit)
- Must follow existing MVVM architecture with dependency injection
- Backend API provides floor plan data (read-only GET endpoints)
- Single concurrent live stream limitation (platform constraint)
- Max 10 floor plans per site (backend enforced)

**Stakeholders:**
- End users: Security operators, facility managers needing on-site monitoring
- Development team: Requires maintainable, testable code following project conventions
- Backend team: Provides floor plan API endpoints

## Goals / Non-Goals

**Goals:**
- Enable mobile users to view floor plans with camera positions in spatial context
- Provide quick access to live camera streams from floor plan interface
- Support touch-optimized zoom/pan interactions for floor plan exploration
- Integrate seamlessly with existing app navigation and data patterns
- Maintain performance with multiple camera overlays
- Support offline viewing with cached data

**Non-Goals:**
- Floor plan creation, editing, or deletion (web-only functionality)
- Camera positioning via drag-and-drop (desktop precision required)
- FOV configuration editing (complex UI, web-only)
- Multi-camera simultaneous streaming (platform limitation)
- Augmented reality (AR) camera positioning (future enhancement)
- Real-time camera position updates via WebSocket (v1 uses polling)

## Decisions

### Decision 1: SheetManager for Floor Plan Detail Presentation

**What:** Use `SheetManager.openFloorPlanDetail()` for full-screen modal presentation instead of NavigationStack push.

**Why:**
- **Consistency:** Aligns with existing app patterns for detail views (e.g., `openArchiveFileDetail`, `openMultipleView`)
- **Landscape support:** SheetManager provides `supportOrientation: true` parameter for landscape viewing
- **Simplified navigation:** No NavigationStack needed in FloorPlanTabView, reducing complexity
- **Modal hierarchy:** Enables nested modals (floor plan detail → streaming view)
- **Centralized control:** All modal presentations managed through single SheetManager instance

**Alternatives considered:**
- **NavigationStack push:** Would require NavigationStack wrapper in FloorPlanTabView, less consistent with existing patterns, more complex state management
- **Custom modal presentation:** Would duplicate SheetManager functionality, harder to maintain

**Trade-offs:**
- ✅ Pro: Consistent with 10+ existing modal presentations in app
- ✅ Pro: Automatic orientation and dismiss handling
- ⚠️ Con: Another modal in stack (acceptable, follows existing pattern)

### Decision 2: FloorPlanManager Singleton Pattern

**What:** Create new `FloorPlanManager` following same singleton pattern as existing `DeviceManager`.

**Why:**
- **Consistency:** Mirrors established `DeviceManager` architecture
- **Centralized state:** Single source of truth for floor plan data across app
- **Dependency injection:** Uses `@Dependency` macro for testability
- **Reactive updates:** `@Published` properties enable automatic UI updates
- **Caching:** Memory cache for floor plans and device positions reduces API calls

**Alternatives considered:**
- **Extend DeviceManager:** Would violate single responsibility principle, DeviceManager already complex
- **ViewModel-only data:** Would duplicate data fetching logic across multiple ViewModels
- **Repository pattern:** Over-engineered for read-only use case

**Trade-offs:**
- ✅ Pro: Developers already familiar with DeviceManager pattern
- ✅ Pro: Testable via dependency injection
- ✅ Pro: Reusable across potential future floor plan features
- ⚠️ Con: Another singleton (acceptable, follows project convention)

### Decision 3: Reuse DeviceManager for Camera Data

**What:** Use existing `DeviceManager.shared.sites` and `DeviceManager.findDevice()` for site list and camera information instead of duplicating.

**Why:**
- **Single source of truth:** Sites and devices already managed by DeviceManager
- **Real-time updates:** DeviceManager handles device state changes via backend notifications
- **No duplication:** Avoids syncing duplicate device data
- **Consistent status:** Camera online/offline status matches rest of app

**Alternatives considered:**
- **Duplicate site/device data in FloorPlanManager:** Would cause sync issues, violate DRY principle
- **Fetch fresh device data per floor plan:** Unnecessary API calls, slower performance

**Trade-offs:**
- ✅ Pro: Leverages existing, tested infrastructure
- ✅ Pro: Automatic status updates when devices change state
- ✅ Pro: Zero data duplication
- ⚠️ Con: Dependency on DeviceManager (acceptable, it's core infrastructure)

### Decision 4: Normalized Coordinates (0-1) for Camera Positions

**What:** Store camera positions as normalized coordinates (0.0 to 1.0) relative to floor plan dimensions.

**Why:**
- **Resolution independence:** Works across different image sizes and device screens
- **Zoom invariant:** Positions remain accurate at any zoom level
- **Backend alignment:** Matches web platform's coordinate system
- **Simple scaling:** Multiply by actual image width/height to get pixel positions

**Alternatives considered:**
- **Absolute pixel coordinates:** Would break on different floor plan resolutions
- **Percentage strings:** Less type-safe, requires parsing

**Trade-offs:**
- ✅ Pro: Works universally across image sizes
- ✅ Pro: Simple calculation in UI layer
- ⚠️ Con: Requires coordinate conversion (minimal cost)

### Decision 5: Two-Tier Device Interaction (Tap + Long-Press)

**What:**
- **Tap:** Selects device, shows info panel with details
- **Long-press (0.5s):** Opens live streaming view

**Why:**
- **Discoverability:** Tap is intuitive first interaction, reveals streaming option
- **Prevents accidents:** Long-press prevents accidental stream opening (network/battery intensive)
- **Progressive disclosure:** Info panel educates users about long-press for streaming
- **Touch target size:** Easier to tap small markers than long-press reliably

**Alternatives considered:**
- **Single tap for streaming:** Too easy to trigger accidentally, no way to see device info without streaming
- **Info button + stream button:** Clutters UI with small buttons on markers, poor touch target size
- **Tap for info, separate stream button in panel:** Extra step, less direct

**Trade-offs:**
- ✅ Pro: Intuitive two-step interaction model
- ✅ Pro: Info panel hints at streaming capability
- ⚠️ Con: Requires user education (mitigated by hint text)

### Decision 6: Lazy Loading of Device Positions

**What:** Fetch device positions only when floor plan detail view opens, not when loading floor plan list.

**Why:**
- **Performance:** Reduces initial data load, faster list display
- **Network efficiency:** Only fetches positions for viewed floor plans
- **Memory efficiency:** Doesn't cache positions for all floor plans upfront
- **User-driven:** Loads data when user demonstrates interest

**Alternatives considered:**
- **Eager load all positions:** Would slow initial tab load, waste bandwidth
- **Background prefetch:** Complex, unclear benefit given fast API responses

**Trade-offs:**
- ✅ Pro: Fast floor plan list display
- ✅ Pro: Efficient network and memory usage
- ⚠️ Con: Brief loading state in detail view (acceptable, with spinner)

### Decision 7: SwiftUI ScrollView + Gestures for Zoom/Pan

**What:** Use native SwiftUI `ScrollView` with `MagnificationGesture` and `DragGesture` for zoom/pan instead of custom implementation.

**Why:**
- **Native behavior:** Users expect iOS-standard zoom/pan interactions
- **Simple implementation:** SwiftUI provides gesture recognition out-of-box
- **Accessibility:** Built-in accessibility support for gestures
- **Performance:** Hardware-accelerated by system

**Alternatives considered:**
- **Custom gesture recognizers:** More code, reinvents wheel, worse accessibility
- **UIScrollView bridge:** Violates SwiftUI-only constraint, adds complexity
- **Third-party zoom library:** Unnecessary dependency for solved problem

**Trade-offs:**
- ✅ Pro: Leverages battle-tested iOS zoom/pan behavior
- ✅ Pro: Minimal code, high maintainability
- ⚠️ Con: Limited customization (acceptable, standard behavior is ideal)

### Decision 8: FeatureToggle Remote Config Control

**What:** Control Floor Plan tab visibility via remote config flag `feature_floor_plan` with additional permission and license checks.

**Why:**
- **Gradual rollout:** Can enable for subset of users during beta
- **Kill switch:** Can disable if critical issues discovered
- **A/B testing:** Can test impact on engagement metrics
- **Follows pattern:** Consistent with other feature flags in app

**Alternatives considered:**
- **Hardcoded always-on:** No rollout control, risky for new feature
- **App version gating:** Requires app release to change, inflexible

**Trade-offs:**
- ✅ Pro: Safe, controllable rollout
- ✅ Pro: Instant disable if needed
- ⚠️ Con: Requires backend config management (already in place)

## Risks / Trade-offs

### Risk 1: Performance with Large Floor Plans
**Risk:** Large floor plan images (approaching 10 MB) may cause memory pressure or slow rendering.

**Mitigation:**
- Use AsyncImage for efficient loading and caching
- Test with max-size images during development
- Monitor memory usage via Instruments
- Consider progressive JPEG loading if needed (future optimization)

### Risk 2: Touch Target Size for Camera Markers
**Risk:** Camera markers may be too small for reliable touch interaction, especially when many cameras are clustered.

**Mitigation:**
- Use 44x44pt minimum touch target size (iOS HIG guideline)
- Extend touch area beyond visible marker
- Test with real floor plans containing many cameras
- Consider clustering UI for dense areas (future enhancement)

### Risk 3: Offline Data Freshness
**Risk:** Cached floor plans may become stale if not updated regularly.

**Mitigation:**
- Display "Last updated" timestamp on cached data
- Implement pull-to-refresh for manual updates
- Clear cache on logout
- Consider TTL-based auto-refresh (future optimization)

### Risk 4: FOV Sector Rendering Accuracy
**Risk:** FOV sectors may not align perfectly with camera markers at all zoom levels.

**Mitigation:**
- Use SwiftUI Path with normalized coordinates
- Test FOV rendering at multiple zoom levels
- Verify with VIVOTEK team that coordinate systems match
- Document any known limitations

### Risk 5: Single Stream Limitation UX
**Risk:** Users may be frustrated by inability to view multiple streams simultaneously.

**Mitigation:**
- Clear error message if user tries to open second stream
- Info panel hints at streaming capability before opening
- Future: Consider grid view for multiple streams (separate feature)

## Migration Plan

**Phase 1: Foundation (Week 1)**
1. Add Floor Plan tab to navigation (hidden behind feature flag)
2. Create data models and API integration
3. Implement FloorPlanManager with basic fetching

**Phase 2: List View (Week 2)**
4. Build floor plan list UI with site hierarchy
5. Implement search and filtering
6. Add pull-to-refresh and offline support

**Phase 3: Detail View (Week 3)**
7. Implement floor plan detail modal with zoom/pan
8. Add camera marker overlays with status colors
9. Render FOV sectors

**Phase 4: Interactions (Week 4)**
10. Implement device selection with info panel
11. Add long-press for streaming integration
12. Polish gestures and animations

**Phase 5: Testing & Rollout (Week 5)**
13. Unit tests for ViewModels and Manager
14. UI tests for navigation flows
15. Enable feature flag for internal beta
16. Collect feedback and iterate

**Rollback Plan:**
- Disable `feature_floor_plan` remote config flag
- Floor Plan tab disappears from navigation
- No data migration needed (read-only feature)
- No breaking changes to existing functionality

## Open Questions

1. **Should we support SVG floor plans in v1?**
   - SVG provides infinite zoom quality
   - Requires SVG rendering library or WebView
   - **Decision:** Support both JPEG and SVG via AsyncImage; SVG may require additional handling

2. **Should we show camera snapshots in markers?**
   - Provides visual confirmation of camera view
   - Increases network traffic and memory
   - **Decision:** No for v1; use icon + status color. Consider for v2.

3. **Should we support filtering cameras by status?**
   - Useful for finding offline cameras
   - Adds UI complexity to floor plan view
   - **Decision:** No for v1; use search in floor plan list. Consider for v2.

4. **Should we pre-cache floor plan images?**
   - Improves offline experience
   - Increases storage usage
   - **Decision:** Rely on AsyncImage's automatic caching for v1. Monitor cache behavior.

5. **Should we support multiple floor plan views (stacked buildings)?**
   - Some facilities have multi-story layouts
   - Backend API supports, but adds navigation complexity
   - **Decision:** Yes, via site expansion; each floor plan is separate. User navigates between them via list.
