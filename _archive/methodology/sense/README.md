# Sense Phase

*Develop shared understanding of users and systems.*

---

## Purpose

Ground told you what's possible. Sense tells you what's actually happening — for users, in the system, and in the gaps between them.

This phase answers: **Who are we designing for, and how does the current system serve (or fail) them?**

---

## At a Glance

| | |
|---|---|
| **Duration** | 2-4 weeks |
| **Primary Owner** | UX Strategist |
| **Key Activities** | User research, systems mapping, equity analysis |
| **Outputs** | System map, Research findings, Risk/impact register |
| **Exit Criteria** | Team has shared understanding of users and system; ready to generate solutions |

---

## Who Does What

| Role | Sense Phase Responsibilities |
|------|------------------------------|
| **Project Lead** | Coordinates access to users, manages client expectations |
| **UX Strategist** | Leads research, facilitates synthesis, drafts deliverables |
| **UX/UI Designer** | Observes research, creates journey maps, identifies design opportunities |
| **Builder** | Maps technical systems, identifies integration points and risks |

---

## Key Principle: Decision-Driven Research

Don't do research for research's sake. Every research activity should answer a question that will inform a decision.

| ❌ Research Theater | ✅ Decision-Driven Research |
|---------------------|----------------------------|
| "Let's interview 20 users" | "We need to decide if users can self-serve — 5 interviews will tell us" |
| "We should map the full journey" | "Where do users drop off? Map those moments" |
| "Let's do a survey" | "What specific question can only a survey answer?" |

Before any research: **What decision will this inform?**

---

## Week-by-Week Activities

### Week 1: Plan & Recruit

**Goal:** Set up research for success.

| Day | Activity | Owner |
|-----|----------|-------|
| 1 | Define research questions (tied to decisions) | UX Strategist |
| 1-2 | Identify user segments to include | UX Strategist |
| 2-3 | Recruit participants (5-8 per segment) | Project Lead + Client |
| 2-3 | Request system documentation | Builder |
| 3-5 | Schedule research sessions | UX Strategist |
| 3-5 | Begin technical system mapping | Builder |

### Week 2: Conduct Research

**Goal:** Talk to users, observe reality.

| Day | Activity | Owner |
|-----|----------|-------|
| 1-5 | Conduct user interviews/observations | UX Strategist + Designer |
| 1-5 | Continue system mapping | Builder |
| 3-5 | Daily debrief: capture insights | All |
| 5 | Mid-research check: are we learning what we need? | UX Strategist |

### Week 3: Synthesize

**Goal:** Turn data into understanding.

| Day | Activity | Owner |
|-----|----------|-------|
| 1-2 | Affinity mapping: cluster findings | UX Strategist + Designer |
| 2-3 | Create journey map (current state) | Designer |
| 2-3 | Complete system map | Builder |
| 3-4 | Draft research findings | UX Strategist |
| 4-5 | Draft risk/impact register | UX Strategist + Builder |
| 5 | Internal review | All |

### Week 4: Align (if needed)

**Goal:** Get client agreement on findings.

| Day | Activity | Owner |
|-----|----------|-------|
| 1-2 | Refine deliverables based on internal review | UX Strategist |
| 2-3 | Present findings to client | Project Lead + UX Strategist |
| 3-4 | Incorporate feedback | UX Strategist |
| 5 | Sign-off to proceed to Shape | Project Lead |

---

## User Research

### Who to Talk To

Include multiple user segments. For government projects, this often means:

| Segment | Why They Matter | Example |
|---------|-----------------|---------|
| **Primary users** | Directly use the system | Applicants, claimants, citizens |
| **Power users** | Use it heavily, know workarounds | Frequent filers, case managers |
| **Edge cases** | Stress-test the system | Users with accessibility needs, limited English, rural access |
| **Internal users** | Process the work | Case workers, reviewers, call center staff |
| **Failed users** | Couldn't complete the process | Abandoned applications, denied claims |

### Research Methods

| Method | When to Use | Sample Size |
|--------|-------------|-------------|
| **Interviews** | Deep understanding of needs, context, emotions | 5-8 per segment |
| **Contextual inquiry** | See how work actually happens | 3-5 observations |
| **Usability testing** | Evaluate existing system | 5-8 participants |
| **Diary studies** | Understand behavior over time | 5-10 participants |
| **Survey** | Validate patterns at scale (after qualitative) | 50+ responses |

### Sense Phase Interview Questions

These build on Ground phase — now we're focused on the user experience, not organizational dynamics.

#### Opening (5 min)
- Tell me about yourself. What brings you to [this service/process]?
- How long have you been dealing with this?

#### Their Journey (15 min)
- Walk me through what happened from the beginning.
- What were you trying to accomplish?
- What did you try first? Then what?
- Where did you get stuck?
- How did you feel at that moment?

