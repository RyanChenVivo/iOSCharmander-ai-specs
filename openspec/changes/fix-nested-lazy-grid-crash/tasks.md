## 1. Create CollectionGridView Component

- [ ] 1.1 Create `CollectionGridView.swift` in `VortexFeatures/Sources/VortexFeatures/UI/GridView/`, using `UIViewControllerRepresentable` + `UICollectionView` + `UIHostingConfiguration`
- [ ] 1.2 API 對齊 `FlexibleGridView`: `init(config:items:content:)`, 支援 `Config`（count, rowSpacing, columnSpacing）
- [ ] 1.3 Handle content height reporting — layout 完成後更新 height constraint，讓外層 SwiftUI 正確計算大小

## 2. Replace Inner Device Grid

- [ ] 2.1 In `ViewTabSiteView`, replace inner `FlexibleGridView` (device grid inside `RoundedBackgroundDisclosureGroup`) with `CollectionGridView`
- [ ] 2.2 Keep all parameters identical: `config: .init(count: isListMode ? 1 : 2)`, `items: devices`, content closure

## 3. Verification

- [ ] 3.1 Clean build and verify no compiler errors
- [ ] 3.2 Test with 1000 sites / 5000 devices: expand all → collapse all → expand all without crash
- [ ] 3.3 Test individual site expand/collapse works correctly
- [ ] 3.4 Test list mode vs grid mode layout renders correctly
- [ ] 3.5 Verify scroll performance is acceptable
