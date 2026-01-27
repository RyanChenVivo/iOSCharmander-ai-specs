#!/bin/bash
# Lookup Confluence page ID by space key and title
#
# Usage: ./lookup_page_by_title.sh <space_key> <title>
#   e.g., ./lookup_page_by_title.sh PP2 "ACaaS - Brivo Event Type List"
#
# Environment variables (loaded from .env):
#   CONFLUENCE_USER - Confluence username
#   CONFLUENCE_PASS - Confluence password
#   CONFLUENCE_BASE_URL - Base URL (default: https://confluence.vivotek.com)
#
# Output: JSON response from Confluence API

set -e

SPACE_KEY="${1:?Usage: $0 <space_key> <title>}"
TITLE="${2:?Usage: $0 <space_key> <title>}"

# Load credentials from .env
if [[ -f ".env" ]]; then
    source .env
fi

BASE_URL="${CONFLUENCE_BASE_URL:-https://confluence.vivotek.com}"

# Check credentials
if [[ -z "$CONFLUENCE_USER" || -z "$CONFLUENCE_PASS" ]]; then
    echo "Error: CONFLUENCE_USER and CONFLUENCE_PASS must be set in .env" >&2
    exit 1
fi

# URL-encode the title
ENCODED_TITLE=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$TITLE'))")

# Lookup page by title and space
curl -s -f -u "$CONFLUENCE_USER:$CONFLUENCE_PASS" \
    "$BASE_URL/rest/api/content?title=$ENCODED_TITLE&spaceKey=$SPACE_KEY&expand=body.storage,version,space,title" \
    -H "Accept: application/json" || {
    echo "Error: Failed to lookup page. Check credentials and page title." >&2
    exit 1
}
