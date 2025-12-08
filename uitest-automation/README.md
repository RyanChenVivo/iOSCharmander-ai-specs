# UITest 自動化分析與修正工具

這個工具集幫助 AI Agent 自動分析 Jenkins CI 上的 UITest 失敗，透過 OpenSpec 工作流程建立修正提案，並將修復知識累積到 archive 中，實現持續改進的測試維護循環。

## 🎯 核心理念

**知識累積循環：**
```
測試失敗 → AI 分析 → OpenSpec Proposal → 修復 → Archive → 知識庫 🔄
```

每次修復都會在 `openspec/archive/` 留下完整記錄，讓 AI Agent 在下次遇到類似問題時可以參考歷史經驗，逐步提升診斷準確度和修復效率。

## ✨ 功能

- ✅ 自動從 CI 機器下載測試結果
- ✅ 提取測試失敗資訊和截圖
- ✅ AI Agent 分析失敗原因並搜尋歷史修復記錄
- ✅ 建立包含完整診斷資訊的 OpenSpec 修正提案
- ✅ 修復後 archive，自動累積知識庫
- ✅ 完全可移植，支援多台電腦使用

## 📁 檔案結構

```
uitest-automation/
├── README.md                       # 本檔案 - 快速開始與使用指南
├── PROJECT.md                      # 完整架構說明與技術細節
├── SETUP.md                        # 環境設定指南
├── download_test_data.sh          # 輕量下載腳本（僅下載 JSON）
├── config.example.sh              # 設定檔範例
│
├── ci-scripts/                     # CI 機器上的腳本
│   ├── extract_uitest_data.sh     # 在 CI 機器上提取精簡資料
│   └── README.md                  # CI 腳本部署說明
│
└── test-specs/                     # UITest 知識庫
    ├── ui-identifiers.md           # UI 元素 accessibility IDs
    ├── test-data.md                # 測試數據需求
    ├── timing-guidelines.md        # 等待時間指南
    └── external-dependencies.md    # 外部依賴行為記錄
```

## 🚀 快速開始

### 1. 設定環境

```bash
# 在 iOSCharmander-ai-specs 根目錄
cp uitest-automation/config.example.sh config.sh

# 編輯 config.sh，更新 CI 機器資訊
nano config.sh
```

### 2. 使用 AI Agent 進行分析（唯一推薦方式）

在 Claude Code 中執行：

```
/analyze-uitest
```

**AI Agent 自動執行完整流程：**

**階段 1: 下載測試資料（輕量，約 100KB）**
- 自動執行 `download_test_data.sh` 從 CI 下載 JSON 檔案
- 下載時間：約 10-30 秒

**階段 2: AI Triage 分析**
1. 檢查是否有失敗測試
2. 讀取測試源碼、錯誤訊息、失敗資訊
3. 搜尋 `openspec/archive/` 查找類似歷史問題
4. 檢查 `external-dependencies.md` 確認已知問題
5. 生成 triage 報告並詢問用戶決策：
   - **A**: 建立 OpenSpec proposal 修復
   - **B**: 下載截圖深入分析
   - **C**: 觀察明天（可能是暫時性問題）
   - **D**: 不需處理（已知問題）

**階段 3: 根據用戶決定執行**
- 如選擇 A，建立包含完整診斷的 OpenSpec proposal
- 如選擇 B，下載截圖並進行深入分析

**為什麼統一使用 AI Agent？**
- ✅ 所有經驗在同一流程中累積和疊代
- ✅ 流程一致性，更容易優化
- ✅ 減少人為錯誤
- ✅ 新成員學習成本低

> **注意**：不建議手動執行底層腳本，因為最終還是需要 AI 進行 triage 分析。底層腳本技術細節請見本文後段「進階技術細節」。

## 📊 完整工作流程

```
1. CI 執行 UITest
   ↓
2. 產生 .xcresult 儲存在 CI 機器
   ↓
3. CI: 執行 extract_uitest_data.sh（自動）
   ├─ 從 .xcresult 提取精簡資料
   ├─ 產生 JSON 檔案（test_summary.json, test_details.json, test_failures.json）
   ├─ 提取截圖和診斷資料
   └─ 儲存到 UITestAnalysisData/ (約 5-20 MB，vs 原本 200-500 MB)
   ↓
4. AI Agent: 執行 download_test_data.sh（快速）
   └─ 只下載 JSON 檔案（約 100 KB，10-30 秒）
   ↓
5. AI Agent: Triage 分析
   ├─ 檢查失敗數量
   ├─ 讀取測試源碼
   ├─ 分析錯誤訊息
   ├─ 搜尋 openspec/archive/ 尋找歷史問題
   ├─ 檢查 external-dependencies.md 確認已知問題
   └─ 生成 triage 報告
   ↓
6. AI Agent: 詢問用戶決策
   ├─ A: 建立 OpenSpec proposal
   ├─ B: 下載截圖深入分析
   ├─ C: 觀察明天
   └─ D: 不需處理
   ↓
7. [如選擇 A] AI Agent: 建立 OpenSpec Proposal
   ├─ 記錄完整診斷過程
   ├─ 附上錯誤證據
   └─ 建議修復方案
   ↓
8. 開發者: 實作修復
   ↓
9. 開發者: Archive OpenSpec Change
   └─ 知識自動累積到 openspec/archive/ ✨
   ↓
10. 下次遇到類似問題時，AI Agent 可參考這次的修復經驗 🔄
```

