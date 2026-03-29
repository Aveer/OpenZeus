# agents/ — Agent Definitions Module

## Responsibility

The `agents/` directory houses **OpenCode agent definition files** — Markdown documents that define AI agent personas, capabilities, permissions, and behavioral rules. This module serves as the **agent registry and definition layer** for the OpenZeus ecosystem.

**Primary responsibilities:**
- Define agent personas via system prompts (YAML frontmatter + Markdown body)
- Specify agent permissions, models, and operational parameters
- Provide skill loading guidance and domain expertise routing
- Enable multi-agent orchestration through delegation patterns

**In the OpenCode architecture:**
- Agents are first-class citizens loaded at runtime by the OpenCode runtime
- Agent definitions are discovered from `~/.config/opencode/agents/` or `<repo>/.opencode/agents/`
- Agents can be referenced via `@mention` syntax or set as `default_agent` in `opencode.json`

---

## Design Patterns

### 1. **Agent Definition Pattern** (Declarative Configuration)

Each agent is a **declarative YAML + Markdown hybrid document**:

```yaml
---
description: Human-readable agent summary
mode: all              # Operational mode (all | ask | edit)
model: opencode/model  # LLM model identifier
color: "#HEXCODE"      # UI color for agent identification
temperature: 0.1       # LLM sampling temperature
steps: 50              # Max conversation turns
permission:            # Capability grants
  edit: allow
  write: allow
  webfetch: allow
  bash: allow
---
# Agent Name — Persona Title

System prompt content...
```

**Key abstractions:**
- **YAML Frontmatter**: Structured metadata for OpenCode runtime parsing
- **Markdown Body**: Human-readable system prompt with behavioral rules
- **Permission Matrix**: Granular tool access control via `permission:` block

### 2. **Skill Routing Pattern** (Intent Detection)

OpenZeus implements **keyword-based intent detection** for proactive skill loading:

```
User Input → Keyword Matching → Skill Selection → Execution
```

**Intent → Skill mappings** stored in agent prompt:
- `"create agent"` → `zeus-agents`
- `"docker"` → `zeus-docker`
- `"sql"` → `zeus-sql`
- `"health check"` → `zeus-self`

### 3. **Multi-Agent Delegation Pattern** (Task Offloading)

Non-domain tasks are delegated via OpenCode's `task` tool:

```
OpenZeus → task(tool) → subagent_type:"explorer|librarian|fixer"
```

**Delegation matrix:**
| Task Domain | Subagent Type |
|-------------|---------------|
| Web automation | `explorer` |
| Library research | `librarian` |
| Code analysis | `explorer` |
| Task management | `beads-task-agent` |
| Context management | `ContextManager` |

### 4. **Context-Aware Creation Pattern** (Location Intelligence)

Determines optimal file creation location based on context:

```
1. Check current directory
2. Detect OpenZeus repo availability
3. Apply priority: Repo (versioned) > Config (local)
4. Enable auto-sync for bidirectional consistency
```

**Location strategy matrix:**
| Context | Target Location | Sync Behavior |
|---------|-----------------|---------------|
| In OpenZeus repo | `repo/agents/` | Auto-sync to config |
| Repo findable | Ask user preference | Manual sync |
| No repo | `~/.config/opencode/agents/` | Local only |

### 5. **Multi-Skill Workflow Pattern** (Composable Expertise)

Complex tasks load **ordered skill chains**:

```markdown
### Code Analysis
skill("cartography") → skill("zeus-core") → skill("simplify")

### Docker & DevOps
skill("zeus-docker") → skill("zeus-core")

### Multi-Agent Orchestration
skill("zeus-swarm") → skill("zeus-agents") → skill("zeus-core")
```

---

## Data & Control Flow

### Entry Points

**1. User Invocation Flow**
```
User: "@OpenZeus help me configure OpenCode"
  │
  ├─► OpenCode runtime loads agent definition
  │
  ├─► Parser extracts YAML frontmatter (permissions, model, mode)
  │
  ├─► System prompt injected into LLM context
  │
  └─► Agent responds with skill loading decision
```

**2. Intent Detection Flow**
```
User Input
    │
    ▼
Keyword Matcher (in agent prompt rules)
    │
    ├─► "create agent" → Load zeus-agents + zeus-core
    ├─► "docker" → Load zeus-docker
    ├─► "health check" → Load zeus-self
    │
    ▼
Skill Tool Invocation
    │
    ▼
Skill Content Injected into Context
```

### State Transitions

**Agent Lifecycle States:**
```
UNLOADED → LOADING → ACTIVE → IDLE → SUSPENDED → UNLOADED
    │           │         │       │         │
    └───────────┴─────────┴───────┴─────────┘
              (Runtime Managed)
```

**Session State within Agent:**
```
INITIALIZE → PARSE_PROMPT → LOAD_SKILLS → EXECUTE_TASK → MONITOR_PERFORMANCE
     │              │              │            │              │
     └──────────────┴──────────────┴────────────┴──────────────┘
                            (Continuous Loop)
```

### Data Structures

**Agent Definition Schema:**
```typescript
interface AgentDefinition {
  metadata: {
    description: string;
    mode: "all" | "ask" | "edit";
    model: string;
    color: string;
    temperature: number;
    steps: number;
  };
  permissions: {
    edit?: "allow" | "deny";
    write?: "allow" | "deny";
    webfetch?: "allow" | "deny";
    bash?: "allow" | "deny";
    [key: string]: string | undefined;
  };
  systemPrompt: string;  // Markdown body
}
```

**Skill Loading Request:**
```typescript
interface SkillLoadRequest {
  skillName: string;    // e.g., "zeus-core"
  priority: number;      // Load order
  context: "auto" | "manual";
}
```

