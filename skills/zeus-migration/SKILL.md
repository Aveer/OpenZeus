---
name: zeus-migration
description: Plan and verify OpenCode configuration migrations, especially V1-to-V2 changes. Use when legacy fields, old plugin APIs, tui.json, or deprecated agent/command syntax are present.
---

# OpenCode migration

Migrate behavior, not formatting for its own sake.

## Workflow

1. Inspect the complete relevant config/asset.
2. Identify only legacy, unsupported or conflicting fields.
3. Confirm current representation from the migration guide/schema.
4. Produce a plan before mutation.
5. Preserve unrelated settings and IDs.
6. Back up user-owned config before applying changes.
7. Apply the smallest coherent migration.
8. Validate and explain remaining compatibility behavior.

## Common mappings

| V1 | Native V2 |
|---|---|
| `permission` | ordered `permissions` |
| `bash` permission action | `shell` |
| `task` permission action | `subagent` |
| `write` / `patch` permission actions | `edit` |
| agent `disable` | `disabled` |
| command map `command` | `commands` |
| command `subtask` | `subagent` |
| separate model variant | `provider/model#variant` |
| skill paths/URLs maps | ordered `skills` array |
| plugin config `plugin` | `plugins` |
| V1 terminal `tui.json(c)` | global V2 `cli.json` |

V1 plugin implementations require a real V2 plugin port; renaming config is not
sufficient.

Prefer plural V2 asset directories for new files. Keep existing IDs stable when
moving assets.

Reference: `https://opencode.ai/v2/docs/migrate-v1`.
