# scripts/ — OpenZeus Runtime Management Module

---

## Responsibility

The `scripts/` directory serves as the **installation, synchronization, and lifecycle management layer** for the OpenZeus OpenCode extension. It implements the **Deployment Subsystem** responsible for:

- **Initial Installation**: Deploying OpenZeus agents, skills, and commands to the OpenCode runtime configuration directory (`~/.config/opencode/`)
- **Bidirectional Synchronization**: Maintaining consistency between the version-controlled OpenZeus repository and the runtime configuration
- **Context-Aware Asset Creation**: Providing utilities for creating new OpenCode assets (agents, skills, commands) with intelligent location routing
- **Git-Integrated Workflow Automation**: Installing git hooks to automate sync operations during version control workflows

This module bridges the **development environment** (OpenZeus git repository) and the **runtime environment** (OpenCode configuration), acting as the deployment pipeline for the OpenZeus system.

---

## Design Patterns

### 1. **Command Dispatcher Pattern** (sync-utils.sh, create-utils.sh)
All utility scripts implement a command-line interface with a central dispatcher:

```
main() {
    case "${1:-default}" in
        command1) handler1 ;;
        command2) handler2 ;;
        ...
    esac
}
```

**Files**: `sync-utils.sh:254-286`, `create-utils.sh:292-318`

### 2. **Repository Locator Pattern** (detect_zeus_repo)
A three-tier fallback strategy for locating the OpenZeus repository:

| Priority | Method | Detection Logic |
|----------|--------|-----------------|
| 1 | Current Directory | Check if `pwd` basename is "OpenZeus" and `agents/OpenZeus.md` exists |
| 2 | Common Paths | Scan `$HOME/projects/OpenZeus`, `$HOME/OpenZeus`, etc. |
| 3 | Git Remotes | Search all git repos for remote URLs containing "OpenZeus" |

**Files**: `sync-utils.sh:12-47`, `create-utils.sh:13-36`

### 3. **Strategy Pattern for Sync Direction** (auto_sync)
Timestamp-based decision logic chooses between push/pull strategies:

```
if repo_newest > config_newest → push_to_config()
else if config_newest > repo_newest → pull_from_config()
else → already in sync
```

**File**: `sync-utils.sh:221-252`

### 4. **Template Expansion Pattern** (create-utils.sh)
Uses heredoc (`<<EOF`) for generating structured markdown files from templates with variable interpolation:

```bash
cat > "$output_file" << EOF
# $name
Content with $variables
EOF
```

**Files**: `create-utils.sh:107-133` (agent), `165-187` (skill), `227-253` (command)

### 5. **Context-Aware Factory Pattern** (create-utils.sh)
Intelligent routing determines creation target based on execution context:

```
if in OpenZeus repo → create in repo + auto-sync
else if repo detected → prompt user
else → create in global config
```

**File**: `create-utils.sh:39-78`

### 6. **Git Hook Injection Pattern** (setup-hooks.sh)
Creates executable hook scripts by writing heredoc content to `.git/hooks/`:

```bash
cat > "$HOOKS_DIR/post-merge" << 'EOF'
#!/bin/bash
# Hook content
EOF
chmod +x "$HOOKS_DIR/post-merge"
```

**File**: `setup-hooks.sh:10-44`

---

## Data & Control Flow

### Installation Flow (`install.sh`)

```
┌─────────────────────────────────────────────────────────────────┐
│ install.sh                                                       │
├─────────────────────────────────────────────────────────────────┤
│ Entry: ./install.sh                                             │
│                                                                  │
│ 1. Validate OpenCode installation                               │
│    └─ Check: [ ! -d "$HOME/.config/opencode" ]                  │
│       └─ Exit 1 if missing                                      │
│                                                                  │
│ 2. Create runtime directories                                    │
│    ├─ mkdir -p agents/                                          │
│    ├─ mkdir -p skills/                                          │
│    └─ mkdir -p commands/                                        │
│                                                                  │
│ 3. Deploy OpenZeus agent                                         │
│    └─ cp agents/OpenZeus.md → ~/.config/opencode/agents/       │
│                                                                  │
│ 4. Deploy skills (pattern: zeus-*)                              │
│    └─ For each skill_dir in skills/zeus-*:                      │
│       └─ cp -rf skill_dir → ~/.config/opencode/skills/          │
│                                                                  │
│ 5. Deploy commands (pattern: zeus-*)                             │
│    └─ For each cmd in commands/zeus-*.md:                       │
│       └─ cp cmd → ~/.config/opencode/commands/                  │
│                                                                  │
│ 6. Install utilities (if present)                                │
│    ├─ sync-utils.sh → chmod +x                                  │
│    └─ create-utils.sh → chmod +x                                 │
│                                                                  │
│ 7. Install documentation cache (if present)                      │
│    └─ cp -rf docs/docs-cache/* → ~/.config/opencode/docs-cache/ │
│                                                                  │
│ Exit: 0 (success)                                               │
└─────────────────────────────────────────────────────────────────┘
```

