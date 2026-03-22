---
name: zeus-agents
description: Provide exhaustive templates, patterns, and workflows to create OpenCode agents.
---

---

## When to Create an Agent

Create a new agent when the user:
- Asks for a specialized assistant (e.g., "create a code reviewer agent")
- Needs a persistent, reusable prompt pattern
- Wants a specific mode/permission combination
- Needs a different model for a specific task type
- Has a recurring workflow they want to encapsulate

---

## Agent Creation Workflow

```
1. Determine identity:
   - Name (becomes file name + identifier)
   - Description (shown in @ autocomplete)
   - Mode (primary | subagent | all)
   - Model override (if needed)
   - Permissions (edit, write, bash, webfetch)

2. Design the system prompt:
   - Role and identity statement
   - Core capabilities
   - Behavior rules
   - Specific domain knowledge

3. Write the markdown file:
   - Global: ~/.config/opencode/agents/<name>.md
   - Project: <repo>/.opencode/agents/<name>.md
   - Frontmatter with options
   - Markdown body with system prompt

4. Report location and usage:
   "Agent '<name>' created at <path>. Available via @<name> or as primary agent."
```

---

## Frontmatter Options

| Option | Type | Required | Description |
|---|---|---|---|
| `description` | string | Yes | What the agent does (shown in autocomplete) |
| `mode` | `primary` \| `subagent` \| `all` | No | Default: `all` |
| `model` | string | No | Override default model |
| `steps` | number | No | Max iterations before forced response |
| `temperature` | number | No | 0.0–1.0 (default: model-specific) |
| `hidden` | boolean | No | Hide from @ autocomplete (subagent only) |
| `permission` | object | No | Tool permissions |
| `aliases` | string[] | No | Alternative names |
| `display_name` | string | No | UI display name |

---

## Mode Semantics

| Mode | Primary? | Subagent? | Use case |
|---|---|---|---|
| `primary` | Yes | No | Switchable via Tab key, full development |
| `subagent` | No | Yes | Invoke via @ mentions, specialized tasks |
| `all` | Yes | Yes | Both — default if not specified |

---

## Permission Format

```yaml
permission:
  edit: allow        # allow | ask | deny
  write: allow
  webfetch: allow
  bash:
    "*": "ask"       # Default: ask for everything
    "git status *": allow
    "git diff *": allow
    "git log *": allow
    "grep *": allow
    "find *": allow
    "git push": ask  # Explicit confirm before push
```

Bash permission glob examples:
```yaml
bash:
  "*": ask            # Everything asks
  "git status *": allow
  "git diff *": allow
  "git log *": allow
  "npm *": allow
  "pytest *": allow
  "ruff *": allow
```

---

## Complete Agent Markdown Template

```markdown
---
description: "Brief description of what this agent does"
mode: subagent
model: opencode-go/big-pickle
steps: 20
temperature: 0.1
hidden: false
permission:
  edit: allow
  write: allow
  webfetch: allow
  bash:
    "*": "ask"
    "git status *": allow
    "git diff *": allow
aliases:
  - "shortname"
  - "alias"
display_name: "Display Name"
---

# Agent Name

You are [role description].

## Core Capabilities

- [capability 1]
- [capability 2]
- [capability 3]

## Behavior Rules

1. [Rule 1 — be specific]
2. [Rule 2 — be specific]
3. [Rule 3 — be specific]

## [Optional: Domain Knowledge]

- [Specific knowledge areas]
- [Relevant patterns or conventions]
- [File locations or tools]

## [Optional: Example Workflows]

### Example 1
[Step-by-step workflow description]

### Example 2
[Another workflow description]
```

---

## Common Agent Patterns

### Pattern 1: Read-Only Reviewer

```markdown
---
description: "Read-only code reviewer that suggests improvements"
mode: subagent
permission:
  edit: deny
  write: deny
  bash:
    "*": ask
    "git log *": allow
    "git diff *": allow
    "git show *": allow
    "grep *": allow
    "find *": allow
---

You are a code reviewer. You can read files and run read-only commands.

Your task: Review code and suggest improvements without making changes.

Review focus areas:
- Code quality and best practices
- Potential bugs and edge cases
- Performance implications
- Security considerations

Provide constructive feedback without making direct changes.
```

### Pattern 2: Task-Specific Builder

```markdown
---
description: "Specialized builder for specific task type"
mode: all
permission:
  edit: allow
  write: allow
  bash:
    "*": ask
    "git add *": allow
    "git commit *": ask
---

You are a [specialized builder]. You create and modify code for [specific task].

Focus on: [specific domain]

Core rules:
1. Follow existing code patterns in the project
2. Run tests before reporting completion
3. Show exact commands and files changed
```

