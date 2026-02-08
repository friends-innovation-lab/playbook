# Getting Started Guide

*What happens from contract signed to project underway.*

> **First time?** Complete [First-Time Setup](first-time-setup.md) before continuing.

---

## Overview

You've won the project. The contract is signed. Now what?

This guide covers the first 30 days — from internal prep through the end of the Ground phase. It defines who does what and when.

Before starting, read [Project Operations](../operations/README.md) to understand our tools and workflows.

---

## The Four Roles

These are hats, not people. One person may wear multiple hats.

| Role | Responsibility |
|------|----------------|
| **Project Lead** | Client relationship, decisions, accountable for outcomes |
| **UX Strategist** | Discovery, research, systems thinking, shapes the "what" |
| **UX/UI Designer** | Visual design, interaction design, prototypes |
| **Builder** | Code, deployment, technical implementation |

---

## The First 30 Days

```
Contract     Internal        Kickoff        Ground Phase
Signed       Prep            Meeting        Begins
  │          (10 days)          │           (2-3 weeks)
  ▼              ▼              ▼               ▼
Day 0        Days 1-10        Day 10        Days 11-30
```

---

## Phase 0: Internal Prep (Days 1-10)

This happens before the client kickoff. Use this time to get smart, get set up, and get aligned.

### Days 1-2: Orientation

**Project Lead:**
- [ ] Read the full SOW — highlight deliverables, timeline, assumptions
- [ ] Identify unknowns and questions for kickoff
- [ ] Create project folder in shared drive
- [ ] Schedule internal prep meeting (Day 7-8)
- [ ] Draft kickoff meeting invite (hold for client confirmation)

**UX Strategist:**
- [ ] Read the SOW — focus on problem statement and constraints
- [ ] Start background research list (prior attempts, related initiatives, key stakeholders)
- [ ] Note initial hypotheses about root causes

**Builder:**
- [ ] Read the SOW — focus on technical requirements and integrations
- [ ] Identify any technical risks or unknowns
- [ ] Plan infrastructure needs

### Days 2-3: Spin Up Infrastructure

**Builder:**
- [ ] Run spinup script: `spinup project-slug "Project Name"` (add `--db` if database needed)
- [ ] Verify deployment at project-slug.lab.cityfriends.tech
- [ ] Set up any additional integrations (auth, APIs, etc.)
- [ ] Update README with project-specific context
- [ ] Share repo access with team

### Days 3-7: Background Research

**UX Strategist:**
- [ ] Research prior attempts at solving this problem
- [ ] Identify key stakeholders and their likely interests
- [ ] Map known constraints (policy, legal, technical, political)
- [ ] Document initial questions for SMEs at kickoff
- [ ] Prepare 1-page "What We Know So Far" brief

**UX/UI Designer:**
- [ ] Review any existing systems or interfaces
- [ ] Screenshot current state (if applicable)
- [ ] Note initial UX observations

### Days 5-7: Kickoff Prep

**Project Lead:**
- [ ] Draft kickoff agenda (see template below)
- [ ] Confirm attendees with client PM
- [ ] Prepare "About Our Approach" slide (PIM overview, 1-2 slides max)
- [ ] Draft working rhythm proposal (meeting cadence, communication channels)

**UX Strategist:**
- [ ] Finalize "What We Know So Far" brief
- [ ] Prepare 3-5 open questions for kickoff discussion
- [ ] Draft initial stakeholder map (to validate at kickoff)

### Days 7-10: Internal Alignment

**All Roles — Internal Prep Meeting (60-90 min):**
- [ ] Walk through SOW together
- [ ] Review "What We Know So Far"
- [ ] Discuss risks and unknowns
- [ ] Align on kickoff roles (who presents what)
- [ ] Confirm technical setup is complete
- [ ] Finalize kickoff materials

---

## Kickoff Meeting (Day 10)

### Purpose

Get everyone aligned on what success looks like, how you'll work together, and what happens next.

### Who's in the Room

**Client Side:**
- Project sponsor / leadership
- Project manager (your day-to-day contact)
- Subject matter experts

**Our Side:**
- Project Lead (facilitates)
- UX Strategist (captures insights, asks research questions)
- Builder (as needed for technical discussion)

### Agenda (90 minutes)

| Time | Topic | Who Leads | Purpose |
|------|-------|-----------|---------|
| 10 min | Introductions | Project Lead | Names, roles, decision authority |
| 10 min | Our approach | Project Lead | Brief PIM/BUILD overview (1-2 slides max) |
| 15 min | SOW walkthrough | Project Lead | Confirm shared understanding of scope |
| 20 min | Success criteria | Project Lead | What does "done well" look like for them? |
| 20 min | Constraints + context | UX Strategist | What should we know that's not written down? |
| 10 min | Working rhythm | Project Lead | Meetings, check-ins, communication |
| 5 min | Next steps | Project Lead | What happens in the next 2 weeks |

### Kickoff Questions to Ask

**For Leadership:**
- What does success look like for you personally?
- What's the biggest risk you see?
- What's been tried before?

