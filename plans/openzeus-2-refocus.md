# OpenZeus 2 Refocus Plan

Status: active
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
| `zeus-core` | MERGE/REDUCE; stop copying broad OpenCode docs |
| `zeus-agents` | REDUCE; advanced design only, use native creation for basic scaffolding |
| `zeus-skills` | KEEP/FOCUS; skill authoring remains a real differentiator |
| `zeus-commands` | REDUCE; authoring guidance only |
| `zeus-upskill` | KEEP temporarily; reassess after plugin architecture |
| `zeus-context` | MERGE candidate into diagnostics/project awareness |
| `zeus-self` | MERGE candidate into diagnostics |
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

### Phase 1 — Identity and scope reduction

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

### Phase 2 — Current OpenCode compatibility

Goal: stop maintaining stale OpenCode conventions.

Deliverables:
- audit current OpenCode schemas and built-ins;
- migrate OpenZeus-owned assets to current native formats;
- remove hard-coded model choice unless technically required;
- replace stale config-path assumptions;
- add contract tests for generated agent/skill/command assets.

Exit criteria: OpenZeus-generated assets are native-current rather than
legacy-compatible by translation.

### Phase 3 — Inspector / provenance foundation

Goal: understand the user's effective OpenCode environment.

Deliverables:
- inventory global + project config;
- inventory discovered agents, skills, commands and plugins;
- report source/provenance and precedence;
- detect name collisions/shadowing;
- expose deterministic machine-readable inspection output.

Exit criteria: `@OpenZeus` can answer “where did this come from?” from
runtime evidence.

### Phase 4 — Audit and migration UX

Goal: turn inspection into useful maintenance.

Deliverables:
- introduce `openzeus audit` as the human-facing diagnostic command;
- detect legacy/deprecated forms;
- add `openzeus migrate --plan`;
- add guarded apply + backup + validation + rollback.

Exit criteria: OpenZeus can detect and safely plan at least one real OpenCode
migration end-to-end.

### Phase 5 — Native plugin packaging

Goal: make installation and runtime integration OpenCode-native.

Deliverables:
- implement OpenCode plugin entrypoint;
- register OpenZeus-owned tools/capabilities through the current plugin API;
- minimize or retire copy-based global installation;
- replace repo/config sync with an OpenZeus state/manifest model.

Exit criteria: normal users can install OpenZeus as an OpenCode plugin without
manually copying agent/skill files into private machine-specific paths.

### Phase 6 — CLI and repository simplification

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
compatibility work in Phase 2 are coherent. Breaking surface removal should be
documented explicitly; versioning decision is made after the actual diff is
known.
