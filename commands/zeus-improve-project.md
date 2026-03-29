---
description: Project analysis, planning, and execution workflow
---

# Project improvement workflow
You are running a structured project improvement cycle. Work through the five phases below in strict order. Do not skip phases or proceed speculatively.

All standard delegation rules, parallelism constraints, verification protocol, and beads requirements remain in effect throughout.

---

## Phase 1 — Analyse
Build a complete picture of the project before touching anything. Do not delegate this phase — read and reason directly.
- Map the file and folder structure
- Identify the tech stack, dependencies, and entry points
- Read key files: config, main modules, shared utilities, tests
- Note anything that looks fragile, inconsistent, or unclear

---

## Phase 2 — Identify Issues and Improvements
Produce two lists from the analysis:

### Bugs
Things that are broken or likely to break:
- Runtime errors, unhandled edge cases, broken logic
- Missing error handling or null checks
- Dependency mismatches or unsafe assumptions

### Improvements
Things that work but could be better:
- Performance bottlenecks
- Code duplication or structural debt
- Missing tests or poor coverage
- UX or output quality issues

> Every item must reference a file, function, or line range. Vague findings are not actionable and must not appear on the list.

---

## Phase 3 — Plan
Turn Phase 2 findings into an ordered execution plan. Each item must include:
- **What**: a one-line description of the change
- **Why**: which bug or improvement it addresses
- **Where**: the exact file(s) affected
- **Agent**: which agent will handle it
- **Dependencies**: which other items must complete first (if any)

Sort by priority: bugs before improvements, high-impact before low-impact.

Store the full plan as a beads issue before proceeding.

> Present the plan and wait for confirmation. If the user revises it, update the beads issue and re-confirm before proceeding. Do not begin execution until the plan is confirmed.

---

## Phase 4 — Execute
Work through the confirmed plan.
- Dispatch agents according to plan order and dependency graph
- Enforce all parallelism constraints at every dispatch decision
- Verify each agent's output before marking the item complete
- If a task fails twice, self-execute and report back to the user with what was done and why delegation failed

> If a new issue is discovered mid-execution, log it as a beads issue for the next cycle. Do not expand the current plan's scope.

---

## Phase 5 — Test
Run a full verification pass after all plan items are complete.
- Execute the project's existing test suite
- For any changed file, confirm the relevant tests still pass
- If a change has no test coverage, flag it explicitly — do not silently skip
- Confirm no regressions were introduced by cross-checking affected files

If tests fail, treat each failure as a new fixer task under the standard delegation and verification protocol. Do not mark the cycle complete until all tests pass or failures are explicitly documented and understood.

---

## Principles specific to this workflow
- **Analyse before acting.** Read first, plan second, execute third. Never guess at project structure.
- **Plan before executing.** No agent is dispatched without a confirmed plan item behind it.
- **Scope discipline.** Discoveries during execution go into the next cycle, not the current one.
