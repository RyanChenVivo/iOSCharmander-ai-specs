# Swift Language Standards - Detailed Reference

## Naming Conventions

```swift
// ✅ GOOD: Clear, descriptive names
let userAuthenticated = true
let deviceConnectionStatus: ConnectionStatus = .connected
let totalRecordingDuration: TimeInterval = 3600

// ❌ BAD: Unclear abbreviations
let auth = true
let status = 1
let duration = 3600
```

## Type Naming

```swift
// ✅ GOOD: PascalCase for types
struct VideoStream { }
class DeviceManager { }
enum ConnectionStatus { }
protocol Streamable { }

// ❌ BAD: Incorrect casing
struct videoStream { }
class device_manager { }
```

## Method Naming

```swift
// ✅ GOOD: Verb phrase for methods
func fetchDeviceList() async throws -> [Device]
func updateStreamQuality(to quality: Quality)
func isConnected() -> Bool

// ❌ BAD: Unclear or noun-only
func devices() async throws -> [Device]
func quality(_ q: Quality)
func connected() -> Bool
```

## Variable and Constant Usage

```swift
// ✅ GOOD: let for immutable, var for mutable
let maxRetryCount = 3
var currentAttempt = 0

// ❌ BAD: Using var when value doesn't change
var maxRetryCount = 3  // Should be let

// ✅ GOOD: Explicit types when needed for clarity
let timestamp: TimeInterval = Date().timeIntervalSince1970
let deviceID: String = UUID().uuidString

// ❌ BAD: Unnecessary type annotation
let name: String = "Device"  // Type can be inferred
```

## Optional Handling

```swift
// ✅ GOOD: Safe unwrapping with guard
func processDevice(_ device: Device?) {
    guard let device else { return }
    // Use device safely
}

// ✅ GOOD: Optional chaining
let thumbnailURL = device?.currentStream?.thumbnailURL

// ✅ GOOD: Nil coalescing for defaults
let displayName = device?.name ?? "Unknown Device"

// ❌ BAD: Force unwrapping (avoid unless absolutely safe)
let device = deviceList.first!  // Crashes if empty
let name = device!.name

// ❌ BAD: Nested optional binding
if let device = device {
    if let stream = device.stream {
        if let url = stream.url {
            // Too nested
        }
    }
}

// ✅ GOOD: Flat optional binding
guard let device,
      let stream = device.stream,
      let url = stream.url else {
    return
}
// Use values
```

## Immutability Pattern (CRITICAL)

```swift
// ✅ GOOD: Value types are immutable by default
struct VideoConfig {
    let resolution: Resolution
    let framerate: Int
    
    func withResolution(_ resolution: Resolution) -> VideoConfig {
        VideoConfig(resolution: resolution, framerate: framerate)
    }
}

// ✅ GOOD: Non-mutating array operations
let updatedDevices = devices.filter { $0.isOnline }
let deviceIDs = devices.map { $0.id }
let allDevices = existingDevices + newDevices

// ❌ BAD: Unnecessary mutation
var filteredDevices: [Device] = []
for device in devices {
    if device.isOnline {
        filteredDevices.append(device)
    }
}
```

## Error Handling

```swift
// ✅ GOOD: Typed errors with enum
enum DeviceError: LocalizedError {
    case notFound(id: String)
    case connectionFailed(reason: String)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .notFound(let id):
            return "Device \(id) not found"
        case .connectionFailed(let reason):
            return "Connection failed: \(reason)"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
}

// ✅ GOOD: Comprehensive error handling
func connectToDevice(_ deviceID: String) async throws -> Device {
    guard let device = await deviceRepository.find(deviceID) else {
        throw DeviceError.notFound(id: deviceID)
    }
    
    do {
        try await device.connect()
        return device
    } catch {
        throw DeviceError.connectionFailed(reason: error.localizedDescription)
    }
}

// ❌ BAD: Swallowing errors
func loadDevices() {
    do {
        let devices = try fetchDevices()
    } catch {
        // Silent failure - BAD
    }
}

// ❌ BAD: Generic error messages
throw NSError(domain: "Error", code: -1, userInfo: nil)
```

## Async/Await Best Practices

```swift
// ❌ BAD: Sequential when unnecessary
let devices = await fetchDevices()
let users = await fetchUsers()
let settings = await fetchSettings()

// ✅ GOOD: Parallel execution with async let
async let devices = fetchDevices()
async let users = fetchUsers()
async let settings = fetchSettings()
let (deviceList, userList, settingsList) = await (devices, users, settings)

// ✅ GOOD: Proper task cancellation
func loadData() async {
    guard !Task.isCancelled else { return }
    
    let data = await fetchData()
    
    guard !Task.isCancelled else { return }
    
    process(data)
}

// ✅ GOOD: MainActor for UI updates
@MainActor
func updateUI(with devices: [Device]) {
    self.devices = devices
    self.isLoading = false
}
```

## Type Safety & Enums

```swift
// ✅ GOOD: Strong typing with enums
enum StreamQuality: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case ultra = "Ultra"
}

func setQuality(_ quality: StreamQuality) {
    // Type-safe
}

// ❌ BAD: Stringly-typed
func setQuality(_ quality: String) {
    // Prone to typos: "low", "Low", "LOW" all different
}

// ✅ GOOD: Associated values for context
enum NetworkStatus {
    case connected(speed: Int)
    case disconnected(reason: String)
    case connecting
}

// ✅ GOOD: Exhaustive switching
func handleStatus(_ status: NetworkStatus) {
    switch status {
    case .connected(let speed):
        print("Connected at \(speed) Mbps")
    case .disconnected(let reason):
        print("Disconnected: \(reason)")
    case .connecting:
        print("Connecting...")
    }
    // Compiler ensures all cases handled
}
```

## Access Control

```swift
// ✅ GOOD: Appropriate access levels
public protocol DeviceManaging {
    func fetchDevices() async throws -> [Device]
}

public final class DeviceManager: DeviceManaging {
    private let repository: DeviceRepository
    private var cache: [String: Device] = [:]
    
    public static let shared = DeviceManager()
    
    private init() {
        self.repository = DeviceRepository()
    }
    
    public func fetchDevices() async throws -> [Device] {
        try await repository.fetchAll()
    }
}

// ❌ BAD: Everything public
public class DeviceManager {
    public var cache: [String: Device] = [:]  // Should be private
    public init() { }  // Should be private for singleton
}
```

## Code Organization - Extensions

```swift
// ✅ GOOD: Extensions for protocol conformance
extension Device: Codable { }

extension Device: Comparable {
    static func < (lhs: Device, rhs: Device) -> Bool {
        lhs.name < rhs.name
    }
}

// ✅ GOOD: Extensions for related functionality
extension Device {
    var displayName: String {
        name.isEmpty ? "Unknown Device" : name
    }
    
    var statusColor: Color {
        isOnline ? .green : .red
    }
}

// ✅ GOOD: Extensions for convenience
extension Array where Element == Device {
    var onlineDevices: [Device] {
        filter { $0.isOnline }
    }
    
    var sortedByName: [Device] {
        sorted { $0.name < $1.name }
    }
}
```
