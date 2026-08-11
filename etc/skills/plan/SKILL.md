---
name: plan
description: Turn a wayfinder map or conversation into a full plan for the implementation agent.
disable-model-invocation: true
---

Turn current conversation context or a `/wayfinder` map into a plan. Do not interview the user (anymore), just synthesize what you already know.

Use a wayfinder map if this is a wayfinder session or the user explicitly asked for it. Otherwise, synthesize the current conversation context.

For `/wayfinder` or `/interview` sessions, refuse if the frontier is non-empty.

### How and where to write

Read supplied material, relevant code and history, repository instructions, and existing `.claude` files before writing.

Write the plan in `.claude/plans/YYYY-MM-DD-slug.md`. Create a new document or update an existing user-supplied document.

Use the vocabulary defined in `.claude/domain.md` throughout the spec, and respect any `.claude/decisions`.

```markdown
# <name>

[GOAL]

## Constraints

<list>

## Decisions

### <name>
<details>

## Implementation

<details>

### Out-of-scope

<list>

## Open questions

<list>
```

The <name> is always short, descriptive, and sentence-cased.

Omit open questions if there are no open questions left. Only include constraints if relevant.

When the plan consists of multiple steps use checkboxes.

A plan is ready when `/implement` can execute it without inventing decisions. If open questions still block implementation, say so plainly.
