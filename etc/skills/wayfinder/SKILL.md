---
name: wayfinder
description: Build and advance a durable decision map for work too large or uncertain to settle in one session.
disable-model-invocation: true
---

# Wayfinder

Find a route through work too large or uncertain for one session. The output is one evolving plan under `.claude/plans`, not an issue tracker, spec tree, or pile of tickets.

Wayfinder plans by default. It resolves what must be decided before implementation. It does not quietly start building the destination.

## The map

Store the map at `.claude/plans/<name>.md`:

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

Omit empty sections. Keep detail in the one place where it belongs.

- **Destination:** what must be true when wayfinding is complete. This fixes scope.
- **Decisions:** settled choices, named and summarised with their reason.
- **Frontier:** precise unresolved questions whose prerequisites are known. Record dependencies by name when blocked.
- **Later:** in-scope uncertainty that cannot yet be phrased as a precise question.
- **Out of scope:** work deliberately beyond the destination. It does not return unless the destination changes.
- **Implementation:** the ordered route, written only when enough decisions are settled.

Refer to decisions by descriptive name, not numbers or slugs.

## Frontier and fog

The map is deliberately incomplete. Do not invent a full work breakdown while important choices are unresolved.

- Put something on the **frontier** when its question can be stated precisely now, even if another named decision blocks it.
- Put it under **Later** when you know the area matters but cannot yet state the question precisely.
- Keep settled work, live questions, later uncertainty, and excluded work separate.

Resolving a decision clears some fog. Promote newly precise questions to the frontier, remove invalidated questions, and update dependency links. One answer may expose several questions or make an entire area irrelevant.

## Start a map

1. Inspect the repository, history, supplied material, and existing `.claude` files.
2. Use `/interview` to name the destination, constraints, and out-of-scope work first.
3. Map breadth-first: identify decisions across the whole effort before exploring one branch deeply.
4. Add precise questions to the frontier with their dependencies. Put only genuinely vague areas under Later.
5. Classify each frontier item by the work needed:
   - **decide:** a user choice resolved through `/interview`
   - **investigate:** facts the agent can discover
   - **prototype:** a cheap artifact needed to make a choice concrete
   - **prerequisite:** work that must happen before a decision can be made
6. Record the initial map and stop. Do not resolve a decision during the charting session.

If there is no meaningful fog and the route fits one session, say that wayfinder is unnecessary and recommend `/decide`.

## Advance a map

1. Read the destination and low-resolution map first. Load detailed code or decisions only as needed.
2. Take the item named by the user. Otherwise recommend an unblocked frontier item that clears the most uncertainty.
3. Mark it in progress before working so another session can avoid it.
4. Resolve one coherent decision branch per session. Independent factual investigations may run together when useful.
5. Use `/interview` for user decisions. Never let the agent perform both sides of that conversation.
6. Record the answer under Decisions with enough reason to guide dependent work. Remove the frontier entry.
7. Recompute the map: promote fog, add newly exposed questions, update dependencies, and move newly excluded work out of scope.
8. Remove the in-progress mark and stop after saving the map.

Expect the map to change rather than grow monotonically. Delete stale branches instead of preserving a history of discarded guesses.

## Finish

Wayfinding is complete when the destination is understood, the frontier and Later sections are empty, and no implementation step requires an unstated decision.

Write an ordered, checkable Implementation section. Preserve decision references where a step depends on a non-obvious choice. The plan is then ready for `/implement`.
