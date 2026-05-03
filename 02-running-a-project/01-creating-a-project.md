# Creating a Project

Run this when you are ready to start a real project.
Do not run this as part of first-time setup — only run it when
you have a real project to spin up.

This doc covers the full lifecycle of a real project: planning, design, spinup, build, and ship. It assumes you've already completed [`02-lab-orientation.md`](../01-getting-started/02-lab-orientation.md) and [`03-your-first-project.md`](../01-getting-started/03-your-first-project.md), so the basic loop is familiar. Real projects add a planning phase, a design phase, and a different shape for the build itself.

> [!IMPORTANT]
> Spinup credentials are set up by Lapedra when you join the lab as a developer or project lead. If your role does not require spinning up new projects — for example if you are joining an existing project as a researcher or designer — you will not need these credentials and can skip the spinup section. Ask Lapedra which sections apply to your role.

---

## The build loop

Every project follows this loop:

```
Brief arrives
↓
Brainstorm + plan with Claude.ai (orchestrator)
↓
Generate planning artifacts (overview, PRD, epics, issues)
↓
Design with Claude Design (or Figma for refinement)
↓
Spinup script → infrastructure created
↓
CC builds from designs + planning artifacts
↓
Polish + accessibility
↓
Submit, demo, or ship
```

Planning and design come before spinup because the spinup script creates real infrastructure — a live database, deployed app, costs accruing. The planning and design phases are free — you brainstorm with Claude.ai, designers iterate in Claude Design, nothing is committed. By the time you run spinup you know exactly what you're building.

---

## Before you start

Make sure you have completed [`01-first-time-setup.md`](../01-getting-started/01-first-time-setup.md) and run through [`03-your-first-project.md`](../01-getting-started/03-your-first-project.md) at least once. The test project teaches you the spinup-to-deploy loop. This doc assumes you've done that loop and adds the planning, design, and real-project work around it.

If you're not sure all your tools are set up, run a dry-run of the spinup script — it checks everything before doing anything:

```bash
./automation/spinup-typed.sh --type prototype --name=dry-run-check --dry-run
```

The script will report what's missing if anything. Fix any issues before continuing.

---

## Before your first real spinup

You need one shared credential added to your shell profile if you haven't already. This is managed by Lapedra and shared across all lab projects — you set it once and every project uses it automatically.

Ask Lapedra for `LAB_SUPABASE_ORG_ID` if you don't already have it. (You should have received it during onboarding — check your credentials email.)

If you need to add it, open your shell profile in VS Code:

```bash
code ~/.zshrc
```

Add this line at the bottom:

```bash
# Friends Innovation Lab — shared credentials
export LAB_SUPABASE_ORG_ID="[value from Lapedra]"
```

Save the file, then reload your shell profile:

```bash
source ~/.zshrc
```

> [!IMPORTANT]
> Do this before running the spinup script for the first time. The script will fail pre-flight checks without it.

Some projects need additional credentials — transactional email (Resend), rate limiting (Upstash), AI APIs (Anthropic), agency-specific keys. These get provisioned per-project when the project actually needs them. Lapedra will give you the values during project kickoff if applicable. You don't need them for setup or for projects that don't use those services.

---

## Phase 1 — Plan with Claude.ai

This phase is about figuring out what you're actually building before you commit to building it. Skip this at your peril.

Open Claude.ai in your browser. Create a new Project (the Claude.ai feature, in the sidebar). Name it after your project.

**Add the orchestrator starter doc to your project files.**

The starter doc configures Claude.ai to act as your project orchestrator — it tells Claude what the lab is, what stack you use, what artifacts to produce, and how to work with you and Claude Code. Without it, Claude.ai operates with generic context. With it, Claude.ai knows the Friends Innovation Lab patterns and produces consistent project work.

Get the starter doc from the playbook at [`02-running-a-project/claude-ai-project-starter.md`](claude-ai-project-starter.md). Download it, then in your Claude.ai project, click "Add files" and upload it.

> [!TIP]
> The starter doc lives in the playbook so it stays current. Re-download it at the start of each project — the workflow improves over time, and you want the latest version.

**Tell Claude to read the starter doc and get started.**

Adding the file to project files doesn't mean Claude has read it. Send this as your first message in the chat:

```text
Read the claude-ai-project-starter.md file in this project.
Tell me what you understand about your role and how we'll work
together. Then we'll start brainstorming the project.
```

