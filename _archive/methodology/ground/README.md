# Ground Phase

*Establish legitimacy and constraints before proposing solutions.*

---

## Purpose

Most projects fail before they start—by ignoring political reality, prior attempts, or who actually has decision authority. Ground prevents that.

This phase answers: **What's actually true here, and who needs to be on board?**

---

## At a Glance

| | |
|---|---|
| **Duration** | 2-3 weeks |
| **Primary Owner** | UX Strategist |
| **Key Activities** | Stakeholder interviews, constraint mapping, problem framing |
| **Outputs** | Stakeholder snapshot, Constraint map, Problem statement |
| **Exit Criteria** | Client agrees this is the right problem to solve |

---

## Who Does What

| Role | Ground Phase Responsibilities |
|------|------------------------------|
| **Project Lead** | Manages client relationship, removes blockers, signs off on deliverables |
| **UX Strategist** | Leads research, conducts interviews, synthesizes findings, drafts deliverables |
| **UX/UI Designer** | Audits existing experience, documents current-state pain points |
| **Builder** | Technical discovery, assesses existing systems, identifies constraints |

---

## Week-by-Week Activities

### Week 1: Listen

**Goal:** Gather perspectives from people who matter.

| Day | Activity | Owner |
|-----|----------|-------|
| 1-2 | Identify stakeholders to interview (5-8 people) | UX Strategist |
| 2-3 | Schedule interviews | Project Lead |
| 3-5 | Conduct stakeholder interviews (45-60 min each) | UX Strategist |
| 3-5 | Technical discovery: review systems, APIs, data | Builder |
| 5 | Current-state UX audit (if applicable) | UX/UI Designer |

### Week 2: Synthesize

**Goal:** Turn raw input into structured understanding.

| Day | Activity | Owner |
|-----|----------|-------|
| 1-2 | Debrief interviews, identify patterns | UX Strategist |
| 2-3 | Draft stakeholder alignment snapshot | UX Strategist |
| 2-3 | Draft constraint and opportunity map | UX Strategist + Builder |
| 3-4 | Internal review of drafts | All |
| 4-5 | Refine based on team input | UX Strategist |

### Week 3: Align

**Goal:** Get client agreement on problem framing.

| Day | Activity | Owner |
|-----|----------|-------|
| 1-2 | Draft problem statement | UX Strategist |
| 2-3 | Internal review and refinement | All |
| 3-4 | Present findings to client | Project Lead + UX Strategist |
| 4-5 | Incorporate feedback, finalize deliverables | UX Strategist |
| 5 | Client sign-off on problem framing | Project Lead |

---

## Stakeholder Interviews

### Who to Interview

Aim for 5-8 interviews across these categories:

| Category | Why They Matter | Example |
|----------|-----------------|---------|
| **Decision Makers** | Can approve or kill the project | Program director, division chief |
| **Day-to-Day Operators** | Will use or maintain the solution | Case workers, IT staff |
| **Subject Matter Experts** | Understand the domain deeply | Policy analysts, technical leads |
| **Skeptics** | Know why past efforts failed | Long-tenured staff, union reps |
| **Beneficiaries** | Experience the problem directly | End users, field staff |

### Interview Structure (45-60 min)

| Time | Focus | Purpose |
|------|-------|---------|
| 5 min | Intro | Build rapport, explain purpose |
| 15 min | Their world | Understand their role and context |
| 20 min | The problem | Their view of what's broken and why |
| 10 min | Constraints | What limits solutions? What's been tried? |
| 5 min | Close | Who else should we talk to? |

### Ground Phase Interview Questions

#### Opening (5 min)
- Tell me about your role. What does a typical day/week look like?
- How long have you been in this role? This organization?

#### Their World (15 min)
- What are you ultimately trying to accomplish in your work?
- What does success look like for your team/division?
- Who do you depend on to get your work done?
- Who depends on you?

#### The Problem (20 min)
- In your view, what's the core problem we're trying to solve?
- How does this problem affect your work day-to-day?
- When did this become a problem? What changed?
- What would be different if this problem were solved?
- On a scale of 1-10, how urgent is solving this? Why that number?

