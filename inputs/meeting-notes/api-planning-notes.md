# Portfolio API v2 - Technical Planning Session
**Date:** Thursday, October 10, 2025 @ 3:30 PM EST
**Location:** Zoom (recorded)
**Attendees:**
- Carlos Mendez (API Platform Lead) - facilitating
- Stephanie Park (Portfolio Service Owner)
- Derek Chang (Mobile Team Lead)
- Nina Volkov (Web Frontend Lead)
- Raj Patel (Security Architect)
- Observer: Amy Liu (Technical Writer)

**Context:** Planning v2 of the Portfolio API to support new mobile app features and the upcoming rebalancing initiative. Current API is v1.3, last major update was 18 months ago.

---

## Current State & Pain Points

Carlos: OK, let's start by listing what's broken or annoying about the current API. I'll go around.

Derek (Mobile): The biggest issue is chattiness. To render the portfolio dashboard, we make 6 separate API calls:
1. GET /portfolios/{id} - basic info
2. GET /portfolios/{id}/holdings - positions
3. GET /portfolios/{id}/performance - returns
4. GET /accounts/{id} - account details
5. GET /users/{id}/preferences - display settings
6. GET /market/quotes?symbols=... - current prices

That's 300-400ms just in network latency on mobile networks. Users see a loading spinner for 2+ seconds.

Nina (Web): Same problem on web, but we hide it better with skeleton screens. We also have issues with stale data - if someone places a trade, the holdings endpoint doesn't reflect it for up to 30 seconds because of caching.

Stephanie: The caching issue is real. We cache at the CDN level and it's hard to invalidate. The trade service publishes events but the portfolio service doesn't consume them fast enough.

Raj: Security concern - the current API returns way more data than clients need. The holdings endpoint returns cost basis and tax lots even for read-only users. We should have field-level access control.

---

## Proposed New Endpoints

### 1. Composite Dashboard Endpoint

Carlos: Let's design a composite endpoint that returns everything the dashboard needs in one call.

**Proposed:** `GET /v2/portfolios/{id}/dashboard`

Derek: What would the response look like?

Carlos: Something like:
```json
{
  "portfolio": {
    "id": "pf_abc123",
    "name": "Main Investment Account",
    "accountType": "INDIVIDUAL",
    "status": "ACTIVE"
  },
  "summary": {
    "totalValue": 125432.87,
    "totalCostBasis": 98000.00,
    "totalGainLoss": 27432.87,
    "totalGainLossPercent": 27.99,
    "cashBalance": 5432.12,
    "lastUpdated": "2025-10-10T15:30:00Z"
  },
  "performance": {
    "dayChange": 342.15,
    "dayChangePercent": 0.27,
    "weekChange": -521.33,
    "weekChangePercent": -0.41,
    "yearToDateReturn": 12.34
  },
  "holdings": [
    {
      "securityId": "sec_vti",
      "symbol": "VTI",
      "name": "Vanguard Total Stock Market ETF",
      "quantity": 45.234,
      "currentPrice": 234.56,
      "marketValue": 10609.23,
      "costBasis": 8500.00,
      "gainLoss": 2109.23,
      "gainLossPercent": 24.81,
      "allocation": 8.46
    }
    // ... more holdings
  ],
  "allocation": {
    "current": {
      "stocks": 72.5,
      "bonds": 18.3,
      "cash": 4.3,
      "other": 4.9
    },
    "target": {
      "stocks": 70.0,
      "bonds": 20.0,
      "cash": 5.0,
      "other": 5.0
    }
  }
}
```

Nina: That's perfect. But can we make holdings optional? On mobile, we might show summary first and lazy-load holdings.

Carlos: Sure, we can use query params. `?include=holdings,allocation`

Raj: I want to flag - this endpoint returns a LOT of data. We need to make sure it's properly authenticated and rate-limited. Also, the cost basis fields should only be returned if the user has appropriate permissions.

Stephanie: We should also consider what happens if part of the data is unavailable. Like, if the market data service is down, do we fail the whole request or return partial data?

Carlos: Good point. Let's add a `_meta` field with data freshness info:
```json
{
  "_meta": {
    "pricesAsOf": "2025-10-10T15:29:45Z",
    "pricesDelayed": false,
    "holdingsAsOf": "2025-10-10T15:30:00Z",
    "partialData": false,
    "warnings": []
  }
}
```

