# Lab Action Guide

Follow these steps through each stage. After each stage, run `/hand-off` to track progress in `outputs/workflow-tracker.md`.

## Quick Reference

| Stage | Agent (select from dropdown) | Prompt | Core Artifacts |
|-------|------------------------------|--------|----------------|
| 0 | — | — | Environment setup, verify `.github/agents/` |
| 1A | Requirements Analyst | `/extract-requirements` | `outputs/requirements/portfolio-rebalancing-requirements.md` |
| 1B | Legacy Analyst | `/analyze-cobol` | `outputs/requirements/trade-settlement-requirements.md` |
| 2A | Diagram Architect | `/create-architecture-diagram` | `outputs/diagrams/portfolio-architecture.md` |
| 2B | Diagram Architect | `/create-sequence-diagram` | `outputs/diagrams/trade-execution-sequence.md` |
| 2C | Diagram Architect | `/create-legacy-flowchart` | `outputs/diagrams/trade-settlement-flow.md` |
| 2D | Diagram Architect | `/create-fee-logic-diagram` | `outputs/diagrams/fee-calculation-logic.md` |
| 2E | Diagram Architect | `/create-state-diagram` | `outputs/diagrams/settlement-states.md` |
| 3 | Documentation Reviewer | `/review-documentation` | `outputs/review-summary.md` |

**Total Duration:** 50 minutes

---

## How to Use Agents

Agents are selected using the **Agent Selector Dropdown** in Copilot Chat (not by typing `@`).

1. Open Copilot Chat (Ctrl+Shift+I / Cmd+Shift+I)
2. Click the **Agent Selector Dropdown** (top of chat panel)
3. Select the appropriate agent for your task
4. Type your prompt and press Enter

