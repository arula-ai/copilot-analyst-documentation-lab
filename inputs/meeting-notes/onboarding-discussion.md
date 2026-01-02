# Digital Account Opening Redesign - Whiteboard Session
**Date:** Friday, October 12, 2025 @ 10:00 AM EST
**Location:** Innovation Lab (Building 2, Floor 3)
**Attendees:**
- Product: Anika Sharma (PM), Tom Bradley (UX Lead)
- Engineering: Priya Mehta (Backend Lead), Kevin O'Brien (Frontend)
- Operations: Maria Santos (Ops Manager), Greg Thompson (KYC Team Lead)
- Compliance: Jennifer Walsh (Deputy CCO)
- Guest: Consultant from Accenture - Mark Stevens (digital transformation)

**Note-taker:** Anika
**Whiteboard photos:** Uploaded to Confluence > Projects > Account Opening Redesign

---

## The Problem We're Solving

Anika: Alright everyone, thanks for blocking Friday morning for this. Let me set context. Our digital account opening experience is... not good. Here are the numbers:

**Current Funnel (last 90 days):**
- Started application: 14,382
- Completed application: 8,291 (57.6%)
- Passed verification: 6,104 (73.6% of completed)
- Funded account: 4,856 (79.6% of verified)
- **Net conversion: 33.8%**

Maria: And for context, industry benchmark is around 50-60% for digital-first brokerages.

Mark (consultant): I've seen some fintechs hit 70%+ with optimized flows. Robinhood was famous for their 3-minute signup.

Tom: Our average completion time right now is 23 minutes. And that's for people who finish.

Kevin: Plus another 40% get stuck in the identity verification step and just... leave. We see them start, fail the first attempt, and never come back.

---

## Current Flow Analysis

Tom: *drawing on whiteboard* Let me walk through what we have today:

```
1. Landing Page → Create Account (email/password)
2. Personal Info Screen 1 (name, DOB, SSN, address)
3. Personal Info Screen 2 (citizenship, tax status)
4. Employment Information
5. Financial Profile (income, net worth, investment experience)
6. Risk Tolerance Questionnaire (8 questions)
7. Account Type Selection
8. Identity Verification (document upload)
9. ID Selfie Match
10. Terms & Disclosures (3 separate acknowledgments)
11. Signature
12. Account Created → Funding Flow
```

Priya: That's 12 steps before they even get to funding. And the backend does like 15 different API calls throughout.

Greg: The identity verification is actually 3 sub-steps internally - document OCR, database checks, and the facial match. Each can fail independently.

Jennifer: And we have regulatory requirements for almost all of these. We can't just remove the risk questionnaire - that's FINRA Rule 2111 suitability.

---

## Where People Drop Off

Maria: *pulling up analytics* Here's where we lose them:

| Step | Drop-off Rate | Notes |
|------|--------------|-------|
| Email/password | 8% | Mostly bots and duplicates |
| Personal info | 12% | SSN entry is the killer |
| Employment | 6% | Pretty smooth |
| Financial profile | 9% | People don't know their net worth |
| Risk questionnaire | 11% | Too long, feels like a test |
| ID verification | 22% | THIS IS THE PROBLEM |
| Selfie match | 8% | Technical issues |
| Disclosures | 4% | Almost done, they push through |

Kevin: So identity verification is where we hemorrhage users. 22% drop-off is brutal.

Greg: A lot of those are legitimate failures though - blurry photos, expired IDs, mismatched names. We catch about 3% attempted fraud at this step.

Tom: But there's a UX issue too. The error messages are terrible. "Verification failed" doesn't tell them what to do. And we only give them 2 attempts before locking them out for 24 hours.

---

## Brainstorming Solutions

### Idea 1: Progressive Disclosure / Staged Onboarding

Mark: What if you don't collect everything upfront? Let them create a limited account first, then unlock features as they provide more info.

Anika: Interesting. Like, they can view markets and research but can't trade until fully verified?

Jennifer: We'd need to be careful. If they can see account numbers or any PII, that's still a full account from a regulatory standpoint.

Priya: We actually have a "prospect" status in the system already - it's used for demo accounts. We could build on that.

Tom: I like this. The psychological win of "account created" might keep them engaged.

**SKETCH: Three-tier onboarding**
1. Tier 1 (email only): Browse, watchlists, research
2. Tier 2 (+ identity): Cash deposits up to $10K
3. Tier 3 (+ full profile): Full trading, margin, options

Greg: The $10K limit is actually from AML requirements. Over that threshold we need enhanced due diligence anyway.

---

### Idea 2: Alternative Identity Verification

Kevin: Can we use something other than document upload? The camera issues are killing us.