## 📖 詳細文件

- **[PROJECT.md](./PROJECT.md)** - 架構設計、兩種操作模式、知識庫說明
- **[SETUP.md](./SETUP.md)** - 環境設定指南
- **[ci-scripts/README.md](./ci-scripts/README.md)** - CI 端腳本部署說明（CI 管理員）

### 知識庫檔案

- **[test-specs/ui-identifiers.md](./test-specs/ui-identifiers.md)** - UI 元素 accessibility IDs 目錄
- **[test-specs/test-data.md](./test-specs/test-data.md)** - UAT 測試數據需求
- **[test-specs/timing-guidelines.md](./test-specs/timing-guidelines.md)** - 等待時間與 timeout 指南
- **[test-specs/external-dependencies.md](./test-specs/external-dependencies.md)** - 外部服務行為記錄（如 Microsoft SSO）

## 💡 使用情境

### 情境 1: 每日例行檢查

```
# 在 Claude Code 中執行
/analyze-uitest
```

AI 會自動下載最新測試結果並進行 triage 分析（總時間約 1 分鐘）。

### 情境 2: 利用 Archive 加速診斷

當遇到測試失敗時，AI Agent 會自動搜尋歷史修復記錄：

```bash
# 範例：遇到 "StaticText is not exist" 錯誤
grep -r "StaticText is not exist" openspec/archive/*/proposal.md

# 範例：搜尋特定測試類別的歷史問題
grep -r "AccessControlMessageUITest" openspec/archive/*/proposal.md

# 範例：搜尋特定錯誤模式
grep -r "UI_ELEMENT_NOT_FOUND" openspec/archive/*/proposal.md
```

找到類似問題後，AI Agent 可以：
- 參考當時的診斷過程
- 重用相同的修復策略
- 在新 proposal 中引用歷史 change

### 情境 3: 深入分析需要截圖

當 AI triage 建議下載截圖時，選擇選項 **B**，AI 會自動幫你下載並分析截圖。

### 情境 4: 檢查特定日期的測試

```bash
# 如需查看歷史資料，可手動下載特定日期
scp -r "vivotekinc@10.15.254.191:/Users/vivotekinc/Documents/CICD/UITestAnalysisData/2025-12-03" \
    "$HOME/Downloads/UITestAnalysis/2025-12-03/"

# 然後在 Claude Code 中執行
/analyze-uitest
```

AI 會自動偵測並分析該日期的資料。

## ⚙️ 設定說明

新架構簡化了設定，主要在 `download_test_data.sh` 和 `ci-scripts/extract_uitest_data.sh` 中：

**本地端（download_test_data.sh）：**
```bash
# CI 機器連線
CI_MACHINE="vivotekinc@10.15.254.191"

# CI 提取資料的基礎路徑
CI_DATA_BASE="/Users/vivotekinc/Documents/CICD/UITestAnalysisData"

# 本地輸出目錄
OUTPUT_DIR="$HOME/Downloads/UITestAnalysis"
```

**CI 端（extract_uitest_data.sh，在 CI 機器上）：**
```bash
# .xcresult 來源路徑
XCRESULT_PATH="/Users/vivotekinc/Documents/CICD/UITestReport/${TEST_DATE}.xcresult"

# 提取資料的輸出路徑
OUTPUT_BASE="/Users/vivotekinc/Documents/CICD/UITestAnalysisData"
```

## 🔧 常見問題

### Q: 無法連線到 CI 機器？

**A**: 檢查：
1. 是否在公司網路內
2. CI 機器 IP 是否正確
3. SSH 連線是否已設定
4. 或使用網路掛載方式

### Q: 找不到測試報告？

**A**: 確認：
1. 該日期是否有執行測試
2. CI_REPORT_BASE 路徑是否正確
3. 測試是否成功產生 .xcresult

### Q: jq 指令找不到？

**A**: 安裝 jq：
```bash
brew install jq
```

## 📝 輸出檔案說明

### CI 端提取的資料（UITestAnalysisData/）

