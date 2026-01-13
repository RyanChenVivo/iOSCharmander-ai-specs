# API Integration Examples

## Response Model

```swift
// All models conform to VortexBackendModel
struct DeviceResponse: VortexBackendModel {
    let id: String
    let name: String
    let status: DeviceStatus
}

// Enums use SafeDecodableEnum
enum DeviceStatus: SafeDecodableEnum {
    case online, offline, unknown
    static var unknownCase: DeviceStatus { .unknown }
}
```

## Model Separation

```swift
// API Model (VortexBackend/Model/)
struct DeviceResponse: VortexBackendModel {
    let deviceId: String
    let deviceName: String
    let statusCode: Int
}

// Internal Model (Manager/Dependency layer)
struct Device {
    let id: String
    let name: String
    let status: DeviceStatus

    init(from response: DeviceResponse) {
        self.id = response.deviceId
        self.name = response.deviceName
        self.status = DeviceStatus(code: response.statusCode)
    }
}
```

## Error Handling

```swift
do {
    let response = try await apiCall()
    return response
} catch {
    throw handleErrorData(error)  // Convert to VortexError
}
```

## GraphQL Fragments

```swift
extension VortexApiKey {
    static let deviceFragment = """
        fragment DeviceFields on Device {
            id
            name
            status
        }
    """
}

// Usage in query
let query = """
    query GetDevices {
        devices { ...DeviceFields }
    }
    \(VortexApiKey.deviceFragment)
"""
```
