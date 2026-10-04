# Contributing to OpenZeus

OpenZeus is an OpenCode companion agent. Contributions should improve
OpenCode-specific inspection, diagnostics, migration, or asset design rather
than turn the project back into a general-purpose toolkit.

Read first:

- [OpenZeus 2 plan](plans/openzeus-2-refocus.md)
- [OpenZeus 2 continuity](continuity/openzeus-2.md)
- [Repository atlas](../codemap.md)

## Setup

Use Node **22.19+**.

```bash
git clone https://github.com/Aveer/OpenZeus.git
cd OpenZeus
npm install --ignore-scripts --no-audit --no-fund
npm test
```

Local tracker/tool state such as `.beads/`, `.slim/`, credentials and user
OpenCode config must remain untracked.

## Project structure

| Path | Purpose |
|---|---|
| `agents/OpenZeus.md` | Primary conversational agent |
| `src/plugin.js` | Native OpenCode V2 Promise plugin entrypoint; registers `skills/` as a directory source |
| `skills/` | Five focused OpenCode skills |
| `scripts/inspect.mjs` | Filesystem inventory/provenance |
| `scripts/audit.mjs` | User-facing diagnostics |
| `scripts/migrate.mjs` | Non-mutating migration planning |
| `scripts/create-utils.sh` | Asset authoring primitive |
| `scripts/install-agent.sh` | Transitional one-file agent bootstrap |
| `scripts/validate.sh` | Structural validation |
| `bin/openzeus` | Extensionless npm executable exposed as `openzeus` |
| `docs/plans/` | Architecture plans |
| `docs/continuity/` | Campaign/session continuity |

## Native-first rule

Do not reimplement an OpenCode feature without a concrete reason.

New OpenZeus-owned assets must use current OpenCode V2 conventions:

- ordered `permissions`;
- `shell` rather than legacy `bash`;
- `subagent` rather than `subtask`/`task`;
- no legacy agent `tools`, `permission`, `temperature`, `top_p`,
  `prompt`, `disable`, or `maxSteps` fields;
- no hard-coded model unless the feature explicitly needs one.

## Focused skills

The shipped core is intentionally limited to:

- `zeus-diagnostics`;
- `zeus-migration`;
- `zeus-agents`;
- `zeus-commands`;
- `zeus-skills`.

A new skill must have a clear OpenCode-specific reason to exist. Do not add
generic Docker/SQL/LLM/domain packs or copied documentation for unrelated
plugins.

## Common authoring

Use the CLI primitive when useful:

```bash
openzeus create skill release-workflow "Use for release preparation"
openzeus create agent reviewer "Reviews changes for correctness"
openzeus create command release-notes "Draft release notes"
```

For basic agent scaffolding in normal OpenCode usage, prefer the native:

```bash
opencode agent create
```

## Validation

Before pushing a coherent checkpoint:

```bash
npm test
node tests/plugin.mjs
./bin/openzeus validate --ci
npm pack --dry-run
```

CI runs on branch pushes and is part of the development loop; do not leave a
checkpoint red.

## Migration safety

`openzeus migrate --plan` is non-mutating.

Do not add `--apply` as regex/text replacement. A supported automatic
migration requires:

1. parser-backed understanding;
2. explicit change plan;
3. backup;
4. post-change validation;
5. rollback on failure.

## Privacy and portability

Never commit:

- absolute contributor paths;
- tokens, credentials, private keys, or secret config values;
- user-specific OpenCode configuration;
- transient local tool state.

Resolve user paths at runtime from OpenCode context/environment instead.

## Commit style

Use small, imperative commits that describe one coherent change.

Examples:

```text
feat: add runtime provenance check
fix: preserve agent permission ordering
docs: clarify plugin bootstrap
```

## Pull requests

- explain the user-visible reason for the change;
- include or reference tests for behavior changes;
- note compatibility/migration impact;
- do not include unrelated formatting churn.

## License

Contributions are licensed under the MIT License.
