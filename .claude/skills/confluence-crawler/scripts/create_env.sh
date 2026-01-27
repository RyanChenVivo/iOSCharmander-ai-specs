#!/bin/bash
# Create .env file with example credentials and add to .gitignore
#
# Usage: ./create_env.sh

cat > .env << 'EOF'
# Confluence Credentials
# Please fill in your credentials below
CONFLUENCE_USER=your_username_here
CONFLUENCE_PASS=your_password_here
EOF

# Add .env to .gitignore if not already present
if [[ -f ".gitignore" ]]; then
    grep -qxF '.env' .gitignore || echo '.env' >> .gitignore
else
    echo '.env' > .gitignore
fi

echo "Created .env file and added to .gitignore"
