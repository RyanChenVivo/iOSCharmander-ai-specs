# uitest-actions-skill

## Overview

Action execution skill for UITest analysis follow-up. This skill handles Phase 4: executing various actions including observe, fix, restore environment, and learn. Includes smart prompting for learning that only triggers when valuable new information exists.

## Files to Create

### `.claude/skills/uitest-actions/SKILL.md`

```yaml
---
name: uitest-actions
description: >
  Execute UITest analysis follow-up actions. Includes: observation recording
  (observe), prepare fix (fix), restore environment (restore), and record
  learnings (learn). Executes corresponding flow based on analysis conclusion.
---
```

**Content Structure:**

1. **Available Actions Overview**

2. **Observe Action**
   - Record issue and wait for observation
   - **Steps:**
     1. Record to `uitest-automation/observations/active.json`
     2. Set observation period (default 2 days)
     3. Next analysis will check if issue recurs
   - **After completion:** Check if should ask about recording learning (see Learn section)

3. **Fix Action**
   - Prepare for fix
   - **Steps:**
     1. Use `/openspec:proposal` to create fix proposal
     2. After fix complete, check if should record learning
   - **After completion:** Check if should ask about recording learning (see Learn section)

4. **Restore Environment Action**
   - Handle environment configuration issues
   - **Steps:**
     1. Diagnose environment issue (account/credential/config)
     2. Provide restoration steps or execute restore script
     3. Verify environment is back to normal
   - **After completion:** Check if should ask about recording learning (see Learn section)

5. **Learn Action**
   - Record analysis experience to patterns.md
   - **When to ask about recording:**
     - ✅ Ask: New situation (no pattern matched during analysis)
     - ✅ Ask: Recurring observation (previous judgment may be wrong)
     - ❌ Don't ask: Matched known pattern (no new information)
   - **Trigger conditions:**
     - After other actions complete (conditional based on above rules)
     - User explicitly wants to record experience
     - During fix process, discovered new judgment rule
   - **Steps:**
     1. Ask what to record:
        - New pattern
        - Correct previous judgment
        - Fix experience
     2. Guide through filling content
     3. Update `.claude/skills/analyzing-uitest-failures/references/patterns.md`

6. **Smart Prompting Logic**

   ```
   After action completion:

   Was pattern matched during analysis?
   ├─ Yes (known pattern) → Don't ask about learning
   └─ No (new situation) → Ask: "Would you like to record this as a pattern?"

   Is this a recurring issue?
   ├─ Yes (seen before) → Ask: "Previous judgment may be wrong. Record correction?"
   └─ No (first time) → Follow above logic
   ```

**Estimated Lines:** ~80

## Acceptance Criteria

- [ ] SKILL.md follows YAML frontmatter format
- [ ] Description contains trigger keywords (observe, fix, restore, learn)
- [ ] All four actions are documented with clear steps
- [ ] Smart prompting logic is clearly defined
- [ ] Learning only prompts when valuable (not for known patterns)
- [ ] Updates correct patterns.md location (in skills/analyzing-uitest-failures/references/)
- [ ] Total SKILL.md under 500 lines
- [ ] All content in English

## Dependencies

- Typically invoked after `analyzing-uitest-failures` or `investigating-uitest`
- Learn action updates `analyzing-uitest-failures` skill's references

## Testing

1. Test observe action records to active.json correctly
2. Test fix action invokes openspec proposal
3. Test restore action provides diagnostic steps
4. Test learn action:
   - Does NOT prompt when known pattern matched
   - DOES prompt when new situation encountered
   - DOES prompt when recurring issue detected
5. Verify patterns.md update works correctly
