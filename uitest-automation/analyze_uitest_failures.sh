#!/bin/bash

# UITest Failure Analysis Script
# This script extracts test failures, screenshots, and diagnostics from .xcresult bundles
# to help AI assistants analyze and fix UITest issues.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AI_SPECS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load configuration (check both locations for backward compatibility)
if [ -f "$AI_SPECS_ROOT/config.sh" ]; then
    CONFIG_FILE="$AI_SPECS_ROOT/config.sh"
    source "$CONFIG_FILE"
elif [ -f "$SCRIPT_DIR/config.sh" ]; then
    CONFIG_FILE="$SCRIPT_DIR/config.sh"
    source "$CONFIG_FILE"
else
    echo -e "${YELLOW}Warning: config.sh not found, using defaults${NC}"
    echo -e "${YELLOW}Please copy uitest-automation/config.example.sh to config.sh${NC}"
    echo -e "${YELLOW}You can place it in either:${NC}"
    echo -e "${YELLOW}  - $AI_SPECS_ROOT/config.sh (root of AI specs repo)${NC}"
    echo -e "${YELLOW}  - $SCRIPT_DIR/config.sh (uitest-automation folder)${NC}"
    echo ""
fi

# Default configuration (can be overridden in config.sh)
: ${CI_MACHINE:="vivotekinc@10.15.254.191"}
: ${CI_REPORT_BASE:="/Users/vivotekinc/Documents/CICD/UITestReport"}
: ${IOSCHARMANDER_PATH:="$(cd "$AI_SPECS_ROOT/../iOSCharmander" 2>/dev/null && pwd)"}
: ${OUTPUT_DIR:="$HOME/Downloads/UITestAnalysis"}

# Script parameters
XCRESULT_PATH=""
ONLY_FAILURES=false
DATE_PARAM=""

# Help function
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Analyze UITest failures from .xcresult bundle and prepare data for AI analysis.

OPTIONS:
    -x, --xcresult PATH     Path to .xcresult bundle
    -d, --date DATE         Fetch report from CI machine by date (YYYY-MM-DD, default: today)
    -o, --output DIR        Output directory (default: ~/Downloads/UITestAnalysis)
    -f, --only-failures     Export only failure-related attachments
    -h, --help              Show this help message

EXAMPLES:
    # Analyze today's CI report
    $(basename "$0") -d today

    # Analyze specific date's CI report
    $(basename "$0") -d 2025-12-03

    # Analyze local xcresult
    $(basename "$0") -x path/to/Test.xcresult

    # Extract only failures
    $(basename "$0") -d today -f

CONFIGURATION:
    Create config.sh in the AI specs root directory with:

    CI_MACHINE="user@hostname"
    CI_REPORT_BASE="/path/to/CI/reports"
    IOSCHARMANDER_PATH="/path/to/iOSCharmander"
    OUTPUT_DIR="\$HOME/Downloads/UITestAnalysis"

CURRENT SETTINGS:
    CI Machine:         $CI_MACHINE
    CI Report Base:     $CI_REPORT_BASE
    iOSCharmander Path: $IOSCHARMANDER_PATH
    Output Directory:   $OUTPUT_DIR

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -x|--xcresult)
            XCRESULT_PATH="$2"
            shift 2
            ;;
        -d|--date)
            DATE_PARAM="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -f|--only-failures)
            ONLY_FAILURES=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Handle date parameter for CI machine
