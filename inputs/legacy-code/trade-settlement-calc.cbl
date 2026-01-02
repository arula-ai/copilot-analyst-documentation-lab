      ******************************************************************
      * PROGRAM:    TRDSETTL
      * AUTHOR:     R. JOHNSON / M. KOWALSKI
      * DATE:       03/15/1994
      * MODIFIED:   11/22/2003 - ADDED MARGIN ACCOUNT LOGIC (DKB)
      *             06/08/2011 - TAX LOT SELECTION FIX (WHO?)
      *             02/14/2019 - Y2K+20 DATE FIX (CONTRACTOR)
      *
      * PURPOSE:    CALCULATE TRADE SETTLEMENT AMOUNTS AND FEES
      *             FOR EQUITY AND FIXED INCOME TRANSACTIONS
      *
      * NOTE:       DO NOT MODIFY SECTIONS 4000-4999 WITHOUT
      *             APPROVAL FROM COMPLIANCE (SEE MEMO 94-0312)
      *
      * DEPENDENCIES: COPYBOOK ACCTMSTR, FEETABLE, TAXRATES
      *               CALLS PROGRAM DATEUTIL FOR DATE CALCS
      *               VSAM FILE FEEHIST FOR AUDIT
      *
      * WARNING:    THE FEE CALCULATION LOGIC IN 3000-CALC-FEES
      *             HAS KNOWN ISSUES WITH FOREIGN SECURITIES
      *             (TICKET #4521 - OPEN SINCE 2007)
      ******************************************************************
       IDENTIFICATION DIVISION.
       PROGRAM-ID. TRDSETTL.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ACCT-MASTER  ASSIGN TO ACCTMSTR
               ORGANIZATION IS INDEXED
               ACCESS MODE IS DYNAMIC
               RECORD KEY IS AM-ACCT-NUM
               FILE STATUS IS WS-ACCT-STATUS.
           SELECT FEE-HISTORY  ASSIGN TO FEEHIST
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FEE-STATUS.

       DATA DIVISION.
       FILE SECTION.

       FD  ACCT-MASTER.
       01  ACCT-MASTER-REC.
           05  AM-ACCT-NUM             PIC X(10).
           05  AM-ACCT-TYPE            PIC X(02).
               88 AM-TYPE-CASH         VALUE 'CA'.
               88 AM-TYPE-MARGIN       VALUE 'MG'.
               88 AM-TYPE-IRA          VALUE 'IR'.
               88 AM-TYPE-ROTH         VALUE 'RO'.
               88 AM-TYPE-401K         VALUE '4K'.
               88 AM-TYPE-INST         VALUE 'IN'.
           05  AM-STATUS               PIC X(01).
               88 AM-ACTIVE            VALUE 'A'.
               88 AM-SUSPENDED         VALUE 'S'.
               88 AM-CLOSED            VALUE 'C'.
               88 AM-RESTRICTED        VALUE 'R'.
           05  AM-TIER-CODE            PIC 9(02).
           05  AM-DISC-PCT             PIC 9V99.
           05  AM-TAX-STATUS           PIC X(01).
           05  AM-STATE-CODE           PIC X(02).
           05  AM-MARGIN-RATE          PIC 9V9999.
           05  AM-CASH-BAL             PIC S9(11)V99 COMP-3.
           05  AM-MARGIN-BAL           PIC S9(11)V99 COMP-3.
           05  AM-OPEN-DATE            PIC 9(08).
           05  AM-LAST-TRADE-DATE      PIC 9(08).

       FD  FEE-HISTORY.
       01  FEE-HISTORY-REC             PIC X(200).

       WORKING-STORAGE SECTION.

       01  WS-FILE-STATUS.
           05  WS-ACCT-STATUS          PIC X(02).
           05  WS-FEE-STATUS           PIC X(02).

       01  WS-TRADE-INPUT.
           05  WS-TRD-ACCT             PIC X(10).
           05  WS-TRD-ACTION           PIC X(01).
               88 WS-BUY               VALUE 'B'.
               88 WS-SELL              VALUE 'S'.
               88 WS-SHORT             VALUE 'H'.
               88 WS-COVER             VALUE 'C'.
           05  WS-TRD-SECURITY         PIC X(12).
           05  WS-TRD-SEC-TYPE         PIC X(02).
               88 WS-SEC-EQUITY        VALUE 'EQ'.
               88 WS-SEC-ETF           VALUE 'ET'.
               88 WS-SEC-MFUND         VALUE 'MF'.
               88 WS-SEC-BOND          VALUE 'BD'.
               88 WS-SEC-TBILL         VALUE 'TB'.
               88 WS-SEC-OPTION        VALUE 'OP'.
               88 WS-SEC-FOREIGN       VALUE 'FX'.
           05  WS-TRD-QTY              PIC 9(09)V9999.
           05  WS-TRD-PRICE            PIC 9(07)V9999.
           05  WS-TRD-DATE             PIC 9(08).
           05  WS-TRD-TIME             PIC 9(06).
           05  WS-TRD-EXCHANGE         PIC X(04).
           05  WS-TRD-CAPACITY         PIC X(01).
               88 WS-CAP-AGENT         VALUE 'A'.
               88 WS-CAP-PRINCIPAL     VALUE 'P'.
               88 WS-CAP-RISKLESS      VALUE 'R'.

       01  WS-CALCULATED-AMOUNTS.
           05  WS-GROSS-AMT            PIC S9(13)V99 COMP-3.
           05  WS-NET-AMT              PIC S9(13)V99 COMP-3.
           05  WS-COMMISSION           PIC S9(09)V99 COMP-3.
           05  WS-SEC-FEE              PIC S9(09)V9999 COMP-3.
           05  WS-TAF-FEE              PIC S9(09)V9999 COMP-3.
           05  WS-EXCHANGE-FEE         PIC S9(09)V99 COMP-3.
           05  WS-MARKUP               PIC S9(09)V99 COMP-3.
           05  WS-FOREIGN-FEE          PIC S9(09)V99 COMP-3.
           05  WS-MARGIN-INT           PIC S9(09)V99 COMP-3.
           05  WS-TOTAL-FEES           PIC S9(09)V99 COMP-3.
           05  WS-SETTLE-DATE          PIC 9(08).
           05  WS-SETTLE-DAYS          PIC 9(02).

       01  WS-FEE-RATES.
           05  WS-BASE-COMM-RATE       PIC 9V9999     VALUE 0.0075.
           05  WS-MIN-COMMISSION       PIC 9(05)V99   VALUE 4.95.
           05  WS-MAX-COMMISSION       PIC 9(05)V99   VALUE 29.95.
           05  WS-SEC-FEE-RATE         PIC 9V9(08)    VALUE 0.0000278.
           05  WS-TAF-RATE             PIC 9V9(06)    VALUE 0.000166.
           05  WS-TAF-MAX              PIC 9(03)V99   VALUE 8.30.
           05  WS-MFUND-LOAD           PIC 9V99       VALUE 0.00.
           05  WS-FOREIGN-ADR-FEE      PIC 9(03)V99   VALUE 0.05.

       01  WS-TIER-DISCOUNTS.
           05  WS-TIER-1-DISC          PIC 9V99       VALUE 0.00.
           05  WS-TIER-2-DISC          PIC 9V99       VALUE 0.10.
           05  WS-TIER-3-DISC          PIC 9V99       VALUE 0.20.
           05  WS-TIER-4-DISC          PIC 9V99       VALUE 0.35.
           05  WS-TIER-5-DISC          PIC 9V99       VALUE 0.50.
           05  WS-INST-DISC            PIC 9V99       VALUE 0.75.

       01  WS-WORK-FIELDS.
           05  WS-DISC-RATE            PIC 9V99.
           05  WS-WORK-AMT             PIC S9(13)V9999 COMP-3.
           05  WS-WORK-DATE            PIC 9(08).
           05  WS-DAY-OF-WEEK          PIC 9(01).
           05  WS-HOLIDAY-FLAG         PIC X(01).
           05  WS-ERROR-CODE           PIC X(04).
           05  WS-ERROR-MSG            PIC X(80).

       01  WS-RETURN-CODE              PIC S9(04) COMP VALUE 0.
           88  WS-SUCCESS              VALUE 0.
           88  WS-ACCT-NOT-FOUND       VALUE 10.
           88  WS-ACCT-RESTRICTED      VALUE 20.
           88  WS-INSUFF-FUNDS         VALUE 30.
           88  WS-INSUFF-MARGIN        VALUE 31.
           88  WS-SEC-NOT-TRADEABLE    VALUE 40.
           88  WS-INVALID-QTY          VALUE 50.
           88  WS-MARKET-CLOSED        VALUE 60.
           88  WS-SYSTEM-ERROR         VALUE 99.

       01  WS-CONSTANTS.
           05  WS-T-PLUS-1             PIC 9(01)      VALUE 1.
           05  WS-T-PLUS-2             PIC 9(01)      VALUE 2.
           05  WS-OPTIONS-SETTLE       PIC 9(01)      VALUE 1.
           05  WS-GOVT-SETTLE          PIC 9(01)      VALUE 1.

       PROCEDURE DIVISION.

       0000-MAIN-PROCESS.
      *---------------------------------------------------------------
      *    MAIN CONTROL PARAGRAPH
      *    ORCHESTRATES TRADE SETTLEMENT CALCULATION
      *---------------------------------------------------------------
           PERFORM 1000-INITIALIZE

           IF WS-SUCCESS
               PERFORM 2000-VALIDATE-TRADE
           END-IF

           IF WS-SUCCESS
               PERFORM 3000-CALC-FEES
           END-IF

           IF WS-SUCCESS
               PERFORM 4000-CALC-SETTLEMENT
           END-IF

           IF WS-SUCCESS
               PERFORM 5000-APPLY-MARGIN-RULES
           END-IF

           PERFORM 9000-FINALIZE

           STOP RUN.

       1000-INITIALIZE.
      *---------------------------------------------------------------
      *    OPEN FILES AND INITIALIZE WORKING STORAGE
      *---------------------------------------------------------------
           INITIALIZE WS-CALCULATED-AMOUNTS
           INITIALIZE WS-WORK-FIELDS

           OPEN INPUT ACCT-MASTER
           OPEN OUTPUT FEE-HISTORY

           IF WS-ACCT-STATUS NOT = '00'
               SET WS-SYSTEM-ERROR TO TRUE
               MOVE 'E001' TO WS-ERROR-CODE
               MOVE 'UNABLE TO OPEN ACCOUNT MASTER FILE'
                   TO WS-ERROR-MSG
           END-IF.

       2000-VALIDATE-TRADE.
      *---------------------------------------------------------------
      *    VALIDATE TRADE PARAMETERS AND ACCOUNT STATUS
      *    ** CRITICAL - DO NOT MODIFY WITHOUT COMPLIANCE REVIEW **
      *---------------------------------------------------------------
           MOVE WS-TRD-ACCT TO AM-ACCT-NUM
           READ ACCT-MASTER
               INVALID KEY
                   SET WS-ACCT-NOT-FOUND TO TRUE
                   MOVE 'E010' TO WS-ERROR-CODE
                   MOVE 'ACCOUNT NOT FOUND IN MASTER FILE'
                       TO WS-ERROR-MSG
           END-READ

           IF WS-SUCCESS
               PERFORM 2100-CHECK-ACCT-STATUS
           END-IF

           IF WS-SUCCESS
               PERFORM 2200-CHECK-SECURITY
           END-IF

           IF WS-SUCCESS
               PERFORM 2300-CHECK-QUANTITY
           END-IF.

       2100-CHECK-ACCT-STATUS.
      *---------------------------------------------------------------
      *    VERIFY ACCOUNT IS IN GOOD STANDING FOR TRADING
      *---------------------------------------------------------------
           IF AM-CLOSED
               SET WS-ACCT-RESTRICTED TO TRUE
               MOVE 'E020' TO WS-ERROR-CODE
               MOVE 'ACCOUNT IS CLOSED - NO TRADING ALLOWED'
                   TO WS-ERROR-MSG
           ELSE IF AM-SUSPENDED
               SET WS-ACCT-RESTRICTED TO TRUE
               MOVE 'E021' TO WS-ERROR-CODE
               MOVE 'ACCOUNT IS SUSPENDED - CONTACT COMPLIANCE'
                   TO WS-ERROR-MSG
           ELSE IF AM-RESTRICTED
      *        RESTRICTED ACCOUNTS CAN ONLY SELL/CLOSE POSITIONS
      *        THIS WAS ADDED IN 2003 PER REG-T REQUIREMENTS
               IF WS-BUY OR WS-SHORT
                   SET WS-ACCT-RESTRICTED TO TRUE
                   MOVE 'E022' TO WS-ERROR-CODE
                   MOVE 'RESTRICTED ACCT - CLOSING TRANS ONLY'
                       TO WS-ERROR-MSG
               END-IF
           END-IF.

       2200-CHECK-SECURITY.
      *---------------------------------------------------------------
      *    VALIDATE SECURITY TYPE AND TRADABILITY
      *    NOTE: FOREIGN SECURITIES HAVE ADDITIONAL CHECKS (2201)
      *---------------------------------------------------------------
           IF WS-SEC-OPTION
      *        OPTIONS REQUIRE SIGNED OPTIONS AGREEMENT
      *        CHECK IS IN ACCT MASTER BUT FIELD NOT SHOWN HERE
      *        TODO: ADD OPTIONS LEVEL CHECK (LEVELS 1-4)
               CONTINUE
           END-IF

           IF WS-SEC-FOREIGN
               PERFORM 2201-CHECK-FOREIGN-SECURITY
           END-IF

           IF WS-SEC-MFUND
      *        MUTUAL FUNDS CANNOT BE SHORTED OR MARGINED
               IF WS-SHORT
                   SET WS-SEC-NOT-TRADEABLE TO TRUE
                   MOVE 'E040' TO WS-ERROR-CODE
                   MOVE 'MUTUAL FUNDS CANNOT BE SOLD SHORT'
                       TO WS-ERROR-MSG
               END-IF
           END-IF.

       2201-CHECK-FOREIGN-SECURITY.
      *---------------------------------------------------------------
      *    ADDITIONAL VALIDATION FOR ADRs AND FOREIGN ORDINARIES
      *    WARNING: THIS SECTION HAS KNOWN BUGS - SEE TICKET #4521
      *---------------------------------------------------------------
      *    PLACEHOLDER - FOREIGN SECURITY CHECKS GO HERE
      *    CURRENT IMPLEMENTATION JUST LOGS WARNING
           CONTINUE.

       2300-CHECK-QUANTITY.
      *---------------------------------------------------------------
      *    VALIDATE TRADE QUANTITY AGAINST ACCOUNT RULES
      *---------------------------------------------------------------
           IF WS-TRD-QTY <= 0
               SET WS-INVALID-QTY TO TRUE
               MOVE 'E050' TO WS-ERROR-CODE
               MOVE 'TRADE QUANTITY MUST BE GREATER THAN ZERO'
                   TO WS-ERROR-MSG
           END-IF

      *    CHECK FOR ODD LOT (LESS THAN 100 SHARES)
      *    ODD LOTS MAY HAVE DIFFERENT EXECUTION RULES
           IF WS-SEC-EQUITY
               IF WS-TRD-QTY < 100
                   CONTINUE
      *            ODD LOT HANDLING - NO ADDITIONAL FEE SINCE 2015
               END-IF
           END-IF.

       3000-CALC-FEES.
      *---------------------------------------------------------------
      *    CALCULATE ALL APPLICABLE FEES AND COMMISSIONS
      *    THIS IS THE MAIN FEE CALCULATION ENGINE
      *    ** COMPLIANCE-SENSITIVE - LOG ALL CHANGES **
      *---------------------------------------------------------------
           COMPUTE WS-GROSS-AMT = WS-TRD-QTY * WS-TRD-PRICE

           PERFORM 3100-CALC-COMMISSION
           PERFORM 3200-CALC-REGULATORY-FEES
           PERFORM 3300-CALC-EXCHANGE-FEES

           IF WS-SEC-FOREIGN
               PERFORM 3400-CALC-FOREIGN-FEES
           END-IF

           COMPUTE WS-TOTAL-FEES =
               WS-COMMISSION + WS-SEC-FEE + WS-TAF-FEE +
               WS-EXCHANGE-FEE + WS-FOREIGN-FEE + WS-MARKUP.

       3100-CALC-COMMISSION.
      *---------------------------------------------------------------
      *    COMMISSION CALCULATION WITH TIER-BASED DISCOUNTS
      *    TIER CODES: 01-05 = RETAIL, 06 = INSTITUTIONAL
      *
      *    PRICING STRUCTURE (AS OF 2018 RATE CHANGE):
      *    - BASE: 0.75% OF PRINCIPAL
      *    - MIN: $4.95, MAX: $29.95
      *    - TIER DISCOUNTS APPLIED TO BASE BEFORE MIN/MAX
      *    - MUTUAL FUNDS: VARY BY FUND FAMILY (SEE MFUND-LOAD)
      *    - ETFs: SAME AS EQUITY
      *---------------------------------------------------------------
           IF WS-SEC-MFUND
      *        MUTUAL FUND COMMISSION IS LOAD-BASED
      *        SOME FUNDS ARE NO-LOAD, SOME HAVE FRONT/BACK LOADS
      *        THIS SHOULD BE LOOKED UP FROM FUND MASTER - HARDCODED NOW
               COMPUTE WS-COMMISSION = WS-GROSS-AMT * WS-MFUND-LOAD
           ELSE
      *        STANDARD COMMISSION CALCULATION
               COMPUTE WS-WORK-AMT = WS-GROSS-AMT * WS-BASE-COMM-RATE

      *        APPLY TIER DISCOUNT
               PERFORM 3110-GET-TIER-DISCOUNT
               COMPUTE WS-WORK-AMT =
                   WS-WORK-AMT * (1 - WS-DISC-RATE)

      *        APPLY ACCOUNT-LEVEL DISCOUNT (FROM ACCT MASTER)
      *        THIS IS FOR SPECIAL NEGOTIATED RATES
               IF AM-DISC-PCT > 0
                   COMPUTE WS-WORK-AMT =
                       WS-WORK-AMT * (1 - AM-DISC-PCT)
               END-IF

      *        ENFORCE MIN/MAX
               IF WS-WORK-AMT < WS-MIN-COMMISSION
                   MOVE WS-MIN-COMMISSION TO WS-COMMISSION
               ELSE IF WS-WORK-AMT > WS-MAX-COMMISSION
                   MOVE WS-MAX-COMMISSION TO WS-COMMISSION
               ELSE
                   MOVE WS-WORK-AMT TO WS-COMMISSION
               END-IF

      *        ZERO COMMISSION FOR PRINCIPAL TRADES
      *        (WE MAKE MONEY ON THE SPREAD INSTEAD)
               IF WS-CAP-PRINCIPAL
                   MOVE 0 TO WS-COMMISSION
      *            BUT ADD MARKUP - SEE 3300
               END-IF
           END-IF.

       3110-GET-TIER-DISCOUNT.
      *---------------------------------------------------------------
      *    LOOKUP TIER DISCOUNT BASED ON ACCOUNT TIER CODE
      *---------------------------------------------------------------
           EVALUATE AM-TIER-CODE
               WHEN 01
                   MOVE WS-TIER-1-DISC TO WS-DISC-RATE
               WHEN 02
                   MOVE WS-TIER-2-DISC TO WS-DISC-RATE
               WHEN 03
                   MOVE WS-TIER-3-DISC TO WS-DISC-RATE
               WHEN 04
                   MOVE WS-TIER-4-DISC TO WS-DISC-RATE
               WHEN 05
                   MOVE WS-TIER-5-DISC TO WS-DISC-RATE
               WHEN 06
      *            INSTITUTIONAL TIER - HIGHEST DISCOUNT
                   MOVE WS-INST-DISC TO WS-DISC-RATE
               WHEN OTHER
      *            UNKNOWN TIER - USE NO DISCOUNT
      *            THIS SHOULDN'T HAPPEN BUT DOES SOMETIMES
                   MOVE 0 TO WS-DISC-RATE
           END-EVALUATE.

       3200-CALC-REGULATORY-FEES.
      *---------------------------------------------------------------
      *    SEC FEE AND TAF (TRADING ACTIVITY FEE)
      *    THESE ARE PASS-THROUGH FEES - WE DON'T KEEP THEM
      *
      *    SEC FEE: ONLY ON SELLS, BASED ON PRINCIPAL AMOUNT
      *             RATE CHANGES PERIODICALLY (CHECK SEC WEBSITE)
      *             CURRENT RATE: $27.80 PER $1,000,000
      *
      *    TAF: CHARGED BY FINRA, ON ALL SALES
      *         RATE: $0.000166 PER SHARE, MAX $8.30/TRADE
      *---------------------------------------------------------------
           MOVE 0 TO WS-SEC-FEE
           MOVE 0 TO WS-TAF-FEE

           IF WS-SELL OR WS-SHORT
      *        SEC FEE APPLIES TO SALES
               COMPUTE WS-SEC-FEE = WS-GROSS-AMT * WS-SEC-FEE-RATE

      *        ROUND TO 2 DECIMAL PLACES (ALWAYS ROUND UP)
               COMPUTE WS-SEC-FEE ROUNDED = WS-SEC-FEE

      *        TAF FEE - PER SHARE WITH CAP
               COMPUTE WS-TAF-FEE = WS-TRD-QTY * WS-TAF-RATE
               IF WS-TAF-FEE > WS-TAF-MAX
                   MOVE WS-TAF-MAX TO WS-TAF-FEE
               END-IF
           END-IF

      *    TAX-ADVANTAGED ACCOUNTS DON'T PAY SOME FEES
      *    WAIT NO THAT'S WRONG - REGULATORY FEES APPLY TO ALL
      *    (LEFT THIS COMMENT AS REMINDER OF PAST BUG).

       3300-CALC-EXCHANGE-FEES.
      *---------------------------------------------------------------
      *    EXCHANGE-SPECIFIC FEES (ECN, ROUTING, ETC)
      *    AND PRINCIPAL TRADE MARKUP/MARKDOWN
      *---------------------------------------------------------------
           MOVE 0 TO WS-EXCHANGE-FEE
           MOVE 0 TO WS-MARKUP

      *    EXCHANGE FEES VARY - SIMPLIFIED HERE
      *    ACTUAL FEES SHOULD COME FROM EXCHANGE FEE TABLE
           IF WS-TRD-EXCHANGE = 'NYSE '
               MOVE 0.01 TO WS-EXCHANGE-FEE
           ELSE IF WS-TRD-EXCHANGE = 'NASD'
               MOVE 0.00 TO WS-EXCHANGE-FEE
           ELSE IF WS-TRD-EXCHANGE = 'ARCA'
               COMPUTE WS-EXCHANGE-FEE = WS-TRD-QTY * 0.003
           END-IF

      *    PRINCIPAL TRADES - ADD MARKUP/MARKDOWN
      *    THIS IS INSTEAD OF COMMISSION
           IF WS-CAP-PRINCIPAL
      *        MARKUP IS BASED ON SECURITY TYPE AND SIZE
      *        BONDS: UP TO 2% MARKUP
      *        EQUITY: UP TO 5% MARKUP (BUT USUALLY LESS)
               IF WS-SEC-BOND OR WS-SEC-TBILL
                   COMPUTE WS-MARKUP = WS-GROSS-AMT * 0.01
               ELSE
                   COMPUTE WS-MARKUP = WS-GROSS-AMT * 0.0025
               END-IF
           END-IF.

       3400-CALC-FOREIGN-FEES.
      *---------------------------------------------------------------
      *    ADDITIONAL FEES FOR ADRs AND FOREIGN SECURITIES
      *    ADR FEE: $0.01-0.05 PER SHARE (VARIES BY SECURITY)
      *    FX CONVERSION: IF TRADING IN FOREIGN CURRENCY
      *---------------------------------------------------------------
           MOVE 0 TO WS-FOREIGN-FEE

      *    ADR CUSTODY FEE - CHARGED PER SHARE
      *    RATE SHOULD COME FROM SECURITY MASTER - USING DEFAULT
           COMPUTE WS-FOREIGN-FEE = WS-TRD-QTY * WS-FOREIGN-ADR-FEE

      *    NOTE: FX FEES FOR FOREIGN ORDINARIES NOT IMPLEMENTED
      *    THOSE TRADES CURRENTLY ROUTE THROUGH DIFFERENT SYSTEM.

       4000-CALC-SETTLEMENT.
      *---------------------------------------------------------------
      *    DETERMINE SETTLEMENT DATE AND NET AMOUNTS
      *
      *    SETTLEMENT CYCLES (AS OF 2024 - T+1):
      *    - EQUITIES/ETFs: T+1
      *    - OPTIONS: T+1
      *    - MUTUAL FUNDS: T+1 OR T+2 (VARIES BY FUND)
      *    - GOVERNMENT BONDS: T+1
      *    - CORPORATE BONDS: T+2
      *
      *    *** UPDATED 05/2024 FOR T+1 TRANSITION ***
      *    *** PREVIOUS CODE HAD T+2 FOR EQUITIES  ***
      *---------------------------------------------------------------
           MOVE WS-TRD-DATE TO WS-WORK-DATE

      *    DETERMINE SETTLEMENT DAYS BASED ON SECURITY TYPE
           EVALUATE TRUE
               WHEN WS-SEC-EQUITY
                   MOVE WS-T-PLUS-1 TO WS-SETTLE-DAYS
               WHEN WS-SEC-ETF
                   MOVE WS-T-PLUS-1 TO WS-SETTLE-DAYS
               WHEN WS-SEC-OPTION
                   MOVE WS-OPTIONS-SETTLE TO WS-SETTLE-DAYS
               WHEN WS-SEC-MFUND
      *            MUTUAL FUNDS VARY - ASSUME T+1 FOR NOW
                   MOVE WS-T-PLUS-1 TO WS-SETTLE-DAYS
               WHEN WS-SEC-BOND
                   MOVE WS-T-PLUS-2 TO WS-SETTLE-DAYS
               WHEN WS-SEC-TBILL
                   MOVE WS-GOVT-SETTLE TO WS-SETTLE-DAYS
               WHEN OTHER
                   MOVE WS-T-PLUS-2 TO WS-SETTLE-DAYS
           END-EVALUATE

      *    CALL DATE UTILITY TO ADD BUSINESS DAYS
      *    (SKIPS WEEKENDS AND HOLIDAYS)
           CALL 'DATEUTIL' USING WS-WORK-DATE
                                 WS-SETTLE-DAYS
                                 WS-SETTLE-DATE
                                 WS-HOLIDAY-FLAG

      *    CALCULATE NET SETTLEMENT AMOUNT
           IF WS-BUY OR WS-COVER
      *        BUYING - CUSTOMER PAYS GROSS + FEES
               COMPUTE WS-NET-AMT = WS-GROSS-AMT + WS-TOTAL-FEES
           ELSE
      *        SELLING - CUSTOMER RECEIVES GROSS - FEES
               COMPUTE WS-NET-AMT = WS-GROSS-AMT - WS-TOTAL-FEES
           END-IF.

       5000-APPLY-MARGIN-RULES.
      *---------------------------------------------------------------
      *    APPLY REGULATION T MARGIN REQUIREMENTS
      *    AND CALCULATE ANY MARGIN INTEREST
      *
      *    REG-T REQUIRES 50% INITIAL MARGIN FOR MOST SECURITIES
      *    MAINTENANCE MARGIN IS 25% (OUR HOUSE REQUIREMENT: 30%)
      *
      *    ADDED 2003 BY DKB - MARGIN LOGIC WAS MISSING FROM ORIGINAL
      *---------------------------------------------------------------
           IF NOT AM-TYPE-MARGIN
      *        NOT A MARGIN ACCOUNT - SKIP THIS SECTION
               CONTINUE
           ELSE
               PERFORM 5100-CHECK-MARGIN-REQUIREMENTS
               IF WS-SUCCESS
                   PERFORM 5200-CALC-MARGIN-INTEREST
               END-IF
           END-IF.

       5100-CHECK-MARGIN-REQUIREMENTS.
      *---------------------------------------------------------------
      *    VERIFY ADEQUATE MARGIN FOR THE TRADE
      *    BUY TRADES: CHECK AVAILABLE MARGIN
      *    SELL TRADES: MAY RELEASE MARGIN
      *---------------------------------------------------------------
           IF WS-BUY
      *        CALCULATE MARGIN REQUIRED (50% OF PURCHASE)
               COMPUTE WS-WORK-AMT = WS-NET-AMT * 0.50

      *        CHECK IF ACCOUNT HAS SUFFICIENT MARGIN AVAILABLE
      *        MARGIN AVAILABLE = CASH + (EQUITY * MARGIN RATE) - DEBT
      *        SIMPLIFIED HERE - ACTUAL CALC IS MORE COMPLEX
               IF WS-WORK-AMT > AM-MARGIN-BAL
                   SET WS-INSUFF-MARGIN TO TRUE
                   MOVE 'E031' TO WS-ERROR-CODE
                   MOVE 'INSUFFICIENT MARGIN FOR THIS TRADE'
                       TO WS-ERROR-MSG
               END-IF
           END-IF.

       5200-CALC-MARGIN-INTEREST.
      *---------------------------------------------------------------
      *    CALCULATE MARGIN INTEREST IF BORROWING FUNDS
      *    INTEREST RATE IS PRIME + SPREAD (FROM ACCT MASTER)
      *    INTEREST ACCRUES DAILY, CHARGED MONTHLY
      *---------------------------------------------------------------
           MOVE 0 TO WS-MARGIN-INT

      *    ONLY CALCULATE IF THIS TRADE USES MARGIN
           IF WS-BUY
               IF AM-CASH-BAL < WS-NET-AMT
      *            WILL NEED TO BORROW - CALC ESTIMATED INTEREST
      *            THIS IS JUST AN ESTIMATE FOR DISCLOSURE
      *            ACTUAL INTEREST CALCULATED IN NIGHTLY BATCH
                   COMPUTE WS-WORK-AMT = WS-NET-AMT - AM-CASH-BAL
                   COMPUTE WS-MARGIN-INT =
                       (WS-WORK-AMT * AM-MARGIN-RATE) / 360
               END-IF
           END-IF.

       9000-FINALIZE.
      *---------------------------------------------------------------
      *    CLEANUP AND WRITE AUDIT RECORD
      *---------------------------------------------------------------
           PERFORM 9100-WRITE-AUDIT-RECORD

           CLOSE ACCT-MASTER
           CLOSE FEE-HISTORY.

       9100-WRITE-AUDIT-RECORD.
      *---------------------------------------------------------------
      *    WRITE FEE CALCULATION DETAILS TO AUDIT FILE
      *    REQUIRED FOR COMPLIANCE AND BILLING RECONCILIATION
      *---------------------------------------------------------------
      *    FORMAT THE AUDIT RECORD
      *    (LAYOUT NOT SHOWN - SEE COPYBOOK FEEAUDIT)
           MOVE WS-TRD-ACCT TO FEE-HISTORY-REC(1:10)
           MOVE WS-TRD-DATE TO FEE-HISTORY-REC(11:8)
           MOVE WS-TRD-SECURITY TO FEE-HISTORY-REC(19:12)
      *    ... ADDITIONAL FIELDS ...

           WRITE FEE-HISTORY-REC.

      ******************************************************************
      *    END OF PROGRAM TRDSETTL
      ******************************************************************
