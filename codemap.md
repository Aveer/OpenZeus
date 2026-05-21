# Repository Atlas: OpenZeus

## Project Responsibility

OpenZeus is a guided OpenCode setup, validation, and asset-generation product. It ships an OpenZeus agent, skill bundles, slash commands, and CLI utilities for profile-aware installs, repo setup plans, CI validation, command capture, context initialization, drift inspection, and safe upgrades.

## Entry Points

| File | Purpose |
|---|---|
| `agents/OpenZeus.md` | Main OpenZeus agent definition |
| `bin/openzeus` | Package CLI entrypoint |
| `scripts/install.sh` | Installs assets into OpenCode config |
| `scripts/sync-utils.sh` | Syncs repository assets with config assets |
| `scripts/create-utils.sh` | Generates agents, skills, and commands |
| `scripts/doctor.sh` | Audits setup and reports fix plans |
| `scripts/setup.sh` | Plans/applies repo-local setup and context files |
| `scripts/validate.sh` | Validates package/config/project assets, including CI mode |
| `scripts/capture-command.sh` | Creates slash commands from prompt text |
| `scripts/diff.sh` | Reports profile-aware package/config drift |
| `scripts/upgrade.sh` | Backs up, upgrades, and rolls back local config assets |
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
  → setup plan / validate / capture / context / diff workflow
  → dry-run, --plan, --ci, or --summary before writes
  → install, upgrade, rollback, or sync when explicitly needed
```

## CLI Surface

| Command | Purpose | Safe behavior |
|---|---|---|
| `openzeus setup --plan|--apply [--recipe node|python|docs|beads|solo-dev] [--target DIR] [--dry-run] [--force]` | Plan or create repo-local `.opencode/` assets | `--plan` previews; `--dry-run` previews writes; `--force` required for replacement |
| `openzeus validate [--ci] [--project DIR]` | Validate package/config or project assets | `--ci` exits non-zero on failures or drift warnings |
| `openzeus capture-command --name NAME --prompt TEXT [--target DIR] [--dry-run] [--force]` | Generate a slash command from a prompt | Dry-run preview; skips existing files unless forced |
| `openzeus recipes` | List setup recipes | Read-only |
| `openzeus context init [--target DIR] [--dry-run] [--force]` | Create project context notes | Dry-run preview; skips existing files unless forced |
| `openzeus doctor --fix-plan|--ci` | Audit OpenCode setup | Prints planned fixes; CI mode fails on warnings/failures |
| `openzeus diff [--summary] [--ci]` | Report package/config drift | Profile-aware; CI mode fails on drift |
| `openzeus upgrade --dry-run|--apply` | Backup and refresh installed config assets | Preserves saved install profile |
| `openzeus rollback --dry-run|--apply` | Restore latest local config backup | Preview before restoring |
| `openzeus status` | Show installed assets and sync state | Inspection-first |
| `openzeus list [agents|skills|commands|all]` | List available assets | Read-only |
| `openzeus examples` | Show starter workflows | Read-only |
| `openzeus init-project [--target DIR] [--dry-run] [--force]` | Create repo-local `.opencode/` assets | Dry-run preview; `--force` for overwrites |
| `openzeus create ...` | Generate agents, skills, or commands | Uses asset templates and sync guidance |
| `openzeus sync ...` | Repo ↔ config sync | Status/auto prefer conflict refusal over guessing |
| `openzeus install --core|--extras|--all` | Install packaged assets by profile | Agent/helpers always installed; skills/commands filtered by profile |
| `openzeus hooks` | Install git sync hooks | Hooks warn/check before mutating push flow |

## Development Patterns

- Markdown-based OpenCode assets.
- Repository source of truth, synced into OpenCode config.
- Guided CLI workflows: install profile, setup plan/apply, validate, capture-command, context init, doctor, diff, upgrade, rollback.
- Minimal permissions and explicit confirmation for remote/destructive operations.
- Concise, example-driven docs.
