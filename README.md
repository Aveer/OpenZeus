# OpenZeus

**Guided OpenCode setup, validation, and asset generation.**

OpenZeus helps you make an OpenCode workspace useful fast: plan repo setup, install profile-aware assets, validate config, capture commands from prompts, and upgrade safely with local backups.

![OpenZeus](./media/OpenZeus.png)

## What OpenZeus is useful for

- **Plan setup**: preview repo-local `.opencode/` assets before writing.
- **Install profiles**: install `core`, `extras`, or `all` OpenZeus assets.
- **Validate CI**: fail fast on package, project, or config drift problems.
- **Create assets**: generate OpenCode agents, skills, and commands safely.
- **Capture commands**: turn repeatable prompts into slash commands.
- **Upgrade safely**: back up local config and preserve the active install profile.

## Installation

### NPM

```bash
npm install -g openzeus
openzeus install --all
```

### Manual

```bash
git clone https://github.com/Aveer/OpenZeus.git
cd OpenZeus
./scripts/install.sh --all
```

The installer copies assets into `${OPENCODE_CONFIG_DIR:-~/.config/opencode}`.

## 30-second golden path

```bash
npm install -g openzeus
openzeus install --core           # agent + helpers + core skills/commands
openzeus setup --plan             # preview repo-local .opencode setup
openzeus setup --apply --target . # write starter assets
openzeus validate --ci            # CI-friendly package/config validation
openzeus diff --summary           # count config drift issues
```

For a stack-specific setup:

```bash
openzeus recipes
openzeus setup --plan --recipe node --target .
openzeus setup --apply --recipe node --target .
```

## Common workflows

### Install profiles

```bash
openzeus install --core    # OpenZeus agent, helpers, core skills/commands
openzeus install --extras  # non-core skills/commands plus agent/helpers
openzeus install --all     # everything
```

The agent and helper scripts are always installed. Skills and commands are filtered by profile. `doctor`, `diff`, and `upgrade` use the saved `.openzeus-install-profile` so profile-filtered assets are not reported as missing.

### Plan and apply project setup

```bash
openzeus recipes
openzeus setup --plan --recipe python --target .
openzeus setup --apply --recipe python --target .
```

Recipes: `node`, `python`, `docs`, `beads`, `solo-dev`. Add `--dry-run` to preview writes and `--force` to replace existing starter files.

### Validate and inspect drift

```bash
openzeus validate --ci
openzeus validate --ci --project .
openzeus doctor --ci
openzeus diff --summary --ci
```

`--ci` exits non-zero on validation failures or drift warnings.

### Capture a slash command

```bash
openzeus capture-command \
  --name release-notes \
  --prompt 'Draft release notes from $ARGUMENTS' \
  --target .opencode \
  --dry-run
```

Remove `--dry-run` to write `.opencode/commands/release-notes.md`. Use `--force` to overwrite.

### Initialize project context

```bash
openzeus context init --target . --dry-run
openzeus context init --target .
```

Writes `.opencode/context/{architecture.md,commands.md,testing.md}` with detected stack, test, and build notes.

### Upgrade or rollback local config

```bash
openzeus upgrade --dry-run
openzeus upgrade --apply
openzeus rollback --dry-run
openzeus rollback --apply
```

Upgrade creates a local backup under the OpenCode config directory, then reinstalls using the saved install profile.

### Create agents, skills, and commands

The original OpenZeus idea is still first-class: it can create OpenCode assets directly, with valid frontmatter, no-overwrite defaults, `--dry-run`, and `--force` when you intentionally want replacement.

```bash
openzeus create agent reviewer "Reviews pull requests for correctness and maintainability"
openzeus create skill project-workflow "Use when following this repo's release workflow"
openzeus create command release-notes "Draft release notes" 'Use $ARGUMENTS to choose the release range.'
```

| Asset | Output |
|---|---|
| Agent | Markdown agent with current `description`, `mode`, and conservative `permission` frontmatter |
| Skill | `SKILL.md` bundle with required `name` and `description` frontmatter |
| Command | Slash command Markdown with frontmatter and `$ARGUMENTS`-ready prompt body |

