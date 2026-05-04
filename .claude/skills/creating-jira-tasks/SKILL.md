---
name: creating-jira-tasks
description: Use when user asks to create Jira issues, tasks, subtasks, or tickets in the ADAT project. Triggers on "open task", "create issue", "build Jira ticket", or any request to track work in Jira.
---

# Creating Jira Tasks

Create Jira issues in ADAT project with iOS team conventions.

## When to Use

- User asks to create Jira tasks, issues, or tickets
- User wants to track implementation work in Jira
- User says "open a task" or "create a Jira issue"

## Configuration

| Field | Value |
|-------|-------|
| cloudId | `3488b3d0-e7f2-4e7b-ab80-045623d2d63a` |
| projectKey | `ADAT` |
| Summary prefix | `[iOS]` |
| Labels | `["iOS"]` |
| Parent issue type | `任務` |
| Subtask issue type | `子任務` |
| Content format | `markdown` |

## Workflow

1. **Confirm scope** with user: parent task summary + list of subtasks
2. **Create parent** issue first (type: `任務`)
3. **Create all subtasks** in parallel (type: `子任務`, linked to parent)
4. **Report** table of created issues with keys and summaries

## Issue Creation Template

### Parent Task

```
mcp__atlassian__createJiraIssue:
  cloudId: 3488b3d0-e7f2-4e7b-ab80-045623d2d63a
  projectKey: ADAT
  issueTypeName: 任務
  summary: "[iOS]<parent summary>"
  additional_fields: {"labels": ["iOS"]}
```

### Subtask

```
mcp__atlassian__createJiraIssue:
  cloudId: 3488b3d0-e7f2-4e7b-ab80-045623d2d63a
  projectKey: ADAT
  issueTypeName: 子任務
  summary: "[iOS]<subtask summary>"
  parent: <parent issue key>
  description: "<bullet list of scope items>"
  contentFormat: markdown
  additional_fields: {"labels": ["iOS"]}
```

## Conventions

- Summary always starts with `[iOS]`
- Description uses markdown bullet list for scope
- All issues get the `iOS` label
- Create subtasks in parallel (single message, multiple tool calls)
- Subtask summaries should be concise and action-oriented (e.g. "Implement X", "Refactor Y", "Add Z")

## Quick Reference

| Action | Issue Type | Parent |
|--------|-----------|--------|
| Feature umbrella | `任務` | none |
| Implementation task | `子任務` | parent key |
| Standalone task (no subtasks) | `任務` | none |
