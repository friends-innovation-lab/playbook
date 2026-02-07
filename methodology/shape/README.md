# Shape Phase

*Design viable pathways, not endless concepts.*

---

## Purpose

You understand the constraints (Ground) and the users (Sense). Now design solutions that can actually work here — not blue-sky ideas that ignore reality.

This phase answers: **What are our options, and which one should we pursue?**

---

## At a Glance

| | |
|---|---|
| **Duration** | 2-3 weeks |
| **Primary Owner** | UX Strategist + Designer |
| **Key Activities** | Ideation, concept development, tradeoff analysis, recommendation |
| **Outputs** | Solution options (2-3), Tradeoff analysis, Recommendation brief |
| **Exit Criteria** | Client selects a path forward |

---

## Who Does What

| Role | Shape Phase Responsibilities |
|------|------------------------------|
| **Project Lead** | Facilitates decision-making, manages client through options |
| **UX Strategist** | Frames options, maps tradeoffs, drafts recommendation |
| **UX/UI Designer** | Creates concepts, prototypes, visualizes solutions |
| **Builder** | Assesses feasibility, estimates effort, identifies technical risks |

---

## Key Principle: Bounded Ideation

Creativity within constraints. The goal isn't the most innovative idea — it's the best idea that can actually survive here.

| ❌ Unbounded Ideation | ✅ Bounded Ideation |
|----------------------|---------------------|
| "What if we reimagined everything?" | "Given our constraints, what's possible?" |
| 50 sticky notes, no filter | 3 viable paths, deeply developed |
| "The sky's the limit" | "Here's what's realistic in 6 months" |
| Ignore politics and policy | Design around them |

Before ideating: **Review Ground phase constraints. They're not obstacles — they're design requirements.**

---

## Week-by-Week Activities

### Week 1: Generate Options

**Goal:** Develop 3-5 candidate solutions.

| Day | Activity | Owner |
|-----|----------|-------|
| 1 | Review Sense findings + Ground constraints | All |
| 1-2 | Ideation session: generate concepts | UX Strategist + Designer |
| 2-3 | Cluster concepts into distinct approaches | UX Strategist |
| 3-4 | Builder feasibility check on each approach | Builder |
| 4-5 | Narrow to 2-3 viable options | All |

### Week 2: Develop & Evaluate

**Goal:** Flesh out options, understand tradeoffs.

| Day | Activity | Owner |
|-----|----------|-------|
| 1-2 | Develop each option: what it is, how it works | Designer + UX Strategist |
| 2-3 | Create low-fidelity prototypes/mockups | Designer |
| 3-4 | Technical feasibility assessment per option | Builder |
| 4-5 | Map tradeoffs across options | UX Strategist |
| 5 | Internal review | All |

### Week 3: Recommend & Align

**Goal:** Make a recommendation, get client decision.

| Day | Activity | Owner |
|-----|----------|-------|
| 1-2 | Draft recommendation brief | UX Strategist |
| 2-3 | Refine prototypes for presentation | Designer |
| 3 | Internal rehearsal | All |
| 4 | Present options to client | Project Lead + UX Strategist |
| 5 | Client decision + sign-off | Project Lead |

---

## Ideation Session

### Setup

| Item | Details |
|------|---------|
| **Duration** | 2-3 hours |
| **Attendees** | Full project team (optionally include client) |
| **Materials** | FigJam board, Sense findings, Ground constraints |
| **Pre-work** | Everyone reviews research findings |

### Session Structure

#### Part 1: Reframe the Problem (20 min)
- Review problem statement from Ground
- Review key findings from Sense
- Articulate: "How might we [solve X] for [user] given [constraints]?"

#### Part 2: Diverge (45 min)
- Individual brainstorming: 10 min silent generation
- Share and build: each person presents, others riff
- No judging yet — volume matters
- Prompt: "What are all the ways we could address this?"

#### Part 3: Cluster (30 min)
- Group similar ideas
- Name each cluster (these become candidate approaches)
- Identify 4-6 distinct directions

#### Part 4: Converge (45 min)
- Evaluate clusters against criteria:
  - Addresses user needs (from Sense)
  - Fits within constraints (from Ground)
  - Technically feasible (Builder gut check)
  - Achievable in timeline
- Vote or discuss to narrow to 3-4 options

#### Part 5: Next Steps (10 min)
- Assign owners to develop each option
- Schedule feasibility check with Builder

### "How Might We" Prompts