![Agent Selector](https://code.visualstudio.com/assets/docs/copilot/chat/agent-picker.png)

## Available Agents

| Agent | Purpose |
|-------|---------|
| Requirements Analyst | Transform meeting notes into requirements |
| Legacy Analyst | Extract business rules from COBOL code |
| Diagram Architect | Create Mermaid and draw.io diagrams |
| Documentation Reviewer | Review documentation quality |

## Available Prompts

| Prompt | Purpose | Invoke With |
|--------|---------|-------------|
| `/extract-requirements` | Meeting notes → requirements doc | Type `/extract-requirements` |
| `/analyze-cobol` | COBOL code → business rules | Type `/analyze-cobol` |
| `/create-architecture-diagram` | System architecture Mermaid | Type `/create-architecture-diagram` |
| `/create-sequence-diagram` | Trade flow sequence Mermaid | Type `/create-sequence-diagram` |
| `/create-legacy-flowchart` | COBOL process flow Mermaid | Type `/create-legacy-flowchart` |
| `/create-fee-logic-diagram` | Fee calculation flowchart | Type `/create-fee-logic-diagram` |
| `/create-state-diagram` | Account states Mermaid | Type `/create-state-diagram` |
| `/create-drawio-diagram` | Draw.io layout instructions | Type `/create-drawio-diagram` |
| `/drawio-legacy-system` | Legacy system draw.io diagram | Type `/drawio-legacy-system` |
| `/review-documentation` | Quality review all outputs | Type `/review-documentation` |
| `/hand-off` | Progress summary between stages | Type `/hand-off` |

---

## Stage 0 – Environment Setup

**Duration:** 5 minutes (pre-lab)

### For Facilitators

1. **Environment Check**
   - [ ] Participants have VS Code with GitHub Copilot
   - [ ] Repository cloned to local machines
   - [ ] Verify `.github/agents/` folder is present
   - [ ] Verify `.github/prompts/` folder is present
   - [ ] Test: Open Agent Selector Dropdown to see custom agents
   - [ ] Test: Type `/` in Copilot Chat to see custom prompts

2. **Materials Review**
   - [ ] Review `inputs/meeting-notes/portfolio-rebalancing-notes.md`
   - [ ] Review `inputs/legacy-code/trade-settlement-calc.cbl`
   - [ ] Test example diagrams at https://mermaid.live

### For Participants

1. **Setup Checklist**
   - [ ] Open this repository in VS Code
   - [ ] Verify Copilot Chat is active (Ctrl+Shift+I / Cmd+Shift+I)
   - [ ] Click Agent Selector Dropdown to verify custom agents appear
   - [ ] Type `/` to verify custom prompts appear
   - [ ] Bookmark https://mermaid.live

2. **Directory Orientation**
   ```
   inputs/                    ← Source materials
   ├── meeting-notes/         ← Meeting transcripts
   ├── legacy-code/           ← COBOL program
   └── existing-docs/         ← (Outdated) documentation
   outputs/                   ← YOUR WORK GOES HERE
   ├── requirements/
   ├── diagrams/
   └── workflow-tracker.md
   .github/
   ├── agents/               ← Custom Copilot agents
   └── prompts/              ← Reusable prompts
   ```

**Hand-Off:** Run `/hand-off` to initialize `outputs/workflow-tracker.md`

---

## Stage 1A – Requirements from Meeting Notes (8 min)

**Agent:** Requirements Analyst (select from dropdown)
**Prompt:** `/extract-requirements`

### Actions

1. **Open input file:**
   ```
   inputs/meeting-notes/portfolio-rebalancing-notes.md
   ```

2. **Select agent:** Click Agent Selector Dropdown → **Requirements Analyst**

3. **Enter prompt:**
   ```
   Transform the meeting notes in
   #file:inputs/meeting-notes/portfolio-rebalancing-notes.md
   into a professional requirements document
   ```

   **Or use the prompt:** `/extract-requirements`

4. **Review output for:**
   - [ ] Feature overview (2-3 sentences)
   - [ ] 3-5 user stories with acceptance criteria
   - [ ] Business rules with conditions
   - [ ] Assumptions documented
   - [ ] Open questions captured

5. **Save to:**
   ```
   outputs/requirements/portfolio-rebalancing-requirements.md
   ```

**Hand-Off:** `/hand-off` note requirements extracted, artifact saved

---

## Stage 1B – Requirements from Legacy COBOL (12 min)

**Agent:** Legacy Analyst (select from dropdown)
**Prompt:** `/analyze-cobol`

### The Challenge

Your company has TRDSETTL, a 1994 COBOL program that calculates trade settlement and fees. The original authors left years ago. **Extract the business requirements from the code.**

### Actions

1. **Open legacy code:**
   ```
   inputs/legacy-code/trade-settlement-calc.cbl
   ```

2. **Select agent:** Click Agent Selector Dropdown → **Legacy Analyst**

3. **Step 1 - Structure Analysis (3 min):** Enter:
   ```
   Analyze the structure of
   #file:inputs/legacy-code/trade-settlement-calc.cbl
   Identify the main purpose, major sections, and data structures.
   ```

4. **Step 2 - Extract Business Rules (5 min):** Enter:
   ```
   Extract all business rules from
   #file:inputs/legacy-code/trade-settlement-calc.cbl
   Focus on: fee calculations, account types, validation rules,
   settlement dates, and tier discounts.
   Format as a business rules catalog with Rule IDs.
   ```

5. **Step 3 - Create Requirements (4 min):** Enter:
   ```
   Create a formal requirements document from
   the extracted business rules. Include: System Overview,
   Functional Requirements, Business Rules Table, Known Issues,
   and Integration Points.
   ```

   **Or use the prompt:** `/analyze-cobol`

6. **Success Criteria:**
   - [ ] At least 10 business rules extracted
   - [ ] Fee calculation logic documented
   - [ ] Account type handling covered
   - [ ] Known issues from comments identified

7. **Save to:**
   ```
   outputs/requirements/trade-settlement-requirements.md
   ```

**Hand-Off:** `/hand-off` note business rules count, key findings, issues identified

---

## Stage 2A – Architecture Diagram (5 min)

**Agent:** Diagram Architect (select from dropdown)
**Prompt:** `/create-architecture-diagram`

### Actions

1. **Select agent:** Click Agent Selector Dropdown → **Diagram Architect**

2. **Enter prompt:**
   ```
   Create a Mermaid architecture diagram for
   a portfolio management system with: Web/Mobile apps, API Gateway,
   Auth/Portfolio/Trading/Notification services, PostgreSQL, Redis,
   and Market Data Feed. Use subgraphs for layers.
   ```

   **Or use the prompt:** `/create-architecture-diagram`

3. **Test at:** https://mermaid.live

4. **Save to:**
   ```
   outputs/diagrams/portfolio-architecture.md
   ```

---

## Stage 2B – Sequence Diagram (5 min)

**Agent:** Diagram Architect (select from dropdown)
**Prompt:** `/create-sequence-diagram`

### Actions

1. **Select agent:** Click Agent Selector Dropdown → **Diagram Architect**

2. **Enter prompt:**
   ```
   Create a Mermaid sequence diagram for trade
   execution: User → Web App → API Gateway → Trading Service →
   Portfolio Service → External Broker → Notification. Include an
   alt block for insufficient funds.
   ```

   **Or use the prompt:** `/create-sequence-diagram`

3. **Test at:** https://mermaid.live

4. **Save to:**
   ```
   outputs/diagrams/trade-execution-sequence.md
   ```

**Hand-Off:** `/hand-off` note diagrams created, any rendering issues

---

## Stage 2C – Legacy System Flow Diagram (5 min)

**Agent:** Diagram Architect (select from dropdown)
**Prompt:** `/create-legacy-flowchart`

### Why This Matters

Legacy code is often in languages few understand. Diagrams become **living documentation** that bridges code and understanding.

### Actions

1. **Select agent:** Click Agent Selector Dropdown → **Diagram Architect**

2. **Enter prompt:**
   ```
   Using my extracted requirements from
   #file:outputs/requirements/trade-settlement-requirements.md
   create a Mermaid flowchart showing the TRDSETTL processing flow:
   Initialization → Validation → Fee Calculation → Settlement →
   Margin Rules → Finalization. Include decision diamonds and error paths.
   ```

   **Or use the prompt:** `/create-legacy-flowchart`

3. **Test at:** https://mermaid.live

4. **Save to:**
   ```
   outputs/diagrams/trade-settlement-flow.md
   ```

---

## Stage 2D – Fee Calculation Logic Diagram (5 min)

**Agent:** Diagram Architect (select from dropdown)
**Prompt:** `/create-fee-logic-diagram`

### Actions

1. **Select agent:** Click Agent Selector Dropdown → **Diagram Architect**

2. **Enter prompt:**
   ```
   Create a Mermaid flowchart showing fee
   calculation logic: Commission (base 0.75%, tier discounts,
   min/max), SEC Fee (sells only), TAF Fee (sells only, capped),
   Exchange fees (varies), and Foreign security fees. Use subgraphs.
   ```

   **Or use the prompt:** `/create-fee-logic-diagram`

3. **Test at:** https://mermaid.live

4. **Save to:**
   ```
   outputs/diagrams/fee-calculation-logic.md
   ```

---

## Stage 2E – State Diagram (5 min)

**Agent:** Diagram Architect (select from dropdown)
**Prompt:** `/create-state-diagram`

### Actions

1. **Select agent:** Click Agent Selector Dropdown → **Diagram Architect**

2. **Enter prompt:**
   ```
   Create a Mermaid stateDiagram-v2 showing
   account status states: ACTIVE, SUSPENDED, RESTRICTED, CLOSED.
   Show allowed transitions and what triggers them.
   ```

   **Or use the prompt:** `/create-state-diagram`

3. **Test at:** https://mermaid.live

4. **Save to:**
   ```
   outputs/diagrams/settlement-states.md
   ```

**Hand-Off:** `/hand-off` note all diagrams complete, rendering verified

---

## Stage 2 Bonus – Draw.io Diagrams

**Prompts:** `/create-drawio-diagram`, `/drawio-legacy-system`

If you prefer draw.io over Mermaid, use these prompts for layout instructions:

```
/create-drawio-diagram Create a draw.io architecture diagram
for the portfolio management system

/drawio-legacy-system Create a draw.io process flow diagram
for the TRDSETTL legacy system
```

Open https://app.diagrams.net to create the diagrams using the layout instructions.

---

## Stage 3 – Documentation Review (5 min)

**Agent:** Documentation Reviewer (select from dropdown)
**Prompt:** `/review-documentation`

### Actions

1. **Gather all outputs:**
   - `outputs/requirements/*.md`
   - `outputs/diagrams/*.md`

2. **Select agent:** Click Agent Selector Dropdown → **Documentation Reviewer**

3. **Enter prompt:**
   ```
   Review all documentation in
   #file:outputs/requirements/portfolio-rebalancing-requirements.md
   #file:outputs/requirements/trade-settlement-requirements.md
   and diagrams in outputs/diagrams/.
   Evaluate: Completeness, Clarity, Consistency, Accuracy, Traceability.
   Score out of 100 and identify top 3 improvements.
   ```

   **Or use the prompt:** `/review-documentation`

4. **Address top issues** identified in the review

5. **Save to:**
   ```
   outputs/review-summary.md
   ```

**Hand-Off:** `/hand-off` note quality score, issues addressed, lab complete

---

## Completion Checklist

**Lab 1 Outputs (Requirements):**
- [ ] `outputs/requirements/portfolio-rebalancing-requirements.md`
- [ ] `outputs/requirements/trade-settlement-requirements.md`

**Lab 2 Outputs (Diagrams):**
- [ ] `outputs/diagrams/portfolio-architecture.md`
- [ ] `outputs/diagrams/trade-execution-sequence.md`
- [ ] `outputs/diagrams/trade-settlement-flow.md`
- [ ] `outputs/diagrams/fee-calculation-logic.md`
- [ ] `outputs/diagrams/settlement-states.md`

**Lab 3 Outputs (Review):**
- [ ] `outputs/review-summary.md`

**Tracking:**
- [ ] `outputs/workflow-tracker.md` (updated via `/hand-off`)

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Agent not in dropdown | Verify `.github/agents/` folder exists with `.agent.md` files |
| Prompt not appearing | Verify `.github/prompts/` folder exists with `.prompt.md` files |
| Mermaid won't render | Check syntax at https://mermaid.live, look for missing quotes |
| Output too generic | Reference specific files with `#file:path/to/file.md` |
| COBOL analysis shallow | Ask agent to focus on specific sections (3000-CALC-FEES) |

### COBOL Patterns Reference

| Element | Meaning |
|---------|---------|
| `PERFORM paragraph` | Function call |
| `EVALUATE` | Switch/case logic |
| `IF` | Conditional branch |
| `88-level` | Valid values enum |
| `COMPUTE` | Calculation |
| `CALL 'program'` | External dependency |
| `*` comments | Developer notes |
| `TODO` | Known issues |

---

## Bonus Challenge

Compare your extracted requirements to the existing (outdated) documentation:

1. Select **Legacy Analyst** from the Agent Selector Dropdown
2. Enter:
   ```
   Compare
   #file:outputs/requirements/trade-settlement-requirements.md
   with #file:inputs/existing-docs/legacy-system-doc.md

   Identify:
   1. What's in the code but not documented?
   2. What's documented but wrong?
   3. Which is more accurate?
   ```

This demonstrates why **code is the ultimate source of truth** for legacy systems.

---

## Agent Workflow

```
Requirements Analyst → Legacy Analyst → Diagram Architect → Documentation Reviewer
```

Use `/hand-off` after each stage to track progress in `outputs/workflow-tracker.md`.

---

## Facilitator Notes

### Pacing Tips
- Start each stage with 1-minute overview
- Give 2-minute warning before stage ends
- Demonstrate agent selection from dropdown first
- Show prompt usage (`/prompt-name`) as alternative
- Have example outputs ready for stuck participants

### Key Learning Points

1. **Agents are specialists** - Each agent has focused expertise
2. **Prompts are shortcuts** - Pre-built workflows for common tasks
3. **File references matter** - Use `#file:` to give agents context
4. **Legacy code is source of truth** - Documentation is often wrong
5. **Diagrams bridge understanding** - Visualize what code does

### Debrief Questions

1. Which agent was most helpful for your workflow?
2. How did prompts save time vs. manual prompting?
3. What surprised you about the legacy code analysis?
4. Which diagrams would you use for your own systems?

---

**End of Lab Action Guide**
