---
name: refactor
description: Find worthwhile architectural refactors, decide one with the user, and turn it into a plan.
disable-model-invocation: true
---

# Refactor

Find architectural friction and propose deepening opportunities: changes that put more useful behavior behind smaller interfaces.

## Choose the search area

Use the scope or pain point the user names. Otherwise inspect enough git history to find recent or recurring change hotspots before widening the search. Refactoring pays where future changes are likely. Do not scan the entire repository by habit.

Read repository instructions, `.claude/domain.md`, relevant plans and decisions, then the code and tests in that area. Existing decisions are constraints, not commandments: reopen one only when current friction justifies it.

## Explore

Use `/codebase-design` and follow friction rather than a rigid smell checklist. Look for:

- one concept spread across many modules
- interfaces nearly as complex as their implementations
- policy duplicated across callers
- dependencies or invariants leaking across seams
- tests aimed at extracted helpers while bugs live in their orchestration
- inconsistent naming
- changes that repeatedly touch unrelated files
- behavior that is hard to test through its current interface

Apply the deletion test to suspected shallow modules. Classify dependencies before suggesting a new seam. Reject speculative abstractions and changes that merely add a layer.

## Present candidates

Rank a small set in chat. For each candidate include:

- affected files
- concrete friction
- current and proposed module shape
- dependency category and seam
- expected locality, leverage, and test improvement
- migration risk
- confidence: **strong**, **worth exploring**, or **speculative**

Show a compact before/after diagram when relationships matter. Recommend one candidate and explain why it beats the others.

Do not design the final interface yet. Ask which candidate the user wants to explore.

## Decide the refactor

For the chosen candidate:

1. Run `/interview` over constraints, module responsibility, interface, seam, adapters, migration, compatibility, tests, rollout, and rollback where relevant.
2. Use `/codebase-design`'s design-it-twice process when the interface is expensive or uncertain.
3. Use `/domain-modeling` when naming exposes a real domain ambiguity.
4. If the proposal conflicts with `.claude/decisions`, name the conflict and why reopening it may be justified.
5. If the user rejects a recurring candidate for a durable reason, offer a decision note so later reviews do not suggest it again.

Save agreed non-trivial work to `.claude/plans/<name>.md`, with ordered migration and verification steps. Do not implement unless asked separately.
