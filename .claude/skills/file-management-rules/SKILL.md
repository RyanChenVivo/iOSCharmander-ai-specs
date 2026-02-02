---
name: file-management-rules
description: Add files to Xcode project correctly. Use when creating new Swift files outside SPM packages to ensure proper project configuration.
---

# File Management Rules

Use this skill when:
- Adding new Swift files to the main project (outside VortexFeatures package)
- Creating new directories with Swift files
- Modifying project.pbxproj
- Ensuring Xcode build succeeds after file changes

## Two File Location Types

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

### Type 2: Main Project (Outside SPM) ⚠️ (Manual Update Required)

**Location:** `iOSCharmander/...` (outside VortexFeatures)

**Behavior:** Must manually update Xcode project file
- ⚠️ Requires project.pbxproj updates
- ⚠️ Must add file references
- ⚠️ Must verify build succeeds

**Example paths:**
```
iOSCharmander/View/Home/Tab/FloorPlanTab/
iOSCharmander/Common/FeatureProvider/
iOSCharmander/Model/
```

**Action Required:** Update project.pbxproj + verify build

---

## Adding Files to Main Project (Type 2)

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

```bash
# Build the project
xcodebuild -project iOSCharmander.xcodeproj -scheme iOSCharmander -configuration Debug
```

**If build fails:**
- Check file paths are relative
- Verify file is added to correct target
- Ensure file reference format matches existing files
- Check for typos in project.pbxproj

---

## Decision Tree

```
Adding a new Swift file?
│
├─ Inside VortexFeatures/Sources/?
│  └─ ✅ Just create the file (automatic)
│
└─ Outside VortexFeatures (in iOSCharmander)?
   ├─ 1. Create the file
   ├─ 2. Update project.pbxproj (relative paths!)
   └─ 3. Build to verify
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
- SPM handles these automatically
- Don't manually add SPM files

---

## Quick Checklist

When adding files outside VortexFeatures:

- [ ] Determine if file is in VortexFeatures SPM (automatic) or main project (manual)
- [ ] If main project: Create the file first
- [ ] If main project: Update project.pbxproj with relative paths
- [ ] If main project: Verify file reference format matches existing files
- [ ] **Always build the project to verify no errors**
- [ ] Commit project.pbxproj changes with the new files

---

## Example Workflow

**Scenario:** Adding `FloorPlanTabViewModel.swift` to main project

```bash
# 1. Create file
# Location: iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanTabViewModel.swift

# 2. Read existing project.pbxproj to understand format
# Use Read tool on iOSCharmander.xcodeproj/project.pbxproj

# 3. Update project.pbxproj following existing patterns
# Add to PBXFileReference, PBXGroup, PBXSourcesBuildPhase

# 4. Build to verify
xcodebuild -project iOSCharmander.xcodeproj -scheme iOSCharmander -configuration Debug

# 5. If successful, commit both files
git add iOSCharmander/View/Home/Tab/FloorPlanTab/FloorPlanTabViewModel.swift
git add iOSCharmander.xcodeproj/project.pbxproj
git commit -m "feat(Vortex): add FloorPlanTabViewModel"
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
