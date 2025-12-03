#!/bin/bash
# Configuration file for UITest Analysis Tools
# Copy this file to config.sh and update with your settings

# CI Machine connection
# Update with your CI machine's user@hostname or IP
CI_MACHINE="vivotekinc@10.15.254.191"

# CI Report base directory on the CI machine
# This is where Jenkins stores the .xcresult files
CI_REPORT_BASE="/Users/vivotekinc/Documents/CICD/UITestReport"

# Path to iOSCharmander project
# Can be relative to this directory or absolute
# Default: assumes iOSCharmander is a sibling directory
IOSCHARMANDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../iOSCharmander" 2>/dev/null && pwd)"

# Output directory for analysis results
# Default: ~/Downloads/UITestAnalysis
OUTPUT_DIR="$HOME/Downloads/UITestAnalysis"
