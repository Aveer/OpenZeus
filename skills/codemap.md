# skills/ — Knowledge System Codemap

<!-- Generated for OpenZeus skills directory architecture -->

---

## Responsibility

The `skills/` directory implements a **domain-specific knowledge bundle architecture** for the OpenZeus AI agent system. Each skill bundle is a self-contained markdown file providing:

- **Expert domain knowledge** (Docker, SQL, LLM configuration)
- **Operational workflows** (agent creation, command templates)
- **Reference documentation** (URLs, command syntax, troubleshooting)
- **Trigger-based activation** (loaded on-demand via `skill()` tool)

The skills serve as OpenZeus's "memory" and "capability modules"—extending the agent's effective knowledge beyond its base training with specialized, searchable reference content organized by domain.

---

## Design Patterns

### Pattern 1: Skill Bundle Architecture

Each skill is a **standalone markdown module** with standardized structure:

```
skills/zeus-<name>/
└── SKILL.md          # Required: main skill file
    README.md         # Optional: human-facing documentation
    [supporting]      # Optional: templates, configs, examples
```

**Abstraction Layer**:
```
┌─────────────────────────────────────────────────────┐
│  OpenZeus Agent (OpenZeus.md)                       │
│  - Intent Detection → keyword matching              │
│  - Skill Loading → skill("zeus-<name>")            │
└─────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────┐
│  SKILL.md Content (per skill)                       │
│  - YAML frontmatter (name, description)             │
│  - Markdown sections (documentation)                 │
│  - Tables, code blocks, templates                   │
└─────────────────────────────────────────────────────┘
```

### Pattern 2: Frontmatter Metadata Schema

All skills use YAML frontmatter for discovery and loading:

```yaml
---
name: zeus-<name>           # Skill identifier (matches directory)
description: Brief purpose    # One-line summary for autocomplete
---
```

**Interface Contract**:
| Field | Type | Required | Purpose |
|-------|------|----------|---------|
| `name` | string | Yes | Skill identifier for `skill()` loading |
| `description` | string | Yes | Shown in skill selection UIs |

### Pattern 3: Trigger-Keyword → Skill Mapping

Skills are loaded via **intent detection** based on user request keywords:

```
User: "How do I create a Docker container?"
         │
         ▼ [keyword: "docker", "container"]
OpenZeus Agent → skill("zeus-docker")
         │
         ▼
zeus-docker/SKILL.md content injected into context
```

**Trigger Registry** (from OpenZeus.md):
| Keyword Pattern | Skill(s) Loaded |
|-----------------|------------------|
| `docker`, `container` | `zeus-docker` |
| `sql`, `database`, `query` | `zeus-sql` |
| `create agent`, `@mention` | `zeus-agents` |
| `llama`, `ollama`, `local model` | `zeus-llm` |
| `hive`, `swarm`, `multi-agent` | `zeus-swarm` |
| `context`, `compress` | `zeus-context` |
| `health check`, `diagnostics` | `zeus-self` |

### Pattern 4: Multi-Skill Workflow Chains

Complex tasks require **skill composition**:

```
Agent Creation:
  zeus-agents → zeus-core

Command Creation:
  zeus-commands → zeus-core

Docker + DevOps:
  zeus-docker → zeus-core

Self-Improvement:
  zeus-upskill → update OpenZeus.md
```

---

## Data & Control Flow

### Entry Point: Intent Detection

```
User Input
    │
    ▼
┌──────────────────────────────────────────────────────┐
│  OpenZeus.md Agent System Prompt                     │
│  - Scans for trigger keywords                        │
│  - Matches against Skill Loading Guide table         │
│  - Determines skill(s) to load                       │
└──────────────────────────────────────────────────────┘
    │
    ▼
skill("<skill-name>")
    │
    ▼
┌──────────────────────────────────────────────────────┐
│  OpenCode Skill Tool                                  │
│  - Locates: ~/.config/opencode/skills/<name>/        │
│  - Reads: SKILL.md                                   │
│  - Injects content into agent context                │
└──────────────────────────────────────────────────────┘
```

### State Transitions

```
┌─────────────┐     skill()      ┌─────────────────┐
│   IDLE      │ ───────────────▶ │  SKILL_LOADED   │
│ (no skill)  │                  │  (content in    │
└─────────────┘                  │   context)      │
       ▲                         └─────────────────┘
       │                                    │
       │                              [agent uses
       │                               skill content]
       │                                    │
       └────────────────────────────────────┘
                    [skill no longer
                     needed]
```

### Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         USER REQUEST                              │
│   "Create a custom command for deploying with Docker Compose"   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    INTENT DETECTION                               │
│   Keywords: "command", "deploy", "Docker Compose"               │
│   → Match: zeus-commands, zeus-docker                           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      SKILL LOADING                                │
│   skill("zeus-commands")  ──────────────────────────────────┐   │
│   skill("zeus-docker")    ──────────────────────────────────┤   │
│   skill("zeus-core")      ──────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    CONTEXT AUGMENTATION                           │
│   SKILL.md content appended to system prompt                     │
│   - Command templates (zeus-commands)                            │
│   - Docker Compose patterns (zeus-docker)                        │
│   - OpenCode config paths (zeus-core)                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      AGENT REASONING                              │
│   Uses skill content to generate:                                │
│   - Custom command template (zeus-commands)                      │
│   - Docker Compose configuration (zeus-docker)                   │
│   - File path: ~/.config/opencode/commands/deploy.md             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      FILE WRITE                                   │
│   write ~/.config/opencode/commands/deploy.md                     │
└─────────────────────────────────────────────────────────────────┘
```

### Skill Content Types

| Content Type | Purpose | Example |
|--------------|---------|---------|
| Reference tables | Quick lookup | Docker flags, SQL syntax |
| Code templates | Reusable patterns | Dockerfile, Docker Compose |
| Workflows | Step-by-step procedures | Agent creation, session close |
| Troubleshooting | Problem → solution | Common Docker issues |
| External URLs | Documentation links | OpenCode docs, plugin repos |

---

## Integration Points

### External Dependencies

| Dependency | Type | Purpose | Integration |
|------------|------|---------|-------------|
| **OpenCode Core** | Platform | Skill loading system | `skill()` tool, config directory |
| **OpenCode Docs** | Documentation | URL reference mapping | Fetched via `webfetch` |
| **beads** | Issue tracker | Task tracking | `bd` CLI commands |
| **opencode-swarm** | Plugin | Multi-agent orchestration | `swarm_*` tool commands |
| **OpenAgentsControl (OAC)** | Framework | Plan-first development | `/add-context`, `/commit` commands |
| **oh-my-opencode-slim** | Plugin | Enhanced capabilities | Provider configs, cartography |
| **llama.cpp / Ollama** | LLM runtime | Local model serving | HTTP API endpoints |
| **Dolt** | Database | Beads SQL backend | `bd sync` → Dolt SQL |

### Consumer Modules

| Consumer | Interaction | Data Flow |
|----------|-------------|-----------|
| **OpenZeus Agent** | Reads skills | Intent detection → skill loading |
| **OpenCode TUI** | Displays skills | Skill selection UI, autocomplete |
| **Sync Scripts** | Syncs skills | `./scripts/sync-utils.sh push/pull` |

### Plugin & External Tool Hooks

| Hook/Event | Skill Responsible | Integration |
|------------|------------------|-------------|
| `swarm_*` commands | `zeus-swarm` | Multi-agent orchestration |
| `bd` commands | `zeus-beads` | Issue tracking workflow |
| `/add-context`, `/commit` | `zeus-oac` | Pattern learning framework |
| Provider switching | `zeus-omo` | `opencode provider set` |
| `opencode cartography` | `zeus-omo` | Codebase mapping |

### Config Paths (Knowledge System)

```
~/.config/opencode/                    # Global config root
├── opencode.json                     # Main config (skill references)
├── agents/
│   └── OpenZeus.md                  # Master agent with skill triggers
├── skills/                           # Skill bundles (15 zeus-* skills)
│   ├── zeus-core/SKILL.md           # OpenCode internals reference
│   ├── zeus-agents/SKILL.md         # Agent creation templates
│   ├── zeus-commands/SKILL.md       # Command creation templates
│   ├── zeus-skills/SKILL.md         # Skill creation guide
│   ├── zeus-upskill/SKILL.md        # OpenZeus self-extension
│   ├── zeus-swarm/SKILL.md          # Swarm orchestration
│   ├── zeus-llm/SKILL.md            # Local LLM configuration
│   ├── zeus-omo/SKILL.md            # oh-my-opencode-slim plugin
│   ├── zeus-docker/SKILL.md         # Docker/containerization
│   ├── zeus-sql/SKILL.md            # SQL/database patterns
│   ├── zeus-self/SKILL.md           # Self-diagnostics
│   ├── zeus-context/SKILL.md         # Context optimization
│   ├── zeus-beads/SKILL.md          # Beads issue tracker
│   ├── zeus-oac/SKILL.md            # OpenAgentsControl framework
│   └── zeus-boston-terrier/SKILL.md # (Example/niche skill)
└── commands/                        # Custom command templates
    └── [user-defined commands]

