# Repository Atlas: OpenZeus

## Project responsibility

OpenZeus is an OpenCode companion agent. The long-term product is the
conversation-first `@OpenZeus` experience backed by deterministic runtime
inspection, diagnostics, migration and focused asset-authoring capabilities.

OpenZeus does not replace OpenCode and should not duplicate OpenCode-native
features without a concrete reason. It ships no generic slash-command pack.

## Active architecture campaign

- Plan: [plans/openzeus-2-refocus.md](plans/openzeus-2-refocus.md)
- Continuity: [docs/continuity/openzeus-2.md](docs/continuity/openzeus-2.md)

## Entry points

| File | Purpose |
|---|---|
| `agents/OpenZeus.md` | Primary product interface and routing policy |
| `src/plugin.js` | Native OpenCode V2 plugin entrypoint |\n| `bin/openzeus` | Transitional CLI/support entrypoint |\n| `scripts/inspect.mjs` | Deterministic filesystem inventory/provenance foundation |\n| `scripts/audit.mjs` | Actionable audit summary built on inspector evidence |
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

Copy-based install/sync/refresh helpers remain temporarily until native plugin
packaging is proven. Generic project bootstrap, recipes, context generation and
prompt-capture helpers have been removed in favor of OpenCode-native behavior.

## Durable design rules

- OpenCode-native behavior first.
- Runtime discovery, never private hard-coded paths.
- Small OpenCode-specific skill set.
- Inspection before mutation.
- Current schema/docs over copied reference tables.
- Plugin/runtime integration is the target distribution architecture.
