# OpenZeus 2 Refocus Plan

Status: implementation complete for review — target release 2.0.0
Branch: `refactor/openzeus-2-agent-first`
Baseline release: `v1.2.0`
Baseline main: `aebb1a323bb02a1f7c5e0d4fc81c856f05a8400f`

## Product definition

OpenZeus is an OpenCode companion agent. Its job is to understand the user's
actual OpenCode environment, diagnose configuration and discovery problems,
help design OpenCode assets, and safely evolve older setups.

OpenZeus is not a replacement for OpenCode, a general developer framework, or
a generic knowledge pack.

## North-star experience

The primary interface is conversational:

```text
@OpenZeus why is this agent not loading?
@OpenZeus where did this skill come from?
@OpenZeus which config wins here?
@OpenZeus audit my OpenCode setup.
@OpenZeus migrate this old agent to the current format.
@OpenZeus design a portable skill for this workflow.
```

The CLI exists to give the agent deterministic inspection, validation and
migration primitives. Users should not need to learn a large CLI surface.

## Target architecture

```text
OpenCode native config / agents / skills / commands / plugins
                           |
                           v
                    OpenZeus plugin
                           |
             +-------------+-------------+
             |             |             |
             v             v             v
        inspector     diagnostics    migrations
             |             |             |
             +-------------+-------------+
                           |
                     @OpenZeus agent
                           |
                focused authoring skills
```

### Runtime discovery

Never commit user-specific absolute paths. Resolve environment locations at
runtime from OpenCode-provided context where possible, then environment
variables such as `OPENCODE_CONFIG_DIR` / `XDG_CONFIG_HOME`, then portable
platform defaults.

### Native-first rule

Do not duplicate OpenCode functionality that OpenCode already provides well.
Prefer OpenCode's current schema, built-in configuration knowledge and native
commands. OpenZeus adds value through environment inspection, provenance,
diagnostics, migrations and higher-level asset design.

## Current surface disposition

| Current component | Target |
|---|---|
| `agents/OpenZeus.md` | KEEP; make it a thin agent-first interface |
| `zeus-diagnostics` | KEEP; focused runtime/config diagnosis |
| `zeus-migration` | KEEP; focused compatibility/migration workflow |
| `zeus-agents` | KEEP; advanced design only, native creator for basic scaffolding |
| `zeus-skills` | KEEP; skill authoring remains a differentiator |
| `zeus-commands` | KEEP; focused command design/review |
| `zeus-core` | DELETE; broad OpenCode doc mirror replaced by schema/native knowledge |
| `zeus-upskill` | DELETE; meta-skill proliferation removed |
| `zeus-context` | DELETE; generic conversation-context management is not OpenCode core |
| `zeus-self` | DELETE; pseudo-introspection replaced by deterministic diagnostics |
| `zeus-boston-terrier` | DELETE |
| `zeus-docker` | DELETE |
| `zeus-sql` | DELETE |
| `zeus-llm` | DELETE |
| `zeus-beads` | DELETE from core |
| `zeus-swarm` | DELETE from core |
| `zeus-oac` | DELETE from core |
| `zeus-omo` | DELETE from core |
| generic repo/config sync | REPLACE with runtime state/manifest model |
| `doctor`, `diff`, `validate` | KEEP internally; converge user UX toward `audit` |
| `setup` / `init-project` / recipes | REASSESS against native OpenCode init/customization |
| `upgrade` | REDEFINE; current behavior is refresh/reinstall, not package upgrade |

## Phases

### Phase 1 — Identity and scope reduction — COMPLETE

Goal: make the repository describe and ship one coherent product.

Deliverables:
- rewrite README around the agent-first value proposition;
- rewrite OpenZeus agent prompt around discovery/diagnosis/design;
- remove clearly unrelated/general-purpose skills;
- remove external-plugin documentation skills from core;
- update tests, installer inventories and docs accordingly;
- keep CI green.

Exit criteria: a new user can explain OpenZeus in one sentence after reading
the first README screen, and the installed core contains only OpenCode-related
capabilities.

### Phase 2 — Current OpenCode compatibility — COMPLETE

Goal: stop maintaining stale OpenCode conventions.

Deliverables:
- audit current OpenCode schemas and built-ins;
- migrate OpenZeus-owned assets to current native formats;
- remove hard-coded model choice unless technically required;
- replace stale config-path assumptions;
- add contract tests for generated agent/skill/command assets.

Exit criteria: OpenZeus-generated assets are native-current rather than
legacy-compatible by translation.

### Phase 3 — Inspector / provenance foundation — COMPLETE

Goal: understand the user's effective OpenCode environment.

Deliverables:
- inventory global + project config;
- inventory discovered agents, skills, commands and plugins;
- report source/provenance and precedence;
- detect name collisions/shadowing;
- expose deterministic machine-readable inspection output.

Exit criteria: `@OpenZeus` can answer “where did this come from?” from
runtime evidence.

### Phase 4 — Audit and migration UX — PLAN-ONLY IMPLEMENTED

Goal: turn inspection into useful maintenance.

