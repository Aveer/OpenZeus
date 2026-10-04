---
name: zeus-agents
description: Design and review non-trivial OpenCode agents. Use for agent architecture, modes, model inheritance, permissions, subagent relationships, or migration beyond the basic native agent creator.
---

# OpenCode agent design

For a basic scaffold, prefer `opencode agent create`. Use this skill when the
design itself matters.

## Native V2 example

```markdown
---
description: Reviews changes for correctness and regressions
mode: subagent
permissions:
  - action: edit
    resource: "*"
    effect: deny
  - action: shell
    resource: "*"
    effect: deny
---

Review the current changes. Report findings in severity order.
```

Use ordered `permissions`. The last matching rule wins.

Do not hard-code a model by default; subagents can inherit the parent session
model. Use a model override only for a real capability/cost/latency reason.

Do not generate legacy top-level `permission`, `tools`, `temperature`,
`top_p`, `prompt`, `disable`, or `maxSteps` fields in new V2 agents.

For legacy agents, use `zeus-migration`.
