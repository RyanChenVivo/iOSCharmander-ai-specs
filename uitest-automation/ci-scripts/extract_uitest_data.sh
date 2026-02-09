#!/bin/bash

# UITest Data Extraction Script
# This script extracts essential data from xcresult for AI analysis

set -e

# 設定路徑
TEST_DATE=$(date +%Y-%m-%d)
XCRESULT_PATH="/Users/vivotekinc/Documents/CICD/UITestReport/${TEST_DATE}.xcresult"
XCRESULT_DIR="/Users/vivotekinc/Documents/CICD/UITestReport"
OUTPUT_BASE="/Users/vivotekinc/Documents/CICD/UITestAnalysisData"
OUTPUT_DIR="${OUTPUT_BASE}/${TEST_DATE}"
RETENTION_DAYS=30

echo "========================================"
echo "UITest Data Extraction"
echo "========================================"
echo "Date: $TEST_DATE"
echo "xcresult: $XCRESULT_PATH"
echo ""

# 檢查 xcresult 是否存在
if [ ! -d "$XCRESULT_PATH" ]; then
    echo "ERROR: xcresult not found!"
    echo "Expected: $XCRESULT_PATH"
    exit 1
fi

echo "Found xcresult"
echo ""

# 建立輸出目錄
echo "Creating output directory: $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# 提取測試摘要
echo "Extracting test summary..."
xcrun xcresulttool get test-results summary --path "$XCRESULT_PATH" > test_summary.json

# 提取詳細測試資訊
echo "Extracting test details..."
xcrun xcresulttool get test-results tests --path "$XCRESULT_PATH" > test_details.json

# 解析結果
TOTAL_TESTS=$(jq -r '.totalTestCount // 0' test_summary.json)
PASSED_TESTS=$(jq -r '.passedTests // 0' test_summary.json)
FAILED_TESTS=$(jq -r '.failedTests // 0' test_summary.json)

echo "Tests: Total=$TOTAL_TESTS, Passed=$PASSED_TESTS, Failed=$FAILED_TESTS"

# 如果有失敗，提取失敗資訊
if [ "$FAILED_TESTS" -gt 0 ]; then
    echo "Extracting failure details..."
    jq '.testFailures' test_summary.json > test_failures.json
    jq -r '.testNodes[] | .. | select(.result? == "Failed") | "\(.nodeIdentifierURL)\t\(.name)"' \
        test_details.json > failed_test_ids.txt 2>/dev/null || true
fi

# 提取診斷資料
echo "Extracting diagnostics..."
xcrun xcresulttool export diagnostics --path "$XCRESULT_PATH" --output-path "./diagnostics" 2>/dev/null || true

# 提取附件（截圖）
echo "Extracting attachments..."
xcrun xcresulttool export attachments --path "$XCRESULT_PATH" --output-path "./attachments" 2>/dev/null || true

# 刪除影片檔節省空間
echo "Removing video files..."
find ./attachments -name "*.mp4" -delete 2>/dev/null || true

# 統計檔案數量
DIAG_COUNT=$(find ./diagnostics -type f 2>/dev/null | wc -l | tr -d ' ')
ATTACH_COUNT=$(find ./attachments -type f ! -name "manifest.json" 2>/dev/null | wc -l | tr -d ' ')

# 建立 metadata
echo "Creating metadata..."
cat > metadata.json << METADATA_EOF
{
  "extractionDate": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "testDate": "$TEST_DATE",
  "xcresultPath": "$XCRESULT_PATH",
  "totalTests": $TOTAL_TESTS,
  "passedTests": $PASSED_TESTS,
  "failedTests": $FAILED_TESTS,
  "diagnosticFiles": $DIAG_COUNT,
  "attachments": $ATTACH_COUNT
}
METADATA_EOF

# 建立 latest 連結
ln -sfn "$OUTPUT_DIR" "${OUTPUT_BASE}/latest"

# 完成
DATA_SIZE=$(du -sh "$OUTPUT_DIR" | cut -f1)

echo ""
echo "========================================"
echo "DONE!"
echo "========================================"
echo "Output: $OUTPUT_DIR"
echo "Size: $DATA_SIZE"
echo "Diagnostics: $DIAG_COUNT files"
echo "Attachments: $ATTACH_COUNT files"
echo ""

if [ "$FAILED_TESTS" -gt 0 ]; then
    echo "WARNING: $FAILED_TESTS test(s) failed"
else
    echo "SUCCESS: All tests passed"
fi

echo "========================================"

# ========================================
# 清理超過 RETENTION_DAYS 天的舊資料
# ========================================
echo ""
echo "========================================"
echo "Cleaning old data (older than ${RETENTION_DAYS} days)"
echo "========================================"

CUTOFF_DATE=$(date -v-${RETENTION_DAYS}d +%Y-%m-%d)
echo "Cutoff date: $CUTOFF_DATE"
echo ""

# 清理 UITestAnalysisData
DELETED_ANALYSIS=0
for dir in "$OUTPUT_BASE"/202*-*-*; do
    [ -d "$dir" ] || continue
    [ -L "$dir" ] && continue  # 跳過 symlink

    dir_date=$(basename "$dir")
    if [[ "$dir_date" < "$CUTOFF_DATE" ]]; then
        echo "DELETE analysis: $dir_date"
        rm -rf "$dir"
        ((DELETED_ANALYSIS++)) || true
    fi
done

# 清理 xcresult
DELETED_XCRESULT=0
for xcresult in "$XCRESULT_DIR"/202*-*-*.xcresult; do
    [ -d "$xcresult" ] || continue

    file_date=$(basename "$xcresult" .xcresult)
    if [[ "$file_date" < "$CUTOFF_DATE" ]]; then
        echo "DELETE xcresult: $file_date"
        rm -rf "$xcresult"
        ((DELETED_XCRESULT++)) || true
    fi
done

echo ""
echo "Cleanup done: $DELETED_ANALYSIS analysis folders, $DELETED_XCRESULT xcresults deleted"
echo "========================================"

exit 0
