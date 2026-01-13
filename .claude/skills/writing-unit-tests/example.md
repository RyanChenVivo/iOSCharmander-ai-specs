# Unit Test Examples

## Basic Test

```swift
import Testing
@testable import VortexFeatures

@Suite("DeviceManager Tests")
struct DeviceManagerTests {
    @Test("Fetch devices updates state")
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

## Assertions

```swift
#expect(value == expected)         // Basic assertion
#expect(array.isEmpty)             // Boolean check
let item = try #require(optional)  // Unwrap or fail
```

## Testing ViewModel Error Handling

```swift
@Test("Handles error correctly")
func handleError() async {
    var handledError: Error?
    let mockAppManager = MockAppManager(
        _handleErrorWithDefaultAlert: { error, _ in
            handledError = error
        }
    )
    let viewModel = MyViewModel(appManager: mockAppManager)

    await viewModel.loadData()

    #expect(handledError != nil)
    #expect(viewModel.isLoading == false)
}
```

## Parameterized Tests

```swift
@Test("Validates input", arguments: [1, 2, 3])
func validateInput(value: Int) {
    #expect(value > 0)
}
```
