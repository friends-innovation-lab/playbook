# Test Phase

*Validate in real conditions, not lab conditions.*

---

## Purpose

You have a recommended solution (Shape). Now prove it works — with real users, real data, real operations. Not a demo. Not a simulation. Reality.

This phase answers: **Does this actually work, and are we ready to scale it?**

---

## At a Glance

| | |
|---|---|
| **Duration** | 3-6 weeks |
| **Primary Owner** | Builder + UX Strategist |
| **Key Activities** | Build pilot, run pilot, measure results, iterate |
| **Outputs** | Working pilot, Test results, Go/no-go recommendation |
| **Exit Criteria** | Evidence-based decision to scale, iterate, or stop |

---

## Who Does What

| Role | Test Phase Responsibilities |
|------|------------------------------|
| **Project Lead** | Manages client expectations, removes blockers, owns go/no-go decision |
| **UX Strategist** | Defines success metrics, gathers user feedback, synthesizes findings |
| **UX/UI Designer** | Refines UI based on feedback, documents final patterns |
| **Builder** | Builds pilot, monitors performance, fixes issues, documents technical learnings |

---

## Key Principle: Real Conditions

A pilot isn't a demo. It's the solution running in the actual environment with actual constraints.

| ❌ Demo Conditions | ✅ Real Conditions |
|-------------------|-------------------|
| Perfect test data | Real (messy) data |
| Hand-picked users | Actual user population |
| Developers standing by | Normal support model |
| "Happy path" only | Edge cases included |
| Controlled environment | Production environment |
| Stakeholders watching | Day-to-day operations |

If it only works in demo conditions, it doesn't work.

---

## Week-by-Week Activities

### Week 1-2: Build Pilot

**Goal:** Get something real into users' hands.

| Day | Activity | Owner |
|-----|----------|-------|
| 1-2 | Define pilot scope (what's in, what's out) | All |
| 1-2 | Define success metrics | UX Strategist |
| 2-3 | Set up pilot infrastructure | Builder |
| 3-8 | Build pilot (MVP of selected option) | Builder + Designer |
| 5-8 | Internal testing | All |
| 8-10 | Fix critical issues | Builder |

### Week 3-4: Run Pilot

**Goal:** Observe the solution in real use.

| Day | Activity | Owner |
|-----|----------|-------|
| 1 | Pilot launch (limited rollout) | Builder |
| 1-10 | Monitor performance and errors | Builder |
| 2-10 | Gather user feedback (interviews, observation) | UX Strategist |
| 3-10 | Daily standups: what's working, what's not | All |
| 5 | Mid-pilot check: any critical issues? | All |
| 10 | End pilot data collection | UX Strategist |

### Week 5-6: Evaluate & Decide

**Goal:** Make an evidence-based recommendation.

| Day | Activity | Owner |
|-----|----------|-------|
| 1-2 | Compile quantitative results | Builder + UX Strategist |
| 2-3 | Synthesize qualitative feedback | UX Strategist |
| 3-4 | Draft test results document | UX Strategist |
| 4-5 | Internal review | All |
| 5-6 | Prepare go/no-go recommendation | Project Lead |
| 6-7 | Present to client | Project Lead + UX Strategist |
| 7 | Decision made | Client + Project Lead |

---

## Defining the Pilot

### Pilot Scope Questions

| Question | Why It Matters |
|----------|----------------|
| Which users are included? | Start narrow, expand if successful |
| Which features are included? | Core functionality only — not everything |
| What's the geographic/organizational scope? | One office? One region? |
| How long will it run? | Enough time to see real patterns |
| What's the rollback plan? | If it fails, how do we revert? |

### Pilot Scope Template

```markdown
## Pilot Scope

**Pilot name:** [Name]
**Duration:** [Start date] — [End date]
**Pilot population:** [Who's included]

### In Scope
- [Feature/capability 1]
- [Feature/capability 2]
- [User segment]

### Out of Scope (for this pilot)
- [Feature deferred to later]
- [User segment not included]
- [Edge case we're not testing]

### Success Criteria
| Metric | Target | How Measured |
|--------|--------|--------------|
| [Metric 1] | [Target] | [Data source] |
| [Metric 2] | [Target] | [Data source] |

### Rollback Plan
If [trigger condition], we will [rollback action].

### Pilot Team
| Role | Person | Availability |
|------|--------|--------------|
| [Role] | [Name] | [Hours/week] |
```

---

## Success Metrics

### Types of Metrics

| Type | What It Measures | Examples |
|------|------------------|----------|
| **Usability** | Can users complete tasks? | Task completion rate, error rate, time on task |
| **Adoption** | Are users using it? | Active users, login frequency, feature usage |
| **Satisfaction** | Do users like it? | NPS, satisfaction rating, qualitative feedback |
| **Performance** | Does it work technically? | Uptime, load time, error rate |
| **Operational** | Does it help staff? | Processing time, case volume, rework rate |
| **Outcome** | Does it achieve the goal? | Wait time reduced, accuracy improved |

