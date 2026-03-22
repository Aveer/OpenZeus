# Zeus Maintenance Guide

## What is OpenZeus?

OpenZeus is the agent that knows OpenCode inside-out, so you don't have to.

**What it does:**
- Knows OpenCode inside out — paths, configs, docs, schemas
- Creates agents and commands when you ask
- Builds skills from scratch
- Knows OpenCode plugins (opencode-swarm, oh-my-opencode-slim)
- Knows external tools (llama.cpp, llama-swap)
- Handles routine tasks fast
- Fetches docs proactively when unsure
- Knows which skill to load for any question

**What it is NOT:**
- An orchestrator

## Two-Repo Structure

### Public: https://github.com/Aveer/OpenZeus
- Agent definition (`OpenZeus.md`)
- User-facing skills
- README for users
- Should be clean and accurate for public consumption

### Private: https://github.com/Aveer/opencode-config
- Full backup of all agents, skills, commands, configs
- Private maintenance docs (this file)
- Experimental/backup files

## Updating the Public Repo

**When to update:**
- OpenZeus definition changes
- New skills added
- README improvements

**Process:**
1. Work in `~/.config/opencode/` (opencode-config)
2. Copy changed files to a temp folder
3. Clone OpenZeus repo to temp
4. Replace changed files
5. Commit and push from temp
6. Clean up

**Files in public repo:**
```
OpenZeus.md                    # Agent definition
README.md                      # User-facing README
skills/zeus-core/
skills/zeus-agents/
skills/zeus-commands/
skills/zeus-skills/
skills/zeus-swarm/
skills/zeus-llm/
skills/zeus-omo/
commands/zeus-git-commit.md    # Git commit + push command
commands/zeus-kanban.md         # Team kanban board
commands/zeus-roadmap.md        # Project roadmap
```

## README Rules

- Description must be accurate (knowledge keeper + builder, NOT orchestrator)
- Skills table: link the second column (tools/plugins) not the skill names
- Use actual default values, don't make things up
- Don't include redundant docs links
- Keep it clean and useful for users
- Add emojis for personality, but not too corporate

## Skill Descriptions (accurate)

| Skill | Covers |
|-------|--------|
| `zeus-core` | OpenCode docs, paths, config schema |
| `zeus-agents` | Agent creation templates |
| `zeus-commands` | Command creation templates |
| `zeus-skills` | Skill creation guide |
| `zeus-swarm` | opencode-swarm plugin |
| `zeus-omo` | oh-my-opencode-slim plugin |
| `zeus-llm` | llama.cpp, llama-swap (NOT Ollama) |

## Commands

| Command | Purpose |
|---------|---------|
| `zeus-git-commit.md` | Draft commits and push (after confirmation) |
| `git-status.md` | Git status overview |
| `zeus-kanban.md` | Team kanban board management |
| `zeus-roadmap.md` | Project roadmap tracking |

**Note:** Commands go in `~/.config/opencode/commands/`. All `zeus-*` commands are in the public repo.

## Agent Default Configuration

```yaml
---
description: Master of OpenCode docs, agents, and configs
mode: all
model: opencode/big-pickle
color: "#FFD700"
temperature: 0.1
steps: 20
permission:
  edit: allow
  write: allow
  webfetch: allow
  bash:
    "*": allow
    "git push": ask
    "git push *": ask
---
```

## Future Changes

When modifying OpenZeus in a new chat:
1. Load this doc first
2. Follow the established definition
3. Update this doc if rules change
4. Push to appropriate repo(s)