Generate HMW questions from Sense findings:

| Finding | HMW Question |
|---------|--------------|
| Users don't know their application status | HMW give users visibility without adding staff burden? |
| Staff spend 40% of time on data entry | HMW reduce manual data entry while maintaining accuracy? |
| Edge cases get stuck for weeks | HMW handle exceptions without slowing standard cases? |

---

## Developing Options

### What Each Option Needs

| Component | Description |
|-----------|-------------|
| **Name** | Short, memorable label |
| **Summary** | 2-3 sentences: what is this approach? |
| **How it works** | Key features/changes |
| **User experience** | What changes for users? |
| **Operational impact** | What changes for staff? |
| **Technical approach** | High-level architecture |
| **Effort estimate** | T-shirt size: S/M/L/XL |
| **Timeline** | Rough implementation time |
| **Risks** | What could go wrong? |
| **Tradeoffs** | What does this prioritize? What does it sacrifice? |

### Option Development Template

```markdown
## Option [A/B/C]: [Name]

### Summary
[2-3 sentences describing the approach]

### How It Works
- [Key feature/change 1]
- [Key feature/change 2]
- [Key feature/change 3]

### User Experience
**Before:** [Current state]
**After:** [Future state with this option]

### Operational Impact
- [Change for staff 1]
- [Change for staff 2]

### Technical Approach
- [Architecture/integration approach]
- [Key technical decisions]
- [Dependencies]

### Effort & Timeline
| | |
|---|---|
| Effort | [S/M/L/XL] |
| Timeline | [X weeks/months] |
| Team needed | [Roles/skills] |

### Risks
| Risk | Likelihood | Mitigation |
|------|------------|------------|
| [Risk 1] | High/Med/Low | [How to address] |

### Tradeoffs
**Prioritizes:** [What this option optimizes for]
**Sacrifices:** [What you give up]
```

---

## Feasibility Assessment

The Builder assesses each option to determine what's realistic. This takes 1-2 hours per option.

### Step 1: Answer These Questions

| Question | How to Answer |
|----------|---------------|
| Can we build with current stack? | Review option requirements against your tech (Next.js, Supabase, Vercel) |
| New systems/integrations needed? | List external APIs, databases, services required |
| Data migration complexity? | Identify what data moves, from where, in what format |
| Security/compliance concerns? | Check against client's requirements (FedRAMP, ATO, PII handling) |
| Realistic build timeline? | Break into tasks, estimate each, add 20% buffer |
| Skills needed? | List roles/expertise — do we have them or need to hire/contract? |
| Maintenance burden? | What needs ongoing attention after launch? |
| What could go wrong? | Technical risks, dependencies, unknowns |

### Step 2: Rate Each Option

| Rating | Criteria |
|--------|----------|
| 🟢 **High Feasibility** | Uses known tech, no new integrations, team has skills, <4 weeks build |
| 🟡 **Medium Feasibility** | Some unknowns, 1-2 new integrations, may need support, 4-8 weeks |
| 🔴 **Low Feasibility** | Significant unknowns, complex integrations, missing skills, 8+ weeks or uncertain |

### Step 3: Document Each Option

```markdown
## Feasibility Assessment: Option [A/B/C]

**Assessed by:** [Builder name]
**Date:** [Date]

### Overall Rating: 🟢/🟡/🔴

### Technical Approach
[2-3 sentences: How would we build this?]

### Stack Fit
| Component | Our Stack | Fit | Notes |
|-----------|-----------|-----|-------|
| Frontend | Next.js | ✅/⚠️/❌ | |
| Backend | Supabase | ✅/⚠️/❌ | |
| Hosting | Vercel | ✅/⚠️/❌ | |
| Auth | [TBD] | ✅/⚠️/❌ | |

### Integrations Required
| System | Purpose | Complexity | Risk |
|--------|---------|------------|------|
| [System] | [Why needed] | Low/Med/High | [What could go wrong] |

### Data Considerations
- **Data sources:** [Where data comes from]
- **Migration needed:** Yes/No — [Details]
- **PII/sensitive data:** Yes/No — [Implications]

### Build Estimate
| Component | Effort | Notes |
|-----------|--------|-------|
| [Component 1] | [X days] | |
| [Component 2] | [X days] | |
| Integration/testing | [X days] | |
| Buffer (20%) | [X days] | |
| **Total** | **[X days]** | |

### Skills Required
| Skill | Have It? | Gap Plan |
|-------|----------|----------|
| [Skill] | Yes/No | [Hire/Learn/Contract] |

### Risks
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk] | H/M/L | H/M/L | [Plan] |

### Dependencies
| Dependency | Owner | Status | Risk if Unavailable |
|------------|-------|--------|---------------------|
| [API access, data, decision] | [Who] | [Status] | [Impact] |

### Recommendation
[1-2 sentences: Should we pursue this option? Any conditions?]
```

