# Embed Phase

*Ensure work lasts beyond the project.*

---

## Purpose

Most innovation projects die after the demo. The pilot worked, everyone clapped, then nothing changed. Embed prevents that.

This phase answers: **How does this become how things are done here?**

---

## At a Glance

| | |
|---|---|
| **Duration** | 2-4 weeks |
| **Primary Owner** | Project Lead + UX Strategist |
| **Key Activities** | Handoff, documentation, training, sustainability planning |
| **Outputs** | Handoff documentation, Sustainability plan, Measurement framework |
| **Exit Criteria** | Client can run, maintain, and evolve the solution without us |

---

## Who Does What

| Role | Embed Phase Responsibilities |
|------|------------------------------|
| **Project Lead** | Manages transition, ensures client ownership, closes engagement |
| **UX Strategist** | Documents decisions, creates training materials, transfers knowledge |
| **UX/UI Designer** | Documents design system, patterns, future recommendations |
| **Builder** | Documents technical architecture, trains client team, transitions support |

---

## Key Principle: Institutional Ownership

If we're the only ones who can run it, we failed. The goal is to transfer ownership so completely that the client forgets they needed us.

| ❌ Vendor Dependency | ✅ Institutional Ownership |
|---------------------|---------------------------|
| "Call the consultants" | "We know how this works" |
| Documentation in our repo | Documentation in their systems |
| We hold the keys | They hold the keys |
| Solution dies when contract ends | Solution evolves after we leave |
| Knowledge in our heads | Knowledge in their team |

---

## Week-by-Week Activities

### Week 1: Document

**Goal:** Capture everything needed to run and maintain the solution.

| Day | Activity | Owner |
|-----|----------|-------|
| 1-2 | Draft technical documentation | Builder |
| 1-2 | Draft operational runbook | UX Strategist |
| 2-3 | Document design patterns and rationale | Designer |
| 3-4 | Create user guides/training materials | UX Strategist |
| 4-5 | Internal review of all documentation | All |

### Week 2: Transfer

**Goal:** Hand over knowledge to client team.

| Day | Activity | Owner |
|-----|----------|-------|
| 1-2 | Technical walkthrough with client IT/dev | Builder |
| 2-3 | Operational training with client staff | UX Strategist |
| 3-4 | Admin training (if applicable) | Builder |
| 4-5 | Transfer accounts, credentials, access | Builder + Project Lead |
| 5 | Confirm client can operate independently | Project Lead |

### Week 3: Sustain

**Goal:** Plan for long-term success and close engagement.

| Day | Activity | Owner |
|-----|----------|-------|
| 1-2 | Draft sustainability plan | UX Strategist |
| 2-3 | Define measurement framework | UX Strategist |
| 3-4 | Final client review | Project Lead |
| 4-5 | Engagement closeout | Project Lead |

---

## What Gets Handed Off

| Category | What to Transfer |
|----------|------------------|
| **Code & Systems** | Repositories, databases, hosting accounts, API keys |
| **Documentation** | Technical docs, runbooks, user guides, design files |
| **Knowledge** | Why decisions were made, what was tried, what didn't work |
| **Access** | Admin credentials, service accounts, vendor contacts |
| **Relationships** | Key contacts, escalation paths, support channels |
| **Roadmap** | What's next, recommended improvements, known issues |

---

## Output 1: Handoff Documentation

### Technical Documentation (Builder)

```markdown
# Technical Documentation

**Project:** [Name]
**Date:** [Date]
**Prepared by:** [Builder name]

---

## Architecture Overview

[Diagram or description of how the system works]

### Components

| Component | Technology | Purpose | Location |
|-----------|------------|---------|----------|
| Frontend | Next.js | User interface | [GitHub repo] |
| Backend | Supabase | Database, auth | [Supabase project] |
| Hosting | Vercel | Deployment | [Vercel project] |

---

## Environments

| Environment | URL | Purpose |
|-------------|-----|---------|
| Production | [URL] | Live system |
| Staging | [URL] | Testing |
| Development | [URL] | Local dev |

---

## Access & Credentials

| System | Account Owner | How to Access |
|--------|---------------|---------------|
| GitHub | [Client team] | [Instructions] |
| Vercel | [Client team] | [Instructions] |
| Supabase | [Client team] | [Instructions] |

⚠️ All credentials should be transferred to client-owned accounts before project close.

---

## Deployment

### How to Deploy

1. [Step 1]
2. [Step 2]
3. [Step 3]

### Rollback Procedure

1. [Step 1]
2. [Step 2]

---

## Database

### Schema

[ERD or table descriptions]

### Backups

- **Frequency:** [Daily/Weekly]
- **Location:** [Where backups are stored]
- **Restore procedure:** [How to restore]

---

## Integrations

| Integration | Purpose | Documentation | Contact |
|-------------|---------|---------------|---------|
| [System] | [Why] | [Link] | [Who to call] |

---

## Monitoring & Alerts

| What's Monitored | Tool | Alert Threshold | Who Gets Notified |
|------------------|------|-----------------|-------------------|
| Uptime | [Tool] | [Threshold] | [Email/Slack] |
| Errors | [Tool] | [Threshold] | [Email/Slack] |

---

## Common Issues & Fixes

| Issue | Symptoms | Fix |
|-------|----------|-----|
| [Issue 1] | [What you see] | [How to fix] |
| [Issue 2] | [What you see] | [How to fix] |

---

## Future Technical Recommendations

| Recommendation | Priority | Rationale |
|----------------|----------|-----------|
| [Recommendation] | High/Med/Low | [Why] |
```

