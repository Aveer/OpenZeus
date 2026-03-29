# commands/ — OpenCode Slash Command Templates

## Responsibility

The `commands/` directory houses **OpenCode slash command templates** — declarative Markdown files that define reusable command interfaces for AI agent operations. Each command template is a self-contained workflow definition that:

- Specifies an agent persona and execution context
- Defines input/output contract via `$ARGUMENTS` placeholder
- Encodes business logic as structured instructions
- Provides safety rules and guardrails for autonomous operations

This directory serves as the **command layer** in OpenZeus's layered architecture: skills provide domain expertise, agents provide reasoning capabilities, and commands provide task entry points.

---

## Design Patterns

### 1. Command Template Pattern

Each command file follows a standardized template structure:

```markdown
---
description: Human-readable description
agent: OpenZeus
---

# Command Name

[Agent persona definition]

## Workflow/Phases/Command Modes

[Step-by-step execution logic]

---

**User's input**: $ARGUMENTS
```

**Key abstractions:**
- **Frontmatter metadata**: `description` (human docs), `agent` (runtime binding)
- **Persona definition**: Sets agent identity and role context
- **Workflow sections**: Sequential execution phases with explicit ordering
- **`$ARGUMENTS` placeholder**: Runtime variable substitution for user input

### 2. State Machine Pattern (Kanban & Roadmap)

Commands managing tasks (kanban, roadmap) implement explicit state transitions:

| Command | States | Transitions |
|---------|--------|-------------|
| `zeus-kanban` | To Do → In Progress → Done | add, inprogress, complete |
| `zeus-roadmap` | Planned → Implemented | add, complete |

State transitions are enforced through:
- Column-based organization in output files
- Checkbox syntax (`[ ]` → `[x]`) for visual state
- Date stamps on completion for auditability

### 3. Multi-Phase Pipeline Pattern (improve-project)

Complex commands use a 5-phase execution pipeline:

```
Analyse → Identify Issues → Plan → Execute → Test
```

Each phase:
- Has explicit deliverables
- May produce artifacts (beads issues, execution plans)
- Must complete before next phase begins
- Can delegate to sub-agents

### 4. Safety Guardrail Pattern (git-commit)

Safety-critical commands embed explicit guardrails:

- **Pre-flight checks**: Scan for secrets, large files, build artifacts before staging
- **Confirmation gates**: Require explicit user approval before destructive operations
- **Flag-based modes**: `--quick`/`-q` flags modify safety behavior
- **Atomic rules**: One logical change per commit, force-push warnings

---

## Data & Control Flow

### Entry Point: Slash Command Invocation

```
User types: /zeus-kanban Tilmandel Fix memory leak
    ↓
OpenCode parses command name: "zeus-kanban"
    ↓
OpenCode locates: ~/.config/opencode/commands/zeus-kanban.md
    ↓
OpenCode replaces $ARGUMENTS with: "Tilmandel Fix memory leak"
    ↓
OpenCode instantiates agent specified in frontmatter (OpenZeus)
    ↓
Agent executes workflow defined in template
```

### Data Flow Diagrams

