---
name: zeus-self
description: Runtime introspection and self-diagnostics for OpenZeus - current session state, health checks, and operational awareness.
---

# zeus-self (Skill)

Purpose: Runtime introspection and self-diagnostics for OpenZeus — current session state, health checks, and operational awareness.

---

## Session Introspection

### Current Context Analysis
- **Conversation Length**: Check message count and context size
- **Active Skills**: Track which skills have been loaded this session
- **Tool Usage Patterns**: Most/least used tools in current session
- **Working Directory**: Current location and git repository status
- **Recent Operations**: Summary of major actions taken

### Context Health
- **Signal-to-Noise Ratio**: Assess conversation quality
- **Compression History**: Track what's been compressed and when
- **Memory Pressure**: Evaluate need for context cleanup
- **Stale Ranges**: Identify conversation sections ready for compression

---

## System Health Diagnostics

### Core File Integrity
Check essential OpenZeus files:
- `~/.config/opencode/agents/OpenZeus.md` — Agent definition
- `~/.config/opencode/opencode.json` — Main configuration
- `~/.config/opencode/skills/zeus-*/SKILL.md` — Skill bundles
- `~/.config/opencode/commands/` — Custom commands

### Configuration Validation
- **Schema Compliance**: Validate config against expected structure
- **Permission Check**: Verify edit/write/bash/webfetch access
- **Path Accessibility**: Test key directory access
- **Git Status**: Check repository state and cleanliness

### Capability Testing
- **Tool Access**: Test bash, read, write, glob, grep functionality
- **Network Connectivity**: Check webfetch and URL reachability
- **Skill Loading**: Verify skill system operational
- **Task Delegation**: Test subagent communication

---

## Operational Awareness

### Performance Metrics
- **Response Latency**: Track tool execution times
- **Success Rates**: Monitor tool failure patterns
- **Resource Usage**: Assess computational overhead
- **Error Frequency**: Identify recurring issues

### Learning Indicators
- **Knowledge Gaps**: Areas where I lack information
- **Skill Usage Patterns**: Which skills are most/least valuable
- **User Intent Mapping**: How well I detect user needs
- **Delegation Efficiency**: Subagent usage effectiveness

---

## Self-Diagnostic Commands

### Quick Health Check
```markdown
**System Status**: ✅ Operational / ⚠️ Degraded / ❌ Critical
**Configuration**: Valid / Invalid
**Core Files**: Present / Missing
**Tool Access**: Full / Partial / None
**Git Status**: Clean / Dirty / Unknown
```

### Detailed Diagnostics
```markdown
**Session Context**:
- Messages: X total, Y compressed
- Skills loaded: [list]
- Tools used: [frequency table]
- Working dir: /path/to/current

**File Integrity**:
- Agent definition: ✅ Present (194 lines)
- Main config: ✅ Valid JSON
- Skills: ✅ X skills available
- Commands: ✅ Y commands defined

**Capabilities**:
- Bash: ✅ Responsive
- File ops: ✅ Read/Write functional  
- Network: ✅ Can reach opencode.ai
- Git: ✅ Repository accessible
```

### Performance Analysis
```markdown
**Tool Usage This Session**:
| Tool | Uses | Avg Time | Success Rate |
|------|------|----------|--------------|
| bash | X | Yms | Z% |
| read | X | Yms | Z% |

**Skill Loading Patterns**:
- Most used: zeus-core (X times)
- Least used: zeus-swarm (0 times)
- Load sequence: [chronological list]
```

---

## Context Management Insights

### Compression Candidates
Identify conversation ranges that could be compressed:
- **Closed exploration**: Research that reached conclusions
- **Completed tasks**: Finished implementations
- **Failed attempts**: Dead-end troubleshooting
- **Verbose outputs**: Large tool results no longer needed

### Signal Preservation
Assess what must be kept in active context:
- **Active code**: Files currently being modified  
- **Pending decisions**: Unresolved questions
- **Error context**: Recent failures needing attention
- **User intent**: Current task requirements

---

## Self-Improvement Tracking

### Capability Gaps
- **Missing skills**: Domains I can't handle well
- **Tool limitations**: Operations I struggle with
- **Knowledge holes**: Topics requiring external lookup
- **Workflow inefficiencies**: Repeated manual steps

### Learning Opportunities
- **New skill candidates**: Based on user request patterns
- **Automation potential**: Manual processes worth scripting
- **Configuration improvements**: Settings optimizations
- **Workflow enhancements**: Better delegation strategies

---

## Runtime State Queries

### Session Summary
Generate current session overview:
```markdown
**OpenZeus Session Report**
- Duration: X minutes
- Major actions: [list key accomplishments]
- Skills utilized: [loaded skills with usage]
- Files modified: [paths and change types]
- Git operations: [commits, branches, status]
- Context health: [compression needs, signal quality]
```

### Health Dashboard
Real-time system status:
```markdown
**OpenZeus Health Dashboard**
🟢 System: Fully operational
🟢 Config: Valid and accessible  
🟢 Tools: All responsive
🟢 Network: Connected to docs
🟡 Context: Moderate compression needed
🟢 Git: Clean working directory
```

