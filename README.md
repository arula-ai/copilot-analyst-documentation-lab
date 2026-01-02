# Analyst Documentation Lab

Hands-on lab for AI-assisted technical documentation using GitHub Copilot custom agents and prompts.

## What You'll Learn

- Extract requirements from meeting notes using AI
- Reverse-engineer business rules from legacy COBOL code
- Create Mermaid diagrams for system architecture and business logic
- Review documentation for quality and completeness

## Prerequisites

- VS Code with GitHub Copilot extension
- Access to https://mermaid.live for diagram verification

## Quick Start

1. Clone this repository
2. Open in VS Code
3. Verify agents work: Type `@` in Copilot Chat to see custom agents
4. Verify prompts work: Type `/` in Copilot Chat to see custom prompts
5. Follow the [LAB_ACTION_GUIDE.md](LAB_ACTION_GUIDE.md)

## Lab Structure

| Lab | Duration | Focus |
|-----|----------|-------|
| Lab 1 | 20 min | Requirements extraction (meeting notes + COBOL) |
| Lab 2 | 25 min | Visual diagrams (Mermaid + draw.io) |
| Lab 3 | 5 min | Documentation review |
| **Total** | **50 min** | |

## Custom Agents

Select from the Agent Selector Dropdown in Copilot Chat:

| Agent | Purpose |
|-------|---------|
| Requirements Analyst | Transform meeting notes into requirements |
| Legacy Analyst | Extract business rules from COBOL code |
| Diagram Architect | Create Mermaid and draw.io diagrams |
| Documentation Reviewer | Review documentation quality |

## Custom Prompts

| Prompt | Purpose |
|--------|---------|
| `/extract-requirements` | Meeting notes to requirements doc |
| `/analyze-cobol` | COBOL code to business rules |
| `/create-architecture-diagram` | System architecture diagram |
| `/create-sequence-diagram` | Trade execution sequence |
| `/create-legacy-flowchart` | COBOL process flow |
| `/create-fee-logic-diagram` | Fee calculation logic |
| `/create-state-diagram` | Account state machine |
| `/review-documentation` | Quality review all outputs |

## Directory Structure

```
├── .github/
│   ├── agents/              # Custom Copilot agents
│   ├── prompts/             # Reusable prompts
│   └── copilot-instructions.md
├── inputs/
│   ├── meeting-notes/       # Meeting transcripts
│   ├── legacy-code/         # COBOL trade settlement program
│   └── existing-docs/       # Outdated documentation
├── outputs/                 # Your work goes here
│   ├── requirements/
│   └── diagrams/
├── exercises/               # Detailed lab instructions
├── templates/               # Document templates
├── examples/                # Before/after examples
└── reference/               # Glossary and standards
```

## Key Input Materials

- **Portfolio Rebalancing Notes** - Meeting transcript to convert to requirements
- **TRDSETTL COBOL Program** - 1994 trade settlement system with embedded business rules
- **Legacy System Doc** - Intentionally outdated documentation for comparison

## Tools

- **GitHub Copilot** - AI assistant with custom agents
- **Mermaid Live Editor** - https://mermaid.live
- **Draw.io** - https://app.diagrams.net (optional)

## License

MIT
