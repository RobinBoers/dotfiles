---
name: domain-modeling
description: Build and sharpen a project's domain model when terminology or relationships affect a design.
---

# Domain modeling

Clarify the model while designing. This skill doesn't just read the domain terminology, it edits it.

## During discussion

- Challenge a term when the user, docs, or code use it for different concepts.
- Replace vague or overloaded language with one precise term, but preserve established language when it is already clear.
- Test definitions with concrete normal cases, edge cases, and counterexamples.
- Check whether the code matches the stated relationships and invariants. Surface disagreements immediately.
- Separate domain concepts from implementation names and general programming terms.

Do not force domain-driven-design ceremony onto a problem that only needs clearer naming.

## Record terminology

When a durable definition will help later sessions, update `.claude/domain.md` immediately after it is settled. Create the file lazily.

Keep entries short:

```markdown
## <area>

**Order:** A confirmed request to supply items to one customer.
Avoid: purchase, transaction
```

Define what a concept is and how it differs from nearby concepts. Do not turn the file into a spec, implementation guide, or exhaustive dictionary. Use sections in the same file for multiple contexts unless separation is genuinely necessary.

## Record decisions rarely

Most decisions belong in the active plan. Offer a note under `.claude/decisions/<name>.md` only when all three are true:

1. Changing it later would be expensive.
2. A future reader would find it surprising without the reason.
3. Real alternatives were rejected for a meaningful trade-off.

Ask before creating one. Record the context, decision, and reason in a few paragraphs. Add alternatives or consequences only when they matter.