Mark: Some banks use database verification - they match your info against credit bureaus and public records. Higher pass rate, no photos needed.

Priya: We looked at this last year. The vendor we talked to was Socure. Their "database first" approach has like 85% auto-verification rate.

Greg: We'd still need document backup for the 15% that fail database verification. And some states require document verification for certain account types.

Jennifer: Whatever we do, we need to maintain our CIP (Customer Identification Program) compliance. BSA requires "reasonable belief" of identity.

Anika: What about letting them choose? "Verify instantly with your info" vs "Upload your ID"?

Tom: *drawing* I like that. Make database the default, document as fallback.

**ACTION: Priya to get updated pricing from Socure and Jumio**

---

### Idea 3: Pre-fill from Linked Bank

Maria: Plaid has a product where they can pull basic info from your bank connection. Name, address, even last-4 SSN matches.

Kevin: We already use Plaid for bank linking in the funding step. Could we move that earlier?

Anika: "Link your bank to pre-fill your application" - that's a good value prop.

Priya: Risk is they might not want to connect their bank that early. Trust issue.

Mark: You'd be surprised. The data shows users trust bank connections more than typing in SSN manually. It feels more secure.

Jennifer: We'd still need them to confirm/edit the pre-filled data. Can't just assume it's accurate.

**CONSENSUS: Worth prototyping - move bank linking to step 2**

---

### Idea 4: Risk Questionnaire Redesign

Tom: The current risk questionnaire is 8 questions and feels like an exam. Can we simplify?

Jennifer: The questions themselves come from our suitability model. We can reword them but the substance needs to stay.

Kevin: What if we made it visual? Instead of "What percentage loss would cause you to sell" with 5 radio buttons, show a graph.

Maria: Wealthfront does this really well. They show you a simulation.

Greg: From a compliance perspective, we need to capture and retain the actual selections. But the UI can be whatever.

Tom: *sketching* What about a slider interface? "Drag to show your risk comfort level" and we map that to the technical categories on the backend.

Jennifer: As long as the output maps to our existing risk scoring model, I think that works. Let me review with legal.

**ACTION: Tom to prototype interactive risk questionnaire**

---

### Idea 5: Fix the Error Handling

Kevin: This is low-hanging fruit. Our error messages suck.

**Current:** "Identity verification failed. Please try again."

**Better:** "We couldn't read your driver's license. Tips:
- Make sure all 4 corners are visible
- Use good lighting
- Avoid glare on the hologram
[Try again] [Use different document] [Get help]"

Greg: We actually know WHY verification fails from the vendor response. We just don't surface it.

Priya: This is definitely fixable. The vendor returns like 20 different failure codes. We could map each to helpful messaging.

Maria: Can we also add live chat at this step? Right now if they fail twice, they're stuck waiting for email support.

**ACTION: Kevin to create error message mapping document**

---

## Mobile-Specific Issues

Tom: 68% of our applications start on mobile. But our mobile completion rate is way lower than desktop.

Kevin: The document capture is the main issue. Mobile browsers have weird camera permissions, and people try to upload photos that are too big.

Priya: We should probably just redirect to our mobile app for the ID capture step. The app camera experience is way better.

Anika: But then we're asking them to download an app mid-flow. That's another drop-off point.

Mark: Progressive web app approach? Request camera permissions once at the start, use native capture.

Kevin: We've been meaning to upgrade our camera library. The current one is 3 years old.

**ACTION: Kevin to evaluate camera SDK options (Onfido, Jumio, in-house)**

---

## Funding Flow Optimization

Maria: Once they're verified, funding is actually pretty good, but there's room to improve.

**Current funding options:**
1. Link bank account (ACH) - 2-3 business days
2. Wire transfer - same day but requires leaving our platform
3. Account transfer (ACAT) - 5-7 business days

Anika: Any way to speed up ACH?

Priya: We could enable instant deposits like Robinhood - let them trade immediately while ACH settles, up to a limit.

Jennifer: That's essentially extending them credit. Requires different regulatory treatment.

Maria: What if we just set expectations better? Right now after linking, we say "funds will arrive in 2-3 days." People think something's wrong.

Greg: We could show a progress tracker. "Your deposit is processing. Day 1 of 2."

**NICE-TO-HAVE: Add funding progress tracker and day-by-day status**

---

## The "Happy Path" Vision

Tom: Let me draw what the optimized flow could look like:

