## Why

View Tab 的「全展開」按鈕在大量 site（~1000 sites / ~5000 devices）時觸發 `AsyncRenderer dispatch_assert_queue_fail` crash。根因是 nested `LazyVGrid`（外層 sites grid 內嵌內層 devices grid）觸發 Apple 已知的 framework bug（FB21851974），當大量 cell 同時從收合變展開時，SwiftUI 的 lazy view lifecycle 產生 race condition。

## What Changes

- **Replace inner FlexibleGridView (LazyVGrid) with UICollectionView-backed CollectionGridView**: 在 `RoundedBackgroundDisclosureGroup` 內部，將 device grid 從 SwiftUI `LazyVGrid` 換成 UIKit `UICollectionView` 實作，避開 nested lazy container 問題。
  - 外層結構（`FlexibleGridView` + `RoundedBackgroundDisclosureGroup`）不動
  - 只替換內層 device grid 的 rendering engine
  - `CollectionGridView` 作為通用 component，API 對齊 `FlexibleGridView`，可在其他場景複用

## Capabilities

### New Capabilities
- `collection-grid-view`: UIKit `UICollectionView`-backed grid component，API 對齊 `FlexibleGridView`，可安全嵌套在 SwiftUI lazy container 內而不觸發 nested lazy crash。放在 `VortexFeatures` SPM package 供全 app 使用。

### Modified Capabilities
- `ios-view-tab-device-management`: 內層 device grid 從 `FlexibleGridView`（`LazyVGrid`）改為 `CollectionGridView`（`UICollectionView`）。外層結構、展開/收合行為、視覺效果不變。

## Impact

- `SiteView.swift`（`ViewTabSiteView`）— 內層 `FlexibleGridView` 替換為 `CollectionGridView`
- `CollectionGridView.swift`（新增）— UICollectionView-backed grid component in VortexFeatures
- `RoundedBackgroundDisclosureGroup.swift` — 不動
- `FlexibleGridView` — 外層仍使用，不動
- 無 API 變動、無 dependency 變動

## Decision Log

### 2026-03-25: 放棄 flattened single-layer LazyVGrid 方案

**原方案**: 將 site header + device cells 攤平成 flat array，用單層 `LazyVGrid` render。

**放棄原因**:
- `LazyVGrid` column 定義是整個 grid 統一的，無法讓 site header（1 column）和 device cell（2 columns）共存於同一個 `ForEach`
- `Section` header 是 pinned/sticky 行為，與原本 `DisclosureGroup` 的 UX 不同
- 在 1000 sites × 5000 devices 的量級下，SwiftUI `LazyVGrid` 即使攤平也有 view tree 過大、state 變化量過大的風險

**結論**: 以這個量級來說，UIKit `UICollectionView` 是唯一能同時解決所有問題的方案：

| 問題 | SwiftUI LazyVGrid | UICollectionView |
|------|-------------------|------------------|
| Nested lazy crash | ❌ Apple bug | ✅ 原生支援 section + item |
| 5M items 記憶體 | ❌ view tree 太大 | ✅ cell reuse，只 retain 可見 cell |
| 全展開/收合 | ❌ 大量 state 變化 crash | ✅ reloadSections 只處理可見 |
| Scroll stability | ❌ 高度變化跳動 | ✅ estimated height + prefetch |

### 2026-03-25: 採用最小改動驗證策略

**決定**: 先做簡單版本測試 — 只將 `ViewTabSiteView` 內層的 `FlexibleGridView`（device grid）替換為 `CollectionGridView`（UICollectionView），外層結構完全不動，驗證是否能解決 nested lazy crash。

**理由**: 
- 問題確認是「lazy 裡面套 lazy」，只要內層不是 SwiftUI lazy container 就應該能解決
- 外層 `FlexibleGridView` + `RoundedBackgroundDisclosureGroup` 結構不動，改動最小
- `CollectionGridView` 設計為通用 component（對齊 `FlexibleGridView` API），未來其他地方也能用
