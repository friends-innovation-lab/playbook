# Starter Issues

Standard issues created for every project, organized by PIM phase.

---

## Labels (Created First)

```bash
# Phase labels (blue)
gh label create "phase:ground" --color "0052CC" --description "Ground phase work"
gh label create "phase:sense" --color "0052CC" --description "Sense phase work"
gh label create "phase:shape" --color "0052CC" --description "Shape phase work"
gh label create "phase:test" --color "0052CC" --description "Test phase work"
gh label create "phase:embed" --color "0052CC" --description "Embed phase work"

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
gh milestone create "1. Ground" --description "Establish legitimacy and constraints"
gh milestone create "2. Sense" --description "Develop shared understanding of users and systems"
gh milestone create "3. Shape" --description "Design viable pathways"
gh milestone create "4. Test" --description "Validate in real conditions"
gh milestone create "5. Embed" --description "Ensure work lasts beyond the project"
```

---

## Ground Phase Issues

### G1: Identify stakeholders to interview

```markdown
**Title:** Identify stakeholders to interview

**Labels:** phase:ground, type:research

**Milestone:** 1. Ground

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
- [Ground Phase Guide](../../methodology/ground/README.md)
```

---

### G2: Schedule stakeholder interviews

```markdown
**Title:** Schedule stakeholder interviews

**Labels:** phase:ground, type:internal

**Milestone:** 1. Ground

**Body:**
## Task
Schedule 45-60 minute interviews with identified stakeholders.

## Acceptance Criteria
- [ ] All interviews scheduled
- [ ] Calendar invites sent
- [ ] Interview guide prepared
- [ ] Note-taking template ready

## Links
- [Interview Questions](../../methodology/ground/README.md#ground-phase-interview-questions)
```

---

### G3: Conduct stakeholder interviews

```markdown
**Title:** Conduct stakeholder interviews

**Labels:** phase:ground, type:research

**Milestone:** 1. Ground

**Body:**
## Task
Conduct all scheduled stakeholder interviews. Capture notes in `/notes/interviews/`.

## Acceptance Criteria
- [ ] All interviews completed
- [ ] Notes captured for each interview
- [ ] Key quotes highlighted
- [ ] Follow-up items noted

## Links
- [Interview Note Template](../../methodology/ground/README.md)
```

---

### G4: Technical discovery

```markdown
**Title:** Technical discovery

**Labels:** phase:ground, type:technical

**Milestone:** 1. Ground

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
- [Ground Phase Guide](../../methodology/ground/README.md)
```

---

### G5: Draft stakeholder alignment snapshot

```markdown
**Title:** Draft stakeholder alignment snapshot

**Labels:** phase:ground, type:deliverable

**Milestone:** 1. Ground

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
See [Stakeholder Alignment Snapshot Template](../../methodology/ground/README.md#output-1-stakeholder-alignment-snapshot)
```

---

### G6: Draft constraint and opportunity map

```markdown
**Title:** Draft constraint and opportunity map

**Labels:** phase:ground, type:deliverable

**Milestone:** 1. Ground

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
See [Constraint and Opportunity Map Template](../../methodology/ground/README.md#output-2-constraint-and-opportunity-map)
```

---

### G7: Draft problem statement

```markdown
**Title:** Draft problem statement

**Labels:** phase:ground, type:deliverable

**Milestone:** 1. Ground

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
See [Problem Statement Template](../../methodology/ground/README.md#output-3-problem-statement)
```

---

### G8: Ground phase client sign-off

```markdown
**Title:** Ground phase client sign-off

**Labels:** phase:ground, type:internal, client-review

**Milestone:** 1. Ground

**Body:**
## Task
Present Ground phase findings to client and get sign-off to proceed to Sense.

## Acceptance Criteria
- [ ] Findings presented to client
- [ ] Client feedback incorporated
- [ ] Problem statement agreed upon
- [ ] Sign-off received
- [ ] Ready to proceed to Sense

## Deliverables to Present
- Stakeholder alignment snapshot
- Constraint and opportunity map
- Problem statement
```

---

## Sense Phase Issues

### S1: Define research questions

```markdown
**Title:** Define research questions

**Labels:** phase:sense, type:research

**Milestone:** 2. Sense

**Body:**
## Task
Define research questions tied to specific decisions. No research for research's sake.

## Acceptance Criteria
- [ ] Research questions documented
- [ ] Each question tied to a decision it will inform
- [ ] Methods selected for each question
- [ ] Sample size determined

## Links
- [Decision-Driven Research](../../methodology/sense/README.md#key-principle-decision-driven-research)
```

---

### S2: Recruit research participants

