#!/bin/bash
#
# Download UITest data from CI machine
#
# Usage:
#   ./download_uitest_data.sh              # Download JSON data only (Phase 1)
#   ./download_uitest_data.sh --screenshots # Download screenshots (Phase 2)
#   ./download_uitest_data.sh --all         # Download everything
#
# Output location: $HOME/Downloads/UITestAnalysis/latest/
#

set -e

# Configuration
CI_HOST="vivotekinc@172.18.2.83"
CI_DATA_PATH="/Users/vivotekinc/Documents/CICD/UITestAnalysisData/latest"
LOCAL_PATH="$HOME/Downloads/UITestAnalysis/latest"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Create local directory
mkdir -p "$LOCAL_PATH"

download_json() {
    echo -e "${BLUE}📥 Downloading JSON test data...${NC}"
    scp -q "$CI_HOST:$CI_DATA_PATH/*.json" "$LOCAL_PATH/" 2>&1 || {
        echo "嘗試逐個下載檔案..."
        for file in metadata.json test_details.json test_failures.json test_summary.json; do
            scp -q "$CI_HOST:$CI_DATA_PATH/${file}" "$LOCAL_PATH/" 2>/dev/null || true
        done

        if [ ! -f "$LOCAL_PATH/metadata.json" ]; then
            echo -e "${RED}❌ 無法下載檔案${NC}"
            exit 1
        fi
    }
    scp -q "$CI_HOST:$CI_DATA_PATH/*.txt" "$LOCAL_PATH/" 2>/dev/null || true
    echo -e "${GREEN}✅ JSON data downloaded${NC}"
}

download_screenshots() {
    echo -e "${BLUE}📥 Downloading screenshots and attachments...${NC}"
    echo "⚠️  This may take a while (~100MB-500MB)..."
    scp -r "$CI_HOST:$CI_DATA_PATH/attachments" "$LOCAL_PATH/"
    echo -e "${GREEN}✅ Screenshots downloaded to: $LOCAL_PATH/attachments/${NC}"
}

case "$1" in
    --screenshots)
        download_screenshots
        ;;
    --all)
        download_json
        download_screenshots
        ;;
    *)
        download_json
        ;;
esac

echo ""
echo -e "📁 Files location: $LOCAL_PATH"
echo ""

# Show summary from metadata
if [ -f "$LOCAL_PATH/metadata.json" ]; then
    FAILED=$(jq -r '.failedTests' "$LOCAL_PATH/metadata.json")
    TOTAL=$(jq -r '.totalTests' "$LOCAL_PATH/metadata.json")
    TEST_DATE=$(jq -r '.testDate' "$LOCAL_PATH/metadata.json")

    echo "測試日期: $TEST_DATE"
    echo "總測試數: $TOTAL"
    echo "失敗數: $FAILED"
    echo ""

    if [ "$FAILED" = "0" ]; then
        echo -e "${GREEN}沒有失敗的測試！${NC}"
    else
        echo -e "發現 ${FAILED} 個失敗測試"
    fi
fi
