---
name: decide
description: Sharpen a plan or design by inspecting its context, interviewing the user, and recording the result as a plan.
---

# Decide

Turn an unclear idea into an agreed plan.

## Orient

1. Read supplied material, relevant code and history, repository instructions, and existing `.claude` files.
2. State the intended outcome, current constraints, and obvious unknowns briefly. Do not dump your research on the user.
3. If the effort is too large to map in one session, recommend `/wayfinder` instead.

## Decide

Run `/interview` over the design tree.

- Find facts yourself. Ask only for intent, preferences, and decisions.
- Cover scope, behavior, constraints, dependencies, failure cases, migration, verification, and rollout where relevant.
- Use `/domain-modeling` when ambiguous terms affect the design. Ordinary code names do not need a glossary.
- Check claims against the code. Surface contradictions instead of silently choosing one source.
- Keep the plan coherent as decisions change. Do not preserve obsolete branches as historical clutter.
- Do not implement while deciding.

## Record

When the user confirms the result, create or update `.claude/plans/<name>.md`. If the user supplied a plan, update that file instead of creating another.

Use only the sections the work needs:

```markdown
# <name>

## Goal
## Scope
## Constraints
## Decisions
## Implementation
## Verification
## Open questions
```

Implementation steps must be ordered, concrete, and checkable. Name affected areas and dependencies where known, but do not paste code that the implementer can read from the repository.

A plan is ready when `/implement` can execute it without inventing product or design decisions. If open questions still block implementation, say so plainly.
