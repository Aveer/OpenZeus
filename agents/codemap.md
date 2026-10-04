# agents/ — OpenZeus agent

## Responsibility

`agents/OpenZeus.md` defines the conversational OpenZeus companion.

It is intentionally the only shipped agent. Current OpenCode V2 plugin APIs can
register skills/tools/commands but cannot add a new agent, so this file remains
a transitional bootstrap asset.

## Current format

OpenZeus uses native-current agent conventions:

```yaml
---
description: ...
mode: all
permissions:
  - action: edit
    resource: "*"
    effect: ask
  - action: shell
    resource: "*"
    effect: ask
  - action: skill
    resource: "zeus-*"
    effect: allow
  - action: openzeus_runtime
    resource: "*"
    effect: allow
---
```

Do not reintroduce legacy `permission`, `bash`, `tools`, `temperature`,
`top_p`, `prompt`, `disable`, or `maxSteps` fields.

## Model behavior

No model is pinned. OpenZeus should inherit the user's configured/session model
unless the user explicitly chooses otherwise.

## Skill routing

| Need | Skill |
|---|---|
| Diagnostics / precedence / provenance | `zeus-diagnostics` |
| Migration planning | `zeus-migration` |
| Advanced agent design | `zeus-agents` |
| Command design | `zeus-commands` |
| Skill authoring | `zeus-skills` |

## Evidence sources

Prefer:

1. `openzeus_runtime` for live OpenCode version/location/registry inventory;
2. `openzeus inspect --json` for filesystem provenance/collisions;
3. current OpenCode schema/docs for exact syntax;
4. `openzeus migrate --plan --json` when compatibility findings need a
   concrete non-mutating migration plan.

## Safety

- Never hard-code user-specific absolute paths in reusable assets.
- Never print secret values for diagnostic proof.
- Ask before destructive, publishing, credential, or remote mutations.
- Preserve behavior when proposing migrations.
