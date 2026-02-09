# CI Scripts

這個目錄包含需要部署到 CI 機器上的腳本。

## 檔案說明

### extract_uitest_data.sh

**用途：** 在 CI 機器上提取 UITest 執行結果的精簡資料

**部署位置：** `/Users/vivotekinc/Documents/iOSTool/iOSCharmander-ai-specs/uitest-automation/ci-scripts/extract_uitest_data.sh`

**執行時機：** Jenkins UITest job 完成後自動執行

**輸入：** 完整的 `.xcresult` bundle (200-500 MB)

**輸出：** 精簡的分析資料夾 (5-20 MB)
```
/Users/vivotekinc/Documents/CICD/UITestAnalysisData/YYYY-MM-DD/
├── metadata.json              # 測試統計摘要
├── test_summary.json          # 測試結果摘要
├── test_details.json          # 詳細測試資訊（含錯誤行號）
├── test_failures.json         # 失敗詳情
├── failed_test_ids.txt        # 失敗測試 ID 列表
├── diagnostics/               # Crash logs, console output
└── attachments/               # 截圖（已移除影片檔）
```

## 部署步驟

### 1. 複製腳本到 CI 機器

```bash
# 從本地機器執行
scp uitest-automation/ci-scripts/extract_uitest_data.sh \
    vivotekinc@172.18.2.83:/Users/vivotekinc/Documents/iOSTool/iOSCharmander-ai-specs/uitest-automation/ci-scripts/

# 設定執行權限
ssh vivotekinc@172.18.2.83 \
    "chmod +x /Users/vivotekinc/Documents/iOSTool/iOSCharmander-ai-specs/uitest-automation/ci-scripts/extract_uitest_data.sh"
```

### 2. 在 Jenkins 中整合

編輯 UITest Jenkins job，在測試完成後加入：

```bash
# 測試完成後執行資料提取
/bin/bash ~/Documents/iOSTool/iOSCharmander-ai-specs/uitest-automation/ci-scripts/extract_uitest_data.sh
```

### 3. 驗證部署

```bash
# 測試腳本是否正常運作
ssh vivotekinc@172.18.2.83 \
    "bash ~/Documents/iOSTool/iOSCharmander-ai-specs/uitest-automation/ci-scripts/extract_uitest_data.sh"
```

## 自動清理機制

腳本會在每次執行時**自動清理超過 7 天的舊資料**：

| 清理目標 | 路徑 | 保留天數 |
|----------|------|----------|
| 提取資料 | `/Users/vivotekinc/Documents/CICD/UITestAnalysisData/` | 7 天 |
| xcresult 來源 | `/Users/vivotekinc/Documents/CICD/UITestReport/` | 7 天 |

**清理邏輯：**
- 根據資料夾/檔案名稱的日期（YYYY-MM-DD）判斷
- 自動跳過 symlink（如 `latest`）
- 每次執行都會顯示清理結果

**修改保留天數：**
```bash
# 在腳本開頭修改 RETENTION_DAYS 變數
RETENTION_DAYS=7  # 改成你想要的天數
```

## 優勢

**相比原本直接下載 xcresult：**

| 項目 | 原本 | 新架構 |
|------|------|--------|
| 下載大小 | 200-500 MB | 5-20 MB |
| 下載時間 | 5-10 分鐘 | 10-30 秒 |
| 超時風險 | 高 | 極低 |
| 本地需求 | xcresulttool | 只需 jq |
| 資料完整性 | 完整但龐大 | 精簡但足夠診斷 |
| 磁碟管理 | 手動清理 | 自動清理 |

**保留的診斷資訊：**
- ✅ 測試結果 JSON（含精確錯誤行號）
- ✅ 失敗截圖（UI 實際狀態）
- ✅ Crash logs（App 崩潰資訊）
- ✅ Console output（Debug 訊息）
- ✅ 系統診斷日誌

**移除的資料：**
- ❌ 影片檔（截圖已足夠，且影片很大）

## 疑難排解

### 腳本執行失敗

檢查：
1. CI 機器是否安裝 `jq`：`brew install jq`
2. xcresult 路徑是否正確
3. 輸出目錄是否有寫入權限

### 資料不完整

檢查：
1. xcresult bundle 是否完整（測試是否正常完成）
2. 查看腳本輸出的錯誤訊息
3. 手動執行 `xcrun xcresulttool` 確認 xcresult 可讀取

### 清理功能問題

檢查：
1. 確認日期格式正確（YYYY-MM-DD）
2. 查看腳本輸出的 "Cutoff date" 是否正確
3. 手動執行 `date -v-7d +%Y-%m-%d` 確認日期計算正常
