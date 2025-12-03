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
├── README.md                       # 本檔案 - 快速開始指南
├── PROJECT.md                      # 完整架構說明與最佳實踐
├── SETUP.md                        # 環境設定指南
├── GUIDE.md                        # 詳細使用指南
├── analyze_uitest_failures.sh     # 主要分析腳本
├── analyze-uitest-command.md      # Claude Code slash command
├── config.example.sh              # 設定檔範例
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

### 2. 使用 AI Agent 分析並建立修正提案（推薦）

在 Claude Code 中，從 `iOSCharmander-ai-specs` 專案目錄執行：

```
/analyze-uitest
```

然後說：
```
分析今天的 UITest 失敗並建立 OpenSpec 修正提案
```

AI Agent 會自動：
1. 執行 `analyze_uitest_failures.sh` 抓取測試結果
2. 搜尋 `openspec/archive/` 查找類似歷史問題
3. 分析失敗原因（檢視測試碼、截圖、錯誤訊息）
4. 建立包含完整診斷的 OpenSpec proposal
5. 建議修復方案

### 3. 手動執行腳本

```bash
# 分析今天的測試結果
./uitest-automation/analyze_uitest_failures.sh -d today

# 分析特定日期
./uitest-automation/analyze_uitest_failures.sh -d 2025-12-03

# 只匯出失敗相關的資料
./uitest-automation/analyze_uitest_failures.sh -d today -f
```

## 📊 完整工作流程

```
1. CI 執行 UITest
   ↓
2. 產生 .xcresult 儲存在 CI 機器
   ↓
3. AI Agent: 執行 analyze_uitest_failures.sh
   ├─ 下載 .xcresult
   ├─ 提取 test_failures.json
   ├─ 提取 test_summary.json
   └─ 提取截圖到 attachments/
   ↓
4. AI Agent: 搜尋歷史修復記錄
   └─ grep openspec/archive/ 尋找類似問題
   ↓
5. AI Agent: 診斷失敗原因
   ├─ 讀取測試源碼
   ├─ 檢視失敗截圖
   ├─ 分析錯誤訊息
   └─ 參考歷史修復經驗
   ↓
6. AI Agent: 建立 OpenSpec Proposal
   ├─ 記錄完整診斷過程
   ├─ 附上截圖和錯誤證據
   └─ 建議修復方案
   ↓
7. 開發者: 實作修復
   ↓
8. 開發者: Archive OpenSpec Change
   └─ 知識自動累積到 openspec/archive/ ✨
   ↓
9. 下次遇到類似問題時，AI Agent 可參考這次的修復經驗 🔄
```

## 📖 詳細文件

- **[PROJECT.md](./PROJECT.md)** - 架構設計、兩種操作模式、知識庫說明
- **[SETUP.md](./SETUP.md)** - 環境設定指南
- **[GUIDE.md](./GUIDE.md)** - 完整使用指南和最佳實踐
- **[analyze-uitest-command.md](./analyze-uitest-command.md)** - AI Agent 工作流程定義

### 知識庫檔案

- **[test-specs/ui-identifiers.md](./test-specs/ui-identifiers.md)** - UI 元素 accessibility IDs 目錄
- **[test-specs/test-data.md](./test-specs/test-data.md)** - UAT 測試數據需求
- **[test-specs/timing-guidelines.md](./test-specs/timing-guidelines.md)** - 等待時間與 timeout 指南
- **[test-specs/external-dependencies.md](./test-specs/external-dependencies.md)** - 外部服務行為記錄（如 Microsoft SSO）

## 💡 使用情境

### 情境 1: 每日例行檢查

```bash
# 每天早上檢查昨晚的測試結果
./uitest-automation/analyze_uitest_failures.sh -d today -f
```

### 情境 2: 利用 Archive 加速診斷

當遇到測試失敗時，AI Agent 會先搜尋歷史修復記錄：

```bash
# 範例：遇到 "StaticText is not exist" 錯誤
cd /path/to/iOSCharmander-ai-specs
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

### 情境 3: PR 前檢查

```bash
# 檢查最新的測試結果，確保 PR 不會破壞測試
./uitest-automation/analyze_uitest_failures.sh -d today
```

### 情境 4: 回溯調查

```bash
# 檢查過去某天的測試結果
./uitest-automation/analyze_uitest_failures.sh -d 2025-11-20
```

## ⚙️ 設定說明

在 `config.sh` 中設定：

```bash
# CI 機器連線
CI_MACHINE="user@hostname"

# CI 測試報告路徑
CI_REPORT_BASE="/path/to/CI/reports"

# iOSCharmander 專案路徑（自動偵測，通常不需要改）
IOSCHARMANDER_PATH="../iOSCharmander"

# 分析結果輸出目錄
OUTPUT_DIR="$HOME/Downloads/UITestAnalysis"
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

分析完成後，會在 `~/Downloads/UITestAnalysis/` 產生：

```
UITestAnalysis/
├── ANALYSIS_REPORT.md      # 總覽報告
├── test_summary.json        # 測試摘要
├── test_details.json        # 詳細測試資訊
├── test_failures.json       # 失敗詳情
├── failed_test_ids.txt      # 失敗測試 ID 列表
├── attachments/             # 截圖和附件
│   ├── Screenshot_*.png
│   └── manifest.json
└── diagnostics/             # 診斷日誌
```

## 🎓 最佳實踐

### 分析與診斷
1. **每日檢查** - 養成每天檢查測試結果的習慣
2. **查看截圖優先** - 截圖是診斷問題的 ground truth
3. **搜尋歷史記錄** - 執行 `grep -r "關鍵字" openspec/archive/*/proposal.md` 查找類似問題

### OpenSpec Proposal 撰寫
4. **完整記錄診斷過程** - 包含錯誤訊息、截圖路徑、測試碼行號
5. **標記失敗模式** - 在 proposal 中加入 `Error Pattern:` 標籤（如 UI_ELEMENT_NOT_FOUND）
6. **附上證據** - 截圖、測試碼片段、相關 app 碼
7. **參考歷史修復** - 如找到類似問題，在 proposal 中加入 `Related Changes:` 連結

### 知識累積
8. **及時 Archive** - 修復完成後立即執行 `/openspec:archive`
9. **更新 test-specs** - 發現新 UI ID 或外部依賴變化時，同步更新知識庫
10. **記錄預防措施** - 在 proposal 中說明如何避免未來類似問題

## 🤝 支援

如有問題或建議，請聯繫：
- Ryan Chen (ryan.cl.chen@vivotek.com)

或在 GitHub 上提 issue：
- https://github.com/RyanChenVivo/iOSCharmander-ai-specs/issues
