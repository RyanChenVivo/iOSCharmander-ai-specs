# API Integration Patterns

## Location

**Package**: `VortexFeatures`

**Folders**:
- `VortexRestfulApi/` - RESTful API implementations
- `VortexApi/` - GraphQL API implementations

---

## Naming Conventions

### RESTful APIs

**Pattern**: HTTP method prefix + operation

**Examples**:
```swift
func getDeviceList() async throws -> [Device]
func postCreateUser(userData: UserData) async throws -> User
func putUpdateDevice(id: String, data: DeviceData) async throws -> Device
func deleteDevice(id: String) async throws
```

**Key Points**:
- ✅ Use HTTP verbs: `get`, `post`, `put`, `delete`
- ✅ Descriptive operation names
- ✅ Include parameter types in function signature

### GraphQL APIs

**Pattern**: Operation name directly

**Examples**:
```swift
func listMyOrganization() async throws -> Organization
func createDevice(input: CreateDeviceInput) async throws -> Device
func updateUserProfile(input: UpdateProfileInput) async throws -> UserProfile
```

**Key Points**:
- ✅ Use operation name from GraphQL schema
- ✅ No HTTP verb prefix
- ✅ Input types match GraphQL definitions

---

## Response Models

### Location

**Path**: `VortexFeatures/.../VortexBackend/Model/`

**Example**:
```
VortexFeatures/
  Sources/
    VortexFeatures/
      VortexBackend/
        Model/
          DeviceResponse.swift
          OrganizationResponse.swift
```

### Model Requirements

**Protocol Conformance**:
```swift
struct DeviceResponse: VortexBackendModel {
    let id: String
    let name: String
    let status: DeviceStatus
}
```

**Enum Handling**:
```swift
enum DeviceStatus: SafeDecodableEnum {
    case online
    case offline
    case unknown

    static var unknownCase: DeviceStatus { .unknown }
}
```

**Key Points**:
- ✅ All response models conform to `VortexBackendModel`
- ✅ Enums use `SafeDecodableEnum` for safe decoding
- ✅ Handle unknown/future enum cases gracefully

### GraphQL Fragments

**Define in `VortexApiKey`**:
```swift
extension VortexApiKey {
    static let deviceFragment = """
        fragment DeviceFields on Device {
            id
            name
            status
            createdAt
        }
    """
}
```

**Reuse across queries**:
```swift
let query = """
    query GetDevices {
        devices {
            ...DeviceFields
        }
    }
    \(VortexApiKey.deviceFragment)
"""
```

---

## Model Separation Pattern

### Two-Layer Architecture

**API Model** (VortexBackendModel):
- Lives in `VortexBackend/Model/`
- Matches API response structure
- Only for network layer

**Internal Model**:
- Lives in Manager/Dependency layer
- App-specific structure
- Business logic friendly

### Example

**API Model**:
```swift
// VortexBackend/Model/DeviceResponse.swift
struct DeviceResponse: VortexBackendModel {
    let deviceId: String
    let deviceName: String
    let statusCode: Int
}
```

**Internal Model**:
```swift
// Core/DeviceManager.swift
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

**Benefits**:
- ✅ API changes don't ripple through app
- ✅ Clean separation of concerns
- ✅ Type-safe transformations

---

## Error Handling

### Convert to VortexError

**Common Pattern** - `handleErrorData`:
```swift
do {
    let response = try await apiCall()
    return response
} catch {
    throw handleErrorData(error)
}
```

**API-Specific Pattern** - Extension:
```swift
extension VortexError {
    init(from apiError: DeviceAPIError) {
        switch apiError.code {
        case .deviceNotFound:
            self = .deviceNotFound
        case .unauthorized:
            self = .unauthorized
        default:
            self = .unknown(apiError.message)
        }
    }
}
```

### Error Handling Rules

- ✅ **Always** convert API errors to `VortexError`
- ✅ Use `handleErrorData` for common HTTP errors
- ✅ Create specific extensions for domain-specific errors
- ✅ Preserve error context for debugging
- ❌ **Never** expose raw API errors to ViewModels

---

## Quick Reference

| Aspect | RESTful | GraphQL |
|--------|---------|---------|
| **Function naming** | `getDeviceList()` | `listDevices()` |
| **Location** | `VortexRestfulApi/` | `VortexApi/` |
| **Response model** | `VortexBackendModel` | `VortexBackendModel` |
| **Fragments** | N/A | Define in `VortexApiKey` |
| **Error handling** | `handleErrorData` | `handleErrorData` or extension |

---

## Best Practices

1. **Model Separation**: Always separate API models from internal models
2. **Enum Safety**: Use `SafeDecodableEnum` for all API enums
3. **Error Context**: Preserve error information for debugging
4. **Fragment Reuse**: Define common GraphQL fragments in `VortexApiKey`
5. **Type Safety**: Leverage Swift's type system for compile-time guarantees
