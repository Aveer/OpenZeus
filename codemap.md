# Repository Atlas: OpenZeus

## Project Responsibility

OpenZeus is an OpenCode asset pack: agent definitions, slash commands, skill bundles, and install/sync utilities for OpenCode configuration workflows.

## Entry Points

| File | Purpose |
|---|---|
| `agents/OpenZeus.md` | Main OpenZeus agent definition |
| `bin/openzeus` | Package CLI entrypoint |
| `scripts/install.sh` | Installs assets into OpenCode config |
| `scripts/sync-utils.sh` | Syncs repository assets with config assets |
| `README.md` | User-facing install and usage guide |
| `package.json` | NPM package metadata, version, and test script |

## Directory Map

| Directory | Responsibility | Detailed Map |
|---|---|---|
| `agents/` | Agent Markdown definitions | [agents/codemap.md](agents/codemap.md) |
| `commands/` | Slash command Markdown templates | [commands/codemap.md](commands/codemap.md) |
| `skills/` | Zeus skill bundles | [skills/codemap.md](skills/codemap.md) |
| `scripts/` | Install/sync/create/hook shell utilities | [scripts/codemap.md](scripts/codemap.md) |
| `docs/` | Contributor and publishing docs | — |

## OpenCode Discovery Facts

| Asset | Global location | Project location |
|---|---|---|
| Agents | `${OPENCODE_CONFIG_DIR:-~/.config/opencode}/agents/` | `<repo>/.opencode/agents/` |
| Commands | `${OPENCODE_CONFIG_DIR:-~/.config/opencode}/commands/` | `<repo>/.opencode/commands/` |
| Skills | `${OPENCODE_CONFIG_DIR:-~/.config/opencode}/skills/` | `<repo>/.opencode/skills/` |

Additional skill discovery locations used by compatible tooling may include `<repo>/.claude/skills/` and `<repo>/.agents/skills/`.

Keep `opencode.json` and `tui.json` separate: `opencode.json` stores runtime configuration; `tui.json` stores TUI state/preferences.

## OpenCode Asset Conventions

| Asset | Convention |
|---|---|
| Agent modes | `primary`, `subagent`, `all` |
| Agents | Markdown with frontmatter and system prompt body |
| Commands | Markdown with frontmatter, workflow, and supported placeholders |
| Skills | `skills/<name>/SKILL.md` with `name` and `description` frontmatter |

## Data Flow

```text
User request
  → OpenZeus agent
  → optional skill loading
  → command/agent/skill/config operation
  → install or sync when needed
```

## Development Patterns

- Markdown-based OpenCode assets.
- Repository source of truth, synced into OpenCode config.
- Minimal permissions and explicit confirmation for remote/destructive operations.
- Concise, example-driven docs.