### Operational Runbook (UX Strategist)

```markdown
# Operational Runbook

**Project:** [Name]
**Date:** [Date]
**Prepared by:** [Name]

---

## Purpose

This document describes how to operate [system name] on a day-to-day basis.

---

## Roles & Responsibilities

| Role | Responsibilities | Current Person |
|------|------------------|----------------|
| System Owner | Overall accountability, budget | [Name] |
| Day-to-Day Admin | User management, configuration | [Name] |
| Technical Support | Bug fixes, maintenance | [Name/Team] |
| Escalation Contact | Major issues, decisions | [Name] |

---

## Daily Operations

### What Needs to Happen Daily

- [ ] [Task 1]
- [ ] [Task 2]

### Weekly Tasks

- [ ] [Task 1]
- [ ] [Task 2]

### Monthly Tasks

- [ ] [Task 1]

---

## User Management

### Adding a New User

1. [Step 1]
2. [Step 2]

### Removing a User

1. [Step 1]
2. [Step 2]

### Password Resets

1. [Step 1]

---

## Common Requests & How to Handle

| Request | Who Can Approve | How to Do It |
|---------|-----------------|--------------|
| [Request type] | [Role] | [Steps] |

---

## Troubleshooting

| Problem | Likely Cause | Solution |
|---------|--------------|----------|
| [Problem] | [Cause] | [Fix] |

### When to Escalate

Escalate to [technical support] if:
- [Condition 1]
- [Condition 2]

---

## Support Contacts

| Issue Type | Contact | Response Time |
|------------|---------|---------------|
| User questions | [Name/Email] | [SLA] |
| Technical issues | [Name/Email] | [SLA] |
| Urgent/outage | [Name/Phone] | Immediate |
```

### Design Documentation (Designer)

```markdown
# Design Documentation

**Project:** [Name]
**Date:** [Date]
**Prepared by:** [Designer name]

---

## Design Files

| File | Purpose | Location |
|------|---------|----------|
| Figma - Final Designs | Production screens | [Link] |
| Figma - Components | Design system | [Link] |
| FigJam - Research | Journey maps, etc. | [Link] |

---

## Design System

### Colors

| Name | Hex | Usage |
|------|-----|-------|
| Primary | #XXXXXX | Buttons, links |
| Secondary | #XXXXXX | Accents |
| Error | #XXXXXX | Error states |

### Typography

| Style | Font | Size | Usage |
|-------|------|------|-------|
| H1 | [Font] | [Size] | Page titles |
| Body | [Font] | [Size] | Content |

### Components

| Component | Usage | Figma Link |
|-----------|-------|------------|
| Button | [When to use] | [Link] |
| Form field | [When to use] | [Link] |

---

## Design Decisions & Rationale

| Decision | What We Chose | Why |
|----------|---------------|-----|
| [Decision] | [Choice] | [Rationale] |

---

## Accessibility

- [Accessibility feature 1]
- [Accessibility feature 2]

### Known Limitations

- [Limitation and recommended fix]

---

## Future Design Recommendations

| Recommendation | Priority | Rationale |
|----------------|----------|-----------|
| [Recommendation] | High/Med/Low | [Why] |
```

---

## Output 2: Sustainability Plan

### Purpose
Ensure the solution continues to deliver value after the engagement ends.

### Template

