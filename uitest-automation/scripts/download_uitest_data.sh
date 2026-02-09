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

CI_HOST="vivotekinc@172.18.2.83"
CI_DATA_PATH="/Users/vivotekinc/Documents/CICD/UITestAnalysisData/latest"
LOCAL_PATH="$HOME/Downloads/UITestAnalysis/latest"

# Create local directory
mkdir -p "$LOCAL_PATH"

download_json() {
    echo "📥 Downloading JSON test data..."
    scp "$CI_HOST:$CI_DATA_PATH/*.json" "$LOCAL_PATH/" 2>/dev/null
    scp "$CI_HOST:$CI_DATA_PATH/*.txt" "$LOCAL_PATH/" 2>/dev/null
    echo "✅ JSON data downloaded to: $LOCAL_PATH"
}

download_screenshots() {
    echo "📥 Downloading screenshots and attachments..."
    echo "⚠️  This may take a while (~100MB-500MB)..."
    scp -r "$CI_HOST:$CI_DATA_PATH/attachments" "$LOCAL_PATH/"
    echo "✅ Screenshots downloaded to: $LOCAL_PATH/attachments/"
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
echo "📁 Files location: $LOCAL_PATH"
