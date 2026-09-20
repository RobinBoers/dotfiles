---
name: stage
description: Stage the changes made in the current session
disable-model-invocation: true
allowed-tools: Bash(git *)
---

```!
git status
git diff --name-only --cached
```

## What to do?

1. Cross-reference the status above against files you changed in this session.
2. Stage any session files not yet staged. Leave everything else alone.
3. If staged files exist that you didn't touch this session, flag them explicitly and ask whether to include.