**DECISION: Dashboard endpoint will be composite with optional includes and metadata**

---

### 2. Performance History Endpoint

Carlos: Next, we need a better performance endpoint. Current one only returns point-in-time values.

**Proposed:** `GET /v2/portfolios/{id}/performance`

**Query Parameters:**
- `period`: 1D, 1W, 1M, 3M, 6M, 1Y, YTD, ALL
- `interval`: For charts - AUTO, HOUR, DAY, WEEK, MONTH
- `benchmark`: Optional benchmark symbol for comparison (e.g., SPY, ^GSPC)
- `includeContributions`: Boolean - adjust for deposits/withdrawals (TWR vs MWR)

Derek: The `interval` parameter is critical. For 1D view, we want hourly data points. For 1Y, daily is fine.

Stephanie: The contributions adjustment is tricky. True time-weighted return calculation requires knowing every cash flow. We have that data but it's expensive to compute on the fly.

Carlos: Can we pre-calculate and cache it?

Stephanie: Yeah, we run a nightly job that calculates TWR. But intraday we'd need to approximate.

Nina: For the benchmark comparison - can we support custom benchmarks? Some users want to compare against a 60/40 portfolio or their own custom blend.

Carlos: Let's keep it simple for v2 - predefined benchmarks only. Custom blends can be v2.1.

**Response structure:**
```json
{
  "period": "1M",
  "startDate": "2025-09-10",
  "endDate": "2025-10-10",
  "startValue": 118500.00,
  "endValue": 125432.87,
  "absoluteReturn": 6932.87,
  "percentReturn": 5.85,
  "annualizedReturn": 92.4,
  "contributions": 2000.00,
  "withdrawals": 0,
  "timeWeightedReturn": 4.21,
  "dataPoints": [
    {"date": "2025-09-10", "value": 118500.00},
    {"date": "2025-09-11", "value": 119200.00},
    // ... daily values
  ],
  "benchmark": {
    "symbol": "SPY",
    "name": "S&P 500 ETF",
    "percentReturn": 4.89,
    "dataPoints": [/* matching dates */]
  }
}
```

Raj: What's the max data points we'd return? ALL period could be years of data.

Carlos: Good catch. Let's cap at 365 data points. For longer periods, we aggregate to weekly or monthly.

---

### 3. Holdings Detail Endpoint

Carlos: We need a more flexible holdings endpoint. Current one doesn't support filtering or sorting well.

**Proposed:** `GET /v2/portfolios/{id}/holdings`

**Query Parameters:**
- `sort`: symbol, value, gainLoss, allocation (prefix with - for descending)
- `filter[assetClass]`: STOCK, ETF, MUTUAL_FUND, BOND, CASH, OTHER
- `filter[gainLoss]`: GAIN, LOSS, ALL
- `page[size]`: Default 50, max 200
- `page[cursor]`: For cursor-based pagination
- `include`: taxLots, fundamentals, analystRatings

Derek: Why cursor pagination instead of offset?

Carlos: Better performance with large portfolios. Offset pagination gets slow after page 10.

Stephanie: The `include` options worry me. Tax lots could be 50+ rows per holding. And analyst ratings requires calling a third-party API.

Carlos: Fair. Let's make those separate endpoints then:
- `GET /v2/holdings/{id}/tax-lots`
- `GET /v2/holdings/{id}/fundamentals`

Nina: Can we also get a "changes" view? Like, show me positions added or removed in the last 30 days.

Carlos: That's a good idea for the activity feed. Let's add it to the transactions endpoint scope.

---

### 4. Rebalancing Endpoints

Carlos: These are new for the rebalancing feature. Stephanie, want to walk through?

Stephanie: Sure. We need three endpoints:

**4a. Get Rebalancing Recommendation**
`GET /v2/portfolios/{id}/rebalance/recommendation`

