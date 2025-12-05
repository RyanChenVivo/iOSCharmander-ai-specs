# CI Scripts

這個目錄包含需要部署到 CI 機器上的腳本。

## 檔案說明

### extract_uitest_data.sh

**用途：** 在 CI 機器上提取 UITest 執行結果的精簡資料

**部署位置：** `/Users/vivotekinc/Documents/CICD/scripts/extract_uitest_data.sh`

**執行時機：** Jenkins UITest job 完成後自動執行

**輸入：** 完整的 `.xcresult` bundle (200-500 MB)

**輸出：** 精簡的分析資料夾 (5-20 MB)
```
/Users/vivotekinc/Documents/CICD/UITestData/YYYY-MM-DD/
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
    vivotekinc@10.15.254.191:/Users/vivotekinc/Documents/CICD/scripts/

# 設定執行權限
ssh vivotekinc@10.15.254.191 \
    "chmod +x /Users/vivotekinc/Documents/CICD/scripts/extract_uitest_data.sh"
```

### 2. 在 Jenkins 中整合

編輯 UITest Jenkins job，在測試完成後加入：

```bash
# 測試完成後執行資料提取
if [ -f "$XCRESULT_PATH" ]; then
    /Users/vivotekinc/Documents/CICD/scripts/extract_uitest_data.sh "$XCRESULT_PATH"
fi
```

或者手動執行：

```bash
# 在 CI 機器上
/Users/vivotekinc/Documents/CICD/scripts/extract_uitest_data.sh \
    /Users/vivotekinc/Documents/CICD/UITestReport/2025-12-05.xcresult
```

### 3. 驗證部署

```bash
# 測試腳本是否正常運作
ssh vivotekinc@10.15.254.191 \
    "/Users/vivotekinc/Documents/CICD/scripts/extract_uitest_data.sh --help"
```

## 資料保留策略

建議在 CI 機器上設定定期清理：

```bash
# 保留最近 7 天的完整 xcresult
find /Users/vivotekinc/Documents/CICD/UITestReport -name "*.xcresult" -mtime +7 -delete

# 保留最近 30 天的提取資料
find /Users/vivotekinc/Documents/CICD/UITestData -maxdepth 1 -type d -mtime +30 -delete
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
