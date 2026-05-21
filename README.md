# OpenZeus

**Guided OpenCode setup, audit, and asset generation.**

OpenZeus helps you make an OpenCode workspace useful fast: audit your config, initialize repo-local assets, generate agents/skills/commands, and sync safely between this repository and your OpenCode config.

![OpenZeus](./media/OpenZeus.png)

## What OpenZeus is useful for

- **Audit setup**: inspect installed agents, commands, skills, and config drift.
- **Initialize projects**: create repo-local `.opencode/` assets with dry-run previews.
- **Generate assets**: create agents, skills, and commands from focused prompts.
- **Sync safely**: compare repo ↔ config state before copying assets.
- **Learn by example**: list installed assets and copy starter workflows.

## Installation

### NPM

```bash
npm install -g openzeus
openzeus install
```

### Manual

```bash
git clone https://github.com/Aveer/OpenZeus.git
cd OpenZeus
./scripts/install.sh
```

The installer copies assets into `${OPENCODE_CONFIG_DIR:-~/.config/opencode}`.

## 30-second golden path

```bash
npm install -g openzeus
openzeus doctor --fix-plan        # audit setup; print planned fixes only
openzeus install --dry-run        # preview global OpenCode asset install
openzeus status                   # inspect installed assets and sync state
openzeus init-project --dry-run   # preview repo-local .opencode assets
openzeus examples                 # see copy-pasteable workflows
```

When the dry runs look right:

```bash
openzeus install
openzeus init-project --target .
```

## Common workflows

### Audit OpenCode setup

```bash
openzeus doctor --fix-plan
openzeus status
openzeus list all
```

### Initialize repo-local assets

```bash
openzeus init-project --target . --dry-run
openzeus init-project --target .
```

`init-project` detects common project files (`package.json`, `Makefile`,
`pyproject.toml`, `setup.cfg`, `setup.py`) and pre-fills `/test`, `/build`, and
`project-context` with likely commands such as `npm test`, `npm run build`,
`make test`, `make build`, or `pytest`.

### Create agents, skills, and commands

```bash
openzeus create agent reviewer "Reviews pull requests"
openzeus create skill zeus-example "Project-specific guidance"
openzeus create command release-notes "Draft release notes" 'Use $ARGUMENTS'
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
@OpenZeus initialize this repo with project-local OpenCode assets
@OpenZeus turn this release process into a slash command
@OpenZeus diagnose why my project skills are not loading
```

### Use commands

```bash
/zeus-git-commit      # Draft and create a local commit; push only when authorized
/zeus-kanban          # Manage docs/team/KANBAN.md
/zeus-roadmap         # Manage docs/team/ROADMAP.md
/zeus-improve-project # Structured project improvement cycle
```

## Zeus Skills

OpenZeus currently ships **15** Zeus skills.

| Category | Skills |
|---|---|
| OpenCode | `zeus-core`, `zeus-agents`, `zeus-commands`, `zeus-skills`, `zeus-upskill` |
| Workflow | `zeus-context`, `zeus-self`, `zeus-beads`, `zeus-swarm`, `zeus-oac`, `zeus-omo` |
| Technical | `zeus-docker`, `zeus-sql`, `zeus-llm` |
| Fun/testing | `zeus-boston-terrier` |

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
openzeus status
openzeus doctor --fix-plan
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
| `OpenZeus` not available | Run `npm install -g openzeus` or `./scripts/install.sh`, then restart OpenCode. |
| Skills not found | Check `${OPENCODE_CONFIG_DIR:-~/.config/opencode}/skills/`. |
| Commands not found | Check `${OPENCODE_CONFIG_DIR:-~/.config/opencode}/commands/`. |
| Config path differs | Set `OPENCODE_CONFIG_DIR` before installing/syncing. |

## Version

Current package version: **1.1.0**.

## Links

- Repository: https://github.com/Aveer/OpenZeus
- Issues: https://github.com/Aveer/OpenZeus/issues
- OpenCode Docs: https://opencode.ai/docs/
- NPM Package: https://npmjs.com/package/openzeus

---

**🏛️ Welcome to the realm of OpenZeus!**