Returns proposed trades to get back to target allocation. Response:
```json
{
  "status": "REBALANCE_RECOMMENDED",
  "currentDrift": 4.2,
  "thresholdDrift": 5.0,
  "proposedTrades": [
    {
      "action": "SELL",
      "securityId": "sec_vti",
      "symbol": "VTI",
      "quantity": 5.5,
      "estimatedProceeds": 1290.08,
      "reason": "Reduce US equity allocation from 45% to 40%"
    },
    {
      "action": "BUY",
      "securityId": "sec_bnd",
      "symbol": "BND",
      "quantity": 12.3,
      "estimatedCost": 1285.50,
      "reason": "Increase bond allocation from 15% to 20%"
    }
  ],
  "taxImpact": {
    "estimatedShortTermGains": 0,
    "estimatedLongTermGains": 145.23,
    "estimatedTaxLiability": 21.78
  },
  "projectedAllocation": {
    "stocks": 70.0,
    "bonds": 20.0,
    "cash": 5.0,
    "other": 5.0
  }
}
```

Raj: The tax impact calculation - is that accurate or estimated?

Stephanie: Estimated. We use FIFO and assume current tax rates. There's a disclaimer in the UI.

**4b. Submit Rebalancing Request**
`POST /v2/portfolios/{id}/rebalance`

Request body:
```json
{
  "trades": [/* same structure as recommendation, or modified */],
  "executionStrategy": "MARKET" | "LIMIT",
  "limitPriceBuffer": 0.5,
  "notifyOnComplete": true
}
```

Response includes a `rebalanceId` for tracking.

**4c. Get Rebalancing Status**
`GET /v2/portfolios/{id}/rebalance/{rebalanceId}`

Returns status of all trades (pending, submitted, filled, rejected, etc.)

Carlos: Should we support cancellation?

Stephanie: Yes - `DELETE /v2/portfolios/{id}/rebalance/{rebalanceId}` but only for trades not yet submitted.

---

### 5. Transactions Endpoint (Enhanced)

Carlos: Current transactions endpoint is basic. Let's enhance it.

**Proposed:** `GET /v2/portfolios/{id}/transactions`

**Query Parameters:**
- `startDate`, `endDate`: Date range (required, max 1 year span)
- `type`: BUY, SELL, DIVIDEND, INTEREST, FEE, TRANSFER, CONTRIBUTION, WITHDRAWAL
- `securityId`: Filter to specific holding
- `status`: PENDING, COMPLETED, CANCELLED, FAILED
- `sort`: date, amount (default: -date)
- `page[size]`, `page[cursor]`

Nina: Can we get a summary view too? Like monthly totals?

Carlos: Good idea. `?view=summary` could return:
```json
{
  "summary": {
    "totalBuys": 15234.00,
    "totalSells": 8500.00,
    "totalDividends": 342.15,
    "totalFees": 45.00,
    "netCashFlow": 7031.15
  },
  "byMonth": [
    {"month": "2025-10", "buys": 2000, "sells": 0, "dividends": 45.23},
    {"month": "2025-09", "buys": 5000, "sells": 1500, "dividends": 52.11}
  ]
}
```

---

## Authentication & Authorization

Raj: Let me outline the auth requirements:

1. **Authentication**: All endpoints require Bearer token (OAuth 2.0 JWT)
2. **Scopes needed**:
   - `portfolio:read` - Basic portfolio data, holdings, performance
   - `portfolio:write` - Rebalancing, trade submission
   - `portfolio:sensitive` - Cost basis, tax lots, tax impact
3. **Rate limits**:
   - Standard: 100 req/min per user
   - Burst: 20 req/sec
   - Dashboard composite: Counts as 1 request despite multiple data sources
4. **Field filtering**: Cost basis, tax lots hidden unless `portfolio:sensitive` scope

Carlos: The scope-based field filtering is new. How do we handle it in the response?

Raj: Two options:
1. Omit the fields entirely if no permission
2. Return null with a `_permissions` object explaining why

I prefer option 2 - it's clearer for API consumers.

Derek: What about service-to-service calls? The mobile BFF needs `portfolio:sensitive` but end users shouldn't.

Raj: BFF should use client credentials grant with elevated permissions, then filter appropriately before sending to mobile.

---

## Error Handling

Carlos: Let's standardize error responses.

