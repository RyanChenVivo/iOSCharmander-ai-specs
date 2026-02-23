---
name: file-management-rules
description: Use when creating Swift files (source or test files) and need to determine target assignment. Triggers on adding unit tests, UI tests, or files outside SPM packages.
---

# File Management Rules

Use this skill when:
- Adding new Swift files (source or test) to the main project
- Creating unit test files (*Test.swift)
- Creating UI test files (*UITest.swift)
- Creating new directories with Swift files
- Modifying project.pbxproj
- Ensuring correct target assignment
- Ensuring Xcode build succeeds after file changes

## Three File Location Types

### Type 1: VortexFeatures SPM Package ✅ (Automatic)

**Location:** `VortexFeatures/Sources/VortexFeatures/...`

**Behavior:** Files are automatically included by Swift Package Manager
- ✅ No project.pbxproj updates needed
- ✅ No manual file references required
- ✅ Build automatically picks up new files

**Example paths:**
```
VortexFeatures/Sources/VortexFeatures/Core/DeviceManager/
VortexFeatures/Sources/VortexFeatures/VortexRestfulApi/
VortexFeatures/Sources/VortexFeatures/VortexBackend/Model/
```

**Action Required:** None - just create the file

---

### Type 2: VortexFeatures Tests ✅ (Automatic)

**Location:** `VortexFeatures/Tests/VortexFeaturesTests/...`

**Behavior:** Test files are automatically included by Swift Package Manager
- ✅ No project.pbxproj updates needed
- ✅ No manual file references required
- ✅ Build automatically picks up new test files

**Example paths:**
```
VortexFeatures/Tests/VortexFeaturesTests/Core/DeviceManagerTest.swift
VortexFeatures/Tests/VortexFeaturesTests/VortexBackend/APIClientTest.swift
```

**Action Required:** None - just create the file

---

### Type 3: Main Project (Outside SPM) ⚠️ (Manual Update Required)

**Location:** `iOSCharmander/...` or test directories (outside VortexFeatures)

**Behavior:** Must manually update Xcode project file
- ⚠️ Requires project.pbxproj updates
- ⚠️ Must add file references to correct target
- ⚠️ Must verify build succeeds

**Example paths:**
```
Source files:
iOSCharmander/View/Home/Tab/FloorPlanTab/
iOSCharmander/Common/FeatureProvider/
iOSCharmander/Model/

Unit test files:
iOSCharmanderTests/Test/

UI test files:
iOSCharmanderUITests/Device/
iOSCharmanderUITests/FloorPlan/
iOSCharmanderUITests/Organization/
```

**Action Required:** Update project.pbxproj + assign to correct target + verify build

---

## Target Assignment Rules

**IMPORTANT:** Target IDs and Build Phase IDs are project-specific. Always discover them from the current project's project.pbxproj file.

| File Location | File Pattern | Target Name | How to Find Target ID |
|---------------|--------------|-------------|----------------------|
| `iOSCharmander/...` | Source files | iOSCharmander (or main app target) | Search for `PBXNativeTarget.*"<AppName>"` in project.pbxproj |
| `<App>Tests/Test/` | `*Test.swift` | <App>Tests | Search for `PBXNativeTarget.*"<App>Tests"` in project.pbxproj |
| `<App>UITests/` | `*UITest.swift` | <App>UITests | Search for `PBXNativeTarget.*"<App>UITests"` in project.pbxproj |

**How to discover correct IDs:**

1. **Find Target ID:**
```bash
# Search for target definition
grep -A 10 'PBXNativeTarget.*"TargetName"' project.pbxproj
# Look for the hex ID before the comment
# Example: 8A01C08726314CB80030DA0A /* iOSCharmanderTests */
```

2. **Find Build Phase ID:**
```bash
# Search for Sources build phase for that target
grep -A 3 'isa = PBXNativeTarget' project.pbxproj | grep -A 50 'name = TargetName'
# Look for the buildPhases section, find ID with comment "/* Sources */"
# Example: 8A01C08426314CB80030DA0A /* Sources */
```

3. **Verify by checking existing test files:**
- Find a similar existing file in project.pbxproj
- Trace its PBXBuildFile entry to the PBXSourcesBuildPhase
- Confirm the build phase belongs to the correct target

**How to identify the correct target:**

1. **Unit Tests** (`*Test.swift`):
   - Location: `iOSCharmanderTests/Test/`
   - Target: iOSCharmanderTests
   - Flat directory structure

2. **UI Tests** (`*UITest.swift`):
   - Location: `iOSCharmanderUITests/<Feature>/`
   - Target: iOSCharmanderUITests
   - Feature-organized subdirectories (Device, FloorPlan, Organization, etc.)

3. **Source Files** (everything else):
   - Location: `iOSCharmander/...`
   - Target: iOSCharmander
   - Hierarchical structure

---

## Adding Files to Main Project (Type 3)

### Step 1: Create the File

Use Write tool to create the Swift file in the desired location.

```swift
// Example: iOSCharmander/View/Home/Tab/NewTab/NewTabViewModel.swift
import SwiftUI
import Observation

@MainActor
@Observable
final class NewTabViewModel {
    // Implementation
}
```

