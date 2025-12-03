# UITest 自動化分析流程指南

這個指南說明如何使用 AI 來自動分析 UITest 失敗並產生修正任務。

## 概述

當 Jenkins CI 執行 UITest 後，會產生 `.xcresult` 檔案儲存在 CI 機器上。我們可以使用自動化工具提取測試結果、截圖和錯誤訊息，然後讓 AI 分析並建立 OpenSpec 修正任務。

## 工具架構

```
CI 機器 (vivotekinc)
  └─ /Users/vivotekinc/Documents/CICD/UITestReport/{日期}.xcresult
         ↓ (透過 analyze_uitest_failures.sh 下載並分析)
本地端
  └─ ~/Downloads/UITestAnalysis/
       ├─ ANALYSIS_REPORT.md          (總覽報告)
       ├─ test_summary.json           (測試摘要)
       ├─ test_failures.json          (失敗詳情)
       ├─ attachments/                (截圖)
       │   ├─ Screenshot_*.png
       │   └─ manifest.json
       └─ diagnostics/                (診斷日誌)
         ↓ (餵給 Claude Code 分析)
OpenSpec 修正提案
  └─ iOSCharmander-ai-specs/openspec/changes/fix-uitest-*/
```

## 使用方式

### 方法 1: 使用 Slash Command（推薦）

在 Claude Code 中，從 `iOSCharmander-ai-specs` 專案目錄執行：

```
/analyze-uitest
```

然後說：
```
我們來看看今天UITest的狀況並且建立openspec格式的修正任務
```

Claude Code 會自動：
1. 執行分析腳本從 CI 機器抓取測試結果
2. 分析失敗的測試
3. 檢視截圖了解實際 UI 狀態
4. 建立 OpenSpec 修正提案

### 方法 2: 手動執行

#### 步驟 1: 執行分析腳本

```bash
cd /Users/ryanchen/code/VIVOTEK/iOSCharmander

# 分析今天的測試結果
./Scripts/analyze_uitest_failures.sh -d today

# 或指定特定日期
./Scripts/analyze_uitest_failures.sh -d 2025-12-03

# 只提取失敗相關的資料（節省空間）
./Scripts/analyze_uitest_failures.sh -d today -f
```

#### 步驟 2: 查看分析報告

```bash
# 查看總覽
cat ~/Downloads/UITestAnalysis/ANALYSIS_REPORT.md

# 如果有失敗，查看失敗詳情
cat ~/Downloads/UITestAnalysis/test_failures.json | jq .

# 查看截圖
open ~/Downloads/UITestAnalysis/attachments/
```

#### 步驟 3: 讓 Claude Code 分析

在 Claude Code 對話中：

```
/add-dir ~/Downloads/UITestAnalysis
```

然後詢問：
```
請分析這些 UITest 失敗，並為每個問題建立 OpenSpec 修正提案
```

## 腳本參數說明

```bash
./Scripts/analyze_uitest_failures.sh [OPTIONS]

OPTIONS:
  -d, --date DATE       從 CI 機器抓取指定日期的報告
                        DATE 可以是 "today" 或 "YYYY-MM-DD" 格式

  -x, --xcresult PATH   分析本地的 .xcresult 檔案

  -o, --output DIR      指定輸出目錄
                        預設: ~/Downloads/UITestAnalysis

  -f, --only-failures   只匯出失敗相關的附件
                        (節省空間和時間)

  -h, --help            顯示說明
```

## 設定 CI 機器連線

腳本需要從 CI 機器下載測試結果，有兩種方式：

### 方式 1: SSH 連線（推薦）

1. 設定 SSH key (如果還沒設定)：
```bash
ssh-copy-id vivotekinc@10.1.30.38
```

2. 測試連線：
```bash
ssh vivotekinc@10.1.30.38 "ls /Users/vivotekinc/Documents/CICD/UITestReport/"
```

3. 更新腳本中的 CI 機器位址（如果不同）：
編輯 `Scripts/analyze_uitest_failures.sh`：
```bash
CI_MACHINE="vivotekinc@實際IP位址"
```

### 方式 2: 網路掛載

如果 CI 機器有共享資料夾：

1. 掛載 CI 機器的共享資料夾
2. 腳本會自動偵測並使用掛載路徑

## AI 分析的重點

當 Claude Code 分析失敗時，它會：