#### Constraints (10 min)
- What's been tried before to address this?
- Why didn't those attempts work?
- What would make a solution fail here?
- Are there policies, regulations, or budget realities we need to know about?
- Who would need to approve any changes?

#### Close (5 min)
- What's the one thing you wish outside teams understood about this?
- Who else should we talk to?
- Anything I didn't ask that I should have?

---

## Output 1: Stakeholder Alignment Snapshot

### Purpose
Document who matters, what they want, and how aligned they are.

### Template

```markdown
# Stakeholder Alignment Snapshot

**Project:** [Project Name]
**Date:** [Date]
**Prepared by:** [Name]

---

## Key Stakeholders

| Name | Role | Interest | Influence | Position | Notes |
|------|------|----------|-----------|----------|-------|
| [Name] | [Title] | [What they care about] | High/Med/Low | Champion/Supporter/Neutral/Skeptic | [Key insight] |

---

## Alignment Summary

### Champions (Actively support)
- [Name]: [Why they support, what they bring]

### Supporters (Generally positive)
- [Name]: [Why they support, any reservations]

### Neutral (No strong position)
- [Name]: [What would move them to support?]

### Skeptics (Have concerns)
- [Name]: [What are their concerns? Are they valid?]

---

## Decision Authority

| Decision Type | Who Decides | Who Influences | Who Must Be Informed |
|---------------|-------------|----------------|---------------------|
| Project scope changes | | | |
| Budget allocation | | | |
| Technical architecture | | | |
| Go-live approval | | | |

---

## Alignment Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Stakeholder X may block because...] | High/Med/Low | High/Med/Low | [Strategy] |

---

## Recommendations

1. [Who to engage more deeply]
2. [Who to keep informed]
3. [Potential conflicts to monitor]
```

---

## Output 2: Constraint and Opportunity Map

### Purpose
Document what's actually possible given policy, legal, technical, and political realities.

### Template

```markdown
# Constraint and Opportunity Map

**Project:** [Project Name]
**Date:** [Date]
**Prepared by:** [Name]

---

## Constraints

### Policy & Legal
| Constraint | Source | Flexibility | Impact on Solutions |
|------------|--------|-------------|---------------------|
| [e.g., Data must stay on-prem] | [Regulation/Policy name] | None/Some/High | [What this rules out] |

### Technical
| Constraint | Current State | Flexibility | Impact on Solutions |
|------------|---------------|-------------|---------------------|
| [e.g., Legacy system can't be modified] | [Details] | None/Some/High | [What this rules out] |

### Budget & Resources
| Constraint | Details | Flexibility | Impact on Solutions |
|------------|---------|-------------|---------------------|
| [e.g., No new FTEs for 18 months] | [Context] | None/Some/High | [What this rules out] |

### Political & Organizational
| Constraint | Details | Flexibility | Impact on Solutions |
|------------|---------|-------------|---------------------|
| [e.g., Division X won't share data with Division Y] | [History] | None/Some/High | [What this rules out] |

### Timeline
| Constraint | Details | Flexibility | Impact on Solutions |
|------------|---------|-------------|---------------------|
| [e.g., Must show results before fiscal year end] | [Date] | None/Some/High | [What this rules out] |

---

## Opportunities

### Existing Assets
| Asset | How It Helps | Owner |
|-------|--------------|-------|
| [e.g., Recent user research from Project X] | [Could inform our work] | [Team/Person] |

### Tailwinds
| Opportunity | Why Now | How to Leverage |
|-------------|---------|-----------------|
| [e.g., New leadership supportive of change] | [Context] | [Strategy] |

### Adjacent Efforts
| Initiative | Overlap | Coordination Needed |
|------------|---------|---------------------|
| [e.g., IT modernization project] | [Shared infrastructure] | [Who to talk to] |

---

## What's Been Tried Before

| Attempt | When | What Happened | Why It Didn't Work | Lessons |
|---------|------|---------------|--------------------| --------|
| [Project/Initiative name] | [Year] | [Outcome] | [Root cause] | [What to do differently] |

---

## Implications for This Project

### Must Do
- [Non-negotiables based on constraints]

### Can't Do
- [Off the table based on constraints]

### Should Explore
- [Opportunities to leverage]

### Watch Out For
- [Risks based on history/politics]
```