### Exit Points

**1. Direct Response:**
```
Agent → LLM Generation → User Response
```

**2. Delegated Task:**
```
Agent → task(tool) → Subagent → task completion → Agent resumes
```

**3. File System Operation:**
```
Agent → write(tool) → File System → Confirmation to User
```

**4. Skill Injection:**
```
Agent → skill(tool) → Skill Content → Extended Context → Continued Execution
```

---

## Integration Points

### Upstream Dependencies (Inputs)

| Source | Type | Purpose |
|--------|------|---------|
| `~/.config/opencode/opencode.json` | Config file | Agent registry, default_agent setting |
| `~/.config/opencode/agents/*.md` | Agent definitions | Runtime-loaded agent personas |
| `<repo>/.opencode/agents/*.md` | Project agents | Repository-scoped agent overrides |
| OpenCode runtime | System | Agent lifecycle management, tool execution |

### Downstream Consumers (Outputs)

| Consumer | Integration Method |
|----------|-------------------|
| OpenCode runtime | Agent loading via file discovery |
| `@mention` invocation | Agent selection by name |
| Task delegation (`task` tool) | Subagent type references |
| Skill system | Agent triggers skill loading |

### Skill System Integration

**Zeus skill bundle locations:**
```
~/.config/opencode/skills/zeus-*/SKILL.md  (installed)
<OpenZeus-repo>/skills/zeus-*/SKILL.md      (source)
```

**Skill loading interface:**
```javascript
// Via skill tool
skill("zeus-core")           // Load single skill
skill("zeus-agents", "zeus-core")  // Load multiple
```

**Skill categories consumed by agents:**
| Category | Skills | Purpose |
|----------|--------|---------|
| OpenCode Internals | `zeus-core` | Config, paths, schema, URLs |
| Creation | `zeus-agents`, `zeus-commands`, `zeus-skills` | Creation workflows |
| Self-Management | `zeus-self`, `zeus-context`, `zeus-upskill` | Introspection, improvement |
| Domain Expertise | `zeus-docker`, `zeus-sql`, `zeus-llm` | External tool knowledge |
| Orchestration | `zeus-swarm`, `zeus-omo`, `zeus-beads` | Multi-agent, terminal, issues |

### Command System Integration

**Command file locations:**
```
~/.config/opencode/commands/zeus-*.md  (installed)
<OpenZeus-repo>/commands/zeus-*.md      (source)
```

**Agent commands invocation:**
```
/zeus-kanban         # Project kanban
/zeus-git-commit     # Git commit helper
/zeus-roadmap        # Roadmap generator
/zeus-improve-project # Improvement suggestions
```

### Sync Infrastructure Integration

**Scripts consumed by agents:**
| Script | Purpose | Integration |
|--------|---------|-------------|
| `scripts/sync-utils.sh` | Bidirectional repo↔config sync | OpenZeus prompts, zeus-upskill |
| `scripts/install.sh` | Initial setup, skill/command installation | Post-install hook |
| `scripts/create-utils.sh` | Context-aware file creation | Agent creation workflow |
| `scripts/setup-hooks.sh` | Git hooks installation | Self-improvement workflow |

### External System Integration

| System | Integration | Purpose |
|--------|-------------|---------|
| OpenCode Docs (opencode.ai) | `webfetch` tool + URL mapping | Proactive documentation fetching |
| NPM Registry | `npm publish` | Package distribution |
| GitHub | `gh` CLI, git push | Version control, issue tracking |
| Beads (bd) | `bd` CLI | Issue tracker integration |

---

## OpenZeus Agent Architecture

### Core Components

```
agents/OpenZeus.md
│
├── YAML Frontmatter (Runtime Configuration)
│   ├── model: "opencode/big-pickle"
│   ├── mode: "all"
│   ├── permissions: [edit, write, webfetch, bash]
│   └── operational params (temperature, steps)
│
├── System Prompt Sections
│   ├── Core Responsibilities
│   ├── Behavior Rules (10 rules)
│   ├── Quick Paths Reference
│   ├── Skill Loading Guide
│   ├── Intent → Skill Mapping
│   ├── Topic → URL Lookup Table
│   ├── Context-Aware Creation Strategy
│   ├── Creation Workflows (Agents, Commands, Skills)
│   ├── Sync Management
│   ├── Self-Improvement Workflow
│   ├── Multi-Skill Workflows
│   └── Performance Monitoring Patterns
```

### Permission Model

**Permission hierarchy:**
```
ALL TOOLS (default)
    │
    ├── edit ──────► File content modification
    ├── write ─────► New file creation
    ├── webfetch ──► HTTP requests
    ├── bash ───────► Shell execution
    │
    └── [runtime-granted] ─► Additional capabilities
```

### Error Handling Patterns

**Rule-based error prevention:**
1. Never push without confirmation
2. Never write secrets to disk
3. Fetch docs before unfamiliar operations
4. Load skills for complex tasks

**Recovery strategies:**
- Proactive documentation fetching on uncertainty
- Skill loading for domain gaps
- Delegation to specialized subagents

---

## File Manifest

| File | Purpose |
|------|---------|
| `OpenZeus.md` | Primary agent definition — Master of OpenCode |
| `codemap.md` | This architectural documentation |

---

## Related Documentation

- **Skills module**: `../skills/codemap.md` — Skill bundle architecture
- **Commands module**: `../commands/` — Slash command templates  
- **Scripts**: `../scripts/sync-utils.sh` — Sync infrastructure
- **OpenCode docs**: https://opencode.ai/docs/agents/
