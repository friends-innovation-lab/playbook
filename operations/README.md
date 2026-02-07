# Project Operations Guide

*How we run projects at Friends Innovation Lab.*

---

## Tool Stack

| Tool | Purpose | Who Uses It |
|------|---------|-------------|
| **GitHub** | Source of truth — methodology, code, task tracking | Everyone (Project Lead manages boards) |
| **Google Docs** | Template library, internal drafts | Everyone |
| **FigJam** | Visual collaboration — maps, workshops | UX Strategist, Designer |
| **Figma** | UI/UX design | Designer, Builder |
| **Word/PDF** | Client deliverables (export from Google Docs) | Project Lead (for delivery) |

---

## Why GitHub-Centric?

1. **Single source of truth** — No hunting across tools
2. **Version control** — See what changed and when
3. **Already set up** — Spinup script creates repos automatically
4. **Methodology lives there** — Playbook is in the same place as projects
5. **Free** — No per-seat costs for project management

---

## GitHub Structure

### Organization Level

```
friends-innovation-lab (GitHub Org)
├── playbook/                    # Methodology, operations, templates
├── project-template/            # Base template for new projects
├── truebid/                     # Product: TrueBid
├── [client-project-1]/          # Client project repo
├── [client-project-2]/          # Client project repo
└── ...
```

### Project Repo Structure

Each project repo (created by spinup script) contains:

```
[project-name]/
├── README.md                    # Project overview, links, status
├── CLAUDE.md                    # AI coding standards
├── docs/
│   ├── ground/                  # Ground phase deliverables
│   │   ├── stakeholder-snapshot.md
│   │   ├── constraint-map.md
│   │   └── problem-statement.md
│   ├── sense/                   # Sense phase deliverables
│   ├── shape/                   # Shape phase deliverables
│   ├── test/                    # Test phase deliverables
│   └── embed/                   # Embed phase deliverables
├── notes/                       # Internal working notes
│   ├── interviews/              # Interview notes
│   ├── meetings/                # Meeting notes
│   └── synthesis/               # Working synthesis docs
├── assets/                      # Images, exports, etc.
├── src/                         # Application code (if applicable)
└── ...
```

---

## Task Tracking with GitHub

### GitHub Issues = Tasks

Every task is a GitHub Issue. Use labels to track:

| Label | Meaning |
|-------|---------|
| `phase:ground` | Ground phase work |
| `phase:sense` | Sense phase work |
| `phase:shape` | Shape phase work |
| `phase:test` | Test phase work |
| `phase:embed` | Embed phase work |
| `type:research` | Interviews, discovery |
| `type:deliverable` | Client-facing output |
| `type:internal` | Internal task |
| `type:technical` | Code/infrastructure |
| `role:lead` | Project Lead owns |
| `role:strategist` | UX Strategist owns |
| `role:designer` | Designer owns |
| `role:builder` | Builder owns |

### GitHub Projects = Kanban Board

Each project repo gets a GitHub Project board:

| Column | What's Here |
|--------|-------------|
| **Backlog** | Future tasks, not yet started |
| **This Week** | Committed for current week |
| **In Progress** | Actively being worked |
| **Review** | Done, needs review/approval |
| **Done** | Complete |

### Issue Template

When creating issues, use this format:

```markdown
## Task
[What needs to be done]

## Context
[Why this matters, any background]

## Acceptance Criteria
- [ ] [Specific outcome 1]
- [ ] [Specific outcome 2]

## Links
- [Related doc/FigJam/etc.]
```

---

## Weekly Rhythm

### Monday: Planning
- Review board, move items to "This Week"
- Assign owners to issues
- Identify blockers

### Daily: Async Updates
- Update issue comments with progress
- Move cards on board as status changes

### Friday: Wrap-up
- Move completed items to "Done"
- Update README with status
- Prep for client check-in (if scheduled)

---

## Google Docs: Template Library

Templates live in a shared Google Drive folder. Each template links from the playbook.

### Folder Structure

```
Friends Innovation Lab (Google Drive)
└── Templates/
    ├── Ground Phase/
    │   ├── Stakeholder Alignment Snapshot
    │   ├── Constraint and Opportunity Map
    │   └── Problem Statement
    ├── Sense Phase/
    │   ├── [templates TBD]
    ├── Shape Phase/
    │   ├── [templates TBD]
    ├── Test Phase/
    │   ├── [templates TBD]
    └── Embed Phase/
        ├── [templates TBD]
```

### How to Use Templates

1. **Find template** — Link in playbook methodology guide
2. **Make a copy** — File → Make a copy → Save to project folder
3. **Rename** — `[Project Name] - [Template Name]`
4. **Work in Google Docs** — Draft, iterate, get internal review
5. **Export for client** — Download as Word (.docx) or PDF
6. **Archive in repo** — Save final version to `docs/[phase]/` as markdown or PDF

### Why Google Docs for Templates?

- Easy for non-technical team to use
- Real-time collaboration
- Comments and suggestions
- Exports cleanly to Word for Microsoft clients
- Free

---

## FigJam: Visual Collaboration

Use FigJam for work that's inherently visual:

| Artifact | When to Use FigJam |
|----------|-------------------|
| **Stakeholder map** | Visualizing relationships and influence |
| **System map** | Showing how parts connect |
| **Journey map** | User experience over time |
| **Service blueprint** | Front-stage/back-stage view |
| **Affinity diagram** | Clustering research findings |
| **Workshop boards** | Collaborative sessions with clients |

### FigJam File Naming

```
[Project Name] - [Artifact Type] - [Version/Date]

Examples:
CAMP - Stakeholder Map - v1
VA Benefits - Journey Map - 2025-01-15
TrueBid - Service Blueprint - Draft
```

