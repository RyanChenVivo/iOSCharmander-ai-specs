---
name: swift-coding-standards
description: Swift coding standards - quick reference with on-demand detailed guides
---

# Swift Coding Standards - Quick Reference

## 🎯 Top 10 Critical Rules (MUST FOLLOW)

1. ❌ **Never force unwrap** → use `guard let` / `if let`
2. 🔄 **Use `[weak self]` in closures** → avoid retain cycles  
3. 📦 **Prefer value types** → `struct` over `class` for data
4. 🔒 **Type-safe enums** → no stringly-typed code
5. 🧊 **Immutable by default** → `let` over `var`
6. ⚠️ **Typed error handling** → enum-based errors
7. ⚡ **Async/await** → no completion handlers
8. 🎨 **@MainActor for UI** → explicit UI thread
9. 🧩 **Protocol-oriented** → composition over inheritance
10. 🧪 **Dependency injection** → testable code

## 📚 How AI Should Use This Guide

### When to Load Full Details:

| Task | Load From | Search Keywords |
|------|-----------|-----------------|
| Optional handling issues | `reference/language.md` | `optional`, `guard`, `if let` |
| SwiftUI view architecture | `reference/swiftui.md` | `@State`, `View`, `body` |
| Memory leak debugging | `reference/memory.md` | `weak`, `retain cycle`, `ARC` |
| Code review/refactoring | `reference/anti-patterns.md` | Force unwrap, magic numbers |

### Quick Loading Command:
```bash
# Use view tool to load specific reference
@view .copilot/skills/swift-coding-standards/reference/language.md
@view .copilot/skills/swift-coding-standards/reference/swiftui.md
@view .copilot/skills/swift-coding-standards/reference/memory.md
@view .copilot/skills/swift-coding-standards/reference/anti-patterns.md
```

---

## 🚀 Essential Patterns (Most Frequently Used)

### Optional Handling

```swift
// ✅ ALWAYS: Guard let for early exit
guard let device else { return }

// ✅ ALWAYS: Nil coalescing for defaults
let name = device?.name ?? "Unknown"

// ✅ ALWAYS: Optional chaining
let url = device?.stream?.thumbnailURL

// ❌ NEVER: Force unwrap
let device = list.first!  // Will crash!
```

### Error Handling

```swift
// ✅ ALWAYS: Typed errors
enum DeviceError: LocalizedError {
    case notFound(id: String)
    case connectionFailed(reason: String)
    
    var errorDescription: String? {
        switch self {
        case .notFound(let id): return "Device \(id) not found"
        case .connectionFailed(let reason): return "Connection failed: \(reason)"
        }
    }
}

// ❌ NEVER: Swallow errors silently
catch { /* empty */ }

// ❌ NEVER: Generic errors
throw NSError(domain: "Error", code: -1, userInfo: nil)
```

### Memory Management  

```swift
// ✅ ALWAYS: Weak self in closures
networkService.fetch { [weak self] result in
    self?.updateUI(result)
}

// ❌ NEVER: Strong capture of self
networkService.fetch { result in
    self.updateUI(result)  // Retain cycle!
}

// ✅ GOOD: Guard let for multiple uses
loadData { [weak self] data in
    guard let self else { return }
    self.process(data)
    self.updateUI()
}
```

### SwiftUI State

```swift
// ✅ ALWAYS: @State for local, @Binding for child
struct ParentView: View {
    @State private var count = 0
    
    var body: some View {
        ChildView(count: $count)
    }
}

struct ChildView: View {
    @Binding var count: Int
    
    var body: some View {
        Button("Count: \(count)") {
            count += 1
        }
    }
}

// ✅ ALWAYS: @Observable for complex state (iOS 17+)
@Observable
final class DeviceListViewModel {
    var devices: [Device] = []
    var isLoading = false
}
```

### Async/Await

```swift
// ✅ ALWAYS: Parallel with async let
async let devices = fetchDevices()
async let users = fetchUsers()
let (deviceList, userList) = await (devices, users)

// ❌ BAD: Sequential when unnecessary
let devices = await fetchDevices()
let users = await fetchUsers()

// ✅ ALWAYS: MainActor for UI
@MainActor
func updateUI() {
    self.devices = newDevices
}

// ✅ ALWAYS: Check cancellation
func loadData() async {
    guard !Task.isCancelled else { return }
    let data = await fetchData()
    guard !Task.isCancelled else { return }
    process(data)
}
```

### Type Safety

```swift
// ✅ ALWAYS: Enums for fixed values
enum Quality: String, Codable {
    case low, medium, high
}

func setQuality(_ quality: Quality) {
    switch quality {
    case .low: // Handle
    case .medium: // Handle
    case .high: // Handle
    }
}

// ❌ NEVER: Stringly-typed
func setQuality(_ quality: String) {
    // Typos, case sensitivity issues
}
```

### Immutability

```swift
// ✅ ALWAYS: Non-mutating operations
let onlineDevices = devices.filter { $0.isOnline }
let deviceIDs = devices.map { $0.id }

// ❌ BAD: Unnecessary mutation
var result: [Device] = []
for device in devices {
    if device.isOnline {
        result.append(device)
    }
}
```

---

## 🔍 Quick Anti-Pattern Checklist

Before committing, verify:

- [ ] No force unwraps (`!`) without justification comment
- [ ] All closures capturing `self` use `[weak self]`
- [ ] No magic numbers/strings (use `enum Constants`)
- [ ] No stringly-typed code (use type-safe enums)
- [ ] Public APIs have documentation comments
- [ ] Error handling is specific (not generic)
- [ ] ViewModels are focused (< 200 lines)
- [ ] Dependencies are injected (not hard-coded)

---

## 📖 Code Quality Principles

### 1. Clarity at the Point of Use
- Code should be clear and readable where it's used
- Prefer explicit over implicit
- Self-documenting code over comments

### 2. KISS (Keep It Simple, Stupid)
- Simplest solution that works
- Avoid over-engineering
- No premature optimization

### 3. DRY (Don't Repeat Yourself)
- Extract common logic into functions/extensions
- Create reusable components
- Avoid copy-paste programming

### 4. YAGNI (You Aren't Gonna Need It)
- Don't build features before they're needed
- Avoid speculative generality
- Start simple, refactor when needed

---

## 📖 Detailed References

For comprehensive examples, edge cases, and in-depth explanations, see:

- **Language Standards**: `.copilot/skills/swift-coding-standards/reference/language.md`
  - Naming conventions, optionals, error handling, async/await, type safety, access control, extensions
  
- **SwiftUI Patterns**: `.copilot/skills/swift-coding-standards/reference/swiftui.md`
  - View structure, state management, view modifiers, conditional rendering, performance

- **Memory & Testing**: `.copilot/skills/swift-coding-standards/reference/memory.md`
  - ARC, weak/unowned, value vs reference types, testing patterns, testable code

- **Anti-Patterns**: `.copilot/skills/swift-coding-standards/reference/anti-patterns.md`
  - Common mistakes, why they're bad, how to fix them

**AI Usage**: Use `view` tool to load specific reference when detailed guidance is needed.

---

**Remember**: Swift code should be safe, fast, and expressive. Leverage the type system, embrace value semantics, and write code that is clear at the point of use.
