# commands/ — OpenCode Slash Commands

## Responsibility

`commands/` contains Markdown slash command templates for OpenCode. Commands bind a reusable workflow to a slash command name such as `/zeus-git-commit`.

## Command Pattern

```markdown
---
description: Human-readable description
agent: OpenZeus
---

# Command Name

Workflow instructions.

**User's input**: $ARGUMENTS
```

## Supported Syntax

| Syntax | Purpose | Example |
|---|---|---|
| `$ARGUMENTS` | Full user input after the command | `**User's input**: $ARGUMENTS` |
| `$1`, `$2` | Positional arguments | `$1` = first arg, `$2` = second arg |
| Shell injection | Inline shell output in command context when supported by OpenCode | Use for read-only context gathering, not secrets |
| `@file` | Reference file contents in user input/context | `/cmd review @README.md` |

Prefer `$ARGUMENTS` for free-form prompts and `$1/$2` for strict command shapes.

## Discovery Paths

| Scope | Commands path |
|---|---|
| Global | `${OPENCODE_CONFIG_DIR:-~/.config/opencode}/commands/` |
| Project | `<repo>/.opencode/commands/` |
| Source package | `<OpenZeus-repo>/commands/` |

## Command Inventory

| Command | File | Purpose | Safety |
|---|---|---|---|
| `/zeus-git-commit` | `zeus-git-commit.md` | Draft and create a local commit | High: no auto-push |
| `/zeus-kanban` | `zeus-kanban.md` | Manage `docs/team/KANBAN.md` | Low |
| `/zeus-roadmap` | `zeus-roadmap.md` | Manage `docs/team/ROADMAP.md` | Low |
| `/zeus-improve-project` | `zeus-improve-project.md` | Structured improvement workflow | Medium |

## Git Command Safety

`/zeus-git-commit` follows a local-first protocol:

```text
inspect diff → scan for unsafe files → show commit plan → commit locally → push only if explicitly authorized
```

`--quick` may shorten output, but it must not push.

## Integration Flow

```text
User invokes /zeus-command args
  → OpenCode loads command Markdown
  → placeholders are resolved
  → configured agent executes workflow
```

## File Manifest

| File | Purpose |
|---|---|
| `zeus-git-commit.md` | Safe local commit helper |
| `zeus-kanban.md` | Kanban board command |
| `zeus-roadmap.md` | Roadmap command |
| `zeus-improve-project.md` | Project improvement command |
| `codemap.md` | This map |
