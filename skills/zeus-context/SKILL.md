---
name: zeus-context
description: Context management strategies, compression analysis, and conversation optimization for OpenZeus.
---

# zeus-context (Skill)

Purpose: Context management strategies, compression analysis, and conversation optimization for OpenZeus.

---

## Context Health Assessment

### Signal-to-Noise Analysis
| Pattern | Signal | Noise |
|---------|---------|-------|
| Completed tasks | ✅ Summary | ❌ Verbose tool outputs |
| Failed attempts | ✅ Root cause | ❌ Debug loops |
| Research findings | ✅ Conclusions | ❌ Raw exploration |
| Code implementations | ✅ Final version | ❌ Iteration history |

### Compression Readiness Indicators
- ✅ **Task completed**: Implementation finished and verified
- ✅ **Research concluded**: Findings clear and documented
- ✅ **Dead-end exploration**: Failed attempts with clear outcomes
- ✅ **Large tool outputs**: Raw data no longer needed for reference

---

## Compression Strategies

### Range Selection Rules
1. **Prefer smaller ranges** — Better summary quality
2. **Target closed tasks** — Avoid active work
3. **Parallel compression** — Multiple independent ranges
4. **Preserve active context** — Keep current work visible

### Quality Thresholds
| Context Size | Action |
|--------------|--------|
| < 50 messages | Monitor only |
| 50-100 messages | Identify compression candidates |
| 100-150 messages | Compress completed ranges |
| > 150 messages | Aggressive compression needed |

---

## Context Optimization Patterns

### High-Signal Preservation
Keep these in active context:
- **Current task requirements**
- **Error messages needing attention** 
- **Files being actively modified**
- **Unresolved decisions**
- **Recent user feedback**

### Low-Signal Compression
Compress these ranges:
- **Completed implementations**
- **Successful troubleshooting**
- **Large diagnostic outputs**
- **Resolved research questions**
- **Dead-end explorations**

---

## Memory Management

### Session Handoff Preparation
Before session end, preserve:
```markdown
**Working State**:
- Current directory: /path/to/work
- Active files: [list modified files]
- Git status: [staged/unstaged/pushed]
- Pending tasks: [list incomplete work]

**Context Summary**:
- Major accomplishments: [key achievements]
- Current focus: [what you're working on]
- Next steps: [immediate actions needed]
- Blockers: [what's preventing progress]
```

### Cross-Session Continuity
- **Compress completed work** before handoff
- **Document active state** clearly
- **Preserve error context** if troubleshooting
- **Note configuration changes** made

---

## Proactive Context Management

### Continuous Housekeeping
- Monitor conversation length regularly
- Identify closed ranges immediately after task completion  
- Compress in parallel when multiple ranges are ready
- Preserve high-signal ranges for reference

### Quality-First Compression
- Write exhaustive summaries that preserve all context
- Include file paths, function signatures, key decisions
- Capture constraints and requirements discovered
- Maintain chronological flow with compressed blocks

---

## Context Analysis Commands

### Quick Assessment
```
Context size: X messages
Compression candidates: [list ranges ready for compression]
Signal quality: High/Medium/Low
Active work: [current tasks requiring preservation]
```

### Detailed Analysis
```
**Context Health Report**
Total messages: X
Signal-to-noise ratio: Y%
Compression opportunities: Z ranges identified

**Range Analysis**:
- Messages 1-20: Completed setup (ready for compression)
- Messages 21-40: Active debugging (preserve)
- Messages 41-60: Research findings (compress after current task)

**Recommendations**:
- Compress ranges: [specific message ranges]
- Preserve: [active context ranges]  
- Monitor: [borderline ranges]
```

---

## Usage Triggers

Load this skill when user mentions:
- "context cleanup"
- "compress context"  
- "conversation getting long"
- "manage context"
- "optimize conversation"
- "session handoff"
- "prepare for next session"

---

End of skill.