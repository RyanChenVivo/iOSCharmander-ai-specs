# Generate Design System

Scan UI components from iOSCharmander project and generate design system documentation for use by VortexPrototype project.

## Output Location

Write to `design-system/` folder in this project (iOSCharmander-ai-specs):

```
design-system/
├── index.md                 # Index + Component Selection Guide
├── typography.md            # Font Sizes, Text Styles, Color Modifiers
├── colors.md               # Semantic, Text, Surface, Outline, Icon colors (with hex codes)
├── button-styles.md        # Large, Medium, Small, Special buttons
├── row-patterns.md         # BasicRow, MenuRow, ToggleRow, FilterRow, etc.
├── section-patterns.md     # SectionHeader, SectionFooter, BottomSheet
├── textfield-patterns.md   # TextField styles
└── layout.md               # Spacing, Sizing, Page Structure
```

## Source Paths

```
../iOSCharmander/
├── iOSCharmander/View/Component/
│   ├── TextStyle/          → typography.md
│   ├── ButtonStyle/        → button-styles.md
│   ├── CustomRow/          → row-patterns.md
│   ├── Section/            → section-patterns.md
│   ├── BottomSheet/        → section-patterns.md
│   ├── TextField/          → textfield-patterns.md
│   ├── Avatar/             → section-patterns.md
│   └── *.swift             → appropriate pattern file
└── Assets.xcassets/Color/  → colors.md (extract hex from Contents.json)
```

## Execution Flow

1. **Scan** - Read all files under source paths
2. **Analyze** - Extract from each component:
   - Purpose (one-line description)
   - Structure (ASCII diagram with spacing values inline)
   - Specs Table (structured key-value for all properties)
   - Usage (code examples)
