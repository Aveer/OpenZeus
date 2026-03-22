---
name: zeus-upskill
description: Guide for creating new skills for OpenCode and automatically registering them in OpenZeus. Use this when the user wants to create a custom skill that will be available to OpenZeus.
---

# zeus-upskill (Skill)

Purpose: Guide for creating new skills for OpenCode and automatically registering them in OpenZeus. Use this when the user wants to create a custom skill that will be available to OpenZeus.

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

4. Add skill to OpenZeus:
   - Read ~/.config/opencode/agents/OpenZeus.md
   - Add entry to Skill Loading Guide table:
     | `zeus-<name>` | User asks about [topic] |
   
5. Report location and how to use:
   "Skill '<name>' created at ~/.config/opencode/skills/<name>/.
    Load with: skill('<name>')"
```

---

## Adding to OpenZeus (Required)

After creating the skill, you MUST add it to OpenZeus's skill loading guide:

1. Read `~/.config/opencode/agents/OpenZeus.md`

2. Find the Skill Loading Guide table (starts around line 45)

3. Add new entry:
```markdown
| `zeus-<skill-name>` | User asks about [topic description] |
```

4. Example addition:
```markdown
| `zeus-docker` | User asks about Docker, containers, or containerization |
```

---

## Example: Creating a Docker Skill

### Step 1: Determine identity
- Name: `zeus-docker`
- Purpose: Expert Docker and containerization reference

### Step 2: Create directory
```bash
mkdir -p ~/.config/opencode/skills/zeus-docker/
```

### Step 3: Write SKILL.md
```markdown
# zeus-docker (Skill)

Purpose: Expert Docker and containerization reference.

---

## Common Commands

| Task | Command |
|---|---|
| Build image | `docker build -t myapp .` |
| Run container | `docker run -d -p 8080:80 myapp` |

---

End of skill.
```

### Step 4: Add to OpenZeus
Edit `~/.config/opencode/agents/OpenZeus.md` and add:
```markdown
| `zeus-docker` | User asks about Docker, containers, or containerization |
```

### Step 5: Report
```
Skill 'zeus-docker' created at ~/.config/opencode/skills/zeus-docker/
Added to OpenZeus skill loading guide.
Load with: skill('zeus-docker')
```

---

## Naming Convention

Skills created for OpenZeus should follow the `zeus-<name>` pattern:
- `zeus-beads` — Beads issue tracker
- `zeus-oac` — OpenAgentsControl
- `zeus-docker` — Docker/containerization
- `zeus-aws` — Amazon Web Services

---

## Skill Best Practices

1. **Start with Purpose** — One-line description of what the skill provides
2. **Use Tables** — For quick reference tables (commands, troubleshooting)
3. **Include Examples** — Real, copy-pasteable examples
4. **End Clearly** — Use `---` or "End of skill." to mark completion
5. **Keep Focused** — One skill = one domain
6. **Name Clearly** — Use `zeus-<name>` pattern for OpenZeus skills
7. **Always Register** — Always add to OpenZeus after creation

---

## Two-Repo Structure (Remember)

When updating OpenZeus skills:
- Private repo (`~/.config/opencode/`) — Full changes
- Public repo (`Aveer/OpenZeus`) — User-facing skills only

Update both repos after creating a new skill.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Skill not loading | Check path: `~/.config/opencode/skills/<name>/SKILL.md` |
| Skill not in OpenZeus | Add entry to OpenZeus.md Skill Loading Guide |
| Skill not found | Ensure directory name matches skill name in `skill()` call |
| Empty skill | Add content to SKILL.md |

---

## Relevant Documentation

- OpenCode Skills: https://opencode.ai/docs/skills/
- OpenZeus: https://github.com/Aveer/OpenZeus

---

End of skill.
