# Lab Orientation

A short read before your first project. The Treehouse has a few moving parts that are worth understanding before you encounter them. This doc explains what they are, why they exist, and how they fit together.

You don't need to memorize any of this. You need to recognize the words when you see them.

**Reading time:** about 10 minutes.

**Jump to:** [The four repos](#the-four-repos) · [Project types](#project-types) · [Extensions](#extensions) · [Lab standards](#lab-standards) · [How design connects to code](#how-design-connects-to-code) · [Local vs. live](#local-vs-live) · [What CI does](#what-ci-does-for-you) · [Tools you'll touch](#tools-youll-touch) · [Quick reference](#quick-reference)

---

## The four repos

The Treehouse is built across four GitHub repositories. Knowing what each one does helps everything else make sense.

**`lab-standards`** — The rulebook. Nine documents describing how the lab builds software (security, performance, accessibility, data governance, and more). Also contains an audit script that can check any project against those standards. You won't edit this. You'll read it when you want to understand why something works the way it does.

**`project-template`** — The seed. Every new project gets created from this template. It contains the base code, the CI workflows, the design system foundation, and three reusable extensions (more on those below). When the template improves, future projects get the improvements. Existing projects don't auto-update.

**`playbook`** — Where you are right now. The operational manual. How to set up your machine, how to start projects, how to build features, how to demo and ship. Documentation for humans, not code.

**Your project repo** — Created when you run the spinup script. Lives under `friends-innovation-lab` on GitHub. Inherits the tech stack, the CI workflows, the standards, and whichever extensions match the project type you chose.

The relationship is one-directional: lab-standards informs project-template, project-template seeds your project repo, and the playbook tells you how to use all of it.

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

An extension is a packaged piece of functionality that the spinup script can layer onto a base project. The Treehouse has three.

**Multi-tenancy** — The system that makes a single piece of software work for multiple separate customers without their data mixing. If you've ever used Slack and noticed your company's workspace doesn't see other companies' messages, that's multi-tenancy. SaaS products need it. Prototypes usually don't. The extension adds the database tables (organizations, members), the rules (RLS policies that enforce who sees what), and the helper code that ties them to the application.

**Audit logging** — Every important action gets recorded. Who did what, when, and to what. Required for security compliance and useful for debugging. The extension creates an `audit_log` table, makes it append-only (entries can't be edited or deleted), and provides a small helper for recording entries from application code.

**Soft deletes** — Instead of permanently deleting records, mark them as deleted with a timestamp. Recoverable, auditable, safer. Especially important for products handling sensitive data. The extension adds a `deleted_at` column to relevant tables, updates queries to ignore deleted rows by default, and provides helpers for recovery.

When you pick a project type, the spinup script applies the right extensions automatically. You don't choose individually.

---

## Lab standards

Nine documents in `lab-standards`. They describe how the lab builds — what counts as good code, how data should be handled, what accessibility means in practice. They get copied into every spun-up project at `/docs/standards/`.

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

When the lab updates a standard, projects don't auto-update. Each project decides whether to sync the new version or document a deviation in an ADR (architecture decision record).

---

## How design connects to code

The lab supports two design workflows depending on the designer and the project. Both end at Claude Code (CC) implementing the design.

### Workflow 1 — Claude Design straight to CC

The lab's primary design path. Best for prototypes and rapid work.

1. Designer opens Claude Design (the Friends design system is loaded at the org level — colors, typography, components, spacing all come pre-configured)
2. Designer iterates on screens
3. Designer clicks "Hand off to Claude Code" — downloads a folder of design specs (HTML, CSS, tokens, a README explaining the components)
4. The folder goes into the spun-up project
5. CC implements it using the project-template's React + Tailwind + shadcn/ui stack

Icons in Claude Design use Lucide, which is the same icon library the project-template uses. No translation needed. No Figma involved.

### Workflow 2 — Claude Design through Figma to CC

For professional designers who want full design-tool refinement. Best for complex projects where designs need precise control before implementation.

1. Designer starts in Claude Design (same Friends design system loaded)
2. Designer uses Anima's Figma agent to bridge the design into Figma
3. Designer continues refining on the Figma canvas — fine detail, custom interactions, detailed specs
4. The Figma file goes to CC via the Figma MCP integration
5. CC implements

### For federal projects

Designs follow USWDS conventions (the U.S. Web Design System).

- Right now: federal designers use existing Figma files for USWDS conventions, plus Storybook for USWDS components
- Coming soon: a USWDS design system in Claude Design (in setup)

Until the USWDS Claude Design system is live, federal designs come from Figma + Storybook directly.

---

The choice between workflows isn't strict. A designer might start in Claude Design, decide a screen needs more refinement, move to Figma via Anima, then hand to CC. The point is that designs always end up at CC, and CC always implements against the project-template's code conventions. The path through is flexible.

---

## Local vs. live

This concept catches people more than any other. Worth understanding clearly.

When you work on a project, three different environments are running the same code:

**Local development** — Your machine. You run `npm run dev` in your terminal. The site loads at `http://localhost:3000`. Only you can see it. Changes appear instantly when you save files.

**CI environment** — GitHub's servers, briefly, every time you push code. Runs all the automated checks (tests, security scans, accessibility, bundle budgets). Doesn't deploy anywhere. Just confirms the code is okay before letting it merge.

**Live deployment** — Vercel's servers. Runs the actual public website at `[your-project].lab.cityfriends.tech`. Updates automatically when code merges to main. This is what real users see.

**Preview deployments** — Vercel also creates a preview URL for every pull request. These let you (and reviewers) see changes in a real browser before they merge. Preview URLs appear automatically in PR comments. They're throwaway — they disappear when the PR closes.

These three environments are *mostly* the same code, but they read configuration values from different places.

**Configuration values** are things like database URLs, API keys, secret tokens. They can't be in the code itself (security), so they live in environment files.

- **Local config** lives in `.env.local` in your project folder. You add values there for local development.
- **CI config** lives in workflow YAML files. The lab uses placeholder values here so dependabot PRs don't break.
- **Live config** lives in Vercel's environment variable settings. The spinup script puts the right values there automatically.

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

**VS Code** — Your code editor. Where you spend most of the day. Includes a built-in terminal (View → Terminal) — most of the lab's command-line work happens there: git commands, `npm` commands, the `gh`, `vercel`, `supabase`, and `railway` CLIs, and running the spinup script itself. You don't need a separate terminal app; the one inside VS Code is enough.

**Claude Code (CC)** — Lives inside VS Code as a sidebar. You talk to it in plain English, it writes code. Most lab work happens through CC, not by you typing code line by line.

**Claude Design** — Browser-based. The lab's primary design tool. The Friends design system is loaded at the org level, so designs start with Friends conventions baked in. Produces handoff folders (HTML, CSS, tokens, README) that go directly to CC for implementation. No Figma required for most lab work.

**Figma** — Where designs continue when professional designers want full design-tool refinement. The Anima Figma agent bridges from Claude Design into Figma when needed. Federal projects also use existing Figma files for USWDS conventions until the USWDS Claude Design system is set up.

**Storybook** — Component documentation that ships inside every project. Run `npm run storybook` to see it. Useful for verifying components in isolation. Federal projects reference USWDS components in Storybook.

**GitHub** — Where the code lives. You won't usually visit it in a browser; the `gh` command-line tool handles most interactions.

**Vercel** — Where deployed sites live. You'll glance at the dashboard occasionally to see deploy status. Most of the time, deploys just happen automatically when you push.

**Supabase** — The database. You'll see it during spinup and rarely after. The application talks to it; you mostly don't.

**Railway** — Where backend services and scheduled jobs run, when projects need them. Less common than Vercel for typical lab work.

> [!NOTE]
> You don't need accounts you create yourself for these. The lab handles your access during onboarding.

---

## Quick reference

Things to recognize when you encounter them:

| When you see... | It means... |
|-----------------|-------------|
| `--type=prototype` (or any other type) | The kind of project being created |
| `multi-tenancy`, `audit-log`, `soft-deletes` | The three extensions |
| `.env.local` | Configuration values for your local development |
| `lab.cityfriends.tech` | The lab's domain for deployed prototypes |
| `friends-innovation-lab` on GitHub | The org all lab projects live under |
| `/docs/standards/` in a project | The lab standards copied into that project |
| Hand off to Claude Code | Claude Design's export that produces a folder of design specs for CC to implement |
| Anima Figma agent | The bridge from Claude Design into Figma for designers who want full design-tool control |
| Lucide icons | The icon library used in both Claude Design and the project-template — the same icons end up in your code |
| Green checkmarks on a PR | CI checks passed; safe to merge |
| Red X on a PR | A check failed; click for details |
| The Treehouse | What we call the Innovation Lab internally |

---

## What's next

Now you know the territory. The concepts won't be strangers when you encounter them.

Next: a real test project, walked through step by step. You'll spin up a project, make a change with CC, see it deploy, and tear it down. No stakes. Just practice.

→ [`03-your-first-project.md`](03-your-first-project.md)