### Step 4: Compare Options

| Question | Option A | Option B | Option C |
|----------|----------|----------|----------|
| **Overall Rating** | 🟢/🟡/🔴 | 🟢/🟡/🔴 | 🟢/🟡/🔴 |
| Build timeline | [X weeks] | [X weeks] | [X weeks] |
| New integrations | [Count] | [Count] | [Count] |
| Skill gaps | [Count] | [Count] | [Count] |
| Top risk | [Risk] | [Risk] | [Risk] |

---

## Tradeoff Analysis

### Purpose
Make tradeoffs explicit so client can make an informed decision.

### Common Tradeoffs in Government Projects

| Tension | Option A Leans | Option B Leans |
|---------|----------------|----------------|
| **Speed vs. Thoroughness** | Ship fast, iterate | Get it right first time |
| **Automation vs. Human touch** | Efficient, scalable | Personal, flexible |
| **Centralized vs. Distributed** | Consistent, controlled | Empowered, adaptable |
| **Build vs. Buy** | Custom fit, ownership | Faster, proven, vendor risk |
| **Big bang vs. Incremental** | One transition | Many small changes |
| **User needs vs. Staff needs** | Optimizes for public | Optimizes for operations |

### Tradeoff Matrix Template

| Criteria | Weight | Option A | Option B | Option C |
|----------|--------|----------|----------|----------|
| Addresses user pain points | High | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| Fits within constraints | High | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| Technical feasibility | High | ⭐⭐⭐ | ⭐⭐ | ⭐ |
| Implementation speed | Med | ⭐⭐ | ⭐⭐⭐ | ⭐ |
| Operational sustainability | Med | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| Cost | Med | ⭐⭐ | ⭐⭐⭐ | ⭐ |
| Risk level | High | ⭐⭐ | ⭐⭐⭐ | ⭐ |

---

## Prototyping

### Purpose
Make options tangible so stakeholders can react to something real.

### Prototype Fidelity by Purpose

| Purpose | Fidelity | Format |
|---------|----------|--------|
| Internal alignment | Low | Sketches, FigJam wireframes |
| Client feedback on concepts | Low-Medium | Clickable Figma wireframes |
| Usability testing | Medium | Interactive Figma prototype |
| Stakeholder buy-in | Medium-High | Polished Figma prototype |
| Technical proof of concept | Varies | Working code (limited scope) |

### What to Prototype

Focus prototypes on:
- The most uncertain parts of the solution
- The parts stakeholders need to see to decide
- The user-facing changes

Don't prototype:
- Everything
- Backend systems (describe them instead)
- Things everyone already agrees on

### Prototype Checklist

- [ ] Shows key user flows
- [ ] Reflects real content (not lorem ipsum)
- [ ] Demonstrates differentiation between options
- [ ] Testable with users (if time allows)
- [ ] Presentable to client

---

## Output 1: Solution Options

### Purpose
Document 2-3 viable approaches for client decision.

### Template

```markdown
# Solution Options

**Project:** [Project Name]
**Date:** [Date]
**Prepared by:** [Name]

---

## Context

### Problem We're Solving
[Brief restatement from Ground]

### Key Findings Informing Solutions
[Top 3-5 findings from Sense that shaped these options]

### Design Constraints
[Key constraints from Ground that all options must respect]

---

## Option A: [Name]

### Summary
[2-3 sentences]

### How It Works
[Key features/changes]

### Prototype
[Link to Figma or embedded images]

### Pros
- [Pro 1]
- [Pro 2]

### Cons
- [Con 1]
- [Con 2]

### Effort: [S/M/L/XL] | Timeline: [X weeks/months]

---

## Option B: [Name]

[Same structure]

---

## Option C: [Name]

[Same structure]

---

## Comparison

| Criteria | Option A | Option B | Option C |
|----------|----------|----------|----------|
| User impact | | | |
| Feasibility | | | |
| Timeline | | | |
| Cost | | | |
| Risk | | | |

---

## Our Recommendation

**We recommend Option [X] because:**

1. [Reason 1 — tied to findings/constraints]
2. [Reason 2]
3. [Reason 3]

**Key risks to manage:**
- [Risk 1 and mitigation]
- [Risk 2 and mitigation]

**Next steps if approved:**
1. [Immediate next step]
2. [Following step]
```

