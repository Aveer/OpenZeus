# Repository Atlas: OpenZeus

## Project responsibility

OpenZeus is an OpenCode companion agent. The long-term product is the
conversation-first `@OpenZeus` experience backed by deterministic runtime
inspection, diagnostics, migration and focused asset-authoring capabilities.

OpenZeus does not replace OpenCode and should not duplicate OpenCode-native
features without a concrete reason.

## Active architecture campaign

- Plan: [plans/openzeus-2-refocus.md](plans/openzeus-2-refocus.md)
- Continuity: [docs/continuity/openzeus-2.md](docs/continuity/openzeus-2.md)

## Entry points

| File | Purpose |
|---|---|
| `agents/OpenZeus.md` | Primary product interface and routing policy |
| `bin/openzeus` | Transitional CLI/support entrypoint |
| `skills/` | Focused OpenCode authoring/diagnostic guidance |
| `scripts/install.sh` | Transitional copy-based installer |
| `scripts/doctor.sh` | Installed-bundle health checks |
| `scripts/validate.sh` | Structural validation |
| `scripts/diff.sh` | Installed-bundle drift checks |
| `README.md` | User-facing product explanation |
| `plans/` | Canonical architectural plans |

## Target data flow

```text
user question
   -> @OpenZeus
   -> inspect effective OpenCode runtime/config state
   -> load focused skill only when useful
   -> explain evidence / precedence / compatibility
   -> plan before mutation
   -> validate after mutation
```

## Transitional 1.x surface

The repository still contains setup, sync, capture, context and upgrade helpers
from the 1.x product direction. They remain until replacement behavior is
designed and tested; they should not drive new architecture.

## Durable design rules

- OpenCode-native behavior first.
- Runtime discovery, never private hard-coded paths.
- Small OpenCode-specific skill set.
- Inspection before mutation.
- Current schema/docs over copied reference tables.
- Plugin/runtime integration is the target distribution architecture.
