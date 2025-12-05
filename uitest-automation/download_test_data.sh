#!/bin/bash

# Simple script to download UITest data from CI machine
# Only downloads JSON files for quick triage analysis
# Screenshots can be downloaded separately if needed

set -e

# Configuration
CI_MACHINE="vivotekinc@10.15.254.191"
CI_DATA_BASE="/Users/vivotekinc/Documents/CICD/UITestAnalysisData"
OUTPUT_DIR="$HOME/Downloads/UITestAnalysis"
LOCAL_OUTPUT="${OUTPUT_DIR}/latest"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== 下載 UITest 測試資料 ===${NC}"
echo "從 CI 機器下載 JSON 檔案..."
echo ""

# Create output directory
mkdir -p "$LOCAL_OUTPUT"

# Download JSON and txt files only (fast - about 100KB)
echo "正在下載..."
scp -q "${CI_MACHINE}:${CI_DATA_BASE}/latest/*.json" "$LOCAL_OUTPUT/" || {
    echo "錯誤：無法下載檔案"
    exit 1
}
scp -q "${CI_MACHINE}:${CI_DATA_BASE}/latest/*.txt" "$LOCAL_OUTPUT/" 2>/dev/null || true

echo -e "${GREEN}✓ 下載完成！${NC}"
echo ""
echo "資料位置: $LOCAL_OUTPUT"
echo ""

# Show summary
if [ -f "$LOCAL_OUTPUT/metadata.json" ]; then
    FAILED=$(jq -r '.failedTests' "$LOCAL_OUTPUT/metadata.json")
    TOTAL=$(jq -r '.totalTests' "$LOCAL_OUTPUT/metadata.json")
    TEST_DATE=$(jq -r '.testDate' "$LOCAL_OUTPUT/metadata.json")

    echo "測試日期: $TEST_DATE"
    echo "總測試數: $TOTAL"
    echo "失敗數: $FAILED"
    echo ""

    if [ "$FAILED" -eq 0 ]; then
        echo -e "${GREEN}沒有失敗的測試！${NC}"
    else
        echo -e "發現 ${FAILED} 個失敗測試"
        echo ""
        echo "下一步："
        echo "  執行 AI triage 分析來判斷是否需要處理"
    fi
fi

echo ""
echo "如需下載截圖（較大）："
echo "  scp -r \"${CI_MACHINE}:${CI_DATA_BASE}/latest/attachments\" \"$LOCAL_OUTPUT/\""