---

### Step 2: Update project.pbxproj

**Location:** `iOSCharmander.xcodeproj/project.pbxproj`

**IMPORTANT:** Use relative paths, NOT absolute paths!

#### Finding the Right Format

1. Read existing project.pbxproj
2. Find similar file references
3. Copy the path format

**Example - Relative Path Format:**
```
View/Home/Tab/NewTab/NewTabViewModel.swift
```

**NOT:**
```
/Users/username/code/project/iOSCharmander/View/Home/Tab/NewTab/NewTabViewModel.swift
```

#### Required Sections to Update

You need to add entries to three sections:

1. **PBXFileReference** - Define the file
2. **PBXGroup** - Add to logical folder
3. **PBXSourcesBuildPhase** - Include in build

**Read the existing project.pbxproj** to find the correct format and IDs.

---

### Step 3: Verify Build

**CRITICAL:** Always build after adding files!

**For source files:**
```bash
xcodebuild -project iOSCharmander.xcodeproj -scheme iOSCharmander -configuration Debug
```

**For unit test files:**
```bash
xcodebuild test -project iOSCharmander.xcodeproj -scheme iOSCharmander -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:iOSCharmanderTests
```

**For UI test files:**
```bash
xcodebuild test -project iOSCharmander.xcodeproj -scheme iOSCharmander -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:iOSCharmanderUITests
```

**If build fails:**
- Check file paths are relative
- Verify file is added to correct target (see Target Assignment Rules)
- Ensure correct build phase ID for the target
- Ensure file reference format matches existing files
- Check for typos in project.pbxproj

---

## Decision Tree

```
Adding a new Swift file?
│
├─ Inside VortexFeatures/Sources/?
│  └─ ✅ Just create the file (SPM automatic)
│
├─ Inside VortexFeatures/Tests/?
│  └─ ✅ Just create the file (SPM automatic)
│
├─ Is it a unit test file (*Test.swift)?
│  ├─ Location: <App>Tests/Test/
│  ├─ Target: <App>Tests
│  ├─ 1. Create the file
│  ├─ 2. Discover target ID from project.pbxproj
│  ├─ 3. Update project.pbxproj with correct target
│  └─ 4. Build and test to verify
│
├─ Is it a UI test file (*UITest.swift)?
│  ├─ Location: <App>UITests/<Feature>/
│  ├─ Target: <App>UITests
│  ├─ 1. Create the file
│  ├─ 2. Discover target ID from project.pbxproj
│  ├─ 3. Update project.pbxproj with correct target
│  └─ 4. Build and test to verify
│
└─ Source file in main project?
   ├─ Location: <App>/...
   ├─ Target: <App> (main app target)
   ├─ 1. Create the file
   ├─ 2. Discover target ID from project.pbxproj
   ├─ 3. Update project.pbxproj with correct target
   └─ 4. Build to verify
```

---

## Common Pitfalls

❌ **Using absolute paths in project.pbxproj**
```
// WRONG
/Users/ryan/code/project/iOSCharmander/View/Home/NewFile.swift
```

✅ **Using relative paths**
```
// CORRECT
View/Home/NewFile.swift
```

---

❌ **Forgetting to build after changes**
- Always run build to verify
- Catch issues early

---

❌ **Adding VortexFeatures files to project.pbxproj**
- SPM handles these automatically (both Sources and Tests)
- Don't manually add SPM files

---

❌ **Adding test files to wrong target**
```
// WRONG - Unit test in UI test target
iOSCharmanderTests/Test/DeviceManagerTest.swift → iOSCharmanderUITests target

// WRONG - UI test in unit test target
iOSCharmanderUITests/FloorPlan/FloorPlanUITest.swift → iOSCharmanderTests target
```

✅ **Correct target assignment**
```
// CORRECT
Unit tests (*Test.swift) → iOSCharmanderTests target
UI tests (*UITest.swift) → iOSCharmanderUITests target
Source files → iOSCharmander target
```

---

❌ **Using wrong build phase ID**
- Each target has its own Sources build phase ID
- Always discover IDs from the current project
- Don't copy IDs from other projects or documentation

---

❌ **Hardcoding target IDs from documentation**
- Target IDs are project-specific and change between projects
- Always discover IDs dynamically from project.pbxproj
- Use grep or search to find the correct IDs for your project

```bash
# WRONG - Using hardcoded ID from docs
Target ID: 8A01C08726314CB80030DA0A  # May not exist in your project!

# CORRECT - Discover from project
grep -A 10 'PBXNativeTarget' project.pbxproj | grep 'MyAppTests'
```

---

## Quick Checklist

When adding files:

- [ ] Determine file type and location:
  - VortexFeatures/Sources/ or VortexFeatures/Tests/? → ✅ Automatic (just create)
  - iOSCharmander/...? → Main app target
  - iOSCharmanderTests/Test/*Test.swift? → Unit test target
  - iOSCharmanderUITests/**/*UITest.swift? → UI test target