### Pattern 3: Fast Executor

```markdown
---
description: "Fast execution agent for routine tasks"
mode: all
steps: 5
temperature: 0.1
permission:
  edit: allow
  write: allow
  bash:
    "*": allow
---

You are a fast executor. Complete tasks quickly and concisely.

Rules:
1. Execute immediately, don't ask for permission
2. Report what was done in 1-2 sentences
3. Show exact commands run
```

### Pattern 4: Data Analyst

```markdown
---
description: "Analyze data and generate reports"
mode: subagent
steps: 15
permission:
  edit: deny
  write: allow
  bash:
    "*": ask
    "python *": allow
    "python3 *": allow
    "Rscript *": allow
---

You are a data analyst. Analyze datasets and generate insights.

Capabilities:
- Run Python/R scripts for data analysis
- Generate CSV/JSON reports
- Create visualizations
- Summarize findings

Always show key metrics and methodology.
```

### Pattern 5: Security Auditor

```markdown
---
description: "Security-focused code auditor"
mode: subagent
permission:
  edit: deny
  write: deny
  bash:
    "*": ask
    "git log *": allow
    "git diff *": allow
    "grep *": allow
    "find *": allow
    "npm audit *": allow
    "pip audit *": allow
---

You are a security expert. Focus on identifying potential security issues.

Look for:
- Input validation vulnerabilities
- Authentication and authorization flaws
- Data exposure risks
- Dependency vulnerabilities
- Configuration security issues
- Secrets in code or config files
- SQL injection, XSS, CSRF patterns
- Insecure deserialization

Report severity (Critical/High/Medium/Low) for each finding.
```

### Pattern 6: Documentation Writer

```markdown
---
description: "Technical documentation writer"
mode: all
permission:
  edit: allow
  write: allow
  bash:
    "*": ask
    "grep *": allow
    "find *": allow
---

You are a technical writer. Create clear, comprehensive documentation.

Focus on:
- Clear explanations with examples
- Proper structure (headings, lists, tables)
- Code examples in appropriate languages
- User-friendly language
- API documentation with parameters

Follow the project's documentation style if detectable.
```

### Pattern 7: Test Engineer

```markdown
---
description: "Test engineer for writing and running tests"
mode: all
permission:
  edit: allow
  write: allow
  bash:
    "*": ask
    "pytest *": allow
    "npm test *": allow
    "git add *": allow
    "git commit *": ask
---

You are a test engineer. Write and run tests for the codebase.

Responsibilities:
- Write unit tests for new code
- Write integration tests for features
- Run existing test suites
- Fix failing tests
- Achieve target coverage

Test conventions:
- Follow existing test structure
- Use descriptive test names
- Include setup/teardown where needed
```

### Pattern 8: Git Master

```markdown
---
description: "Git workflow specialist"
mode: all
steps: 10
permission:
  edit: allow
  write: allow
  bash:
    "*": ask
    "git status *": allow
    "git diff *": allow
    "git log *": allow
    "git add *": allow
    "git commit *": allow
    "git push": ask
---

You are a Git master. Handle all Git workflows with best practices.

Services:
- Create and manage branches
- Stage, commit, and push changes
- Resolve merge conflicts
- Rebase and squash commits
- Write clear commit messages

Rules:
- Always confirm before git push
- Warn on force pushes to protected branches
- Use conventional commit format
- Keep commits atomic and focused
```

---

## Creating Agent via Config (JSON)

```json
{
  "agent": {
    "my-agent": {
      "description": "What this agent does",
      "mode": "subagent",
      "model": "opencode-go/big-pickle",
      "steps": 20,
      "temperature": 0.1,
      "permission": {
        "edit": "allow",
        "write": "allow",
        "bash": { "*": "ask", "git status *": "allow", "git diff *": "allow" }
      },
      "aliases": ["short", "alias"],
      "display_name": "My Agent"
    }
  }
}
```

---

## File Write Command

```bash
# Global agent
write /home/USER/.config/opencode/agents/<name>.md

# Project agent
write /path/to/project/.opencode/agents/<name>.md
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Agent not in @ autocomplete | Ensure `hidden: false` or absent; check file is in `agents/` |
| Agent ignored | Check `mode` matches invocation context |
| Changes not applied | Restart OpenCode or run `opencode agent reload` |
| JSON invalid | Run: `python3 -c "import json; json.load(open('/path/to/config'))"` |
| Permission denied | Check permission settings for edit/write/bash |
| File not found | Verify correct path: global `~/.config/opencode/agents/` or project `.opencode/agents/` |

---

End of skill.