ANALYSIS_DATE=""
if [ ! -z "$DATE_PARAM" ]; then
    if [ "$DATE_PARAM" = "today" ]; then
        DATE_PARAM=$(date +%Y-%m-%d)
    fi
    ANALYSIS_DATE="$DATE_PARAM"

    echo -e "${BLUE}Fetching report from CI machine for date: $DATE_PARAM${NC}"

    CI_XCRESULT="$CI_REPORT_BASE/$DATE_PARAM.xcresult"
    LOCAL_TEMP="$HOME/Downloads/CI_Reports"
    mkdir -p "$LOCAL_TEMP"

    echo -e "${YELLOW}Downloading from CI machine...${NC}"
    echo -e "Source: ${BLUE}$CI_MACHINE:$CI_XCRESULT${NC}"

    # Use scp to copy the xcresult bundle
    # Remove existing directory to avoid nested structure
    rm -rf "$LOCAL_TEMP/$DATE_PARAM.xcresult"
    if scp -r "$CI_MACHINE:$CI_XCRESULT" "$LOCAL_TEMP/" 2>/dev/null; then
        echo -e "${GREEN}✓ Downloaded successfully${NC}"
        XCRESULT_PATH="$LOCAL_TEMP/$DATE_PARAM.xcresult"

        # Fix nested structure if it exists (scp creates target dir inside destination)
        if [ -d "$XCRESULT_PATH/$DATE_PARAM.xcresult" ]; then
            echo -e "${YELLOW}Fixing nested xcresult structure...${NC}"
            mv "$XCRESULT_PATH/$DATE_PARAM.xcresult" "$LOCAL_TEMP/temp_xcresult"
            rm -rf "$XCRESULT_PATH"
            mv "$LOCAL_TEMP/temp_xcresult" "$XCRESULT_PATH"
        fi
    else
        echo -e "${RED}Error: Failed to download from CI machine${NC}"
        echo -e "${YELLOW}Trying alternative: direct path access...${NC}"

        # Alternative: if CI machine is network mounted
        MOUNTED_PATH="/Volumes/vivotekinc/Documents/CICD/UITestReport/$DATE_PARAM.xcresult"
        if [ -d "$MOUNTED_PATH" ]; then
            XCRESULT_PATH="$MOUNTED_PATH"
            echo -e "${GREEN}✓ Found via network mount${NC}"
        else
            echo -e "${RED}Error: Cannot access CI report for $DATE_PARAM${NC}"
            echo -e "${YELLOW}Please ensure:${NC}"
            echo -e "  1. SSH access to CI machine is configured"
            echo -e "  2. Or CI machine share is mounted"
            echo -e "  3. Report exists at: $CI_XCRESULT"
            exit 1
        fi
    fi
fi

# Validate required arguments
if [ -z "$XCRESULT_PATH" ]; then
    echo -e "${RED}Error: .xcresult path is required (use -x or -d)${NC}"
    show_help
    exit 1
fi

# Expand path if it contains wildcards
if [[ "$XCRESULT_PATH" == *"*"* ]]; then
    EXPANDED_PATH=$(ls -dt $XCRESULT_PATH 2>/dev/null | head -1)
    if [ -z "$EXPANDED_PATH" ]; then
        echo -e "${RED}Error: No .xcresult found matching: $XCRESULT_PATH${NC}"
        exit 1
    fi
    XCRESULT_PATH="$EXPANDED_PATH"
fi

# Validate xcresult path
if [ ! -d "$XCRESULT_PATH" ]; then
    echo -e "${RED}Error: .xcresult bundle not found: $XCRESULT_PATH${NC}"
    exit 1
fi