- [ ] If requires manual project update:
  - [ ] Create the file first
  - [ ] Identify correct target from Target Assignment Rules
  - [ ] Update project.pbxproj with relative paths
  - [ ] Add to correct PBXSourcesBuildPhase (use correct build phase ID)
  - [ ] Verify file reference format matches existing files
- [ ] **Always build/test to verify no errors**
  - Source files: xcodebuild build
  - Unit tests: xcodebuild test -only-testing:iOSCharmanderTests
  - UI tests: xcodebuild test -only-testing:iOSCharmanderUITests
- [ ] Commit project.pbxproj changes with the new files

---

## Example Workflows

### Scenario 1: Adding Source File to Main Project

**File:** `FloorPlanTabViewModel.swift`

```bash
# 1. Create file
# Location: iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanTabViewModel.swift

# 2. Discover target ID
grep -A 10 'PBXNativeTarget' iOSCharmander.xcodeproj/project.pbxproj | grep 'name = iOSCharmander'
# Found: 8A01C03526314CB70030DA0A /* iOSCharmander */

# 3. Discover build phase ID
grep -B 5 '8A01C03526314CB70030DA0A' iOSCharmander.xcodeproj/project.pbxproj | grep 'Sources'
# Found: 8A01C03226314CB70030DA0A /* Sources */

# 4. Read existing project.pbxproj to understand format
# Use Read tool on iOSCharmander.xcodeproj/project.pbxproj

# 5. Update project.pbxproj following existing patterns
# Add to PBXFileReference, PBXGroup, PBXSourcesBuildPhase with discovered IDs

# 6. Build to verify
xcodebuild -project iOSCharmander.xcodeproj -scheme iOSCharmander -configuration Debug

# 7. If successful, commit both files
git add iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanTabViewModel.swift
git add iOSCharmander.xcodeproj/project.pbxproj
git commit -m "feat(Vortex): add FloorPlanTabViewModel"
```

### Scenario 2: Adding Unit Test File

**File:** `DeviceManagerTest.swift`

```bash
# 1. Create file
# Location: iOSCharmanderTests/Test/DeviceManagerTest.swift

# 2. Discover target ID by searching for existing test file
grep 'AppManagerTest.swift' iOSCharmander.xcodeproj/project.pbxproj
# Trace the file to its PBXBuildFile, then to PBXSourcesBuildPhase
# Or search directly:
grep -A 10 'PBXNativeTarget' iOSCharmander.xcodeproj/project.pbxproj | grep 'iOSCharmanderTests'
# Found target: 8A01C08726314CB80030DA0A
# Found build phase: 8A01C08426314CB80030DA0A

# 3. Read existing project.pbxproj to understand format
# Look for similar test files like AppManagerTest.swift

# 4. Update project.pbxproj
# Add to PBXFileReference, PBXGroup (Test folder), PBXSourcesBuildPhase (test target)

# 5. Build and run tests to verify
xcodebuild test -project iOSCharmander.xcodeproj -scheme iOSCharmander \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:iOSCharmanderTests

# 6. If successful, commit both files
git add iOSCharmanderTests/Test/DeviceManagerTest.swift
git add iOSCharmander.xcodeproj/project.pbxproj
git commit -m "test(Vortex): add DeviceManager unit tests"
```

### Scenario 3: Adding UI Test File

**File:** `FloorPlanUITest.swift`

```bash
# 1. Create file
# Location: iOSCharmanderUITests/FloorPlan/FloorPlanUITest.swift

# 2. Discover target ID by searching for existing UI test file
grep 'DeviceInfoUITest.swift' iOSCharmander.xcodeproj/project.pbxproj
# Trace to find target and build phase IDs
# Or search directly:
grep -A 10 'PBXNativeTarget' iOSCharmander.xcodeproj/project.pbxproj | grep 'iOSCharmanderUITests'
# Found target: 8A205B6F26FC646A004D4371
# Found build phase: 8A205B6C26FC646A004D4371

# 3. Read existing project.pbxproj to understand format
# Look for similar UI test files like DeviceInfoUITest.swift

# 4. Update project.pbxproj
# Add to PBXFileReference, PBXGroup (FloorPlan folder), PBXSourcesBuildPhase (UI test target)

# 5. Build and run UI tests to verify
xcodebuild test -project iOSCharmander.xcodeproj -scheme iOSCharmander \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -only-testing:iOSCharmanderUITests

# 6. If successful, commit both files
git add iOSCharmanderUITests/FloorPlan/FloorPlanUITest.swift
git add iOSCharmander.xcodeproj/project.pbxproj
git commit -m "test(Vortex): add FloorPlan UI tests"
```

---

## Path Format Reference

Study existing entries in project.pbxproj:

```
/* Example PBXFileReference format */
A1B2C3D4E5F6 /* NewFile.swift */ = {
    isa = PBXFileReference;
    fileEncoding = 4;
    lastKnownFileType = sourcecode.swift;
    path = NewFile.swift;  // ← Relative to parent group
    sourceTree = "<group>";
};
```

**Key Points:**
- `path` is relative to the parent group
- `sourceTree = "<group>"` means relative path
- Follow the exact format of existing files
