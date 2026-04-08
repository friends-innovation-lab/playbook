# Starter Issues

Standard issues created for every project, organized by project stage.

> **Note:** This document contains detailed issue templates for reference. The `spinup.sh` script creates a simplified version of these issues automatically. Use this document when you need to manually create issues or want to understand the full scope of work for each stage.

---

## Labels (Created First)

```bash
# Stage labels (blue)
gh label create "stage:discovery" --color "0052CC" --description "Discovery stage work"
gh label create "stage:research" --color "0052CC" --description "Research stage work"
gh label create "stage:design" --color "0052CC" --description "Design stage work"
gh label create "stage:build" --color "0052CC" --description "Build stage work"
gh label create "stage:handoff" --color "0052CC" --description "Handoff stage work"

# Type labels (green)
gh label create "type:research" --color "0E8A16" --description "Interviews, discovery, analysis"
gh label create "type:deliverable" --color "0E8A16" --description "Client-facing output"
gh label create "type:technical" --color "0E8A16" --description "Code, infrastructure, systems"
gh label create "type:internal" --color "0E8A16" --description "Internal task"

# Status labels (yellow/red)
gh label create "blocked" --color "D93F0B" --description "Waiting on something"
gh label create "needs-review" --color "FBCA04" --description "Ready for internal review"
gh label create "client-review" --color "FBCA04" --description "Waiting on client"
```

---

## Milestones (Created Second)

```bash
gh milestone create "1. Discovery" --description "Establish legitimacy and constraints"
gh milestone create "2. Research" --description "Develop shared understanding of users and systems"
gh milestone create "3. Design" --description "Design viable pathways"
gh milestone create "4. Build" --description "Validate in real conditions"
gh milestone create "5. Handoff" --description "Ensure work lasts beyond the project"
```

---

## Discovery Stage Issues

### G1: Identify stakeholders to interview

```markdown
**Title:** Identify stakeholders to interview

**Labels:** stage:discovery, type:research

**Milestone:** 1. Discovery

**Body:**
## Task
Identify 5-8 stakeholders across these categories:
- Decision makers
- Day-to-day operators
- Subject matter experts
- Skeptics
- Beneficiaries

## Acceptance Criteria
- [ ] List of 5-8 names with roles
- [ ] Category assigned to each
- [ ] Contact info gathered
- [ ] Priority order determined

## Links
- [Getting Started Guide](../../operations/getting-started-guide.md)
```

---

### G2: Schedule stakeholder interviews

```markdown
**Title:** Schedule stakeholder interviews

**Labels:** stage:discovery, type:internal

**Milestone:** 1. Discovery

**Body:**
## Task
Schedule 45-60 minute interviews with identified stakeholders.

## Acceptance Criteria
- [ ] All interviews scheduled
- [ ] Calendar invites sent
- [ ] Interview guide prepared
- [ ] Note-taking template ready

## Links
- [Getting Started Guide](../../operations/getting-started-guide.md)
```

---

### G3: Conduct stakeholder interviews

```markdown
**Title:** Conduct stakeholder interviews

**Labels:** stage:discovery, type:research

**Milestone:** 1. Discovery

**Body:**
## Task
Conduct all scheduled stakeholder interviews. Capture notes in `/notes/interviews/`.

## Acceptance Criteria
- [ ] All interviews completed
- [ ] Notes captured for each interview
- [ ] Key quotes highlighted
- [ ] Follow-up items noted

## Links
- [Getting Started Guide](../../operations/getting-started-guide.md)
```

---

### G4: Technical discovery

```markdown
**Title:** Technical discovery

**Labels:** stage:discovery, type:technical

**Milestone:** 1. Discovery

**Body:**
## Task
Review existing systems, APIs, data, and technical constraints.

## Acceptance Criteria
- [ ] Existing systems documented
- [ ] Integration points identified
- [ ] Technical constraints listed
- [ ] Data sources mapped
- [ ] Access requirements noted

## Links
- [Getting Started Guide](../../operations/getting-started-guide.md)
```

---

### G5: Draft stakeholder alignment snapshot

```markdown
**Title:** Draft stakeholder alignment snapshot

**Labels:** stage:discovery, type:deliverable

**Milestone:** 1. Discovery

**Body:**
## Task
Synthesize interview findings into stakeholder alignment snapshot.

## Acceptance Criteria
- [ ] All stakeholders listed with role/interest/influence
- [ ] Champions, supporters, neutral, skeptics categorized
- [ ] Decision authority mapped
- [ ] Alignment risks identified
- [ ] Internal review completed

## Template
See templates folder for Stakeholder Alignment Snapshot template
```

