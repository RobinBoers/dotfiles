---
name: interview
description: Interview the user relentlessly to expose assumptions and settle a plan, decision, or idea. Use when another skill needs a decision loop or the user wants to stress-test their thinking.
---

- Interview the user relentlessly until you reach shared understanding.

- Start with the outcome. What must be decided, and what is outside the discussion?

- Map as a decision tree. Record which decisions depend on others.

- Ask questions in rounds based on dependencies. The frontier consists of every unsettled decision whose prerequisites are settled (you can ask them *now* without guessing). Ask the whole frontier in one round.

- Never ask a question whose answer depends on another question in the same round.

- Rebuild the frontier after each round. New answers may add, remove, or invalidate branches.

- Stop when the frontier is empty and no important choice remains implicit.

- Do not pretend the whole tree is visible at the start. Discover it as answers expose new branches.

### Question format

```markdown
### Q1. <decision>

<focused question>

- **A:** <option>
- **B:** <option>
- **C:** <option>

**Recommendation:** <option and brief reason>
```

Omit options when the question is open-ended. Keep question numbers stable so the user can answer by reference.

State the decision plainly. Explain only the constraint or trade-off needed to answer it. Always give your recommended answer and why.

## Divide the work correctly

Facts are your job. Dispatch sub-agents to inspect environment, code, files, tools, history, and documentation instead of asking the user. Non-blocking: exploration is an unsettled prerequisite, continue with unrelated frontier questions and hold dependent ones back.

Decisions are the user's job. Do not answer on their behalf, even when one option looks obvious. Challenge contradictions, weak assumptions, accidental scope, and needless complexity directly.

Do not act on decisions or write any durable files until the user confirms shared understanding.
