---
name: redmine-issue-report
description: Use when querying Redmine issues, generating issue reports, or creating issue summary markdown files. Triggers on "redmine", "issue report", "issue list", "bug list".
---

# Redmine Issue Report

## Overview

Query Redmine issues via REST API and generate a formatted markdown report with issue details and descriptions.

## Trigger

Use when user:
- Wants to query or list Redmine issues
- Needs a summary report of issues (by assignee, status, priority, etc.)
- Asks to generate a markdown report from Redmine

## Skill Directory

```bash
SKILL_DIR=".claude/skills/redmine-issue-report"
```

## Authentication Flow

**Credentials are stored in a `.env` file inside the skill directory (`$SKILL_DIR/.env`).**

### Step 1: Check for credentials

Read `$SKILL_DIR/.env` and verify `REDMINE_URL`, `REDMINE_API_KEY`, and `REDMINE_PROJECT` are set.

- If `.env` exists and all values are set → proceed to Workflow
- If `.env` exists but values are empty → ask user to fill in, go to Step 3
- If `.env` doesn't exist → go to Step 2

### Step 2: Create .env file (if doesn't exist)

Create `$SKILL_DIR/.env` with template:

```
REDMINE_URL=
REDMINE_API_KEY=
REDMINE_PROJECT=
REDMINE_USER=
```

Ensure `.env` is in `.gitignore` to prevent credential leaks.

Then display this message to the user:

```
I've created a .env file at .claude/skills/redmine-issue-report/.env
Please edit the file and fill in your Redmine credentials:

REDMINE_URL=https://redmine.vivotek.tw
REDMINE_API_KEY=your_api_key_here
REDMINE_PROJECT=vsaas
REDMINE_USER=your_login_name

After updating the file, let me know and I'll continue.
```

### Step 3: Load credentials

Read values from `.env` and use them for all subsequent API calls. Never log or echo the API key.

## Filter Parameters

These are provided by the user at query time (not stored in .env):

| Parameter | Description | Example |
|-----------|-------------|---------|
| Assignee | Person to filter by (login name) | `alive.kuo` |
| Status | `open`, `closed`, `*` (all) | `open` |
| Priority | Filter by priority | `High` |
| Output path | Where to save the .md report | `./report.md` |

## Workflow

### Step 1: Resolve User ID (if filtering by assignee)

**CRITICAL: Redmine API `assigned_to_id` only accepts numeric IDs, NOT login names.**

Do NOT attempt `assigned_to_id=login_name` — it returns 0 results silently.

**Strategy:** Fetch first page of issues, find the target assignee's numeric ID from the `assigned_to` field in any matching issue, then use that ID for the full query.

```
GET {REDMINE_URL}/projects/{project}/issues.json?key={api_key}&limit=100&status_id=*&sort=updated_on:desc
```

From results, find: `"assigned_to": {"id": 34, "name": "alive.kuo"}` → use `assigned_to_id=34`

### Step 2: Fetch All Issues

Once you have the numeric user ID, query with server-side filtering:

```
GET {REDMINE_URL}/issues.json?key={api_key}&assigned_to_id={user_id}&limit=100&status_id={status}&sort=id:desc
```

**Important parameters:**
- `status_id=*` → all statuses (open + closed)
- `status_id=open` → only open issues
- `status_id=closed` → only closed issues
- `limit=100` → max per page
- `offset=N` → for pagination (if total_count > 100)

Check `total_count` in response. If more than 100, paginate with `offset=100`, `offset=200`, etc.

### Step 3: Fetch Issue Details

For each issue, fetch full details including description:

```
GET {REDMINE_URL}/issues/{issue_id}.json?key={api_key}
```

The description field contains the full issue body with formatting.

**Performance tip:** Fetch multiple issue details in parallel using the Agent tool or parallel WebFetch calls.

### Step 4: Generate Markdown Report

**CRITICAL: You MUST write the report to a `.md` file using the Write tool. Do NOT only display results in conversation.**

After writing the file, provide a brief summary to the user in conversation.

Output filename: `redmine_issue_{YYYY-MM-DD}.md` (e.g., `redmine_issue_2026-03-06.md`)

```markdown
# {Project} Issue Report

**Generated:** {date}
**Filter:** Assignee: {name} | Status: {status}
**Total Issues:** {count}

## Summary

| ID | Subject | Status | Priority | Assigned To |
|----|---------|--------|----------|-------------|
| #ID | Subject text | Status | Priority | Name |
| ... | ... | ... | ... | ... |

## Issue Details

### #{id} - {subject}

- **Status:** {status}
- **Priority:** {priority}
- **Tracker:** {tracker}
- **Assigned To:** {name}
- **Author:** {author}
- **Created:** {date}
- **Updated:** {date}

**Description:**

{Copy the full description from Redmine as-is. Do NOT summarize, paraphrase, or restructure.}

---

(repeat for each issue)
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Using login name as `assigned_to_id` | Always resolve to numeric ID first |
| Relying on AI model to filter large JSON | Use API query parameters for server-side filtering |
| Missing paginated results | Check `total_count` and loop with `offset` |
| Forgetting `status_id=*` | Default only returns open issues; use `*` for all |
| Exposing API key in logs or commits | Store in `.env`, add to `.gitignore`, never echo |
| Only displaying results in conversation without writing .md file | ALWAYS write the report to a `.md` file first, then summarize in conversation |
| Summarizing or paraphrasing issue descriptions | Copy the full Redmine description as-is into the report |

## WebFetch Limitations

The `WebFetch` tool processes content through a small AI model. When dealing with large JSON (100+ issues), this model may **miss entries**. Always:
1. Use server-side filtering (query parameters) instead of client-side filtering
2. Verify `total_count` matches the number of results you received
3. For assignee queries, resolve user ID first, then let Redmine filter