#### zeus-git-commit Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    INPUT PROCESSING                          │
├─────────────────────────────────────────────────────────────┤
│ 1. Parse flags: --quick, -q, quick, q                       │
│ 2. Analyze: git status, git diff                            │
│ 3. Detect issues: scan for secrets/binaries/artifacts       │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    DECISION GATE                             │
├─────────────────────────────────────────────────────────────┤
│ If secrets/binaries found → Alert user, HALT                │
│ If clean → Proceed                                          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    MESSAGE DRAFTING                          │
├─────────────────────────────────────────────────────────────┤
│ 1. Compose conventional commit message                       │
│ 2. Format: 72-char subject, optional body, issue refs        │
│ 3. Show plan before execution                                │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    EXECUTION                                 │
├─────────────────────────────────────────────────────────────┤
│ git add .                                                    │
│ git commit -m "message"                                      │
│ IF --quick flag → git push (skip confirm)                   │
│ ELSE → Request user confirmation → git push                 │
└─────────────────────────────────────────────────────────────┘
```

#### zeus-kanban/zeus-roadmap Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    INPUT PARSING                             │
├─────────────────────────────────────────────────────────────┤
│ Parse mode: add | inprogress | complete | status             │
│ Extract: user, goal/task                                    │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    FILE OPERATIONS                           │
├─────────────────────────────────────────────────────────────┤
│ Read: docs/team/KANBAN.md or ROADMAP.md                      │
│ If missing → Create from template                           │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    TASK REFINEMENT                           │
├─────────────────────────────────────────────────────────────┤
│ 1. Fix typos/grammar                                        │
│ 2. Improve clarity and style                                │
│ 3. Add category-specific emoji                              │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    STATE TRANSITION                          │
├─────────────────────────────────────────────────────────────┤
│ add:      → Append to To Do/Planned column                   │
│ inprogress: Remove from To Do, add to In Progress            │
│ complete: Remove from In Progress, add to Done (with date)   │
│ status:   Display current board state                        │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    OUTPUT                                    │
├─────────────────────────────────────────────────────────────┤
│ Write: Updated KANBAN.md or ROADMAP.md                       │
│ Report: Summary of changes, original vs refined, stats        │
└─────────────────────────────────────────────────────────────┘
```

#### zeus-improve-project Flow

```
┌─────────────────────────────────────────────────────────────┐
│ PHASE 1: ANALYSE (Self-execution, no delegation)              │
├─────────────────────────────────────────────────────────────┤
│ Read: File structure, tech stack, config, main modules       │
│ Output: Complete project understanding                       │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ PHASE 2: IDENTIFY ISSUES                                     │
├─────────────────────────────────────────────────────────────┤
│ Output: Bug list + Improvement list                         │
│ Format: File/function/line references, no vague findings     │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ PHASE 3: PLAN                                                │
├─────────────────────────────────────────────────────────────┤
│ Output: Ordered execution plan with What/Why/Where/Agent    │
│ Store: Create beads issue for plan                           │
│ Gate: Wait for user confirmation                            │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ PHASE 4: EXECUTE                                             │
├─────────────────────────────────────────────────────────────┤
│ Dispatch agents per plan order and dependency graph          │
│ Verify each output before marking complete                   │
│ Fail twice → Self-execute and report                        │
│ New discoveries → Log to beads for next cycle               │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ PHASE 5: TEST                                                │
├─────────────────────────────────────────────────────────────┤
│ Run existing test suite                                      │
│ Verify changed files have passing tests                      │
│ Flag uncovered changes                                       │
│ Gate: All tests pass or explicit documented failures        │
└─────────────────────────────────────────────────────────────┘
```

### State Transitions

#### Kanban Board States

| User Column | To Do | In Progress | Done |
|-------------|-------|-------------|------|
| Tilmandel   | Task  | Task        | Task |
| Aveer       | Task  | Task        | Task |
| Unassigned  | Task  | Task        | Task |

**Valid transitions:**
- `add` → New task enters **To Do** column
- `inprogress` → Task moves from **To Do** to **In Progress**
- `complete` → Task moves from **In Progress** to **Done** (with completion date)

#### Roadmap States

**Valid transitions:**
- `add` → Feature enters **Planned** section
- `complete` → Feature moves from **Planned** to **Implemented** (with date)

---

## Integration Points

### 1. OpenCode Runtime Integration

| Component | Location | Purpose |
|-----------|----------|---------|
| Command files | `~/.config/opencode/commands/*.md` | Slash command definitions |
| Install hook | `npm postinstall` → `scripts/install.sh` | Copies commands to config |
| Command registry | OpenCode internal | Parses `/zeus-*` commands |

**Installation flow:**
```
npm install openzeus
    ↓ (postinstall hook)
./scripts/install.sh
    ↓
cp commands/zeus-*.md ~/.config/opencode/commands/
```

### 2. File System Integration

| Target File | Directory | Purpose |
|-------------|-----------|---------|
| `KANBAN.md` | `docs/team/` | Team task board (kanban command) |
| `ROADMAP.md` | `docs/team/` | Feature tracking (roadmap command) |

**File creation templates:**

