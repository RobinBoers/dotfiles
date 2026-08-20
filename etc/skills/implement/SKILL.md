---
name: implement
description: Implement an entire plan or a named step from a plan.
disable-model-invocation: true
---

# Implement

Implement work from a plan supplied by the user, usually `.claude/plans/YYYY-MM-DD-slug.md`. If no plan was given, use the most recent plan from `.claude/plans`.

## Establish what to do

1. Read the whole plan and relevant code.
2. Identify the requested step (next step when none is named).
3. Check that dependencies and decisions are settled. If not, stop and ask. Do not invent an answer.
4. Explain the intended change and files briefly before editing when the plan leaves room for interpretation.

## Do it

- Follow existing patterns and reuse existing implementations.
- Preserve unrelated user changes.
- Do not opportunistically complete later steps.
- If code contradicts the plan, determine whether the plan is stale or the code exposes a missed constraint. Surface the conflict before changing direction.
- Prefer a complete vertical change over disconnected scaffolding (when the plan permits it).
- Run checks only when asked. Limit them to the changed area. Report what was and was not checked.

## Finish off nicely

- Mark completed checkboxes in the plan.
- Add brief notes to the plan only for hard-to-recover facts, like deviations, discovered constraints, follow-up work. Use markdown blockquotes. Keep it short.
- Update later steps when implementation proves an assumption false. Do not rewrite agreed scope silently.
- Summarise changed files, checks, next steps, blockers. Use second level headings with lists, both sentence-case.

Do not commit, push, perform a review, or start next step unless asked.
