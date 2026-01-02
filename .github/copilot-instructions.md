# GitHub Copilot Instructions for Analyst Documentation Lab

## Context

This is a hands-on lab for teaching analysts how to use AI assistants for technical documentation tasks. The lab focuses on two key skill areas:

1. **Requirements Extraction** - Converting meeting notes and legacy code into professional requirements documents
2. **Technical Diagramming** - Creating Mermaid diagrams to visualize system architecture and business logic

## Lab Structure

- **Lab 1 (20 min)**: Creating Technical Documentation
  - Task 1: Requirements from meeting notes (8 min)
  - Task 2: Requirements from legacy COBOL code (12 min)
- **Lab 2 (25 min)**: Creating Visual Diagrams
  - Task 1: Architecture diagram (5 min)
  - Task 2: Sequence diagram (5 min)
  - Task 3: Legacy system diagrams (15 min)
- **Lab 3 (5 min)**: Documentation Review

## Key Directories

| Directory | Purpose |
|-----------|---------|
| `inputs/` | Source materials (meeting notes, legacy code, rough specs) |
| `inputs/legacy-code/` | COBOL trade settlement program (TRDSETTL) |
| `templates/` | Document templates for requirements, specs, diagrams |
| `outputs/` | Where participants save their work |
| `exercises/` | Lab instructions for each exercise |
| `reference/` | Terminology glossary and documentation standards |

## Domain Context

The lab uses a **financial services / portfolio management** domain with:
- Trade execution and settlement systems
- Fee calculation logic (commissions, SEC fees, TAF, exchange fees)
- Account types (cash, margin, IRA, institutional)
- Portfolio rebalancing features

## Legacy Code Context

The COBOL program `inputs/legacy-code/trade-settlement-calc.cbl` (TRDSETTL) is a realistic 1994 mainframe program that:
- Calculates trade settlement amounts and fees
- Contains embedded business rules for fee tiers and account types
- Has known issues documented in comments (TODOs, tickets)
- References departed employees (realistic legacy scenario)

When analyzing this code, focus on extracting:
- Business rules (fee calculations, validation logic)
- Account type handling
- Settlement date calculations
- Margin account rules
- Known technical debt

## Output Standards

### Requirements Documents
- Use professional business analyst language
- Include user stories with acceptance criteria
- Document business rules with rule IDs (BR-001, etc.)
- List assumptions and open questions
- Reference source locations in legacy code

### Mermaid Diagrams
- Always output valid Mermaid syntax
- Use `graph TD` for flowcharts (top-down layout)
- Use `sequenceDiagram` for sequence diagrams
- Use `stateDiagram-v2` for state diagrams
- Include subgraphs for logical grouping
- Add labels and annotations for clarity

## Tone and Style

- Professional and clear for development teams
- Avoid jargon unless domain-specific and defined
- Use active voice
- Be concise but complete
- When documenting legacy code, translate COBOL terminology to business language

## File Naming Conventions

- Requirements: `outputs/requirements/{feature-name}-requirements.md`
- Diagrams: `outputs/diagrams/{diagram-name}.md`
- Reviews: `outputs/review-summary.md`

## Verification

All Mermaid diagrams should be tested at https://mermaid.live before saving.
