# scripts/ — Runtime Management Module

## Responsibility

The `scripts/` directory powers the product-facing OpenZeus CLI. It installs packaged OpenCode assets, audits setup health, initializes project-local `.opencode/` assets, creates agents/skills/commands, syncs repo/config state, and installs optional git hooks.

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
| `setup-hooks.sh` | Optional git hooks for post-merge sync and pre-push drift warning |

## User-Facing CLI

`bin/openzeus` wraps the scripts with outcome-oriented commands:

| Command | Behavior |
|---|---|
| `openzeus doctor [--fix-plan]` | Validate package assets and print concrete fixes without mutation |
| `openzeus status` | Show package root, config root, installed asset counts, and drift summary |
| `openzeus list [agents|skills|commands|all]` | List package assets with `[installed]`, `[missing]`, or `[different]` status |
| `openzeus examples` | Print copy-pasteable starter workflows |
| `openzeus init-project [--target DIR] [--dry-run] [--force]` | Create repo-local `.opencode/` starter files safely |
| `openzeus install [--dry-run] [--force] [--backup] [--target DIR]` | Install OpenZeus global assets |
| `openzeus sync status|push|pull|auto` | Compare or copy repo/config OpenZeus assets |
| `openzeus create agent|skill|command ...` | Generate valid OpenCode Markdown assets |
| `openzeus hooks [--dry-run] [--force]` | Install optional git hooks |

## Safety Defaults

- `install.sh` and `sync-utils.sh` skip conflicting destination files unless `--force` is supplied.
- `--backup` preserves overwritten files/directories with timestamped `.bak.*` names.
- `init-project.sh` skips existing starter files unless `--force` is supplied.
- `doctor.sh --fix-plan` and `openzeus status/list/examples` never mutate files.
- `sync-utils.sh auto` only syncs when direction is unambiguous; mixed or conflicting changes are refused.
- Git `pre-push` hook runs sync status only; it does not mutate or push Beads/Git state.

## Asset Scope

OpenZeus intentionally manages only its own package assets:

| Asset type | Managed pattern |
|---|---|
| Agent | `agents/OpenZeus.md` |
| Skills | `skills/zeus-*` |
| Commands | `commands/zeus-*.md` |
| Helpers | `sync-utils.sh`, `create-utils.sh`, `setup-hooks.sh`, `doctor.sh`, `init-project.sh` |

This namespace boundary protects unrelated user agents, skills, and commands.

## Project Initialization Output

`openzeus init-project` writes starter project-local assets under `<target>/.opencode/`:

```text
.opencode/
├── README.md
├── agents/project-guide.md
├── commands/build.md
├── commands/test.md
└── skills/project-context/SKILL.md
```

The generated files use current OpenCode conventions: Markdown frontmatter, `mode: subagent` for the starter agent, conservative `permission` defaults, command templates using `$ARGUMENTS`, and skill `name`/`description` frontmatter.

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
npm pack --dry-run
git diff --check
```

`tests/run.sh` performs per-script Bash syntax checks, fixture installs/syncs, create-template checks, doctor/status/list/examples smoke tests, init-project overwrite tests, and CLI symlink resolution checks.
