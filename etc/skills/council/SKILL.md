---
name: council
description: |
  Convene a structured council of five thinking-lens LLMs (Red Team, First Principles, Expansionist, Outsider, Executor) to pressure-test high-stakes decisions, with anonymised peer review, forced debate on consensus, and dual-chairman synthesis with dissent preservation. Use when the user indicates doubt on an important decision (e.g. "I'm torn between X and Y", "this is a big decision", "help me think this through from multiple angles", "I need outside perspectives", "should I X or Y").
allowed-tools: Read, Write, Glob, Grep, Bash, Agent, AskUserQuestion
---

Run any high-stakes decision through five structured thinking lenses, a peer-review round, a forced debate when consensus is too clean, and a dual-chairman synthesis that preserves dissent.

**Not for:** factual lookups, debugging, single-domain technical questions, quick yes/no decisions, emotional support. If none of the options feel genuinely hard, just answer directly.

## 1. Triage

Reject and answer directly if ANY applies:

1. Factual / one right answer ("capital of France?")
2. Single-domain technical (a competent practitioner tweets it)
3. No stakes are named: ask once via AskUserQuestion "What makes this high-stakes?". If shrugs, drop it.
4. Binary question with an obvious answer ("ship untested code to prod Friday?")
5. Already decided and seeking validation. Ask: challenge or confirm? If confirm, drop it.
6. Emotional-support framing. Say so kindly, don't council it.

## 2. Frame the question + bias audit

### 2a. Workspace scan

Search for `CLAUDE.md`, `.claude/*.md`, and any user-referenced files. Cap at 3 files chosen by recency, and always give `CLAUDE.md` precedence. Cap the framed question at ~4k tokens. If context is truncated, say so in `CONTEXT`. If no project files are found, use: "No project context found; council proceeds with user-provided context only."

If question is vague, use AskUserQuestion **once** to clarify. Then produce `FRAMED_QUESTION`:

```
DECISION: <core question>
CONTEXT: <workspace + user context>
STAKES: <what's at stake>
OPTIONS: <options named by user, if any>
```

### 2b. Bias audit

Skip this in Quick mode. In Standard and Deep modes, make one `Agent()` call using the prompt in @references/bias-audit.md.

Receives back a structured bias-flags list. Append to framed question as:
 
```
BIAS FLAGS: <list: these are signals, not verdicts>
```

If the bias audit returns "BIAS AUDIT: Clean, no significant distortions detected.", omit the `BIAS FLAGS:` section from the framed question entirely.

## 3. Mode selection

Read @references/modes.md for full escalation logic. Summary:

| Mode     | When                                                     | ~Calls       |
| -------- | -------------------------------------------------------- | ------------ |
| Quick    | "quick" suffix / stakes < $1k / ≤ 1-day reversible       | 4            |
| Standard | default                                                  | 14–16        |
| Deep     | "deep" / high stakes / auto-escalate from low confidence | 16           |

## 4. Fan-out (parallel Agent calls)

Read @references/personas.md for all five persona prompts. Dispatch in a **single turn**:

- **Quick:** 3 advisors (Red Team, Executor, First Principles)

- **Standard/Deep:** 5 parallel `Agent(subagent_type="general-purpose", description="<persona>", prompt=<persona_prompt with FRAMED_QUESTION substituted>)` calls

**Deep mode enhancement:** For Deep mode, append to First Principles and Expansionist prompts: "Return ALL three reframings/options with full reasoning for each, not just the strongest + runner-up."

Every persona prompt mandates this appendix at the end of the response:
```
=== CONFIDENCE ===
confidence: high | medium | low
assumptions: <bulleted premises>
what_would_change_my_mind: <1-3 signals>
unknowns: <missing facts>
```

## 5. Anonymize + peer review + forced debate (Standard/Deep only)

Quick mode skips this section.

### 5a. Anonymize

