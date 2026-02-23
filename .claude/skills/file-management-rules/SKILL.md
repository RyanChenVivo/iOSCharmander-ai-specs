---
name: file-management-rules
description: Use when creating Swift files (source or test files) and need to determine target assignment. Triggers on adding unit tests, UI tests, or files outside SPM packages.
---

# File Management Rules

## File Location Types

### VortexFeatures SPM (Automatic) ✅
- `VortexFeatures/Sources/VortexFeatures/...` - Source files
- `VortexFeatures/Tests/VortexFeaturesTests/...` - Test files
- **Action:** Just create the file. SPM handles everything automatically.

### Main Project (Manual) ⚠️
- `<App>/...` - Source files → `<App>` target
- `<App>Tests/Test/` - Unit tests (`*Test.swift`) → `<App>Tests` target (flat structure)
- `<App>UITests/<Feature>/` - UI tests (`*UITest.swift`) → `<App>UITests` target (organized by feature)

**Action:** Create file → Discover target IDs → Update project.pbxproj → Build to verify

---

## Discovering Target IDs

**CRITICAL:** Target IDs are project-specific. Always discover them dynamically.

```bash
# Find target ID
grep -A 10 'PBXNativeTarget.*"TargetName"' project.pbxproj
# Example output: 8A01C08726314CB80030DA0A /* iOSCharmanderTests */

# Find build phase ID (for Sources)
grep -B 5 '<TargetID>' project.pbxproj | grep 'Sources'
# Example output: 8A01C08426314CB80030DA0A /* Sources */
```

Or trace from existing similar file:
```bash
# Find existing test file, trace to PBXSourcesBuildPhase
grep 'ExistingTest.swift' project.pbxproj
```

---

## Adding Files to Main Project

### Steps

1. **Create the file** using Write tool
2. **Discover target and build phase IDs** (see above)
3. **Update project.pbxproj** with relative paths:
   - Add to `PBXFileReference` (define file)
   - Add to `PBXGroup` (logical folder)
   - Add to `PBXSourcesBuildPhase` (include in build)
4. **Verify build:**
   ```bash
   # Source files
   xcodebuild -project <Project>.xcodeproj -scheme <Scheme> -configuration Debug

   # Unit tests
   xcodebuild test ... -only-testing:<App>Tests

   # UI tests
   xcodebuild test ... -only-testing:<App>UITests
   ```

### Example

```bash
# Adding DeviceManagerTest.swift to iOSCharmanderTests

# 1. Create file at iOSCharmanderTests/Test/DeviceManagerTest.swift

# 2. Discover IDs
grep -A 10 'PBXNativeTarget' project.pbxproj | grep 'iOSCharmanderTests'
# Found: 8A01C08726314CB80030DA0A

# 3. Update project.pbxproj
# - Add PBXFileReference: Test/DeviceManagerTest.swift (relative path!)
# - Add to PBXGroup for Test folder
# - Add to PBXSourcesBuildPhase 8A01C08426314CB80030DA0A

# 4. Verify
xcodebuild test -only-testing:iOSCharmanderTests
```

---

## Common Pitfalls

❌ **Absolute paths** - Use `Test/File.swift` not `/Users/.../Test/File.swift`

❌ **Hardcoded IDs from docs** - Always discover from current project

❌ **Wrong target** - Unit tests → `<App>Tests`, UI tests → `<App>UITests`

❌ **Adding SPM files to project.pbxproj** - VortexFeatures handles automatically

❌ **Skipping build verification** - Always build after changes

---

## Quick Reference

```
Adding Swift file?
├─ VortexFeatures/Sources/ or Tests/? → ✅ Just create
├─ Unit test (*Test.swift)? → <App>Tests target + flat structure
├─ UI test (*UITest.swift)? → <App>UITests target + feature folders
└─ Source file? → <App> target

For main project files:
1. Create file
2. Discover IDs (grep PBXNativeTarget)
3. Update project.pbxproj (relative paths)
4. Build to verify
```