### 1. 識別失敗類型

- **UI 元素找不到**: identifier 改變？元素未顯示？
- **時序問題**: 載入太慢？動畫未完成？
- **斷言失敗**: 期望值不符？
- **測試資料問題**: UAT 環境資料改變？
- **App 行為改變**: 功能更新但測試未更新？

### 2. 檢視截圖

截圖是最重要的資訊來源：
- 失敗時 UI 的實際狀態
- 元素是否存在但位置改變
- 是否有非預期的 UI 顯示

### 3. 建議修正方案

- 更新 UI element identifier
- 加入適當的等待時間
- 修正測試斷言
- 更新測試資料
- 修正 UITest 邏輯

### 4. 建立 OpenSpec 提案

每個不同的問題會建立獨立的 OpenSpec change proposal：
- 清楚描述問題和原因
- 列出需要修改的檔案
- 提供測試驗證方式

## 輸出檔案說明

### ANALYSIS_REPORT.md
總覽報告，包含：
- 測試統計（總數、通過、失敗）
- 測試環境資訊
- 失敗測試列表
- 使用說明

### test_summary.json
測試摘要，包含：
```json
{
  "failedTests": 2,
  "passedTests": 36,
  "totalTestCount": 38,
  "result": "Failed",
  "testFailures": [...]
}
```

### test_details.json
所有測試的詳細資訊，包括測試階層結構和每個測試的結果。

### test_failures.json
失敗測試的詳細錯誤訊息。

### attachments/
測試附件，主要是截圖：
- `Screenshot_*.png`: 測試過程中的截圖
- `manifest.json`: 附件清單

### diagnostics/
診斷資訊，包含 crash logs 等。

## 常見問題

### Q: 腳本無法連線到 CI 機器？

A: 檢查：
1. CI 機器 IP 是否正確
2. SSH key 是否已設定
3. 網路連線是否正常
4. 防火牆設定

### Q: 找不到指定日期的測試結果？

A: 可能原因：
1. 該日期沒有執行測試
2. 測試執行失敗，未產生 xcresult
3. 檔案命名格式不同

檢查 CI 機器上的實際檔案：
```bash
ssh vivotekinc@10.1.30.38 "ls -la /Users/vivotekinc/Documents/CICD/UITestReport/"
```

### Q: 所有測試都通過，還需要分析嗎？

A: 如果測試全部通過，腳本會顯示成功訊息，不需要進一步分析。

### Q: 如何分析歷史測試結果？

A: 使用 `-d` 參數指定日期：
```bash
./Scripts/analyze_uitest_failures.sh -d 2025-11-21
```

## 進階使用

### 批次分析多個日期

```bash
#!/bin/bash
for date in 2025-12-01 2025-12-02 2025-12-03; do
  ./Scripts/analyze_uitest_failures.sh -d $date -o ~/Downloads/UITestAnalysis_$date
done
```

### 自動化通知

可以在 Jenkins 測試失敗後自動執行分析並通知：

```bash
# 在 Jenkins job 中加入
if [ "$FAILED_TESTS" -gt 0 ]; then
  ./Scripts/analyze_uitest_failures.sh -d today -f
  # 發送通知給團隊
fi
```

## 最佳實踐

1. **每日檢查**: 養成每天檢查 UITest 結果的習慣
2. **及時修復**: 測試失敗後儘快分析和修復，避免累積
3. **保留截圖**: 截圖是診斷問題的關鍵證據
4. **更新測試**: App 功能更新時，記得同步更新 UITest
5. **文件化**: 在 OpenSpec proposal 中詳細記錄問題和解決方案

## 相關檔案

- 分析腳本: `/Users/ryanchen/code/VIVOTEK/iOSCharmander/Scripts/analyze_uitest_failures.sh`
- Slash Command: `/Users/ryanchen/code/VIVOTEK/iOSCharmander-ai-specs/.claude/commands/analyze-uitest.md`
- UITest 原始碼: `/Users/ryanchen/code/VIVOTEK/iOSCharmander/iOSCharmanderUITests/`
- OpenSpec 提案: `/Users/ryanchen/code/VIVOTEK/iOSCharmander-ai-specs/openspec/changes/`

## 支援

如有問題，請聯繫：
- Ryan Chen (ryan.cl.chen@vivotek.com)