---

## Output 2: Recommendation Brief

### Purpose
One-page summary for decision-makers who won't read the full document.

### Template

```markdown
# Recommendation Brief

**Project:** [Project Name]
**Date:** [Date]
**Decision needed by:** [Date]

---

## The Ask

We recommend proceeding with **[Option Name]** and request approval to move to pilot/build.

---

## Why This Option

| What We Learned | How This Option Responds |
|-----------------|--------------------------|
| [Key finding 1] | [How option addresses it] |
| [Key finding 2] | [How option addresses it] |
| [Key constraint] | [How option respects it] |

---

## What This Means

| | |
|---|---|
| **For users** | [Primary change/benefit] |
| **For staff** | [Primary change/impact] |
| **Timeline** | [Implementation estimate] |
| **Investment** | [Effort/cost summary] |

---

## Risks & Mitigations

| Risk | How We'll Address It |
|------|---------------------|
| [Top risk 1] | [Mitigation] |
| [Top risk 2] | [Mitigation] |

---

## Alternatives Considered

| Option | Why Not |
|--------|---------|
| [Option B] | [Brief reason] |
| [Option C] | [Brief reason] |

---

## Decision

☐ Approve recommendation — proceed with [Option Name]
☐ Request changes: ________________________________
☐ Select alternative: ________________________________
☐ Need more information: ________________________________

**Approved by:** _________________ **Date:** _________
```

---

## Client Presentation

### Presentation Structure (60-90 min)

| Time | Section | Purpose |
|------|---------|---------|
| 5 min | Context | Remind them of problem and what we learned |
| 10 min | Approach | How we developed options |
| 30 min | Options | Walk through each option with prototypes |
| 15 min | Comparison | Tradeoffs and our analysis |
| 10 min | Recommendation | What we suggest and why |
| 20 min | Discussion | Questions, concerns, decision |

### Presentation Tips

- **Lead with the recommendation** if you know they want direction
- **Lead with options** if they want to feel in control of the decision
- **Show prototypes live** — don't just screenshot
- **Anticipate objections** — address them before they're raised
- **Name the tradeoffs** — don't pretend there's a perfect option
- **Make the decision easy** — be clear about what you're asking

---

## Shape Phase Checklist

### Ideation Complete
- [ ] Ideation session conducted
- [ ] Concepts clustered into distinct approaches
- [ ] Builder feasibility check completed
- [ ] Narrowed to 2-3 viable options

### Options Developed
- [ ] Each option fully documented
- [ ] Prototypes created for each option
- [ ] Technical feasibility assessed
- [ ] Effort and timeline estimated
- [ ] Tradeoffs mapped

### Deliverables Complete
- [ ] Solution options document drafted
- [ ] Recommendation brief drafted
- [ ] Prototypes presentation-ready
- [ ] Internal review completed
- [ ] Revisions incorporated

### Client Alignment
- [ ] Options presented to client
- [ ] Client questions addressed
- [ ] Decision made
- [ ] Sign-off to proceed to Test

---

## Common Shape Phase Mistakes

| Mistake | Why It Happens | How to Avoid |
|---------|----------------|--------------|
| Too many options | Afraid to narrow | 3 options max — more creates decision paralysis |
| Options too similar | Didn't push thinking | Force distinctly different approaches |
| Ignoring constraints | "They'll make an exception" | They won't. Design around them |
| Beautiful prototype, infeasible tech | Designer worked alone | Builder involved from day 1 |
| No recommendation | Afraid to have an opinion | Clients hire you to advise — advise |
| Recommendation without rationale | Assumed it's obvious | Connect explicitly to findings |

---

## Transitioning to Test

Shape is complete when:

1. **Options are clear** — 2-3 distinct, viable approaches documented
2. **Tradeoffs are explicit** — Client understands what each option prioritizes
3. **Recommendation is made** — Team has a point of view
4. **Decision is made** — Client selects a path forward
5. **Scope is agreed** — What's in/out for the pilot

**Next phase:** Test — Validate in real conditions, not lab conditions.

---

*This guide is part of the Public Impact Method. See methodology/overview.md for the full framework.*
