---
name: implement
description: Implement an entire plan or a named step from a plan.
disable-model-invocation: true
---

# Implement

Implement work from a plan supplied by the user, normally `.claude/plans/<name>.md`.

## Establish the step

1. Read the whole plan, repository instructions, relevant code, and nearby tests.
2. Identify the requested step, or the next incomplete unblocked step when none is named.
3. Check that its dependencies and decisions are settled. If not, stop and ask. Do not invent an answer.
4. Explain the intended change and files briefly before editing when the plan leaves room for interpretation.

## Work

- Follow existing patterns and reuse existing implementations.
- Preserve unrelated user changes.
- Keep the change within the chosen step. Do not opportunistically complete later steps.
- If code contradicts the plan, determine whether the plan is stale or the code exposes a missed constraint. Surface the conflict before changing direction.
- Prefer a complete vertical change over disconnected scaffolding when the plan permits it.
- Run checks appropriate to the changed area only when requested or required by repository instructions. Report what was and was not checked.

## Leave a usable state

- Mark completed checkboxes in the plan.
- Add a brief note only for facts the next session cannot recover easily: deviations, discovered constraints, or follow-up work.
- Update later steps when implementation proves an assumption false. Do not rewrite agreed scope silently.
- Summarise changed files, checks, remaining steps, and blockers.

Do not commit, push, perform a separate review, or start another step unless asked.
