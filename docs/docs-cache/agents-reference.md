# OpenCode Agents Documentation
Last Updated: Mar 21 2026
Source: https://opencode.ai/docs/agents/

## Quick Reference

### Agent Types
1. **Primary Agents** - Main assistants (Build, Plan)
2. **Subagents** - Specialized assistants invoked via @mention

### Built-in Agents
- **Build** (primary): Default agent, all tools enabled
- **Plan** (primary): Read-only planning/analysis mode
- **General** (subagent): Multi-step tasks with full tools
- **Explore** (subagent): Fast read-only codebase exploration

### Agent Options
- `mode`: primary, subagent, or all
- `model`: Override default model
- `temperature`: 0.0-1.0 (creativity/randomness)
- `steps`: Max iterations before forced response
- `hidden`: Hide from @ autocomplete
- `color`: UI color (hex or theme color)
- `permission`: Tool access controls (ask/allow/deny)
- `task.permission`: Control which subagents can be invoked

### Agent Configuration Locations
- Global: `~/.config/opencode/agents/`
- Project: `.opencode/agents/`
- JSON Config: `opencode.json` agent section

### Agent Creation Command
```
opencode agent create
```

### Common Use Cases
- Build agent: Full development work
- Plan agent: Analysis without changes
- Review agent: Code review (read-only)
- Debug agent: Investigation tasks
- Docs agent: Documentation writing
