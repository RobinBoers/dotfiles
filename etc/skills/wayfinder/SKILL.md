---
name: wayfinder
description: Build and advance one durable decision map for work too large or uncertain to settle at once.
disable-model-invocation: true
---

# Wayfinder

Plan large, unclear work. Settle every decision needed before implementation. Do not start building unless the user asks.

Keep one plan at `.claude/plans/<name>.md`:

```markdown
# <name>

## Destination
## Constraints
## Decisions
## Frontier
## Later
## Out of scope
## Implementation
```

Omit empty sections. Put each fact in one place.

- **Destination:** What must be true when planning is done.
- **Constraints:** Rules the route must obey.
- **Decisions:** Settled choices and the reason for each.
- **Frontier:** Precise open questions. Name blockers where needed.
- **Later:** In-scope areas that are still too vague for a precise question.
- **Out of scope:** Work this plan will not cover.
- **Implementation:** The ordered route. Write it only after all decisions are settled.

Use descriptive names, not ticket numbers or decision IDs.

## Keep the map current

The map is not a history log. Rewrite it as understanding changes.

After every settled decision:

1. Record it under Decisions.
2. Remove its Frontier item.
3. Remove stale questions.
4. Add questions the answer exposed.
5. Update all affected blockers.
6. Move newly precise items from Later to Frontier.
7. Move excluded work to Out of scope.
8. Save before asking another question.

Do not collect several answers and update the map later.

## Start a map

1. Inspect the repository, history, supplied material, and existing `.claude` files.
2. Use `/interview` to settle the destination, constraints, and exclusions.
3. Map breadth-first. Cover the whole effort before going deep.
4. Put precise questions on Frontier, even when blocked. Put vague areas under Later.
5. Mark each Frontier item as `decide`, `investigate`, `prototype`, or `prerequisite`.
6. Save the initial map and stop. Do not resolve decisions while charting.

If the work fits one session and has no real uncertainty, recommend `/decide` instead.

## Advance a map

A conversation may settle several decisions, but handle one coherent branch at a time.

For each branch:

1. Read the low-detail map. Load code and detailed decisions only as needed.
2. Use the item named by the user. Otherwise choose an unblocked question that clears useful uncertainty.
3. Mark it in progress.
4. Investigate facts or use `/interview` for user choices. Never answer the user’s side yourself.
5. Record the answer and fully update the map using the checklist above.
6. Remove the in-progress mark and save.
7. If continuing, ask the next focused question directly. Do not announce a “next frontier.”

Independent factual checks may run together. Decisions may not be left unrecorded between questions.

## Finish

Planning is done when Frontier and Later are empty and implementation needs no unstated choice.

Write an ordered, checkable Implementation section. Keep references to decisions where their reasons matter. The plan is then ready for `/implement`.
