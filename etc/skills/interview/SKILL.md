---
name: interview
description: Interview the user to expose assumptions and settle a plan, decision, or idea. Use when another skill needs a decision loop or the user wants their thinking challenged.
---

# Interview

Reach shared understanding by working through a decision tree.

## Build the tree

- Start with the outcome. What must be decided, and what is outside the discussion?
- Split it into decisions. Record which decisions depend on others.
- The **frontier** is every unsettled decision whose prerequisites are settled.
- Rebuild the frontier after each answer. New answers may add, remove, or invalidate branches.
- Stop when the frontier is empty and no important choice remains implicit.

Do not pretend the whole tree is visible at the start. Discover it as answers expose the next branches.

## Ask in rounds

Ask one focused question at a time, or a small numbered group when the questions are independent. Never ask a question whose answer depends on another question in the same round.

Format each question like this:

```markdown
### Q1. <decision>

<focused question>

- **A:** <option>
- **B:** <option>
- **C:** <option>

**Recommendation:** <option and brief reason>
```

Omit the options when the question is open-ended. Keep question numbers stable so the user can answer by reference.

State the decision plainly. Explain only the constraint or trade-off needed to answer it. Always give your recommended answer and why.

Wait for the user's answer before advancing. Keep a short running summary of settled decisions so they stay settled.

## Divide the work correctly

Facts are your job. Inspect code, files, tools, history, and documentation instead of asking the user what you can discover. If an investigation is still running, continue with unrelated frontier questions and hold dependent ones back.

Decisions are the user's job. Do not answer on their behalf, even when one option looks obvious. Challenge contradictions, weak assumptions, accidental scope, and needless complexity directly.

Do not implement or write durable documents until the user confirms the shared understanding or the calling skill asks for an update.
