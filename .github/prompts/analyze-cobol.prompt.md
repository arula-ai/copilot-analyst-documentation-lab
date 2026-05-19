---
name: Analyze COBOL
description: Extract business requirements from legacy COBOL code
---
 
Analyze the COBOL trade settlement program and extract business requirements.

## Input

Use the COBOL program: [inputs/legacy-code/trade-settlement-calc.cbl](../inputs/legacy-code/trade-settlement-calc.cbl)

## Analysis Steps

### Step 1: Structure Analysis
Identify:
1. Main purpose of the program
2. Major processing sections (paragraphs)
3. External systems or files it interacts with
4. Key data structures

### Step 2: Business Rule Extraction
For each rule found, document:

| Rule ID | Name | Description | Conditions | Source Location |
|---------|------|-------------|------------|-----------------|
| BR-001 | ... | ... | ... | 3000-CALC-FEES |

Look specifically for:
- Fee calculation logic (commissions, SEC fees, TAF, exchange fees)
- Account type-specific rules (margin, IRA, institutional)
- Validation rules (what causes rejection)
- Settlement date calculation rules
- Tier-based discount logic

### Step 3: Technical Debt
Document issues found in comments:
- TODOs and FIXMEs
- References to tickets or departed employees
- Hardcoded values that should be configurable
- Known bugs or limitations

## Output Structure

```markdown
# Trade Settlement System Requirements

## System Overview
[Purpose and capabilities]

## Functional Requirements

### Fee Calculation
[Requirements for each fee type]

### Account Validation
[Requirements for account checks]

### Settlement Date Calculation
[Requirements for date logic]

## Business Rules Summary
[Table of all rules]

## Known Issues and Technical Debt
[List from comments]

## Integration Points
[External systems and files]
```

## Save To
`outputs/requirements/trade-settlement-requirements.md`