```
UITestAnalysisData/
├── 2025-12-08/              # 按日期分類
│   ├── metadata.json        # 測試統計摘要
│   ├── test_summary.json    # 測試結果摘要
│   ├── test_details.json    # 詳細測試資訊（含錯誤行號）
│   ├── test_failures.json   # 失敗詳情（僅在有失敗時）
│   ├── failed_test_ids.txt  # 失敗測試 ID 列表
│   ├── attachments/         # 截圖（已移除影片）
│   │   ├── Screenshot_*.png
│   │   └── manifest.json
│   └── diagnostics/         # Crash logs, console output
└── latest -> 2025-12-08/    # 符號連結指向最新資料
```

### 本地端下載的資料（Downloads/UITestAnalysis/）

```
UITestAnalysis/
└── latest/
    ├── metadata.json        # 測試統計（總數、失敗數、日期）
    ├── test_summary.json    # 測試結果摘要
    ├── test_details.json    # 詳細測試資訊
    ├── test_failures.json   # 失敗詳情
    ├── failed_test_ids.txt  # 失敗測試 ID 列表
    └── attachments/         # 截圖（需要時才下載）
        ├── Screenshot_*.png
        └── manifest.json
```

## 🎓 最佳實踐

### 分析與診斷
1. **快速 Triage** - 先用輕量下載 + AI 分析判斷是否需要處理
2. **理性決策** - 不是所有失敗都需要立即修復（可能是暫時性或已知問題）
3. **按需下載截圖** - 只在需要視覺確認時才下載截圖，節省時間
4. **搜尋歷史記錄** - AI 會自動搜尋，你也可以手動 `grep -r "關鍵字" openspec/archive/*/proposal.md`

### OpenSpec Proposal 撰寫（僅當決定修復時）
5. **完整記錄診斷過程** - 包含錯誤訊息、測試碼行號、triage 分析結果
6. **標記失敗模式** - 在 proposal 中加入 `Error Pattern:` 標籤（如 UI_ELEMENT_NOT_FOUND）
7. **附上證據** - 錯誤訊息、測試碼片段、截圖（如有下載）
8. **參考歷史修復** - 如找到類似問題，在 proposal 中加入 `Related Changes:` 連結

### 知識累積
9. **及時 Archive** - 修復完成後立即執行 `/openspec:archive`
10. **更新 test-specs** - 發現新 UI ID 或外部依賴變化時，同步更新知識庫
11. **記錄預防措施** - 在 proposal 中說明如何避免未來類似問題
12. **更新 external-dependencies.md** - 發現新的外部服務行為變化時記錄下來

---

## 🔧 進階：技術細節與底層腳本

> **重要**：以下內容僅供了解技術實現或調試使用。日常使用請直接執行 `/analyze-uitest`。

### 底層腳本說明

AI Agent 在執行時會自動調用以下腳本：

#### download_test_data.sh（本地端）

```bash
# AI 自動執行，無需手動調用
./uitest-automation/download_test_data.sh
```

**功能：**
- 從 CI 下載最新測試結果的 JSON 檔案
- 下載大小：約 100 KB
- 下載時間：10-30 秒
- 輸出位置：`~/Downloads/UITestAnalysis/latest/`

**配置：**
```bash
CI_MACHINE="vivotekinc@10.15.254.191"
CI_DATA_BASE="/Users/vivotekinc/Documents/CICD/UITestAnalysisData"
OUTPUT_DIR="$HOME/Downloads/UITestAnalysis"
```

如需修改配置，直接編輯腳本檔案。

#### extract_uitest_data.sh（CI 端）

```bash
# 在 CI 機器上由 Jenkins 自動執行
/Users/vivotekinc/Documents/CICD/scripts/extract_uitest_data.sh
```

**功能：**
- 從 .xcresult (200-500 MB) 提取精簡資料
- 提取 JSON、截圖、診斷日誌
- 移除影片檔節省空間
- 輸出大小：5-20 MB
- 輸出位置：`/Users/vivotekinc/Documents/CICD/UITestAnalysisData/{YYYY-MM-DD}/`

部署說明請見 `ci-scripts/README.md`（僅 CI 管理員需要）。

### 手動查看資料（僅供調試）

如果需要手動檢查下載的資料：

```bash
# 查看測試統計
cat ~/Downloads/UITestAnalysis/latest/metadata.json | jq .

# 查看失敗詳情
cat ~/Downloads/UITestAnalysis/latest/test_failures.json | jq .

# 查看詳細資訊（含錯誤行號）
cat ~/Downloads/UITestAnalysis/latest/test_details.json | jq .
```

---

## 🤝 支援

如有問題或建議，請聯繫：
- Ryan Chen (ryan.cl.chen@vivotek.com)

或在 GitHub 上提 issue：
- https://github.com/RyanChenVivo/iOSCharmander-ai-specs/issues
