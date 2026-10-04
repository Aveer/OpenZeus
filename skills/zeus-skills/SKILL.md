---
name: zeus-skills
description: Create and review portable OpenCode skills. Use for SKILL.md authoring, trigger descriptions, discovery/precedence, supporting files, collisions, or skill portability.
---

# OpenCode skill authoring

OpenCode already discovers and loads skills. OpenZeus helps design skills that
are focused, discoverable, portable and collision-safe.

## Preferred shape

```text
.opencode/skills/release/
├── SKILL.md
├── references/
└── scripts/
```

```markdown
---
name: Release
description: Prepare repository releases, changelogs, version bumps and tags. Use when the user asks to cut or validate a release.
---

# Release workflow
...
```

The path determines the skill ID. Keep portable IDs unique, lowercase,
kebab-case and aligned with the directory name.

A clear description matters because it is what OpenCode advertises for model
discovery.

Keep large references/scripts/templates beside `SKILL.md` and use relative
paths. Never embed contributor-specific absolute paths, credentials or
transient local state.

For missing/wrong skills, use `zeus-diagnostics`.
