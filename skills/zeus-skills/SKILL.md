---
name: zeus-skills
description: Guide for creating new skills for OpenCode. Use this when the user wants to create a custom skill.
---

---

## What is a Skill?

A skill is a reusable capability bundle for OpenCode agents. Skills are markdown files that:
- Provide domain-specific knowledge and templates
- Are loaded on-demand by agents via the `skill` tool
- Live in `~/.config/opencode/skills/` (global) or `<repo>/.opencode/skills/` (project)

---

## Skill Structure

```
skills/
├── my-skill/
│   ├── SKILL.md          # Main skill file (required)
│   ├── README.md         # Optional documentation
│   └── [supporting files] # Optional resources
```

---

## SKILL.md Format

Skills use YAML frontmatter at the top:

```yaml
---
name: my-skill
description: Brief description of what this skill provides.
---

---

## Section 1

[Content...]

## Section 2

[Content...]

---

End of skill.
```

**Required frontmatter fields:**
- `name`: Skill identifier (matches directory name)
- `description`: One-line purpose summary

---

## When to Create a Skill

Create a skill when:
- The user wants reusable domain knowledge
- You keep loading the same reference content
- You want to modularize agent capabilities
- A specific topic deserves deep, focused documentation

---

## Skill Creation Workflow

```
1. Determine skill identity:
   - Name (becomes directory name)
   - Purpose (one-liner)
   - Contents (what sections to include)

2. Create directory:
   - Global: ~/.config/opencode/skills/<name>/
   - Project: <repo>/.opencode/skills/<name>/

3. Write SKILL.md:
   - Start with YAML frontmatter (name + description)
   - Add content sections
   - End with "---" or "End of skill."

4. Optional: Add supporting files (README.md, templates, etc.)

5. Report location and how to use:
   "Skill '<name>' created at ~/.config/opencode/skills/<name>/. 
    Load with: skill('<name>')"
```

---

## Example: Creating a Git Master Skill

### Step 1: Determine identity
- Name: `git-master`
- Purpose: Expert git workflows, branching, rebasing, and troubleshooting

### Step 2: Create directory
```bash
mkdir -p ~/.config/opencode/skills/git-master/
```

### Step 3: Write SKILL.md

```yaml
---
name: git-master
description: Expert git workflows, branching, rebasing, and troubleshooting.
---

---

## Common Git Commands

| Task | Command |
|---|---|
| Create branch | `git checkout -b feature-name` |
| Squash commits | `git rebase -i HEAD~3` |
| Undo last commit | `git reset --soft HEAD~1` |

## Branching Strategies

### GitFlow
- main, develop, feature/*, release/*, hotfix/*

### Trunk-Based
- Short-lived feature branches from main

---

---

End of skill.
```

### Step 4: Report

```
Skill 'git-master' created at ~/.config/opencode/skills/git-master/
Load with: skill('git-master')
```

---

## Example: Creating a Docker Skill

```yaml
---
name: docker-basics
description: Common Docker commands and troubleshooting.
---

---

## Common Commands

| Task | Command |
|---|---|
| Build image | `docker build -t myapp .` |
| Run container | `docker run -d -p 8080:80 myapp` |
| List containers | `docker ps -a` |
| Stop all | `docker stop $(docker ps -q)` |

## Troubleshooting

| Problem | Solution |
|---|---|
| Port already bound | Change port mapping: `-p 8081:80` |
| Out of disk space | `docker system prune -a` |
| Container won't start | `docker logs <container>` |

---

End of skill.
```

---

## Skill Best Practices

1. **Start with Purpose** — One-line description of what the skill provides
2. **Use Tables** — For quick reference tables (commands, troubleshooting)
3. **Include Examples** — Real, copy-pasteable examples
4. **End Clearly** — Use `---` or "End of skill." to mark completion
5. **Keep Focused** — One skill = one domain
6. **Name Clearly** — Skill name should be obvious: `git-master`, `docker-basics`, `python-testing`

---

## Adding Skill to an Agent

To make an agent load a skill, update the agent's skill loading guide:

```markdown
| Skill Name | Load When |
|---|---|
| `my-skill` | When user asks about [topic] |
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Skill not loading | Check path: `~/.config/opencode/skills/<name>/SKILL.md` |
| Skill not found | Ensure directory name matches skill name in `skill()` call |
| Empty skill | Add content to SKILL.md |

---

## Relevant Documentation

- OpenCode Skills: https://opencode.ai/docs/skills/

---

End of skill.