Deliverables:
- introduce `openzeus audit` as the human-facing diagnostic command;
- detect legacy/deprecated forms;
- add `openzeus migrate --plan`; **implemented**
- add guarded apply + backup + validation + rollback.

Exit criteria: OpenZeus can detect and safely plan at least one real OpenCode
migration end-to-end.

### Phase 5 — Native plugin packaging — PROTOTYPE CI-GREEN

Goal: make installation and runtime integration OpenCode-native.

Deliverables:
- implement OpenCode plugin entrypoint;
- register the focused skills through the current plugin API;
- minimize or retire copy-based global installation;
- replace repo/config sync with an OpenZeus state/manifest model.

Exit criteria: normal users can install OpenZeus as an OpenCode plugin without
manually copying agent/skill files into private machine-specific paths.

### Phase 6 — CLI and repository simplification — SUBSTANTIALLY COMPLETE

Goal: remove transitional machinery after the plugin path is proven.

Deliverables:
- collapse redundant CLI commands;
- move maintainer-only sync/dev helpers out of user-facing UX;
- remove deprecated profiles/workflows;
- update packaging, tests, docs and release process.

## Non-goals

- replacing OpenCode;
- becoming a generic AI/developer toolkit;
- maintaining copied documentation for unrelated plugins;
- bundling generic Docker/SQL/LLM knowledge;
- encoding any contributor's private machine paths;
- adding features merely because they can be represented as a skill.

## Release strategy

Do not publish a refocus release until at least Phase 1 and the current-format
compatibility work in Phase 2 are coherent. Breaking surface removal is documented explicitly. The actual diff warrants a major release; target version is `2.0.0`.


## Progress update — 2026-10-04

Phase 1 is complete on the refocus branch.

Completed:
- rewritten README around the companion-agent value proposition;
- moved the OpenZeus agent to current ordered `permissions` syntax;
- removed hard-coded model/request tuning from the OpenZeus agent;
- removed 12 unrelated, integration-copy, broad/meta or pseudo-introspection skills;
- consolidated the shipped skill set to five focused capabilities:
  `zeus-diagnostics`, `zeus-migration`, `zeus-agents`,
  `zeus-commands`, `zeus-skills`;
- enabled branch CI and restored a fully green validation pipeline.

Next implementation slice:
- finish Phase 4 with deterministic `openzeus migrate --plan`;
- keep apply disabled until migrations are parser-backed and rollback-safe;
- then finalize package/docs for the OpenZeus 2 breaking release.


## Plugin constraint discovered — 2026-10-04

Current OpenCode V2 Promise plugins can add skill sources and transform existing domains, but
`AgentEditor` exposes no `add()`. Therefore OpenZeus cannot yet ship the
`@OpenZeus` agent purely through the plugin API.

Interim target:
- plugin owns focused skills;
- agent file remains the only required copy/bootstrap artifact;
- remove that bootstrap once upstream supports plugin agent registration.


## Copy-management retirement — 2026-10-04

After the corrected V2 plugin entrypoint passed CI against the real `@opencode-ai/plugin/v2/promise` API, OpenZeus retired its old repo/config package-management layer.

Removed:
- bidirectional sync;
- sync Git hooks;
- bundle doctor/diff;
- bundle refresh/upgrade and rollback;
- copy-install of skills.

The only transitional copy operation is `install-agent`, required solely
because current OpenCode V2 plugins cannot add agents.


## Repository layout decision — 2026-10-04

Canonical architecture plans live under `docs/plans/`; continuity lives under
`docs/continuity/`. Local tracker state such as `.beads/` is intentionally
untracked.

`bin/openzeus` remains extensionless intentionally: it is the Unix/npm
executable entrypoint installed as the `openzeus` command. Implementation
modules use normal extensions (`.js`, `.mjs`, `.sh`).


## Migration safety decision — 2026-10-04

`openzeus migrate --plan` is implemented and CI-covered.

`--apply` deliberately returns an error and performs no mutations. Apply will
not be implemented as text substitution; each supported migration needs:

1. parser-backed source understanding;
2. an exact change plan;
3. backup;
4. post-change validation;
5. rollback on validation failure.


## Release decision — 2026-10-04

The refocus is a breaking release and is prepared as **OpenZeus 2.0.0**.

Reasons for the major version:
- most 1.x generic/config-manager CLI commands were removed;
- the shipped skill set was reduced from broad/general integrations to five
  focused OpenCode skills;
- native OpenCode V2 plugin delivery is now the primary architecture;
- the old copy-installed skill/config lifecycle was retired;
- migration apply remains intentionally unavailable until it is safe.

Merge and publication are separate, explicit steps after review.


## Plugin API correction — 2026-10-04

A final source-level audit against `anomalyco/opencode@dev` corrected an
earlier prototype assumption.

The actual current V2 Promise API is exported from:

```text
@opencode-ai/plugin/v2/promise
```

Its skill editor registers `SkillV2Source` entries, so OpenZeus registers the
packaged `skills/` directory as one directory source.

The current Promise `PluginContext` has no custom `tool`, `app`, or
`location` domains. Therefore the earlier prototype `openzeus_runtime` idea
was removed rather than shipping against a mock-only contract.
