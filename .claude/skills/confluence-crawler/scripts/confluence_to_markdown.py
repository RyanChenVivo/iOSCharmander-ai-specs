#!/usr/bin/env python3
"""
Confluence HTML to Markdown converter.

Properly handles:
- Nested lists (3+ levels with correct indentation)
- Internal Confluence links (converts to complete URLs)
- Confluence macros (drawio, attachments, etc.)
- Standard HTML formatting (headings, bold, italic, code)

Usage:
    python3 confluence_to_markdown.py --input raw.json --output page.md
    python3 confluence_to_markdown.py --input raw.json  # outputs to stdout
    cat raw.json | python3 confluence_to_markdown.py    # reads from stdin
"""

import argparse
import json
import re
import sys
import html
from html.parser import HTMLParser
from urllib.parse import quote


class ConfluenceToMarkdown(HTMLParser):
    """HTML parser that properly handles nested lists, tables, and Confluence-specific elements."""

    def __init__(self, base_url: str = "https://confluence.vivotek.com"):
        super().__init__()
        self.base_url = base_url
        self.output = []
        self.list_depth = 0
        self.list_type_stack = []
        self.ol_counters = []
        self.in_list_item = False
        self.current_item = []
        self.skip_content = False
        self.item_has_content = False
        self._pending_href = ""
        # Code block handling (supports multiple code macros per page)
        self.in_code_macro = False
        self.code_language = ""
        self.in_code_body = False
        self.code_content = []
        self._capturing_language = False
        self._skip_param = False
        # Expand macro handling
        self.in_expand_macro = False
        self.expand_title = ""
        self._capturing_expand_title = False
        # Pre tag handling (for preformatted code)
        self.in_pre = False
        self.pre_content = []
        # Table handling
        self.in_table = False
        self.table_rows = []
        self.current_row = []
        self.current_cell = []
        self.current_cell_code_blocks = []  # Code blocks in current cell
        self.in_cell = False
        self.cell_is_header = False
        self.cell_colspan = 1
        self.has_header_row = False

    def _flush_list_item_prefix(self):
        """Output the list item bullet and any accumulated text before a nested list."""
        # Skip list formatting when inside table cell - just capture text
        if self.in_cell:
            if self.current_item:
                item_text = ''.join(self.current_item).strip()
                if item_text:
                    self.current_cell.append(item_text + ' ')
                self.current_item = []
            self.item_has_content = True
            return

        if self.in_list_item and not self.item_has_content:
            indent = '  ' * (self.list_depth - 1)
            item_text = ''.join(self.current_item).strip()

            if self.list_type_stack and self.list_type_stack[-1] == 'ol':
                if self.ol_counters:
                    self.ol_counters[-1] += 1
                    bullet = f'{self.ol_counters[-1]}.'
                else:
                    bullet = '1.'
            else:
                bullet = '-'

            if item_text:
                self.output.append(f'\n{indent}{bullet} {item_text}')
            else:
                self.output.append(f'\n{indent}{bullet}')

            self.item_has_content = True
            self.current_item = []

    def _append(self, text: str):
        """Append text to current item, table cell, or output."""
        if self.in_cell:
            self.current_cell.append(text)
        elif self.in_list_item and not self.item_has_content:
            self.current_item.append(text)
        else:
            self.output.append(text)

    def _output_table(self):
        """Output table as HTML to completely duplicate the source Confluence table structure."""
        if not self.table_rows:
            return

        self.output.append('\n\n<table>\n')

        # Output all rows preserving exact structure
        for row in self.table_rows:
            self.output.append('<tr>\n')

            for cell in row:
                cell_text = cell.get('text', '')
                code_blocks = cell.get('code_blocks', [])
                is_header = cell.get('is_header', False)
                colspan = cell.get('colspan', 1)

                # Use th for header cells, td for data cells
                tag = 'th' if is_header else 'td'

                # Add colspan attribute if > 1
                colspan_attr = f' colspan="{colspan}"' if colspan > 1 else ''

                self.output.append(f'  <{tag}{colspan_attr}>')

                # Add cell text if present (clean up bold markers for header cells)
                if cell_text:
                    if is_header:
                        # Remove markdown bold markers from header text
                        clean_text = re.sub(r'\*{2,}', '', cell_text).strip()
                        self.output.append(f'{clean_text}')
                    else:
                        self.output.append(f'{cell_text}')

                # Add code blocks with proper HTML formatting (markdown doesn't work in HTML tables)
                for code_block in code_blocks:
                    lang = code_block.get('language', '')
                    code = code_block.get('code', '')
                    title = code_block.get('title', '')
                    # Escape HTML entities in code
                    code_escaped = code.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
                    if title:
                        self.output.append(f'\n<details><summary><strong>{title}</strong></summary>\n<pre><code class="{lang}">{code_escaped}</code></pre>\n</details>\n')
                    else:
                        self.output.append(f'\n<pre><code class="{lang}">{code_escaped}</code></pre>\n')

                self.output.append(f'</{tag}>\n')

            self.output.append('</tr>\n')

        self.output.append('</table>\n\n')

    def handle_starttag(self, tag: str, attrs: list):
        attrs_dict = dict(attrs)

        # Table handling
        if tag == 'table':
            self.in_table = True
            self.table_rows = []
            self.has_header_row = False

        elif tag == 'tr':
            if self.in_table:
                self.current_row = []

        elif tag in ('th', 'td'):
            if self.in_table:
                self.in_cell = True
                self.current_cell = []
                self.current_cell_code_blocks = []
                self.cell_is_header = (tag == 'th')
                self.cell_colspan = int(attrs_dict.get('colspan', '1'))
                if tag == 'th':
                    self.has_header_row = True

        elif tag in ('ul', 'ol'):
            if self.in_list_item and self.current_item:
                self._flush_list_item_prefix()
            self.list_type_stack.append(tag)
            if tag == 'ol':
                self.ol_counters.append(0)
            self.list_depth += 1

        elif tag == 'li':
            self.in_list_item = True
            self.current_item = []
            self.item_has_content = False

        elif tag in ('h1', 'h2', 'h3', 'h4', 'h5', 'h6'):
            level = int(tag[1])
            self.output.append('\n' + '#' * level + ' ')

        elif tag == 'p':
            if not self.in_list_item:
                self.output.append('\n')

        elif tag == 'br':
            self._append('\n')

        elif tag in ('strong', 'b'):
            self._append('**')

        elif tag in ('em', 'i'):
            self._append('*')

        elif tag == 'code':
            self._append('`')

        elif tag == 'a':
            href = attrs_dict.get('href', '')
            # Convert relative URLs to absolute
            if href.startswith('/'):
                href = self.base_url + href
            self._append('[')
            self._pending_href = href

        elif tag == 'ri:page':
            # Confluence internal page link - construct full URL
            page_space = attrs_dict.get('ri:space-key', '')
            content_title = attrs_dict.get('ri:content-title', '')
            encoded_title = quote(content_title, safe='')
            full_url = f'{self.base_url}/display/{page_space}/{encoded_title}'
            link_text = f'[{content_title}]({full_url})'
            self._append(link_text)

        elif tag == 'ri:attachment':
            filename = attrs_dict.get('ri:filename', '')
            self._append(f'[Attachment: {filename}]')

        elif tag == 'pre':
            # Start capturing preformatted content
            self.in_pre = True
            self.pre_content = []

        elif tag == 'ac:structured-macro':
            macro_name = attrs_dict.get('ac:name', '')
            if macro_name == 'code':
                # Start capturing code block
                self.in_code_macro = True
                self.code_language = ""
                self.code_content = []
            elif macro_name == 'expand':
                # Start capturing expand macro
                self.in_expand_macro = True
                self.expand_title = ""
            elif macro_name in ('drawio', 'view-file', 'ui-children'):
                self.skip_content = True
                if macro_name == 'drawio':
                    self.output.append('[Drawio Diagram]')
                elif macro_name == 'ui-children':
                    self.output.append('[Child Pages]')

        elif tag == 'ac:parameter':
            param_name = attrs_dict.get('ac:name', '')
            if self.in_code_macro:
                if param_name == 'language':
                    # Language will be captured in handle_data
                    self._capturing_language = True
                elif param_name in ('theme', 'title', 'linenumbers', 'collapse'):
                    # Skip other code macro parameters (theme, title, etc.)
                    self._skip_param = True
            elif self.in_expand_macro:
                if param_name == 'title':
                    # Title will be captured in handle_data
                    self._capturing_expand_title = True

        elif tag == 'ac:plain-text-body' and self.in_code_macro:
            self.in_code_body = True

    def handle_endtag(self, tag: str):
        # Table handling
        if tag in ('th', 'td'):
            if self.in_table and self.in_cell:
                # Get cell content
                cell_text = ''.join(self.current_cell).strip()
                # Clean up whitespace and newlines for table cell
                cell_text = ' '.join(cell_text.split())
                # Store cell with its code blocks and colspan
                cell_data = {
                    'text': cell_text,
                    'code_blocks': self.current_cell_code_blocks[:],
                    'is_header': self.cell_is_header,
                    'colspan': self.cell_colspan
                }
                self.current_row.append(cell_data)
                self.in_cell = False
                self.current_cell = []
                self.current_cell_code_blocks = []
                self.cell_colspan = 1

        elif tag == 'tr':
            if self.in_table and self.current_row:
                self.table_rows.append(self.current_row)
                self.current_row = []

        elif tag == 'table':
            if self.in_table:
                # Convert table to markdown
                self._output_table()
                self.in_table = False
                self.table_rows = []

        elif tag in ('ul', 'ol'):
            if self.list_type_stack:
                self.list_type_stack.pop()
            if tag == 'ol' and self.ol_counters:
                self.ol_counters.pop()
            self.list_depth -= 1
            # Only append newline when outside table cells
            if self.list_depth == 0 and not self.in_cell:
                self.output.append('\n')

        elif tag == 'li':
            if self.in_list_item and not self.item_has_content:
                self._flush_list_item_prefix()
            self.in_list_item = False
            self.current_item = []
            self.item_has_content = False

        elif tag in ('h1', 'h2', 'h3', 'h4', 'h5', 'h6'):
            self.output.append('\n\n')

        elif tag == 'p':
            if not self.in_list_item:
                self.output.append('\n')

        elif tag in ('strong', 'b'):
            self._append('**')

        elif tag in ('em', 'i'):
            self._append('*')

        elif tag == 'code':
            self._append('`')

        elif tag == 'a':
            href = self._pending_href
            self._append(f']({href})')
            self._pending_href = ""

        elif tag == 'pre':
            if self.in_pre:
                # Output preformatted content as code block
                code = ''.join(self.pre_content).strip()
                if code:
                    if self.in_cell:
                        # Store code block for table cell
                        self.current_cell_code_blocks.append({
                            'language': 'json',  # Assume JSON for pre content
                            'code': code,
                            'title': self.expand_title if self.in_expand_macro else ''
                        })
                    else:
                        if self.in_expand_macro and self.expand_title:
                            self._append(f'\n\n**{self.expand_title}**\n```json\n{code}\n```\n')
                        else:
                            self._append(f'\n\n```\n{code}\n```\n')
                self.in_pre = False
                self.pre_content = []

        elif tag == 'ac:parameter':
            if self._capturing_language:
                self._capturing_language = False
            if self._skip_param:
                self._skip_param = False
            if self._capturing_expand_title:
                self._capturing_expand_title = False

        elif tag == 'ac:plain-text-body' and self.in_code_macro:
            self.in_code_body = False

        elif tag == 'ac:structured-macro':
            if self.in_code_macro:
                # Output the code block in Markdown format
                lang = self.code_language or ""
                code = ''.join(self.code_content).strip()
                if self.in_cell:
                    # Store code block for table cell
                    self.current_cell_code_blocks.append({
                        'language': lang,
                        'code': code
                    })
                else:
                    self._append(f'\n\n```{lang}\n{code}\n```\n')
                # Reset code macro state for next code block
                self.in_code_macro = False
                self.code_language = ""
                self.code_content = []
            if self.in_expand_macro:
                # Reset expand macro state
                self.in_expand_macro = False
                self.expand_title = ""
            self.skip_content = False

    def handle_data(self, data: str):
        if self.skip_content:
            return
        # Skip other code macro parameters (theme, title, etc.)
        if self._skip_param:
            return
        # Capture language for code macro
        if self._capturing_language:
            self.code_language = data.strip()
            return
        # Capture expand macro title
        if self._capturing_expand_title:
            self.expand_title = data.strip()
            return
        # Capture code content
        if self.in_code_body:
            self.code_content.append(data)
            return
        # Capture preformatted content
        if self.in_pre:
            self.pre_content.append(data)
            return
        self._append(data)

    def get_markdown(self) -> str:
        result = ''.join(self.output)
        result = re.sub(r'\n{3,}', '\n\n', result)
        result = html.unescape(result)
        return result.strip()