1. Generate a random A–E permutation and retain the mapping until synthesis.
2. Strip each response's first line if it contains a self-identification.
3. **Structural sanitisation**: regex-replace persona-signature patterns that leak identity through anonymised text:
   - `THE FAILURE MODE` / `THE ROOT CAUSE` / `THE MISSED SIGNAL` / `THE ALTERNATIVE` → `POINT 1` / `POINT 2` / `POINT 3` / `POINT 4`
   - `REFRAMING [ABC]` → `PERSPECTIVE [1/2/3]`; `STRONGEST:` / `RUNNER-UP:` → `PRIMARY:` / `SECONDARY:`
   - `OPTION [XYZ]` → `ALTERNATIVE [1/2/3]`; `DOMINANT:` → `RECOMMENDED:`
   - `FIELD:` / `NAIVE READ:` / `BUBBLE SPOTS:` / `CROSS-DOMAIN INSIGHT:` → `LENS:` / `INITIAL READ:` / `ASSUMPTIONS:` / `INSIGHT:`
   - `OODA STAGE` → `PHASE ASSESSMENT`; `RICE SCORING` / `RICE Score` → `PRIORITY SCORING` / `Priority Score`; `STATUS: DRAFT` → `NOTE: INCOMPLETE DATA`
4. Preserve `=== CONFIDENCE ===` blocks unchanged (all personas share this format).

## 5b. Peer review (Standard/Deep)

Read @references/peer-review.md for the full reviewer prompt. Dispatch 5 parallel `Agent()` calls, each receiving all anonymized A–E responses plus the reviewer prompt.

**Score extraction:** Each reviewer's Q4 answer must be a single integer 1–5. Extract using regex: `CONSENSUS STRENGTH:\s*(\d)` (case-insensitive). If a reviewer outputs a non-integer or out-of-range value, default to 3 (neutral). Compute the arithmetic mean of all 5 extracted scores, rounded to one decimal.

**Consensus summary synthesis:** After collecting peer reviews, produce a 2-3 sentence `CONSENSUS_SUMMARY` capturing: (a) what the majority of advisors recommend, (b) the dominant reasoning, (c) any conditions or caveats shared across reviews. Store as the variable `$CONSENSUS_SUMMARY`: this is substituted into the Prosecutor and Defender prompts in @references/debate-round.md.

### 5c. Forced debate

If consensus-strength average ≥ 4.0 (or always in Deep), run two **sequential** `Agent()` calls using @references/debate-round.md. Otherwise skip debate.

1. Prosecutor: attacks the consensus. Wait for response.
2. Defender: substitutes `{{PROSECUTOR_RESPONSE}}` with the Prosecutor's output, then dispatches. Defender cannot run until Prosecutor returns.

Read @references/debate-round.md for full prompts.

## 6. Synthesis

Read @references/chairman.md.

**Quick:** make one `Agent()` call using the Quick chairman prompt and the three available advisor responses. Return its verdict directly.

**Standard/Deep:** de-anonymize the responses using the mapping from Step 5a. Give the chairmen the original responses, not the sanitised peer-review versions. Make three `Agent()` calls in two waves:

1. In parallel, run **Chairman-consensus** and **Chairman-dissent**.
2. After both return, run the **Dissent preservation pass**.

Final verdict = Chairman-Consensus output + Dissent Ledger appended.

The Standard/Deep verdict must begin with:
```
Council confidence: high | medium | low  (n/5 high, n/5 medium, n/5 low)
Dominant assumption: <single shared premise>
Breakers: <top 2 signals that flip the recommendation>
```

**Escalation check (Standard mode only: Deep does not re-escalate):**

Trigger escalation if ANY of:
- `chairman_confidence` is `low`
- 3 or more advisors output `confidence: low`
- "Where the council clashes" section has ≥2 items where neither side was found "more persuasive"

If triggered: `AskUserQuestion` "Council confidence is low (reason: {which trigger}). Escalate to Deep mode for a more thorough analysis?"

- If yes: re-run from Step 4 in Deep mode, passing prior advisor outputs as context so advisors refine rather than restart.
- If no: proceed with the Standard verdict and state the low confidence prominently.
- If mode is already Deep: do not re-escalate. Proceed with low-confidence verdict and note it prominently.

## 7. Final verdict

Run `mkdir -p .claude/council`, then write a markdown file to `.claude/council/YYYY-MM-DD-SLUG.md` containing the invocation timestamp, framed question, anonymization map, all advisor responses with persona names, all peer reviews, debate transcript if run, both chairman outputs, dissent ledger, and full verdict.

Return the final verdict in chat and state the report path.
