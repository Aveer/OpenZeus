---
name: zeus-swarm
description: Documentation and reference for the OpenCode opencode-swarm plugin. Tools, concepts, workflows, templates, and troubleshooting for swarm features, tasks, worktrees, and multi-agent orchestration.
---

---

## Swarm Concepts

### Core Terms

| Term | Description |
|---|---|
| `feature` | A unit of work, like a user story or epic |
| `task` | A sub-unit of a feature, a specific deliverable |
| `worktree` | A git worktree linked to a feature/task |
| `session` | A conversation/working context |
| `hive` | The orchestration layer coordinating agents |

### Workflow Overview

```
feature create "new-login"
  └── task create "design-ui"
  └── task create "implement-backend"
  └── task create "write-tests"
        │
        ▼
worktree start task-123  ← Creates git worktree + spawns worker
        │
        ├── Worker (Forager) executes in isolated session
        │
        ▼
worktree commit  ← Commits changes to feature branch
        │
        ▼
hive merge        ← Merges feature into main
```

---

## Swarm Tools

### Feature Management

```bash
# Create a new feature
swarm_feature_create name="user-auth" ticket="US-123"

# Complete a feature
swarm_feature_complete name="user-auth"

# List features
swarm_status

# Read feature context
swarm_status feature="user-auth"
```

### Task Management

```bash
# Create a task (manual)
swarm_task_create name="Implement login form" feature="user-auth" order=1

# Create tasks from approved plan
swarm_tasks_sync feature="user-auth"

# Update task status
swarm_task_update task="task-123" status="completed"

# Update task summary
swarm_task_update task="task-123" summary="Login form implemented with validation"
```

### Worktree Lifecycle

```bash
# Start worktree for a task
swarm_worktree_start task="task-123" feature="user-auth"
# → Creates: git worktree add feature/user-auth-t123
# → Spawns: Forager worker agent

# Resume blocked worktree
swarm_worktree_create task="task-123" feature="user-auth" continue_from="blocked"

# Commit changes (worker → feature branch)
swarm_worktree_commit task="task-123" status="completed" summary="Implemented login form"

# Discard changes
swarm_worktree_discard task="task-123"
```

### Integration

```bash
# Merge feature into current branch
swarm_merge task="task-123" feature="user-auth"

# Merge with strategy
swarm_merge task="task-123" strategy="squash"  # merge | squash | rebase
```

### Context Files

```bash
# Write persistent context
swarm_context_write name="architecture.md" content="# Architecture" feature="user-auth"

# Write plan
swarm_plan_write content="# Plan" feature="user-auth"

# Read plan and comments
swarm_plan_read feature="user-auth"
```

### Agent Memory Sync

```bash
# Sync AGENTS.md
swarm_agents_md action="init"      # Scan codebase, generate (preview)
swarm_agents_md action="sync"      # Propose updates from contexts
swarm_agents_md action="apply"     # Write approved content to disk
```

---

## plan.md Template

```markdown
# Feature: [Feature Name]

**Ticket:** [Ticket ID]
**Status:** [Draft | Approved | In Progress | Completed]

---

## Goals

1. [Goal 1]
2. [Goal 2]

---

## Tasks

- [ ] Task 1
- [ ] Task 2

---

## Notes

[Additional context, decisions, constraints]
```

---

## Feature Context Template

```markdown
# [Feature Name]

**Created:** [Date]
**Status:** [Active | Completed | Abandoned]

## Purpose

[Brief description of what this feature does]

## Key Decisions

- [Decision 1]
- [Decision 2]

## Files Changed

- `src/feature/main.ts`
- `tests/feature/test.ts`

## Open Questions

- [Question 1]
- [Question 2]
```

---

## Task Template

```markdown
# Task: [Task Name]

**Feature:** [Feature Name]
**Status:** [Pending | In Progress | Blocked | Completed]

## Description

[What needs to be done]

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Notes

[Implementation notes, constraints, references]
```

---

## Agent Definition Template (for Feature Workers)

```markdown
---
description: "Worker agent for [feature-name] feature"
mode: all
model: opencode-go/big-pickle
steps: 50
permission:
  edit: allow
  write: allow
  webfetch: allow
  bash:
    "*": ask
    "git status *": allow
    "git diff *": allow
    "git add *": allow
    "git commit *": allow
    "git push": ask
---

# Feature Worker: [Feature Name]

You are a worker agent implementing the [Feature Name] feature.

## Task Context

Feature goal: [Brief description]
Current task: [Specific task from plan]

## Your Responsibilities

1. Implement the task according to the plan
2. Follow existing code patterns
3. Run tests before marking complete
4. Report progress to the orchestrator

## Rules

1. Always check the plan before implementing
2. Write tests for new code
3. Commit frequently with clear messages
4. Ask for clarification if blocked

## Quality Gates

- [ ] Code compiles/passes lint
- [ ] Tests pass
- [ ] Follows project conventions
- [ ] No secrets committed
```

---

## Multi-Agent Orchestration Patterns

### Pattern 1: Fan-Out (Parallel Workers)

```
Orchestrator (Swarm Master)
  ├── Worker A (Task 1) ──→ commits
  ├── Worker B (Task 2) ──→ commits
  └── Worker C (Task 3) ──→ commits
        │
        ▼
    Swarm Merge
```

### Pattern 2: Sequential (Pipeline)

```
Worker A ──→ Worker B ──→ Worker C ──→ Merge
```

### Pattern 3: Review Gate

```
Worker ──→ Reviewer ──→ Approve? ──→ Merge
                    │
                    ├── Yes ──→ Merge
                    └── No ──→ Worker (fix)
```

---

## Git Worktree Strategy

### Create Feature Branch + Worktree

```bash
# From main
git checkout main
git pull

# Create feature branch
git worktree add ../feature-name main
cd ../feature-name

# Or with -b flag (creates new branch)
git worktree add -b feature/name ../feature-name main
```

### Worktree Cleanup

```bash
# List worktrees
git worktree list

# Remove worktree
git worktree remove ../feature-name

# Prune stale worktrees
git worktree prune
```

---

## Common Issues

| Issue | Solution |
|---|---|
| Task blocked | Use `swarm_worktree_create continue_from="blocked"` |
| Worktree conflict | Remove conflicting worktree: `git worktree remove` |
| Plan not found | Create with `swarm_plan_write` |
| Worker not responding | Check task status with `swarm_task_update` |
| Merge conflict | Resolve in main branch, then merge |

---

## Relevant URLs

| Resource | URL |
|---|---|
| OpenCode Swarm Architecture | https://github.com/zaxbysauce/opencode-swarm/blob/main/docs/architecture.md |
| Pre-Swarm Planning | https://github.com/zaxbysauce/opencode-swarm/blob/main/docs/planning.md |
| Swarm Briefing | https://github.com/zaxbysauce/opencode-swarm/blob/main/docs/swarm-briefing.md |

---

End of skill.
