---
name: confluence-crawler
description: Extract Confluence pages to Markdown with proper formatting, nested lists, and complete URLs.
---

# Confluence crawler

## Trigger

Use this skill when user:
- Provides a Confluence URL (contains `confluence` and `pageId=` or `/display/`)
- **And** asks to "fetch", "extract", or "save" a Confluence page
- **OR** Wants to convert Confluence content to Markdown

## Scripts Location

All scripts are located in: `$SKILL_DIR/scripts/`

**IMPORTANT**: Set `SKILL_DIR` at the beginning of every session:
```bash
SKILL_DIR=".claude/skills/confluence-crawler"
```

## Authentication Flow

**IMPORTANT**: Credentials are stored in a `.env` file inside the skill directory (`$SKILL_DIR/.env`).

### Step 1: Check for credentials

Run: `bash $SKILL_DIR/scripts/check_credentials.sh`

Output values:
- `CREDENTIALS_SET=true USER=username` - credentials are configured, proceed
- `CREDENTIALS_SET=false ENV_EXISTS=true` - .env exists but credentials not set (go to Step 3)
- `CREDENTIALS_SET=false ENV_EXISTS=false` - .env doesn't exist (go to Step 2)

### Step 2: Create .env file (if doesn't exist)

Run: `bash $SKILL_DIR/scripts/create_env.sh`

Then display this message to the user:

```
I've created a .env file at .claude/skills/confluence-crawler/.env and added it to .gitignore. Please edit the file and fill in your Confluence credentials:

CONFLUENCE_USER=your_username_here
CONFLUENCE_PASS=your_password_here

After updating the file, let me know and I'll continue.
```

Wait for user confirmation before proceeding.

### Step 3: If .env exists but credentials not set

Display this message:

```
The .env file exists at .claude/skills/confluence-crawler/.env but credentials are not properly configured. Please edit the file and ensure these values are set:

CONFLUENCE_USER=your_username_here
CONFLUENCE_PASS=your_password_here

After updating the file, let me know and I'll continue.
```

Wait for user confirmation before proceeding.

### Step 4: Verify credentials after user confirms

Run: `bash $SKILL_DIR/scripts/verify_credentials.sh`

Output values:
- `CREDENTIALS_VERIFIED=true USER=username` - proceed with workflow
- `CREDENTIALS_VERIFIED=false` - ask user to check .env again

## Workflow

1. **Extract page info from URL**:
   - For `pageId=487526229` format: extract the page ID number directly
   - For `/display/SPACE/Title` format: extract space key and title, then lookup page ID

2. **Check for credentials** using the Authentication Flow above

3. **For /display/ URLs, lookup page ID first**:

   Run: `bash $SKILL_DIR/scripts/lookup_page_by_title.sh <space_key> "<title>"`

   Example: `bash $SKILL_DIR/scripts/lookup_page_by_title.sh PP2 "ACaaS - Brivo Event Type List"`

   Parse the JSON response to get the page ID from `results[0].id`

4. **Fetch and convert page**:

   Run: `source $SKILL_DIR/.env && bash $SKILL_DIR/scripts/fetch_page.sh <page_id> $SKILL_DIR/confluence-pages`

   This script:
   - Fetches page via REST API
   - Saves raw JSON to `$SKILL_DIR/confluence-pages/raw/page_{pageId}_raw.json`
   - Converts to Markdown using `confluence_to_markdown.py`
   - Saves to `$SKILL_DIR/confluence-pages/{Page_Title}.md`

5. **Download images**:

   Run: `bash $SKILL_DIR/scripts/download_images.sh <page_id> $SKILL_DIR/confluence-pages/raw/page_<page_id>_raw.json $SKILL_DIR/confluence-pages`

   This downloads only image attachments (PNG, JPG, GIF, SVG, WEBP) with title prefix.

6. **Update attachment references**:

   First, get the title prefix:
   ```bash
   TITLE_PREFIX=$(python3 -c "
   import json, re
   d = json.load(open('$SKILL_DIR/confluence-pages/raw/page_<page_id>_raw.json'))
   title = d.get('title', 'Unknown')
   safe = re.sub(r'[\[\]]', '', title)
   safe = re.sub(r'[^\w\u4e00-\u9fff]', '_', safe)
   safe = re.sub(r'_+', '_', safe).strip('_')
   print(safe)
   ")
   ```

   Then run: `python3 $SKILL_DIR/scripts/update_attachment_refs.py <markdown_file> <page_id> "$TITLE_PREFIX"`

   This script:
   - **Outside tables**: Images use markdown syntax `![name](images/prefix_name.png)`
   - **Inside tables**: Images use HTML syntax `<img src="images/prefix_name.png" alt="name">`
   - Non-image attachments link to Confluence URLs

## Features

- Properly handles nested lists (3+ levels with correct indentation)
- Converts internal Confluence links to complete URLs
- Handles Confluence macros (drawio, attachments, code blocks, expand, etc.)
- **Extracts code blocks** with language syntax highlighting (supports multiple code blocks per page)
- **Expand macros with `<pre>` content** render as collapsible `<details>` with proper code formatting in tables
- Preserves headings, bold, italic, inline code formatting
- URL-encodes special characters in links
- **Downloads images only** from page attachments with page title prefix (e.g., `PageTitle_image.png`)
- **Images in tables** use HTML `<img>` tags for proper rendering (markdown syntax doesn't work inside HTML tables)
- **Links non-image attachments** (PDF, WAV, ZIP, etc.) directly to Confluence URLs to save disk space
- **Secure credential handling** - credentials stored in .env file (automatically added to .gitignore)

## Output Location

```
.claude/skills/confluence-crawler/
├── confluence-pages/
│   ├── Page_Title.md                       # Non-image attachments link to Confluence URLs
│   ├── Another_Page.md
│   ├── images/
│   │   ├── Page_Title_image1.png           # Only images are downloaded locally
│   │   ├── Page_Title_screenshot_2025.png
│   │   ├── Another_Page_diagram.png
│   │   └── Another_Page_figure1.png
│   └── raw/
│       ├── page_12345_raw.json
│       └── page_67890_raw.json
├── scripts/
│   └── ...
├── .env                                    # Credentials file (gitignored)
└── SKILL.md
```

**Note:** Non-image attachments (PDF, WAV, ZIP, DOC, etc.) are NOT downloaded locally. They are linked directly to Confluence URLs to save disk space.

## Scripts Reference

| Script | Purpose |
|--------|---------|
| `check_credentials.sh` | Check if .env and credentials exist |
| `create_env.sh` | Create .env template and update .gitignore |
| `verify_credentials.sh` | Verify credentials after user updates .env |
| `lookup_page_by_title.sh` | Lookup page ID by space key and title |
| `fetch_page.sh` | Fetch page, save raw JSON, convert to Markdown |
| `download_images.sh` | Download image attachments only |
| `confluence_to_markdown.py` | HTML-to-Markdown converter |
| `update_attachment_refs.py` | Update attachment references in Markdown |