**For the PM:**
- Who else should we talk to?
- What's the approval process for decisions?
- How do you prefer to communicate?

**For SMEs:**
- What do you wish outsiders understood about this problem?
- Where do things break down today?
- What would make your job easier?

### Capture During Kickoff

**UX Strategist — document these:**
- Stated success criteria
- Constraints mentioned (policy, budget, timeline, political)
- Stakeholders named (add to stakeholder map)
- Prior attempts referenced
- Risks or concerns raised
- Open questions to follow up on

---

## Post-Kickoff: Entering Ground Phase (Days 11-30)

After kickoff, you're officially in the **Ground** phase of PIM.

### Ground Phase Goal

Establish legitimacy and constraints before proposing solutions.

### Week 1 Post-Kickoff (Days 11-17)

**Project Lead:**
- [ ] Send kickoff summary email to client within 24 hours
- [ ] Schedule recurring check-ins (weekly or biweekly)
- [ ] Set up project communication channel (Slack, Teams, etc.)

**UX Strategist:**
- [ ] Finalize stakeholder map based on kickoff
- [ ] Schedule stakeholder interviews (3-5 conversations)
- [ ] Begin constraint and opportunity mapping
- [ ] Document "what's been tried before" with outcomes

**Builder:**
- [ ] Technical discovery — review existing systems, APIs, data
- [ ] Document technical constraints
- [ ] Set up development environment for prototyping

**UX/UI Designer:**
- [ ] Audit existing user experience (if applicable)
- [ ] Begin documenting user pain points
- [ ] Start collecting visual references and patterns

### Week 2-3 Post-Kickoff (Days 18-30)

**UX Strategist:**
- [ ] Complete stakeholder interviews
- [ ] Synthesize findings into constraint/opportunity map
- [ ] Draft problem statement with named tradeoffs
- [ ] Prepare Ground phase deliverables for client review

**Project Lead:**
- [ ] Mid-phase check-in with client
- [ ] Review draft deliverables with team
- [ ] Prepare for Ground → Sense transition

**Builder:**
- [ ] Complete technical assessment
- [ ] Identify integration requirements
- [ ] Document technical risks and dependencies

### Ground Phase Outputs

Before moving to Sense, you should have:

- [ ] **Stakeholder alignment snapshot** — who matters, what they want, who decides
- [ ] **Constraint and opportunity map** — policy, legal, technical, political realities
- [ ] **Problem statement** — clear articulation that names tradeoffs
- [ ] **Technical assessment** — systems, integrations, data considerations
- [ ] **Client sign-off** — they agree this is the right problem to solve

---

## Role Responsibilities by Phase (Summary)

| Phase | Project Lead | UX Strategist | UX/UI Designer | Builder |
|-------|--------------|---------------|----------------|---------|
| **Ground** | Client alignment, risk management | Stakeholder research, constraint mapping | UX audit, pain points | Technical discovery |
| **Sense** | Decision facilitation | User research, systems mapping | Journey maps, personas | Data analysis, feastic |
| **Shape** | Option review, recommendation | Solution framing, tradeoffs | Wireframes, concepts | Technical feasibility |
| **Test** | Go/no-go decisions | Pilot design, feedback synthesis | UI implementation | Build prototype |
| **Embed** | Handoff management | Knowledge transfer, documentation | Design system handoff | Deployment, training |

*Detailed phase guides coming in methodology/[phase] folders.*

---

## Quick Reference

### Spinup Command
```bash
spinup project-slug "Project Name"         # No database
spinup project-slug "Project Name" --db    # With Supabase database
```

### Project URL Pattern
```
https://project-slug.lab.cityfriends.tech
```

### Key Folders
```
playbook/
├── methodology/     # PIM phases and templates
├── operations/      # Sales, contracts, automation, dev standards
├── products/        # TrueBid, etc.
└── templates/       # Reusable templates
```

### How We Work
- [Project Operations](../operations/README.md) — Tools, task tracking, file structure

### Communication Rhythm (Default)

| Cadence | Meeting | Attendees | Purpose |
|---------|---------|-----------|---------|
| Weekly | Client check-in | Project Lead + Client PM | Status, blockers, decisions |
| Weekly | Internal sync | All team | Coordination, planning |
| End of phase | Phase review | All + Client stakeholders | Present deliverables, get sign-off |

---

## Checklist: First 30 Days

### Internal Prep (Days 1-10)
- [ ] SOW reviewed by all team members
- [ ] Infrastructure spun up and tested
- [ ] Background research completed
- [ ] Kickoff materials prepared
- [ ] Internal alignment meeting held

### Kickoff (Day 10)
- [ ] All key stakeholders attended
- [ ] Success criteria captured
- [ ] Constraints and context documented
- [ ] Working rhythm agreed
- [ ] Next steps clear

### Ground Phase (Days 11-30)
- [ ] Stakeholder interviews completed
- [ ] Constraint/opportunity map drafted
- [ ] Problem statement articulated
- [ ] Technical assessment complete
- [ ] Client sign-off on problem framing

---

*This guide gets you through the first 30 days. For detailed phase guidance, see the methodology folder.*