```markdown
# Sustainability Plan

**Project:** [Name]
**Date:** [Date]
**Prepared by:** [Name]

---

## Ownership

### Accountable Owner

| | |
|---|---|
| **Name** | [Name] |
| **Role** | [Title] |
| **Responsibility** | Overall success and continuation of [solution] |

### Supporting Roles

| Role | Person | Responsibility |
|------|--------|----------------|
| Technical lead | [Name] | Maintenance, bug fixes |
| Operations lead | [Name] | Day-to-day operations |
| Budget owner | [Name] | Funding decisions |

---

## Funding

### Current Funding

| Item | Cost | Frequency | Funded Through |
|------|------|-----------|----------------|
| Hosting | $X | Monthly | [Budget line] |
| Maintenance | $X | Annually | [Budget line] |
| Licenses | $X | Annually | [Budget line] |

### Future Funding Needs

| Need | Estimated Cost | When | Status |
|------|----------------|------|--------|
| [Need] | $X | [Timeframe] | Secured/Pending/At risk |

### Budget Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| [Risk] | H/M/L | [Plan] |

---

## Maintenance

### Ongoing Maintenance Needs

| Task | Frequency | Owner | Estimated Effort |
|------|-----------|-------|------------------|
| Security updates | Monthly | [Name] | [Hours] |
| Backup verification | Weekly | [Name] | [Hours] |
| User support | Ongoing | [Name] | [Hours/week] |

### Technical Debt & Known Issues

| Issue | Severity | Recommendation | Effort |
|-------|----------|----------------|--------|
| [Issue] | H/M/L | [Fix] | [Estimate] |

---

## Evolution

### Recommended Improvements

| Improvement | Priority | Benefit | Effort |
|-------------|----------|---------|--------|
| [Improvement] | H/M/L | [Why] | [Estimate] |

### What NOT to Change

| Element | Why It Matters |
|---------|----------------|
| [Element] | [Reason to preserve] |

### Decision Rights

| Decision Type | Who Decides | Who Approves |
|---------------|-------------|--------------|
| Minor UI changes | [Role] | No approval needed |
| Feature additions | [Role] | [Role] |
| Architecture changes | [Role] | [Role] |

---

## Risks to Sustainability

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Key person leaves | Med | High | Document everything, cross-train |
| Budget cut | Low | High | Demonstrate value with metrics |
| Technology obsolescence | Low | Med | Plan for updates |

---

## Sunset Criteria

If [solution] is no longer viable, here's how to wind it down:

### When to Consider Sunset

- [Condition 1 — e.g., usage drops below X]
- [Condition 2 — e.g., maintenance cost exceeds value]

### Sunset Process

1. [Step 1 — notify users]
2. [Step 2 — export/migrate data]
3. [Step 3 — archive code/docs]
4. [Step 4 — decommission infrastructure]

### Data Retention

- [What data must be kept and for how long]
```

---

## Output 3: Measurement Framework

### Purpose
Define how success will be tracked after the engagement ends.

### Template

```markdown
# Measurement Framework

**Project:** [Name]
**Date:** [Date]
**Prepared by:** [Name]

---

## Success Metrics

### Primary Outcomes

What ultimate impact should this solution have?

| Outcome | Metric | Baseline | Target | Timeframe |
|---------|--------|----------|--------|-----------|
| [Outcome] | [How measured] | [Before] | [Goal] | [When] |

### Leading Indicators

What early signals show we're on track?

| Indicator | Metric | Target | Measured |
|-----------|--------|--------|----------|
| [Indicator] | [How measured] | [Goal] | [Frequency] |

---

## Data Collection

### What Data to Collect

| Metric | Data Source | Collection Method | Frequency |
|--------|-------------|-------------------|-----------|
| [Metric] | [System/survey/manual] | [How] | [When] |

### Who Collects It

| Data | Owner | Backup |
|------|-------|--------|
| [Data type] | [Name] | [Name] |

---

## Reporting

### Report Schedule

| Report | Audience | Frequency | Owner |
|--------|----------|-----------|-------|
| Dashboard update | Operations | Weekly | [Name] |
| Executive summary | Leadership | Monthly | [Name] |
| Full review | Stakeholders | Quarterly | [Name] |

### Report Template

```
## [Solution Name] — [Month/Quarter] Report

### Summary
[1-2 sentences: How are we doing?]

### Key Metrics
| Metric | Target | Actual | Trend |
|--------|--------|--------|-------|
| | | | ↑/↓/→ |

### Highlights
- [Win 1]
- [Win 2]

### Issues
- [Issue and action being taken]