---

## Output 3: Problem Statement

### Purpose
Articulate the problem clearly, including the tradeoffs any solution must navigate.

### Template

```markdown
# Problem Statement

**Project:** [Project Name]
**Date:** [Date]
**Version:** [Draft/Final]

---

## The Problem

[2-3 sentences describing the core problem in plain language. Focus on impact, not symptoms.]

**Example:** *Veterans applying for disability benefits wait an average of 6 months for a decision. During this time, they have no visibility into their claim status, leading to anxiety, repeated calls to support lines, and loss of trust in the VA.*

---

## Who Is Affected

| Group | How They're Affected | Scale |
|-------|---------------------|-------|
| [e.g., Veterans] | [Impact on them] | [# of people] |
| [e.g., Claims processors] | [Impact on them] | [# of people] |

---

## Why It Matters Now

[What's changed that makes this urgent? New leadership? Budget cycle? Crisis?]

---

## Root Causes

| Cause | Evidence | Addressable? |
|-------|----------|--------------|
| [e.g., Manual handoffs between systems] | [What we heard/observed] | Yes/Partially/No |

---

## What Success Looks Like

| Outcome | Measure | Target |
|---------|---------|--------|
| [e.g., Reduced wait time] | [Average days to decision] | [From X to Y] |
| [e.g., Improved transparency] | [% of applicants who can see status] | [From X to Y] |

---

## Tradeoffs to Navigate

Any solution will need to balance:

| Tension | Option A | Option B |
|---------|----------|----------|
| [e.g., Speed vs. Accuracy] | [Faster decisions, more errors] | [Slower decisions, fewer errors] |
| [e.g., Automation vs. Human touch] | [Efficient but impersonal] | [Personal but expensive] |

**Our recommendation:** [Which tradeoff to prioritize and why]

---

## Scope Boundaries

### In Scope
- [What this project will address]

### Out of Scope
- [What this project will NOT address, and why]

### Dependencies
- [What must be true for this project to succeed]

---

## Agreement

By signing below, stakeholders confirm:
1. This problem statement accurately reflects the challenge
2. The scope boundaries are appropriate
3. We are ready to move to the Sense phase

| Name | Role | Date |
|------|------|------|
| | | |
| | | |
```

---

## Ground Phase Checklist

### Research Complete
- [ ] 5-8 stakeholder interviews conducted
- [ ] Technical discovery completed
- [ ] Current-state UX audit completed (if applicable)
- [ ] Prior attempts documented

### Deliverables Complete
- [ ] Stakeholder alignment snapshot drafted
- [ ] Constraint and opportunity map drafted
- [ ] Problem statement drafted
- [ ] Internal team review completed
- [ ] Revisions incorporated

### Client Alignment
- [ ] Findings presented to client
- [ ] Client feedback incorporated
- [ ] Problem statement agreed upon
- [ ] Sign-off received to proceed to Sense

---

## Common Ground Phase Mistakes

| Mistake | Why It Happens | How to Avoid |
|---------|----------------|--------------|
| Skipping skeptics | Feels uncomfortable | They have the most valuable information |
| Accepting first answer | Time pressure | Always ask "why?" at least twice |
| Assuming constraints are fixed | Stated as facts | Ask "has anyone tried to change this?" |
| Moving to solutions too fast | Client pressure | Hold the line—Ground is about understanding |
| Overcomplicating deliverables | Want to impress | Simple and clear beats comprehensive and dense |

---

## Transitioning to Sense

Ground is complete when:

1. **Stakeholders are mapped** — You know who matters and where they stand
2. **Constraints are documented** — You know what's actually possible
3. **Problem is framed** — Client agrees this is the right problem
4. **Trust is established** — Client sees you understand their world

**Next phase:** Sense — Develop shared understanding of users and systems.

---

*This guide is part of the Public Impact Method. See methodology/overview.md for the full framework.*
