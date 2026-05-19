---
name: Hand-Off
description: Summarize progress and update workflow tracker between lab stages
agent: documentation-reviewer

Summarize the current lab stage progress for hand-off.

## Purpose

This prompt creates a progress checkpoint between lab stages, capturing:
- What was completed
- Artifacts created
- Decisions made
- Issues encountered
- Next steps

## Output Format

```markdown
## Stage [X] Hand-Off Summary

**Completed:** [Date/Time]
**Duration:** [Actual time spent]

### Artifacts Created
| File | Status | Notes |
|------|--------|-------|
| `outputs/...` | Complete/Partial | ... |

### Key Accomplishments
- ...

### Decisions Made
- ...

### Issues Encountered
| Issue | Resolution | Follow-up |
|-------|------------|-----------|
| ... | ... | ... |

### Agent Usage
| Agent | Purpose | Outcome |
|-------|---------|---------|
| @requirements-analyst | ... | ... |
| @diagram-architect | ... | ... |

### Next Stage Preparation
- [ ] Prerequisites for next stage
- [ ] Files needed
- [ ] Questions to resolve
```

## Usage

Run `/hand-off` at the end of each lab stage to:
1. Document progress
2. Capture learnings
3. Prepare for next stage
4. Track agent usage patterns

## Save To
Append to `outputs/workflow-tracker.md`
