# OpenZeus

**Master of OpenCode — docs, agents, commands, skills, and config helpers.**

OpenZeus is an OpenCode asset pack: one OpenCode agent, Zeus skill bundles, slash commands, and install/sync utilities for keeping this repository aligned with your OpenCode config.

![OpenZeus](./media/OpenZeus.png)

## Features

- **🏛️ OpenZeus agent**: concise operator for OpenCode workflows.
- **🛠️ 15 Zeus skills**: domain references for OpenCode, Docker, SQL, LLMs, Beads, and more.
- **⚡ Slash commands**: reusable workflows for commits, kanban, roadmaps, and project improvement.
- **🔄 Repo ↔ config sync**: install and sync helpers for OpenCode assets.
- **🎯 Intent-based routing**: OpenZeus loads relevant skills when tasks need deeper guidance.

## Installation

### NPM

```bash
npm install -g openzeus

# CLI entrypoint
openzeus help

# Explicitly install assets into OpenCode config
openzeus install
```

### Manual

```bash
git clone https://github.com/Aveer/OpenZeus.git
cd OpenZeus
./scripts/install.sh
```

The installer copies assets into `${OPENCODE_CONFIG_DIR:-~/.config/opencode}`.

## Quick Start

### Use the agent

```bash
@OpenZeus help me configure OpenCode for this repo
@OpenZeus create a project command for release notes
@OpenZeus explain OpenCode agent permissions
```

### Use commands

```bash
/zeus-git-commit      # Draft and create a local commit; push only when authorized
/zeus-kanban          # Manage docs/team/KANBAN.md
/zeus-roadmap         # Manage docs/team/ROADMAP.md
/zeus-improve-project # Structured project improvement cycle
```

### Sync repo assets to OpenCode config

```bash
./scripts/sync-utils.sh status
./scripts/sync-utils.sh push
# or: openzeus sync status
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