#### The System (10 min)
- What worked well?
- What was confusing or frustrating?
- Did you have to ask anyone for help? Who?
- Did you use any workarounds?

#### Needs & Expectations (10 min)
- What did you expect would happen?
- What would have made this easier?
- If you could change one thing, what would it be?
- How does this compare to other similar experiences?

#### Close (5 min)
- Is there anything I didn't ask about that I should know?
- Would you be willing to look at ideas later and give feedback?

---

## Systems Mapping

### Purpose
Understand how the current system actually works — not how it's documented, but how it operates in practice.

### What to Map

| Layer | Questions to Answer |
|-------|---------------------|
| **User journey** | What steps do users go through? Where do they struggle? |
| **Service delivery** | Who does what to process the work? What are the handoffs? |
| **Technology** | What systems are involved? How do they connect? |
| **Policy** | What rules govern decisions? Where is there discretion? |
| **Data** | What data moves through the system? Where does it break? |

### System Map Components

```
┌─────────────────────────────────────────────────────────────┐
│                        USER JOURNEY                          │
│  [Awareness] → [Application] → [Processing] → [Decision]    │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                     SERVICE DELIVERY                         │
│  [Intake] → [Review] → [Adjudication] → [Notification]      │
│     ↓          ↓            ↓               ↓               │
│  [Staff]    [Staff]     [Staff]         [System]            │
└─────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────┐
│                        TECHNOLOGY                            │
│  [Portal] ←→ [Case Mgmt] ←→ [Legacy DB] ←→ [Notification]   │
└─────────────────────────────────────────────────────────────┘
```

### Builder's Technical Discovery Checklist

- [ ] What systems touch this process?
- [ ] What are the integration points?
- [ ] Where is data stored? How does it move?
- [ ] What are the known reliability issues?
- [ ] What can/can't be changed?
- [ ] What would it take to integrate or replace each component?

---

## Equity Analysis

### Purpose
Identify who is underserved by the current system and why.

### Questions to Ask

| Question | What You're Looking For |
|----------|------------------------|
| Who succeeds easily with this system? | Default design assumptions |
| Who struggles? | Barriers and gaps |
| Who doesn't use it at all? | Exclusion (intentional or not) |
| What does the data show by demographic? | Disparities in outcomes |
| What workarounds exist? | Signs of system failure |

### Common Equity Barriers in Government Services

| Barrier Type | Examples |
|--------------|----------|
| **Access** | Requires internet, smartphone, transportation, time off work |
| **Language** | English-only, jargon, reading level |
| **Trust** | Fear of immigration enforcement, past negative experiences |
| **Digital literacy** | Assumes familiarity with forms, uploads, accounts |
| **Documentation** | Requires ID, records, proof that some people can't get |
| **Complexity** | Too many steps, confusing instructions, no help available |

---

## Output 1: Research Findings

### Purpose
Translate research into actionable insights tied to decisions.

### Template

```markdown
# Research Findings

**Project:** [Project Name]
**Date:** [Date]
**Prepared by:** [Name]

---

## Research Overview

| | |
|---|---|
| **Research questions** | [What we set out to learn] |
| **Methods** | [Interviews, observations, etc.] |
| **Participants** | [X users across Y segments] |
| **Dates** | [When research was conducted] |

---

## Key Findings

### Finding 1: [Headline]

**What we learned:** [2-3 sentences describing the finding]

**Evidence:**
- [Quote or observation]
- [Quote or observation]
- [Data point if available]

**Decision implication:** [What this means for our solution]

---

### Finding 2: [Headline]

**What we learned:** [2-3 sentences]

**Evidence:**
- [Quote or observation]
- [Quote or observation]

**Decision implication:** [What this means for our solution]

---

### Finding 3: [Headline]

[Same structure]

---

## User Segments

### Segment 1: [Name]

**Who they are:** [Description]

**Key needs:**
- [Need 1]
- [Need 2]

**Key pain points:**
- [Pain point 1]
- [Pain point 2]

**Quote:** "[Representative quote]"

---

### Segment 2: [Name]

[Same structure]

---

## Journey Pain Points

| Journey Stage | Pain Point | Severity | Frequency |
|---------------|------------|----------|-----------|
| [Stage] | [What goes wrong] | High/Med/Low | Common/Occasional/Rare |

---

## Equity Considerations

| Population | Barrier | Impact | Opportunity |
|------------|---------|--------|-------------|
| [Group] | [What blocks them] | [How it affects them] | [How we might address it] |

---

## Recommendations for Shape Phase

Based on these findings, we recommend exploring solutions that:

1. [Direction 1 — tied to findings]
2. [Direction 2 — tied to findings]
3. [Direction 3 — tied to findings]

---

## Appendix

- [Link to interview notes]
- [Link to journey map]
- [Link to affinity diagram]
```

