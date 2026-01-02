---
name: Create Draw.io Diagram
description: Generate draw.io compatible diagrams with layout instructions
agent: diagram-architect
---

Create a diagram with draw.io-compatible format and layout instructions.

## Draw.io Export Options

### Option 1: Mermaid Import
Draw.io can import Mermaid diagrams directly:
1. Open draw.io (https://app.diagrams.net)
2. Go to **Arrange → Insert → Advanced → Mermaid**
3. Paste the Mermaid code
4. Edit and style as needed

### Option 2: Step-by-Step Layout Instructions
When Mermaid import isn't suitable, provide detailed layout instructions.

## Diagram Types

### Architecture Diagram Layout
```
Create a draw.io architecture diagram with:

LAYERS (top to bottom):
1. Client Layer (light blue background)
   - Web App (rectangle, left)
   - Mobile App (rectangle, right)

2. API Layer (light green background)
   - API Gateway (rectangle, centered)

3. Service Layer (light orange background)
   - Auth Service (rectangle)
   - Portfolio Service (rectangle)
   - Trading Service (rectangle)
   - Notification Service (rectangle)

4. Data Layer (light purple background)
   - PostgreSQL (cylinder shape)
   - Redis (cylinder shape)

5. External (light gray background)
   - Market Data Feed (cloud shape)

CONNECTIONS (arrows with labels):
- Web App → API Gateway: "HTTPS"
- Mobile App → API Gateway: "HTTPS"
- API Gateway → All Services: "REST"
- Services → PostgreSQL: "SQL"
- Services → Redis: "Cache"
- Trading Service → Market Data Feed: "WebSocket"
```

### Flowchart Layout
```
Create a draw.io flowchart with:

SHAPES:
- Start/End: Rounded rectangle (green/red)
- Process: Rectangle (blue)
- Decision: Diamond (yellow)
- Subprocess: Rectangle with bars (purple)

FLOW:
1. Start → Initialize
2. Initialize → [Decision: Account Valid?]
3. Account Valid? --Yes--> Validate Security
4. Account Valid? --No--> Reject (red)
5. [Continue with full flow...]

ALIGNMENT:
- Main flow: vertical (top to bottom)
- Error paths: branch right
- Use swimlanes for phases
```

### Sequence Diagram Layout
```
Create a draw.io sequence diagram with:

PARTICIPANTS (left to right):
1. User (actor shape)
2. Web App (rectangle)
3. API Gateway (rectangle)
4. Trading Service (rectangle)
5. Portfolio Service (rectangle)
6. External Broker (rectangle)
7. Notification Service (rectangle)

MESSAGES (numbered):
1. User → Web App: "Submit Order"
2. Web App → API Gateway: "POST /orders"
[Continue...]

LIFELINES: Vertical dashed lines from each participant

ACTIVATION BOXES: Rectangles on lifelines during processing

ALT BOX: Rectangle around alternative flows with [condition] label
```

## Draw.io Tips

1. **Use Layers** - Separate diagram elements for easy editing
2. **Group Related Shapes** - Select → Group (Ctrl+G)
3. **Apply Styles** - Right-click → Edit Style for consistent formatting
4. **Use Containers** - Swimlanes and containers for grouping
5. **Connect Shapes** - Use connection points for clean arrows
6. **Export Options** - PNG, SVG, PDF, or embed in docs

## Color Palette

| Element | Color Code | Usage |
|---------|------------|-------|
| Client Layer | #E3F2FD | Light blue |
| API Layer | #E8F5E9 | Light green |
| Service Layer | #FFF3E0 | Light orange |
| Data Layer | #F3E5F5 | Light purple |
| External | #ECEFF1 | Light gray |
| Error Path | #FFEBEE | Light red |
| Success Path | #E8F5E9 | Light green |

## Output

Provide either:
1. **Mermaid code** (for direct import)
2. **Detailed layout instructions** (for manual creation)
3. **Both** (recommended)

## Save To
`outputs/diagrams/{diagram-name}.drawio.md` (instructions)
Or export from draw.io as `.drawio` or `.png`
