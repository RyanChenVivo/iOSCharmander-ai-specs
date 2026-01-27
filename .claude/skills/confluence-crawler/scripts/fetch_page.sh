#!/bin/bash
# Fetch a Confluence page via REST API
#
# Usage:
#   ./fetch_page.sh <page_id> [output_dir]
#   ./fetch_page.sh 487526229 ./confluence-pages
#
# Environment variables:
#   CONFLUENCE_USER - Confluence username
#   CONFLUENCE_PASS - Confluence password
#   CONFLUENCE_BASE_URL - Base URL (default: https://confluence.vivotek.com)

set -e

PAGE_ID="${1:?Usage: $0 <page_id> [output_dir]}"
OUTPUT_DIR="${2:-./confluence-pages}"
BASE_URL="${CONFLUENCE_BASE_URL:-https://confluence.vivotek.com}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check credentials
if [[ -z "$CONFLUENCE_USER" || -z "$CONFLUENCE_PASS" ]]; then
    echo "Error: CONFLUENCE_USER and CONFLUENCE_PASS environment variables must be set" >&2
    echo "" >&2
    echo "Set them with:" >&2
    echo "  export CONFLUENCE_USER='your_username'" >&2
    echo "  export CONFLUENCE_PASS='your_password'" >&2
    exit 1
fi

# Create output directories
mkdir -p "$OUTPUT_DIR/raw"

echo "Fetching page $PAGE_ID from $BASE_URL..." >&2

# Fetch page content
RESPONSE=$(curl -s -f -u "$CONFLUENCE_USER:$CONFLUENCE_PASS" \
    "$BASE_URL/rest/api/content/$PAGE_ID?expand=body.storage,version,space,title" \
    -H "Accept: application/json") || {
    echo "Error: Failed to fetch page. Check your credentials and page ID." >&2
    exit 1
}

# Save raw JSON to raw subfolder
RAW_FILE="$OUTPUT_DIR/raw/page_${PAGE_ID}_raw.json"
echo "$RESPONSE" > "$RAW_FILE"
echo "Saved raw JSON: $RAW_FILE" >&2

# Convert to Markdown
python3 "$SCRIPT_DIR/confluence_to_markdown.py" \
    --input "$RAW_FILE" \
    --output "$OUTPUT_DIR/$(echo "$RESPONSE" | python3 -c "
import sys, json, re
data = json.load(sys.stdin)
title = data.get('title', 'Untitled')
safe = re.sub(r'[^\w\s-]', '', title).strip().replace(' ', '_')
print(f'{safe}.md')
")" \
    --base-url "$BASE_URL"

echo "Done!" >&2
