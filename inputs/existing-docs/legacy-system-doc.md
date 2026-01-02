# Trade Settlement System (TRDSETTL) Documentation

*Last updated: November 2003 by D.K. Briggs (margin logic update)*
*Originally written: March 1994 by R. Johnson & M. Kowalski*

---

## Overview

TRDSETTL is the mainframe program that calculates settlement amounts and fees for trades. It runs on the IBM z/OS system in the overnight batch cycle.

**Important:** This documentation may be incomplete. The original authors (Johnson and Kowalski) left in 1998 and 2001 respectively. For questions, ask around - someone on the team might know. *(Note: DKB who did the 2003 update also left in 2015)*

---

## What It Does

The program calculates fees for trades. It reads from the account master file and writes to the fee history file.

Main functions:
- Validates trades
- Calculates commissions
- Calculates other fees (SEC, TAF, etc.)
- Figures out settlement date
- Does something with margin accounts (added later)

---

## Files Used

**ACCTMSTR** - Account master file (VSAM)
- Has account information
- See copybook for record layout

**FEEHIST** - Fee history output file
- Audit trail of fee calculations
- Format is in the FEEAUDIT copybook (somewhere)

There might be other files? Check the JCL.

---

## Fee Calculations

The program calculates several fees. Here's what I remember:

### Commission
- Base rate is 0.75% (I think?)
- There's a minimum of $4.95 and maximum of $29.95
- Different account tiers get discounts
- Institutional accounts get bigger discounts

### SEC Fee
- Only on sells
- Rate is like $27.80 per million or something
- Check the SEC website for current rate

### TAF Fee
- Also only on sells
- Per share fee, there's a cap
- Can't remember the exact numbers

### Other Fees
- Exchange fees vary
- Something about foreign securities
- Markup for principal trades

**Note:** The fee rates in the program might be outdated. Rates were last updated in 2018 maybe?

---

## Account Types

The system handles different account types:
- CA = Cash account
- MG = Margin account
- IR = IRA
- RO = Roth IRA
- 4K = 401(k)
- IN = Institutional

Each type might have different rules. The margin stuff was added in 2003.

---

## Tier Discounts

There's a tiering system for commission discounts:

| Tier | Discount |
|------|----------|
| 1 | None |
| 2 | 10% |
| 3 | 20% |
| 4 | 35% |
| 5 | 50% |
| 6 | 75% (institutional) |

Or something like that. Check the code.

---

## Settlement Dates

Settlement days depend on security type:
- Stocks are T+2 (wait, they changed to T+1 in 2024)
- Options are T+1
- Mutual funds vary
- Bonds are T+2

The program calls DATEUTIL to skip weekends and holidays.

**UPDATE 2024:** Someone updated the code for T+1 but I don't know if the documentation matches.

---

## Error Codes

When something fails, it sets return codes:

| Code | Meaning |
|------|---------|
| 0 | OK |
| 10 | Account not found |
| 20 | Account restricted |
| 30-31 | Funds/margin issue |
| 40 | Security problem |
| 50 | Bad quantity |
| 60 | Market closed |
| 99 | System error |

There are also error codes starting with E (like E001, E010, etc.) in the messages but I don't have a full list.

---

## Known Issues

1. **Foreign securities bug** - There's a ticket (#4521) from 2007 about foreign securities not being handled right. Still open I think.

2. **Options level check** - There's a TODO in the code about checking options trading levels. Never implemented.

3. **Fee rates hardcoded** - The fee rates are hardcoded in working storage. They should come from a table.

4. **Memory issue?** - The program sometimes has issues with large accounts. Might be related to working storage size.

5. **That weird thing with wash sales** - There are some comments about wash sale rules but I don't think it's actually implemented.

---

## How to Run

The program runs in the nightly batch. JCL is in PROD.JCLLIB.

```
//TRDSETTL JOB ...
//STEP1    EXEC PGM=TRDSETTL
//ACCTMSTR DD  DSN=PROD.ACCTMSTR,DISP=SHR
//FEEHIST  DD  DSN=...
```

Check with operations for the actual JCL. This example might be outdated.

---

## Dependencies

- DATEUTIL program (for date calculations)
- ACCTMSTR VSAM file
- Various copybooks (ACCTMSTR, FEETABLE, TAXRATES, FEEAUDIT)

The copybooks should be in the copy library. Ask the mainframe team.

---

## Code Structure

Main paragraphs:
- 0000-MAIN-PROCESS - Main control
- 1000-INITIALIZE - Opens files
- 2000-VALIDATE-TRADE - Checks if trade is valid
- 3000-CALC-FEES - Calculates all the fees
- 4000-CALC-SETTLEMENT - Settlement date stuff
- 5000-APPLY-MARGIN-RULES - Margin account logic
- 9000-FINALIZE - Closes files, writes audit

The 3000 section is the most complex. It has sub-paragraphs for each fee type.

---

## Compliance Note

The fee calculation logic (section 3000-3999) is compliance-sensitive. There's an old memo (94-0312) about getting approval before modifying. Not sure if that still applies.

Also, section 4000-4999 has a similar warning in the code. Something about regulatory requirements.

---

## Change History

| Date | Who | What |
|------|-----|------|
| 1994-03 | Johnson/Kowalski | Initial program |
| 2003-11 | DKB | Added margin logic |
| 2011-06 | ??? | Tax lot fix |
| 2019-02 | Contractor | Date fix |
| 2024-05 | ??? | T+1 update |

---

## Related Systems

- Account Master maintenance (don't know program name)
- Portfolio system
- Trade entry system
- Reporting system

Each has their own documentation (quality varies).

---

## Contact

~~For questions contact:~~
- ~~R. Johnson (original author)~~ - Left 1998
- ~~M. Kowalski (original author)~~ - Left 2001
- ~~D.K. Briggs (margin update)~~ - Left 2015
- Mainframe team (general questions)
- Compliance (fee/regulatory questions)

Or post in #legacy-systems channel, someone might know.

---

## TODO

- [ ] Update fee rates to current values
- [ ] Document all error codes properly
- [ ] Get proper system diagrams
- [ ] Find and document all copybook layouts
- [ ] Figure out what that foreign securities code actually does
- [ ] Confirm settlement date logic is correct for T+1
- [ ] Find memo 94-0312 to understand compliance requirements

---

*If this documentation is wrong, please fix it. Or at least add a comment saying what's wrong.*

*Best source of truth is probably the code itself: TRDSETTL in PROD.SRCLIB*
