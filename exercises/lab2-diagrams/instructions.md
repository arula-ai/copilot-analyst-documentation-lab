# Lab 2: Creating Visual Diagrams

## Objective
Create professional diagrams using AI-generated Mermaid syntax. This lab covers:
1. System architecture diagrams
2. Sequence diagrams for workflows
3. Process flowcharts
4. **Legacy system visualization** - turning complex code into understandable diagrams

## Duration
25 minutes

---

## Task 1: Architecture Diagram (5 minutes)

### Scenario
Create an architecture diagram for the portfolio management system.

### Components to Include
- Web Application
- Mobile Application
- API Gateway
- Authentication Service
- Portfolio Service
- Trading Service
- Notification Service
- PostgreSQL Database
- Redis Cache
- External: Market Data Feed

### AI Prompt
```
Create a Mermaid architecture diagram for a portfolio management system:

Components:
- Web App and Mobile App (client layer)
- API Gateway (routing layer)
- Auth Service, Portfolio Service, Trading Service, Notification Service
- PostgreSQL database, Redis cache
- External market data feed integration

Requirements:
- Group components by layer
- Show data flow directions
- Label all connections
- Use subgraphs for logical grouping

Output: Valid Mermaid graph TD syntax
```

### Deliverable
Save diagram to `outputs/diagrams/portfolio-architecture.md`

Verify it renders correctly at https://mermaid.live

---

## Task 2: Sequence Diagram (5 minutes)

### Scenario
Create a sequence diagram for the trade execution flow.

### Flow to Document
1. User initiates trade in Web App
2. Request goes through API Gateway
3. Trading Service validates order
4. Trading Service checks with Portfolio Service for funds
5. Trading Service submits to external broker
6. On success: update portfolio, send notification
7. Return confirmation to user

### AI Prompt
```
Create a Mermaid sequence diagram for trade execution:

Participants:
- User
- Web App
- API Gateway
- Trading Service
- Portfolio Service
- External Broker
- Notification Service

Flow:
1. User submits trade order
2. Validate order details
3. Check available funds
4. Submit to broker
5. Receive execution confirmation
6. Update portfolio
7. Send notification
8. Return confirmation to user

Include:
- Success path with all steps
- Alt block for insufficient funds scenario
- Proper arrow types (sync vs async)
```

### Deliverable
Save to `outputs/diagrams/trade-execution-sequence.md`

---

## Task 3: Legacy COBOL System Diagrams (15 minutes)

### The Challenge
You've extracted requirements from the TRDSETTL COBOL program in Lab 1. Now you need to create visual diagrams that help stakeholders understand how this 30-year-old system actually works.

