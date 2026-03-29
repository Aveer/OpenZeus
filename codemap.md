# Repository Atlas: OpenZeus

## Project Responsibility
Master AI agent for OpenCode - provides comprehensive system-level operations, autonomous configuration management, and domain-specific knowledge orchestration through modular skill bundles and custom commands.

## System Entry Points
- `agents/OpenZeus.md`: Primary agent definition with permissions, model configuration, and behavioral rules
- `package.json`: NPM package configuration with install hooks and metadata
- `scripts/install.sh`: Deployment entrypoint - installs OpenZeus to OpenCode config directory
- `README.md`: User-facing documentation and installation guide

## Directory Map (Aggregated)
| Directory | Responsibility Summary | Detailed Map |
|-----------|------------------------|--------------|
| `scripts/` | **Deployment Subsystem** - Installation, bidirectional sync, context-aware creation, git hooks | [View Map](scripts/codemap.md) |
| `skills/` | **Knowledge Bundle Architecture** - 15 domain-specific skill bundles with trigger-keyword activation | [View Map](skills/codemap.md) |
| `agents/` | **Agent Registry** - OpenZeus agent definition with persona, capabilities, and permissions | [View Map](agents/codemap.md) |
| `commands/` | **Command Interface Layer** - 4 custom slash commands for workflow automation | [View Map](commands/codemap.md) |

## System Architecture

OpenZeus operates as a **multi-layered orchestration system**:

1. **Agent Layer** (`agents/`): Core persona and behavior definition
2. **Knowledge Layer** (`skills/`): Domain expertise via skill bundles  
3. **Interface Layer** (`commands/`): User-facing slash commands
4. **Deployment Layer** (`scripts/`): Installation and sync automation

## Data Flow Overview

```
User Request → OpenZeus Agent → Intent Detection → Skill Loading → Task Execution
                                      ↓
External Tools ← Command Execution ← Multi-Skill Workflows ← Knowledge Retrieval
```

## Key Integration Points

- **OpenCode Runtime**: `~/.config/opencode/` (agents, skills, commands)
- **NPM Registry**: Global installation via `npm install -g openzeus`
- **Git Repository**: Version control and bidirectional sync
- **External Tools**: Beads, opencode-swarm, oh-my-opencode-slim, Docker, SQL, LLM servers

## Development Patterns

OpenZeus follows consistent patterns across all modules:
- **Markdown-based configuration**: YAML frontmatter + structured content
- **Context-aware creation**: Repository-first, config-fallback strategy
- **Bidirectional sync**: Repo ↔ Config automatic synchronization
- **Intent-based routing**: Keyword detection → skill activation
- **Delegated execution**: Specialized subagents for non-domain tasks