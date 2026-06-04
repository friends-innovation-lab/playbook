# Creating a Project

This doc covers the full lifecycle of a real project: planning, design, spinup, build, and ship. It assumes you've completed [`01-first-time-setup.md`](../01-getting-started/01-first-time-setup.md) and run through [`03-your-first-project.md`](../01-getting-started/03-your-first-project.md) at least once, so the basic loop is familiar. Real projects add a planning phase, a design phase, and a different shape for the build itself.

> [!IMPORTANT]
> Spinup credentials are set up by Lapedra when you join the lab as a developer or project lead. If your role does not require spinning up new projects — for example if you are joining an existing project as a researcher or designer — you will not need these credentials and can skip the spinup section. Ask Lapedra which sections apply to your role.

---

## How the three Claude tools work together

The lab uses three Claude tools together: Claude.ai as orchestrator, Claude Design as designer, and Claude Code (CC) as builder. You are the director — you give direction, make judgment calls, and copy-paste between the tools.

Claude.ai holds your project context across the whole engagement. It brainstorms with you, writes the prompts you send to Claude Design and Claude Code, and validates plans before implementation. You don't need to be a prompt engineer — Claude.ai writes prompts for you. Claude Design produces visual designs that conform to the project's domain model. Claude Code implements the project in your VS Code editor, building the domain layer first, then mounting screens on top.

| Tool | Job | What you do with it |
|------|-----|---------------------|
| **Claude.ai** | Orchestrator | Holds project context, brainstorms with you, writes the prompts you'll send to Claude Code, validates plans |
| **Claude Design** | Designer | Produces visual designs that conform to the project's domain model |
| **Claude Code (CC)** | Builder | Implements the project — domain first, then screens |
| **You** | Director | Give direction, make judgment calls, copy-paste between the tools |

> [!IMPORTANT]
> Expect to go back and forth with Claude.ai a lot — especially in Phase 1 and Phase 5. This is the entire point of having an orchestrator. If you find yourself accepting Claude.ai's first response without pushing back, slow down.

> [!IMPORTANT]
> Claude.ai Project files are shared with the team; Claude.ai conversations are not. Teammates invited to the project can see the starter doc, planning artifacts, and Domain Model — but they cannot see your chat history with Claude.ai. Treat the artifacts in `/docs/` as the shared source of truth. The chat is your private workspace as Project Lead.

---

## The build loop

Every project follows this loop:

```mermaid
flowchart TD
    A[Brief arrives] --> B[Brainstorm with Claude.ai]
    B --> C[Generate planning artifacts:<br/>Overview, PRD, Domain Model, Epics, Issues]
    C --> D[Domain Model review<br/>Second pair of eyes]
    D --> E[Design with Claude Design<br/>Conforms to Domain Model]
    E --> F[Run spinup script]
    F --> G[Set up project locally]
    G --> H[Build with orchestrated loop<br/>Claude.ai ↔ CC, domain first]
    H --> I[Ship: develop → main]
    I -.->|Optional| J[Archive to Figma]

    H -.->|Stuck or scope shift| B

    style J stroke-dasharray: 5 5
```

Planning and design come before spinup because the spinup script creates real infrastructure — a live database, deployed app, costs accruing. The planning and design phases are free — you brainstorm with Claude.ai, designers iterate in Claude Design, nothing is committed. By the time you run spinup you know exactly what you're building.

---

## Before you start

Make sure you have:

- Completed [`01-first-time-setup.md`](../01-getting-started/01-first-time-setup.md)
- Run through [`03-your-first-project.md`](../01-getting-started/03-your-first-project.md) at least once
- A real project to spin up

If you're not sure all your tools are set up, run a dry-run of the spinup script — it checks everything before doing anything:

```bash
./automation/spinup-typed.sh --type prototype --name=dry-run-check --dry-run
```

The script will report what's missing if anything. Fix any issues before continuing.

