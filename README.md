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
- Live at a real URL (`[name].labs.cityfriends.tech`) in under 3 minutes
- Built on a consistent stack (Next.js, TypeScript, Supabase, Vercel)
- Accessible by default (WCAG 2.1 AA, Section 508)
- Ready to demo to a client or evaluator

## How to use this playbook

> [!IMPORTANT]
> **New here? Start with [START-HERE.md](START-HERE.md).** It's a quick read that explains what the lab is, what it can do, and how the rest of the docs walk you through getting set up.

Once you've read START-HERE, the path forward is laid out there. Below is a quick reference for finding specific docs once you know what you're looking for.

**Already set up and looking for something specific?**

- [First-time setup](01-getting-started/01-first-time-setup.md) — for new machines
- [Creating a project](01-getting-started/04-creating-a-project.md) — for real projects
- [Type-aware spinup guide](docs/spinup-typed.md) — full spinup script reference
- [AI workflow with CC](03-building/ai-workflow.md) — working with Claude Code
- [Starter prompts](03-building/prompts/README.md) — prompt templates for common tasks
- [Design system](03-building/design-system.md) — Friends brand and component conventions
- [Demo standards](04-delivering/demo-standards.md) — preparing for client demos
- [Submission checklist](04-delivering/submission-checklist.md) — preparing for submissions
- [Prototype lifecycle](05-operations/prototype-lifecycle.md) — wrapping up a project
- [Teardown script](operations/automation/README.md) — removing a project's resources

## Playbook structure

The playbook has two parts:

### Workflow docs (numbered folders)
Read these in order. They cover the end-to-end process of
working in the Innovation Lab — from getting set up to
building and shipping prototypes.

- `01-getting-started/` — Setup, onboarding, creating and ending projects
- `02-spinup/` — Spinup and teardown scripts
- `03-building/` — Design system, AI workflow, starter prompts, Storybook
- `04-delivering/` — Demo standards, submission checklists, handoff
- `05-operations/` — Prototype lifecycle, costs, offboarding

### Reference docs (unnumbered folders)
Dip into these as needed. They are SOPs and reference material
for specific topics — not meant to be read start to finish.

- `development/` — Technical standards: code quality, testing,
  security, deployment, git workflow
- `operations/` — Automation scripts and lab tooling
- `products/` — Standalone product documentation (Qori, Truebid)
- `_archive/` — Retired content preserved for reference

---
New to the lab? Start with `01-getting-started/`.
Starting a project? Go to `01-getting-started/04-creating-a-project.md`.
Looking for technical standards? Go to `development/`.

---

Friends Innovation Lab is a division of Friends From The City (FFTC)
