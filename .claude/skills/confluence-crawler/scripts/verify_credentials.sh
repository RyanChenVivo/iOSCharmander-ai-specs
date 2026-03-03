#!/bin/bash
# Verify credentials after user confirms they've updated .env
#
# Usage: ./verify_credentials.sh
#
# Output:
#   CREDENTIALS_VERIFIED=true USER=username  - credentials are set
#   CREDENTIALS_VERIFIED=false               - credentials still not set

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SKILL_DIR/.env" 2>/dev/null
if [[ -n "$CONFLUENCE_USER" && -n "$CONFLUENCE_PASS" ]]; then
    echo "CREDENTIALS_VERIFIED=true USER=$CONFLUENCE_USER"
else
    echo "CREDENTIALS_VERIFIED=false"
fi
