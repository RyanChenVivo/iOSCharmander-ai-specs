#!/bin/bash
# Create .env file with example credentials and add to .gitignore
#
# Usage: ./create_env.sh

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$SKILL_DIR/.env"
PROJECT_ROOT="$(cd "$SKILL_DIR/../../.." && pwd)"
GITIGNORE="$PROJECT_ROOT/.gitignore"

cat > "$ENV_FILE" << 'EOF'
# Confluence Credentials
# Please fill in your credentials below
CONFLUENCE_USER=your_username_here
CONFLUENCE_PASS=your_password_here
EOF

# Add .claude/skills/confluence-crawler/.env to .gitignore if not already present
REL_ENV=".claude/skills/confluence-crawler/.env"
if [[ -f "$GITIGNORE" ]]; then
    grep -qxF "$REL_ENV" "$GITIGNORE" || echo "$REL_ENV" >> "$GITIGNORE"
else
    echo "$REL_ENV" > "$GITIGNORE"
fi

echo "Created .env file at $ENV_FILE and added to .gitignore"