**Your mission:** Create diagrams that make the complex business logic accessible to:
- Business stakeholders (who can't read COBOL)
- Developers (who need to understand the system for modernization)
- Compliance teams (who need to verify fee calculation rules)

### Input Materials
Use the COBOL program in `inputs/legacy-code/trade-settlement-calc.cbl`
(Or use your extracted requirements from Lab 1)

### Why Diagrams Matter for Legacy Systems
Legacy code is often:
- Written in languages few people know
- Complex with nested conditions
- Missing documentation
- Critical to business operations

Diagrams bridge the gap between code and understanding. They become the **living documentation** for legacy systems.

---

### Task 3A: Program Flow Diagram (5 minutes)

Create a flowchart showing the main processing flow of the TRDSETTL program.

#### AI Prompt
```
Based on this COBOL trade settlement program, create a Mermaid flowchart
showing the main processing flow:

[Paste the COBOL code or your extracted requirements]

The flowchart should show:
1. Initialization
2. Validation phase (account status, security checks, quantity validation)
3. Fee calculation phase (commission, regulatory fees, exchange fees)
4. Settlement date calculation
5. Margin rules application (if margin account)
6. Finalization and audit logging

Include:
- Decision diamonds for key validations
- Error/rejection paths
- The main success path
- Labels showing what each step does

Make it understandable to a business analyst who doesn't know COBOL.
Output: Valid Mermaid flowchart syntax
```

#### Deliverable
Save to `outputs/diagrams/trade-settlement-flow.md`

---

### Task 3B: Fee Calculation Logic Diagram (5 minutes)

Create a diagram that visualizes the complex fee calculation logic.

#### AI Prompt
```
Create a Mermaid flowchart showing the fee calculation logic from this
COBOL trade settlement system:

[Paste the fee-related sections of the COBOL code]

The diagram should show:

1. Commission Calculation Path:
   - Check if mutual fund (different calculation)
   - Calculate base commission (0.75% of principal)
   - Apply tier discount based on account tier (1-6)
   - Apply account-level negotiated discount
   - Enforce min ($4.95) / max ($29.95)
   - Special case: zero commission for principal trades

2. Regulatory Fee Path:
   - SEC Fee (only on sells, based on principal)
   - TAF Fee (only on sells, per share with cap)

3. Other Fees:
   - Exchange fees (varies by exchange)
   - Foreign security fees (ADR custody fee)
   - Principal trade markup

4. Total Fee Calculation

Show decision points and different calculation paths clearly.
Use subgraphs to group related calculations.
Output: Valid Mermaid flowchart syntax
```

#### Deliverable
Save to `outputs/diagrams/fee-calculation-logic.md`

---

### Task 3C: State Diagram for Order Processing (5 minutes)

Create a state diagram showing order/account states and transitions.

#### AI Prompt
```
Create a Mermaid state diagram showing the states and transitions in
this COBOL trade settlement system:

[Paste the relevant COBOL code sections]

Document two state machines:

1. Account Status States:
   - ACTIVE (can trade freely)
   - SUSPENDED (no trading)
   - RESTRICTED (sell/close only)
   - CLOSED (no activity)
   Show what actions are allowed in each state.

2. Order Processing States:
   - CREATED
   - VALIDATING
   - VALIDATED
   - REJECTED
   - PENDING
   - SUBMITTED
   - PARTIAL_FILL
   - FILLED
   - CANCELLED
   - EXPIRED
   - FAILED
   Show transitions and what triggers each transition.

Use Mermaid stateDiagram-v2 syntax.
Include guards/conditions on transitions where applicable.
```

#### Deliverable
Save to `outputs/diagrams/settlement-states.md`

---

### Bonus: Settlement Date Decision Tree

If time permits, create a decision tree showing how settlement dates are calculated:

#### AI Prompt
```
Create a Mermaid flowchart showing settlement date calculation logic:

Decision tree based on security type:
- Equity/ETF → T+1
- Options → T+1
- Mutual Funds → T+1 (varies)
- Corporate Bonds → T+2
- Government Bonds/T-Bills → T+1
- Other → T+2

After determining base days:
- Call DATEUTIL to skip weekends and holidays
- Return final settlement date

Show as a clear decision tree with security types and resulting settlement days.
```

#### Deliverable
Save to `outputs/diagrams/settlement-date-logic.md`

---

## Verification

For each diagram:
1. Paste into https://mermaid.live
2. Verify it renders without errors
3. Check all labels are readable
4. Confirm flow is logical and matches the code
5. Would a non-technical stakeholder understand it?

---

## Deliverable Summary

By the end of Lab 2, you should have:

| Diagram | File | Purpose |
|---------|------|---------|
| Architecture | `portfolio-architecture.md` | System components and connections |
| Trade Execution | `trade-execution-sequence.md` | New system workflow |
| Settlement Flow | `trade-settlement-flow.md` | Legacy COBOL main process |
| Fee Calculation | `fee-calculation-logic.md` | Complex fee logic visualization |
| State Machines | `settlement-states.md` | Account and order states |

---

## Tips for Diagramming Legacy Systems

### Extracting Diagram Content from Code

**COBOL Structure → Diagram Elements:**
| COBOL Element | Diagram Element |
|---------------|-----------------|
| PERFORM paragraph | Process box |
| IF/EVALUATE | Decision diamond |
| 88-level conditions | State values |
| COMPUTE | Calculation note |
| CALL | External system box |
| Error conditions | Error path |

### Common Patterns to Look For

1. **Nested IFs** → Multiple decision diamonds in sequence
2. **EVALUATE statements** → Multiple branches from one decision
3. **PERFORM loops** → Iteration indicators
4. **Error handling** → Alternative paths to error states

### Making Diagrams Understandable

1. **Use business language**, not code variable names
   - Not: "WS-SEC-FEE-RATE"
   - Yes: "SEC Fee Rate ($27.80 per $1M)"

2. **Group related logic** using subgraphs

3. **Show the happy path** prominently, exceptions as branches

4. **Add annotations** for complex calculations

5. **Include key values** (rates, limits, thresholds)
