---
name: Extract Requirements
description: Transform meeting notes into a professional requirements document
agent: requirements-analyst
---
---

Transform the provided meeting notes into a professional requirements document.

## Input

Use the meeting notes from: [inputs/meeting-notes/](../inputs/meeting-notes/)

## Output Structure

Create a document with:

### 1. Feature Overview
Write 2-3 sentences summarizing the feature purpose and value.

### 2. User Stories
Create 3-5 user stories in this format:
```
As a [user type]
I want to [action]
So that [benefit]

Acceptance Criteria:
- [ ] Criterion 1
- [ ] Criterion 2
```

### 3. Business Rules
Extract all business rules from the discussion:

| Rule ID | Name | Description | Conditions |
|---------|------|-------------|------------|
| BR-001 | ... | ... | ... |

### 4. Assumptions
List assumptions made based on context.

### 5. Open Questions
Capture items that need clarification before development.

## Quality Checks
- [ ] All key decisions from meeting captured
- [ ] User stories are testable
- [ ] Business rules have clear conditions
- [ ] No ambiguous language

## Save To
`outputs/requirements/{feature-name}-requirements.md`