---

### G6: Draft constraint and opportunity map

```markdown
**Title:** Draft constraint and opportunity map

**Labels:** stage:discovery, type:deliverable

**Milestone:** 1. Discovery

**Body:**
## Task
Document constraints (policy, technical, budget, political, timeline) and opportunities.

## Acceptance Criteria
- [ ] Policy/legal constraints documented
- [ ] Technical constraints documented
- [ ] Budget/resource constraints documented
- [ ] Political/organizational constraints documented
- [ ] Opportunities identified
- [ ] Prior attempts documented
- [ ] Internal review completed

## Template
See templates folder for Constraint and Opportunity Map template
```

---

### G7: Draft problem statement

```markdown
**Title:** Draft problem statement

**Labels:** stage:discovery, type:deliverable

**Milestone:** 1. Discovery

**Body:**
## Task
Articulate the problem clearly, including tradeoffs any solution must navigate.

## Acceptance Criteria
- [ ] Problem described in plain language
- [ ] Affected groups identified with scale
- [ ] Root causes documented
- [ ] Success metrics defined
- [ ] Tradeoffs named
- [ ] Scope boundaries set
- [ ] Internal review completed

## Template
See templates folder for Problem Statement template
```

---

### G8: Discovery stage client sign-off

```markdown
**Title:** Discovery stage client sign-off

**Labels:** stage:discovery, type:internal, client-review

**Milestone:** 1. Discovery

**Body:**
## Task
Present discovery findings to client and get sign-off to proceed to research.

## Acceptance Criteria
- [ ] Findings presented to client
- [ ] Client feedback incorporated
- [ ] Problem statement agreed upon
- [ ] Sign-off received
- [ ] Ready to proceed to research

## Deliverables to Present
- Stakeholder alignment snapshot
- Constraint and opportunity map
- Problem statement
```

---

## Research Stage Issues

### S1: Define research questions

```markdown
**Title:** Define research questions

**Labels:** stage:research, type:research

**Milestone:** 2. Research

**Body:**
## Task
Define research questions tied to specific decisions. No research for research's sake.

## Acceptance Criteria
- [ ] Research questions documented
- [ ] Each question tied to a decision it will inform
- [ ] Methods selected for each question
- [ ] Sample size determined

## Links
- [Operations Guide](../../operations/README.md)
```

---

### S2: Recruit research participants

```markdown
**Title:** Recruit research participants

**Labels:** stage:research, type:research

**Milestone:** 2. Research

**Body:**
## Task
Identify and recruit 5-8 participants per user segment.

## Acceptance Criteria
- [ ] User segments defined
- [ ] Recruitment criteria set
- [ ] Participants recruited (5-8 per segment)
- [ ] Sessions scheduled
- [ ] Incentives arranged (if applicable)

## User Segments to Consider
- Primary users
- Power users
- Edge cases
- Internal users
- Failed users
```

---

### S3: Conduct user research

```markdown
**Title:** Conduct user research

**Labels:** stage:research, type:research

**Milestone:** 2. Research

**Body:**
## Task
Conduct user interviews, observations, or other research methods. Capture notes in `/notes/interviews/`.

## Acceptance Criteria
- [ ] All sessions completed
- [ ] Notes captured for each session
- [ ] Daily debriefs held
- [ ] Key insights flagged
- [ ] Quotes captured

## Links
- [Operations Guide](../../operations/README.md)
```

---

### S4: Create journey map

```markdown
**Title:** Create journey map

**Labels:** stage:research, type:deliverable

**Milestone:** 2. Research

**Body:**
## Task
Map the current user journey in FigJam, including pain points and bright spots.

## Acceptance Criteria
- [ ] All journey stages mapped
- [ ] Touchpoints identified
- [ ] Pain points marked (🔴)
- [ ] Bright spots marked (🟢)
- [ ] Emotional journey captured
- [ ] Exported to `/assets/`

## Links
- [Operations Guide](../../operations/README.md)
```

---

### S5: Create system map

```markdown
**Title:** Create system map

**Labels:** stage:research, type:deliverable, type:technical

**Milestone:** 2. Research

**Body:**
## Task
Map how the current system works: user journey, service delivery, and technology layers.

## Acceptance Criteria
- [ ] User journey layer complete
- [ ] Service delivery layer complete
- [ ] Technology layer complete
- [ ] Handoffs and wait times marked
- [ ] Constraints annotated
- [ ] Reviewed with Builder
- [ ] Exported to `/assets/`

## Links
- [Operations Guide](../../operations/README.md)
```

---

