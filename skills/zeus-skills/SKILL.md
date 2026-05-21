---
name: zeus-skills
description: Guide for creating new skills for OpenCode. Use this when the user wants to create a custom skill.
---

# zeus-skills (Skill)

Canonical guide for creating and editing OpenCode skills.

---

## What is a Skill?

A skill is a reusable markdown knowledge bundle loaded by agents with the `skill` tool.

Use a skill when you need:
- Reusable domain knowledge
- Copy-pasteable templates or commands
- Focused troubleshooting/reference material
- A capability that should be shared across sessions or agents

---

## Discovery Paths

OpenCode discovers skills from these locations:

| Scope | Path |
|---|---|
| Project OpenCode | `.opencode/skills/<name>/SKILL.md` |
| Global OpenCode | `~/.config/opencode/skills/<name>/SKILL.md` |
| Project Claude-compatible | `.claude/skills/<name>/SKILL.md` |
| Global Claude-compatible | `~/.claude/skills/<name>/SKILL.md` |
| Project agents-compatible | `.agents/skills/<name>/SKILL.md` |
| Global agents-compatible | `~/.agents/skills/<name>/SKILL.md` |

Prefer `.opencode/skills/` for project-specific skills and `~/.config/opencode/skills/` for user-wide skills.

---

## Skill Directory Structure

```text
skills/
└── my-skill/
    ├── SKILL.md          # Required
    ├── README.md         # Optional human-facing notes
    └── templates/        # Optional supporting files
```

---

## SKILL.md Frontmatter

`SKILL.md` requires YAML frontmatter with `name` and `description`.

```yaml
---
name: my-skill
description: Brief description of what this skill provides.
---
```

| Field | Required | Notes |
|---|---:|---|
| `name` | Yes | Skill identifier; usually matches directory name |
| `description` | Yes | One-line purpose and trigger guidance |
| `license` | No | Recognized optional metadata |
| `compatibility` | No | Recognized optional compatibility notes |
| `metadata` | No | Recognized optional structured metadata |

---

## Minimal Skill Template

````markdown
---
name: my-skill
description: Short purpose and when to use this skill.
---

# my-skill (Skill)

Purpose: Short, concrete purpose statement.

---

## Quick Reference

| Task | Example |
|---|---|
| Do the common thing | `example command` |

---

## Workflow

```bash
# Copy-pasteable commands only
example command --safe-flag
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Skill not loading | Check `<path>/<name>/SKILL.md` and frontmatter |

---

End of skill.
````

---

## Creation Workflow

```text
1. Choose a focused name and one-line description.
2. Create <skill-root>/<name>/SKILL.md.
3. Add required frontmatter: name + description.
4. Write concise sections with tables and copy-pasteable examples.
5. Add optional supporting files only when they reduce clutter.
6. Load/test with skill("<name>") where available.
```

Example:

```bash
mkdir -p ~/.config/opencode/skills/git-master
cat > ~/.config/opencode/skills/git-master/SKILL.md <<'EOF'
---
name: git-master
description: Expert git workflows, branching, rebasing, and troubleshooting.
---

# git-master (Skill)

## Quick Reference

| Task | Command |
|---|---|
| Create branch | `git switch -c feature-name` |
| Show changes | `git diff --stat` |
| Undo last commit | `git reset --soft HEAD~1` |

---

End of skill.
EOF
```

---

## Best Practices

- **One domain per skill**: keep scope narrow.
- **Concise sections**: prefer tables and examples over prose.
- **Safe examples**: avoid destructive commands unless clearly guarded.
- **Stable frontmatter**: preserve `name` and `description` when editing.
- **Portable content**: no secrets, local-only credentials, or brittle paths.
- **Clear ending**: use `---` and `End of skill.` for consistency.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Skill not found | Verify discovery path and directory name |
| Frontmatter ignored | Ensure YAML starts at line 1 and closes with `---` |
| Skill too noisy | Move long examples to supporting files or shorten tables |
| Wrong scope | Use project path for project-specific knowledge; global path for reusable knowledge |

---

## Related Documentation

- OpenCode Skills: https://opencode.ai/docs/skills/
- OpenCode Agents: https://opencode.ai/docs/agents/

---

End of skill.