Claude will summarize back what it found — your role, the workflow, the artifact discipline. If anything in its summary looks wrong or incomplete, ask Claude to re-read the file. Once you're satisfied Claude has the context, move on to brainstorming.

**Brainstorm your project.**

Now talk to Claude.ai about what you're building. Where did the brief come from? Who is it for? What does success look like? What's out of scope? Go back and forth until the project takes shape. This is exploration, not execution — change direction as many times as you need.

When the project feels real and you're ready to commit, tell Claude.ai. It will move into generating planning artifacts.

**Generate the planning artifacts.**

Claude.ai will produce four artifacts in order:

1. **Project overview** — One page covering what this is, who it's for, what success looks like, what's out of scope. Save it to your Claude project files.
2. **PRD (Product Requirements Document)** — Full requirements: features, technical constraints, success criteria. Save it.
3. **Epic breakdown** — How the project decomposes into chunks of work, sequenced by dependency. Save it.
4. **Initial issue list** — Trackable units of work, each small enough for one CC session. You'll create these as GitHub issues after spinup.

These four artifacts are your contract with the project. They're what designers reference, what CC builds against, and what you review against when checking work.

> [!NOTE]
> The starter doc instructs Claude.ai to refuse to create artifacts beyond this list (plus ADRs and a roadmap when warranted) unless you specifically ask. This prevents documentation sprawl. If you genuinely want a different artifact, ask for it explicitly.

---

## Phase 2 — Design

Once planning is done, design starts. There are two design workflows depending on the designer and the project. Both end with CC implementing.

### Workflow 1 — Claude Design straight to CC

This is the lab's primary design path. Best for prototypes and rapid work.

The Friends design system is loaded into Claude Design at the org level — colors, typography, components, spacing all come pre-configured.

The designer:

1. Opens Claude Design
2. Iterates on screens with Claude Design
3. Clicks "Hand off to Claude Code" when the design is ready
4. Downloads the handoff folder (contains HTML, CSS, tokens, README)

The handoff folder gets dropped into the spun-up project repo at `/design-handoff/`. CC reads it during the build phase and implements using the project-template's React + Tailwind + shadcn/ui stack. Icons match because both Claude Design and the project-template use Lucide.

### Workflow 2 — Claude Design through Figma to CC

For professional designers who want full design-tool refinement. Best for complex projects where designs need precise control.

The designer:

1. Starts in Claude Design (same Friends design system loaded)
2. Uses Anima's Figma agent to bridge the design into Figma
3. Continues refining on the Figma canvas — fine detail, custom interactions, detailed specs
4. Shares the Figma file URL for the build phase

CC reads the Figma file via the Figma MCP integration. You'll need the [Figma plugin for Claude Code](#1-install-the-figma-plugin-for-claude-code) installed — see the builder section below.

### For federal projects

Designs follow USWDS conventions (the U.S. Web Design System).

Right now: federal designers use existing Figma files for USWDS conventions, plus Storybook for USWDS components. Reference these directly.

Coming soon: a USWDS design system in Claude Design.

Until the USWDS Claude Design system is live, federal designs come from Figma + Storybook directly.

---

## If you are a builder

Builders work directly with CC to implement designs and build features. If that is your role, you need two additional things set up before your first project.

### 1. Install the Figma plugin for Claude Code

This lets CC read and write to Figma files directly — needed for Workflow 2 above and for any work that uses Figma as a source of truth.

Open the terminal in VS Code (View → Terminal) and run:

```bash
claude plugin install figma@claude-plugins-official
```

Follow the prompts to authenticate with your Figma account.

> [!IMPORTANT]
> Make sure you are logged into the correct Figma account before clicking Allow — the one connected to the Innovation Lab org. Ask Lapedra to confirm which account to use.

**Verify it worked:** Type `claude` in the terminal to open CC, then type `/mcp` and look for `figma` in the installed list.

