## Context

View Tab 使用 nested `LazyVGrid` 結構：外層 `FlexibleGridView` 以 `LazyVGrid` render sites，每個 site 展開後內層又用 `FlexibleGridView`（`LazyVGrid`）render devices。這觸發 Apple 已知 bug（FB21851974）— nested lazy containers 在大量 cell 同時展開時產生 `AsyncRenderer dispatch_assert_queue_fail` crash。

實測確認：
- 1000 sites，每 site >10 devices 時全展開必 crash
- 問題不在 `DisclosureGroup`、state mutation 方式、或 `DeviceView` 複雜度
- 內層 `FlexibleGridView` 換成 `ForEach` + `Text` 就不 crash → 確認是 nested `LazyVGrid` 問題

目標規模：1000 sites / 5000 devices 穩定運作。

## Goals / Non-Goals

**Goals:**
- 消除 nested `LazyVGrid` 造成的 crash
- 支援 1000 sites / 5000 devices 全展開不 crash
- 保持現有 UX 行為（展開/收合、全展開/全收合、site header、device grid layout）
- 保持滑動效能（lazy rendering）
- 新 component 為通用設計，可在其他場景複用

**Non-Goals:**
- 不改變 `DeviceView` 或 `SiteRow` 的內容/樣式
- 不改變 `DeviceManager` 的 data model 或 API
- 不處理搜尋模式（`ViewTabSiteSearchingView`）— 搜尋結果量小，暫不受影響
- 不改動外層結構（`FlexibleGridView` + `RoundedBackgroundDisclosureGroup` 保持不動）

## Decisions

### Decision 1: 內層 device grid 替換為 UICollectionView-backed component

**選擇**: 建立 `CollectionGridView`，以 `UICollectionView` + `UIHostingConfiguration` 實作，API 對齊 `FlexibleGridView`，只替換 `ViewTabSiteView` 內層的 device grid。

**放棄的替代方案**:
- Flattened single-layer `LazyVGrid`：`LazyVGrid` column 定義是整個 grid 統一的，無法讓 site header（1 column）和 device cell（2 columns）共存；`Section` header 是 pinned/sticky 行為，與 `DisclosureGroup` UX 不同
- 內層改 non-lazy `VStack`：每個可見 site 一次 evaluate 所有 devices，500 devices/site 時滑動卡頓
- 分批展開（每次展開 N 個 site）：UX 不自然

**理由**: 最小改動策略 — 只要內層不是 SwiftUI lazy container 就能避開 nested lazy bug。`UICollectionView` 有 cell reuse 機制，大量 device 也不會有效能問題。

### Decision 2: CollectionGridView 作為通用 component 放在 VortexFeatures

**選擇**: `CollectionGridView` 放在 `VortexFeatures/Sources/VortexFeatures/UI/GridView/`，與 `FlexibleGridView` 同層，API 對齊（`config`, `items`, `content`）。

**理由**: 任何需要在 SwiftUI lazy container 內嵌套 grid 的場景都能使用，不只限於 ViewTab。設計為 drop-in replacement — 呼叫端只需把 `FlexibleGridView` 改成 `CollectionGridView`。

### Decision 3: Cell 內容繼續用 SwiftUI

**選擇**: `UICollectionViewCell` 使用 `UIHostingConfiguration` 包裝 SwiftUI content view（`DeviceView` 等），不重寫 UI layer。

**理由**: 只換 layout engine，不換 UI layer。現有的 `DeviceView`、`SiteRow` 等 SwiftUI view 全部複用。

## Risks / Trade-offs

- **UIHostingConfiguration 效能**: 每個 cell 包一個 SwiftUI hosting view，比純 UIKit cell 略重 → 但比 nested `LazyVGrid` 好得多，且 cell reuse 機制會控制同時存在的 hosting view 數量
- **高度計算**: `UICollectionView` 嵌在 SwiftUI 裡需要正確回報 content height → 需要在 layout 完成後更新 height constraint
- **搜尋模式未處理**: `ViewTabSiteSearchingView` 仍使用 nested `FlexibleGridView`，但搜尋結果量通常很小，暫不受影響
