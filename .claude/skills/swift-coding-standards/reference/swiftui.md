# SwiftUI Best Practices - Detailed Reference

## View Structure

```swift
// ✅ GOOD: Clean, focused view
struct DeviceRow: View {
    let device: Device
    
    var body: some View {
        HStack(spacing: 12) {
            deviceThumbnail
            deviceInfo
            Spacer()
            statusIndicator
        }
        .padding()
    }
    
    private var deviceThumbnail: some View {
        AsyncImage(url: device.thumbnailURL) { image in
            image.resizable()
        } placeholder: {
            ProgressView()
        }
        .frame(width: 60, height: 60)
    }
    
    private var deviceInfo: some View {
        VStack(alignment: .leading) {
            Text(device.name)
                .font(.headline)
            Text(device.model)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var statusIndicator: some View {
        Circle()
            .fill(device.isOnline ? .green : .red)
            .frame(width: 10, height: 10)
    }
}

// ❌ BAD: Monolithic view
struct DeviceRow: View {
    let device: Device
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: device.thumbnailURL) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 60, height: 60)
            VStack(alignment: .leading) {
                Text(device.name).font(.headline)
                Text(device.model).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Circle().fill(device.isOnline ? .green : .red).frame(width: 10, height: 10)
        }
        .padding()
    }
}
```

## State Management

```swift
// ✅ GOOD: @State for view-local state
struct CounterView: View {
    @State private var count = 0
    
    var body: some View {
        Button("Count: \(count)") {
            count += 1
        }
    }
}

// ✅ GOOD: @Binding for child view state
struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(title, isOn: $isOn)
    }
}

// ✅ GOOD: @Observable for complex state (iOS 17+)
@Observable
final class DeviceListViewModel {
    var devices: [Device] = []
    var isLoading = false
    var searchText = ""
    
    var filteredDevices: [Device] {
        guard !searchText.isEmpty else { return devices }
        return devices.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}

// ✅ GOOD: Computed properties for derived state
struct DeviceListView: View {
    @State private var viewModel = DeviceListViewModel()
    
    var body: some View {
        List(viewModel.filteredDevices) { device in
            DeviceRow(device: device)
        }
        .searchable(text: $viewModel.searchText)
    }
}
```

## View Modifiers

```swift
// ✅ GOOD: Custom view modifiers for reusability
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// Usage
Text("Hello")
    .cardStyle()

// ❌ BAD: Repeating modifier chains
Text("Hello")
    .padding()
    .background(.background)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(radius: 2)
```

## Conditional Rendering

```swift
// ✅ GOOD: Clear conditional rendering
if isLoading {
    ProgressView()
} else if let error {
    ErrorView(error: error)
} else if devices.isEmpty {
    EmptyStateView()
} else {
    DeviceList(devices: devices)
}

// ✅ GOOD: Optional view rendering
if let selectedDevice {
    DeviceDetailView(device: selectedDevice)
}

// ❌ BAD: Nested ternary operators
isLoading 
    ? ProgressView() 
    : error != nil 
        ? ErrorView(error: error!) 
        : devices.isEmpty 
            ? EmptyStateView() 
            : DeviceList(devices: devices)
```

## Performance Optimization

```swift
// ✅ GOOD: Task modifier for async loading
struct DeviceListView: View {
    @State private var devices: [Device] = []
    
    var body: some View {
        List(devices) { device in
            DeviceRow(device: device)
        }
        .task {
            await loadDevices()
        }
    }
}

// ✅ GOOD: Lazy loading for large lists
ScrollView {
    LazyVStack {
        ForEach(devices) { device in
            DeviceRow(device: device)
        }
    }
}

// ✅ GOOD: Identify views for diffing
struct DeviceRow: View {
    let device: Device
    
    var body: some View {
        HStack {
            Text(device.name)
            Spacer()
            Text(device.status)
        }
        .id(device.id)  // Helps SwiftUI optimize updates
    }
}
```

## SwiftUI Best Practices Summary

### State Property Wrappers
- `@State` - For simple view-local state
- `@Binding` - For two-way bindings to parent state
- `@Observable` - For complex observable objects (iOS 17+)
- `@Environment` - For dependency injection

### View Composition
- Break large views into smaller computed properties
- Extract reusable components into separate views
- Use view modifiers for common styling patterns

### Performance
- Use `LazyVStack`/`LazyHStack` for large lists
- Use `.task` modifier for async work tied to view lifecycle
- Add `.id()` to help SwiftUI optimize diffing
- Avoid expensive computations in `body`