---

## Output 2: System Map

### Purpose
Visual representation of how the current system works.

### Template (FigJam)

Create in FigJam with these layers:

```
Layer 1: User Journey (top)
- Stages the user goes through
- Touchpoints (where they interact with the system)
- Pain points (🔴) and bright spots (🟢)
- Emotional journey (if useful)

Layer 2: Service Delivery (middle)
- Staff actions at each stage
- Handoffs between teams
- Decision points
- Time/wait periods

Layer 3: Technology (bottom)
- Systems involved
- Data flows
- Integration points
- Known issues (⚠️)

Annotations:
- Constraints from Ground phase
- Research findings
- Opportunities identified
```

### System Map Checklist

- [ ] All user touchpoints identified
- [ ] All systems labeled
- [ ] Handoffs and wait times marked
- [ ] Pain points highlighted
- [ ] Technical constraints noted
- [ ] Reviewed with Builder for accuracy
- [ ] Exported to project assets folder

---

## Output 3: Risk/Impact Register

### Purpose
Document what could go wrong and who would be affected.

### Template

```markdown
# Risk/Impact Register

**Project:** [Project Name]
**Date:** [Date]
**Prepared by:** [Name]

---

## Current State Risks

Risks that exist today, before any changes.

| Risk | Description | Likelihood | Impact | Who's Affected | Evidence |
|------|-------------|------------|--------|----------------|----------|
| [Risk name] | [What could go wrong] | High/Med/Low | High/Med/Low | [User groups] | [What we heard/saw] |

---

## Change Risks

Risks introduced by making changes to the system.

| Risk | Description | Likelihood | Impact | Who's Affected | Mitigation |
|------|-------------|------------|--------|----------------|------------|
| [Risk name] | [What could go wrong] | High/Med/Low | High/Med/Low | [User groups] | [How to reduce risk] |

---

## Equity Risks

Risks that changes could worsen disparities or exclude populations.

| Risk | Population Affected | Current State | Potential Impact | Mitigation |
|------|---------------------|---------------|------------------|------------|
| [Risk name] | [Group] | [How they're served now] | [How change could harm] | [How to prevent] |

---

## Dependencies

External factors that could affect success.

| Dependency | Owner | Status | Risk if Unavailable |
|------------|-------|--------|---------------------|
| [System/resource/decision] | [Who controls it] | [Current status] | [What happens without it] |

---

## Recommendations

Based on this analysis:

1. **Must address:** [Risks that block progress]
2. **Should address:** [Risks that increase likelihood of failure]
3. **Monitor:** [Risks to watch but not immediately act on]
```

---

## Sense Phase Checklist

### Research Complete
- [ ] Research questions defined (tied to decisions)
- [ ] User segments identified
- [ ] 5-8 users interviewed per key segment
- [ ] Observations/contextual inquiry conducted (if applicable)
- [ ] Daily debriefs captured insights

### Synthesis Complete
- [ ] Affinity mapping done
- [ ] Journey map created (FigJam)
- [ ] System map created (FigJam)
- [ ] Findings documented
- [ ] Risk/impact register drafted

### Deliverables Complete
- [ ] Research findings document drafted
- [ ] System map exported and archived
- [ ] Risk/impact register drafted
- [ ] Internal review completed
- [ ] Revisions incorporated

### Client Alignment
- [ ] Findings presented to client
- [ ] Client feedback incorporated
- [ ] Agreement on key insights
- [ ] Sign-off to proceed to Shape

---

## Common Sense Phase Mistakes

| Mistake | Why It Happens | How to Avoid |
|---------|----------------|--------------|
| Too many interviews | "More data = better" | Define decision first, then minimum sample |
| Research without synthesis | Ran out of time | Block synthesis time before research starts |
| Insights without implications | Stopped at "users said..." | Force every finding to answer "so what?" |
| Ignoring edge cases | Focus on "typical" users | Explicitly recruit users who struggle |
| Beautiful journey map, no action | Design theater | Map only what informs decisions |
| Skipping equity analysis | Uncomfortable or unfamiliar | Build it into research plan from start |

---

## Transitioning to Shape

Sense is complete when:

1. **Users are understood** — You can describe key segments, their needs, their pain points
2. **System is mapped** — You know how it works, where it breaks, what constrains change
3. **Risks are identified** — You know what could go wrong and for whom
4. **Team is aligned** — Everyone shares the same understanding
5. **Direction is emerging** — Findings point toward solution directions

**Next phase:** Shape — Design viable pathways, not endless concepts.

---

*This guide is part of the Public Impact Method. See methodology/overview.md for the full framework.*
