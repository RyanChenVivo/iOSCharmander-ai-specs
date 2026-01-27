#!/bin/bash
# Download images from Confluence page attachments
#
# Usage: ./download_images.sh <page_id> <raw_json_file> [output_dir]
#   e.g., ./download_images.sh 487526229 confluence-pages/raw/page_487526229_raw.json confluence-pages
#
# Environment variables (loaded from .env):
#   CONFLUENCE_USER - Confluence username
#   CONFLUENCE_PASS - Confluence password
#   CONFLUENCE_BASE_URL - Base URL (default: https://confluence.vivotek.com)
#
# Only downloads image files: .png, .jpg, .jpeg, .gif, .svg, .webp

set -e

PAGE_ID="${1:?Usage: $0 <page_id> <raw_json_file> [output_dir]}"
RAW_JSON="${2:?Usage: $0 <page_id> <raw_json_file> [output_dir]}"
OUTPUT_DIR="${3:-./confluence-pages}"

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

# Create images directory
mkdir -p "$OUTPUT_DIR/images"

# Extract page title and create sanitized prefix
PAGE_TITLE=$(python3 -c "import json; d=json.load(open('$RAW_JSON')); print(d.get('title', 'Unknown'))")
TITLE_PREFIX=$(python3 -c "
import re
title = '''$PAGE_TITLE'''
safe = re.sub(r'[\[\]]', '', title)
safe = re.sub(r'[^\w\u4e00-\u9fff]', '_', safe)
safe = re.sub(r'_+', '_', safe).strip('_')
print(safe)
")

echo "Page title: $PAGE_TITLE" >&2
echo "Title prefix: $TITLE_PREFIX" >&2

# Extract image filenames from raw JSON (ri:attachment tags)
# Image extensions: .png, .jpg, .jpeg, .gif, .svg, .webp
IMAGE_FILES=$(python3 -c "
import json
import re

with open('$RAW_JSON') as f:
    data = json.load(f)

body = data.get('body', {}).get('storage', {}).get('value', '')

# Find all ri:attachment filenames
pattern = r'ri:filename=\"([^\"]+)\"'
matches = re.findall(pattern, body)

# Filter to only image files
image_exts = ('.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp')
for filename in matches:
    if filename.lower().endswith(image_exts):
        print(filename)
")

if [[ -z "$IMAGE_FILES" ]]; then
    echo "No image attachments found in page" >&2
    exit 0
fi

# Download each image
echo "$IMAGE_FILES" | while read -r filename; do
    if [[ -n "$filename" ]]; then
        encoded_filename=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$filename'))")
        local_filename="${TITLE_PREFIX}_$(echo "$filename" | tr ' ' '_')"

        echo "Downloading: $filename -> $local_filename" >&2
        curl -s -f -u "$CONFLUENCE_USER:$CONFLUENCE_PASS" \
            -o "$OUTPUT_DIR/images/$local_filename" \
            "$BASE_URL/download/attachments/$PAGE_ID/$encoded_filename" || {
            echo "Warning: Failed to download $filename" >&2
        }
    fi
done

echo "Images downloaded to: $OUTPUT_DIR/images/" >&2
