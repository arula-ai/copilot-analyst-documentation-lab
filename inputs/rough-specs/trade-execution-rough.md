# Trade Execution Engine - Rough Technical Spec

**Author:** Mike Rodriguez
**Last Updated:** Oct 8, 2025 (draft v0.3)
**Status:** DRAFT - Not reviewed

---

## Background / Why

We're rebuilding the trade execution engine. Current system (built 2018) is showing its age:
- Latency issues - order submission averaging 450ms, should be under 100ms
- Reliability problems - 2-3 incidents per quarter from the order routing logic
- Can't support new order types that clients are asking for (bracket orders, OCO)
- Hard to add new broker integrations - took 6 months to add Apex last year
- Monolithic architecture makes it hard to scale pieces independently

The new system needs to support:
1. Retail clients placing orders via web/mobile
2. Advisor bulk orders (multiple clients at once)
3. Automated trading (rebalancing, DRIP, etc.)
4. Eventually: API access for algorithmic traders (phase 2)

---

## High-Level Architecture

```
                    ┌──────────────────┐
                    │   API Gateway    │
                    │  (rate limiting, │
                    │   auth)          │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │  Order Service   │
                    │  (validation,    │
                    │   routing)       │
                    └────────┬─────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
     ┌────────▼───────┐ ┌────▼────┐ ┌───────▼───────┐
     │ Broker Adapter │ │ Broker  │ │ Broker Adapter│
     │ (Apex)         │ │ Adapter │ │ (DriveWealth) │
     │                │ │(Schwab) │ │               │
     └────────┬───────┘ └────┬────┘ └───────┬───────┘
              │              │              │
              └──────────────┴──────────────┘
                             │
                    ┌────────▼─────────┐
                    │   Market/Broker  │
                    │   (external)     │
                    └──────────────────┘
```

**Key design decisions:**
- Microservices but not too micro - order service handles core logic, adapters are separate
- Event-driven for status updates (Kafka)
- Postgres for order storage, Redis for caching and rate limiting
- Stateless services for horizontal scaling

---

## Order Lifecycle

### States

```
CREATED        -> Order received, not yet validated
VALIDATING     -> Running validations (funds, restrictions, etc.)
VALIDATED      -> Passed all checks, ready to route
REJECTED       -> Failed validation (terminal)
PENDING        -> Sent to broker, awaiting acknowledgment
SUBMITTED      -> Broker acknowledged, waiting for fill
PARTIAL_FILL   -> Some quantity filled
FILLED         -> Fully executed (terminal)
CANCELLED      -> User or system cancelled (terminal)
EXPIRED        -> Time-in-force expired (terminal)
FAILED         -> Broker error or system failure (terminal)
```

### State Transitions

| From | To | Trigger |
|------|-------|---------|
| CREATED | VALIDATING | Immediate on receipt |
| VALIDATING | VALIDATED | All validations pass |
| VALIDATING | REJECTED | Any validation fails |
| VALIDATED | PENDING | Route to broker |
| PENDING | SUBMITTED | Broker ACK received |
| PENDING | FAILED | Broker NAK or timeout |
| SUBMITTED | PARTIAL_FILL | Execution report (partial) |
| SUBMITTED | FILLED | Execution report (complete) |
| PARTIAL_FILL | FILLED | Remaining quantity filled |
| SUBMITTED | CANCELLED | Cancel confirmed |
| PARTIAL_FILL | CANCELLED | Cancel confirmed (partial) |
| SUBMITTED | EXPIRED | Market close / TIF expiry |

**TODO:** Need to handle edge case where broker sends fill before ACK (happens with Apex sometimes)

**TODO:** What happens if we get conflicting messages? e.g., cancel confirm followed by fill?

---

## Order Types Supported

### Phase 1 (MVP)

| Type | Description | Supported TIF |
|------|-------------|---------------|
| MARKET | Execute at current market price | DAY, IOC, FOK |
| LIMIT | Execute at specified price or better | DAY, GTC, IOC, FOK |
| STOP | Trigger market order when stop price hit | DAY, GTC |
| STOP_LIMIT | Trigger limit order when stop price hit | DAY, GTC |

### Phase 2 (Q2 2026?)

| Type | Description | Notes |
|------|-------------|-------|
| BRACKET | Entry + profit target + stop loss | Need UI work |
| OCO | One-cancels-other | Complex order linking |
| TRAILING_STOP | Stop that trails price | Real-time price monitoring |

### TIF (Time-in-Force) Options

- **DAY**: Cancel at market close if not filled
- **GTC**: Good til cancelled (we cap at 90 days per Apex rules)
- **IOC**: Immediate or cancel - fill what you can, cancel rest
- **FOK**: Fill or kill - all or nothing
- **EXT**: Extended hours (pre-market/after-hours)

**TODO:** EXT hours - need to check which brokers support and price implications

---

## Validation Rules

