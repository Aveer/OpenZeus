# OpenZeus Developer Guide

This file provides guidelines for AI agents operating in the OpenZeus repository.

---

## Project Overview

OpenZeus is an AI agent for OpenCode - a sophisticated configuration and automation system. The project consists of:

- **Bash scripts**: Installation, sync utilities, context-aware creator, git hooks
- **Markdown skills**: Domain expertise guides for OpenCode operations
- **Markdown commands**: Custom slash command templates
- **Markdown agents**: Agent definitions for OpenCode
- **NPM package**: Published distribution with install.sh

---

## Build & Test Commands

### Running Tests

```bash
# Validate bash syntax (single file)
bash -n scripts/install.sh

# Validate all bash scripts
bash -n scripts/install.sh && bash -n scripts/sync-utils.sh && bash -n scripts/create-utils.sh && bash -n scripts/setup-hooks.sh

# Run package tests
npm test

# Full validation - syntax + npm test
bash -n scripts/install.sh && npm test
```

### Publishing to npm

```bash
# Bump version in package.json, then:
npm publish

# Check package contents before publishing
npm pack --dry-run
```

### Git Workflow

```bash
# Check sync status (repo vs config)
./scripts/sync-utils.sh status

# Push changes from repo to config
./scripts/sync-utils.sh push

# Pull changes from config to repo
./scripts/sync-utils.sh pull

# Auto-detect sync direction
./scripts/sync-utils.sh auto
```

---

## Code Style Guidelines

### Bash Scripts

**Shebang & Error Handling**
```bash
#!/bin/bash
set -e  # Exit on error (always use this)
set -u  # Exit on undefined variable
set -o pipefail  # Catch errors in pipelines
```

**Variables**
```bash
# Use UPPER_CASE for constants
CONSTANT_VALUE="fixed"

# Use lower_case for local variables
local user_input=""

# Always quote variables to handle spaces
cp -f "$source_file" "$target_dir/"
```

**Functions**
```bash
# Declare with local variables
function my_function() {
    local arg1="$1"
    local arg2="$2"
    
    # Use return for exit codes, not values
    return 0  # success
    return 1  # failure
}
```

**Conditionals**
```bash
# Use [[ ]] for tests (not [ ])
if [[ -f "$file" ]]; then
    echo "exists"
fi

# String comparison
if [[ "$var" == "expected" ]]; then
    echo "match"
fi
```

**Loops**
```bash
# Always use proper quoting in loops
for file in "$directory"/*; do
    if [[ -f "$file" ]]; then
        process "$file"
    fi
done
```

### Markdown Files

**Skill Files** (`skills/*/SKILL.md`)
```markdown
---
name: skill-name
description: Brief description of what the skill covers
---

# Skill Name

## Section 1

Content...

---

## Section 2

More content...

---

End of skill.
```

**Agent Files** (`agents/*.md`)
```markdown
# Agent Name

Description of the agent's role and capabilities.

---

## Instructions

Detailed agent instructions...

---

## Tools

- tool-name: what it does
- Another tool usage

---

## Examples

Example usage patterns...

---

End of agent.
```

**Command Files** (`commands/*.md`)
```markdown
# Command: /command-name

**Description**: What the command does

---

## Template

{{template content with placeholders}}

---

## Usage

`/command-name [arguments]`

---

## Examples

`/command-name example` — Description
```

### File Naming

| Type | Pattern | Example |
|------|---------|---------|
| Agents | `*.md` | `OpenZeus.md` |
| Skills | `*/SKILL.md` | `zeus-core/SKILL.md` |
| Commands | `*.md` | `zeus-git-commit.md` |
| Scripts | `scripts/*.sh` | `scripts/sync-utils.sh` |

### Error Handling

```bash
# Check for required tools
if ! command -v git &>/dev/null; then
    echo "Error: git is required" >&2
    exit 1
fi

# Check for required files
if [[ ! -f "$required_file" ]]; then
    echo "Error: required file not found: $required_file" >&2
    exit 1
fi

# Use subshells for isolated error handling
if (set -e; dangerous_command); then
    echo "Success"
else
    echo "Failed but continuing..."
fi
```

### Naming Conventions

| Item | Convention | Example |
|------|------------|---------|
| Bash functions | snake_case | `detect_zeus_repo` |
| Variables | snake_case | `opencode_dir` |
| Constants | UPPER_CASE | `DEFAULT_TIMEOUT` |
| Skills | prefix | `zeus-core`, `zeus-swarm` |
| Commands | prefix | `zeus-git-commit`, `zeus-kanban` |
| Agents | PascalCase | `OpenZeus`, `TaskManager` |

---

## Sync Strategy

This project uses a bidirectional sync system:

1. **Repo** (`/home/aver/projects/OpenZeus`) - Version controlled, contains all source
2. **Config** (`~/.config/opencode/`) - Runtime location for OpenCode

**Key principle**: Changes made in the repo must sync to config, and vice versa.

Scripts in the `scripts/` folder are included in the npm package and installed to user config. The scripts folder contains: install.sh, sync-utils.sh, create-utils.sh, setup-hooks.sh

---

## Common Tasks

### Adding a New Skill

1. Create `skills/zeus-newskill/SKILL.md`
2. Add skill metadata header (name, description)
3. Document the skill's purpose and usage
4. Update README.md skills table
5. Sync: `./scripts/sync-utils.sh push`

### Adding a New Command

1. Create `commands/zeus-command.md`
2. Follow command template format
3. Update README.md commands table
4. Sync: `./sync-utils.sh push`

### Publishing a Release

1. Update `package.json` version
2. Update `CHANGELOG.md`
3. Commit with message: `Release v1.0.x: description`
4. Push to GitHub
5. Publish to npm: `npm publish`

---

<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:ca08a54f -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

## Session Completion

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd dolt push
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
<!-- END BEADS INTEGRATION -->
