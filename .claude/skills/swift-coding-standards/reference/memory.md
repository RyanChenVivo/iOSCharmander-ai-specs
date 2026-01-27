# Memory Management & Testing - Detailed Reference

## Memory Management

### Reference Types and ARC

```swift
// ❌ BAD: Strong reference cycle
class VideoPlayer {
    var onComplete: (() -> Void)?
    
    func start() {
        onComplete = {
            self.cleanup()  // Captures self strongly
        }
    }
}

// ✅ GOOD: Break the cycle with weak self
class VideoPlayer {
    var onComplete: (() -> Void)?
    
    func start() {
        onComplete = { [weak self] in
            self?.cleanup()
        }
    }
}

// ✅ GOOD: Weak references to avoid retain cycles
class DeviceManager {
    weak var delegate: DeviceManagerDelegate?
    
    private var completionHandler: (() -> Void)?
    
    func performTask(completion: @escaping () -> Void) {
        completionHandler = completion
    }
}

// ✅ GOOD: Weak self in closures
class VideoPlayer {
    func startPlayback() {
        networkService.fetchStream { [weak self] result in
            guard let self else { return }
            self.handleStream(result)
        }
    }
}

// ✅ GOOD: Unowned when guaranteed non-nil
class StreamViewController {
    unowned let deviceManager: DeviceManager
    
    init(deviceManager: DeviceManager) {
        self.deviceManager = deviceManager
    }
}
```

### Value Types vs Reference Types

```swift
// ✅ GOOD: Value types for data models
struct Device: Identifiable {
    let id: String
    let name: String
    var isOnline: Bool
}

// ✅ GOOD: Reference types for services/managers
final class DeviceManager {
    static let shared = DeviceManager()
    private init() { }
    
    func updateDevice(_ device: Device) async throws {
        // Implementation
    }
}

// ✅ GOOD: Copy-on-write for large value types
struct DeviceList {
    private var storage: [Device]
    
    var devices: [Device] {
        get { storage }
        set {
            if !isKnownUniquelyReferenced(&storage) {
                storage = newValue
            }
        }
    }
}
```

## Testing Best Practices

### Test Structure

```swift
import Testing

// ✅ GOOD: Descriptive test names
@Suite("Device Manager Tests")
struct DeviceManagerTests {
    
    @Test("Fetches devices successfully")
    func fetchDevicesSuccess() async throws {
        // Arrange
        let manager = DeviceManager()
        
        // Act
        let devices = try await manager.fetchDevices()
        
        // Assert
        #expect(devices.isEmpty == false)
    }
    
    @Test("Throws error when network unavailable")
    func fetchDevicesNetworkError() async {
        // Arrange
        let manager = DeviceManager(networkService: MockFailingNetwork())
        
        // Act & Assert
        await #expect(throws: NetworkError.self) {
            try await manager.fetchDevices()
        }
    }
    
    @Test("Filters devices by status", arguments: [
        (status: .online, expectedCount: 3),
        (status: .offline, expectedCount: 2)
    ])
    func filterDevicesByStatus(
        status: DeviceStatus,
        expectedCount: Int
    ) async {
        // Test implementation
    }
}

// ✅ GOOD: Test doubles
struct MockDeviceRepository: DeviceRepositoryProtocol {
    var devicesToReturn: [Device] = []
    
    func fetchAll() async throws -> [Device] {
        devicesToReturn
    }
}
```

### Testable Code

```swift
// ✅ GOOD: Dependency injection for testability
protocol NetworkServicing {
    func fetch(from url: URL) async throws -> Data
}

final class DeviceManager {
    private let networkService: NetworkServicing
    
    init(networkService: NetworkServicing = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchDevices() async throws -> [Device] {
        let data = try await networkService.fetch(from: devicesURL)
        return try JSONDecoder().decode([Device].self, from: data)
    }
}

// ❌ BAD: Hard-coded dependencies
final class DeviceManager {
    func fetchDevices() async throws -> [Device] {
        let data = try await URLSession.shared.data(from: devicesURL).0
        return try JSONDecoder().decode([Device].self, from: data)
    }
}
```

### Testing Guidelines

1. **AAA Pattern**: Arrange, Act, Assert
2. **One assertion per test**: Focus on single behavior
3. **Descriptive names**: Test name should explain what's being tested
4. **Mock dependencies**: Use protocols and dependency injection
5. **Test public APIs**: Don't test private implementation details
6. **Use parameterized tests**: Test multiple scenarios with `arguments:`

### Common Testing Patterns

```swift
// ✅ GOOD: Test success case
@Test("Successfully loads devices")
func testLoadDevicesSuccess() async throws {
    let repository = MockDeviceRepository(devices: mockDevices)
    let manager = DeviceManager(repository: repository)
    
    let devices = try await manager.loadDevices()
    
    #expect(devices.count == mockDevices.count)
}

// ✅ GOOD: Test error case
@Test("Handles network error")
func testNetworkError() async {
    let repository = FailingRepository()
    let manager = DeviceManager(repository: repository)
    
    await #expect(throws: NetworkError.self) {
        try await manager.loadDevices()
    }
}

// ✅ GOOD: Test state changes
@Test("Updates loading state")
func testLoadingState() async {
    let viewModel = DeviceListViewModel()
    
    #expect(viewModel.isLoading == false)
    
    await viewModel.loadDevices()
    
    #expect(viewModel.isLoading == false)
    #expect(viewModel.devices.isEmpty == false)
}
```
