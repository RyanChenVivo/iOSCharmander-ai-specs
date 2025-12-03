# UITest 自動化分析與修正工具

這個工具集幫助你自動分析 Jenkins CI 上的 UITest 失敗，並使用 AI 建立修正任務。

## 🎯 功能

- ✅ 自動從 CI 機器下載測試結果
- ✅ 提取測試失敗資訊和截圖
- ✅ 使用 AI 分析失敗原因
- ✅ 自動建立 OpenSpec 修正提案
- ✅ 完全可移植，支援多台電腦使用

## 📁 檔案結構

```
uitest-automation/
├── README.md                       # 本檔案
├── SETUP.md                        # 快速設定指南
├── GUIDE.md                        # 詳細使用指南
├── analyze_uitest_failures.sh     # 主要分析腳本
├── analyze-uitest-command.md      # Claude Code slash command
└── config.example.sh              # 設定檔範例
```

## 🚀 快速開始

### 1. 設定環境

```bash
# 在 iOSCharmander-ai-specs 根目錄
cp uitest-automation/config.example.sh config.sh

# 編輯 config.sh，更新 CI 機器資訊
nano config.sh
```

### 2. 使用 Claude Code 分析（推薦）

在 Claude Code 中，從 `iOSCharmander-ai-specs` 專案目錄：

```
/add-file uitest-automation/analyze-uitest-command.md
```

然後說：
```
我們來看看今天UITest的狀況並且建立openspec格式的修正任務
```

### 3. 手動執行腳本

```bash
# 分析今天的測試結果
./uitest-automation/analyze_uitest_failures.sh -d today

# 分析特定日期
./uitest-automation/analyze_uitest_failures.sh -d 2025-12-03

# 只匯出失敗相關的資料
./uitest-automation/analyze_uitest_failures.sh -d today -f
```

## 📊 工作流程

```
1. Jenkins 執行 UITest
   ↓
2. 產生 .xcresult 儲存在 CI 機器
   ↓
3. 執行 analyze_uitest_failures.sh
   ↓
4. 下載並分析測試結果
   ↓
5. 提取失敗資訊和截圖
   ↓
6. Claude Code 分析失敗原因
   ↓
7. 建立 OpenSpec 修正提案
   ↓
8. 實作修正並驗證
```

## 📖 詳細文件

- **[SETUP.md](./SETUP.md)** - 首次設定指南
- **[GUIDE.md](./GUIDE.md)** - 完整使用指南和最佳實踐
- **[analyze-uitest-command.md](./analyze-uitest-command.md)** - Claude Code 指令說明

## 💡 使用情境

### 情境 1: 每日例行檢查

```bash
# 每天早上檢查昨晚的測試結果
./uitest-automation/analyze_uitest_failures.sh -d today -f
```

### 情境 2: PR 前檢查

```bash
# 檢查最新的測試結果，確保 PR 不會破壞測試
./uitest-automation/analyze_uitest_failures.sh -d today
```

### 情境 3: 回溯調查

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

1. **每日檢查** - 養成每天檢查測試結果的習慣
2. **及時修復** - 測試失敗後儘快分析和修復
3. **查看截圖** - 截圖是診斷問題的關鍵
4. **使用 OpenSpec** - 為每個問題建立規範的修正提案
5. **文件化** - 在提案中詳細記錄問題和解決方案

## 🤝 支援

如有問題或建議，請聯繫：
- Ryan Chen (ryan.cl.chen@vivotek.com)

或在 GitHub 上提 issue：
- https://github.com/RyanChenVivo/iOSCharmander-ai-specs/issues