### S6: Draft research findings

```markdown
**Title:** Draft research findings

**Labels:** stage:research, type:deliverable

**Milestone:** 2. Research

**Body:**
## Task
Synthesize research into findings with decision implications.

## Acceptance Criteria
- [ ] Key findings documented (3-5)
- [ ] Each finding has evidence
- [ ] Each finding has decision implication
- [ ] User segments described
- [ ] Journey pain points summarized
- [ ] Equity considerations documented
- [ ] Internal review completed

## Template
See templates folder for Research Findings template
```

---

### S7: Draft risk/impact register

```markdown
**Title:** Draft risk/impact register

**Labels:** stage:research, type:deliverable

**Milestone:** 2. Research

**Body:**
## Task
Document current state risks, change risks, equity risks, and dependencies.

## Acceptance Criteria
- [ ] Current state risks documented
- [ ] Change risks documented
- [ ] Equity risks documented
- [ ] Dependencies identified
- [ ] Mitigations proposed
- [ ] Internal review completed

## Template
See templates folder for Risk/Impact Register template
```

---

### S8: Research stage client sign-off

```markdown
**Title:** Research stage client sign-off

**Labels:** stage:research, type:internal, client-review

**Milestone:** 2. Research

**Body:**
## Task
Present research findings to client and get sign-off to proceed to design.

## Acceptance Criteria
- [ ] Findings presented to client
- [ ] Client feedback incorporated
- [ ] Agreement on key insights
- [ ] Sign-off received
- [ ] Ready to proceed to design

## Deliverables to Present
- Research findings
- Journey map
- System map
- Risk/impact register
```

---

## Design Stage Issues

### SH1: Run ideation session

```markdown
**Title:** Run ideation session

**Labels:** stage:design, type:research

**Milestone:** 3. Design

**Body:**
## Task
Facilitate ideation session to generate solution concepts.

## Acceptance Criteria
- [ ] Session scheduled (2-3 hours)
- [ ] Team reviewed research findings beforehand
- [ ] HMW questions prepared
- [ ] Session facilitated
- [ ] Concepts clustered into approaches
- [ ] Notes captured

## Links
- [Operations Guide](../../operations/README.md)
```

---

### SH2: Develop solution options

```markdown
**Title:** Develop solution options

**Labels:** stage:design, type:deliverable

**Milestone:** 3. Design

**Body:**
## Task
Develop 2-3 viable options from ideation output.

## Acceptance Criteria
- [ ] 2-3 options selected
- [ ] Each option documented (summary, how it works, UX, ops impact)
- [ ] Effort and timeline estimated
- [ ] Risks identified
- [ ] Tradeoffs named

## Template
See templates folder for Option Development template
```

---

### SH3: Feasibility assessment

```markdown
**Title:** Feasibility assessment

**Labels:** stage:design, type:technical

**Milestone:** 3. Design

**Body:**
## Task
Builder assesses technical feasibility of each option.

## Acceptance Criteria
- [ ] Each option assessed (1-2 hours each)
- [ ] Stack fit evaluated
- [ ] Integrations identified
- [ ] Build estimate created
- [ ] Skills gaps identified
- [ ] Risks documented
- [ ] Options compared

## Template
See templates folder for Feasibility Assessment template
```

---

### SH4: Create prototypes

```markdown
**Title:** Create prototypes

**Labels:** stage:design, type:deliverable

**Milestone:** 3. Design

**Body:**
## Task
Create low-to-medium fidelity prototypes for each option in Figma.

## Acceptance Criteria
- [ ] Prototype for each option
- [ ] Key user flows covered
- [ ] Real content (not lorem ipsum)
- [ ] Differentiation between options clear
- [ ] Presentation-ready

## Links
- [Operations Guide](../../operations/README.md)
```

---

### SH5: Tradeoff analysis

```markdown
**Title:** Tradeoff analysis

**Labels:** stage:design, type:deliverable

**Milestone:** 3. Design

**Body:**
## Task
Map tradeoffs across options so client can make informed decision.

## Acceptance Criteria
- [ ] Evaluation criteria defined
- [ ] Each option scored
- [ ] Tradeoffs made explicit
- [ ] Comparison matrix complete

## Template
See templates folder for Tradeoff Analysis template
```

---

### SH6: Draft recommendation

```markdown
**Title:** Draft recommendation

**Labels:** stage:design, type:deliverable

**Milestone:** 3. Design

**Body:**
## Task
Draft Solution Options document and Recommendation Brief.

## Acceptance Criteria
- [ ] Solution Options document complete
- [ ] Recommendation Brief (one-pager) complete
- [ ] Rationale tied to findings
- [ ] Risks and mitigations included
- [ ] Internal review completed

## Templates
- See templates folder for Solution Options template
- See templates folder for Recommendation Brief template
```