```markdown
**Title:** Recruit research participants

**Labels:** phase:sense, type:research

**Milestone:** 2. Sense

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

**Labels:** phase:sense, type:research

**Milestone:** 2. Sense

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
- [Sense Interview Questions](../../methodology/sense/README.md#sense-phase-interview-questions)
```

---

### S4: Create journey map

```markdown
**Title:** Create journey map

**Labels:** phase:sense, type:deliverable

**Milestone:** 2. Sense

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
- [System Map Components](../../methodology/sense/README.md#system-map-components)
```

---

### S5: Create system map

```markdown
**Title:** Create system map

**Labels:** phase:sense, type:deliverable, type:technical

**Milestone:** 2. Sense

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
- [System Mapping](../../methodology/sense/README.md#systems-mapping)
```

---

### S6: Draft research findings

```markdown
**Title:** Draft research findings

**Labels:** phase:sense, type:deliverable

**Milestone:** 2. Sense

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
See [Research Findings Template](../../methodology/sense/README.md#output-1-research-findings)
```

---

### S7: Draft risk/impact register

```markdown
**Title:** Draft risk/impact register

**Labels:** phase:sense, type:deliverable

**Milestone:** 2. Sense

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
See [Risk/Impact Register Template](../../methodology/sense/README.md#output-3-riskimpact-register)
```

---

### S8: Sense phase client sign-off

```markdown
**Title:** Sense phase client sign-off

**Labels:** phase:sense, type:internal, client-review

**Milestone:** 2. Sense

**Body:**
## Task
Present Sense phase findings to client and get sign-off to proceed to Shape.

## Acceptance Criteria
- [ ] Findings presented to client
- [ ] Client feedback incorporated
- [ ] Agreement on key insights
- [ ] Sign-off received
- [ ] Ready to proceed to Shape

## Deliverables to Present
- Research findings
- Journey map
- System map
- Risk/impact register
```

---

## Shape Phase Issues

### SH1: Run ideation session

```markdown
**Title:** Run ideation session

**Labels:** phase:shape, type:research

**Milestone:** 3. Shape

**Body:**
## Task
Facilitate ideation session to generate solution concepts.

## Acceptance Criteria
- [ ] Session scheduled (2-3 hours)
- [ ] Team reviewed Sense findings beforehand
- [ ] HMW questions prepared
- [ ] Session facilitated
- [ ] Concepts clustered into approaches
- [ ] Notes captured

## Links
- [Ideation Session Guide](../../methodology/shape/README.md#ideation-session)
```

---

### SH2: Develop solution options

```markdown
**Title:** Develop solution options

**Labels:** phase:shape, type:deliverable

**Milestone:** 3. Shape

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
See [Option Development Template](../../methodology/shape/README.md#option-development-template)
```

---

### SH3: Feasibility assessment

```markdown
**Title:** Feasibility assessment

**Labels:** phase:shape, type:technical

**Milestone:** 3. Shape

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
See [Feasibility Assessment](../../methodology/shape/README.md#feasibility-assessment)
```

---

### SH4: Create prototypes

```markdown
**Title:** Create prototypes

**Labels:** phase:shape, type:deliverable

**Milestone:** 3. Shape

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
- [Prototyping Guidance](../../methodology/shape/README.md#prototyping)
```

---

### SH5: Tradeoff analysis

```markdown
**Title:** Tradeoff analysis

**Labels:** phase:shape, type:deliverable

**Milestone:** 3. Shape

**Body:**
## Task
Map tradeoffs across options so client can make informed decision.

## Acceptance Criteria
- [ ] Evaluation criteria defined
- [ ] Each option scored
- [ ] Tradeoffs made explicit
- [ ] Comparison matrix complete

## Template
See [Tradeoff Analysis](../../methodology/shape/README.md#tradeoff-analysis)
```

---

### SH6: Draft recommendation

```markdown
**Title:** Draft recommendation

**Labels:** phase:shape, type:deliverable

**Milestone:** 3. Shape

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
- [Solution Options](../../methodology/shape/README.md#output-1-solution-options)
- [Recommendation Brief](../../methodology/shape/README.md#output-2-recommendation-brief)
```

---

### SH7: Present options to client

```markdown
**Title:** Present options to client

**Labels:** phase:shape, type:internal, client-review

**Milestone:** 3. Shape

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
- [Presentation Structure](../../methodology/shape/README.md#client-presentation)
```

---

### SH8: Shape phase client decision

```markdown
**Title:** Shape phase client decision

**Labels:** phase:shape, type:internal, client-review

**Milestone:** 3. Shape

**Body:**
## Task
Get client decision on which option to pursue.

## Acceptance Criteria
- [ ] Client selects option
- [ ] Decision documented
- [ ] Scope for pilot agreed
- [ ] Sign-off received
- [ ] Ready to proceed to Test
```

