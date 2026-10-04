# Repository Atlas: OpenZeus

## Product responsibility

OpenZeus is an OpenCode companion agent for understanding and maintaining the
user's effective OpenCode environment.

The primary interface is `@OpenZeus`. Deterministic CLI/plugin primitives
supply evidence for diagnostics, provenance, compatibility and migration
planning.

## Canonical docs

- Plan: [docs/plans/openzeus-2-refocus.md](docs/plans/openzeus-2-refocus.md)
- Continuity: [docs/continuity/openzeus-2.md](docs/continuity/openzeus-2.md)
- Contributing: [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md)
- Publishing: [docs/PUBLISHING.md](docs/PUBLISHING.md)

## Entry points

| File | Purpose |
|---|---|
| `agents/OpenZeus.md` | Primary conversational agent and routing policy |
| `src/plugin.js` | Native OpenCode V2 plugin entrypoint |
| `bin/openzeus` | Extensionless executable shell entrypoint exposed by npm as `openzeus` |
| `scripts/inspect.mjs` | Filesystem inventory, source precedence and compatibility evidence |
| `scripts/audit.mjs` | Actionable diagnostic summary |
| `scripts/migrate.mjs` | Non-mutating migration planning |
| `scripts/create-utils.sh` | Agent/skill/command authoring primitive |
| `scripts/install-agent.sh` | Transitional one-file @OpenZeus agent bootstrap |
| `scripts/validate.sh` | Structural validation |
| `skills/` | Five focused OpenCode-specific skills |
| `docs/plans/` | Architecture plans |
| `docs/continuity/` | Campaign/session continuity |

## Data flow

```text
user question
   -> @OpenZeus
   -> filesystem evidence (inspect)
   +  current OpenCode schema/runtime context available to the session
   -> focused skill when useful
   -> audit / explanation / migration plan
   -> deliberate mutation only after review
```

## Distribution

The V2 plugin owns:

- five focused `zeus-*` skills;
- native registration of the packaged `skills/` directory.

Current OpenCode V2 plugins cannot add agents, so `agents/OpenZeus.md` still
uses a small guarded `install-agent` bootstrap. That is the only intended
copy-installed OpenZeus asset.

## Durable rules

- Prefer OpenCode-native functionality.
- Resolve user paths at runtime; never commit contributor-specific paths.
- Keep the shipped skill set small and OpenCode-specific.
- Inspect before mutation.
- Use current OpenCode schema/docs instead of copied reference tables.
- Keep migration apply disabled until parser-backed edits, backup, validation
  and rollback are implemented.
