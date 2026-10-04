# OpenZeus 2 Continuity

This document is the canonical handoff for the OpenZeus refocus campaign.

## Current state

- Repository: `Aveer/OpenZeus`
- Default branch: `main`
- Stable baseline: `v1.2.0`
- Baseline commit: `aebb1a323bb02a1f7c5e0d4fc81c856f05a8400f`
- Active branch: `refactor/openzeus-2-agent-first`
- Active phase: Phase 1 — identity and scope reduction
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

## Immediate Phase 1 decisions

Remove from the shipped skill set:
- `zeus-boston-terrier`
- `zeus-docker`
- `zeus-sql`
- `zeus-llm`
- `zeus-beads`
- `zeus-swarm`
- `zeus-oac`
- `zeus-omo`

Keep for now:
- `zeus-core`
- `zeus-agents`
- `zeus-commands`
- `zeus-skills`
- `zeus-upskill`
- `zeus-context`
- `zeus-self`

The kept set is not final. `zeus-core`, `zeus-context` and `zeus-self`
are consolidation candidates after current OpenCode capabilities are mapped.

## Invariants

- never add contributor-specific paths, credentials or personal config data;
- do not mutate `main` during the campaign;
- keep branch CI green at coherent checkpoints;
- do not introduce another task/evidence layer outside this continuity file,
  the canonical plan and normal Git history;
- do not publish npm or create a release from this branch without an explicit
  release decision.

## Next actions

1. Execute Phase 1 scope reduction.
2. Rewrite README and agent identity around the companion-agent model.
3. Update installation/profile/test logic to reflect the reduced skill set.
4. Run CI and fix regressions.
5. Start Phase 2 with a fresh audit of current OpenCode native capabilities,
   schema and plugin API.

## Last updated

2026-10-04 — branch and refocus campaign initialized.