Related generators:

```bash
openzeus capture-command --name triage --prompt 'Triage $ARGUMENTS and propose next steps' --target .opencode
openzeus setup --plan --target .
openzeus setup --apply --target .
```

### Sync safely

```bash
openzeus sync status
openzeus sync auto     # safe one-way sync or conflict refusal
```

## Use OpenZeus in OpenCode

Ask for outcomes, not file names:

```bash
@OpenZeus audit my OpenCode setup and explain what to fix
@OpenZeus plan setup for this repo, then apply it after I review
@OpenZeus turn this release process into a slash command
@OpenZeus validate this project for CI
```

### Use commands

```bash
/zeus-git-commit      # Draft and create a local commit; push only when authorized
/zeus-kanban          # Manage docs/team/KANBAN.md
/zeus-roadmap         # Manage docs/team/ROADMAP.md
/zeus-improve-project # Structured project improvement cycle
```

## Zeus Skills

OpenZeus currently ships **15** Zeus skills. Install the focused product surface with `openzeus install --core`, or install every skill with `openzeus install --all`.

| Skill | Purpose |
|---|---|
| `zeus-core` | OpenCode config, paths, permissions, docs, and troubleshooting reference |
| `zeus-agents` | Design and create OpenCode agents with current modes and permissions |
| `zeus-commands` | Create reusable slash commands and prompt templates |
| `zeus-skills` | Canonical guide for writing OpenCode skills |
| `zeus-upskill` | Add/register new `zeus-*` capabilities into OpenZeus |
| `zeus-context` | Context management, session handoff, and repo knowledge workflows |
| `zeus-self` | Runtime self-diagnostics and OpenZeus operational awareness |
| `zeus-beads` | Beads issue-tracking workflows and command reference |
| `zeus-swarm` | opencode-swarm workflows and multi-agent orchestration |
| `zeus-oac` | OpenAgentsControl reference and plan-first workflows |
| `zeus-omo` | oh-my-opencode-slim reference and tmux/provider workflows |
| `zeus-docker` | Docker and containerization reference |
| `zeus-sql` | SQL/database patterns and query guidance |
| `zeus-llm` | Local LLM tooling: llama.cpp, llama-swap, Ollama |
| `zeus-boston-terrier` | Fun/example skill for Boston Terrier knowledge |

Example routing:

```bash
@OpenZeus create a new agent for SQL reviews
# loads zeus-agents + zeus-core

@OpenZeus help me containerize this service
# loads zeus-docker when available
```

## Development

### Test local package install

```bash
npm pack
npm install -g ./openzeus-1.1.0.tgz
openzeus help
```

### Validate changes

```bash
npm test
openzeus validate --ci
openzeus doctor --ci
openzeus diff --summary --ci
./scripts/sync-utils.sh status
```

### Project folders

| Folder | Purpose |
|---|---|
| `agents/` | OpenCode agent definitions |
| `commands/` | Slash command templates |
| `skills/` | Zeus skill bundles |
| `scripts/` | Install, sync, creation, and hook utilities |
| `docs/` | Contributor, release, and package docs |

## Troubleshooting

| Issue | Try |
|---|---|
| `OpenZeus` not available | Run `npm install -g openzeus && openzeus install --core`, then restart OpenCode. |
| Skills not found | Check `${OPENCODE_CONFIG_DIR:-~/.config/opencode}/skills/`. |
| Commands not found | Check `${OPENCODE_CONFIG_DIR:-~/.config/opencode}/commands/`. |
| Config path differs | Set `OPENCODE_CONFIG_DIR` before installing/syncing. |
| CI fails on drift | Run `openzeus diff --summary` and `openzeus doctor --fix-plan`. |

## Version

Current package version: **1.1.0**.

## Links

- Repository: https://github.com/Aveer/OpenZeus
- Issues: https://github.com/Aveer/OpenZeus/issues
- OpenCode Docs: https://opencode.ai/docs/
- NPM Package: https://npmjs.com/package/openzeus

---

**🏛️ Welcome to the realm of OpenZeus!**
