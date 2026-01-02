# Documentation Transformation Example

## BEFORE: Raw Meeting Notes

```
talked about the dashboard today
- needs to show portfolio value
- maybe a chart?
- sarah wants to see gains/losses
- mike said api already has the data
- need to figure out refresh rate
- mobile too or just web?
```

---

## AFTER: Requirements Document

# Dashboard Feature Requirements

**Version:** 1.0
**Author:** [Name]
**Date:** October 2025
**Status:** Draft

---

## 1. Overview

### 1.1 Purpose
Provide users with an at-a-glance view of their portfolio performance, including current value, gains/losses, and historical trends. This feature addresses user feedback requesting easier access to key portfolio metrics.

### 1.2 Scope
**In Scope:**
- Portfolio value display with real-time updates
- Gain/loss visualization (absolute and percentage)
- Historical performance chart
- Web application implementation

**Out of Scope:**
- Mobile application (Phase 2)
- Customizable dashboard layouts
- Third-party widget integrations

---

## 2. User Stories

### US-001: View Portfolio Value
**As a** portfolio owner
**I want** to see my current portfolio value on the dashboard
**So that** I can quickly understand my financial position

**Acceptance Criteria:**
- [ ] Dashboard displays total portfolio value prominently
- [ ] Value updates within 15 seconds of market changes
- [ ] Currency formatting matches user preferences
- [ ] Loading state shown during data fetch

**Priority:** High

### US-002: View Gains and Losses
**As a** portfolio owner
**I want** to see my gains and losses on the dashboard
**So that** I can track my investment performance

**Acceptance Criteria:**
- [ ] Shows absolute gain/loss in currency
- [ ] Shows percentage gain/loss
- [ ] Green color for gains, red for losses
- [ ] Timeframe selector (day, week, month, year, all-time)

**Priority:** High

### US-003: View Performance Chart
**As a** portfolio owner
**I want** to see a historical performance chart
**So that** I can visualize trends over time

**Acceptance Criteria:**
- [ ] Line chart showing portfolio value over time
- [ ] Selectable timeframes (1W, 1M, 3M, 6M, 1Y, ALL)
- [ ] Benchmark comparison option (S&P 500)
- [ ] Hover to see specific date values

**Priority:** Medium

---

## 3. Technical Notes

### 3.1 Data Source
- Existing Portfolio API provides required data
- Endpoint: GET /portfolios/{id}/performance
- Real-time updates via WebSocket connection

### 3.2 Refresh Rate
- Initial load: On page load
- Background refresh: Every 15 seconds during market hours
- Manual refresh: User-triggered

---

## 4. Open Questions

1. Should we cache performance data client-side?
2. What's the fallback if WebSocket connection fails?
3. Mobile timeline - when should Phase 2 begin?

---

## Key Improvements Made

| Aspect | Before | After |
|--------|--------|-------|
| **Structure** | Unorganized bullets | Clear sections with headers |
| **Specificity** | "maybe a chart?" | Detailed acceptance criteria |
| **Completeness** | Missing context | Scope, tech notes, questions |
| **Actionability** | Can't estimate | Team can plan and build |
| **Decisions** | "mobile too?" | Explicit scope decision |

---

## Transformation Tips

1. **Extract implicit requirements** - "sarah wants gains/losses" becomes a full user story
2. **Add structure** - Organize chaos into standard sections
3. **Make decisions explicit** - Document what's in/out of scope
4. **Quantify where possible** - "15 seconds" vs "real-time"
5. **Capture unknowns** - Open questions section for unresolved items