# Extract date from xcresult filename if not already set
if [ -z "$ANALYSIS_DATE" ]; then
    ANALYSIS_DATE=$(basename "$XCRESULT_PATH" .xcresult | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' || date +%Y-%m-%d)
fi

# Update output directory to include date
OUTPUT_DIR="${OUTPUT_DIR}/${ANALYSIS_DATE}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}UITest Failure Analysis${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Date:     ${GREEN}$ANALYSIS_DATE${NC}"
echo -e "XCResult: ${GREEN}$XCRESULT_PATH${NC}"
echo -e "Output:   ${GREEN}$OUTPUT_DIR${NC}"
echo ""

# Create output directory
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

# Step 1: Extract test summary
echo -e "${YELLOW}[1/5] Extracting test summary...${NC}"
xcrun xcresulttool get test-results summary \
    --path "$XCRESULT_PATH" \
    > "$OUTPUT_DIR/test_summary.json"
echo -e "${GREEN}✓ Saved to: $OUTPUT_DIR/test_summary.json${NC}"

# Parse summary to check for failures
FAILED_TESTS=$(jq -r '.failedTests' "$OUTPUT_DIR/test_summary.json")
PASSED_TESTS=$(jq -r '.passedTests' "$OUTPUT_DIR/test_summary.json")
TOTAL_TESTS=$(jq -r '.totalTestCount' "$OUTPUT_DIR/test_summary.json")
TEST_RESULT=$(jq -r '.result' "$OUTPUT_DIR/test_summary.json")

echo ""
echo -e "${BLUE}Test Summary:${NC}"
echo -e "  Total:  $TOTAL_TESTS"
echo -e "  Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "  Failed: ${RED}$FAILED_TESTS${NC}"
echo -e "  Result: $TEST_RESULT"
echo ""

# Step 2: Extract detailed test list
echo -e "${YELLOW}[2/5] Extracting detailed test list...${NC}"
xcrun xcresulttool get test-results tests \
    --path "$XCRESULT_PATH" \
    > "$OUTPUT_DIR/test_details.json"
echo -e "${GREEN}✓ Saved to: $OUTPUT_DIR/test_details.json${NC}"

# Step 3: Extract test failures (if any)
echo -e "${YELLOW}[3/5] Extracting test failures...${NC}"
if [ "$FAILED_TESTS" -gt 0 ]; then
    # Extract failure information
    jq '.testFailures' "$OUTPUT_DIR/test_summary.json" > "$OUTPUT_DIR/test_failures.json"

    # Extract failed test identifiers and details
    jq -r '.testNodes[] | .. | select(.result? == "Failed") | "\(.nodeIdentifierURL)\t\(.name)"' "$OUTPUT_DIR/test_details.json" \
        > "$OUTPUT_DIR/failed_test_ids.txt" 2>/dev/null || true

    echo -e "${GREEN}✓ Saved to: $OUTPUT_DIR/test_failures.json${NC}"
    echo -e "${GREEN}✓ Failed test IDs: $OUTPUT_DIR/failed_test_ids.txt${NC}"
else
    echo -e "${GREEN}✓ No test failures found${NC}"
fi

# Step 4: Export attachments (screenshots, etc.)
echo -e "${YELLOW}[4/5] Exporting test attachments...${NC}"
EXPORT_CMD="xcrun xcresulttool export attachments --path \"$XCRESULT_PATH\" --output-path \"$OUTPUT_DIR/attachments\""

if [ "$ONLY_FAILURES" = true ] && [ "$FAILED_TESTS" -gt 0 ]; then
    EXPORT_CMD="$EXPORT_CMD --only-failures"
    echo -e "  ${BLUE}Exporting only failure attachments...${NC}"
fi

if [ "$FAILED_TESTS" -eq 0 ] && [ "$ONLY_FAILURES" = true ]; then
    echo -e "${GREEN}✓ No failures to export${NC}"
else
    eval $EXPORT_CMD 2>/dev/null || echo -e "${YELLOW}Note: Some attachments may not be available${NC}"

    # Count exported files
    ATTACHMENT_COUNT=$(find "$OUTPUT_DIR/attachments" -type f ! -name "manifest.json" 2>/dev/null | wc -l | xargs)
    echo -e "${GREEN}✓ Exported $ATTACHMENT_COUNT attachment(s) to: $OUTPUT_DIR/attachments/${NC}"
fi

# Step 5: Export diagnostics
echo -e "${YELLOW}[5/5] Exporting diagnostics...${NC}"
xcrun xcresulttool export diagnostics \
    --path "$XCRESULT_PATH" \
    --output-path "$OUTPUT_DIR/diagnostics" 2>/dev/null || true
echo -e "${GREEN}✓ Diagnostics exported to: $OUTPUT_DIR/diagnostics/${NC}"

# Generate analysis report
echo ""
echo -e "${YELLOW}Generating analysis report...${NC}"

cat > "$OUTPUT_DIR/ANALYSIS_REPORT.md" << EOF
# UITest Analysis Report - $ANALYSIS_DATE

Generated: $(date)

## Test Summary

- **Test Date**: $ANALYSIS_DATE
- **XCResult Path**: \`$XCRESULT_PATH\`
- **Total Tests**: $TOTAL_TESTS
- **Passed**: $PASSED_TESTS
- **Failed**: $FAILED_TESTS
- **Overall Result**: $TEST_RESULT

## Test Environment

\`\`\`json
$(jq '.devicesAndConfigurations[0].device' "$OUTPUT_DIR/test_summary.json")
\`\`\`

## Files Generated

1. \`test_summary.json\` - High-level test results summary
2. \`test_details.json\` - Detailed information about all tests
3. \`test_failures.json\` - Detailed failure information (if failures exist)
4. \`failed_test_ids.txt\` - List of failed test identifiers (if failures exist)
5. \`attachments/\` - Screenshots and other test attachments
6. \`diagnostics/\` - Diagnostic logs and crash reports

## Failed Tests

EOF

if [ "$FAILED_TESTS" -gt 0 ]; then
    echo "The following tests failed:" >> "$OUTPUT_DIR/ANALYSIS_REPORT.md"
    echo "" >> "$OUTPUT_DIR/ANALYSIS_REPORT.md"

    # Extract and format failed test names
    jq -r '.testNodes[] | .. | select(.result? == "Failed") | "- \(.name) (\(.nodeType))"' "$OUTPUT_DIR/test_details.json" \
        >> "$OUTPUT_DIR/ANALYSIS_REPORT.md" 2>/dev/null || true

    echo "" >> "$OUTPUT_DIR/ANALYSIS_REPORT.md"
    echo "### Failure Details" >> "$OUTPUT_DIR/ANALYSIS_REPORT.md"
    echo "" >> "$OUTPUT_DIR/ANALYSIS_REPORT.md"
    echo "\`\`\`json" >> "$OUTPUT_DIR/ANALYSIS_REPORT.md"
    jq '.testFailures' "$OUTPUT_DIR/test_summary.json" >> "$OUTPUT_DIR/ANALYSIS_REPORT.md"
    echo "\`\`\`" >> "$OUTPUT_DIR/ANALYSIS_REPORT.md"
else
    echo "All tests passed successfully! ✅" >> "$OUTPUT_DIR/ANALYSIS_REPORT.md"
fi

cat >> "$OUTPUT_DIR/ANALYSIS_REPORT.md" << EOF

## How to Use This Report with Claude Code

\`\`\`bash
# In Claude Code, add this directory to context:
# Then type in the chat: /add-dir $OUTPUT_DIR

# Then ask Claude:
# "我們來看看今天UITest的狀況並且建立openspec格式的修正任務"
\`\`\`

## Next Steps

1. Review the failed tests listed above
2. Check the screenshots in \`attachments/\` to see what the UI looked like when tests failed
3. Read \`test_failures.json\` for detailed error messages
4. Use Claude Code to analyze and create OpenSpec tasks for fixes

---

**Ready for Claude Code Analysis**: Yes ✅

EOF

echo -e "${GREEN}✓ Report saved to: $OUTPUT_DIR/ANALYSIS_REPORT.md${NC}"

# Final summary
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Analysis Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "Output directory: ${GREEN}$OUTPUT_DIR${NC}"
echo ""

if [ "$FAILED_TESTS" -gt 0 ]; then
    echo -e "${RED}Found $FAILED_TESTS failed test(s)${NC}"
    echo ""
    echo -e "Next steps:"
    echo -e "  1. Review ${YELLOW}$OUTPUT_DIR/ANALYSIS_REPORT.md${NC}"
    echo -e "  2. Check screenshots in ${YELLOW}$OUTPUT_DIR/attachments/${NC}"
    echo -e "  3. In Claude Code, add the directory:"
    echo -e "     ${BLUE}/add-dir $OUTPUT_DIR${NC}"
    echo -e "  4. Then ask:"
    echo -e "     ${BLUE}\"我們來看看今天UITest的狀況並且建立openspec格式的修正任務\"${NC}"
else
    echo -e "${GREEN}All tests passed! No action needed. ✅${NC}"
fi
echo ""

# Save the output path for easy access
echo "$OUTPUT_DIR" > "$HOME/.last_uitest_analysis"
