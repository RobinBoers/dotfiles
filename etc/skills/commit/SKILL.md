---
name: commit
description: Draft commit message for current session
disable-model-invocation: true
allowed-tools: Bash(git *)
---

Draft a commit message for the work done in this session, ask for approval, then commit.

## What to do?

1. Use /stage to stage this session's changes.
2. Run `git diff --cached` to read the full diff, then draft a commit message.
3. Show the message and the file list. Ask for approval.
4. On approval, commit. On rejection, revise and ask again.

If nothing was staged and nothing was touched this session, exit with "Nothing to commit."

# Guidelines for commit message format

- Subject line
  - Start with a present-tense verb (Add, Fix, Update, Refactor, Remove)
  - Capitalize the first letter
  - Do not end with a period
  - Keep it short (under ~50 chars)
  - NO conventional commit prefixes (`feat:``, `fix:`, `chore:`, `docs:`, etc.)

- Body
  - Provide concise, high-information summary of essential details
  - Explain the "why" behind the change, not just the "how"
  - Keep terse and to the point
  - Separate from subject with blank line
  - Wrap at 72 characters
  - Crucially, omit the body for trivial commit messages.

- Footer (optional)
  - Reference GitHub/ClickUp/Sentry issues on new line after body
  - Use `Fixes #123` if commit resolves the issue
  - Use `See #456` if commit relates to but doesn't resolve issue
