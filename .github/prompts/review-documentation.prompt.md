---
name: Review Documentation
description: Review all lab outputs for quality, completeness, and accuracy
---
 
Review the documentation artifacts created during Labs 1 and 2.

## Artifacts to Review

### Lab 1 Requirements Documents
- `outputs/requirements/portfolio-rebalancing-requirements.md`
- `outputs/requirements/trade-settlement-requirements.md`

### Lab 2 Diagrams
- `outputs/diagrams/portfolio-architecture.md`
- `outputs/diagrams/trade-execution-sequence.md`
- `outputs/diagrams/trade-settlement-flow.md`
- `outputs/diagrams/fee-calculation-logic.md`
- `outputs/diagrams/settlement-states.md`

## Review Criteria

### 1. Completeness (20 points)
- [ ] All required sections present
- [ ] No major gaps in coverage
- [ ] Edge cases and errors documented

### 2. Clarity (20 points)
- [ ] Language is clear and unambiguous
- [ ] Terms are defined or commonly understood
- [ ] Target audience can understand it

### 3. Consistency (20 points)
- [ ] Same terminology throughout
- [ ] Consistent formatting
- [ ] Matching detail levels

### 4. Accuracy (20 points)
- [ ] Diagrams match text descriptions
- [ ] Business rules correctly stated
- [ ] Examples align with requirements

### 5. Traceability (20 points)
- [ ] Requirements traced to sources
- [ ] Code references accurate
- [ ] Decisions documented

## Legacy Code Extraction Checks

- [ ] At least 10 business rules extracted
- [ ] Fee calculations accurately documented
- [ ] All account types covered
- [ ] Known issues from comments identified
- [ ] Integration points documented

## Diagram Checks

- [ ] All diagrams render without errors
- [ ] Components properly labeled
- [ ] Connections have meaningful labels
- [ ] Decision points clearly marked
- [ ] Error paths included
- [ ] Business language used (not code variables)

## Output Format

```markdown
# Documentation Review Summary

## Overall Quality Score: X/100

### Scores by Dimension
| Dimension | Score | Notes |
|-----------|-------|-------|
| Completeness | /20 | ... |
| Clarity | /20 | ... |
| Consistency | /20 | ... |
| Accuracy | /20 | ... |
| Traceability | /20 | ... |

### Issues Found
| Priority | Issue | Location | Recommendation |
|----------|-------|----------|----------------|
| High | ... | ... | ... |

### Top 3 Improvements
1. ...
2. ...
3. ...

### Strengths
- ...
```

## Save To
`outputs/review-summary.md`
