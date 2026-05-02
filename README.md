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
- Live at a real URL (`[name].lab.cityfriends.tech`) in under 3 minutes
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
- [Type-aware spinup guide](docs/spinup-typed.md) — full spinup script reference
- [AI workflow with CC](reference/building/ai-workflow.md) — working with Claude Code
- [Starter prompts](reference/prompts/README.md) — prompt templates for common tasks
- [Design system](reference/building/design-system.md) — Friends brand and component conventions
- [Demo standards](reference/delivering/demo-standards.md) — preparing for client demos
- [Submission checklist](reference/delivering/submission-checklist.md) — preparing for submissions
- [Prototype lifecycle](reference/operations/prototype-lifecycle.md) — wrapping up a project
- [Teardown script](automation/README.md) — removing a project's resources

## Playbook structure

The playbook has two parts:

### Workflow docs (numbered folders)
Read these in order. They cover the end-to-end process of
working in the Innovation Lab — from getting set up to
building and shipping prototypes.

- `01-getting-started/` — Setup, orientation, first test project
- `02-running-a-project/` — Creating, running, troubleshooting, and ending projects

### Reference docs
Dip into these as needed. They are SOPs and reference material
for specific topics — not meant to be read start to finish.

- `automation/` — Spinup and teardown scripts
- `reference/building/` — Design system, AI workflow, Storybook
- `reference/prompts/` — Starter prompts for common tasks
- `reference/delivering/` — Demo standards, submission checklists, handoff
- `reference/operations/` — Prototype lifecycle, costs, offboarding
- `reference/development/` — Technical standards: code quality, testing, security, deployment
- `reference/products/` — Standalone product documentation (Qori, Truebid)
- `_archive/` — Retired content preserved for reference

---
New to the lab? Start with `01-getting-started/`.
Starting a project? Go to `02-running-a-project/01-creating-a-project.md`.
Looking for technical standards? Go to `reference/development/`.

---

Friends Innovation Lab is a division of Friends From The City (FFTC)
