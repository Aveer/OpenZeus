# Repository Atlas: OpenZeus

## Project responsibility

OpenZeus is an OpenCode companion agent. The long-term product is the
conversation-first `@OpenZeus` experience backed by deterministic runtime
inspection, diagnostics, migration and focused asset-authoring capabilities.

OpenZeus should not duplicate OpenCode-native features without a concrete reason. It ships no generic slash-command pack.

## Active architecture campaign

- Plan: [docs/plans/openzeus-2-refocus.md](docs/plans/openzeus-2-refocus.md)
- Continuity: [docs/continuity/openzeus-2.md](docs/continuity/openzeus-2.md)

## Entry points

| File | Purpose |
|---|---|
| `agents/OpenZeus.md` | Primary product interface and routing policy |
| `src/plugin.js` | Native OpenCode V2 plugin entrypoint |\n| `bin/openzeus` | Extensionless executable shell entrypoint exposed by npm as the `openzeus` command |\n| `scripts/inspect.mjs` | Deterministic filesystem inventory/provenance foundation |\n| `scripts/audit.mjs` | Actionable audit summary built on inspector evidence |
| `skills/` | Focused OpenCode authoring/diagnostic guidance |
| `scripts/install-agent.sh` | Transitional one-file @OpenZeus agent bootstrap |
| `scripts/validate.sh` | Structural validation |
| `README.md` | User-facing product explanation |
| `docs/plans/` | Canonical architectural plans |

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

The V2 plugin owns the focused skills and live runtime tool. The only remaining
copy bootstrap is the agent Markdown file because OpenCode V2 currently cannot
add agents from plugins.

## Durable design rules

- OpenCode-native behavior first.
- Runtime discovery, never private hard-coded paths.
- Small OpenCode-specific skill set.
- Inspection before mutation.
- Current schema/docs over copied reference tables.
- Plugin/runtime integration is the target distribution architecture.
