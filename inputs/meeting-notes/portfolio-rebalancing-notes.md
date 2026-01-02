# Portfolio Rebalancing Feature - Discovery Meeting
**Date:** Tuesday, October 15, 2025 @ 2:00 PM EST
**Location:** Conference Room B / Zoom (hybrid)
**Attendees:**
- Sarah Chen (Product Manager) - facilitating
- Mike Rodriguez (Engineering Lead)
- Lisa Patel (Business Analyst)
- James Wu (Compliance Officer) - joined at 2:15
- David Kim (UX Designer) - left at 2:45 for another meeting
- Rachel Foster (Client Success) - called in from Denver

**Recording:** Yes, saved to SharePoint > Product > Recordings

---

## Context / Why We're Here

Sarah: OK everyone, thanks for joining. As you know from the email, we've been getting a LOT of requests for automated rebalancing. I pulled the data - 47 support tickets in Q3 alone, plus it came up in 8 of our 12 enterprise client QBRs. Fidelity and Schwab both have this, so we're behind.

Rachel: Can confirm - I had three calls last week where clients specifically asked when we're adding this. Meridian Wealth said they're evaluating competitors partly because of this gap.

Mike: Before we dive in - are we talking about automatic rebalancing that just happens, or more like "smart suggestions" that users approve?

Sarah: Good question. Let's figure that out today. My instinct is we need both - maybe a toggle? Enterprise clients definitely want full automation, but retail might want more control.

---

## Current State Discussion

Lisa: So right now, if a client wants to rebalance, what do they do?

Mike: Basically nothing in-app. They either call their advisor or manually calculate and place individual trades. It's painful.

Rachel: Yeah, I've walked clients through it. They have to export to Excel, compare to their target allocation, figure out what to buy/sell, then come back and place like 15 separate orders. One client told me it took him 3 hours.

David: Do we have data on how many users even HAVE target allocations set up?

Sarah: Good point - Lisa, can you pull that?

Lisa: *checking* Roughly 34% of accounts have target allocations defined in their profile. But that includes ones set during onboarding that might be stale.

---

## Core Requirements Discussion

### Triggering Rebalancing

Sarah: OK so first big question - when does rebalancing happen?

Mike: Industry standard seems to be either calendar-based (quarterly, annually) or threshold-based (when drift exceeds X%).

James (joining): Sorry I'm late - compliance review ran over. What did I miss?

Sarah: Just getting started. We're talking triggers - calendar vs threshold.

James: From compliance perspective, we need to be careful with automatic execution. FINRA has rules about suitability - we can't just auto-trade without considering the client's current situation.

Rachel: Our enterprise clients at the $50M+ AUM level definitely want calendar-based. They do quarterly rebalancing as part of their investment policy statements.

Lisa: What about combining them? Like, check quarterly OR when drift exceeds 5%?

Mike: 5% on the whole portfolio or 5% on individual asset classes?

Lisa: Hmm, I was thinking portfolio level but asset class makes more sense...

Sarah: Let's say both? Portfolio-level threshold of 10% OR any single asset class drifts more than 5% from target. Plus optional calendar schedule.

David: That's going to be confusing in the UI. We need to think about how to explain this to users who aren't financial experts.

**ACTION: David to sketch 2-3 UI concepts for threshold configuration by EOW**

---

### Tax-Loss Harvesting Integration

Mike: OK here's a big question - do we integrate with tax-loss harvesting or keep them separate?

Sarah: What's the complexity difference?

Mike: Huge. If we're just rebalancing, we calculate trades to get back to target. If we're also considering taxes, we need to look at cost basis, holding periods, wash sale rules... it's like 3x the complexity.

James: We also need to consider whether the account is taxable vs tax-advantaged. No point optimizing for taxes in an IRA.

Lisa: Current system already tracks cost basis at the lot level, right?

Mike: Yes, but the tax-loss harvesting logic is in a separate service that Marcus built two years ago. It's... not well documented. And Marcus left in June.

Rachel: Clients WILL ask about this. "Why did you sell my Apple shares at a loss right before it went up?" We need to be able to explain.

Sarah: Let's descope tax optimization for v1. Just basic rebalancing. We can add tax-smart features in v2.

Mike: Agreed. But we should at least show users the estimated tax impact before they approve trades.

**DECISION: V1 will NOT include tax-loss harvesting but WILL show estimated capital gains/losses for proposed trades**

---

### The Approval Workflow

David: So walk me through the user flow. I get an alert saying my portfolio needs rebalancing - then what?

Sarah: I'm thinking: notification (email + in-app) → user clicks through → sees current vs target allocation → sees proposed trades → can approve as-is, modify, or dismiss.

Mike: What does "modify" mean exactly? Can they change quantities? Remove certain trades?

Sarah: Both ideally?

James: If they modify, we need to re-validate. They might create a situation where the resulting allocation is actually further from target.

Lisa: Also - what if they approve but then the market moves before we execute? A market order at 3pm might fill at a very different price than what we showed them at 9am.

Mike: That's why we should use limit orders by default. Set the limit at current price + small buffer.

Rachel: What buffer? Our retail clients will complain if orders don't fill.

Mike: Maybe 0.5% for liquid ETFs, 1% for individual stocks? We'd need to test.

**ACTION: Mike to propose order execution strategy doc by next Tuesday**

---

### Account Restrictions

James: I need to bring up restricted securities. We have clients who can't trade certain stocks due to employment restrictions - like, they work at Google so they can't trade GOOGL.