**Standard error format:**
```json
{
  "error": {
    "code": "PORTFOLIO_NOT_FOUND",
    "message": "Portfolio with ID 'pf_xyz' not found or you don't have access",
    "status": 404,
    "timestamp": "2025-10-10T15:30:00Z",
    "requestId": "req_abc123",
    "details": {
      "portfolioId": "pf_xyz"
    },
    "documentation": "https://api.example.com/docs/errors#PORTFOLIO_NOT_FOUND"
  }
}
```

**Error codes we need:**
| Code | HTTP Status | Description |
|------|-------------|-------------|
| PORTFOLIO_NOT_FOUND | 404 | Portfolio doesn't exist or no access |
| INSUFFICIENT_PERMISSIONS | 403 | Missing required scope |
| INVALID_DATE_RANGE | 400 | Date range invalid or too large |
| MARKET_DATA_UNAVAILABLE | 503 | Price data temporarily unavailable |
| REBALANCE_IN_PROGRESS | 409 | Can't start new rebalance while one is pending |
| TRADE_RESTRICTED | 403 | Security has trading restrictions |
| INSUFFICIENT_FUNDS | 400 | Not enough cash for proposed trades |
| RATE_LIMITED | 429 | Too many requests |

Stephanie: What about partial failures? Like, 3 of 5 trades succeed?

Carlos: For rebalancing, we should use atomic transactions - all or nothing. If one trade fails validation, reject the whole batch.

Raj: Agreed. Partial execution is a nightmare for users and compliance.

---

## Versioning & Deprecation

Carlos: We're calling this v2. How do we handle the v1 to v2 transition?

**Proposal:**
- v1 endpoints remain available for 12 months after v2 GA
- v1 endpoints return `Deprecation` and `Sunset` headers
- API gateway logs v1 usage for migration tracking
- Breaking changes only in major versions (v3, v4)

Nina: Can we run v1 and v2 in parallel during the transition?

Carlos: Yes, but they use different URL prefixes. `/v1/portfolios/...` vs `/v2/portfolios/...`

Derek: What about feature flags? Can we gradually roll out v2 endpoints?

Carlos: Good idea. We'll use LaunchDarkly. First to internal users, then beta, then GA.

---

## Performance Requirements

Carlos: Let's set SLAs for the new endpoints:

| Endpoint | P50 Latency | P99 Latency | Availability |
|----------|-------------|-------------|--------------|
| Dashboard composite | 150ms | 500ms | 99.9% |
| Performance history | 100ms | 300ms | 99.9% |
| Holdings list | 75ms | 200ms | 99.9% |
| Rebalance recommendation | 300ms | 1000ms | 99.5% |
| Rebalance submit | 200ms | 500ms | 99.9% |

Stephanie: The rebalance recommendation is complex. 300ms P50 is aggressive for large portfolios.

Carlos: What's "large"?

Stephanie: 200+ holdings. We have some institutional accounts with 500+.

Carlos: Let's add a note - these SLAs are for portfolios under 200 holdings. Larger portfolios may see 2-3x latency.

---

## Open Questions

1. **Webhook support**: Should we offer webhooks for portfolio changes? (trades completed, dividends received)
2. **GraphQL**: Some teams want GraphQL. Worth building a GraphQL layer over REST?
3. **Bulk operations**: Support for getting multiple portfolios in one call? (advisor dashboards)
4. **Streaming**: WebSocket for real-time price updates in dashboard?

---

## Next Steps

| Action | Owner | Due |
|--------|-------|-----|
| Finalize OpenAPI spec for dashboard endpoint | Carlos | Oct 15 |
| Performance prototype for composite query | Stephanie | Oct 17 |
| Security review of scope model | Raj | Oct 14 |
| Mobile wireframes aligned to new API | Derek | Oct 18 |
| Error code documentation | Amy | Oct 16 |
| Capacity planning for new endpoints | Carlos | Oct 21 |

**Next sync:** Tuesday Oct 15 @ 2pm - Review OpenAPI spec draft

---

## Notes from Slack after meeting

Derek: Can we also add a `lastViewedAt` timestamp to know when user last checked their portfolio? Useful for notification logic.

Nina: +1 on GraphQL eventually. Would make our frontend code so much cleaner.

Raj: FYI - the security review might surface additional requirements. PCI compliance if we ever show full account numbers.
