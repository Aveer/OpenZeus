---
name: zeus-oac
description: Expert reference for OpenAgentsControl (OAC) — a plan-first AI development framework with approval gates, context management, and pattern control for OpenCode. Covers setup, agents, commands, and workflows.
---

# zeus-oac (Skill)

Purpose: Expert reference for OpenAgentsControl (OAC) — a plan-first AI development framework with approval gates, context management, and pattern control for OpenCode. Covers setup, agents, commands, and workflows.

**🔗 OpenAgentsControl Repository**: https://github.com/darrenhinde/OpenAgentsControl

---

## What is OpenAgentsControl?

OAC is an AI agent framework for **plan-first development** with human approval gates. It teaches agents your coding patterns so they generate matching code from the start.

**Key features:**
- **Pattern Control** — Define your patterns once, AI uses them forever
- **Approval Gates** — Review and approve before execution
- **Context System** — Learn YOUR coding standards (MVI principle)
- **Team-Ready** — Shared context files committed to git
- **Token Efficient** — 80% reduction via Minimal Viable Information

**Why use it?**
- Code ships without refactoring
- Team uses consistent patterns
- Human-guided quality control
- No vendor lock-in (any model)

---

## Documentation Links

| Resource | URL |
|---|---|
| Main README | https://github.com/darrenhinde/OpenAgentsControl |
| Quick Start | https://github.com/darrenhinde/OpenAgentsControl#-quick-start |
| Context System | https://github.com/darrenhinde/OpenAgentsControl#-the-context-system-your-secret-weapon |
| Context Guide | https://github.com/darrenhinde/OpenAgentsControl/blob/main/CONTEXT_SYSTEM_GUIDE.md |
| Compatibility | https://github.com/darrenhinde/OpenAgentsControl/blob/main/COMPATIBILITY.md |
| Changelog | https://github.com/darrenhinde/OpenAgentsControl/blob/main/CHANGELOG.md |

---

## Installation

### Option 1: Script (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/darrenhinde/OpenAgentsControl/main/install.sh | bash -s developer
```

### Option 2: Manual

```bash
# Clone the repo
git clone https://github.com/darrenhinde/OpenAgentsControl.git

# Install globally
cd OpenAgentsControl
bash install.sh
```

### Update

```bash
curl -fsSL https://raw.githubusercontent.com/darrenhinde/OpenAgentsControl/main/update.sh | bash
```

---

## Main Agents

| Agent | Purpose | Use Case |
|---|---|---|
| `@OpenAgent` | General tasks, learning | Start here, simple features, questions |
| `@OpenCoder` | Production development | Complex features, multi-file refactoring |

### Subagents (Auto-delegated)

| Agent | Purpose |
|---|---|
| `ContextScout` | Smart pattern discovery |
| `TaskManager` | Breaks features into atomic subtasks |
| `CoderAgent` | Focused code implementations |
| `TestEngineer` | Test authoring and TDD |
| `CodeReviewer` | Code review and security |
| `BuildAgent` | Type checking and validation |
| `ExternalScout` | Fetches live docs for external libraries |

---

## Essential Commands

| Command | Purpose |
|---|---|
| `/add-context` | Interactive wizard to add your patterns |
| `/commit` | Smart git commits (conventional format) |
| `/test` | Testing workflows |
| `/optimize` | Code optimization |
| `/context` | Context management |

---

## The Workflow

```
1. Add Your Context (one time)
   ↓
2. ContextScout discovers relevant patterns
   ↓
3. Agent loads YOUR standards
   ↓
4. Agent proposes plan (you approve)
   ↓
5. You approve
   ↓
6. Agent implements (matches your patterns)
   ↓
7. Ships without refactoring ✅
```

---

## The Context System (MVI Principle)

### How It Works

```
Your Request
    ↓
ContextScout discovers relevant patterns
    ↓
Agent loads YOUR standards
    ↓
Code generated using YOUR patterns
    ↓
Ships without refactoring ✅
```

### Add Your Patterns

```bash
/add-context
```

Answer 6 questions:
1. What's your tech stack?
2. Show an API endpoint example
3. Show a component example
4. What naming conventions?
5. Any code standards?
6. Any security requirements?

### MVI (Minimal Viable Information)

Files designed for quick loading:
- **Concepts:** <100 lines
- **Guides:** <150 lines
- **Examples:** <80 lines

Result: 80% token reduction vs loading entire codebase.

---

## Approval Gates

Agents ALWAYS request approval before:
- Writing/editing files
- Running bash commands
- Delegating to subagents
- Making any changes

**You stay in control.** Review plans before execution.

---

## For Teams

### Store Patterns in Git

```bash
# Team lead adds patterns once
/add-context

# Commit to repo
git add .opencode/context/
git commit -m "Add team coding standards"
git push

# All team members use same patterns automatically
```

### Context Resolution

```
1. Check local: .opencode/context/core/navigation.md
   ↓ Found? → Use local for everything
   ↓ Not found?
2. Check global: ~/.config/opencode/context/core/navigation.md
   ↓ Found? → Use global for core/ only
   ↓ Not found? → Proceed without core context
```

**Key rules:**
- Local always wins
- Global fallback is only for `core/`
- Project intelligence is always local

---

## Configuration

### Edit Agent Behavior

Agents are markdown files you can edit directly:

```bash
# Local project
nano .opencode/agent/core/opencoder.md

# Global
nano ~/.config/opencode/agent/core/opencoder.md
```

### Change Model Per Agent

Edit the agent file and change the model in frontmatter:

```yaml
---
description: "Development specialist"
model: anthropic/claude-sonnet-4-5
---
```

---

## When to Use OAC

### ✅ Use OAC if you:
- Build production code that ships without heavy rework
- Work in a team with established coding standards
- Want control over agent behavior
- Care about token efficiency and cost savings
- Need approval gates for quality assurance

### ⚠️ Skip OAC if you:
- Want fully autonomous execution without approval gates
- Prefer "just do it" mode
- Don't have established coding patterns yet
- Need multi-agent parallelization (use oh-my-opencode-slim instead)

---

## Comparison

| Feature | OAC | Cursor/Copilot | Aider | Oh My OpenCode |
|---------|-----|----------------|-------|----------------|
| Learn Your Patterns | ✅ Built-in | ❌ | ❌ | ⚠️ Manual |
| Approval Gates | ✅ Always | ⚠️ Optional | ❌ | ❌ |
| Token Efficiency | ✅ MVI (80%) | ❌ Full | ❌ Full | ❌ High |
| Team Standards | ✅ Shared | ❌ | ❌ | ⚠️ Manual |
| Edit Agent Behavior | ✅ Markdown | ❌ | ⚠️ Limited | ✅ Config |
| Model Agnostic | ✅ Any | ⚠️ Limited | ⚠️ OAI/Claude | ✅ Multiple |

---

## Troubleshooting

| Problem | Solution |
|---|---|
| Commands not found | Restart OpenCode after install |
| Context not loading | Run `/add-context` to set up patterns |
| Token usage high | Ensure MVI compliance (<200 lines per file) |
| Approval prompts annoying | Use `@OpenAgent` instead of `@OpenCoder` |

---

## Related

| Resource | URL |
|---|---|
| GitHub | https://github.com/darrenhinde/OpenAgentsControl |
| Plugin | Local: `~/.config/opencode/plugins/OAC/` |
| Community | https://nextsystems.ai |

---

End of skill.
