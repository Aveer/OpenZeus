# scripts/ — Runtime Management Module

## Responsibility

The `scripts/` directory powers the product-facing OpenZeus CLI. It installs profile-aware OpenCode assets, plans/applies project setup, validates package/config/project assets, captures commands from prompts, initializes context files, compares repo/config drift, and upgrades or rolls back local config safely.

OpenZeus scripts prefer **plan-before-mutation** behavior: inspect first, preview when possible, skip overwrites by default, and require `--force` for replacement.

## Entry Points

| File | Role |
|---|---|
| `../bin/openzeus` | User-facing command dispatcher |
| `install.sh` | Safe install into `${OPENCODE_CONFIG_DIR:-~/.config/opencode}` or `--target DIR` |
| `sync-utils.sh` | Manifest-limited repo/config compare and sync |
| `create-utils.sh` | Generate OpenCode agents, skills, and commands |
| `doctor.sh` | Non-mutating package/config health checks and `--fix-plan` guidance |
| `init-project.sh` | Safe project-local `.opencode/` starter generator |
| `setup.sh` | `setup --plan|--apply`, `recipes`, and `context init` workflows |
| `validate.sh` | Package, config, and project asset validation with `--ci` mode |
| `capture-command.sh` | Prompt-to-command Markdown generator |
| `diff.sh` | Profile-aware package/config drift report with `--summary` and `--ci` |
| `upgrade.sh` | Profile-preserving local config backup, upgrade, and rollback |
| `setup-hooks.sh` | Optional git hooks for post-merge sync and pre-push drift warning |

## User-Facing CLI

`bin/openzeus` wraps the scripts with outcome-oriented commands:

| Command | Behavior |
|---|---|
| `openzeus setup --plan|--apply [--recipe node|python|docs|beads|solo-dev] [--target DIR] [--dry-run] [--force]` | Plan or write repo-local `.opencode/` starter assets and context files |
| `openzeus validate [--ci] [--project DIR]` | Validate package/config or project assets; CI mode exits non-zero on failures/drift |
| `openzeus capture-command --name NAME --prompt TEXT [--target DIR] [--dry-run] [--force]` | Generate `<target>/commands/NAME.md` from prompt text |
| `openzeus recipes` | List supported setup recipes |
| `openzeus context init [--target DIR] [--dry-run] [--force]` | Write `.opencode/context/{architecture.md,commands.md,testing.md}` |
| `openzeus doctor [--fix-plan] [--ci]` | Validate package assets, detect profile-aware config/install drift, and optionally fail CI |
| `openzeus diff [--summary] [--ci]` | Show package/config drift; summary mode prints issue count |
| `openzeus upgrade --dry-run|--apply` | Back up managed config assets, then reinstall with the saved profile |
| `openzeus rollback --dry-run|--apply` | Restore the latest OpenZeus config backup |
| `openzeus status` | Show package root, config root, installed asset counts, and drift summary |
| `openzeus list [agents|skills|commands|all]` | List package assets with `[installed]`, `[missing]`, or `[different]` status |
| `openzeus examples` | Print copy-pasteable starter workflows |
| `openzeus init-project [--target DIR] [--dry-run] [--force]` | Create repo-local `.opencode/` starter files safely |
| `openzeus install [--dry-run] [--force] [--backup] [--core|--extras|--all] [--target DIR]` | Install OpenZeus global assets by profile |
| `openzeus sync status|push|pull|auto` | Compare or copy repo/config OpenZeus assets |
| `openzeus create agent|skill|command ...` | Generate valid OpenCode Markdown assets |
| `openzeus hooks [--dry-run] [--force]` | Install optional git hooks |

## Safety Defaults

- `install.sh` and `sync-utils.sh` skip conflicting destination files unless `--force` is supplied.
- `--backup` preserves overwritten files/directories with timestamped `.bak.*` names.
- `install.sh` always installs `agents/OpenZeus.md` and helper scripts. `--core`, `--extras`, and `--all` filter only `skills/zeus-*` and `commands/zeus-*.md`.
- `install.sh` writes `.openzeus-install-profile`; `doctor.sh`, `diff.sh`, and `upgrade.sh` respect it.
- `init-project.sh` skips existing starter files unless `--force` is supplied.
- `setup.sh --plan`, `doctor.sh --fix-plan`, `openzeus recipes`, `openzeus status/list/examples`, and `diff.sh` never mutate files.
- `validate.sh --ci`, `doctor.sh --ci`, and `diff.sh --ci` use non-zero exits for automation.
- `capture-command.sh --dry-run` previews the destination and writes nothing; existing commands are skipped unless `--force` is supplied.
- `upgrade.sh --dry-run` and `rollback --dry-run` preview backup/restore actions. `--apply` is required to mutate config.
- `upgrade.sh --apply` creates a local backup under `.openzeus-backups` and reinstalls with the saved profile.
- `sync-utils.sh auto` only syncs when direction is unambiguous; mixed or conflicting changes are refused.
- Git `pre-push` hook runs sync status only; it does not mutate or push Beads/Git state.

## Asset Scope

OpenZeus intentionally manages only its own package assets:

| Asset type | Managed pattern |
|---|---|
| Agent | `agents/OpenZeus.md` |
| Skills | `skills/zeus-*` |
| Commands | `commands/zeus-*.md` |
| Helpers | `sync-utils.sh`, `create-utils.sh`, `setup-hooks.sh`, `doctor.sh`, `init-project.sh`, `setup.sh`, `validate.sh`, `capture-command.sh`, `diff.sh`, `upgrade.sh` |
| Install profile | `.openzeus-install-profile` |

This namespace boundary protects unrelated user agents, skills, and commands.

## Project Setup Output

`openzeus setup --apply` wraps `init-project`, recipe extras, and context initialization. It writes starter project-local assets under `<target>/.opencode/`:

```text
.opencode/
├── README.md
├── agents/project-guide.md
├── commands/build.md
├── commands/test.md
├── context/architecture.md
├── context/commands.md
├── context/testing.md
└── skills/project-context/SKILL.md
```

The generated files use current OpenCode conventions: Markdown frontmatter, `mode: subagent` for the starter agent, conservative `permission` defaults, command templates using `$ARGUMENTS`, and skill `name`/`description` frontmatter. `setup.sh` detects `package.json`, `Makefile`/`makefile`, and Python project files (`pyproject.toml`, `setup.cfg`, `setup.py`) to pre-fill likely commands such as `npm test`, `npm run build`, `make test`, `make build`, or `pytest` when available.

Recipes add focused command/context hints:

| Recipe | Adds |
|---|---|
| `node` | npm test/build defaults |
| `python` | pytest-first test notes |
| `docs` | docs review command |
| `beads` | Beads status command |
| `solo-dev` | lightweight session check |

## Sync Model

`sync-utils.sh` builds a manifest from the package repo and config directory, compares files byte-for-byte (`cmp`) and skill directories recursively (`diff -qr`), then reports:

- `OK <path>` — both sides match
- `DIFF <path>` — both sides exist but differ
- `MISSING config:<path>` — repo asset is not installed
- `MISSING repo:<path>` — config asset is not present in repo

`push` copies repo → config, `pull` copies config → repo, and `auto` chooses a safe one-way direction only when there are no ambiguous conflicts.

## Verification

Primary quality gate:

```bash
npm test
openzeus validate --ci
openzeus doctor --ci
openzeus diff --summary --ci
npm pack --dry-run
git diff --check
```

`tests/run.sh` performs per-script Bash syntax checks, fixture installs/syncs, create-template checks, doctor/status/list/examples smoke tests, init-project overwrite tests, and CLI symlink resolution checks.
