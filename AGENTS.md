# OpenZeus Developer Guide

This file defines repository-level rules for agents and contributors working on OpenZeus.

## Product

OpenZeus is an OpenCode companion agent. Its target responsibilities are:

- inspect the user's effective OpenCode environment;
- explain source/provenance, precedence and shadowing;
- diagnose configuration and discovery problems;
- plan safe migrations to current OpenCode formats;
- help design high-quality OpenCode agents, skills and commands.

OpenZeus is not a replacement for OpenCode and not a generic knowledge pack.

Before architecture work, read:

1. `plans/openzeus-2-refocus.md`
2. `docs/continuity/openzeus-2.md`
3. `codemap.md`

## Active branch policy

The OpenZeus 2 campaign is developed on a work branch until a coherent
checkpoint is ready. Do not publish npm releases or tags from refocus branches.

Keep plans in `/plans` and campaign continuity in `docs/continuity/`.
Do not create evidence branches, report branches, or parallel tracking layers.

## Native-first rule

Prefer current OpenCode-native behavior over OpenZeus wrappers.

For exact OpenCode configuration shapes, use the current OpenCode schema and
official V2 docs. New OpenZeus-owned assets must use native-current syntax.

In particular:

- use ordered `permissions` rules, not legacy `permission`;
- use permission action `shell`, not `bash`;
- use `subagent`, not legacy `subtask`/`task`;
- do not generate legacy top-level agent request fields such as
  `temperature`, `top_p`, `prompt`, `tools`, `disable`, or
  `maxSteps`;
- do not hard-code a model unless the feature specifically requires one.

## Privacy and portability

Never commit:

- contributor-specific absolute paths;
- credentials, tokens, private keys, or copied local secrets;
- transient local tool state.

Resolve user/config paths at runtime. Examples should use portable placeholders
or environment variables.

## Scope boundary

A shipped skill or command must directly serve OpenCode operation, diagnosis,
migration, or authoring.

Do not add generic domain packs or copied documentation for unrelated tools.
If an external integration becomes valuable, implement a real optional adapter
rather than mirroring its documentation in a skill.

## Build and validation

Run:

```bash
npm test
./bin/openzeus validate --ci
npm pack --dry-run
```

For an isolated bootstrap check:

```bash
export OPENCODE_CONFIG_DIR="$(mktemp -d)"
./bin/openzeus install-agent
cmp agents/OpenZeus.md "$OPENCODE_CONFIG_DIR/agents/OpenZeus.md"
```

CI runs on branch pushes. A feature checkpoint is not complete while CI is
red.

## Code conventions

### Bash

- `#!/bin/bash`
- `set -euo pipefail`
- quote path/user variables;
- default to non-mutating behavior;
- use `--dry-run`/plan flows for consequential changes where practical;
- do not silently overwrite user-owned files.

### Node

Runtime-inspection code should:

- avoid network access unless explicitly part of the contract;
- never print secret values;
- expose machine-readable JSON when the agent needs deterministic evidence;
- report unresolved runtime-only information as a limitation instead of
  guessing.

### Markdown assets

Skills require `name` and trigger-oriented `description` frontmatter.

Agents require a useful `description`; use current OpenCode modes and
permissions.

Commands should represent genuinely reusable workflows rather than trivial
prompt aliases.

## Git and remote mutations

Normal commits/pushes on the authorized campaign branch are allowed for this
work. Destructive history rewrites, force-pushes, releases, registry
publication, credential changes, or deletion of canonical branches require
explicit authorization.

## Current focused skills

- `zeus-diagnostics`
- `zeus-migration`
- `zeus-agents`
- `zeus-commands`
- `zeus-skills`

Keep this set small unless a new skill has a clear OpenCode-specific reason to
exist.
