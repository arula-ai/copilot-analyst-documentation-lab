# Lab 1: Creating Technical Documentation

## Objective
Transform rough inputs into professional documentation using AI assistance. This lab covers two critical analyst skills:
1. Converting meeting notes into requirements
2. Extracting business requirements from legacy code

## Duration
20 minutes

---

## Task 1: Requirements from Meeting Notes (8 minutes)

### Input Materials
Use the meeting notes in `inputs/meeting-notes/portfolio-rebalancing-notes.md`

### Instructions
1. Open the portfolio rebalancing meeting notes
2. Use this AI prompt template:

```
Transform these meeting notes into a professional requirements document:

[Paste meeting notes]

Create:
1. Feature overview (2-3 sentences)
2. 3-5 user stories with acceptance criteria
3. Business rules extracted from discussion
4. Assumptions based on context
5. Open questions that need resolution

Format: Use the template structure from templates/requirements/
Tone: Professional, clear for development team
```

3. Review and refine the output
4. Save to `outputs/requirements/portfolio-rebalancing-requirements.md`

### Deliverable Checklist
- [ ] Clear feature overview
- [ ] At least 3 user stories with acceptance criteria
- [ ] Business rules documented
- [ ] Assumptions listed
- [ ] Open questions captured

---

## Task 2: Requirements from Legacy Code (12 minutes)

### The Challenge
Your company has a critical COBOL program (TRDSETTL) that handles trade settlement and fee calculations. This program was written in 1994 and has been modified multiple times. The original authors are no longer with the company.

**Your mission:** Extract the business requirements embedded in this legacy code so the team can understand what the system actually does (not just what the documentation says it does).

### Input Materials
Use the COBOL program in `inputs/legacy-code/trade-settlement-calc.cbl`

### Why This Matters
In real-world modernization projects, documentation is often outdated or missing. The **code itself becomes the source of truth** for business rules. Analysts must be able to:
- Read legacy code (with AI assistance)
- Extract embedded business logic
- Document undocumented rules
- Identify edge cases and special handling

### Instructions

#### Step 1: Initial Code Analysis (3 minutes)
Use this prompt to understand the overall structure:

```
Analyze this COBOL program and provide a high-level summary:

[Paste the COBOL code]

Identify:
1. What is the main purpose of this program?
2. What are the major processing sections (paragraphs)?
3. What external systems or files does it interact with?
4. What are the key data structures?

Format as a brief technical overview (1 page max).
```

#### Step 2: Extract Business Rules (5 minutes)
Use this prompt to extract the embedded business logic:

```
Extract all business rules from this COBOL trade settlement program:

[Paste the COBOL code]

For each business rule found, document:
1. Rule ID (BR-001, BR-002, etc.)
2. Rule Name (short descriptive title)
3. Rule Description (what the rule does)
4. Conditions (when the rule applies)
5. Source Location (which paragraph/section)
6. Any exceptions or special cases

Look specifically for:
- Fee calculation logic (commissions, SEC fees, TAF, etc.)
- Account type-specific rules (margin, IRA, institutional)
- Validation rules (what causes rejection)
- Settlement date calculation rules
- Tier-based discount logic
- Security type-specific handling

Format as a business rules catalog.
```

#### Step 3: Create Requirements Document (4 minutes)
Use this prompt to formalize the extracted rules:

```
Based on these extracted business rules from the legacy COBOL system,
create a formal requirements document:

[Paste the extracted business rules]

Create:
1. System Overview
   - Purpose of the trade settlement system
   - Key capabilities

2. Functional Requirements
   - Fee Calculation Requirements
   - Account Validation Requirements
   - Settlement Date Requirements
   - Margin Requirements

3. Business Rules Summary Table
   | Rule ID | Category | Description | Priority |

4. Data Requirements
   - What data elements are required for processing
   - Validation rules for each element

5. Integration Points
   - External systems referenced
   - File dependencies

6. Known Issues and Technical Debt
   - Issues mentioned in code comments
   - Areas marked as TODO or needing attention

Format: Professional requirements document
Include: References to original code sections where rules were found
```

4. Save to `outputs/requirements/trade-settlement-requirements.md`

### Deliverable Checklist
- [ ] System overview documented
- [ ] At least 10 business rules extracted
- [ ] Fee calculation logic clearly explained
- [ ] Account type handling documented
- [ ] Settlement date rules captured
- [ ] Validation rules listed
- [ ] Known issues/technical debt identified
- [ ] Integration points documented

### Hints for Legacy Code Analysis

**Look for these COBOL patterns:**
- `EVALUATE` statements = Business decision trees
- `IF` conditions = Validation rules
- `COMPUTE` statements = Calculation formulas
- `88-level` items = Valid values/status codes
- Comments starting with `*` = Developer notes (often contain business context)
- `TODO` comments = Known issues or incomplete features

**Red flags to document:**
- Comments like "not sure why" or "ask [person who left]"
- Hardcoded values that should be configurable
- Inconsistent logic (different rules for similar scenarios)
- Disabled or commented-out code
- References to external documentation that may not exist

---

## Quality Check

Use this prompt to review your legacy code requirements:
```
Review this requirements document extracted from legacy COBOL code:

[Paste your requirements document]

Evaluate:
1. Completeness - Did I capture all major business rules?
2. Accuracy - Does my interpretation match the code logic?
3. Clarity - Will developers understand the requirements?
4. Traceability - Can rules be traced back to code sections?
5. Gaps - What business context might be missing?

Identify any rules that need clarification from subject matter experts.
```

---

## Bonus Challenge: Compare Documentation

If time permits, compare:
1. Your extracted requirements from the code
2. The existing (poor) documentation in `inputs/existing-docs/legacy-system-doc.md`

Use this prompt:
```
Compare these two documents:

Document 1 (extracted from code):
[Paste your extracted requirements]

Document 2 (existing documentation):
[Paste the legacy-system-doc.md]

Identify:
1. What's documented but not in the code?
2. What's in the code but not documented?
3. Contradictions between docs and code
4. Which document is more accurate/useful?
```

This exercise demonstrates why **code archaeology** is a critical skill - existing documentation is often incomplete or wrong.