### Synchronization Flow (`sync-utils.sh`)

```
┌─────────────────────────────────────────────────────────────────┐
│ sync-utils.sh                                                    │
├─────────────────────────────────────────────────────────────────┤
│ Entry: ./sync-utils.sh <command>                                 │
│                                                                  │
├─ Command: push (repo → config)                                  │
│   ├─ detect_zeus_repo()                                         │
│   ├─ Sync agents: cp *.md → config/agents/                     │
│   ├─ Sync skills: cp -rf zeus-* → config/skills/               │
│   └─ Sync commands: cp zeus-*.md → config/commands/            │
│                                                                  │
├─ Command: pull (config → repo)                                  │
│   ├─ detect_zeus_repo()                                         │
│   ├─ For each file: cmp -s (compare)                            │
│   │   └─ If different: cp config → repo                         │
│   ├─ Track changes flag                                         │
│   └─ If changes=true: suggest git commit                        │
│                                                                  │
├─ Command: status                                                │
│   ├─ detect_zeus_repo()                                         │
│   ├─ cmp OpenZeus.md (agent file)                               │
│   ├─ Count zeus-* skills in both locations                      │
│   └─ Count zeus-*.md commands in both locations                │
│                                                                  │
└─ Command: auto (timestamp-based)                               │
    ├─ detect_zeus_repo()                                         │
    ├─ Find newest .md file in repo (stat -c %Y)                  │
    ├─ Find newest .md file in config                             │
    ├─ Compare timestamps                                         │
    │   ├─ repo newer → push_to_config()                         │
    │   ├─ config newer → pull_from_config()                     │
    │   └─ equal → "Already in sync"                             │
    └─ Execute determined direction                                │
└─────────────────────────────────────────────────────────────────┘
```

### Creation Flow (`create-utils.sh`)

```
┌─────────────────────────────────────────────────────────────────┐
│ create-utils.sh                                                  │
├─────────────────────────────────────────────────────────────────┤
│ Entry: ./create-utils.sh <type> <name> [desc] [template]       │
│                                                                  │
├─ Parse CLI arguments                                            │
│   ├─ type: agent | skill | command                             │
│   ├─ name: target filename without extension                    │
│   ├─ description: for template content                        │
│   └─ template: for commands                                    │
│                                                                  │
├─ determine_location(type)                                       │
│   ├─ If in OpenZeus repo → CREATE_LOCATION="repo"              │
│   ├─ Else if repo detected → interactive prompt                │
│   │   └─ [1] OpenZeus repo (recommended)                       │
│   │   └─ [2] Global config (~/.config/opencode/)               │
│   └─ Else → CREATE_LOCATION="config"                            │
│                                                                  │
├─ get_target_dir(type)                                           │
│   └─ Return: $OPENZEUS_REPO/$type  OR  $OPENCODE_DIR/$type     │
│                                                                  │
├─ create_agent(name, desc)                                       │
│   ├─ determine_location("agent")                               │
│   ├─ mkdir -p target_dir                                       │
│   ├─ Generate agent template (heredoc)                          │
│   ├─ If CREATE_LOCATION=repo: invoke sync-utils.sh push        │
│   └─ Return: agent_file path                                   │
│                                                                  │
├─ create_skill(name, desc)                                       │
│   ├─ determine_location("skill")                               │
│   ├─ mkdir -p target_dir/name                                  │
│   ├─ Generate skill/SKILL.md template                          │
│   ├─ If CREATE_LOCATION=repo: invoke sync-utils.sh push        │
│   └─ If name matches zeus-*: suggest manual OpenZeus.md update │
│                                                                  │
└─ create_command(name, desc, template)                           │
    ├─ determine_location("command")                              │
    ├─ mkdir -p target_dir                                       │
    ├─ Generate command.md template                               │
    └─ If CREATE_LOCATION=repo: invoke sync-utils.sh push        │
└─────────────────────────────────────────────────────────────────┘
```

### Git Hook Flow (`setup-hooks.sh`)

```
┌─────────────────────────────────────────────────────────────────┐
│ setup-hooks.sh                                                   │
├─────────────────────────────────────────────────────────────────┤
│ Entry: ./setup-hooks.sh                                         │
│                                                                  │
│ 1. Create post-merge hook                                       │
│    └─ File: .git/hooks/post-merge                              │
│       └─ Content:                                               │
│          if OpenZeus repo detected:                            │
│              invoke sync-utils.sh push                         │
│                                                                  │
│ 2. Create pre-push hook                                        │
│    └─ File: .git/hooks/pre-push                                │
│       └─ Content:                                               │
│          if OpenZeus repo detected:                            │
│              invoke sync-utils.sh pull                         │
│                                                                  │
│ 3. chmod +x on both hooks                                      │
│                                                                  │
│ Exit: 0 (success)                                              │
└─────────────────────────────────────────────────────────────────┘

Git Workflow Integration:
┌─────────────────────────────────────────────────────────────────┐
│ git pull/merge → post-merge hook → sync-utils.sh push          │
│     (brings repo up-to-date → syncs to config)                  │
│                                                                  │
│ git push → pre-push hook → sync-utils.sh pull                  │
│     (checks for external config changes → merges to repo first) │
└─────────────────────────────────────────────────────────────────┘
```

