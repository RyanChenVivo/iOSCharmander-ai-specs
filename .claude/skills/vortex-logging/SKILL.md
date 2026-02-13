---
name: vortex-logging
description: Use when creating or modifying logic layer classes (ViewModel, Manager, Service, Repository, Control). Triggers on new class creation, adding catch blocks, or editing existing logic layer code.
---

# VortexLogger Logging Rules

Add consistent VortexLogger logs in logic layer classes. Rules differ by class type.

## Applies To

All logic layer classes: ViewModel, Manager, Service, Repository, Control, and similar non-UI classes.

**Does NOT apply to:** Views, UIViewControllers (layout code), Model/DTO structs, unit tests.

## Class Type Identification

### Resource Manager

Classes that manage data/hardware resources under the `.resource` subsystem. Examples: DeviceManager, AccessControlManager, UserManager, NetworkSpeakerManager, SmartSensorManager, AlarmSettingManager, FaceProfileManager, ExportFileManager, etc.

**NOT Resource Managers:** AppManager, SheetManager, ThumbnailManager, UniversalLinkManager — these are app-state or UI-flow managers and follow the "Other Logic Layer" rules below.

### ViewModel

Classes ending in `ViewModel` that coordinate between views and managers/services.

### Other Logic Layer

Service, Repository, Control, and any non-resource-Manager, non-ViewModel logic class (including app-state managers like AppManager, SheetManager).

## Rules

### 1. Logger Declaration (All Classes)

Every logic layer class must declare a logger:

```swift
private let logger = VortexLogger.make(type: .myClassName)
```

If the `LogType` case doesn't exist, add it in `VortexFeatures/Sources/VortexLogger/VortexLogger.swift`:
- Add case under the appropriate subsystem MARK section
- Resource Managers go under `.resource` subsystem
- Naming: camelCase case, PascalCase raw value (e.g., `case deviceManager = "DeviceManager"`)
- Add subsystem mapping in the `subsystem` computed property (use `.core` unless the class clearly belongs to another subsystem)

**Structs:** If the logic layer type is a `struct`, skip the deinit rule (structs have no deinit). All other rules apply.

### 2. Resource Manager Rules

Resource Managers have **minimal logging** — only error logs in `public func` catch blocks:

```swift
public func fetchAll() async throws {
    do {
        // ... operation
    } catch {
        logger.error("DeviceManager.fetchAll failed, error: \(error)")
        throw error
    }
}
```

- **No lifecycle logs** (init/deinit) required
- **No operation trace logs** required
- **Only `public func` catch blocks** need error logs — `private`/`internal` func catch blocks do NOT require logging

### 3. ViewModel Rules

**Error logs in catch blocks:** Required in all catch blocks (same format as below).

**Lifecycle logs (init/deinit):** Optional — **ask the user** whether to add init/deinit trace logs when creating or modifying a ViewModel.

```swift
// If user opts in:
init(...) {
    // ... initialization logic
    logger.trace("init ClassName")
}

deinit {
    logger.trace("deinit ClassName")
}
```

**Operation func trace logs:** Optional — **ask the user** whether to add trace logs at the start of operation functions.

```swift
// If user opts in:
func onViewAppear() async {
    logger.trace("ClassName.onViewAppear")
    // ... operation
}
```

When creating a new ViewModel or adding functions to an existing one, ask the user:
1. Whether to include init/deinit lifecycle trace logs
2. Whether to include operation func trace logs

### 4. Other Logic Layer Rules (Service, Repository, Control, etc.)

Same as ViewModel rules:

- **Error logs in catch blocks:** Required
- **Lifecycle logs (init/deinit):** Optional — ask the user
- **Operation func trace logs:** Optional — ask the user

### 5. Log Level Judgment

Required logs have fixed levels:
- init/deinit → `trace`
- catch blocks → `error` (or `critical` for unrecoverable failures)
- operation func entry → `trace`

For any additional logs, choose the appropriate level:

| Level | When to use |
|-------|-------------|
| trace | Internal flow tracing, lifecycle |
| debug | Variable state during development |
| info | Important business events completed |
| warning | Recoverable anomalies, retries |
| error | Operation failures |
| critical | Unrecoverable severe errors |

## Quick Reference

| Class Type | Logger Decl | init/deinit | catch (public) | catch (private) | Operation trace |
|------------|-------------|-------------|----------------|-----------------|-----------------|
| Resource Manager | Required | Not needed | error log | Not needed | Not needed |
| ViewModel | Required | Ask user | error log | error log | Ask user |
| Other Logic Layer | Required | Ask user | error log | error log | Ask user |

## Error Log Format

```swift
logger.error("ClassName.methodName failed, error: \(error)")
```

Each catch clause gets its own log.

## Modifying Existing Classes

When editing (not creating) a logic layer class:

1. **Check** if `private let logger` exists — if missing, remind to add
2. **New catch blocks** added in this change — apply error log rules for the class type
3. **Existing gaps** — remind but don't force-add to avoid large diffs
4. **Do not auto-fix** existing gaps unless explicitly asked

**Exception:** If your new code requires `logger` (e.g., adding a catch block) but the class has no logger declaration, add the `private let logger` property as part of your change. This is a prerequisite, not an auto-fix.

Output reminders like:
> Note: This class is missing [specific logging]. Consider adding in a separate commit.