> [!TIP]
> Having trouble? See [Figma MCP not connecting](03-troubleshooting.md#figma-mcp-not-connecting)

### 2. Get access to the Innovation Lab Design System in Figma

Ask Lapedra to add you to the Innovation Lab Figma org so you can access:

- **Tokens file** — design variables (colors, typography, spacing)
- **Components file** — Button, Input, Badge, Card, Avatar
- **Templates file** — page-level designs for each prototype type (currently being built out)

You'll reference these files when working with CC on Figma-based work. Always paste the exact Figma file URL into your CC prompt so CC knows which file to read.

The three files:

- Tokens: <https://www.figma.com/design/MgWiTmboj3YSTUK8xRKzRt/Tokens>
- Components: <https://www.figma.com/design/zZFKdl9JDitNfnZkTGJYKR/Components>
- Templates: <https://www.figma.com/design/vqKtu40TwBNNUYnPH87PvB/Templates>

---

## Phase 3 — Spin up the project

You've planned and designed. Now you provision real infrastructure.

Make sure you are in your projects folder first:

```bash
cd ~/Projects/playbook
```

> [!WARNING]
> Run the spinup script from the playbook folder, not from another project folder. The script's relative paths assume this location.

Pick the right project type. Each type applies different scaffolding:

- `prototype` — Fast, lightweight. No extensions. For proposals, demos, validating quickly.
- `internal-tool` — Audit logging, soft deletes. For Friends' internal use.
- `saas-web` — Multi-tenancy, audit logging, soft deletes. For products with multiple customers.
- `ai-product` — Same as saas-web, with room to grow into AI features.
- `federal` — Audit logging, soft deletes, USWDS theme. For government clients.

Pick a name that's descriptive and lowercase with hyphens. For example: `va-benefits-prototype`, `truebid-rfp-import`, `proposal-fy26-q1`.

Run the spinup script with your type and name:

```bash
./automation/spinup-typed.sh --type=[type] --name=[project-name]
```

The script doesn't ask you anything during execution. It just runs. You'll see a banner showing what it's about to do, then pre-flight checks, then provisioning steps. Takes 5-10 minutes.

When it finishes, you'll have:

- A GitHub repo at `github.com/friends-innovation-lab/[project-name]`
- A live URL at `https://[project-name].lab.cityfriends.tech`
- A Supabase database (if not skipped)
- A Vercel deployment
- A `develop` branch set as the default working branch
- Branch protection on `main`
- Starter issues and a project board on GitHub

The script will print a summary with all the URLs. Save them somewhere.

> [!NOTE]
> Run this once after spinup to install the accessibility test browser:
>
> ```bash
> npx playwright install chromium
> ```

For full details on what the script does:
→ [`docs/spinup-typed.md`](../docs/spinup-typed.md)

---

## Phase 4 — Set up the project locally

The spinup script already cloned the project to `~/Projects/[project-name]` and configured the local environment file (`.env.local`) with the Supabase credentials your app needs to run. Open it in VS Code:

```bash
cd ~/Projects/[project-name]
code .
```

This opens the project in a new VS Code window. Confirm everything works by starting the dev server:

```bash
npm install
npm run dev
```

**Save the planning artifacts to the repo.** Take the project overview, PRD, and epic breakdown that Claude.ai produced in Phase 1, and save them to `/docs/` in the new project:

- `/docs/project-overview.md`
- `/docs/prd.md`
- `/docs/epics.md`

This makes them persistent and findable — not just living in the Claude.ai chat. When you (or anyone) looks at this project six months from now, the planning artifacts are right there in the repo.

**Save the design handoff to the repo** (if using Workflow 1). Take the handoff folder Claude Design produced and put it at `/design-handoff/` in the project. CC will read from there during the build phase.

**Create GitHub issues from the issue list.** Either manually create them, or ask Claude.ai to generate a `gh issue create` command for each one and run them in the terminal.

**Switch to the develop branch.** The spinup script set develop as the default, but if you cloned and ended up on main, switch:

```bash
git checkout develop
```

You'll work on develop and feature branches off develop for the rest of the project. Main stays untouched until release.

---

## Phase 5 — Build with the orchestrated loop

This is where Claude.ai, Claude Code, and you work together.

For each work unit (typically one issue at a time):

1. **Tell Claude.ai what you want to do next.** Reference the issue or describe the work.
2. **Claude.ai generates a CC prompt.** Clear, scoped, with the relevant context CC needs.
3. **Paste the prompt into CC.**
4. **CC produces a plan before implementing.** This is required by the starter doc — CC will list the files it'll modify, the changes it'll make, and any new dependencies. CC waits for explicit approval before doing the work.
5. **Paste CC's plan back into Claude.ai.** Claude validates: Does it match the intent? Are there missing considerations? Will it conflict with existing code?
6. **Claude.ai responds with "proceed" or specific adjustments.**
7. **Tell CC to proceed** (or to adjust per Claude.ai's notes).
8. **CC implements.**
9. **Tell Claude.ai what got built.** A sentence or two is fine. Claude updates project context.

Repeat for each work unit until the project is built.

> [!IMPORTANT]
> The "plan before proceed" step catches problems before they become committed code. Don't skip it. It's especially important when CC is working on something complex or unfamiliar.

**When errors happen:**

- Paste the error directly into CC for resolution. CC is the right tool to fix its own errors.
- After resolution, tell Claude.ai what happened so project context stays current.

**When you're stuck:**

- Pause the build loop. Return to brainstorming with Claude.ai.
- Ask questions. Help yourself think through the decision.
- When direction is clear, resume building.

---

## Daily Git commands

Use these every day when working on a project. Run them from inside your project folder in the VS Code terminal.

To open the terminal inside VS Code: click **View** in the top menu then click **Terminal**.

**Make sure you're on develop and up to date:**

```bash
git checkout develop
git pull
```

Run this at the start of every work session.

**Create a feature branch for the work you're about to do:**

```bash
git checkout -b feature/[short-description]
```

Use descriptive names like `feature/login-page` or `fix/mobile-nav`.

**Check what has changed:**

```bash
git status
```

**Stage your changes:**

```bash
git add .
```

**Save your changes with a message:**

```bash
git commit -m "describe what you changed"
```

Keep messages short and descriptive. Examples: `"add login form"` or `"fix mobile layout on dashboard"`.

**Push to GitHub:**

```bash
git push -u origin feature/[short-description]
```

The `-u origin [branch-name]` part tells git "push this branch for the first time." Future pushes from this branch can just use `git push`.

**Open a pull request:**

```bash
gh pr create --base develop --title "Your title" --body "What this changes and why"
```

Note that the base is `develop`, not `main`. Feature branches always merge into develop. Releases (develop → main) happen separately when the project is ready to ship to production.

> [!IMPORTANT]
> Always work on a feature branch off `develop`, not on `develop` directly and never on `main`. The spinup script sets develop as your default; protected status on main prevents direct pushes.

---

## Working with CC

Once your project is open in VS Code, here is how to work with CC for the implementation phase.

**Open CC:** Click the **Claude icon** in the left sidebar.

**Start every session the same way:** Before asking CC to build anything, always orient it to the project first:

```text
Read CLAUDE.md first, then tell me what you understand
about this project before we start.
```

This makes CC read the project context — the stack, standards, and current focus — before writing any code. Without this step CC may make incorrect assumptions.

**Keep CLAUDE.md updated:** The `## Current Focus` section at the bottom of CLAUDE.md is the most important part. Update it every time priorities change. A stale CLAUDE.md means CC works with wrong assumptions.

**Reference the planning artifacts.** When asking CC to implement a feature, point at the relevant artifacts:

```text
Implement [feature] from /docs/prd.md, working on the issue [issue number].
Reference the design handoff at /design-handoff/ for the visual treatment.
Produce a plan before implementing, listing files to modify and any new dependencies.
```

**Starter prompts:** For common tasks, the playbook has starter prompts that get you 50% of the way there fast:
→ [`reference/prompts/`](../reference/prompts/README.md)

**Document architectural decisions:** When CC makes a significant decision — choosing between two approaches, picking a library, designing a data model — have CC record an ADR:

```text
Create an ADR documenting this decision at /docs/decisions/[number]-[short-title].md
using the project's existing ADR template.
```

> [!TIP]
> Having trouble with CC? See [Claude Code not connecting](03-troubleshooting.md#claude-code-not-connecting)

---

## When the project is ready to ship

Production deploys happen by merging develop → main. This is a separate, deliberate step from regular feature work.

When you're ready to release:

1. Make sure all the work intended for this release is merged to develop
2. Make sure the develop branch is passing CI cleanly
3. Open a PR from develop → main with a release summary
4. Merge it (with appropriate review)

Vercel deploys main to the production URL automatically.

For demos before release, every PR gets a Vercel preview URL — you can share previews with stakeholders without merging to main first.

---

## Something not working after spinup?

→ [Troubleshooting](03-troubleshooting.md)
