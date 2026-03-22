---
name: zeus-commands
description: Provide exhaustive templates, patterns, and workflows to create OpenCode custom commands.
---

---

## When to Create a Command

Create a new command when the user:
- Has a repetitive task they want to automate
- Wants a quick shortcut for a complex workflow
- Needs to pass arguments to a template prompt
- Wants to inject shell output or file content into a prompt
- Wants to use a specific model or agent for a task

---

## Command Creation Workflow

```
1. Determine identity:
   - Name (becomes file name, e.g., "deploy.md" → /deploy)
   - Description (shown in TUI when typing /)
   - Agent (which agent to invoke)

2. Design the template:
   - Instructions for the agent
   - Use $ARGUMENTS for user input
   - Use !`command` to inject shell output
   - Use @filename to include file content

3. Write the markdown file:
   - Global: ~/.config/opencode/commands/<name>.md
   - Project: <repo>/.opencode/commands/<name>.md

4. Report: "Command /<name> created at <path>"
```

---

## Frontmatter Options

| Option | Type | Required | Description |
|---|---|---|---|
| `description` | string | Yes | Shown in TUI when typing / |
| `agent` | string | No | Which agent to invoke (default: current agent) |
| `model` | string | No | Override model for this command |
| `subtask` | boolean | No | Force subagent invocation |

---

## Special Placeholders

| Placeholder | Expands to | Example |
|---|---|---|
| `$ARGUMENTS` | Everything after command name | `/deploy production` → "production" |
| `$1`, `$2`...`$9` | Positional arguments | `/create user alice admin` → $1="user", $2="alice", $3="admin" |
| `!`command`` | Bash output injected | `!`git status`` → git status output |
| `@filename` | File content included | `@README.md` → README.md contents |

### Placeholder Examples

#### $ARGUMENTS — All remaining args as one string

```
/component Button
```
Template: `Create a component named $ARGUMENTS`
Result: `Create a component named Button`

#### $1, $2, $3 — Positional arguments

```
/create user alice admin
```
Template: `Create a $1 named $2 with role $3`
Result: `Create a user named alice with role admin`

#### !`command` — Shell output injection

```
---
description: Review recent changes
---
Recent commits:
!`git log --oneline -5`

Changed files:
!`git diff --stat`

Review these changes.
```

#### @filename — File content inclusion

```
---
description: Review file
---
Review this file:
@$ARGUMENTS
```

---

## Complete Command Markdown Template

```markdown
---
description: "Brief description of what this command does"
agent: general
model: opencode-go/big-pickle
subtask: false
---

[Template body with instructions and placeholders]

[Use $ARGUMENTS, $1, $2 for input]
[Use !`command` for shell output]
[Use @filename for file inclusion]
```

---

## Common Command Patterns

### Pattern 1: Simple Task Command

```markdown
---
description: Run tests with coverage
agent: build
---

Run the full test suite with coverage report and show any failures.
Focus on the failing tests and suggest fixes.
```

### Pattern 2: Argument-Based Task

```markdown
---
description: Create a new React component with TypeScript
agent: build
---

Create a new React component named $ARGUMENTS with TypeScript support.
Include proper typing and basic structure.
```

### Pattern 3: Multi-Argument Command

```markdown
---
description: Create a database migration
agent: build
---

Create a new database migration:
- Table name: $1
- Action: $2 (create/drop/alter)
- Fields: $3

Output the migration file to db/migrations/
```

### Pattern 4: Shell-Output-Injection

```markdown
---
description: Review recent git changes
agent: general
---

Recent git commits:
!`git log --oneline -10`

Changed files:
!`git diff --stat`

Review these changes and suggest improvements.
```

### Pattern 5: File-Inclusion

```markdown
---
description: Review a specific file
agent: general
---

Review the following file for bugs and improvements:
@$ARGUMENTS
```

### Pattern 6: Status Report Command

```markdown
---
description: Show project status
agent: general
---

Project status:
!`git status`

Recent changes:
!`git log --oneline -5`

Current branch: !`git branch --show-current`

Provide a summary of the project state.
```

### Pattern 7: Deploy Command

```markdown
---
description: Deploy to environment
agent: build
---

Deploy application to $ARGUMENTS environment.

Steps:
1. Run tests: !`npm test`
2. Build: !`npm run build`
3. Deploy: !`deploy $ARGUMENTS`

Report deployment status.
```

### Pattern 8: Code Analysis

```markdown
---
description: Analyze code complexity
agent: general
---

Analyze the codebase for complexity issues.

File structure:
!`find . -name "*.py" -o -name "*.js" | head -20`

Line counts:
!`wc -l !`find . -name "*.py" -o -name "*.js"` | sort -n | tail -10`

Report top 5 most complex files.
```

---

## Creating Command via Config (JSON)

```json
{
  "command": {
    "my-command": {
      "template": "Template body with $ARGUMENTS...",
      "description": "What this command does",
      "agent": "general",
      "model": "opencode-go/big-pickle",
      "subtask": false
    }
  }
}
```

---

## File Write Command

```bash
# Global command
write ~/.config/opencode/commands/<name>.md

# Project command
write /path/to/project/.opencode/commands/<name>.md
```

---

## Command vs Agent

| Aspect | Command | Agent |
|---|---|---|
| Trigger | `/name` in TUI | `@name` or Tab switch |
| Template | Yes — prompt template | Yes — system prompt |
| Arguments | Yes — $ARGUMENTS, $1-$9 | No (unless combined) |
| Shell injection | Yes — !`command` | No |
| Mode | Always subtask | Primary or subagent |
| Persistence | Ephemeral template | Persistent persona |

Commands are great for: repetitive workflows, injecting context, running specific agents.
Agents are great for: persistent personas, complex reasoning, multi-step tasks.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Command not found | Check file is in `commands/` with correct name |
| Overrides built-in | Custom commands can override `/init`, `/help`, etc. |
| Placeholders not replaced | Use exact syntax: `$ARGUMENTS`, `$1`, `!`command`` |
| Arguments not parsing | Check positional markers `$1`/`$2` match usage |
| Wrong agent invoked | Set `agent` in frontmatter |
| Model not overridden | Set `model` in frontmatter |

---

End of skill.