```
1. Email/Password → Create prospect account
   [CELEBRATION: "Welcome! You're in."]

2. Link Bank (Plaid) → Pre-fill personal info
   [Show: "We found your info - please confirm"]

3. Employment + Financial (1 combined screen)

4. Risk Quiz (visual/interactive, 3 min)

5. Account type recommendation
   [Based on their profile]

6. Identity Verification
   - Database match (instant) OR
   - Document upload (fallback)

7. E-sign disclosures (combined into 1)
   [CELEBRATION: "Account approved!"]

8. Funding
   - Instant deposit if eligible, or
   - ACH with progress tracker

TOTAL SCREENS: 8 (down from 12)
TARGET TIME: 8 minutes (down from 23)
```

Anika: I love this. Can we hit 50% conversion with this?

Mark: Based on similar redesigns I've seen, you could hit 55-60% if the execution is clean.

---

## Technical Constraints & Dependencies

Priya: Few things engineering needs to flag:

1. **Legacy SSO system**: Current auth is tied to the old Oracle system. Moving to progressive enrollment means reworking session management.

2. **Vendor contracts**: We're locked into Jumio until March 2026. Adding Socure means running two vendors.

3. **Database changes**: "Prospect" accounts need a new status in the accounts table. Has downstream impacts on reporting.

4. **Mobile app updates**: If we're redirecting to app for camera, we need App Store approval cycles built in.

Kevin: Also, the frontend is React 16. We'd want to upgrade to 18 for the new camera APIs.

Anika: What's the minimum we could ship by end of year?

Priya: Error message improvements and the combined screens - that's doable. Bank pre-fill and database verification would be Q1.

---

## Compliance Concerns

Jennifer: I need to raise a few things:

1. **Fair lending**: If we're using database verification, we need to make sure it doesn't have disparate impact. Credit bureau data can be biased.

2. **OFAC/Sanctions**: Currently checked at document verification. If we defer that, we need to add checks earlier.

3. **State requirements**: Some states (looking at you, California) have additional privacy disclosures that can't be combined.

4. **Record retention**: All the new UX flows need to be logged with timestamps for audit trail.

Anika: Can you send me the state-by-state requirements? We might need state-specific flows.

Jennifer: I'll put together a matrix. Probably 4-5 states that need special handling.

**ACTION: Jennifer to provide state compliance matrix by Oct 18**

---

## Success Metrics

Anika: Let's define what success looks like:

| Metric | Current | Target (90 days) | Stretch |
|--------|---------|------------------|---------|
| Completion rate | 33.8% | 45% | 55% |
| Time to complete | 23 min | 12 min | 8 min |
| ID verification pass rate | 73.6% | 85% | 90% |
| Funding rate | 79.6% | 85% | 90% |
| Support tickets (onboarding) | 342/week | 200/week | 100/week |

Maria: We should also track abandon points. Right now we only know WHERE they drop, not WHY.

Mark: Exit surveys are usually low response, but worth having. "What stopped you today?"

---

## Prioritized Next Steps

**Phase 1 (MVP - End of Nov):**
- [ ] Fix error messages with helpful guidance
- [ ] Combine screens (employment + financial, disclosures)
- [ ] Add mobile camera improvements
- [ ] A/B test visual risk questionnaire

**Phase 2 (Q1 2026):**
- [ ] Database-first identity verification
- [ ] Bank linking pre-fill
- [ ] Progressive/tiered enrollment
- [ ] Instant deposits

**Phase 3 (Q2 2026):**
- [ ] Full mobile app integration
- [ ] State-specific optimizations
- [ ] Multi-language support

---

## Parking Lot / Future Ideas

- Joint account onboarding (currently requires paper forms)
- Entity accounts (LLC, Trust) - whole different flow needed
- International clients - working with UK/EU subsidiaries
- Biometric login option after onboarding
- Referral program integration (give $50, get $50)
- Advisor-assisted onboarding mode

---

## Action Items Summary

| Action | Owner | Due |
|--------|-------|-----|
| Get Socure/Jumio pricing comparison | Priya | Oct 16 |
| Prototype interactive risk questionnaire | Tom | Oct 23 |
| Create error message mapping document | Kevin | Oct 18 |
| Evaluate camera SDK options | Kevin | Oct 23 |
| State compliance matrix | Jennifer | Oct 18 |
| Draft phased project plan | Anika | Oct 21 |
| ROI analysis for exec presentation | Maria | Oct 21 |

**Next meeting:** Monday Oct 21 @ 2pm - Review prototypes and project plan

---

## Post-Meeting Notes

Tom sent Figma links to everyone for async feedback on current state flows.

Maria mentioned that call center is already overwhelmed - any changes need CSR training built in.

Greg's team is doing a fraud review next week that might impact requirements - stay tuned.

Mark will send his Accenture deck on industry benchmarks and best practices.
