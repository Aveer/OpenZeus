# agents/ — Agent Definitions

## Responsibility

`agents/` contains OpenCode agent Markdown files. Agents define persona, mode, model preferences, permissions, and behavioral rules.

## Current Agent Pattern

```markdown
---
description: Human-readable summary
mode: all              # primary | subagent | all
model: opencode/model
color: "#FFD700"
temperature: 0.1
steps: 100
permission:
  edit: allow
  webfetch: allow
  bash: ask
---

# Agent Name

System prompt...
```

## Mode Terms

| Mode | Meaning |
|---|---|
| `primary` | Main interactive agent |
| `subagent` | Delegated agent called by another agent/tool |
| `all` | Available in both primary and subagent contexts |

## Discovery Paths

| Scope | Agents path |
|---|---|
| Global | `${OPENCODE_CONFIG_DIR:-~/.config/opencode}/agents/` |
| Project | `<repo>/.opencode/agents/` |
| Source package | `<OpenZeus-repo>/agents/` |

Related config files:

- `opencode.json`: runtime config such as agents, providers, and permissions.
- `tui.json`: TUI state/preferences; do not document it as the main runtime config.

## Permission Pattern

- Grant the minimum needed permissions.
- Prefer `ask` for shell and risky operations.
- Do not document unrestricted bash as the default.
- Remote or destructive mutations require explicit user confirmation unless repo policy clearly authorizes them.

## OpenZeus Agent

`OpenZeus.md` is the main operator agent.

| Concern | Implementation |
|---|---|
| Mode | `all` |
| Steps | `100` |
| Routing | Loads Zeus skills for deeper domain guidance |
| Safety | Commit/push/publish/destructive actions gated by confirmation |

## Skill Integration

OpenZeus routes common intents to skills:

```text
config/permissions → zeus-core
create agent      → zeus-agents + zeus-core
create command    → zeus-commands + zeus-core
create skill      → zeus-skills + zeus-core
docker/sql/llm    → matching Zeus skill
```

## File Manifest

| File | Purpose |
|---|---|
| `OpenZeus.md` | Main OpenCode operator agent |
| `codemap.md` | This map |