### FigJam → GitHub

After FigJam work is final:
1. Export as PNG or PDF
2. Save to `assets/` in project repo
3. Link from relevant doc in `docs/`

---

## Client Deliverables Workflow

### Internal Process

```
Template (Google Docs)
    ↓
Copy to project folder
    ↓
Draft in Google Docs
    ↓
Internal review (comments)
    ↓
Revise
    ↓
Export to Word/PDF
    ↓
Send to client
    ↓
Client feedback (usually email or tracked changes)
    ↓
Revise in Google Docs
    ↓
Export final version
    ↓
Archive to GitHub (docs/[phase]/)
```

### Naming Convention for Client Deliverables

```
[Project Name] - [Deliverable] - [Status] - [Date]

Examples:
CAMP - Problem Statement - DRAFT - 2025-01-15.docx
CAMP - Problem Statement - FINAL - 2025-01-22.pdf
```

### What Clients Receive

| Phase | Deliverables | Format |
|-------|--------------|--------|
| **Ground** | Problem Statement, Stakeholder Snapshot (optional) | Word or PDF |
| **Sense** | Research Summary, Journey Map | Word/PDF + FigJam export |
| **Shape** | Solution Options, Recommendation | Word or PDF + Figma links |
| **Test** | Pilot Plan, Test Results | Word or PDF |
| **Embed** | Handoff Documentation, Sustainability Plan | Word or PDF |

---

## Meeting Notes

### Where They Live

```
[project-repo]/notes/meetings/
├── 2025-01-10-kickoff.md
├── 2025-01-17-weekly-checkin.md
├── 2025-01-24-ground-review.md
└── ...
```

### Meeting Note Template

```markdown
# [Meeting Name]

**Date:** [Date]
**Attendees:** [Names]
**Purpose:** [Why we met]

---

## Agenda
1. [Topic 1]
2. [Topic 2]

## Discussion
[Key points, decisions, insights]

## Action Items
- [ ] [Action] — [Owner] — [Due date]
- [ ] [Action] — [Owner] — [Due date]

## Next Meeting
[Date, purpose]
```

---

## Interview Notes

### Where They Live

```
[project-repo]/notes/interviews/
├── 2025-01-12-jane-smith-program-director.md
├── 2025-01-13-bob-jones-it-lead.md
└── ...
```

### Interview Note Template

```markdown
# Interview: [Name]

**Role:** [Title]
**Date:** [Date]
**Interviewer:** [Your name]
**Duration:** [X minutes]

---

## Context
[Their role, how long they've been there, relationship to project]

## Key Quotes
> "[Direct quote that captures something important]"

> "[Another key quote]"

## Themes
- **[Theme 1]:** [What they said about it]
- **[Theme 2]:** [What they said about it]

## Constraints Mentioned
- [Constraint 1]
- [Constraint 2]

## Opportunities Mentioned
- [Opportunity 1]

## People They Mentioned
- [Name] — [Role] — [Should we talk to them?]

## Follow-up Needed
- [ ] [Question to clarify]
- [ ] [Document to request]

## Raw Notes
[Detailed notes from the conversation]
```

---

## Project README Template

Each project repo README should follow this structure:

```markdown
# [Project Name]

**Client:** [Client name]
**Timeline:** [Start] — [End]
**Phase:** [Current PIM phase]
**Status:** [On track / At risk / Blocked]

---

## Overview
[2-3 sentences: What is this project? What problem does it solve?]

## Team
| Role | Person |
|------|--------|
| Project Lead | [Name] |
| UX Strategist | [Name] |
| Designer | [Name] |
| Builder | [Name] |

## Key Links
- [Project Board](link to GitHub Projects)
- [Google Drive Folder](link)
- [FigJam Files](link)
- [Figma Design](link)
- [Live Site](https://[project].lab.cityfriends.tech)

## Phase Progress

| Phase | Status | Dates |
|-------|--------|-------|
| Ground | ✅ Complete | Jan 10-24 |
| Sense | 🔄 In Progress | Jan 24 - Feb 7 |
| Shape | ⬜ Not Started | |
| Test | ⬜ Not Started | |
| Embed | ⬜ Not Started | |

## Key Deliverables
- [x] Problem Statement — [link]
- [x] Stakeholder Snapshot — [link]
- [ ] Journey Map — in progress
- [ ] Solution Options — upcoming

## Recent Updates
- **[Date]:** [What happened]
- **[Date]:** [What happened]

---

*This project follows the [Public Impact Method](link to playbook).*
```

---

## Quick Reference

### New Project Setup

1. Run spinup: `spinup project-slug "Project Name"`
2. Create GitHub Project board (kanban)
3. Add phase labels to repo
4. Create project folder in Google Drive
5. Copy relevant templates to Google Drive folder
6. Update README with links
7. Create FigJam file for visual work

### Daily Habits

- Update GitHub Issues as you work
- Move cards on the board
- Commit notes to repo (don't let them pile up)

### Weekly Habits

- Monday: Plan the week, assign issues
- Friday: Update README status, archive completed work

### Phase Transitions

- Ensure all deliverables are in `docs/[phase]/`
- Update README phase status
- Close phase-related issues
- Create issues for next phase
- Client sign-off documented

---

## Tool Access

| Tool | How to Get Access |
|------|------------------|
| GitHub (friends-innovation-lab) | Invite from Project Lead |
| Google Drive (Templates) | Shared folder link |
| FigJam/Figma | Invite from Designer |
| Vercel | Invite from Builder |
| Supabase | Invite from Builder (if project uses database) |

---

*This guide is part of the Friends Innovation Lab Playbook. See operations/ for related guides.*
