# Proposal: View Tab Expand/Collapse All Toggle

## Summary

Add a control panel to the View Tab page with site count display and an expand/collapse all toggle button. The button icon dynamically updates based on the actual expanded state of all sites below.

## Problem Statement

Currently, View Tab lacks a one-click expand or collapse all sites feature. Users need to manually toggle each site individually.

## Proposed Solution

### Control Panel UI

Add a control panel above the site list (only visible when there are 2 or more sites):
- Left side: Site count text (with singular/plural handling: "1 site" / "X sites")
- Right side: Expand/collapse toggle button

### Button Icon Logic

| All Sites State | Button Icon |
|-----------------|-------------|
| All expanded | `iconGeneralCollapseAllSolid` (double arrow up) |
| All collapsed | `iconGeneralExpandAllSolid` (double arrow down) |
| Mixed state | Maintain current icon unchanged |

### Button Tap Behavior

- Tapping toggles the expand/collapse state of all sites
- If currently expanded → collapse all
- If currently collapsed → expand all

## UI Reference

Based on design spec:
- Control panel height: 44pt
- Left text uses `.callout.color05` style
- Right button uses `RoundedIconSmallSecondaryButtonStyle`
- Control panel only visible when site count >= 2

## Scope

- Add `SiteExpandStateViewModel` to manage expand states
- Modify `ViewTabSiteView` to add control panel
- Modify `RoundedBackgroundDisclosureGroup` to support external binding

## Out of Scope

- Search page (`ViewTabSiteSearchingView`) maintains existing logic unchanged
- No persistence for expand states required
