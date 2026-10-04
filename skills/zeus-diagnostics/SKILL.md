---
name: zeus-diagnostics
description: Diagnose OpenCode config, agent, skill, command, and plugin discovery problems. Use when something is not loading, the winning source is unclear, or the user asks what OpenCode is actually using.
---

# OpenCode diagnostics

Use evidence, not guesses. Prefer runtime inspection and current schema/docs
over remembered configuration snippets.

## Workflow

1. Identify the OpenCode version and active workspace.
2. Inspect relevant global/project/explicit config sources.
3. Inventory the relevant agents, skills, commands or plugins.
4. Find duplicate IDs and higher-precedence definitions.
5. Check permissions and current-format compatibility.
6. Explain the winning source and smallest useful fix.
7. Validate after any change.

Do not assume contributor-specific paths and never print credential values just
to prove that a source exists.

## Skill precedence

For duplicate skill IDs, precedence rises through:

1. built-in skills;
2. compatible `.claude/skills` sources;
3. compatible `.agents/skills` sources;
4. global OpenCode skills;
5. project `.opencode/skills` from project root toward the working directory;
6. explicit configured skill sources in configured order.

Later sources win for the same path-derived skill ID.

## Common checks

| Symptom | Check |
|---|---|
| Skill missing | ID, description/autoinvoke, permission, discovery root |
| Wrong skill loads | duplicate ID and source precedence |
| Agent missing | scope, file ID, mode/disabled state |
| Command differs | project override, agent/model/subagent fields |
| Plugin inactive | package/local discovery and plugin API version |
| Config ignored | scope, precedence, schema validity, runtime reload |
| Permission prompt | ordered global + agent permission rules |

For exact syntax, use the current OpenCode schema and V2 docs.
