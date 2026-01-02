# Sample Diagrams

Collection of example Mermaid diagrams for reference.

---

## 1. Portfolio Management Architecture

```mermaid
graph TD
    subgraph "Client Layer"
        WEB[Web Application]
        MOB[Mobile App]
    end

    subgraph "Gateway Layer"
        GW[API Gateway]
        AUTH[Auth Service]
    end

    subgraph "Service Layer"
        PS[Portfolio Service]
        TS[Trading Service]
        NS[Notification Service]
        RS[Reporting Service]
    end

    subgraph "Data Layer"
        PG[(PostgreSQL)]
        RD[(Redis Cache)]
        ES[(Elasticsearch)]
    end

    subgraph "External"
        MDF[Market Data Feed]
        BRK[Broker API]
    end

    WEB --> GW
    MOB --> GW
    GW --> AUTH
    GW --> PS
    GW --> TS
    GW --> RS
    PS --> PG
    PS --> RD
    TS --> BRK
    TS --> MDF
    TS --> NS
    RS --> ES
    NS --> WEB
    NS --> MOB
```

---

## 2. Trade Execution Sequence

```mermaid
sequenceDiagram
    participant U as User
    participant W as Web App
    participant G as API Gateway
    participant T as Trading Service
    participant P as Portfolio Service
    participant B as Broker
    participant N as Notification

    U->>W: Submit Order
    W->>G: POST /orders
    G->>T: Create Order

    T->>P: Check Funds
    P-->>T: Funds Available

    T->>T: Validate Order
    T->>B: Submit to Broker

    alt Order Accepted
        B-->>T: Execution Confirmed
        T->>P: Update Holdings
        T->>N: Send Confirmation
        N-->>U: Order Filled
    else Order Rejected
        B-->>T: Rejection Reason
        T->>N: Send Alert
        N-->>U: Order Failed
    end
```

---

## 3. Account Onboarding Flow

```mermaid
flowchart TD
    A[Start Application] --> B[Personal Info]
    B --> C[Identity Verification]

    C --> D{ID Verified?}
    D -->|Yes| E[Compliance Checks]
    D -->|No| F[Request Additional Docs]
    F --> C

    E --> G{Checks Pass?}
    G -->|Yes| H{Risk Level?}
    G -->|No| I[Manual Review Queue]

    H -->|Low| J[Auto Approve]
    H -->|High| I

    I --> K{Review Decision}
    K -->|Approve| L[Account Created]
    K -->|Reject| M[Application Denied]

    J --> L
    L --> N[Link Bank Account]
    N --> O[Initial Funding]
    O --> P[Welcome Email]
    P --> Q[End: Active Account]
    M --> R[End: Rejected]
```

---

## 4. Portfolio Data Model

```mermaid
erDiagram
    USER ||--o{ ACCOUNT : owns
    ACCOUNT ||--o{ PORTFOLIO : contains
    PORTFOLIO ||--o{ HOLDING : has
    PORTFOLIO ||--o{ TRANSACTION : records
    HOLDING }o--|| SECURITY : references
    TRANSACTION }o--|| SECURITY : involves

    USER {
        uuid id PK
        string email
        string name
        timestamp created_at
    }

    ACCOUNT {
        uuid id PK
        uuid user_id FK
        string account_type
        string status
    }

    PORTFOLIO {
        uuid id PK
        uuid account_id FK
        string name
        decimal total_value
    }

    HOLDING {
        uuid id PK
        uuid portfolio_id FK
        uuid security_id FK
        decimal quantity
        decimal cost_basis
    }

    SECURITY {
        uuid id PK
        string symbol
        string name
        string type
    }

    TRANSACTION {
        uuid id PK
        uuid portfolio_id FK
        uuid security_id FK
        string type
        decimal amount
        timestamp executed_at
    }
```

---

## 5. Order State Machine

```mermaid
stateDiagram-v2
    [*] --> Draft: Create Order

    Draft --> Pending: Submit
    Draft --> Cancelled: Cancel

    Pending --> Validated: Pass Validation
    Pending --> Rejected: Fail Validation

    Validated --> Submitted: Send to Broker
    Validated --> Cancelled: Cancel

    Submitted --> PartialFill: Partial Execution
    Submitted --> Filled: Full Execution
    Submitted --> Failed: Broker Error

    PartialFill --> Filled: Complete
    PartialFill --> Cancelled: Cancel Remaining

    Filled --> [*]
    Cancelled --> [*]
    Rejected --> [*]
    Failed --> [*]
```

---

## 6. Rebalancing Process

```mermaid
flowchart LR
    subgraph "Analysis"
        A[Get Current Allocation] --> B[Compare to Target]
        B --> C{Drift > Threshold?}
    end

    subgraph "Planning"
        C -->|Yes| D[Calculate Trades]
        D --> E[Tax Optimization]
        E --> F[Generate Proposal]
    end

    subgraph "Execution"
        F --> G{User Approval}
        G -->|Approve| H[Execute Trades]
        G -->|Modify| D
        G -->|Reject| I[Cancel]
        H --> J[Update Portfolio]
    end

    C -->|No| K[No Action Needed]
```

---

## Diagram Best Practices

1. **Keep it simple** - Don't overcrowd diagrams
2. **Use consistent naming** - Same terms in docs and diagrams
3. **Add labels** - Explain connections and decisions
4. **Group logically** - Use subgraphs for layers/domains
5. **Test rendering** - Verify at mermaid.live before sharing
