# skills/ — OpenZeus capability map

The skills directory contains focused guidance that extends the OpenZeus agent.
It is intentionally not a general-purpose knowledge library.

## Current inventory

| Skill | Responsibility | Status |
|---|---|---|
| `zeus-core` | Transitional OpenCode operations and troubleshooting | Keep, then reduce |
| `zeus-agents` | Advanced agent design and maintenance | Keep |
| `zeus-commands` | Command design and maintenance | Keep |
| `zeus-skills` | Skill authoring, triggers, discovery and portability | Keep |
| `zeus-upskill` | Extend OpenZeus capabilities | Keep for now |
| `zeus-context` | Project/session context workflows | Merge candidate |
| `zeus-self` | OpenZeus self-diagnostics | Merge candidate |

## Design rule

A skill belongs in OpenZeus core only when it directly helps operate, diagnose,
migrate or author OpenCode itself.

Generic domain expertise and copied documentation for unrelated integrations
do not belong here.

## Native-first rule

OpenCode's current schema, official documentation and built-in customization
knowledge are the source of truth for generic OpenCode syntax. Zeus skills
should encode workflow and durable reasoning patterns, not copy broad API or
configuration reference material that will quickly become stale.

## Skill quality

Every shipped skill should:

- have a precise trigger-oriented `description`;
- be portable across machines;
- avoid credentials and contributor-specific paths;
- prefer current OpenCode terminology;
- state when native OpenCode functionality should be used instead;
- remain small enough to justify on-demand loading.

See `plans/openzeus-2-refocus.md` for the active consolidation plan.
