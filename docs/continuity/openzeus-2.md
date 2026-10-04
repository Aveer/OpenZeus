# OpenZeus 2 Continuity

This document is the canonical handoff for the OpenZeus refocus campaign.

## Current state

- Repository: `Aveer/OpenZeus`
- Default branch: `main`
- Stable baseline: `v1.2.0`
- Baseline commit: `aebb1a323bb02a1f7c5e0d4fc81c856f05a8400f`
- Active branch: `refactor/openzeus-2-agent-first`
- Active phase: Phase 2/3 foundation — current-format compatibility + runtime inspector
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

1. Implement deterministic `openzeus inspect` with human and JSON output.
2. Inventory runtime-resolvable config sources plus agents/skills/commands/plugins.
3. Report provenance/precedence and collisions without exposing secret values.
4. Add current-format compatibility warnings that can feed `zeus-migration`.
5. Build a simpler `openzeus audit` UX on top of inspector evidence.
6. Prototype native OpenCode plugin packaging only after the inspector contract
   is stable.

## Last updated

2026-10-04 — Phase 1 completed; focused five-skill architecture is CI-green; inspector work starts next.
