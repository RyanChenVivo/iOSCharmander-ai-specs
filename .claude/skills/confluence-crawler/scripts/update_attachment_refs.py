#!/usr/bin/env python3
"""
Update attachment references in Markdown files.

- Images outside tables: Replace [Attachment: filename.png] with ![Alt](images/prefix_filename.png)
- Images inside tables: Replace [Attachment: filename.png] with <img src="images/prefix_filename.png" alt="filename.png">
- Non-images: Replace [Attachment: filename.pdf] with appropriate link format

Usage:
    python3 update_attachment_refs.py <markdown_file> <page_id> <title_prefix> [--base-url URL]
"""

import argparse
import re
import urllib.parse
import sys


def main():
    parser = argparse.ArgumentParser(
        description="Update attachment references in Markdown"
    )
    parser.add_argument("markdown_file", help="Path to the Markdown file to update")
    parser.add_argument("page_id", help="Confluence page ID")
    parser.add_argument("title_prefix", help="Sanitized title prefix for local images")
    parser.add_argument(
        "--base-url",
        default="https://confluence.vivotek.com",
        help="Confluence base URL"
    )

    args = parser.parse_args()

    # Read markdown file
    with open(args.markdown_file, "r", encoding="utf-8") as f:
        content = f.read()

    base_url = f"{args.base_url}/download/attachments/{args.page_id}"

    # Image extensions (download locally)
    image_exts = ('.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp')

    # Non-image extensions (link to Confluence)
    non_image_exts = (
        '.wav', '.pdf', '.zip', '.doc', '.docx', '.xls', '.xlsx',
        '.ppt', '.pptx', '.txt', '.mp3', '.mp4', '.avi', '.mov'
    )

    def replace_attachment_html(match):
        """Replace attachment refs inside HTML tables with HTML tags."""
        filename = match.group(1)
        lower_filename = filename.lower()

        if lower_filename.endswith(image_exts):
            # Image: use HTML img tag with local path
            local_filename = f"{args.title_prefix}_{filename.replace(' ', '_')}"
            return f'<img src="images/{local_filename}" alt="{filename}">'
        elif lower_filename.endswith(non_image_exts):
            # Non-image: link to Confluence URL with HTML a tag
            encoded = urllib.parse.quote(filename)
            return f'<a href="{base_url}/{encoded}">{filename}</a>'
        else:
            # Unknown: link to Confluence URL
            encoded = urllib.parse.quote(filename)
            return f'<a href="{base_url}/{encoded}">{filename}</a>'

    def replace_attachment_markdown(match):
        """Replace attachment refs outside tables with Markdown syntax."""
        filename = match.group(1)
        lower_filename = filename.lower()

        if lower_filename.endswith(image_exts):
            # Image: use local path
            local_filename = f"{args.title_prefix}_{filename.replace(' ', '_')}"
            return f"![{filename}](images/{local_filename})"
        elif lower_filename.endswith(non_image_exts):
            # Non-image: link to Confluence URL
            encoded = urllib.parse.quote(filename)
            return f"[{filename}]({base_url}/{encoded})"
        else:
            # Unknown: link to Confluence URL
            encoded = urllib.parse.quote(filename)
            return f"[{filename}]({base_url}/{encoded})"

    def process_content(content):
        """Process content, handling tables differently from regular content."""
        result = []
        attachment_pattern = r'\[Attachment: ([^\]]+)\]'

        # Split content by table boundaries
        # Find all <table>...</table> sections
        table_pattern = r'(<table>.*?</table>)'
        parts = re.split(table_pattern, content, flags=re.DOTALL)

        for part in parts:
            if part.startswith('<table>') and part.endswith('</table>'):
                # Inside table: use HTML tags
                updated_part = re.sub(attachment_pattern, replace_attachment_html, part)
            else:
                # Outside table: use Markdown syntax
                updated_part = re.sub(attachment_pattern, replace_attachment_markdown, part)
            result.append(updated_part)

        return ''.join(result)

    updated_content = process_content(content)

    # Write updated content back
    with open(args.markdown_file, "w", encoding="utf-8") as f:
        f.write(updated_content)

    print(f"Updated attachment references in: {args.markdown_file}", file=sys.stderr)


if __name__ == "__main__":
    main()
