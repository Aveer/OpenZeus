---
name: zeus-beads
description: Expert reference for Steve Yegge's Beads issue tracker — a git-backed, dependency-aware graph tracker for AI coding agents. Covers setup, commands, workflows, and OpenCode integration.
---

# zeus-beads (Skill)

Purpose: Expert reference for Steve Yegge's Beads issue tracker — a git-backed, dependency-aware graph tracker for AI coding agents. Covers setup, commands, workflows, and OpenCode integration.

**🔗 Beads Repository**: https://github.com/steveyegge/beads

---

## What is Beads?

Beads is a persistent memory system for AI coding agents. It replaces messy markdown plans with a dependency-aware graph tracker.

**Key features:**
- **Zero setup** — `bd init` creates project-local database
- **Dependency tracking** — Four dependency types (blocks, related, parent-child, discovered-from)
- **Git-backed** — Powered by Dolt SQL database with full history
- **Agent-optimized** — JSON output, ready work detection
- **Hash-based IDs** — `bd-a1b2` prevents merge collisions

**Why use it?**
- Agents forget everything between sessions
- Beads provides persistent context across compactions
- Dependency graph shows blockers and ready work
- Git-tracked issues sync with code changes

---

## Documentation Links

| Resource | URL |
|---|---|
| Main README | https://github.com/steveyegge/beads |
| Installation Guide | https://github.com/steveyegge/beads/blob/main/docs/INSTALLING.md |
| Quick Start | https://steveyegge.github.io/beads/getting-started/quickstart |
| CLI Reference | https://github.com/steveyegge/beads (run `bd --help`) |
| Claude Code Integration | https://steveyegge.github.io/beads/integrations/claude-code |
| GitHub Copilot Integration | https://steveyegge.github.io/beads/integrations/github-copilot |
| OpenCode Plugin (opencode-beads) | https://github.com/joshuadavidthomas/opencode-beads |
| Enhanced Plugin (beads-compound) | https://github.com/roberto-mello/beads-compound-plugin |

---

## Installation

### 1. Install beads CLI

**via npm (recommended):**
```bash
npm install -g @beads/bd
```

**via Homebrew (macOS/Linux):**
```bash
brew install beads
```

**via script:**
```bash
curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
```

### 2. Install Dolt (required dependency)

```bash
# Linux/macOS
sudo bash -c 'curl -L https://github.com/dolthub/dolt/releases/latest/download/install.sh | bash'

# Or manual download from https://github.com/dolthub/dolt/releases
```

### 3. Install OpenCode plugin

Add to `~/.config/opencode/opencode.json`:
```json
{
  "plugin": ["opencode-beads"]
}
```

### 4. Initialize in project

```bash
cd your-project
bd init
```

---

## Essential Commands

### Finding Work
| Command | Description |
|---|---|
| `bd ready` | Show issues with no blockers (ready to work) |
| `bd list --status=open` | List all open issues |
| `bd list --status=in_progress` | Show active work |
| `bd blocked` | Show all blocked issues |
| `bd show <id>` | Detailed issue view with dependencies |

### Creating Issues
| Command | Description |
|---|---|
| `bd create "Title" -t task -p 2` | Create task (priority 0-4) |
| `bd create "Title" -t bug -p 0` | Create critical bug |
| `bd create "Title" -t epic` | Create epic (parent issue) |
| `bd create "Title" --parent bd-a3f8` | Create subtask under epic |

### Working on Issues
| Command | Description |
|---|---|
| `bd update <id> --claim` | Start working (claim issue) |
| `bd update <id> --status in_progress` | Set status manually |
| `bd update <id> --notes "context"` | Add notes |
| `bd close <id> --reason "Fixed"` | Complete issue |
| `bd close <id1> <id2>` | Close multiple at once |

### Dependencies
| Command | Description |
|---|---|
| `bd dep add <issue> <blocks>` | Add dependency (A blocks B) |
| `bd dep tree <id>` | Show dependency tree |
| `bd dep cycles` | Detect circular dependencies |

### Project Health
| Command | Description |
|---|---|
| `bd stats` | Statistics (open/closed/blocked) |
| `bd doctor` | Check for issues |
| `bd doctor --check=conventions` | Convention drift check |
| `bd lint` | Check issue quality |
| `bd stale` | Find inactive issues |

---

## Priority Reference

| Priority | Value | Use Case |
|---|---|---|
| P0 | 0 | Critical — blocking release |
| P1 | 1 | High — important for current sprint |
| P2 | 2 | Medium — default priority |
| P3 | 3 | Low — nice to have |
| P4 | 4 | Backlog — someday/maybe |

---

## Issue Types

| Type | Description |
|---|---|
| `task` | Work item (default) |
| `bug` | Something broken |
| `feature` | New functionality |
| `epic` | Large feature with subtasks |
| `chore` | Maintenance (deps, tooling) |
| `decision` | Architectural decision |

---

## Workflow: Session Close Protocol

**CRITICAL** — Before ending a session:

```bash
# 1. Check what changed
git status

# 2. Commit code
git add .
git commit -m "message"

# 3. Sync beads
bd sync

# 4. Push
git push
```

---

## Workflow: Complete Task

```bash
# 1. Find ready work
bd ready

# 2. Review issue
bd show bd-xxx

# 3. Claim work
bd update bd-xxx --claim

# 4. Implement...

# 5. Close and commit
bd close bd-xxx --reason "Implemented feature X"
git add . && git commit -m "feat: implement X" && git push
```

---

## Workflow: Create Dependent Work

```bash
# Create feature
bd create "Implement auth" -t feature -p 1

# Create dependent task
bd create "Write tests" -t task -p 1

# Link: tests depends on auth
bd dep add tests-id auth-id
```

Now `bd ready` only shows `auth-id` until it's closed.

---

## Session Recovery

After session compaction or new session:

```bash
bd prime
```

This injects ~1-2k tokens of workflow context including:
- Ready issues
- Recent activity
- Session close protocol reminders

---

## Configuration

### Set prefix (issue ID format)
```bash
bd init myprefix  # Creates myprefix-1, myprefix-2, etc.
```

### Validate on create
```bash
bd config set validation.on-create warn
```

### Enable stealth mode (local only, no git)
```bash
bd init --stealth
```

---

## Troubleshooting

| Problem | Solution |
|---|---|
| `bd: command not found` | Install beads: `npm install -g @beads/bd` |
| `dolt not found` | Install Dolt: see Installation section |
| `bd init fails` | Ensure `dolt` is on PATH and git is initialized |
| Context not injecting | Run `bd prime` manually; check plugin loaded |

---

## Session Close Checklist

```
[ ] 1. git status              (check what changed)
[ ] 2. git add <files>         (stage code changes)
[ ] 3. git commit -m "..."     (commit code)
[ ] 4. bd sync                 (sync beads to Dolt)
[ ] 5. git push                (push to remote)
```

**NEVER skip this.** Work is not done until pushed.

---

## Beads Rules for Agents

- **Default**: Use beads for ALL task tracking
- **Prohibited**: Do NOT use TodoWrite, TaskCreate, or markdown files
- **Before code**: Create beads issue FIRST, then implement
- **Memory**: Use `bd remember "insight"` for persistent learnings
- **Search**: `bd memories <keyword>` to recall past insights

---

## Related Plugins

| Plugin | Description |
|---|---|
| [opencode-beads](https://github.com/joshuadavidthomas/opencode-beads) | OpenCode integration with /bd-* commands |
| [beads-compound](https://github.com/roberto-mello/beads-compound-plugin) | Enhanced with memory/knowledge capture |

---

End of skill.