All orders must pass these validations before routing:

### 1. Account Validations
- [ ] Account is active (not closed, frozen, or restricted)
- [ ] Account is enabled for trading (not view-only)
- [ ] User has permission to trade this account (owner or authorized)
- [ ] Account is not in margin call status

### 2. Security Validations
- [ ] Security exists in our universe
- [ ] Security is tradeable (not halted, delisted, or restricted)
- [ ] Security is available at selected broker
- [ ] No trading restrictions on security for this account (employer restrictions, etc.)

### 3. Order Validations
- [ ] Order type supported for this security (some ETFs don't allow limit orders??)
- [ ] Price within reasonable bounds (limit orders not >50% from market?)
- [ ] Quantity is valid (positive, whole shares for non-fractional, within lot size)
- [ ] Total order value within account limits

### 4. Funds/Position Validations

**For BUY orders:**
- [ ] Sufficient cash or buying power
- [ ] Order doesn't exceed concentration limits
- [ ] If margin: check margin requirements

**For SELL orders:**
- [ ] Sufficient shares owned
- [ ] Shares not already committed to other orders
- [ ] Check for wash sale implications? (or just warn?)

### 5. Market Hours Validations
- [ ] Market is open for order type (extended hours orders only during extended sessions)
- [ ] If market closed: queue for next open vs reject?

**TODO:** Talk to compliance about validation #4 wash sale thing - is it a blocker or just informational?

**TODO:** What's our position on orders placed outside market hours? Current system queues them. Do we want that?

---

## Broker Routing Logic

We currently use three brokers:

| Broker | Account Types | Best For |
|--------|--------------|----------|
| Apex Clearing | Retail, small advisor | Fractional shares, low minimums |
| Schwab | Larger accounts | Research, customer service |
| DriveWealth | International (UK) | EU compliance |

### Routing Rules (simplified)

```python
def select_broker(order, account):
    # International accounts go to DriveWealth
    if account.country != 'US':
        return 'DRIVEWEALTH'

    # Accounts already at a specific broker stay there
    if account.primary_broker:
        return account.primary_broker

    # Large accounts go to Schwab
    if account.total_value > 500000:
        return 'SCHWAB'

    # Fractional orders need Apex
    if order.quantity % 1 != 0:
        return 'APEX'

    # Default to Apex
    return 'APEX'
```

**TODO:** This is way too simple. Need to factor in:
- Order type support per broker
- Current broker capacity/latency
- Cost optimization (some brokers cheaper for certain order sizes)
- Smart order routing for best execution (NBBO compliance)

---

## API Contracts

### Submit Order

```
POST /v1/orders

Request:
{
  "accountId": "acc_123",
  "symbol": "AAPL",
  "side": "BUY" | "SELL",
  "quantity": 10.5,
  "orderType": "MARKET" | "LIMIT" | "STOP" | "STOP_LIMIT",
  "limitPrice": 150.00,           // required for LIMIT, STOP_LIMIT
  "stopPrice": 145.00,            // required for STOP, STOP_LIMIT
  "timeInForce": "DAY" | "GTC" | "IOC" | "FOK",
  "extendedHours": false,
  "clientOrderId": "my-order-123" // optional, for idempotency
}

Response:
{
  "orderId": "ord_abc123",
  "status": "VALIDATING",
  "createdAt": "2025-10-08T14:30:00Z",
  "estimatedFill": {               // best effort estimate
    "price": 150.12,
    "total": 1576.26,
    "commission": 0.00
  }
}
```

### Get Order Status

```
GET /v1/orders/{orderId}

Response:
{
  "orderId": "ord_abc123",
  "accountId": "acc_123",
  "symbol": "AAPL",
  "side": "BUY",
  "quantity": 10.5,
  "filledQuantity": 10.5,
  "remainingQuantity": 0,
  "orderType": "LIMIT",
  "limitPrice": 150.00,
  "status": "FILLED",
  "createdAt": "2025-10-08T14:30:00Z",
  "updatedAt": "2025-10-08T14:30:05Z",
  "executions": [
    {
      "executionId": "exec_001",
      "quantity": 10.5,
      "price": 149.98,
      "timestamp": "2025-10-08T14:30:05Z"
    }
  ],
  "fees": {
    "commission": 0.00,
    "secFee": 0.02,
    "tafFee": 0.01
  }
}
```

### Cancel Order

```
DELETE /v1/orders/{orderId}

Response:
{
  "orderId": "ord_abc123",
  "status": "PENDING_CANCEL",
  "message": "Cancel request submitted"
}
```

**Note:** Cancel is async - order might fill before cancel is processed. Client should poll for final status.

### List Orders

```
GET /v1/orders?accountId=acc_123&status=OPEN&limit=50

Response:
{
  "orders": [...],
  "pagination": {
    "total": 127,
    "limit": 50,
    "offset": 0,
    "hasMore": true
  }
}
```

---

## Events (Kafka Topics)

### order.created
Fired when order is received

### order.status.changed
Fired on every status transition
```json
{
  "orderId": "ord_abc123",
  "previousStatus": "SUBMITTED",
  "newStatus": "FILLED",
  "timestamp": "2025-10-08T14:30:05Z",
  "metadata": {}
}
```

### order.executed
Fired for each execution (partial or full)
```json
{
  "orderId": "ord_abc123",
  "executionId": "exec_001",
  "quantity": 5.0,
  "price": 149.98,
  "timestamp": "2025-10-08T14:30:05Z",
  "isFinal": false
}
```

**Consumers:**
- Portfolio service (update holdings on fill)
- Notification service (send user alerts)
- Analytics (execution quality metrics)
- Audit log (compliance)

---

## Error Handling

### Validation Errors (synchronous)

Return 400 with structured error:
```json
{
  "error": "VALIDATION_FAILED",
  "code": "INSUFFICIENT_FUNDS",
  "message": "Account has insufficient buying power for this order",
  "details": {
    "required": 1500.00,
    "available": 1234.56,
    "shortfall": 265.44
  }
}
```

### Broker Errors (async)

Published to order.status.changed with status=FAILED:
```json
{
  "orderId": "ord_abc123",
  "newStatus": "FAILED",
  "error": {
    "code": "BROKER_REJECTED",
    "brokerCode": "R101",
    "message": "Symbol not available for trading"
  }
}
```

### Retry Logic

| Failure Type | Retry? | Max Attempts | Backoff |
|--------------|--------|--------------|---------|
| Broker timeout | Yes | 3 | Exponential (1s, 2s, 4s) |
| Broker rate limit | Yes | 5 | Fixed (30s) |
| Broker rejection | No | - | - |
| Invalid order | No | - | - |
| System error | Yes | 3 | Exponential |

**TODO:** What if all retries fail? Notify user? Auto-cancel? Leave in limbo?

---

## Performance Requirements

| Metric | Target | Current (baseline) |
|--------|--------|--------------------|
| Order submission latency (p50) | <50ms | ~200ms |
| Order submission latency (p99) | <200ms | ~800ms |
| Order status update latency | <100ms | ~500ms (batch job) |
| Throughput | 1000 orders/sec | ~100 orders/sec |
| Availability | 99.95% | 99.5% |

### Scalability Notes

- Order service should scale horizontally
- Each broker adapter can scale independently
- Redis cluster for rate limiting / caching
- Kafka partitioned by account ID for ordering guarantees

---

## Security Considerations

1. **Authentication**: JWT tokens validated at API gateway
2. **Authorization**: User must own account or have trading permissions
3. **Encryption**: TLS 1.3 for all external communication
4. **Audit**: All order events logged with user context
5. **Rate limiting**: Per-user and per-account limits
6. **PII**: Order data contains account info - handle appropriately

**TODO:** Get security team to do threat modeling before launch

---

## Open Questions / Decisions Needed

1. **Fractional share handling for sells** - If user owns 10.5 shares and sells 10.5, some brokers only support whole shares for sells. Do we split into 10 + 0.5?

2. **Order modification** - Current system doesn't support modifying orders (must cancel and resubmit). Should v2 support native modification?

3. **Pre-market/after-hours default** - Should we allow extended hours trading by default or require explicit opt-in?

4. **Bulk order execution** - For advisor submitting 50 orders at once, do we validate all first then submit all, or stream submissions as each validates?

5. **Price improvement tracking** - How do we track/report when we get better than limit price? Required for best execution reporting.

6. **Broker failover** - If primary broker is down, do we automatically route to backup? What are the implications?

---

## Dependencies

### Internal Services
- Account service (account status, permissions)
- Portfolio service (holdings, buying power calculation)
- Market data service (current prices, security info)
- Notification service (user alerts)
- Compliance service (trading restrictions)

### External
- Apex Clearing API
- Schwab Advisor API
- DriveWealth API
- Market data feed (for validations)

---

## Rough Timeline

Assuming 2 engineers full-time:

- Weeks 1-2: Core order service, state machine, basic validations
- Weeks 3-4: Apex adapter (primary broker)
- Weeks 5-6: API implementation, unit tests
- Weeks 7-8: Integration testing with Apex sandbox
- Weeks 9-10: Schwab adapter
- Weeks 11-12: Performance testing, bug fixes, soft launch

**Total: ~3 months to MVP with 2 brokers**

Phase 2 (additional order types, DriveWealth) probably another 6-8 weeks.

---

## References

- Current order service docs: [Confluence - Order Service](internal link)
- Apex API documentation: [Apex Developer Portal](link)
- Schwab API documentation: [Schwab API](link)
- FINRA best execution requirements: [FINRA Rule 5310](link)

---

*This is a rough spec - lots of details to fill in. Comments welcome in #trade-engine-v2 Slack channel.*
