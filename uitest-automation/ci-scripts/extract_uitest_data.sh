#!/bin/bash

# UITest Data Extraction Script
# This script extracts essential data from xcresult for AI analysis

set -e

# 設定路徑
TEST_DATE=$(date +%Y-%m-%d)
XCRESULT_PATH="/Users/vivotekinc/Documents/CICD/UITestReport/${TEST_DATE}.xcresult"
OUTPUT_BASE="/Users/vivotekinc/Documents/CICD/UITestAnalysisData"
OUTPUT_DIR="${OUTPUT_BASE}/${TEST_DATE}"

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

exit 0