---

### SH7: Present options to client

```markdown
**Title:** Present options to client

**Labels:** stage:design, type:internal, client-review

**Milestone:** 3. Design

**Body:**
## Task
Present options to client for decision.

## Acceptance Criteria
- [ ] Presentation prepared
- [ ] Internal rehearsal completed
- [ ] Options presented to client
- [ ] Questions answered
- [ ] Feedback captured

## Links
- [Operations Guide](../../operations/README.md)
```

---

### SH8: Design stage client decision

```markdown
**Title:** Design stage client decision

**Labels:** stage:design, type:internal, client-review

**Milestone:** 3. Design

**Body:**
## Task
Get client decision on which option to pursue.

## Acceptance Criteria
- [ ] Client selects option
- [ ] Decision documented
- [ ] Scope for pilot agreed
- [ ] Sign-off received
- [ ] Ready to proceed to build
```

---

## Build Stage Issues

### T1: Write build brief

```markdown
**Title:** Write build brief

**Labels:** stage:build, type:deliverable

**Milestone:** 4. Build

**Body:**
## Task
Distill design outputs into a build brief.

## Acceptance Criteria
- [ ] What we're building documented
- [ ] Pilot scope defined (in/out)
- [ ] Design links included
- [ ] Technical decisions documented
- [ ] Constraints listed
- [ ] Success criteria defined
- [ ] Open questions listed

## Template
See templates folder for Build Brief template
```

---

### T2: Build pilot

```markdown
**Title:** Build pilot

**Labels:** stage:build, type:technical

**Milestone:** 4. Build

**Body:**
## Task
Build MVP pilot based on Build Brief.

## Acceptance Criteria
- [ ] All in-scope features built
- [ ] Internal testing completed
- [ ] Critical bugs fixed
- [ ] Monitoring in place
- [ ] Rollback plan documented
- [ ] Ready for pilot launch
```

---

### T3: Launch pilot

```markdown
**Title:** Launch pilot

**Labels:** stage:build, type:technical

**Milestone:** 4. Build

**Body:**
## Task
Deploy pilot to target users.

## Acceptance Criteria
- [ ] Pilot deployed to production
- [ ] Target users have access
- [ ] Baseline metrics captured
- [ ] Support channels ready
- [ ] Monitoring active
```

---

### T4: Monitor and collect feedback

```markdown
**Title:** Monitor and collect feedback

**Labels:** stage:build, type:research

**Milestone:** 4. Build

**Body:**
## Task
Monitor pilot performance and collect user/staff feedback.

## Acceptance Criteria
- [ ] Daily monitoring completed
- [ ] User interviews conducted
- [ ] Staff feedback collected
- [ ] Issues tracked and resolved
- [ ] Mid-pilot check completed

## Links
- [Operations Guide](../../operations/README.md)
```

---

### T5: Compile test results

```markdown
**Title:** Compile test results

**Labels:** stage:build, type:deliverable

**Milestone:** 4. Build

**Body:**
## Task
Compile quantitative and qualitative results from pilot.

## Acceptance Criteria
- [ ] Quantitative metrics compiled
- [ ] Qualitative findings synthesized
- [ ] Technical performance documented
- [ ] Issues summarized
- [ ] Internal review completed

## Template
See templates folder for Test Results template
```

---

### T6: Go/no-go recommendation

```markdown
**Title:** Go/no-go recommendation

**Labels:** stage:build, type:deliverable

**Milestone:** 4. Build

**Body:**
## Task
Prepare evidence-based go/no-go recommendation.

## Acceptance Criteria
- [ ] Recommendation drafted (Go/Iterate/No-Go)
- [ ] Evidence supports recommendation
- [ ] Risks for scaling documented
- [ ] Requirements for next step listed

## Template
See templates folder for Go/No-Go template
```

---

### T7: Build stage client decision

```markdown
**Title:** Build stage client decision

**Labels:** stage:build, type:internal, client-review

**Milestone:** 4. Build

**Body:**
## Task
Present results and get client decision.

## Acceptance Criteria
- [ ] Results presented
- [ ] Questions answered
- [ ] Decision made (Go/Iterate/No-Go)
- [ ] Next steps agreed
- [ ] Ready to proceed to handoff (if Go)
```

---

## Handoff Stage Issues

### E1: Technical documentation

