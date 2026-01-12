# Testing Strategy

## Unit Testing Framework

**Location**: `iOSCharmanderTests/Test/`

**Framework**: **Swift Testing** (`import Testing`)

**IMPORTANT**: All new unit tests must use Swift Testing framework, not XCTest.

### Swift Testing vs XCTest

| Aspect | Swift Testing (✅ Use This) | XCTest (❌ Legacy) |
|--------|---------------------------|-------------------|
| **Import** | `import Testing` | `import XCTest` |
| **Test function** | `@Test func testName()` | `func testXxx() { }` |
| **Assertions** | `#expect(condition)`, `#require()` | `XCTAssertTrue()`, etc. |
| **Test suite** | `@Suite struct MyTests` | `class MyTests: XCTestCase` |
| **Setup/Teardown** | `init()`, `deinit` | `setUp()`, `tearDown()` |

### Swift Testing Example

```swift
import Testing
@testable import VortexFeatures

@Suite("DeviceManager Tests")
struct DeviceManagerTests {
    @Test("Fetch devices updates published state")
    func fetchDevicesUpdatesState() async throws {
        // Given
        let manager = DeviceManager()

        // When
        try await manager.fetchDevices()

        // Then
        #expect(!manager.devices.isEmpty)
    }
}
```

---

## Testing Requirements

- ✅ **Use Swift Testing** (`import Testing`) for all new unit tests
- ✅ Mock all external dependencies (network, device SDK)
- ✅ Use dependency injection for testability
- ✅ All new ViewModels must have unit tests
- ✅ Critical business logic requires 80%+ coverage

---

## Testing Error Handling in ViewModels

### MockAppManager Pattern

Use `MockAppManager` with appropriate closure to capture error handling calls:

**For `handleError(error, defaultAlert:)`** use `_handleErrorWithDefaultAlert` closure
**For `handleError(error)`** use `_handleError` closure

### Test Pattern with Swift Testing

```swift
import Testing
@testable import iOSCharmander

@Suite("MyViewModel Error Handling")
struct MyViewModelTests {
    @Test("Handles network error correctly")
    func handleNetworkError() async {
        // Given
        var handledError: Error?
        let mockAppManager = MockAppManager(
            _handleErrorWithDefaultAlert: { error, defaultAlert in
                handledError = error
            }
        )
        let viewModel = MyViewModel(appManager: mockAppManager)

        // When
        await viewModel.loadData()

        // Then
        #expect(handledError != nil)
        #expect((handledError as? VortexError) == .networkUnavailable)
        #expect(viewModel.isLoading == false)
    }
}
```

### What to Verify

**Always verify**:
- ✅ Error handling is called for data fetch errors
- ✅ UI state is correct after error (e.g., `isLoading == false`)

**Never verify**:
- ❌ Error handling is NOT called for expected scenarios (e.g., cache misses)

---

## Coverage Requirements

**Coverage Areas**:
- OdysseyClient (backend communication)
- SnoozeRule logic
- View models and business logic
- Extensions and utilities
- Feature toggles
- Alarm, Message, Archive, Export modules

**Test Resources**:
- Mock data: `Test/Mock/` directory
- Network mocking: `URLProtocolMock`

---

## Swift Testing Best Practices

### Test Organization

```swift
@Suite("Feature Name Tests")
struct FeatureTests {
    // Shared test data
    let testData = "test"

    @Test("Descriptive test name")
    func specificBehavior() async throws {
        // Test implementation
    }

    @Test("Another behavior", arguments: [1, 2, 3])
    func parameterizedTest(value: Int) {
        #expect(value > 0)
    }
}
```

### Assertions

**Use `#expect()` for assertions**:
```swift
#expect(value == expectedValue)
#expect(array.isEmpty)
#expect(result != nil)
```

**Use `#require()` for critical checks**:
```swift
let user = try #require(viewModel.user)  // Unwraps or fails
#require(viewModel.isReady)  // Must be true to continue
```

### Async Testing

```swift
@Test("Async operation completes")
func asyncOperation() async throws {
    let result = await viewModel.fetchData()
    #expect(result != nil)
}
```

---

## Integration Testing

**Location**: Tests within VortexFeatures SPM packages

**Coverage**:
- `AWSServicesTests` for cloud integration
- Service layer integration tests

**Framework**: Swift Testing (same as unit tests)
