---
name: zeus-upskill
description: Guide for creating new skills for OpenCode and automatically registering them in OpenZeus. Use this when the user wants to create a custom skill that will be available to OpenZeus.
---

# zeus-upskill (Skill)

Purpose: Create an OpenZeus `zeus-*` skill and wire it into OpenZeus distribution metadata and documentation workflows.

For general skill concepts, structure, frontmatter, and discovery paths, load `zeus-skills` first.

---

## Scope Boundary

| Need | Use |
|---|---|
| Learn what a skill is | `zeus-skills` |
| Create/edit generic OpenCode skills | `zeus-skills` |
| Add a new `zeus-*` OpenZeus skill | `zeus-upskill` |
| Register skill metadata/README entries | `zeus-upskill` |

---

## OpenZeus Skill Workflow

```text
1. Load zeus-skills for canonical SKILL.md rules.
2. Choose name: zeus-<topic>.
3. Create skills/zeus-<topic>/SKILL.md in the OpenZeus repo.
4. Preserve required frontmatter: name + description.
5. Add concise, example-driven content.
6. Register the skill in OpenZeus metadata/README tables when in scope.
7. Sync repo changes to runtime config when project policy requires it.
```

---

## Naming Convention

OpenZeus skills use `zeus-<name>`:

| Example | Responsibility |
|---|---|
| `zeus-core` | OpenCode internals reference |
| `zeus-agents` | Agent creation templates |
| `zeus-commands` | Command creation templates |
| `zeus-docker` | Docker/containerization reference |

---

## Minimal OpenZeus Skill

````markdown
---
name: zeus-example
description: Expert reference for example workflows. Use this when the user asks about examples.
---

# zeus-example (Skill)

Purpose: Expert reference for example workflows.

---

## Quick Reference

| Task | Command |
|---|---|
| Show status | `example status` |

---

End of skill.
````

---

## Registration Checklist

When the task scope allows editing the relevant files, update:

| File | Update |
|---|---|
| `skills/zeus-<name>/SKILL.md` | New skill content |
| `README.md` | Skill table/feature list entry |
| `agents/OpenZeus.md` | Skill loading trigger, if maintained there |
| `skills/codemap.md` | Skill taxonomy/responsibility notes |

OpenZeus currently has no generated central metadata manifest; if one is added later, update it as part of this checklist.

Do not edit files outside the user-approved scope. If registration files are out of scope, report the exact follow-up edits.

---

## Runtime Sync Notes

OpenZeus maintains repo and runtime config copies. After approved repo edits, follow project policy for sync, commonly:

```bash
./scripts/sync-utils.sh push
```

Only run sync when scripts are in scope and the user/project instructions authorize it.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Skill created but not listed | Add README/metadata entries when in scope |
| Skill not available at runtime | Sync repo to `~/.config/opencode/skills/` per project policy |
| Duplicate guidance with `zeus-skills` | Keep general skill rules in `zeus-skills`; keep registration here |
| Registration file out of scope | Leave skill file complete and report follow-up needed |

---

## Related Documentation

- Canonical skill guide: `zeus-skills`
- OpenCode Skills: https://opencode.ai/docs/skills/
- OpenZeus: https://github.com/Aveer/OpenZeus

---

End of skill.