```markdown
**Title:** Technical documentation

**Labels:** stage:handoff, type:deliverable, type:technical

**Milestone:** 5. Handoff

**Body:**
## Task
Document architecture, deployment, database, integrations, and troubleshooting.

## Acceptance Criteria
- [ ] Architecture documented
- [ ] Environments documented
- [ ] Deployment process documented
- [ ] Database schema documented
- [ ] Integrations documented
- [ ] Monitoring/alerts documented
- [ ] Common issues and fixes documented
- [ ] Internal review completed

## Template
See templates folder for Technical Documentation template
```

---

### E2: Operational runbook

```markdown
**Title:** Operational runbook

**Labels:** stage:handoff, type:deliverable

**Milestone:** 5. Handoff

**Body:**
## Task
Document how to operate the solution day-to-day.

## Acceptance Criteria
- [ ] Roles and responsibilities defined
- [ ] Daily/weekly/monthly tasks documented
- [ ] User management procedures documented
- [ ] Common requests documented
- [ ] Troubleshooting guide created
- [ ] Escalation paths defined
- [ ] Internal review completed

## Template
See templates folder for Operational Runbook template
```

---

### E3: Design documentation

```markdown
**Title:** Design documentation

**Labels:** stage:handoff, type:deliverable

**Milestone:** 5. Handoff

**Body:**
## Task
Document design files, design system, decisions, and future recommendations.

## Acceptance Criteria
- [ ] Design files linked
- [ ] Design system documented (colors, typography, components)
- [ ] Key decisions and rationale documented
- [ ] Accessibility notes included
- [ ] Future recommendations listed
- [ ] Internal review completed

## Template
See templates folder for Design Documentation template
```

---

### E4: Training

```markdown
**Title:** Training

**Labels:** stage:handoff, type:internal

**Milestone:** 5. Handoff

**Body:**
## Task
Train client team to operate and maintain the solution.

## Acceptance Criteria
- [ ] Training plan created
- [ ] Technical walkthrough completed
- [ ] Operational training completed
- [ ] Admin training completed (if applicable)
- [ ] Training materials delivered
- [ ] Recordings saved (if applicable)
```

---

### E5: Transfer access

```markdown
**Title:** Transfer access

**Labels:** stage:handoff, type:technical

**Milestone:** 5. Handoff

**Body:**
## Task
Transfer all accounts, credentials, and access to client.

## Acceptance Criteria
- [ ] GitHub repo transferred/access granted
- [ ] Vercel account transferred/access granted
- [ ] Supabase access transferred (if applicable)
- [ ] All API keys documented
- [ ] Third-party accounts transferred
- [ ] Client can deploy independently
```

---

### E6: Sustainability plan

```markdown
**Title:** Sustainability plan

**Labels:** stage:handoff, type:deliverable

**Milestone:** 5. Handoff

**Body:**
## Task
Document ownership, funding, maintenance, and evolution plan.

## Acceptance Criteria
- [ ] Owner identified
- [ ] Funding documented
- [ ] Maintenance tasks assigned
- [ ] Evolution recommendations listed
- [ ] Risks documented
- [ ] Sunset criteria defined
- [ ] Internal review completed

## Template
See templates folder for Sustainability Plan template
```

---

### E7: Measurement framework

```markdown
**Title:** Measurement framework

**Labels:** stage:handoff, type:deliverable

**Milestone:** 5. Handoff

**Body:**
## Task
Define how success will be tracked after engagement ends.

## Acceptance Criteria
- [ ] Success metrics defined
- [ ] Data collection plan created
- [ ] Reporting cadence set
- [ ] Review cadence set
- [ ] Owners assigned
- [ ] Internal review completed

## Template
See templates folder for Measurement Framework template
```

---

### E8: Engagement closeout

```markdown
**Title:** Engagement closeout

**Labels:** stage:handoff, type:internal, client-review

**Milestone:** 5. Handoff

**Body:**
## Task
Get final sign-off and close engagement.

## Acceptance Criteria
- [ ] All deliverables accepted
- [ ] Knowledge transfer complete
- [ ] Access transferred
- [ ] Client sign-off received
- [ ] Lessons learned captured
- [ ] Project archived

## Template
See templates folder for Engagement Closeout template
```

---

## Summary

| Stage | Issues | Milestone |
|-------|--------|-----------|
| Discovery | 8 | 1. Discovery |
| Research | 8 | 2. Research |
| Design | 8 | 3. Design |
| Build | 7 | 4. Build |
| Handoff | 8 | 5. Handoff |
| **Total** | **39** | |

---

## Usage

These issues are created automatically by the spinup script. See `playbook/operations/automation/spinup.sh`.