<project>/.opencode/                 # Project-level overrides
└── skills/                          # Project-specific skills
```

---

## Skill Taxonomy

### Category 1: OpenCode Platform Skills

| Skill | Responsibility | Lines |
|-------|----------------|-------|
| `zeus-core` | OpenCode config, schema, URLs, built-in agents/commands | ~240 |
| `zeus-agents` | Agent creation templates, patterns, permissions | ~451 |
| `zeus-commands` | Command templates, placeholders, shell injection | ~314 |
| `zeus-skills` | Skill creation guide, structure, best practices | ~222 |
| `zeus-upskill` | OpenZeus self-extension workflow | ~219 |

### Category 2: Infrastructure Skills

| Skill | Responsibility | External Dependency |
|-------|----------------|---------------------|
| `zeus-docker` | Docker, containers, Compose, networking | Docker daemon |
| `zeus-sql` | SQL queries, schema design, ORMs | PostgreSQL/SQLite/MySQL |
| `zeus-llm` | llama.cpp, Ollama, llama-swap setup | LLM HTTP servers |
| `zeus-beads` | Issue tracking with bd CLI | Dolt SQL backend |

### Category 3: Orchestration Skills

| Skill | Responsibility | External Dependency |
|-------|----------------|---------------------|
| `zeus-swarm` | Multi-agent worktrees, feature/task mgmt | opencode-swarm plugin |
| `zeus-oac` | Plan-first dev, approval gates, pattern learning | OpenAgentsControl |
| `zeus-omo` | Provider configs, cartography, tmux | oh-my-opencode-slim |

### Category 4: Self-Management Skills

| Skill | Responsibility | Trigger Keywords |
|-------|----------------|-----------------|
| `zeus-self` | Runtime diagnostics, session status | `health check`, `diagnostics` |
| `zeus-context` | Context compression, cleanup, handoff | `context cleanup`, `compress` |

### Category 5: Specialty Skills

| Skill | Responsibility | Notes |
|-------|----------------|-------|
| `zeus-boston-terrier` | Breed reference | Example/niche skill |

---

## Key Architectural Decisions

### 1. Markdown-Based Knowledge
Skills use plain markdown for portability and easy editing without specialized tooling.

### 2. On-Demand Loading
Skills are loaded only when needed, preserving context window for active work.

### 3. Bundle Per Domain
Each skill is self-contained with all relevant information, avoiding cross-skill dependencies.

### 4. Trigger-Keyword Matching
Simple keyword detection enables automatic skill loading without complex intent classification.

### 5. Two-Tier Organization
Global skills (`~/.config/opencode/skills/`) + Project skills (`<repo>/.opencode/skills/`).

### 6. Bidirectional Sync
OpenZeus repo ↔ config directory sync via `sync-utils.sh` scripts.

---

## Quality Attributes

| Attribute | Implementation |
|-----------|----------------|
| **Discoverability** | YAML frontmatter + trigger keywords in OpenZeus.md |
| **Portability** | Pure markdown, no build step required |
| **Maintainability** | One skill = one domain, clear boundaries |
| **Testability** | Manual verification via `skill()` loading |
| **Versioning** | Git-tracked in OpenZeus repo |

---

## Anti-Patterns to Avoid

1. **Cross-skill dependencies** — Each skill should be self-contained
2. **Procedural logic in skills** — Skills are reference, agents reason
3. **Secrets in skills** — Use environment variables, never hardcode
4. **Outdated URLs** — Periodically validate external documentation links

---

## Session Handoff Protocol

When ending a session involving skill modifications:

```
1. git status          # Check changed files
2. skill("zeus-self")  # Verify system health
3. skill("zeus-beads") # Ensure issues updated
4. git add .           # Stage changes
5. git commit          # Commit work
6. ./sync-utils.sh push  # Sync to config (if in repo)
7. git push            # Push to remote
```

---

End of codemap.