KANBAN.md structure:
```markdown
| User | To Do | In Progress | Done |
|------|-------|-------------|------|
| Tilmandel | - [ ] Task | - [ ] Task | - [x] Task - Date |
```

ROADMAP.md structure:
```markdown
## Planned
- [ ] Feature - description

## Implemented
- [x] Feature - description - Date
```

### 3. Git Integration (zeus-git-commit)

| Operation | Command | Purpose |
|-----------|---------|---------|
| Status check | `git status` | Identify changed files |
| Diff analysis | `git diff` | Detect modifications |
| Staging | `git add .` | Prepare commit |
| Committing | `git commit -m` | Create commit |
| Push | `git push` | Remote sync |

**Safety hooks:**
- Secret detection: `.env`, `*.pem`, `*.key`, API keys, tokens
- Binary detection: files >1MB, images, compiled artifacts
- Artifact detection: `node_modules/`, `__pycache__/`, `*.pyc`

### 4. Beads Issue Tracker Integration

| Phase | Operation | Purpose |
|-------|-----------|---------|
| Phase 3 (Plan) | `bd create` | Store execution plan |
| Phase 4 (Execute) | `bd update` | Track progress |
| Discovery (Execute) | `bd create` | Log new issues for next cycle |

**Beads rules enforced:**
- No TodoWrite/TaskCreate — use `bd` for ALL task tracking
- Plans stored as beads issues before execution
- New discoveries logged to beads (not added to current scope)

### 5. Agent Integration

| Command | Agent Binding | Role |
|---------|--------------|------|
| `zeus-git-commit` | `agent: OpenZeus` | Acts as "gitmaster" persona |
| `zeus-kanban` | `agent: OpenZeus` | Project management assistant |
| `zeus-roadmap` | `agent: OpenZeus` | Project planning assistant |
| `zeus-improve-project` | Implicit OpenZeus | Structured improvement cycles |

### 6. Emoji Category System

Both kanban and roadmap commands use category-based emoji classification:

| Category | Emoji Set |
|----------|-----------|
| 🧪 Testing | `🧪`, ✅, 🐛, 🔍 |
| 🔧 Fixes/Bugs | `🐛`, 🚑, 🔨, ⚙️ |
| ✨ Features | `✨`, 🚀, 🆕, 🎯 |
| 📊 Data/ML | `📊`, 🤖, 📈, 🧠 |
| 🎨 UI/UX | `🎨`, 💅, 🖼️, 🎭 |
| 🔐 Security | `🔐`, 🛡️, 🔒, 🔑 |
| ⚡ Performance | `⚡`, 🚀, 🏎️, ⏱️ |
| 📚 Documentation | `📚`, 📖, 📝, ✍️ |
| 🔄 Refactoring | `♻️`, 🔄, 🧹, 🔧 |
| 📦 Dependencies | `📦`, 📥, 📤, 🔌 |
| 🛠️ Infrastructure | `🏗️`, ☁️, 🚇, ⚙️ |
| 📡 API/Integration | `🔌`, 🌐, 📡, 🔗 |

---

## Command Reference

| Command | File | Modes | Target File | Safety Level |
|---------|------|-------|-------------|--------------|
| `/zeus-git-commit` | `zeus-git-commit.md` | commit, --quick | Git repository | High (guardrails) |
| `/zeus-kanban` | `zeus-kanban.md` | add, inprogress, complete, status | `docs/team/KANBAN.md` | Low |
| `/zeus-roadmap` | `zeus-roadmap.md` | add, complete | `docs/team/ROADMAP.md` | Low |
| `/zeus-improve-project` | `zeus-improve-project.md` | 5-phase workflow | N/A (analysis) | Medium |

---

## File Inventory

| File | Lines | Purpose |
|------|-------|---------|
| `zeus-git-commit.md` | 46 | Git workflow automation with safety checks |
| `zeus-kanban.md` | 119 | Team task board management |
| `zeus-roadmap.md` | 82 | Feature roadmap tracking |
| `zeus-improve-project.md` | 82 | Structured project improvement workflow |
| `codemap.md` | This file | Architectural documentation |

---

*Last updated: 2026-03-29*
