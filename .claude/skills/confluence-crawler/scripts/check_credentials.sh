#!/bin/bash
# Check for .env file and Confluence credentials
#
# Usage: ./check_credentials.sh
#
# Output:
#   CREDENTIALS_SET=true USER=username   - credentials are configured
#   CREDENTIALS_SET=false ENV_EXISTS=true  - .env exists but credentials not set
#   CREDENTIALS_SET=false ENV_EXISTS=false - .env doesn't exist

if [[ -f ".env" ]]; then
    source .env
    if [[ -n "$CONFLUENCE_USER" && -n "$CONFLUENCE_PASS" ]]; then
        echo "CREDENTIALS_SET=true USER=$CONFLUENCE_USER"
    else
        echo "CREDENTIALS_SET=false ENV_EXISTS=true"
    fi
else
    echo "CREDENTIALS_SET=false ENV_EXISTS=false"
fi