def preprocess_cdata(html_content: str) -> str:
    """
    Pre-process HTML to convert CDATA sections to regular content.
    CDATA sections in Confluence are used for code blocks and need special handling.
    """
    # Replace CDATA markers with a placeholder that preserves content
    # Pattern: <![CDATA[content]]>
    def replace_cdata(match):
        content = match.group(1)
        # Escape HTML entities in the content to prevent parsing issues
        content = content.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
        return content

    return re.sub(r'<!\[CDATA\[(.*?)\]\]>', replace_cdata, html_content, flags=re.DOTALL)


def convert_confluence_to_markdown(
    data: dict,
    base_url: str = "https://confluence.vivotek.com"
) -> tuple[str, str, str]:
    """
    Convert Confluence API response to Markdown.

    Returns:
        tuple: (title, markdown_content, suggested_filename)
    """
    title = data.get("title", "Untitled")
    space_key = data.get("space", {}).get("key", "unknown")
    page_id = data.get("id", "unknown")
    body_html = data.get("body", {}).get("storage", {}).get("value", "")

    # Pre-process to handle CDATA sections (used in code blocks)
    body_html = preprocess_cdata(body_html)

    parser = ConfluenceToMarkdown(base_url)
    parser.feed(body_html)
    body_markdown = parser.get_markdown()

    # Build full markdown with metadata
    source_url = f"{base_url}/pages/viewpage.action?pageId={page_id}"
    markdown = f"# {title}\n\n"
    markdown += f"**Source:** [{title}]({source_url})\n\n"
    markdown += f"**Space:** {space_key} | **Page ID:** {page_id}\n\n"
    markdown += "---\n\n"
    markdown += body_markdown

    # Generate safe filename
    safe_title = re.sub(r'[^\w\s-]', '', title).strip().replace(' ', '_')
    filename = f"{safe_title}.md"

    return title, markdown, filename


def main():
    parser = argparse.ArgumentParser(
        description="Convert Confluence page JSON to Markdown"
    )
    parser.add_argument(
        "--input", "-i",
        help="Input JSON file (default: stdin)"
    )
    parser.add_argument(
        "--output", "-o",
        help="Output Markdown file (default: stdout)"
    )
    parser.add_argument(
        "--base-url",
        default="https://confluence.vivotek.com",
        help="Confluence base URL"
    )

    args = parser.parse_args()

    # Read input
    if args.input:
        with open(args.input, "r", encoding="utf-8") as f:
            data = json.load(f)
    else:
        data = json.load(sys.stdin)

    # Convert
    title, markdown, suggested_filename = convert_confluence_to_markdown(
        data, args.base_url
    )

    # Write output
    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(markdown)
        print(f"Saved: {args.output}", file=sys.stderr)
        print(f"Title: {title}", file=sys.stderr)
    else:
        print(markdown)


if __name__ == "__main__":
    main()
