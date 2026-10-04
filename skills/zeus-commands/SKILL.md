---
name: zeus-commands
description: Design and review OpenCode slash commands. Use for repeatable prompt workflows, command arguments, safe shell expansion, agent selection, or command migration.
---

# OpenCode command design

Create a command only when a workflow benefits from a stable invocation.

```markdown
---
description: Audit changes
agent: general
subagent: true
---

Audit $ARGUMENTS for bugs and missing tests.
```

Use `$ARGUMENTS` for the complete input and `$1`, `$2`, ... for positional
arguments. In V2, `subagent` is native; `subtask` is deprecated.

Shell expansion uses `!`command``. It executes while the command is expanded,
outside the agent tool-permission flow, so never interpolate untrusted input.

Stored command text does not automatically turn `@path` into an attachment.