### Setting Targets

| Approach | When to Use |
|----------|-------------|
| **Baseline comparison** | "20% better than current state" |
| **Absolute threshold** | "95% task completion" |
| **Industry benchmark** | "Match best-in-class" |
| **Directional** | "Improvement over baseline" (when you can't set a number) |

### Metrics Template

```markdown
## Success Metrics

### Primary Metrics (must hit to proceed)

| Metric | Baseline | Target | Measurement |
|--------|----------|--------|-------------|
| [Metric 1] | [Current] | [Goal] | [How/when measured] |
| [Metric 2] | [Current] | [Goal] | [How/when measured] |

### Secondary Metrics (informative, not decisive)

| Metric | Baseline | Target | Measurement |
|--------|----------|--------|-------------|
| [Metric 3] | [Current] | [Goal] | [How/when measured] |

### Qualitative Indicators

- [What we'll listen for in user feedback]
- [What we'll observe in usage patterns]
```

---

## Running the Pilot

### Daily Monitoring

Builder checks daily:
- [ ] System up and running?
- [ ] Any errors in logs?
- [ ] Performance within acceptable range?
- [ ] Any user-reported issues?

### Feedback Collection

| Method | When | Owner |
|--------|------|-------|
| **Usage analytics** | Continuous | Builder |
| **Error monitoring** | Continuous | Builder |
| **User interviews** | Week 2 and 4 | UX Strategist |
| **User observation** | Week 2-3 | UX Strategist + Designer |
| **Staff feedback** | Weekly | UX Strategist |
| **Support tickets** | Continuous | Project Lead |

### Pilot Feedback Questions

#### For Users (5-10 min)

- How did you find out about [the new system]?
- Walk me through what you did.
- What worked well?
- What was confusing or frustrating?
- How does this compare to the old way?
- Would you recommend this to others?
- What would make it better?

#### For Staff (10-15 min)

- How has this changed your work?
- What's easier now?
- What's harder or more confusing?
- Are users asking different questions?
- What problems are you seeing?
- What would you change?

### Issue Tracking

| Severity | Definition | Response |
|----------|------------|----------|
| 🔴 **Critical** | Blocks users, data loss, security issue | Fix immediately, consider pausing pilot |
| 🟠 **High** | Major functionality broken | Fix within 24-48 hours |
| 🟡 **Medium** | Workaround exists | Fix during pilot or note for iteration |
| 🟢 **Low** | Minor annoyance | Document for future improvement |

---

## Evaluating Results

### Quantitative Analysis

```markdown
## Quantitative Results

### Primary Metrics

| Metric | Baseline | Target | Actual | Status |
|--------|----------|--------|--------|--------|
| [Metric 1] | [X] | [Y] | [Z] | ✅/⚠️/❌ |
| [Metric 2] | [X] | [Y] | [Z] | ✅/⚠️/❌ |

### Secondary Metrics

| Metric | Baseline | Actual | Change |
|--------|----------|--------|--------|
| [Metric 3] | [X] | [Z] | +/-% |

### Technical Performance

| Metric | Target | Actual |
|--------|--------|--------|
| Uptime | 99% | [X]% |
| Avg load time | <2s | [X]s |
| Error rate | <1% | [X]% |
```

### Qualitative Synthesis

| Theme | Frequency | Representative Quote | Implication |
|-------|-----------|---------------------|-------------|
| [Theme 1] | Common/Some/Rare | "[Quote]" | [What to do about it] |
| [Theme 2] | Common/Some/Rare | "[Quote]" | [What to do about it] |

---

## Go/No-Go Decision

### Decision Framework

| Outcome | Criteria | Action |
|---------|----------|--------|
| 🟢 **Go** | Primary metrics met, no critical issues | Proceed to Embed (scale) |
| 🟡 **Iterate** | Promising but gaps identified | Another pilot cycle with changes |
| 🔴 **No-Go** | Fundamental problems, metrics far from target | Stop or return to Shape |

### Decision Meeting Agenda (60 min)

| Time | Topic |
|------|-------|
| 5 min | Recap: what we tested and why |
| 15 min | Results: quantitative metrics |
| 15 min | Results: qualitative findings |
| 10 min | Risks and open issues |
| 10 min | Recommendation and rationale |
| 5 min | Decision and next steps |

---

## Output 1: Test Results

### Template

```markdown
# Test Results

**Project:** [Project Name]
**Pilot dates:** [Start] — [End]
**Prepared by:** [Name]
**Date:** [Date]

---

## Executive Summary

[2-3 paragraphs: What we tested, key results, recommendation]

---

## What We Tested

### Pilot Scope
- **Users:** [Who participated]
- **Features:** [What was included]
- **Duration:** [How long]
- **Environment:** [Where it ran]

### Success Criteria
| Metric | Target |
|--------|--------|
| [Metric 1] | [Target] |
| [Metric 2] | [Target] |

---

## Results

### Quantitative Results

| Metric | Baseline | Target | Actual | Status |
|--------|----------|--------|--------|--------|
| [Metric 1] | | | | |
| [Metric 2] | | | | |

### Qualitative Findings

#### What Worked
- [Finding 1]
- [Finding 2]

#### What Didn't Work
- [Finding 1]
- [Finding 2]

#### Unexpected Findings
- [Finding 1]

---

## User Feedback

### Summary
[Overall sentiment and patterns]

### Key Quotes

> "[Quote 1]" — [User type]

> "[Quote 2]" — [User type]

### Feedback Themes

| Theme | Frequency | Implication |
|-------|-----------|-------------|
| [Theme] | Common/Some/Rare | [What it means] |

---

## Technical Performance

| Metric | Target | Actual | Notes |
|--------|--------|--------|-------|
| Uptime | | | |
| Load time | | | |
| Error rate | | | |

### Issues Encountered

| Issue | Severity | Resolution | Status |
|-------|----------|------------|--------|
| [Issue] | 🔴/🟠/🟡/🟢 | [What we did] | Fixed/Open |

---

## Risks Identified

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | High/Med/Low | High/Med/Low | [Plan] |

---

## Recommendation

### Our Recommendation: [Go / Iterate / No-Go]

**Rationale:**
1. [Reason 1]
2. [Reason 2]
3. [Reason 3]

### If Go: Next Steps for Scale
1. [Step 1]
2. [Step 2]

### If Iterate: What to Change
1. [Change 1]
2. [Change 2]

### Open Questions
- [Question that needs resolution]

---

## Appendix

- [Link to raw metrics data]
- [Link to user feedback notes]
- [Link to issue log]
```

---

## Output 2: Go/No-Go Recommendation

### Template (One-Pager)

```markdown
# Go/No-Go Recommendation

**Project:** [Project Name]
**Date:** [Date]
**Decision needed by:** [Date]

---

## Recommendation: [GO / ITERATE / NO-GO]

---

## Evidence

| Metric | Target | Result | Verdict |
|--------|--------|--------|---------|
| [Primary metric 1] | [X] | [Y] | ✅/❌ |
| [Primary metric 2] | [X] | [Y] | ✅/❌ |

**User feedback:** [1-2 sentence summary]

**Technical performance:** [1-2 sentence summary]

---

## Risks for Scaling

| Risk | Mitigation |
|------|------------|
| [Top risk 1] | [Plan] |
| [Top risk 2] | [Plan] |

---

## What's Needed to Proceed

| Item | Owner | Timeline |
|------|-------|----------|
| [Requirement 1] | [Who] | [When] |
| [Requirement 2] | [Who] | [When] |

---

## Decision

☐ **Go** — Proceed to full rollout
☐ **Iterate** — Run another pilot with changes: _______________
☐ **No-Go** — Stop or revisit approach

**Decided by:** _________________ **Date:** _________
```

---

## Test Phase Checklist

### Pilot Built
- [ ] Pilot scope defined and agreed
- [ ] Success metrics defined with targets
- [ ] Pilot infrastructure set up
- [ ] MVP built and internally tested
- [ ] Rollback plan documented
- [ ] Monitoring in place

### Pilot Run
- [ ] Pilot launched to target users
- [ ] Daily monitoring conducted
- [ ] User feedback collected
- [ ] Staff feedback collected
- [ ] Issues tracked and resolved
- [ ] Mid-pilot check completed

### Evaluation Complete
- [ ] Quantitative metrics compiled
- [ ] Qualitative findings synthesized
- [ ] Technical performance assessed
- [ ] Test results document drafted
- [ ] Go/no-go recommendation prepared
- [ ] Internal review completed

### Client Decision
- [ ] Results presented to client
- [ ] Questions addressed
- [ ] Decision made (go/iterate/no-go)
- [ ] Next steps agreed

---

## Common Test Phase Mistakes

| Mistake | Why It Happens | How to Avoid |
|---------|----------------|--------------|
| Pilot scope too big | Want to test everything | Focus on riskiest assumptions |
| No baseline metrics | Didn't measure "before" | Capture baseline before pilot starts |
| Declaring success too early | Pressure to show progress | Wait for full pilot duration |
| Ignoring negative feedback | Confirmation bias | Actively seek what's not working |
| Hand-holding users | Want pilot to succeed | Let them struggle — that's data |
| No rollback plan | Assumed it would work | Always have an exit |
| Pilot team ≠ real support | Developers always available | Simulate real support model |

---

## Transitioning to Embed

Test is complete when:

1. **Pilot ran in real conditions** — Not a demo, actual use
2. **Metrics collected** — Quantitative and qualitative
3. **Evidence-based decision** — Go/iterate/no-go based on data
4. **Risks identified** — Known issues for scaling
5. **Client aligned** — Decision made and documented

**Next phase:** Embed — Ensure work lasts beyond the project.

---

*This guide is part of the Public Impact Method. See methodology/overview.md for the full framework.*
