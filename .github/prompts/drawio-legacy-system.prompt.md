---
name: Draw.io Legacy System Diagram
description: Create draw.io diagram for legacy COBOL system visualization
agent: diagram-architect
---

Create a professional draw.io diagram visualizing the TRDSETTL legacy system.

## Purpose

Create a visual representation of the COBOL trade settlement system that:
- Executives and business stakeholders can understand
- Developers can use for modernization planning
- Compliance can verify fee calculation logic

## Diagram Options

### Option A: System Context Diagram

```
LAYOUT: Centered target system with external entities around it

CENTER:
- TRDSETTL Program (large rectangle, mainframe icon)
  - Label: "Trade Settlement System"
  - Subtitle: "COBOL/z/OS - Est. 1994"

EXTERNAL ENTITIES (circles/ovals around center):
- TOP: Trade Entry System (input)
- LEFT: Account Master (VSAM file, cylinder)
- RIGHT: Fee History (output file, cylinder)
- BOTTOM-LEFT: DATEUTIL Program (subprocess)
- BOTTOM-RIGHT: Audit Log (output)

ARROWS (with data labels):
- Trade Entry → TRDSETTL: "Trade Records"
- Account Master → TRDSETTL: "Account Data"
- TRDSETTL → Fee History: "Fee Records"
- TRDSETTL → DATEUTIL: "Date Request"
- DATEUTIL → TRDSETTL: "Business Day"
- TRDSETTL → Audit Log: "Audit Trail"
```

### Option B: Process Flow Diagram

```
LAYOUT: Swimlane diagram with phases

SWIMLANES (horizontal bands):
1. Initialization (light blue)
2. Validation (light yellow)
3. Fee Calculation (light green)
4. Settlement (light purple)
5. Finalization (light gray)

SHAPES IN EACH LANE:

Initialization:
- [Start] → [Open Files] → [Initialize Variables]

Validation:
- [Check Account Status] → <Account OK?> → [Check Security] → <Security OK?> → [Check Quantity] → <Quantity OK?>
- Each <Decision> has "No" path to [Reject with Error Code]

Fee Calculation:
- [Calculate Commission] → [Apply Tier Discount] → [Check Min/Max] → [Calculate SEC Fee] → [Calculate TAF] → [Calculate Exchange Fee] → [Sum Total Fees]

Settlement:
- [Determine Security Type] → [Get Base Days] → [Call DATEUTIL] → [Set Settlement Date]

Finalization:
- [Apply Margin Rules?] → [Write Audit Record] → [Close Files] → [End]

DECISION DIAMONDS with conditions visible
ERROR PATHS in red arrows branching to rejection boxes
```

### Option C: Fee Calculation Detail

```
LAYOUT: Hierarchical breakdown with calculations

TOP: [Total Fees] (result box)

LEVEL 1 - Fee Categories:
├── [Commission]
├── [Regulatory Fees]
├── [Exchange Fees]
└── [Other Fees]

LEVEL 2 - Breakdowns:

Commission:
├── [Base: 0.75% × Principal]
├── [Tier Discount: 0-75%]
├── [Account Discount]
└── [Min $4.95 / Max $29.95]

Regulatory (Sells Only):
├── [SEC: $27.80 per $1M]
└── [TAF: $0.000166/share, max $8.30]

Exchange:
├── [NYSE: $0.0003/share]
├── [NASDAQ: $0.0002/share]
├── [AMEX: $0.00025/share]
└── [Other: $0.0001/share]

Other:
├── [ADR Fee: $0.02/share]
└── [Principal Markup: 1.5%]

Use callout boxes for conditions (e.g., "Only for sells", "If foreign security")
```

## Draw.io Styling Guide

### Shapes
| Element | Shape | Color |
|---------|-------|-------|
| Program/System | Rectangle with icon | #1976D2 (blue) |
| File/Database | Cylinder | #7B1FA2 (purple) |
| External System | Cloud or oval | #616161 (gray) |
| Process Step | Rounded rectangle | #4CAF50 (green) |
| Decision | Diamond | #FFC107 (amber) |
| Error/Reject | Rectangle | #F44336 (red) |

### Arrows
- Data flow: Solid arrow
- Control flow: Dashed arrow
- Error path: Red arrow
- Optional: Gray dashed arrow

### Text
- System names: Bold, larger font
- Labels: Regular, smaller font
- Conditions: Italic

## Export Recommendations

1. **For presentations**: PNG at 2x resolution
2. **For documentation**: SVG (scalable)
3. **For editing**: Keep .drawio file
4. **For embedding**: Use draw.io embed code

## Save To
- Layout instructions: `outputs/diagrams/trdsettl-system-drawio.md`
- Diagram file: `outputs/diagrams/trdsettl-system.drawio` (or `.png`)
