# Friends Innovation Lab — Playbook

The operational manual for running the Innovation Lab. Everything a builder
needs to go from zero to a live prototype.

**Who is this for?** Friends Innovation Lab builders — developers, designers,
and project leads working on government prototypes and internal tools.

## What we do

Friends Innovation Lab is the rapid prototyping division of Friends From The
City (FFTC). We build working prototypes for government procurement challenges and internal tools
for FFTC operations.

Every project we spin up is:
- Live at a real URL (`[name].lab.cityfriends.tech`) in under ten minutes
- Built on a consistent stack (Next.js, TypeScript, Supabase, Vercel, Railway)
- Accessible by default (WCAG 2.1 AA, Section 508)
- Ready to demo to a client or evaluator

## How to use this playbook

> [!IMPORTANT]
> **New here? Start with [START-HERE.md](START-HERE.md).** It's a quick read that explains what the lab is, what it can do, and how the rest of the docs walk you through getting set up.

Once you've read START-HERE, the path forward is laid out there. Below is a quick reference for finding specific docs once you know what you're looking for.

**Already set up and looking for something specific?**

- [First-time setup](01-getting-started/01-first-time-setup.md) — for new machines
- [Creating a project](02-running-a-project/01-creating-a-project.md) — for real projects
- [Claude.ai project starter](02-running-a-project/claude-ai-project-starter.md) — orchestrator config for new projects
- [Challenge response playbook](02-running-a-project/04-challenge-response.md) — for federal procurement responses
- [Troubleshooting](02-running-a-project/03-troubleshooting.md) — when things break
- [Type-aware spinup guide](docs/spinup-typed.md) — full spinup script reference
- [AI workflow with CC](reference/building/ai-workflow.md) — working with Claude Code
- [Starter prompts](reference/prompts/) — prompt templates for common tasks
- [Design system](reference/building/design-system.md) — Friends brand and component conventions
- [Demo standards](reference/delivering/demo-standards.md) — preparing for client demos
- [Submission checklist](reference/delivering/submission-checklist.md) — preparing for submissions
- [Prototype lifecycle](reference/operations/prototype-lifecycle.md) — wrapping up a project
- [Lab automation](automation/README.md) — spinup, teardown, lab tooling
- [Onboarding a new Friend](reference/operations/onboarding-a-new-friend.md) — adding team members

## Playbook structure

The playbook has three parts:

### Sequenced docs (numbered folders)
Read these in order. They cover what new Friends do — first when
joining the lab, then when running real projects.

- `01-getting-started/` — Setup, orientation, your first test project
- `02-running-a-project/` — Creating, running, and ending real projects

### Reference material (look up when needed)
Topic-organized reference docs. Dip in when you need them; not
meant to be read start to finish.

- `reference/building/` — AI workflow, design system, design tokens, agency theming, Storybook
- `reference/prompts/` — Starter prompts for common project types
- `reference/delivering/` — Demo standards, submission checklist, handoff
- `reference/operations/` — Costs, offboarding, prototype lifecycle, onboarding-a-new-friend
- `reference/design/` — UI/UX guide
- `reference/development/` — Technical standards: code quality, testing, security, deployment, git workflow
- `reference/products/` — Standalone product documentation (Qori, Truebid)
- `reference/_archive/` — Retired content preserved for reference

### Lab automation
Scripts and supporting files for the lab itself.

- `automation/` — Spinup script, teardown script, templates, lab tooling
- `docs/` — Deeper technical docs the playbook references
- `_archive/old-pre-reorg/` — Files retired during the May 2026 reorganization

---
New to the lab? Start with [`START-HERE.md`](START-HERE.md).
Starting a project? Go to [`02-running-a-project/01-creating-a-project.md`](02-running-a-project/01-creating-a-project.md).
Looking for technical standards? Go to [`reference/development/`](reference/development/).

---

Friends Innovation Lab is a division of Friends From The City (FFTC). The Treehouse is what we call it.