### Diagnostic Report
Comprehensive system analysis:
```markdown
**Full Diagnostic Report**
Generated: [timestamp]

CONFIGURATION:
- Agent file: ✅ ~/.config/opencode/agents/OpenZeus.md (194 lines)
- Main config: ✅ ~/.config/opencode/opencode.json (valid)
- Skills dir: ✅ 16 skills available
- Commands dir: ✅ X custom commands

CAPABILITIES:
- File operations: ✅ Read/write/edit functional
- Shell access: ✅ Bash responsive (non-interactive mode)
- Network access: ✅ Can reach opencode.ai
- Git operations: ✅ Repository accessible
- Skill loading: ✅ All skills loadable
- Task delegation: ✅ Subagent communication working

SESSION STATE:
- Context size: X messages, Y tokens estimated
- Active skills: [list]
- Working directory: [path]
- Git status: [clean/dirty/ahead/behind]
- Recent errors: [none/list]

RECOMMENDATIONS:
- [Context management suggestions]
- [Performance optimizations]
- [Capability improvements]
```

---

## Session Management & Handoff

### Accomplishment Tracking
- **Session Summary**: Major tasks completed this session
- **File Modifications**: Track all files created, edited, or deleted
- **Git Operations**: Commits made, branches worked on, push status
- **Skill Usage**: Which capabilities were exercised
- **Knowledge Gained**: New insights or patterns discovered

### Incomplete Work Analysis
- **Pending Tasks**: Work started but not finished
- **Follow-up Items**: Actions that need continuation
- **Blocked Dependencies**: What's waiting on external factors
- **Context Preservation**: What state must be maintained
- **Handoff Requirements**: Critical info for next session

### Session Continuity
- **Context Handoff Notes**: Essential background for resuming work
- **Working Directory State**: Current location and git status
- **Active Configurations**: Settings or environments in use
- **Dependency Status**: What's installed, configured, or broken
- **Next Steps**: Recommended actions for continuation

### Cleanup Recommendations
- **Git Hygiene**: Uncommitted changes, stashes, branches to clean
- **File Organization**: Temporary files to remove or organize
- **Context Compression**: Conversation ranges ready for cleanup
- **Resource Cleanup**: Processes, connections, or locks to release

---

## Interactive Configuration

### Trigger Keyword Management
- **Usage Analysis**: Track which keywords actually trigger skills
- **Pattern Recognition**: Identify new trigger patterns from user requests
- **Keyword Optimization**: Add/remove triggers based on effectiveness
- **Context Sensitivity**: Adjust triggers based on domain or project type

### Skill Loading Optimization
- **Priority Adjustment**: Reorder skills based on usage frequency
- **Combination Patterns**: Learn which skills work well together
- **Load Sequence**: Optimize the order of multi-skill workflows
- **Dependency Mapping**: Track which skills depend on others

### Behavior Rule Evolution
- **Rule Effectiveness**: Monitor which behavior rules help vs hinder
- **Situational Rules**: Context-specific behavior modifications
- **Performance Rules**: Optimize for speed vs thoroughness based on task
- **Safety Rules**: Enhance security and error prevention patterns

### URL Mapping Updates
- **Link Validation**: Check if documented URLs are still valid
- **New Documentation**: Add mappings for newly discovered resources
- **Usage Tracking**: Monitor which documentation gets accessed most
- **Regional/Version**: Handle different doc versions or mirrors

### Capability Self-Configuration
- **Tool Usage Optimization**: Adjust tool selection based on success rates
- **Delegation Rules**: Refine when to use subagents vs direct action
- **Context Limits**: Auto-adjust context management thresholds
- **Performance Tuning**: Optimize response patterns for different scenarios

---

## Configuration Commands

### Update Trigger Keywords
```markdown
**Current Triggers for zeus-self**: [list current triggers]
**Suggested Additions**: [based on usage analysis]
**Suggested Removals**: [unused or ineffective triggers]
**Update Command**: Modify OpenZeus.md skill loading guide
```

### Optimize Skill Loading
```markdown
**Current Priority**: zeus-core → zeus-agents → zeus-commands
**Usage Analysis**: [frequency and success rates]
**Recommended Changes**: [based on actual patterns]
**New Priority**: [optimized loading order]
```

### Behavior Rule Tuning
```markdown
**Current Rules**: [list from OpenZeus.md]
**Rule Effectiveness**: [which help, which hinder]
**Situational Needs**: [context-specific modifications]
**Proposed Updates**: [rule modifications or additions]
```

---

## Usage Instructions

Load this skill when you need:
- **Self-awareness**: "How am I performing?"
- **Health check**: "Are my systems working properly?"  
- **Session status**: "What have I accomplished?"
- **Diagnostics**: "Why am I having issues?"
- **Context management**: "Should I compress anything?"
- **Session handoff**: "Prepare notes for next session"
- **Configuration**: "Update your trigger keywords"
- **Optimization**: "Analyze and improve your patterns"

This skill transforms from static documentation into dynamic runtime intelligence and self-optimization.

---

End of skill.
