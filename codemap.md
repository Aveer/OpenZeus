# Repository Atlas: OpenZeus

## Project Responsibility

OpenZeus is a guided OpenCode setup, audit, and asset-generation product. It ships an OpenZeus agent, skill bundles, slash commands, and CLI utilities for initializing repo-local assets, auditing configuration, creating agents/skills/commands, and syncing safely.

## Entry Points

| File | Purpose |
|---|---|
| `agents/OpenZeus.md` | Main OpenZeus agent definition |
| `bin/openzeus` | Package CLI entrypoint |
| `scripts/install.sh` | Installs assets into OpenCode config |
| `scripts/sync-utils.sh` | Syncs repository assets with config assets |
| `scripts/create-utils.sh` | Generates agents, skills, and commands |
| `scripts/doctor.sh` | Audits setup and reports fix plans |
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
  → audit / init / create / sync workflow
  → dry-run or fix-plan before risky writes
  → install or sync when explicitly needed
```

## CLI Surface

| Command | Purpose | Safe behavior |
|---|---|---|
| `openzeus doctor --fix-plan` | Audit OpenCode setup | Prints planned fixes without applying them |
| `openzeus status` | Show installed assets and sync state | Inspection-first |
| `openzeus list [agents|skills|commands|all]` | List available assets | Read-only |
| `openzeus examples` | Show starter workflows | Read-only |
| `openzeus init-project [--target DIR] [--dry-run] [--force]` | Create repo-local `.opencode/` assets | Dry-run preview; `--force` for overwrites |
| `openzeus create ...` | Generate agents, skills, or commands | Uses asset templates and sync guidance |
| `openzeus sync ...` | Repo ↔ config sync | Status/auto prefer conflict refusal over guessing |
| `openzeus install` | Install packaged assets | Copies assets into OpenCode config |
| `openzeus hooks` | Install git sync hooks | Hooks warn/check before mutating push flow |

## Development Patterns

- Markdown-based OpenCode assets.
- Repository source of truth, synced into OpenCode config.
- Guided CLI workflows: audit, status, list, examples, init, create, sync.
- Minimal permissions and explicit confirmation for remote/destructive operations.
- Concise, example-driven docs.