### Next Period Focus
- [Priority 1]
```

---

## Review Cadence

### Quarterly Review

Every [quarter], [owner] should:
- [ ] Review all metrics against targets
- [ ] Identify what's working and what's not
- [ ] Decide on adjustments or improvements
- [ ] Update this framework if needed

### Annual Review

Every [year], [owner] should:
- [ ] Assess overall impact
- [ ] Revisit targets for next year
- [ ] Evaluate if solution is still fit for purpose
- [ ] Decide: continue, evolve, or sunset

---

## When to Raise Concerns

| Condition | Action |
|-----------|--------|
| Metric drops below [threshold] | Escalate to [role] |
| [Number] consecutive periods of decline | Trigger review meeting |
| User complaints increase | Investigate root cause |
```

---

## Training & Knowledge Transfer

### Training Plan

| Audience | Topics | Format | Duration | Date |
|----------|--------|--------|----------|------|
| Admins | System configuration, user management | Live session | 2 hours | [Date] |
| End users | How to use the system | Video + guide | 30 min | [Date] |
| Technical team | Architecture, deployment, troubleshooting | Live session | 4 hours | [Date] |

### Training Materials

| Material | Audience | Location |
|----------|----------|----------|
| User guide | End users | [Link] |
| Admin guide | Admins | [Link] |
| Technical docs | Developers | [Link] |
| Training recording | All | [Link] |

---

## Embed Phase Checklist

### Documentation Complete
- [ ] Technical documentation drafted
- [ ] Operational runbook drafted
- [ ] Design documentation drafted
- [ ] User guides created
- [ ] Training materials created
- [ ] All docs reviewed and finalized

### Knowledge Transferred
- [ ] Technical walkthrough completed
- [ ] Operational training completed
- [ ] Admin training completed
- [ ] Training materials delivered
- [ ] Questions answered

### Access Transferred
- [ ] Code repositories transferred to client
- [ ] Hosting accounts transferred
- [ ] Database access transferred
- [ ] All credentials in client's hands
- [ ] Third-party accounts transferred

### Sustainability Planned
- [ ] Owner identified and confirmed
- [ ] Funding secured or planned
- [ ] Maintenance responsibilities assigned
- [ ] Measurement framework agreed
- [ ] Risks documented with mitigations

### Engagement Closed
- [ ] Final deliverables accepted
- [ ] Client sign-off received
- [ ] Lessons learned captured
- [ ] Internal project retrospective completed
- [ ] Project archived

---

## Common Embed Phase Mistakes

| Mistake | Why It Happens | How to Avoid |
|---------|----------------|--------------|
| Skipping Embed entirely | Budget/time ran out | Plan and price Embed from the start |
| Documentation dumping | Check-the-box mentality | Write docs for the person who needs them |
| Training once, then gone | Assumed it stuck | Provide recordings, reference materials |
| No clear owner | Everyone's job = no one's job | Name one accountable person |
| Forgot about funding | Assumed it continues | Explicitly plan and confirm budget |
| No sunset plan | Assumed eternal life | Everything ends — plan for it |

---

## Engagement Closeout

### Final Deliverables Checklist

| Deliverable | Status | Location |
|-------------|--------|----------|
| Technical documentation | ✅/❌ | [Link] |
| Operational runbook | ✅/❌ | [Link] |
| Design documentation | ✅/❌ | [Link] |
| User guides | ✅/❌ | [Link] |
| Training materials | ✅/❌ | [Link] |
| Sustainability plan | ✅/❌ | [Link] |
| Measurement framework | ✅/❌ | [Link] |

### Sign-Off

```markdown
## Project Closeout

**Project:** [Name]
**Date:** [Date]

We confirm that:
- [ ] All deliverables have been received and accepted
- [ ] Knowledge transfer is complete
- [ ] Access and credentials have been transferred
- [ ] Sustainability plan is in place
- [ ] We can operate this solution independently

**Client signature:** ___________________ **Date:** ________

**Project Lead signature:** ___________________ **Date:** ________
```

### Lessons Learned

Capture internally after every project:

| Question | Notes |
|----------|-------|
| What worked well? | |
| What didn't work? | |
| What would we do differently? | |
| What should we add to the playbook? | |

---

## After We Leave

### Support Period (if applicable)

| Period | Support Level | Response Time |
|--------|---------------|---------------|
| Weeks 1-2 | Full support | 24 hours |
| Weeks 3-4 | Questions only | 48 hours |
| After week 4 | New engagement | Scoped separately |

### Staying Connected

- Offer a 30-day check-in call
- Share relevant updates if we learn something new
- Keep the door open for future work

---

*This guide is part of the Public Impact Method. See methodology/overview.md for the full framework.*