3. **Extract Colors** - Parse Assets.xcassets/Color/*/Contents.json for hex values
4. **Generate** - Create all markdown files
5. **Show summary** - Display what was generated
6. **Confirm** - Ask user before writing
7. **Write** - Save all files

---

## Output Format: index.md

```markdown
# VORTEX Design System

> Auto-generated on [date]
> Source: iOSCharmander

## Quick Reference

| Need | Component | File |
|------|-----------|------|
| Text styling | `.textStyle(.body.color02)` | [typography.md](typography.md) |
| Primary button | `.solidLargePrimary()` | [button-styles.md](button-styles.md) |
| Key-value row | `BasicRow` | [row-patterns.md](row-patterns.md) |
| Section header | `SectionHeader` | [section-patterns.md](section-patterns.md) |
| Text input | `RowTextFieldStyle` | [textfield-patterns.md](textfield-patterns.md) |
| Colors | `colorPrimary`, `colorSurface03` | [colors.md](colors.md) |
| Spacing/Sizing | 16pt padding, 48pt row height | [layout.md](layout.md) |

## Component Selection Guide

### Level 1: Use Existing Components

| Need | Component |
|------|-----------|
| Key-value display | `BasicRow` |
| Navigate to detail | `NavigationRow` |
| Toggle setting | `ToggleRow` |
| Menu item | `MenuRow` |
| Section title | `SectionHeader` |
| Primary CTA | `.solidLargePrimary()` |
| Secondary action | `.ghostLarge(.secondary)` |
| Destructive action | `.ghostLarge(.danger)` |

### Level 2: Compose Existing Components

| Page Type | Composition |
|-----------|-------------|
| Settings page | `List` + `Section` + `BasicRow`/`ToggleRow` |
| Filter page | `NavigationStack` + `CheckableGroupView` + `Toolbar(Save)` |
| Detail page | `ScrollView` + `InfoCard` + `BasicRow` list |
| Form page | `VStack` + `TextField` components + `.solidLargePrimary()` |

### Level 3: Build with Tokens

See [layout.md](layout.md) for spacing/sizing tokens and [colors.md](colors.md) for color tokens.
```

---

## Output Format: colors.md

**IMPORTANT:** Extract actual hex values from `Assets.xcassets/Color/[ColorName]/Contents.json`

Each color asset has a Contents.json with structure:
```json
{
  "colors": [
    { "idiom": "universal", "color": { "components": { "red": "0x1A", ... } } },
    { "idiom": "universal", "appearances": [{"value": "dark"}], "color": { ... } }
  ]
}
```

```markdown
# Colors

## How to Add Missing Colors

If VortexPrototype is missing a color, add it in `Assets.xcassets`:
1. Right-click → New Color Set
2. Name it exactly as shown (e.g., `colorText01`)
3. Set "Any Appearance" to the Light hex value
4. Set "Dark" appearance to the Dark hex value

---

## Semantic Colors

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `colorPrimary` | `#007AFF` | `#0A84FF` | Primary action (CTA buttons) |
| `colorPrimaryActive` | `#0056B3` | `#0070E0` | Primary pressed state |
| `colorDanger` | `#FF3B30` | `#FF453A` | Destructive actions |
| `colorSuccess` | `#34C759` | `#30D158` | Success state |
| `colorAlert` | `#FF9500` | `#FF9F0A` | Warning state |
| ... | ... | ... | ... |

## Text Colors

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `colorText01` | `#1A1A1A` | `#FFFFFF` | Primary text |
| `colorText02` | `#666666` | `#B3B3B3` | Secondary text (most common) |
| `colorText03` | `#333333` | `#E5E5E5` | Tertiary / pressed state |
| `colorText04` | `#999999` | `#808080` | Descriptions |
| `colorText05` | `#AAAAAA` | `#666666` | Section headers, hints |
| `colorText06` | `#CCCCCC` | `#4D4D4D` | Disabled text |
| `colorText09` | `#FFFFFF` | `#FFFFFF` | Text on filled buttons |
| `colorTextPrimary` | `#007AFF` | `#0A84FF` | Primary action text (blue) |
| `colorTextDanger` | `#FF3B30` | `#FF453A` | Error text (red) |
| `colorTextSuccess` | `#34C759` | `#30D158` | Success text (green) |
| `colorTextAlert` | `#FF9500` | `#FF9F0A` | Warning text (orange) |
| ... | ... | ... | ... |

## Surface Colors

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `colorSurface02` | `#F2F2F7` | `#000000` | Page background |
| `colorSurface03` | `#FFFFFF` | `#1C1C1E` | Card/section background, nav bar |
| `colorSurface04` | `#F2F2F7` | `#2C2C2E` | Input field background |
| `colorSurface05` | `#E5E5EA` | `#3A3A3C` | List item pressed state |
| `colorSurface06` | `#D1D1D6` | `#48484A` | Disabled background |
| ... | ... | ... | ... |

## Outline Colors

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `colorOutline01` | `#C6C6C8` | `#3A3A3C` | Primary border |
| `colorOutline04` | `#E5E5EA` | `#2C2C2E` | Disabled border |
| `colorOutline07` | `#007AFF` | `#0A84FF` | Selected/focused border |
| `colorOutline14` | `#E5E5EA` | `#2C2C2E` | Subtle divider |
| ... | ... | ... | ... |

## Icon Colors

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `colorIcon01` | `#C7C7CC` | `#48484A` | Disabled icon |
| `colorIcon02` | `#8E8E93` | `#636366` | Secondary (arrows, chevrons) |
| `colorIcon03` | `#666666` | `#AEAEB2` | Tertiary (ToggleRow, LinkRow) |
| `colorIcon06` | `#007AFF` | `#0A84FF` | Selected/check icon |
| `colorIcon15` | `#007AFF` | `#0A84FF` | Accent (default menu icon) |
| `colorIcon17` | `#FF3B30` | `#FF453A` | Destructive icon (red) |
| ... | ... | ... | ... |

## State Color Quick Reference

| State | Background | Border | Text | Icon |
|-------|------------|--------|------|------|
| Normal | `colorSurface03` | `colorOutline01` | `colorText01` | `colorIcon15` |
| Pressed | `colorSurface05` | `colorOutline18` | `colorText03` | `colorIcon16` |
| Disabled | `colorSurface06` | `colorOutline04` | `colorText06` | `colorIcon01` |
| Selected | - | - | `colorText01` | `colorIcon06` |
| Destructive | - | `colorDanger` | `colorTextDanger` | `colorIcon17` |
```

---

## Output Format: typography.md

```markdown
# Typography

## Text Styles

| Style | Font Size | Weight | Default Color | Usage |
|-------|-----------|--------|---------------|-------|
| `.largeTitleBold` | 34pt | bold | colorText01 | Page main title |
| `.title1Bold` | 28pt | bold | colorText01 | Section title |
| `.title2Bold` | 22pt | bold | colorText01 | Card title |
| `.title3Semibold` | 20pt | semibold | colorText01 | Subsection title |
| `.body` | 17pt | regular | (none - must add modifier) | Base body text |
| `.bodyBold` | 17pt | bold | (none) | Emphasized body |
| `.bodySemibold` | 17pt | semibold | (none) | Semi-emphasized body |
| `.callout` | 16pt | regular | (none) | Callout text |
| `.calloutSemibold` | 16pt | semibold | (none) | Emphasized callout |
| `.subhead` | 15pt | regular | (none) | Subheading |
| `.footnote` | 13pt | regular | (none) | Footnote |
| `.caption1` | 12pt | regular | (none) | Caption, labels |
| `.caption1Semibold` | 12pt | semibold | (none) | Emphasized caption |
| `.caption2` | 11pt | regular | (none) | Smallest text |

## Color Modifiers

Apply to styles without default color: `.textStyle(.body.color02)`

| Modifier | Maps to | Usage |
|----------|---------|-------|
| `.color01` | `colorText01` | Primary text |
| `.color02` | `colorText02` | Secondary text (most common) |
| `.color03` | `colorText03` | Tertiary / pressed state |
| `.color04` | `colorText04` | Descriptions |
| `.color05` | `colorText05` | Section headers, hints |
| `.color06` | `colorText06` | Disabled text |
| `.color09` | `colorText09` | Text on primary buttons (white) |
| `.primary` | `colorTextPrimary` | Action text (blue) |
| `.danger` | `colorTextDanger` | Error/destructive (red) |
| `.success` | `colorTextSuccess` | Success (green) |
| `.alert` | `colorTextAlert` | Warning (orange) |

## Usage Examples

```swift
// Title with built-in color
Text("Page Title").textStyle(.largeTitleBold)

// Body with color modifier
Text("Description").textStyle(.body.color02)

// Error message
Text("Invalid input").textStyle(.caption1.danger)

// Button label
Text("Submit").textStyle(.bodySemibold.color09)
```

## Implementation Pattern

If VortexPrototype needs to implement TextStyle:

```swift
struct TextStyle {
    var font: Font
    var weight: Font.Weight
    var color: Color?

    // Styles with default color
    static let largeTitleBold = TextStyle(font: .system(size: 34), weight: .bold, color: .colorText01)
    static let title2Bold = TextStyle(font: .system(size: 22), weight: .bold, color: .colorText01)

    // Styles without default color (require modifier)
    static let body = TextStyle(font: .system(size: 17), weight: .regular, color: nil)
    static let caption1 = TextStyle(font: .system(size: 12), weight: .regular, color: nil)
}

// Color modifiers
extension TextStyle {
    var color01: TextStyle { withColor(.colorText01) }
    var color02: TextStyle { withColor(.colorText02) }
    var color04: TextStyle { withColor(.colorText04) }
    var primary: TextStyle { withColor(.colorTextPrimary) }
    var danger: TextStyle { withColor(.colorTextDanger) }

    private func withColor(_ c: Color) -> TextStyle {
        TextStyle(font: font, weight: weight, color: c)
    }
}

// View modifier
extension View {
    func textStyle(_ style: TextStyle) -> some View {
        self
            .font(style.font.weight(style.weight))
            .foregroundStyle(style.color ?? .primary)
    }
}
```
```

---

## Output Format: button-styles.md

```markdown
# Button Styles

## Large Buttons (height: 50pt)

### SolidLargePrimaryButtonStyle

**Purpose:** Primary call-to-action button

**Structure:**
```
┌──────────────────────────────────────────────────────┐
│                      [Label]                          │
│                  .bodySemibold.color09                │
├──────────────────────────────────────────────────────┤
│ height: 50pt    corner-radius: 8pt    padding-h: 16pt │
└──────────────────────────────────────────────────────┘
```

**Specs Table:**
| Property | Normal | Pressed | Disabled |
|----------|--------|---------|----------|
| Background | `colorPrimary` | `colorPrimaryActive` | `colorSurface06` |
| Text | `.bodySemibold.color09` | `.bodySemibold.color09` | `.bodySemibold.color07` |
| Height | 50pt | 50pt | 50pt |
| Corner radius | 8pt | 8pt | 8pt |

**Usage:**
```swift
Button("OK").buttonStyle(.solidLargePrimary())
Button("OK").buttonStyle(.solidLargePrimary(isLoading: true))
```

---

### GhostLargeButtonStyle

**Purpose:** Secondary action with border

**Structure:**
```
┌──────────────────────────────────────────────────────┐
│                      [Label]                          │
│              .bodySemibold / .body                    │
├──────────────────────────────────────────────────────┤
│ height: 50pt    border: 1pt    corner-radius: 8pt     │
└──────────────────────────────────────────────────────┘
```

**Specs Table:**
| Mode | Text Style | Text Color | Border Color |
|------|------------|------------|--------------|
| `.primary` | `.bodySemibold` | `colorText01` / `colorText03` (pressed) | `colorOutline01` / `colorOutline18` |
| `.secondary` | `.body` | `colorText01` / `colorText03` (pressed) | `colorOutline01` / `colorOutline18` |
| `.danger` | `.bodySemibold` | `colorTextDanger` / `colorTextDangerActive` | `colorDanger` |

| Property | Value |
|----------|-------|
| Height | 50pt |
| Corner radius | 8pt |
| Border width | 1pt |
| Background (pressed) | `colorSurface05` |

**Usage:**
```swift
Button("Cancel").buttonStyle(.ghostLarge(.secondary))
Button("Delete").buttonStyle(.ghostLarge(.danger))
```

---

## Medium Buttons (height: 36pt)

### SolidMediumPrimaryButtonStyle

**Structure:**
```
┌────────────────────────────────┐
│           [Label]              │
│      .caption1Semibold.color09 │
├────────────────────────────────┤
│ height: 36pt   corner-radius: 8pt │
└────────────────────────────────┘
```

**Specs Table:**
| Property | Normal | Pressed | Disabled |
|----------|--------|---------|----------|
| Background | `colorPrimary` | `colorPrimaryActive` | `colorSurface06` |
| Text | `.caption1Semibold.color09` | same | `.caption1Semibold.color07` |
| Height | 36pt | 36pt | 36pt |

**Usage:**
```swift
Button("Save").buttonStyle(.solidMediumPrimary())
```

---

### NakedIconMediumButtonStyle

**Purpose:** Text + icon button for toolbars

**Structure:**
```
┌────────────────────────────────┐
│   [Icon 20pt]  [Label]         │
│                .callout        │
├────────────────────────────────┤
│ height: 36pt   spacing: 4pt    │
└────────────────────────────────┘
```

**Specs Table:**
| Mode | Text Color | Icon Color |
|------|------------|------------|
| `.primary` | `colorTextPrimary` | `colorTextPrimary` |
| `.secondary` | `colorText02` | `colorIcon02` |
| `.danger` | `colorTextDanger` | `colorIcon17` |

**Usage:**
```swift
Button("Filter").buttonStyle(.nakedIconMediumSecondary(.iconFilter))
```

---

## Small Buttons

(Continue same pattern...)

## Special Buttons

(Continue same pattern...)
```

---

## Output Format: row-patterns.md

```markdown
# Row Patterns

## BasicRow

**Purpose:** Key-value display for settings pages

**Structure:**
```
┌─────────────────────────────────────────────────────────────┐
│ 16pt │ [Title]              │    │ [Description] │ 8pt │ [→] │ 16pt │
│      │ .body.color02        │    │ .body.color04 │     │24x24│      │
│      │ minWidth: 150pt      │    │               │     │     │      │
├─────────────────────────────────────────────────────────────┤
│ height: 48pt          background: colorSurface03            │
│ pressed background: colorSurface05 (when action provided)   │
└─────────────────────────────────────────────────────────────┘
```

**Specs Table:**
| Property | Value |
|----------|-------|
| Height | 48pt |
| Horizontal padding | 16pt |
| Title min width | 150pt |
| Title style | `.body.color02` |
| Description style | `.body.color04` |
| Icon size | 24x24pt |
| Icon-text spacing | 8pt |
| Icon color | `colorIcon02` |
| Background | `colorSurface03` |
| Background (pressed) | `colorSurface05` |

**Usage:**
```swift
// Static display
BasicRow(title: "Name", description: "Value")

// With navigation arrow
BasicRow(title: "Name", description: "Value", image: .iconGeneralArrowRightSolid)

// Tappable
BasicRow(title: "Name", description: "Value", image: .iconGeneralArrowRightSolid) {
    // action
}
```

**Variants:** `NavigationRow`, `NavigationFieldRow`, `BasicRowWithColorLabel`

---

## MenuRow

**Purpose:** Menu item with optional icon and selection state

**Structure:**
```
┌─────────────────────────────────────────────────────────────┐
│ 16pt │ [Icon] │ 16pt │ [Description]        │    │ [✓] │ 16pt │
│      │ 28x28  │      │ .body.color01        │    │28x28│      │
├─────────────────────────────────────────────────────────────┤
│ height: 48pt          background: colorSurface03            │
│ pressed background: colorSurface05                          │
└─────────────────────────────────────────────────────────────┘
```

**Specs Table:**
| Property | Value |
|----------|-------|
| Height | 48pt |
| Horizontal padding | 16pt |
| Icon size | 28x28pt |
| Icon-text spacing | 16pt |
| Check icon size | 28x28pt |
| Background | `colorSurface03` |
| Background (pressed) | `colorSurface05` |

**State Colors:**
| State | Icon Color | Text Color |
|-------|------------|------------|
| Normal | `colorIcon15` | `colorText01` |
| Selected | `colorIcon06` | `colorText01` |
| Destructive | `colorIcon17` | `colorTextDanger` |
| Disabled | `colorIcon01` | `colorText06` |

**Usage:**
```swift
MenuRow(description: "Settings", action: { })
MenuRow(image: .iconSettings, description: "Settings", action: { })
MenuRow(description: "Option", isSelected: true, action: { })
MenuRow(image: .iconDelete, description: "Delete", isDestructive: true, action: { })
```

---

## ToggleRow

**Purpose:** Setting item with toggle switch

**Structure:**
```
┌─────────────────────────────────────────────────────────────┐
│ 16pt │ [Icon] │ 16pt │ [Title]              │    │ [Toggle] │ 16pt │
│      │ 28x28  │      │ .body.color02        │    │          │      │
│      │ (opt)  │      │                      │    │          │      │
├─────────────────────────────────────────────────────────────┤
│ height: 48pt          background: colorSurface03            │
└─────────────────────────────────────────────────────────────┘
```

**Specs Table:**
| Property | Value |
|----------|-------|
| Height | 48pt |
| Horizontal padding | 16pt |
| Icon size | 28x28pt (optional) |
| Icon-text spacing | 16pt |
| Icon color | `colorIcon03` |
| Title style | `.body.color02` |
| Background | `colorSurface03` |

**Usage:**
```swift
ToggleRow(title: "Enable Feature", isOn: $isEnabled)
ToggleRow(icon: .iconBell, title: "Notifications", isOn: $notificationsOn)
```

---

## FilterRow

**Purpose:** Filter trigger button (right-aligned)

**Structure:**
```
┌─────────────────────────────────────────────────────────────┐
│                                          │ [Filter Button] │ 16pt │
│                                          │ nakedIconMedium │      │
├─────────────────────────────────────────────────────────────┤
│ height: 56pt                                                │
└─────────────────────────────────────────────────────────────┘
```

**Specs Table:**
| Property | Value |
|----------|-------|
| Height | 56pt |
| Horizontal padding | 16pt |
| Button style | `nakedIconMediumSecondary` |

**Usage:**
```swift
FilterRow {
    // show filter sheet
}
```

---

## SeeAllRow

**Purpose:** Section header with "See all" navigation

**Structure:**
```
┌─────────────────────────────────────────────────────────────┐
│ 16pt │ [Title]                    │    │ [See all →] │ 16pt │
│      │ .title3Semibold            │    │ .caption1.primary │      │
├─────────────────────────────────────────────────────────────┤
│ height: 56pt                                                │
└─────────────────────────────────────────────────────────────┘
```

**Specs Table:**
| Property | Value |
|----------|-------|
| Height | 56pt |
| Horizontal padding | 16pt |
| Title style | `.title3Semibold` |
| Link style | `.caption1Medium.primary` |

**Usage:**
```swift
SeeAllRow(title: "Recent Files") {
    AllFilesView()
}
```

---

## LinkRow

**Purpose:** Row with icon and clickable text

**Structure:**
```
┌─────────────────────────────────────────────────────────────┐
│ 16pt │ [Icon] │ 8pt │ [Content]                       │ 16pt │
│      │ 24x24  │     │ .body.color02 or .body.primary  │      │
├─────────────────────────────────────────────────────────────┤
│ height: 48pt          background: colorSurface03            │
└─────────────────────────────────────────────────────────────┘
```

**Specs Table:**
| Property | Value |
|----------|-------|
| Height | 48pt |
| Horizontal padding | 16pt |
| Icon size | 24x24pt |
| Icon-text spacing | 8pt |
| Icon color | `colorIcon03` |
| Text (no action) | `.body.color02` |
| Text (with action) | `.body.primary` |
| Background | `colorSurface03` |

**Usage:**
```swift
LinkRow(image: .iconEmail, content: "user@example.com")
LinkRow(image: .iconEmail, content: "user@example.com") { await openEmail() }
```

---

## SearchResultRow

**Purpose:** Shows search result count with search button

**Structure:**
```
┌─────────────────────────────────────────────────────────────┐
│ 16pt │ [Result Count]          │    │ [Search Button] │ 16pt │
│      │ .footnote.color05       │    │ nakedIconMedium │      │
├─────────────────────────────────────────────────────────────┤
│ height: 56pt                                                │
└─────────────────────────────────────────────────────────────┘
```

**Specs Table:**
| Property | Value |
|----------|-------|
| Height | 56pt |
| Horizontal padding | 16pt |
| Result text style | `.footnote.color05` |
| Max display count | 1000 (shows "1000+" if exceeded) |

**Usage:**
```swift
SearchResultRow(resultCount: 42) { performSearch() }
```

---

## Row Pattern Summary

| Component | Height | Icon | Primary Use |
|-----------|--------|------|-------------|
| `BasicRow` | 48pt | 24pt | Key-value display |
| `NavigationRow` | 48pt | 24pt | Navigate to detail |
| `MenuRow` | 48pt | 28pt | Menu items, selection |
| `ToggleRow` | 48pt | 28pt | On/off settings |
| `FilterRow` | 56pt | - | Filter trigger |
| `SeeAllRow` | 56pt | - | Section with link |
| `LinkRow` | 48pt | 24pt | Clickable content |
| `SearchResultRow` | 56pt | - | Search results |
```

---

## Output Format: section-patterns.md

```markdown
# Section Patterns

## SectionHeader

**Purpose:** Section title in list views

**Structure:**
```
┌─────────────────────────────────────────────────────────────┐
│ 16pt │ [Title]                                        │ 16pt │
│      │ .subhead.color05                               │      │
├─────────────────────────────────────────────────────────────┤
│ height: 56pt                                                │
└─────────────────────────────────────────────────────────────┘
```

**Specs Table:**
| Property | Value |
|----------|-------|
| Height | 56pt |
| Horizontal padding | 16pt |
| Title style | `.subhead.color05` |

**Usage:**
```swift
SectionHeader(title: "Settings")
```

**Variants:** `DateSectionHeader`, `IconSectionHeader`, `ToggleAllSectionHeader`

---

## SectionFooter

**Purpose:** Section description/hint below a section

**Structure:**
```
┌─────────────────────────────────────────────────────────────┐
│ 16pt │ [Text]                                         │ 16pt │
│      │ .caption1.color05                              │      │
├─────────────────────────────────────────────────────────────┤
│ height: 52pt                                                │
└─────────────────────────────────────────────────────────────┘
```

**Specs Table:**
| Property | Value |
|----------|-------|
| Height | 52pt |
| Horizontal padding | 16pt |
| Text style | `.caption1.color05` |

**Usage:**
```swift
SectionFooter(text: "This setting affects all devices")
```

---

## BottomSheetTitle

**Purpose:** Title bar for bottom sheets

**Structure:**
```
┌─────────────────────────────────────────────────────────────┐
│ 16pt │ [Title]                                        │ 16pt │
│      │ .title3Semibold                                │      │
├─────────────────────────────────────────────────────────────┤
│ height: 56pt                                                │
└─────────────────────────────────────────────────────────────┘
```

**Specs Table:**
| Property | Value |
|----------|-------|
| Height | 56pt |
| Horizontal padding | 16pt |
| Title style | `.title3Semibold` |

**Usage:**
```swift
BottomSheetTitle(title: "Select Option")
```

---

## Section Pattern Summary

| Component | Height | Text Style | Usage |
|-----------|--------|------------|-------|
| `SectionHeader` | 56pt | `.subhead.color05` | Section title |
| `SectionFooter` | 52pt | `.caption1.color05` | Section hint |
| `BottomSheetTitle` | 56pt | `.title3Semibold` | Bottom sheet title |
```

---

## Output Format: textfield-patterns.md

```markdown
# TextField Patterns

## RowTextFieldStyle

**Purpose:** Text field styled as a row item

**Structure:**
```
┌─────────────────────────────────────────────────────────────┐
│ 16pt │ [TextField]                             │ [X] │ 16pt │
│      │ .body.color02                           │20x20│      │
├─────────────────────────────────────────────────────────────┤
│ height: 48pt          background: colorSurface03            │
└─────────────────────────────────────────────────────────────┘
```

**Specs Table:**
| Property | Value |
|----------|-------|
| Height | 48pt |
| Horizontal padding | 16pt |
| Text style | `.body.color02` |
| Placeholder style | `.body.color05` |
| Clear button size | 20x20pt |
| Background | `colorSurface03` |

**Usage:**
```swift
TextField("Name", text: $name)
    .textFieldStyle(RowTextFieldStyle(text: $name))
```

---

## RoundedTextFieldStyle

**Purpose:** Rounded text field for search/input

**Structure:**
```
┌─────────────────────────────────────────────────────────────┐
│ 16pt │ [TextField]                             │ [X] │ 16pt │
│      │ .body.color02                           │20x20│      │
├─────────────────────────────────────────────────────────────┤
│ height: 44pt    corner-radius: 8pt    bg: colorInput01      │
└─────────────────────────────────────────────────────────────┘
```

**Specs Table:**
| Property | Value |
|----------|-------|
| Height | 44pt |
| Horizontal padding | 16pt |
| Corner radius | 8pt |
| Text style | `.body.color02` |
| Placeholder style | `.body.color05` |
| Clear button size | 20x20pt |
| Background | `colorInput01` |

**Usage:**
```swift
TextField("Search", text: $search)
    .textFieldStyle(RoundedTextFieldStyle(text: $search))
```

---

## DefaultTextFieldStyle

**Purpose:** Basic text field with clear button

**Features:**
- Autocorrection disabled
- Clear button when text present

**Usage:**
```swift
TextField("Placeholder", text: $text)
    .textFieldStyle(DefaultTextFieldStyle(text: $text))
```

---

## TextField Pattern Summary

| Style | Height | Corner Radius | Background | Usage |
|-------|--------|---------------|------------|-------|
| `RowTextFieldStyle` | 48pt | 0 | `colorSurface03` | In-row input |
| `RoundedTextFieldStyle` | 44pt | 8pt | `colorInput01` | Search, standalone |
| `DefaultTextFieldStyle` | - | - | - | Basic with clear |
```

---

## Output Format: layout.md

```markdown
# Layout Conventions

## Page Structure

```swift
.vortexDefaultLayout(navigationTitle: "Title")
```

- Page background: `colorSurface02`
- NavigationBar background: `colorSurface03`

## Spacing Scale

| Size | Value | Usage |
|------|-------|-------|
| Tight | 4pt | Icon-text in compact layouts |
| Small | 8pt | Related elements, icon-text spacing |
| Standard | 16pt | Default padding, section spacing |
| Card | 20pt | Card horizontal padding |
| Large | 24pt | Section vertical spacing |

## Sizing Standards

| Element | Size |
|---------|------|
| Row height (compact) | 48pt |
| Row height (standard) | 56pt |
| Large button height | 50pt |
| Medium button height | 36pt |
| Small icon | 20x20pt |
| Standard icon | 24x24pt |
| Large icon | 28x28pt |
| Corner radius (standard) | 8pt |
| Corner radius (pill) | 100pt |
| Minimum tap target | 44x44pt |

## Common Padding

| Context | Horizontal | Vertical |
|---------|------------|----------|
| Row content | 16pt | - |
| Card content | 20pt | 16pt |
| Page content | 16pt | - |
| Button content | 16pt | - |

## State Colors Reference

| State | Background | Border | Text | Icon |
|-------|------------|--------|------|------|
| Normal | `colorSurface03` | `colorOutline01` | `colorText01` | `colorIcon15` |
| Pressed | `colorSurface05` | `colorOutline18` | `colorText03` | `colorIcon16` |
| Disabled | `colorSurface06` | `colorOutline04` | `colorText06` | `colorIcon01` |
| Selected | - | `colorOutline07` | `colorText01` | `colorIcon06` |
| Error | - | `colorDanger` | `colorTextDanger` | `colorIcon17` |
```
