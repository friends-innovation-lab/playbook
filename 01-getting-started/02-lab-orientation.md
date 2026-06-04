# Lab Orientation

A short read before your first project. The Friends Innovation Lab has a few moving parts that are worth understanding before you encounter them. This doc explains what they are, why they exist, and how they fit together.

You don't need to memorize any of this. You need to recognize the words when you see them.

> [!NOTE]
> **If you remember nothing else from this doc:**
>
> - Local changes (on your machine) are not live until you push to GitHub and a deployment completes
> - Adding a value to `.env.local` does not put it in Vercel — you have to add it in both places
> - When something breaks, check the CI checks on your pull request first — the error message almost always tells you what's wrong

**Reading time:** about 10 minutes.

**Jump to:** [The four repos](#the-four-repos) · [Project types](#project-types) · [Extensions](#extensions) · [Lab standards](#lab-standards) · [How design connects to code](#how-design-connects-to-code) · [Local vs. live](#local-vs-live) · [What CI does](#what-ci-does-for-you) · [Tools you'll touch](#tools-youll-touch) · [Quick reference](#quick-reference)

---

## The four repos

The Friends Innovation Lab is built across four GitHub repositories. Knowing what each one does helps everything else make sense.

```
lab-standards
  │ defines standards
  ▼
project-template
  │ inherits standards, adds base code + extensions
  ▼
playbook
  │ spinup script pulls from project-template
  ▼
Your Project (e.g. qori, truebid)
  ├── docs/standards/    ← copy of standards
  ├── docs/decisions/    ← project-specific ADRs
  ├── .github/workflows/ ← workflows from templates
  └── CLAUDE.md          ← AI assistant context
```

**[`lab-standards`](https://github.com/friends-innovation-lab/lab-standards)** — The rulebook. Nine documents describing how the lab builds software (security, performance, accessibility, data governance, and more). Also contains an audit script that can check any project against those standards. You won't edit this. You'll read it when you want to understand why something works the way it does.

**[`project-template`](https://github.com/friends-innovation-lab/project-template)** — The seed. Every new project gets created from this template. It contains the base code, the CI workflows, the design system foundation, and three reusable extensions (more on those below). When the template improves, future projects get the improvements. Existing projects don't auto-update.

**[`playbook`](https://github.com/friends-innovation-lab/playbook)** — Where you are right now. The operational manual. How to set up your machine, how to start projects, how to build features, how to demo and ship. Documentation for humans, not code.

**Your project repo** — Created when you run the spinup script. Lives under `friends-innovation-lab` on GitHub. Inherits the tech stack, the CI workflows, the standards, and whichever extensions match the project type you chose.

The relationship is one-directional: lab-standards informs project-template, project-template seeds your project repo, and the playbook tells you how to use all of it.

### What you get when you spin up

When you run the spinup script, the new project automatically gets:

- **The base code** — Next.js, TypeScript, Tailwind, shadcn/ui scaffolding from the project-template
- **Lab standards** — All nine standards copied into `docs/standards/` for reference
- **Extensions** — Whichever of the three extensions match your project type (more on those below)
- **CI workflows** — All eight-plus automated checks configured in `.github/workflows/`
- **Branch protection** — `main` branch protected; you work on `develop` and feature branches
- **CLAUDE.md** — A starter file that gives Claude Code context about the project
- **Initial issues** — A starter set of GitHub issues based on the project type (when applicable)
- **Live URL** — A subdomain at `[your-project].lab.cityfriends.tech`
- **Live database** — A Supabase project with credentials auto-populated to `.env.local`

You don't configure any of this. The spinup script does it. Your job is to start building.

---

## Project types

The spinup script asks what kind of project you're building. Five types. Each comes with different scaffolding because different projects need different things.

| Type | When to use it | What you get |
|------|----------------|--------------|
| **Prototype** | Proposals, demos, validating an idea quickly | Base template only — fast and minimal |
| **Internal tool** | Something Friends uses ourselves | Audit logging, soft deletes |
| **SaaS web** | A product with multiple paying customers | Multi-tenancy, audit logging, soft deletes |
| **AI product** | A SaaS product with AI-driven features | Multi-tenancy, audit logging, soft deletes |
| **Federal** | Government client work | Audit logging, soft deletes |

Most lab work falls into prototype or federal. SaaS web and AI product matter more for long-term products like Truebid or Qori.

The choice isn't permanent. A prototype that turns out to be promising can be rebuilt as a SaaS web project later. The work transfers, even if the foundation doesn't.

---

## Extensions

An extension is a packaged piece of functionality that the spinup script can layer onto a base project. The Friends Innovation Lab has three.

**Multi-tenancy** — System for serving multiple separate customers from a single application without their data mixing. Like how Slack keeps your company's workspace separate from other companies'.

- Adds: organizations and members tables
- Enforces: RLS policies that determine who sees what
- For: SaaS products with multiple paying customers
- Skipped on: prototypes (usually) and federal projects

**Audit logging** — Records every important action: who did what, when, and to what.

- Adds: an `audit_log` table (append-only — entries can't be edited or deleted)
- Provides: a helper for recording entries from application code
- For: security compliance and debugging
- Required: anywhere data sensitivity matters

**Soft deletes** — Marks records as deleted with a timestamp instead of permanently removing them.

- Adds: a `deleted_at` column to relevant tables
- Updates: queries to ignore deleted rows by default
- Provides: helpers for recovery
- For: products handling sensitive data, where accidental deletion is costly

When you pick a project type, the spinup script applies the right extensions automatically. You don't choose individually.

---

## Lab standards

Nine documents in [`lab-standards`](https://github.com/friends-innovation-lab/lab-standards). They describe how the lab builds — what counts as good code, how data should be handled, what accessibility means in practice.

The lab does federal and civic technology work. That means accessibility, data governance, and security aren't optional — they're contractual requirements baked into how every project gets built. The standards exist so the lab can ship work that holds up under federal evaluation, agency security review, and accessibility audits without scrambling at the end.

Standards get copied into every spun-up project at `/docs/standards/`. Your project owns its copy. When the lab updates a standard, projects don't auto-update — each project decides whether to sync the new version or document a deviation in an ADR (architecture decision record).

The standards are:

- **Standards index** — How to navigate the rest
- **Enterprise readiness** — Security, compliance, multi-tenancy, vendor management
- **Performance** — Bundle budgets, page speed, Core Web Vitals
- **Engineering operations** — CI/CD, branching, code review, releases
- **Data governance** — Classification, retention, PII handling
- **Accessibility** — WCAG 2.2 AA, Section 508, VPAT
- **Architecture decisions** — When and how to write ADRs
- **Retrofit playbook** — Bringing existing projects up to standard
- **AI-assisted development** — Working with AI tools and agents

> [!TIP]
> You don't need to read all nine before your first project. You'll find that most of them describe what's already built into the foundation. They're there when a question arises and you want the authoritative answer.

### Checking your project against standards

The `lab-standards` repo includes an audit script that checks any project against the standards. Run it from your project root:

```bash
bash ~/Projects/lab-standards/lab-templates/scripts/audit-project.sh
```

It reports which standards your project meets, which it deviates from, and which it doesn't address. The output is informational — it doesn't change anything in your project. Useful before submission to confirm a project is in good shape, or any time you want a structured view of where your project stands.

---

## How design connects to code

The lab has one design workflow: Claude Design → Claude Code. Both prototypes and federal projects follow it.

The lab maintains multiple design systems in Claude Design, accessible at the org level. Which one you use depends on the project:

| Project type | Design system |
|--------------|---------------|
| Internal tool | FFTC Design System |
| Prototype, SaaS web, AI product | FFTC Design System (default) |
| Federal | USWDS Design System |
| Client-specific work | The matching client system (CMS, VA, etc.) |

**Starting a new project.** Open Claude Design and click the **Design systems** tab. Pick the system that matches your project type. The system loads with all its conventions — colors, type rules, components — and the agent designs in-system from the first turn.

> [!WARNING]
> Don't start a new prototype without picking a design system. Without one, the agent will reinvent the look from scratch — losing every token, type rule, and component pattern the lab maintains.

**Already working in a project.** Open the attach menu (the `+` icon in the chat input). Under "Attach designs," click **Design system** and select the right one. The agent copies the CSS and preview files into your project and uses the system from that point forward.

1. Designer opens Claude Design (design system loaded at the org level — colors, typography, components, spacing all come pre-configured; USWDS is also loaded for federal projects)
2. Designer iterates on screens, including system states (loading, empty, error, success, hover, focus, disabled, mobile)
3. Designer clicks "Hand off to Claude Code" — downloads a folder of design specs (HTML, CSS, tokens, a `/fixtures/` folder of typed mock data, and a README explaining the components)
4. The folder goes into the spun-up project at `/design-handoff/`
5. Claude Code implements it using the project-template's React + Tailwind + shadcn/ui stack

Icons in Claude Design use Lucide, the same icon library the project-template uses. No translation needed.

> [!IMPORTANT]
> The `/fixtures/` folder is part of the handoff, not an afterthought. Components render off the fixtures (not hardcoded values), which is what lets Claude Code swap fixtures for real data later without component surgery. See [01-creating-a-project.md](../02-running-a-project/01-creating-a-project.md#phase-2--design) for the design workflow in full.

### Where Figma fits

Figma is no longer a step in the design-to-code pipeline. Its only remaining role in lab work is an optional archive step at the end of a project — when a client requires Figma deliverables, when a future designer will pick up the work, or when a federal handoff demands Figma assets. Most projects skip Figma entirely. See "Archiving to Figma (optional)" in [01-creating-a-project.md](../02-running-a-project/01-creating-a-project.md#archiving-to-figma-optional).

---

## Local vs. live

This concept catches people more than any other. Worth understanding clearly.

When you work on a project, three different environments are running the same code:

- **Local development** — Your machine. Run `npm run dev` in your terminal. Site loads at `http://localhost:3000`. Only you can see it. Changes appear instantly when you save files.

- **CI environment** — GitHub's servers, briefly, every time you push code. Runs all the automated checks (tests, security scans, accessibility, bundle budgets). Doesn't deploy anywhere — just confirms the code is okay before letting it merge.

- **Live deployment** — Vercel's servers. Runs the actual public website at `[your-project].lab.cityfriends.tech`. Updates automatically when code merges to main. This is what real users see.

- **Preview deployments** — Vercel also creates a preview URL for every pull request. These let you (and reviewers) see changes in a real browser before they merge. Preview URLs appear automatically in PR comments. They're throwaway — they disappear when the PR closes.

These three environments are *mostly* the same code, but they read configuration values from different places.

**Configuration values** are things like database URLs, API keys, secret tokens. They can't be in the code itself (security), so they live in environment files:

- **Local config** — `.env.local` in your project folder. You add values there for local development.
- **CI config** — workflow YAML files. The lab uses placeholder values so dependabot PRs don't break.
- **Live config** — Vercel's environment variable settings. The spinup script puts the right values there automatically.

> [!IMPORTANT]
> Adding a value to `.env.local` does not put it in Vercel. Your local dev works, your deployed site doesn't, and the difference is invisible until you check. If you ever encounter a "works on my machine" mystery, this is the cause 80% of the time.

When you add a new environment variable to a project, you have to add it in both places — `.env.local` for your local work, and Vercel's settings for the live site. The spinup script and CC handle most of these for you. The cases where you'll add them manually are rare but worth knowing about.

---

## What CI does for you

CI stands for continuous integration. In practice, it means: every time you push code to GitHub, a sequence of automated checks runs against your code before it can merge.

For lab projects, CI runs eight or more checks:

- **Lint** — Catches code style issues
- **Type check** — Catches TypeScript errors
- **Unit tests** — Runs your code's tests
- **Build** — Confirms the project actually builds
- **Bundle size** — Confirms the built site isn't too heavy
- **Accessibility** — Scans for WCAG violations
- **Secret scan** — Checks for leaked API keys
- **Dependency scan** — Checks for known vulnerabilities in libraries
- **License check** — Ensures all dependencies have approved licenses

> [!NOTE]
> A pull request can't merge until these pass (with rare exceptions you'll learn about). Green checkmarks in your PR mean you're safe to merge.

This sounds like a lot. In practice, you'll rarely think about it. You write code, you push, you see green checks, you merge. The system catches problems before they reach production. When it fails, the error message tells you what broke.

Most lab CI runs complete in under three minutes.

---

## Tools you'll touch

A short tour of the tools that show up during a project. You'll learn them by using them — this is just so the names aren't strangers.

**VS Code** — Your code editor. Where you spend most of the day.

- Includes a built-in terminal (View → Terminal) for git, npm, gh, vercel, supabase, railway commands
- Lab work runs from the VS Code terminal — no separate terminal app needed

**Claude Code (CC)** — Your AI coding assistant. Lives inside VS Code as a sidebar.

- Talk to it in plain English; it writes and modifies code
- Most lab work happens through CC, not by typing code line by line

**Claude Design** — Browser-based. The lab's design tool. The Friends design system is loaded at the org level for all projects, and USWDS is loaded for federal projects, so designs start with the right conventions baked in. Produces handoff folders (HTML, CSS, tokens, `/fixtures/`, README) that go directly to Claude Code for implementation. The only design tool in the lab's workflow.

**Figma** — Used only as an optional archive step at the end of a project, when a client requires Figma deliverables or a federal handoff demands them. Not part of the active design-to-code path.

**Storybook** — Component documentation that ships inside every project.

- Run `npm run storybook` in your project to view it
- Useful for verifying components in isolation
- Federal projects reference USWDS components in Storybook

**GitHub** — Where the code lives.

- You'll usually interact via the `gh` command-line tool, not the website
- Browser visits are mostly for PR review and project board

**Vercel** — Where deployed sites live.

- You'll glance at the dashboard to see deploy status
- Most of the time, deploys just happen automatically when you push

**Supabase** — The database.

- You'll see it during spinup, rarely after
- The application talks to it; you mostly don't

**Railway** — Where backend services and scheduled jobs run, when projects need them.

- Less common than Vercel for typical lab work
- Used for things like background workers, scheduled tasks, persistent backend services

You won't encounter Railway in a standard prototype or federal project. It only comes up for projects that need persistent backend services or scheduled jobs — which is rare in lab work. If a project needs it, your project lead will set it up.

**Sentry** — Error tracking for production projects.

- The lab uses Sentry on projects that need visibility into production errors. It's not a default — most prototypes and short-lived demos skip it.
- Sentry comes up when a project will run in production with real users, when silent failures would have real consequences (auth, payments, anything user-facing), or when error triage needs to happen before users complain.
- When a project needs Sentry, Lapedra provides the Sentry org access and project credentials at kickoff. The Sentry project URL gets documented in the project's CLAUDE.md so future CC sessions know it exists.

> [!NOTE]
> When a project is decommissioned, the Sentry project gets archived as part of the teardown checklist (see [02-ending-a-project.md](../02-running-a-project/02-ending-a-project.md)).

> [!NOTE]
> You don't need to create accounts for these yourself. The lab provisions your access during onboarding.

---

## Quick reference

Things to recognize when you encounter them:

| When you see... | It means... |
|-----------------|-------------|
| `--type prototype` (or any other type) | The kind of project being created |
| `multi-tenancy`, `audit-log`, `soft-deletes` | The three extensions |
| `.env.local` | Configuration values for your local development |
| `lab.cityfriends.tech` | The lab's domain for deployed prototypes |
| `friends-innovation-lab` on GitHub | The org all lab projects live under |
| `/docs/standards/` in a project | The lab standards copied into that project |
| Hand off to Claude Code | Claude Design's export — a folder of design specs (HTML, CSS, tokens, `/fixtures/`, README) for Claude Code to implement |
| Lucide icons | The icon library used in both Claude Design and the project-template — the same icons end up in your code |
| Green checkmarks on a PR | CI checks passed; safe to merge |
| Red X on a PR | A check failed; click for details |
| The Treehouse | What we call the Friends Innovation Lab internally |
| `~/Projects/` | The folder on your Mac where all lab projects live locally |
| `--resume` flag on the spinup script | Supabase didn't finish provisioning during spinup — run this to finish the setup once it's ready: `./automation/spinup-typed.sh --name your-project-name --resume` |
| Supabase keys empty in `.env.local` | Supabase was still provisioning when spinup ran — see the [troubleshooting doc](../02-running-a-project/03-troubleshooting.md#supabase-keys-are-empty-after-spinup) |

---

## What's next

Now you know the territory. The concepts won't be strangers when you encounter them.

Next: a real test project, walked through step by step. You'll spin up a project, make a change with CC, see it deploy, and tear it down. No stakes. Just practice.

→ [`03-your-first-project.md`](03-your-first-project.md)
