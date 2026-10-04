# OpenZeus 2 Continuity

This document is the canonical handoff for the OpenZeus refocus campaign.

## Current state

- Repository: `Aveer/OpenZeus`
- Default branch: `main`
- Stable baseline: `v1.2.0`
- Baseline commit: `aebb1a323bb02a1f7c5e0d4fc81c856f05a8400f`
- Active branch: `refactor/openzeus-2-agent-first`
- Active phase: Phase 3/5 crossover — inspector/audit + native V2 plugin prototype
- Detailed plan: [plans/openzeus-2-refocus.md](../../plans/openzeus-2-refocus.md)

## Canonical product decision

OpenZeus is an OpenCode companion agent, not a replacement for OpenCode.

Its durable differentiator should be understanding the user's effective
OpenCode environment: discovery, provenance, precedence, diagnostics,
compatibility/migration and high-quality OpenCode asset design.

The agent is the primary interface. CLI/plugin code supplies deterministic
tools to the agent.

## Architectural decisions

1. **Native-first.** Reuse OpenCode's own capabilities instead of cloning them.
2. **Runtime discovery.** No private absolute paths in repository content.
3. **Small core.** Skills must directly serve OpenCode operation/authoring.
4. **No documentation mirrors for unrelated plugins.** External integrations
   belong outside core unless they become real maintained adapters.
5. **Inspection before mutation.** Plans and diagnostics precede writes.
6. **Plugin is the target distribution architecture.** Existing copy/install
   scripts are transitional until the plugin path is proven.
7. **Do not delete transitional infrastructure prematurely.** Remove it only
   when replacement behavior has tests and an explicit migration path.

## Phase 1 result

The shipped skill set is now intentionally limited to:

- `zeus-diagnostics`
- `zeus-migration`
- `zeus-agents`
- `zeus-commands`
- `zeus-skills`

Removed from core:
- generic Docker / SQL / local-LLM / Boston Terrier knowledge;
- copied Beads / swarm / OAC / OMO integration documentation;
- broad `zeus-core` documentation mirror;
- `zeus-upskill` meta-skill;
- generic conversation-context `zeus-context`;
- pseudo-runtime-introspection `zeus-self`.

OpenZeus-owned agent frontmatter now uses current ordered `permissions`
rules and no longer pins a model, temperature or step budget.

## Invariants

- never add contributor-specific paths, credentials or personal config data;
- do not mutate `main` during the campaign;
- keep branch CI green at coherent checkpoints;
- do not introduce another task/evidence layer outside this continuity file,
  the canonical plan and normal Git history;
- do not publish npm or create a release from this branch without an explicit
  release decision.

## Next actions

1. Harden the new `openzeus inspect` contract against real-world source combinations.
2. Add richer current-format compatibility rules on top of inspector evidence.
3. Build a simpler `openzeus audit` UX on top of inspector output.
4. Add guarded migration planning that consumes inspector findings.
5. Prototype native OpenCode plugin packaging only after the inspector contract
   is stable.

## Last updated

2026-10-04 — Phase 1 completed; focused five-skill architecture is CI-green; inspector work starts next.

- 2026-10-04 — first deterministic filesystem inspector implemented with JSON
  output, precedence/collision reporting and legacy warnings; live-runtime gaps
  are explicit limitations.

- 2026-10-04 — generator/validator compatibility pass moved OpenZeus-owned
  agent templates to native V2 ordered permissions and made package/project
  validation reject legacy agent/command fields.

- 2026-10-04 — removed bundled generic slash commands and collapsed the old
  core/extras content split. OpenZeus still designs/creates commands, but does
  not ship unrelated project-management/Git workflows.

- 2026-10-04 — removed generic project-bootstrap/capture surface
  (`setup`, `init-project`, recipes, context-init, capture-command) after
  confirming OpenCode's native `/init` owns project analysis and AGENTS.md
  initialization.

- 2026-10-04 — added `openzeus audit` as the first user-facing diagnostic
  workflow on top of inspector evidence; `--ci` fails only on warning/error
  findings while shadowing/info remains informational.

- 2026-10-04 — started native V2 plugin packaging using `@opencode/plugin`.
  Plugin registers the five focused skills plus a safe live-runtime inventory
  tool. Upstream `AgentEditor` currently has no `add()`, so the @OpenZeus
  agent remains the only transitional copy-installed asset.