---

## State Transitions

### Sync State Machine

```
┌──────────┐    push()     ┌──────────┐    pull()     ┌──────────┐
│  SYNCED  │◄──────────────│  REPO    │──────────────►│  CONFIG  │
│          │               │  NEWER   │               │  NEWER   │
└──────────┘               └──────────┘               └──────────┘
     ▲                           │                         │
     │         auto_sync()       │                         │
     └───────────────────────────┴─────────────────────────┘
                    (timestamp comparison)
```

### Location State (create-utils.sh)

```
UNDEFINED → determine_location()
    │
    ├─ In OpenZeus repo ──────────────► CREATE_LOCATION="repo"
    │
    ├─ Repo elsewhere + user selects 1 → CREATE_LOCATION="repo"
    ├─ Repo elsewhere + user selects 2 → CREATE_LOCATION="config"
    └─ No repo found ─────────────────► CREATE_LOCATION="config"
```

---

## Integration Points

### External Dependencies

| Dependency | Source | Used By | Purpose |
|------------|--------|---------|---------|
| OpenCode config | `$HOME/.config/opencode/` | All scripts | Target runtime directory |
| OpenZeus repo | Auto-detected | sync-utils.sh, create-utils.sh | Source of truth for version-controlled assets |
| Git | System binary | sync-utils.sh (detect_zeus_repo), setup-hooks.sh | Repository detection and hooks |
| bash | System shell | All scripts | Execution environment |

### Consumer Modules

| Consumer | Integration Method | Purpose |
|----------|-------------------|---------|
| OpenCode runtime | Directory scan | Loads agents, skills, commands from config |
| Git hooks | Executable hooks | Triggers sync on VCS operations |
| npm package | install.sh | Installs scripts during `npm install` |

### Directory Structure Contract

```
~/.config/opencode/              # OpenCode runtime root
├── agents/
│   └── OpenZeus.md              # Main agent definition
├── skills/
│   ├── zeus-core/SKILL.md       # Core Zeus skills
│   ├── zeus-swarm/SKILL.md      # Swarm intelligence skills
│   └── zeus-*/SKILL.md          # Extensible skill modules
├── commands/
│   ├── zeus-git-commit.md       # Git commit command
│   ├── zeus-kanban.md           # Kanban board command
│   └── zeus-*.md                # Extensible commands
├── sync-utils.sh                # Sync utility (installed)
└── create-utils.sh              # Creator utility (installed)

$OPENZEUS_REPO/                  # OpenZeus version-controlled repo
├── agents/OpenZeus.md
├── skills/zeus-*/
├── commands/zeus-*.md
├── scripts/
│   ├── sync-utils.sh
│   ├── create-utils.sh
│   └── setup-hooks.sh
└── .git/hooks/
    ├── post-merge               # Auto-sync trigger
    └── pre-push                 # Pre-push sync trigger
```

### API Surface (CLI Commands)

| Script | Command | Arguments | Description |
|--------|---------|-----------|-------------|
| `install.sh` | (none) | — | One-time installation to config |
| `sync-utils.sh` | `push` | — | Repo → Config sync |
| `sync-utils.sh` | `pull` | — | Config → Repo sync |
| `sync-utils.sh` | `status` | — | Show sync state |
| `sync-utils.sh` | `auto` | — | Timestamp-based auto-sync |
| `sync-utils.sh` | `install` | — | Alias for push |
| `create-utils.sh` | `agent` | `<name> [desc]` | Create agent file |
| `create-utils.sh` | `skill` | `<name> [desc]` | Create skill module |
| `create-utils.sh` | `command` | `<name> [desc] [template]` | Create command file |
| `setup-hooks.sh` | (none) | — | Install git hooks |

### Exit Codes

| Code | Meaning | Used By |
|------|---------|---------|
| 0 | Success | All scripts |
| 1 | Error/Not found | install.sh, sync-utils.sh, create-utils.sh |

---

## Key Design Decisions

1. **Two-Location Architecture**: OpenZeus maintains assets in both a version-controlled repo and a runtime config, requiring explicit sync management.

2. **Zeus-Prefix Convention**: Only files/directories prefixed with `zeus-` are synced, preventing accidental sync of third-party or user-specific assets.

3. **Non-Destructive Sync**: Pull operations use `cmp -s` to avoid unnecessary file overwrites; push operations are unconditional.

4. **Install vs. Sync Separation**: `install.sh` is a one-time deployment, while `sync-utils.sh` handles ongoing bidirectional synchronization.

5. **Context-Aware Defaults**: Creation utilities detect execution context to minimize user prompting while maintaining flexibility.

6. **Git Hook Integration**: Hooks automate sync at natural VCS workflow boundaries (post-merge, pre-push), ensuring runtime config stays current.