> [!TIP]
> Verify your shared credential is set: run `echo $LAB_SUPABASE_ORG_ID` in your terminal. If a value comes back, you're set. If it's blank, return to [Step 11 in first-time-setup](../01-getting-started/01-first-time-setup.md#step-11--set-up-your-environment-variables-1015-minutes) and add it.

---

## Phase 1 — Plan with Claude.ai

### Why this phase exists

This phase is where the project actually gets thought through. Skipping or rushing it is the most expensive mistake a project lead can make. The planning artifacts produced here become the contract that Claude Design and Claude Code both follow.

If the artifacts are vague, every screen and every line of code that follows will be vague with them. The Domain Model in particular is the most consequential artifact — both Claude Design and Claude Code will conform to it. Spend time on it.

### Steps

**1. Open Claude.ai. Create a new Project (sidebar). Name it after your project.**

**2. Add the orchestrator starter doc to project files.**

Download [`claude-ai-project-starter.md`](claude-ai-project-starter.md) from the playbook. In your Claude.ai project, click "Add files" and upload it.

> [!TIP]
> Re-download the starter doc at the start of each project. It lives in the playbook so it stays current.

**3. Tell Claude to read the starter doc.**

Paste [PROMPT_0](claude-prompts.md#prompt_0--orient-claudeai-to-the-starter-doc) from `claude-prompts.md`.

PROMPT_0 tells Claude.ai to read the starter doc and confirm it understands its role as orchestrator. You're not introducing the project yet — that comes in step 4.

**4. Open the brainstorm.**

Paste [PROMPT_1](claude-prompts.md#prompt_1--open-the-brainstorm) from `claude-prompts.md`. This is where you tell Claude.ai what the project is — name, who it's for, where the brief came from, what success looks like, what you're uncertain about.

Then have a real conversation. Claude.ai will ask clarifying questions. Answer them. Push back. Send follow-ups. Expect 5–10 turns before the project starts to feel real.

> [!TIP]
> A good brainstorm has at least 5–10 back-and-forth turns. If you've only sent two messages and Claude.ai has produced the "answer," you have an outline, not a project. Keep pushing.

**5. Stress-test the direction before committing.**

When the project shape feels real but before you commit to it, paste [PROMPT_2](claude-prompts.md#prompt_2--stress-test-the-project-shape) from `claude-prompts.md`. This asks Claude.ai to push back on the project — what's weakest, what you're assuming, the most likely way it fails.

Argue with Claude.ai's pushback. Some of it will be wrong, some will be right. Update where it's right, defend where it's wrong. Iterate until the project survives the stress test.

**6. Generate the planning artifacts.**

When the project feels real, paste [PROMPT_3](claude-prompts.md#prompt_3--generate-the-planning-artifacts) from `claude-prompts.md`. Claude.ai will produce these five artifacts in order, pausing for your review between each:

| # | Artifact | What it is |
|---|----------|------------|
| 1 | Project overview | One page: what, who for, success, out of scope |
| 2 | PRD | Features, technical constraints, success criteria |
| 3 | **Domain Model** | Entities, relationships, IDs, the API contract |
| 4 | Epic breakdown | How the work decomposes, sequenced by dependency |
| 5 | Initial issue list | Trackable units, each small enough for one CC session |

> [!IMPORTANT]
> The Domain Model is the most consequential artifact on this page. Both Claude Design and Claude Code will conform to it. If it's wrong, every screen and every line of code that follows will be wrong with it. Spend time on it.

> [!NOTE]
> The Domain Model is lightweight for prototypes (TypeScript types + fixtures, no database) and full-weight for SaaS, AI Product, and Federal projects (schema, migrations, types, API). Same shape, different weight. Match the depth to the project type.

> [!NOTE]
> The Domain Model can evolve through Phase 2 — design discovery sometimes surfaces missing entities or fields. When that happens, the project lead updates the Domain Model as a named act in the Claude.ai chat. Design and Code never edit it themselves.

**7. Domain Model review (second pair of eyes).**

Before Phase 2 starts, a second person reviews the Domain Model. This is cheap insurance against an expensive mistake — once Claude Design and Claude Code start consuming the model, fixing it is much more expensive than catching it now.

Reviewer can be another project lead, a builder, or anyone with technical literacy. The review takes 20 minutes.

The reviewer looks for:
- Missing entities
- Unclear relationships
- Ambiguous field types
- IDs that aren't stable
- Fields that should be normalized but are flattened

The reviewer doesn't need to approve perfection — they surface anything that will cause downstream pain.

### Before you move on to Phase 2

- [ ] Project overview saved to Claude.ai project files
- [ ] PRD saved to Claude.ai project files
- [ ] Domain Model saved to Claude.ai project files
- [ ] Epic breakdown saved to Claude.ai project files
- [ ] Initial issue list saved (will become GitHub issues after spinup)
- [ ] Domain Model reviewed by a second person

---

## Phase 2 — Design

### Why this phase exists

Design conforms to the Domain Model. The domain is written first; Claude Design does not invent data shapes. This is the whole reason for the Domain Model — without it, designs will quietly define the data, and the build will reverse-engineer data from screens. Backwards. Expensive.

> [!WARNING]
> If Claude Design's output contains a value that should come from a database — an agency name, a contract ID, an RFP number, a user role, a workflow status, a document type — stop and ask: is this conforming to the Domain Model, or inventing it? Invented data in the design is a refactor waiting to happen.

### Design with Claude Design

**1. Open Claude Design.** Confirm the Friends design system is loaded (or USWDS for federal projects — both are live in Claude Design).

**2. Brief Claude Design with the Domain Model.** Paste [PROMPT_4](claude-prompts.md#prompt_4--brief-claude-design) from `claude-prompts.md`. Attach the Domain Model file before sending.

**3. Verify Claude Design summarizes the Domain Model back to you accurately** before letting it design anything. If it gets entity names or relationships wrong, correct it first.

**4. Iterate.** Like with Claude.ai, expect multiple rounds. Claude Design produces screens; you push back; it refines.

**5. Make sure all system states are designed.**

Don't let Claude Design design only the happy path. Before accepting the handoff, confirm Claude Design has designed:

- Loading states (skeletons, spinners)
- Empty states (no data yet, search returned nothing)
- Error states (failed load, validation errors, network errors)
- Success states (toasts, confirmation messages)
- Hover, focus, and disabled states for interactive elements
- Mobile/responsive variants

> [!TIP]
> Claude Design will design the happy path by default. You usually have to ask explicitly for system states. [PROMPT_4](claude-prompts.md#prompt_4--brief-claude-design) includes the prompt language for this — use it.

**6. When the design is ready, click "Hand off to Claude Code."** This downloads a handoff folder.

**7. Verify the handoff includes a `/fixtures/` folder** with typed mock data conforming to the Domain Model. If it doesn't, the handoff is incomplete — ask Claude Design to produce it before moving on.

> [!IMPORTANT]
> The handoff isn't complete without a `/fixtures/` folder. Components should render off fixtures shaped like the Domain Model — never hardcode values inside components. This is what lets Claude Code swap fixtures for real data later without component surgery.

> [!NOTE]
> If design surfaces a missing entity or field in the Domain Model, stop and bring it back to the project lead. The project lead updates the Domain Model in the Claude.ai project. Do not let Claude Design silently invent fields.

**8. Have Claude.ai review the handoff against the Domain Model.**

Before moving to spinup, upload the handoff's `/fixtures/` directory contents and the README to your Claude.ai project files. Use [PROMPT_7](claude-prompts.md#prompt_7--claudeai-reviews-the-claude-design-handoff) in `claude-prompts.md` to ask Claude.ai to audit the handoff for domain conformance — invented fields, missing entities, flattened relationships, unstable IDs.

> [!IMPORTANT]
> This is the last check before infrastructure gets provisioned. Catching a domain conformance issue here is much cheaper than catching it after CC has built against bad fixtures.

### Before you move on to Phase 3

- [ ] Design reviewed and approved by the project lead
- [ ] Handoff folder downloaded from Claude Design
- [ ] Handoff includes a `/fixtures/` folder with typed mock data
- [ ] All values in components come from the fixtures (no hardcoded data)
- [ ] If the Domain Model was updated during design, the updated version is saved
- [ ] Handoff reviewed by Claude.ai using [PROMPT_7](claude-prompts.md#prompt_7--claudeai-reviews-the-claude-design-handoff)
- [ ] Any flagged issues addressed (either in Claude Design or by updating the Domain Model)

---

## Phase 3 — Spin up the project

### Why this phase exists

Planning and design are done. Now you provision real infrastructure.

Spinup runs in two phases. The first phase creates the repo, deploys to Vercel, and gives you a live URL in about 2 minutes. Supabase provisioning starts in the background but takes longer. The second phase (`--resume`) wires up Supabase once it's ready. This two-phase approach means you're never blocked waiting for Supabase — you get a working deployment immediately.

### Step 1: Open VS Code

If VS Code isn't already open, open it now.

### Step 2: Open the integrated terminal

Click **View** in the top menu, then click **Terminal**. A terminal panel will appear at the bottom of VS Code.

### Step 3: Navigate to the playbook folder

In the terminal, run:

```bash
cd ~/Projects/playbook
```

> [!WARNING]
> Run the spinup script from the playbook folder, not from another project folder. The script's relative paths assume this location.

### Pick the right project type

Each type applies different scaffolding:

| Type | When to use | What you get |
|------|-------------|--------------|
| `prototype` | Proposals, demos, validating an idea quickly | Fast, lightweight, no extensions |
| `internal-tool` | Something Friends uses ourselves | Audit logging, soft deletes |
| `saas-web` | A product with multiple paying customers | Multi-tenancy, audit logging, soft deletes |
| `ai-product` | A SaaS product with AI-driven features | Multi-tenancy, audit logging, soft deletes |
| `federal` | Government client work | Audit logging, soft deletes, USWDS theme |

Pick a name that's descriptive and lowercase with hyphens. For example: `va-benefits-prototype`, `truebid-rfp-import`, `proposal-fy26-q1`.

### Step 4: Run the initial spinup (~2 minutes)

```bash
./automation/spinup-typed.sh --type=[type] --name=[project-name]
```

The script doesn't ask you anything during execution. It just runs. You'll see a banner showing what it's about to do, then pre-flight checks, then provisioning steps.

When this finishes, you'll have:

- A GitHub repo at `github.com/friends-innovation-lab/[project-name]`
- A live URL at `https://[project-name].lab.cityfriends.tech`
- A Vercel deployment (working, but Supabase pages will error — that's expected)
- A `develop` branch set as the default working branch
- Branch protection on `main`
- Starter issues and a project board on GitHub

The script will print a summary with all the URLs. Save them somewhere.

> [!NOTE]
> The live URL is configured but not reachable the instant the script exits — Vercel needs about 1 minute to complete the first production build. If you click the URL immediately and get an error, wait a minute and refresh.

### Step 5: Wire up Supabase (~5 minutes later)

Wait about 5 minutes for Supabase to finish provisioning, then run:

```bash
./automation/spinup-typed.sh --name=[project-name] --resume
```

This is a normal part of every spinup, not a recovery step. It waits for Supabase to become active, then:

- Fetches your Supabase API keys
- Sets them in `.env.local` for local development
- Sets them as Vercel environment variables
- Configures Supabase auth redirect URLs
- Triggers a production redeploy with the real credentials

After `--resume` completes, the live URL and all Supabase-connected pages work end-to-end.

> [!NOTE]
> `--resume` is idempotent — safe to run multiple times. If Supabase isn't ready yet, just wait a few more minutes and run it again.

> [!NOTE]
> Run this once after spinup to install the accessibility test browser:
>
> ```bash
> npx playwright install chromium
> ```

For full details on what the script does:
→ [`docs/spinup-typed.md`](../docs/spinup-typed.md)

### Before you move on to Phase 4

- [ ] Spinup script completed without errors
- [ ] GitHub repo exists and you can access it
- [ ] Live URL loads
- [ ] Supabase database exists (if applicable)
- [ ] All URLs from the spinup summary saved somewhere

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

### Save the planning artifacts to the repo

**Step: Download each artifact from Claude.ai.**

In your Claude.ai project, for each of these artifacts, click the artifact → click the download icon → save to your Downloads folder:

| Artifact | Save as |
|----------|---------|
| Project overview | `project-overview.md` |
| PRD | `prd.md` |
| Domain Model | `domain-model.md` |
| Epic breakdown | `epics.md` |

**Step: Drag the files into `/docs/` in VS Code.**

In VS Code's file explorer (left sidebar), find or create the `/docs/` folder in your project. Drag all four files from Downloads into `/docs/`.

> [!NOTE]
> If `/docs/` doesn't exist yet, right-click the project root in VS Code → New Folder → name it `docs`.

### Save the design handoff to the repo

**Step: Drag the design handoff into `/design-handoff/` in VS Code.**

Find the handoff folder you downloaded from Claude Design (probably in your Downloads folder). Drag the entire folder into your project root in VS Code's file explorer. Rename it to `design-handoff` if it isn't already.

> [!IMPORTANT]
> The `/fixtures/` folder must be inside `/design-handoff/`. Verify it's there before continuing.

### Fill in the project's CLAUDE.md

Fill in CLAUDE.md before any other CC work on this project. Every future CC session reads this file first to orient itself — stack, standards, current focus. Skipping it means the first CC invocations happen with no project context.

The spinup script created a `CLAUDE.md` at the project root with placeholder sections. You need to fill it in with project-specific context so CC has accurate information about this project.

Open the integrated terminal in VS Code (View → Terminal), then start CC:

```bash
claude
```

Paste [PROMPT_8](claude-prompts.md#prompt_8--fill-in-the-projects-claudemd) from `claude-prompts.md`. CC will read the planning artifacts and propose a filled-in CLAUDE.md for your approval.

### Create GitHub issues from the issue list

In CC, paste [PROMPT_9](claude-prompts.md#prompt_9--create-github-issues-from-the-issue-list) from `claude-prompts.md`. CC will read your epics and issue list, then create each issue in GitHub using the `gh` CLI.

> [!TIP]
> Watch CC's output in the terminal as it creates each issue. If it pauses for confirmation, review the issue title and body before approving.

### Switch to the develop branch

The spinup script set develop as the default, but if you cloned and ended up on main, switch:

```bash
git checkout develop
```

You'll work on develop and feature branches off develop for the rest of the project. Main stays untouched until release.

### Before you move on to Phase 5

- [ ] Project opens in VS Code
- [ ] `npm run dev` works
- [ ] Planning artifacts saved to `/docs/` including `domain-model.md`
- [ ] Design handoff saved to `/design-handoff/` including the `/fixtures/` folder
- [ ] CLAUDE.md filled in and reviewed
- [ ] GitHub issues created
- [ ] You're on the `develop` branch

---

## Phase 5 — Build with the orchestrated loop

### Why this phase exists

This phase has the most back-and-forth of the whole project. You will not just send CC a prompt and get a finished feature. The loop is:

- You tell Claude.ai what you want to do next
- Claude.ai writes a prompt for CC
- You paste it into CC (in the terminal)
- CC produces a plan
- You paste the plan back to Claude.ai using [PROMPT_6](claude-prompts.md#prompt_6--validate-ccs-plan-via-claudeai)
- Claude.ai validates or pushes back
- You tell CC to proceed (or adjust)
- CC implements
- You tell Claude.ai what got built

> [!IMPORTANT]
> This is not inefficiency. The back-and-forth is what produces good software with AI tools. Anyone who tells you they "just ask CC to build the thing and it works" is either lying, working on something trivial, or about to pay for it later in refactors.

### Build the domain first, then mount the design

The first CC session on a new project always builds the domain layer — schema, types, API stubs, and fixtures conforming to the Domain Model. Screens come later as the presentation layer over a working domain. Not first.

If your first instinct is to ask CC to build the login page, stop. Ask it to build the data foundation first.

Use the prompt matching your project type:

| Project type | Use this prompt |
|--------------|-----------------|
| `prototype` | [PROMPT_5a](claude-prompts.md#prompt_5a--first-cc-build-session-prototype-lightweight) (lightweight: types + fixtures only) |
| `internal-tool`, `saas-web`, `ai-product`, `federal` | [PROMPT_5b](claude-prompts.md#prompt_5b--first-cc-build-session-full-weight) (full-weight: schema, migrations, types, API stubs, fixtures) |

> [!NOTE]
> The lab's approach to building data first, then UI on top, follows the principles of [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html) — a well-established pattern in serious software engineering. The depth varies with project type; the sequence does not.

**Open CC in the integrated terminal.**

In VS Code, open the terminal (View → Terminal), then run:

```bash
claude
```

This starts a Claude Code session in your terminal. You'll see CC's responses stream directly in the terminal. To exit, type `/exit` or press Ctrl+C.

> [!TIP]
> Working in the terminal lets you see CC's full output as it works — file reads, command outputs, plan generation. This is the preferred working mode in the lab.

### The orchestrated loop

The FIRST work unit on any project is always the domain layer, not a screen.

For each work unit (typically one issue at a time):

1. **Tell Claude.ai what you want to do next.** Reference the issue or describe the work.
2. **Claude.ai generates a CC prompt.** Clear, scoped, with the relevant context CC needs.
3. **Paste the prompt into CC.**
4. **CC produces a plan before implementing.** This is required — CC will list the files it'll modify, the changes it'll make, and any new dependencies. CC waits for explicit approval before doing the work.
5. **Paste CC's plan back into Claude.ai.** Use [PROMPT_6](claude-prompts.md#prompt_6--validate-ccs-plan-via-claudeai) from `claude-prompts.md` to structure the validation. Claude validates: Does it match the intent? Are there missing considerations? Will it conflict with existing code?
6. **Claude.ai responds with "proceed" or specific adjustments.**
7. **Tell CC to proceed** (or to adjust per Claude.ai's notes).
8. **CC implements.**
9. **Tell Claude.ai what got built.** A sentence or two is fine. Claude updates project context.

Repeat for each work unit until the project is built.

> [!IMPORTANT]
> Step 4 — "CC produces a plan before implementing" — is non-negotiable. Do not let CC start writing code before showing you a plan. If CC starts implementing immediately, stop it and ask for the plan. The plan is where mistakes get caught cheaply.

### Working with CC in the terminal

CC has a few terminal commands worth knowing:

| Command | What it does | When to use |
|---------|--------------|-------------|
| `claude` | Start a new CC session | Beginning of a work session |
| `claude --continue` or `claude -c` | Resume your most recent session | Coming back after a break |
| `/clear` | Reset the conversation context within a session | Starting a new logical task, or when CC seems confused |
| `/help` | List available commands | When you forget what's available |
| `/exit` or Ctrl+C | End the session | Done working |

**Best practices:**

- **One CC session per logical work unit.** When you start a new issue or change focus, `/clear` (or exit and restart). This keeps context clean.
- **Don't `/clear` mid-task.** You'll lose useful context that CC was using to make decisions.
- **Resume with `claude -c` when picking up where you left off.** Faster than re-orienting CC to the project.
- **Run CC inside the project folder.** Open your terminal inside the project directory (use `cd ~/Projects/[project-name]`) before running `claude`. CC reads CLAUDE.md from the current directory.

> [!TIP]
> CC also supports custom slash commands defined in `.claude/commands/` in your project repo. The lab will be adding shared lab commands (`/adr`, `/audit`, etc.) — for now, the built-in commands above are enough.

### Maintain a project log

The orchestrator's reasoning lives in your Claude.ai chat history, which only you can see. To make that reasoning shareable and durable, maintain a project log in the repo.

Create `/docs/project-log.md` after spinup. Update it weekly (or after any significant decision). It is a synthesis, not a transcript.

What goes in the project log:

- Key decisions made with Claude.ai and the reasoning behind them
- Turning points — when the project direction shifted and why
- Open questions you're carrying forward
- Things Claude.ai pushed back on that changed your mind (or that you defended and why)

What does NOT go in the project log:

- A full transcript of conversations
- Routine prompt-response pairs that don't carry decisions
- Anything already captured as an ADR (link to the ADR instead)

> [!TIP]
> If you ever step away from a project for a few days and come back unsure where you left off, the project log should be enough to re-orient you in 5 minutes. If it isn't, the log is too sparse.

> [!IMPORTANT]
> Without a project log, all the reasoning that shaped the project lives in your personal Claude.ai chat history. If you step away, leave Friends, or just have a long gap, that context is lost. The repo has the artifacts; the project log has the why.

### When errors happen

- Paste the error directly into CC for resolution. CC is the right tool to fix its own errors.
- After resolution, tell Claude.ai what happened so project context stays current.

### When you're stuck

- Pause the build loop. Return to brainstorming with Claude.ai.
- Ask questions. Think through the decision.
- When direction is clear, resume building.

> [!TIP]
> Being stuck is a signal to go back to Claude.ai, not a signal to push harder with CC. CC is a builder, not a thinker. Claude.ai is where uncertainty gets worked out.

### Architecture Decision Records (ADRs)

When CC (or you) makes a significant architectural decision during the build, capture it as an ADR. Examples of when to write one:

- Choosing between two libraries or approaches
- Designing a non-obvious data model relationship
- Deciding to deviate from the project-template's defaults
- Picking a deployment, caching, or auth strategy
- Trading off performance vs. simplicity

Use [PROMPT_10](claude-prompts.md#prompt_10--create-an-architecture-decision-record-adr) in `claude-prompts.md` to ask CC to generate an ADR for the decision. CC will save it to `/docs/decisions/[number]-[title].md`.

> [!TIP]
> Claude.ai will proactively prompt you when a moment calls for an ADR. If Claude.ai doesn't catch it but you notice the conversation is about an architectural choice, write the ADR anyway. Future-you and future-team will thank you.

### Before you move on to shipping

- [ ] All issues for this release closed
- [ ] Develop branch passing CI
- [ ] Manual smoke test passes
- [ ] Architectural decisions captured as ADRs
- [ ] Project log exists at `/docs/project-log.md` and is current

---

## Shipping the project

Production deploys happen by merging develop → main. This is a separate, deliberate step from regular feature work.

When you're ready to release:

1. Make sure all the work intended for this release is merged to develop
2. Make sure the develop branch is passing CI cleanly
3. Open a PR from develop → main with a release summary
4. Merge it (with appropriate review)

Vercel deploys main to the production URL automatically.

For demos before release, every PR gets a Vercel preview URL — you can share previews with stakeholders without merging to main first.

> [!CAUTION]
> Always work on a feature branch off `develop`, not on `develop` directly and never on `main`. Branch protection on `main` prevents direct pushes — but don't rely on that to save you.

---

## Archiving to Figma (optional)

**When to do this:** optional, project-by-project. Use cases include a client requiring Figma deliverables, a future designer picking up the work, or a federal handoff that demands Figma assets. Most prototypes and internal tools skip this entirely.

**When NOT to do this:** in the middle of the build. Figma is an output of finished work, not a tool in the design-to-code path.

**The mechanic:** open the final design state in Claude Design, use Anima's Figma agent to push it to Figma, share the Figma file URL as the deliverable.

> [!NOTE]
> This is not Phase 6. It's optional and most projects skip it. It sits outside the numbered phase sequence.

---

## Reference: Daily Git commands

Use these every day when working on a project. Run them from inside your project folder in the VS Code terminal.

To open the terminal inside VS Code: click **View** in the top menu then click **Terminal**.

### Make sure you're on develop and up to date

```bash
git checkout develop
git pull
```

Run this at the start of every work session.

### Create a feature branch for the work you're about to do

```bash
git checkout -b feature/[short-description]
```

Use descriptive names like `feature/login-page` or `fix/mobile-nav`.

### Check what has changed

```bash
git status
```

### Stage your changes

```bash
git add .
```

### Save your changes with a message

```bash
git commit -m "describe what you changed"
```

Keep messages short and descriptive. Examples: `"add login form"` or `"fix mobile layout on dashboard"`.

### Push to GitHub

```bash
git push -u origin feature/[short-description]
```

The `-u origin [branch-name]` part tells git "push this branch for the first time." Future pushes from this branch can just use `git push`.

### Open a pull request

```bash
gh pr create --base develop --title "Your title" --body "What this changes and why"
```

Note that the base is `develop`, not `main`. Feature branches always merge into develop. Releases (develop → main) happen separately when the project is ready to ship to production.

---

## Something not working after spinup?

→ [Troubleshooting](03-troubleshooting.md)