---

## Test Phase Issues

### T1: Write build brief

```markdown
**Title:** Write build brief

**Labels:** phase:test, type:deliverable

**Milestone:** 4. Test

**Body:**
## Task
Distill Shape outputs into CC-ready Build Brief.

## Acceptance Criteria
- [ ] What we're building documented
- [ ] Pilot scope defined (in/out)
- [ ] Design links included
- [ ] Technical decisions documented
- [ ] Constraints listed
- [ ] Success criteria defined
- [ ] Open questions listed

## Template
See [Build Brief Template](../../methodology/test/README.md#build-brief-template)
```

---

### T2: Build pilot

```markdown
**Title:** Build pilot

**Labels:** phase:test, type:technical

**Milestone:** 4. Test

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

**Labels:** phase:test, type:technical

**Milestone:** 4. Test

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

**Labels:** phase:test, type:research

**Milestone:** 4. Test

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
- [Feedback Collection](../../methodology/test/README.md#feedback-collection)
- [Pilot Feedback Questions](../../methodology/test/README.md#pilot-feedback-questions)
```

---

### T5: Compile test results

```markdown
**Title:** Compile test results

**Labels:** phase:test, type:deliverable

**Milestone:** 4. Test

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
See [Test Results Template](../../methodology/test/README.md#output-1-test-results)
```

---

### T6: Go/no-go recommendation

```markdown
**Title:** Go/no-go recommendation

**Labels:** phase:test, type:deliverable

**Milestone:** 4. Test

**Body:**
## Task
Prepare evidence-based go/no-go recommendation.

## Acceptance Criteria
- [ ] Recommendation drafted (Go/Iterate/No-Go)
- [ ] Evidence supports recommendation
- [ ] Risks for scaling documented
- [ ] Requirements for next step listed

## Template
See [Go/No-Go Template](../../methodology/test/README.md#output-2-gono-go-recommendation)
```

---

### T7: Test phase client decision

```markdown
**Title:** Test phase client decision

**Labels:** phase:test, type:internal, client-review

**Milestone:** 4. Test

**Body:**
## Task
Present results and get client decision.

## Acceptance Criteria
- [ ] Results presented
- [ ] Questions answered
- [ ] Decision made (Go/Iterate/No-Go)
- [ ] Next steps agreed
- [ ] Ready to proceed to Embed (if Go)
```

---

## Embed Phase Issues

### E1: Technical documentation

```markdown
**Title:** Technical documentation

**Labels:** phase:embed, type:deliverable, type:technical

**Milestone:** 5. Embed

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
See [Technical Documentation Template](../../methodology/embed/README.md#technical-documentation-builder)
```

---

### E2: Operational runbook

```markdown
**Title:** Operational runbook

**Labels:** phase:embed, type:deliverable

**Milestone:** 5. Embed

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
See [Operational Runbook Template](../../methodology/embed/README.md#operational-runbook-ux-strategist)
```

---

### E3: Design documentation

```markdown
**Title:** Design documentation

**Labels:** phase:embed, type:deliverable

**Milestone:** 5. Embed

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
See [Design Documentation Template](../../methodology/embed/README.md#design-documentation-designer)
```

---

### E4: Training

```markdown
**Title:** Training

**Labels:** phase:embed, type:internal

**Milestone:** 5. Embed

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

**Labels:** phase:embed, type:technical

**Milestone:** 5. Embed

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

**Labels:** phase:embed, type:deliverable

**Milestone:** 5. Embed

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
See [Sustainability Plan Template](../../methodology/embed/README.md#output-2-sustainability-plan)
```

---

### E7: Measurement framework

```markdown
**Title:** Measurement framework

**Labels:** phase:embed, type:deliverable

**Milestone:** 5. Embed

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
See [Measurement Framework Template](../../methodology/embed/README.md#output-3-measurement-framework)
```

---

### E8: Engagement closeout

```markdown
**Title:** Engagement closeout

**Labels:** phase:embed, type:internal, client-review

**Milestone:** 5. Embed

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
See [Engagement Closeout](../../methodology/embed/README.md#engagement-closeout)
```

---

## Summary

| Phase | Issues | Milestone |
|-------|--------|-----------|
| Ground | 8 | 1. Ground |
| Sense | 8 | 2. Sense |
| Shape | 8 | 3. Shape |
| Test | 7 | 4. Test |
| Embed | 8 | 5. Embed |
| **Total** | **39** | |

---

## Usage

These issues are created automatically by the spinup script. See `playbook/operations/automation/spinup.sh`.
