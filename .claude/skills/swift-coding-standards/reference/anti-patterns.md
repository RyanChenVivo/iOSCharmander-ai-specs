# Common Anti-Patterns to Avoid

## 1. Massive View/ViewModel

```swift
// ❌ BAD: 500+ line ViewModel
class DashboardViewModel {
    // Too many responsibilities
    var devices: [Device]
    var users: [User]
    var analytics: Analytics
    var settings: Settings
    // ... 50+ properties
    
    // ... 100+ methods
}

// ✅ GOOD: Split into focused components
class DeviceListViewModel { }
class UserManagementViewModel { }
class AnalyticsViewModel { }
class SettingsViewModel { }
```

**Why it's bad:**
- Violates Single Responsibility Principle
- Hard to test
- Hard to maintain
- Creates tight coupling

**Fix:**
- Break into smaller, focused ViewModels
- Each ViewModel should have one clear responsibility
- Use composition to combine ViewModels when needed

## 2. Force Unwrapping

```swift
// ❌ BAD: Crash-prone
let device = devices.first!
let url = URL(string: urlString)!
let data = dictionary["key"]!

// ✅ GOOD: Safe handling
guard let device = devices.first else { return }
guard let url = URL(string: urlString) else { return }
guard let data = dictionary["key"] else { return }
```

**Why it's bad:**
- Will crash if value is nil
- Runtime error instead of compile-time safety
- No graceful fallback

**Fix:**
- Use `guard let` or `if let` for safe unwrapping
- Use optional chaining (`?.`)
- Use nil coalescing (`??`) for defaults

**Only exception:**
- IB outlets (but still prefer optionals with proper checks)
- When you have absolute certainty (document with comment)

## 3. Implicit Self in Closures

```swift
// ❌ BAD: Potential retain cycle
class VideoPlayer {
    var playlist: [Video] = []
    
    func loadVideos() {
        networkService.fetchVideos { videos in
            self.playlist = videos  // Strong capture
            self.startPlayback()
        }
    }
}

// ✅ GOOD: Explicit capture
class VideoPlayer {
    var playlist: [Video] = []
    
    func loadVideos() {
        networkService.fetchVideos { [weak self] videos in
            self?.playlist = videos
            self?.startPlayback()
        }
    }
}
```

**Why it's bad:**
- Creates retain cycles
- Memory leaks
- Objects never get deallocated

**Fix:**
- Always use `[weak self]` in closures
- Use `guard let self` if you need self multiple times
- Use `[unowned self]` only when you're certain self outlives the closure

## 4. Magic Numbers/Strings

```swift
// ❌ BAD: Magic values
if retryCount > 3 { }
if statusCode == 404 { }
timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { }
if userRole == "admin" { }

// ✅ GOOD: Named constants
private enum Constants {
    static let maxRetryCount = 3
    static let notFoundStatusCode = 404
    static let refreshInterval: TimeInterval = 0.5
}

enum UserRole: String {
    case admin = "admin"
    case user = "user"
    case guest = "guest"
}

if retryCount > Constants.maxRetryCount { }
if statusCode == Constants.notFoundStatusCode { }
timer = Timer.scheduledTimer(withTimeInterval: Constants.refreshInterval, repeats: true) { }
if userRole == .admin { }
```

**Why it's bad:**
- Hard to understand intent
- Difficult to maintain
- Easy to make typos
- No type safety for strings

**Fix:**
- Use enums for string constants
- Use named constants for numbers
- Group related constants together
- Make constants private to limit scope

## 5. Stringly-Typed Code

```swift
// ❌ BAD: String-based
func setQuality(_ quality: String) {
    switch quality {
    case "low": // Handle
    case "high": // Handle
    default: break
    }
}

setQuality("Low")  // Typo! Will fail silently

// ✅ GOOD: Type-safe
enum Quality {
    case low, medium, high
}

func setQuality(_ quality: Quality) {
    switch quality {
    case .low: // Handle
    case .medium: // Handle
    case .high: // Handle
    }
}

setQuality(.high)  // Compile-time checked
```

**Why it's bad:**
- No compile-time checking
- Prone to typos
- Case sensitivity issues
- No autocomplete
- Hard to refactor

**Fix:**
- Use enums for fixed sets of values
- Use enums with raw values if you need string representation
- Leverage Swift's type system

## 6. Premature Optimization

```swift
// ❌ BAD: Over-engineered for no reason
class DeviceCache {
    private var lruCache: LRUCache<String, Device>
    private var writeAheadLog: WAL
    private var bloomFilter: BloomFilter
    
    // ... 500 lines of complex caching logic
    // For an app that has 5 devices max
}

// ✅ GOOD: Simple solution first
class DeviceCache {
    private var cache: [String: Device] = [:]
    
    func get(_ id: String) -> Device? {
        cache[id]
    }
    
    func set(_ device: Device) {
        cache[device.id] = device
    }
}
```

**Why it's bad:**
- Wastes development time
- Adds unnecessary complexity
- Harder to debug
- May not solve the actual problem

**Fix:**
- Start with the simplest solution
- Measure before optimizing
- Optimize only proven bottlenecks
- "Make it work, make it right, make it fast" - in that order

## 7. Swallowing Errors Silently

```swift
// ❌ BAD: Silent failure
func loadDevices() {
    do {
        let devices = try fetchDevices()
    } catch {
        // Nothing - error disappears
    }
}

// ❌ BAD: Generic logging
func loadDevices() {
    do {
        let devices = try fetchDevices()
    } catch {
        print("Error: \(error)")  // User never knows
    }
}

// ✅ GOOD: Proper error handling
func loadDevices() async {
    do {
        let devices = try await fetchDevices()
        self.devices = devices
        self.errorMessage = nil
    } catch let error as NetworkError {
        self.errorMessage = error.userFacingMessage
        logger.error("Failed to load devices: \(error)")
    } catch {
        self.errorMessage = "An unexpected error occurred"
        logger.error("Unexpected error: \(error)")
    }
}
```

**Why it's bad:**
- Hides problems
- Makes debugging impossible
- Poor user experience
- No way to recover

**Fix:**
- Handle errors appropriately
- Show user-friendly messages
- Log errors for debugging
- Provide recovery options when possible

## Quick Anti-Pattern Checklist

Before committing, check your code for:

- [ ] ❌ Force unwraps (`!`) without justification
- [ ] ❌ Closures capturing `self` without `[weak self]`
- [ ] ❌ Magic numbers or strings scattered in code
- [ ] ❌ Stringly-typed parameters (use enums)
- [ ] ❌ ViewModels with 500+ lines
- [ ] ❌ Silent error swallowing in `catch` blocks
- [ ] ❌ Premature optimizations without profiling
- [ ] ❌ Public APIs without documentation
- [ ] ❌ Hard-coded dependencies (use DI)
- [ ] ❌ Nested ternary operators
