# GenAI DevAssist | Analyst Documentation
## Instructor Guide v1.0

**Version:** 1.0  
**Duration:** 75 minutes  
**Target Audience:** Analysts and product teams  
**Fidelity DevAssist Program**

---

## Table of Contents

1. [Pre-Workshop Preparation](#pre-workshop-preparation)
2. [Facilitation Timeline](#facilitation-timeline)
3. [Section-by-Section Guide](#section-by-section-guide)
4. [Lab Facilitation](#lab-facilitation)
5. [Common Issues & Solutions](#common-issues--solutions)
6. [Assessment](#assessment)

---

## Pre-Workshop Preparation

### One Week Before
- [ ] Verify AI tool access for all participants
- [ ] Prepare sample meeting notes and rough docs
- [ ] Test Mermaid rendering in target environment
- [ ] Review documentation templates
- [ ] Identify participant documentation challenges

### Day Before
- [ ] Load sample inputs in lab repository
- [ ] Test all demo prompts
- [ ] Prepare Mermaid preview environment
- [ ] Print template quick reference cards

### Day Of
- [ ] Arrive 30 minutes early
- [ ] Display Mermaid Live Editor URL
- [ ] Open sample documents
- [ ] Test screen sharing for diagrams

---

## Facilitation Timeline

| Time | Duration | Section | Key Focus |
|------|----------|---------|-----------|
| 0:00 | 5 min | Opening | Documentation value proposition |
| 0:05 | 12 min | Documentation Basics | Prompts, demos |
| 0:17 | 15 min | **Lab 1** | Create requirements & specs |
| 0:32 | 13 min | Visual Artifacts | Mermaid diagrams |
| 0:45 | 15 min | **Lab 2** | Create diagrams |
| 1:00 | 8 min | Standards | Quality & consistency |
| 1:08 | 5 min | **Lab 3** | Review documentation |
| 1:13 | 2 min | Wrap-up | Homework, resources |

### Time Buffers
- If behind: Shorten Lab 1 to 12 min, Lab 2 to 12 min
- If ahead: Extended demo time, more examples

---

## Section-by-Section Guide

### Section 1: Opening (0:00-0:05)

#### Opening Hook
Ask: "How many hours this week did you spend explaining something that was documented somewhere?"

Expected responses: 2-5 hours typical

#### Key Messages
- Poor documentation = repeated questions = wasted time
- AI can draft, you verify and refine
- Goal: 80% faster first drafts

#### Workshop Goals
By end of session, participants will:
- Transform rough notes → professional docs
- Generate architecture/sequence/flow diagrams
- Apply quality standards

---

### Section 2: AI-Powered Documentation Basics (0:05-0:17)

#### Document Types Overview (3 min)
Walk through the table:
| Type | Audience | Purpose |
|------|----------|---------|
| Requirements | Dev team | Define what to build |
| Technical Specs | Engineers | Define how to build |
| Process Docs | Operations | Define how to operate |
| User Guides | End users | Enable self-service |

#### Prompting Technique (4 min)
Explain the structure:
- Audience: Who reads this?
- Purpose: What do they need to do?
- Sections: What to include?
- Format: How should it look?

#### Demo 1: Requirements Document (5 min)
1. Show raw meeting notes
2. Execute prompt in AI tool
3. Review generated document
4. Point out structure, completeness

**Demo Prompt:**
```
Create a requirements document for portfolio rebalancing:

Audience: Development team and QA
Purpose: Sprint planning scope definition

Include:
1. Feature overview
2. 3-5 user stories with acceptance criteria
3. Business rules
4. Out of scope
5. Dependencies

Format: Markdown with headers
Tone: Technical but clear
```

---

### Section 3: Lab 1 - Creating Technical Documentation (0:17-0:32)

#### Setup (2 min)
"You have 15 minutes. Transform the meeting notes into:
1. Requirements document (8 min)
2. Technical spec outline (7 min)

Use the prompts in your participant guide."

#### During Lab

**Circulation Pattern:**
- 0-3 min: Ensure everyone has input file, answer setup questions
- 3-8 min: Review requirements outputs, suggest improvements
- 8-12 min: Help with technical spec outlines
- 12-15 min: Identify good examples to share

#### Lab 1 Checkpoints

**At 5 min:**
"Quick check: How many have their feature overview and at least 2 user stories?"
Target: 70%+

**At 10 min:**
"Who's moving to the technical spec outline?"
Target: 80%+

#### Common Issues
| Issue | Quick Fix |
|-------|-----------|
| Prompt too generic | Add specific sections to include |
| Output too long | Add "Be concise, 1-2 sentences per section" |
| Missing acceptance criteria | Remind: "Testable criteria for each story" |
| User stories vague | Show example format from template |

#### Debrief (2 min)
Ask 1-2 participants to share best user story or insight.

---

### Section 4: Visual Artifacts with GenAI (0:32-0:45)

#### Mermaid Introduction (3 min)
- Text-based diagrams
- Version controllable
- AI generates well
- Renders in GitHub, Confluence, VS Code

#### Demo 2: Architecture Diagram (4 min)
1. Describe system components
2. Execute prompt
3. Show rendered diagram
4. Explain syntax briefly

**Demo Prompt:**
```
Create a Mermaid architecture diagram for portfolio system:

Components: Web App, API Gateway, Portfolio Service, 
Transaction Service, Database, Cache

Show:
- User entry at top
- Service layer in middle
- Data layer at bottom
- Use subgraphs for grouping
```

#### Demo 3: Sequence Diagram (3 min)
Show login flow or trade execution

#### Demo 4: Flowchart (3 min)
Show approval process or decision tree

---

### Section 5: Lab 2 - Creating Diagrams (0:45-1:00)

#### Setup (1 min)
"Three diagrams in 15 minutes:
1. Architecture (5 min)
2. Sequence (5 min)
3. Flowchart (5 min)

Use Mermaid Live Editor or VS Code extension to preview."

#### During Lab

**Circulation Focus:**
- Help with Mermaid syntax errors
- Suggest component groupings
- Encourage proper labeling

#### Lab 2 Checkpoints

**At 5 min:**
"How many have a rendering architecture diagram?"
Help those stuck on syntax.

**At 10 min:**
"Who's on the flowchart?"
Prioritize if behind.

#### Common Syntax Issues
| Error | Fix |
|-------|-----|
| "Parse error" | Check for missing brackets, quotes |
| Arrows not showing | Use --> not -> |
| Subgraph not rendering | Check indentation |
| Labels cut off | Use shorter names |

---

### Section 6: Documentation Standards (1:00-1:08)

#### Quality Checklist (4 min)
Walk through key items:
- Clear purpose statement
- Defined audience
- Consistent terminology
- No TBD content
- Reviewed by SME

#### Consistency Prompt (4 min)
Show how to use AI for consistency review:
```
Review these documents for consistency:
- Same terms for same concepts?
- Similar detail level?
- Accurate cross-references?
```

---

### Section 7: Lab 3 - Documentation Review (1:08-1:13)

#### Setup (1 min)
"Use AI to review your Lab 1 and Lab 2 outputs. Get a quality score and improvement suggestions."

#### During Lab (4 min)
- Help interpret feedback
- Suggest prioritizing top 2-3 improvements
- Collect interesting findings

---

### Section 8: Wrap-up (1:13-1:15)

#### Key Takeaways
1. AI accelerates first drafts
2. Structure your prompts
3. Diagrams communicate better than text
4. Consistency builds trust
5. Always review AI output

#### Homework Assignment
1. Create one feature doc using AI
2. Generate 3 diagrams for team
3. Establish one template

---

## Common Issues & Solutions

### Technical Issues

| Issue | Solution |
|-------|----------|
| Mermaid not rendering | Check syntax at mermaid.live |
| AI giving generic output | Add more specific context |
| Diagrams too complex | Break into multiple diagrams |
| Confluence formatting broken | Use markdown preview first |

### Facilitation Issues

| Issue | Solution |
|-------|----------|
| Analysts unfamiliar with AI tools | Pair with experienced user |
| Lab running long | Focus on one deliverable per lab |
| Diagrams taking all the time | Provide partial templates |
| Questions about specific tools | Park for office hours |

---

## Assessment

### During Workshop

Track per participant:
- [ ] Completed requirements document
- [ ] Created technical spec outline
- [ ] Generated at least 2 diagrams
- [ ] Participated in review

### Quality Indicators

**Lab 1 Success:**
- Requirements doc has 3+ user stories
- Acceptance criteria are testable
- Technical spec has clear sections

**Lab 2 Success:**
- Diagrams render correctly
- Labels are meaningful
- Flow is logical

### Homework Evaluation

| Criterion | Points |
|-----------|--------|
| Feature doc created with AI | 30 |
| 3 diagrams generated | 30 |
| Template established | 20 |
| Quality of outputs | 20 |
| **Total** | **100** |

---

## Appendix: Demo Scripts

### Demo 1: Requirements from Notes

**Input (rough notes):**
```
talked about alerts feature
- price alerts when stock moves 5%
- portfolio value thresholds
- email and push notifications
- user can configure thresholds
```

**Output (show this):**
Well-structured requirements with user stories, acceptance criteria, business rules.

### Demo 2: Architecture Diagram

Show the prompt, execute live, render result, explain components.

---

**End of Instructor Guide**
