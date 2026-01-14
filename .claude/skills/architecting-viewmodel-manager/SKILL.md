---
name: architecting-viewmodel-manager
description: Guides ViewModel and Manager layer decisions - where logic belongs, when to create a Manager, and data flow patterns. Use when creating ViewModels/Managers, asking "should this be in ViewModel or Manager?", or designing feature architecture.
---

# ViewModel & Manager Architecture Guide

## When to Use This Guide

- Creating a new ViewModel or Manager
- Asking "should this logic be in ViewModel or Manager?"
- Designing data flow for a new feature
- Refactoring existing code to proper layers
- Deciding whether you need a Manager at all

## Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│  View Layer                                                 │
│  SwiftUI Views - Pure UI, observes ViewModel                │
└─────────────────────────────────────────────────────────────┘
                              │ @State + @Observable (iOS 17+)
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  ViewModel Layer (@Observable @MainActor)                   │
│  UI State + User Interaction                                │
│  - Observable properties (no @Published needed)             │
│  - User action handlers                                     │
│  - Error presentation (handleError)                         │
└─────────────────────────────────────────────────────────────┘
                              │ @Dependency injection
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Manager Layer                                              │
│  Data Logic + Business Rules                                │
│  - API calls                                                │
│  - Data transformation (Backend → UI Model)                 │
│  - Shared data across ViewModels                            │
│  - Provides AsyncStream subscriptions                       │
└─────────────────────────────────────────────────────────────┘
                              │ @Dependency injection
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  API Layer (VortexRestfulApi / VortexApi)                   │
│  Network contracts - Pure network calls                     │
└─────────────────────────────────────────────────────────────┘
```

## Decision 1: Do You Need a Manager?

| Condition | Yes | No |
|-----------|:---:|:--:|
| Data shared across multiple ViewModels | ✓ Need Manager | |
| Complex data transformation | ✓ Need Manager | |
| Centralized API calls / caching needed | ✓ Need Manager | |
| Single screen, simple API call | | ✓ ViewModel + API |

**Anti-patterns:**
- ❌ ViewModel calls multiple APIs and combines data → Manager should handle
- ❌ Multiple ViewModels duplicate same fetching logic → Extract to Manager
- ❌ View needs lookup to render → Manager should pre-populate UI info

## Decision 2: Where Does Logic Belong?

| Logic Type | Layer | Reason |
|------------|-------|--------|
| Observable UI state | ViewModel | Screen-related |
| User tap/swipe handler | ViewModel | User interaction |
| Navigation decisions | ViewModel | UI flow |
| `handleError()` calls | ViewModel | Error presentation is UI responsibility |
| API calls | Manager | Data layer responsibility |
| Backend → UI Model transform | Manager | Data transformation |
| Pre-populate display info | Manager | Avoid View repeated lookups |
| Cross-feature shared data | Manager | Centralized management |
| throw error (don't handle) | Manager | Let ViewModel decide presentation |

## Decision 3: How to Separate Models?

```
Backend Model (API Layer)        UI Model (Presentation Layer)
─────────────────────────        ──────────────────────────────
- Matches API response           - Matches UI display needs
- Location: VortexBackend/Model/ - Location: Manager or Feature dir
- Decode only, no logic          - Can have computed properties
```

**Key Principle: UI Model should contain all info needed for rendering**

```
✗ Wrong: View lookups on every render
  position.deviceSerialNumber → viewModel.findDevice(byID:) → device.icon

✓ Correct: Manager pre-populates info into UI Model
  position.connectionIcon  (filled during Manager transformation)
```

## Decision 4: Data Flow Patterns

### Pattern A: Simple Fetch (One-time load)

```
ViewModel.loadData()
    → Manager.fetchXxx()
    → API.getXxx()
    → Returns [UIModel]
    → ViewModel updates observable state
```

Use for: One-time load, pull-to-refresh

### Pattern B: Reactive Stream (Continuous updates)

```
ViewModel.init()
    → Task { for await items in manager.xxxValues() { self.items = items } }

Manager internally:
    → @Published private var items
    → func xxxValues() → AsyncStream (from $items)
```

Use for: Data updates from multiple sources, real-time changes

### Pattern C: Manager as Central Data Source

```
TabViewModel ──subscribe──┐
                          ▼
DetailViewModel ─subscribe─→ Manager ←── API
                          ▲
SearchViewModel ─subscribe─┘
```

Use for: Multiple related ViewModels sharing same data, data consistency

## Quick Reference

### ViewModel Responsibilities (UI Layer)

- Observable state management (`@Observable`, no `@Published` needed)
- User interaction handlers
- Navigation decisions
- SwiftUI lifecycle (onAppear, onChange)
- Error presentation (`appManager.handleError`)
- Call Manager methods and update UI state

### Manager Responsibilities (Data Layer)

- All API calls
- Backend → UI Model transformation
- Pre-populate UI display info
- Provide AsyncStream for ViewModel subscription
- Business logic / validation
- throw errors (don't handle, let ViewModel decide)

## Implementation Details

For code patterns, DI registration, and error handling, see:
- `openspec/project.md` - Architecture Patterns section
- `openspec/project.md` - Manager & Dependency Layer Architecture section
