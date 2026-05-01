# Welcome to the Treehouse

Hi Friends.

The Treehouse Innovation Lab is finally up. This is where we go to be creative, but ready. The two things together — that's the whole point.

Read this once, all the way through. It won't take long. By the end you'll know what the lab is, what it can do, and how the rest of the docs walk you through getting set up. When a real project lands, the steps will already feel familiar.

**Jump to:** [Why](#why-the-treehouse-exists) · [What it does](#what-the-treehouse-does) · [What can be built](#what-can-be-built-here) · [How a project goes](#how-a-project-actually-goes) · [Under the hood](#whats-under-the-hood) · [Path from here](#the-path-from-here)

---

## Why the Treehouse exists

The federal contracting landscape is changing. Agencies want to see working prototypes, not slide decks. Teams that can show up with something real and functional — fast — win more work. Friends has the skills to compete at that level. The Treehouse is what makes it possible to move at that speed.

Beyond proposals, this is also where Friends thinks. Internal tools, product ideas, experiments — anything that needs to go from concept to working software lives here. The lab is built for both: quick prototypes that win contracts, and serious products that scale into something bigger.

Either way, the work has to be ready. Real production pipelines. Real security. Real accessibility. Real performance. The Treehouse handles all of that quietly so the team can focus on the creative work and on shipping.

---

## What the Treehouse does

The Treehouse is a system for going from "we have an idea" to "there's a working prototype on the internet" in under ten minutes.

That's not a metaphor. Ten minutes, a real URL, a real database, a real deployed app. Every project that gets spun up from this lab includes:

- A live website at `[your-project-name].lab.cityfriends.tech`
- A GitHub repository where the code lives
- A Supabase database (if the project needs one)
- A Vercel deployment that updates every time code is pushed
- A Railway deployment for backend services or scheduled jobs
- An accessibility-tested, performance-budgeted, security-scanned foundation already wired in

> [!IMPORTANT]
> This isn't prototype-quality infrastructure dressed up to look real. It's a real production pipeline. Same CI workflows, same security scans, same compliance checks that any serious software product would have. Whatever gets built here can be hardened into a shipped product without rebuilding the foundation.

One script handles the setup. The script does the rest.

---

## What can be built here

The Treehouse handles five kinds of projects:

| Type | Use for | What's included |
|------|---------|-----------------|
| **Prototype** | Proposals, demos, validating an idea quickly | Fast and lightweight, built to move |
| **Internal tool** | Something Friends uses internally | Audit logging, soft deletes, designed for FFTC's own work |
| **SaaS web** | A real product with multiple customers | Multi-tenancy, organizations, the whole stack |
| **AI product** | Products with AI-driven features | SaaS web foundation, room to grow into AI |
| **Federal** | Government clients | Audit logging, soft deletes, designed for compliance |

No need to memorize this list. The spinup script asks which kind, and the right scaffolding gets applied automatically.

---

## How a project actually goes

Once setup is done — which comes later — every project follows the same shape.

**1. The brief lands.** Could be a proposal, an internal need, a product idea. The team will discuss it before any tools open. Sometimes it'll come fully scoped. Either way, the goal is clear before anyone touches a keyboard.

**2. Design comes first.** Open Claude Design. Walk through the brief. Iterate on screens until there's a Figma file the team is happy with. This part is free — no infrastructure exists yet, no costs, nothing to undo. Change direction ten times if needed. By the end of design, the build is clear.

**3. Spin it up.** Run the spinup script. Pick a name, pick a type, answer a few questions. Ten minutes later, a live URL exists.

**4. Build it.** Open Claude Code in VS Code — we call it CC for short. Point it at the Figma file. Tell it what to implement. CC reads the design and writes the code. Iterate on what doesn't look right. The lab's CI workflows make sure the code passes accessibility, security, and performance checks before anything goes live.

**5. Polish and ship.** Demo it. Submit it. Hand it off. If it's a real product, keep building.

That's the loop.

---

## What's under the hood

Knowing this isn't required to use the lab, but it's worth seeing what's there. Hidden inside the ten-minute spinup:

- A vetted tech stack: Next.js, TypeScript, Tailwind, Supabase, Vercel, Railway
- Three working extensions: multi-tenancy with proper data isolation, audit logging for compliance, soft deletes for safety
- CI workflows: linting, type-checking, unit tests, accessibility scans, security scans, license compliance, bundle budgets, dependency vulnerability tracking
- A design system (Friends brand colors, typography, components) and an agency theme system (USWDS for federal projects)
- Lab standards documenting how the work gets done (security, performance, accessibility, data governance, architecture decisions, AI-assisted development)
- An audit script that checks any project against those standards
- A retrofit playbook for bringing existing projects up to standard

When something feels easy, it's because the work is done. The Treehouse handles the engineering rigor so the creative work gets the attention.

---

## The path from here

> [!NOTE]
> Nobody needs to do everything at once. The path below is sequenced so that each step earns its place before the next one.

**Today, or whenever there's an hour:** Set up the machine. Install the tools, set up the accounts, configure the credentials. Done once, done forever.
→ [`01-getting-started/01-first-time-setup.md`](01-getting-started/01-first-time-setup.md)

**Before the first real project:** Get oriented. There's a doc that walks through the high-level concepts — what project types mean, what extensions do, how the pieces fit together. Read it once. It's not long.
→ [`01-getting-started/02-lab-orientation.md`](01-getting-started/02-lab-orientation.md)

**Once setup and orientation are done:** Run a test project. Spin one up, make some changes with CC, see the live URL, tear it down at the end. No stakes. Just practice.
→ [`01-getting-started/03-your-first-project.md`](01-getting-started/03-your-first-project.md)

**Then the team meets.** A debrief after the test project. What felt good, what was confusing, what didn't work. The lab gets better from what gets surfaced in those conversations.

**When a real project comes:** The detailed how-to is ready. By then, the steps will already feel familiar.
→ [`01-getting-started/04-creating-a-project.md`](01-getting-started/04-creating-a-project.md)

---

## A few things to know

> [!TIP]
> Asking is encouraged. This is the first version of the Treehouse. Some things will be unclear. Some commands might fail in ways the docs don't predict. When that happens, ask. Better to flag a confusing step ten times than have anyone struggle in silence.

**The docs will keep improving.** As Friends use the lab, rough spots will surface. They'll get fixed. The version of the playbook six months from now will be better than this one because of what gets reported back.

**This isn't only for developers.** The spinup script handles the technical setup. CC handles the code. The job here is knowing what to build and being willing to ask CC for it clearly. Anyone who can describe what they want can build here.

**This is meant to feel possible.** If at any point it feels like too much — too many tools, too many concepts, too many steps — that's a docs problem, not a Friends problem. Surface it. It'll get fixed.

---

## What's next

If this is a first read, that's enough for now. Close the doc. Come back when there's an hour to set up the machine.

| Where you are | Where to go next |
|---------------|------------------|
| Just finished reading this | [First-time setup](01-getting-started/01-first-time-setup.md) |
| Setup is done | [Lab orientation](01-getting-started/02-lab-orientation.md) |
| Setup and orientation are done | [Your first project](01-getting-started/03-your-first-project.md) |
| Ready for a real project | [Creating a project](01-getting-started/04-creating-a-project.md) |

Welcome to the Treehouse.

---

*Friends Innovation Lab is a division of Friends From The City. The Treehouse is what we call it.*