Lisa: How many accounts have restrictions?

James: About 12% have at least one restricted security.

Sarah: So what happens if rebalancing wants to sell a restricted security?

James: We either skip that trade and rebalance around it, or we flag for manual review.

Mike: We already have the restriction data in the compliance database. It's the `account_trading_restrictions` table.

James: We should also consider concentration limits. Some accounts have rules like "no single position over 15% of portfolio."

Sarah: That sounds like a v2 thing?

James: No, that's actually critical. If we rebalance and accidentally create a concentration violation, that's a regulatory issue.

**DECISION: V1 must respect trading restrictions and concentration limits**

---

### Fractional Shares

David: Quick question - do we support fractional shares?

Mike: For ETFs yes, for individual stocks no. It depends on the security type.

Lisa: So if someone's target says 5% in VTI and that works out to 3.7 shares, we can do that?

Mike: For VTI yes. For BRK.A, no - we'd round to nearest whole share.

Rachel: Rounding up or down?

Mike: Whichever gets closer to target allocation. Actually this is more complex - we need to make sure the total still adds up. If we round everything up we might not have enough cash.

**ACTION: Lisa to document fractional share rules and rounding logic**

---

### Notifications & Reporting

Rachel: Can we talk about what communications clients receive?

Sarah: Sure - I'm thinking:
1. Alert when rebalancing is recommended (email + push)
2. Confirmation when trades are submitted
3. Summary when trades complete

Rachel: We need to be careful about frequency. If someone's portfolio drifts in and out of threshold, we don't want to spam them daily.

Lisa: Maybe a cooldown? Like, don't alert again within 7 days of dismissing?

James: From compliance perspective, we need to keep records of all rebalancing recommendations and user decisions for 7 years.

Mike: We'll log everything to the audit service. Same one we use for trade confirmations.

**ACTION: Sarah to draft notification copy and frequency rules**

---

## Technical Considerations

Mike: Few technical notes while I'm thinking about it:

1. **Performance**: Calculating optimal trades for a large portfolio (500+ positions) could be slow. We might need to pre-calculate and cache recommendations overnight.

2. **Market hours**: We should probably only propose trades during market hours, or at least warn users that orders placed after hours will queue.

3. **Cash buffer**: Need to maintain minimum cash for fees and potential margin calls. Default 2% cash buffer?

4. **Batch execution**: If we're executing 50 trades, do we submit all at once or sequence them? Risk of partial fills if market moves.

Lisa: On the cash buffer - that should be configurable per account, right? Some clients want more liquidity.

Mike: Sure, we can add that to account settings.

---

## Competitive Analysis Notes

Lisa: I did some research on what competitors offer:

**Wealthfront**: Fully automated, daily drift check, 5% threshold. Uses tax-loss harvesting. No user approval needed.

**Betterment**: Similar to Wealthfront. Automatic with annual or threshold trigger.

**Schwab Intelligent Portfolios**: Automatic rebalancing, no trading commissions.

**Fidelity**: Manual rebalancing tool OR automatic for managed accounts. Nice visualization.

**Vanguard**: Quarterly rebalancing reminders, user must approve.

Sarah: So we're somewhere between Vanguard (manual) and Wealthfront (fully automatic).

Mike: The Fidelity visualization is nice - shows current vs target as a bar chart with the rebalancing trades overlaid.

David: *takes note* Good reference. I'll look at that.

---

## Open Questions / Parking Lot

1. What's the minimum account value for rebalancing? (small accounts might have $2 trades that aren't worth it)
2. How do we handle accounts with pending transfers or recent large deposits?
3. Should advisors be able to trigger rebalancing for their clients? Or just suggest?
4. Multi-account rebalancing - can we optimize across taxable + IRA together?
5. What happens if the user's target allocation is no longer suitable? (they haven't updated it in 5 years)

---

## Rough Timeline Discussion

Sarah: I want this for Q1 launch. That gives us about 12 weeks.

Mike: That's tight. Core rebalancing engine, UI, notifications, testing... I'd estimate:
- 3 weeks: Design + technical planning
- 4 weeks: Core engine development
- 2 weeks: UI implementation
- 2 weeks: Integration + QA
- 1 week: Beta with select clients

Sarah: That's 12 weeks exactly with no buffer. Can we cut scope?

Mike: We could launch with threshold-only (no calendar) and single-account only. Add calendar and multi-account in v1.1.

**DECISION: V1 scope = threshold-based rebalancing, single account, with approval workflow. Calendar-based is v1.1.**

---

## Next Steps

| Action | Owner | Due |
|--------|-------|-----|
| UI concepts for threshold config | David | Oct 18 |
| Order execution strategy doc | Mike | Oct 22 |
| Document fractional share rules | Lisa | Oct 18 |
| Draft notification copy | Sarah | Oct 22 |
| Pull data on accounts with targets | Lisa | Oct 16 |
| Compliance requirements summary | James | Oct 21 |

**Next meeting:** Thursday Oct 24 @ 2pm - Review designs and tech approach

---

## Side Conversations / Notes

- Mike mentioned the current portfolio service is running on older infrastructure, might need optimization
- Rachel said Meridian Wealth specifically asked about rebalancing across household accounts (multiple family members) - noted for future
- James reminded everyone that marketing materials for this feature need compliance review before publishing
- Someone's phone kept unmuting with background noise - please remember to mute!
