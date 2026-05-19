---
name: Draw.io Legacy System Diagram
description: Create draw.io diagram for legacy COBOL system visualization
agent: diagram-architect
 
Create a professional draw.io diagram visualizing the TRDSETTL legacy system.

## Purpose

Create a visual representation of the COBOL trade settlement system that:

## Diagram Options

### Option A: System Context Diagram

```
LAYOUT: Centered target system with external entities around it

CENTER:
  - Label: "Trade Settlement System"
  - Subtitle: "COBOL/z/OS - Est. 1994"

EXTERNAL ENTITIES (circles/ovals around center):

ARROWS (with data labels):
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

Validation:

Fee Calculation:

Settlement:

Finalization:

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

### Text

## Export Recommendations

1. **For presentations**: PNG at 2x resolution
2. **For documentation**: SVG (scalable)
3. **For editing**: Keep .drawio file
4. **For embedding**: Use draw.io embed code

## Save To
