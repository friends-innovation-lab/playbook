# When a Proposal Lands

This doc covers what happens between a proposal landing in Lapedra's inbox and the team being at the keyboard executing the build. The execution part is covered in [`04-challenge-response.md`](04-challenge-response.md). This doc covers everything before that.

If you're on a project team, you're reading this when you've just been told a project is starting. The pre-decision part — whether we pursue the proposal at all — happens above the lab and isn't yours to navigate. You'll be notified when the answer is yes.

---

## Step 1 — The signal

A proposal arrives. Lapedra reads it, meets with the Directors, and decides whether to pursue. If a prototype is part of what we'll deliver, the proposal moves to the lab.

That's the only part of business development you need to know about. The rest stays at the leadership level. When the project is greenlit, you'll be told, and the lab process begins.

---

## Step 2 — Team assembly

Once a project is greenlit, team assembly happens the same day. There's no waiting period.

The current pattern at Friends' size is small:

- **Project Lead** — the Director the project is handed to (currently the Director of Product & UX; the Director of Engineering will share this when hired)
- **One designer + one developer** — typically. At current team size, this is often one person playing both roles
- **Specialists added as needed** — researcher, content strategist, accessibility specialist on larger projects

Assignment is based on availability. This is why every designer and developer in the lab needs to be fully provisioned — when a proposal lands and a team needs to be assembled in hours, every available person needs to be ready to spin up a project on day one.

When the team grows, this section gets revisited. For now, the simplest pattern is: the Project Lead names the team, the team is told, and work begins.

---

## Step 3 — The kickoff meeting

Before anyone touches Claude.ai or runs the spinup script, the team meets. This is the prototype kickoff meeting and it is required.

The kickoff covers:

- **The brief.** What is the proposal asking for? What's the agency? What's the user need? What does success look like for this submission?
- **Timeline.** When is the deadline? When are interim checkpoints? When does the Review Council need to see the prototype?
- **Roles.** Who is the Project Lead? Who is the designer? Who is the developer? Who is the research synthesizer? On a small team, one person plays multiple roles — name those explicitly.
- **Logistics.** Where does the team communicate (Slack channel, named after the project)? Where does work get tracked (GitHub Issues in the project repo)? Where do government materials live (the project's `client-docs/` folder, covered in Step 4)?
- **Brainstorm.** A short brainstorming session — 30 minutes, not an hour. Surface high-level approaches. Identify concerns. Get the team thinking together. The Project Lead leaves this meeting with context beyond the brief itself, ready to start the planning conversation with Claude.ai.

Schedule the kickoff for the same day or the next morning. Don't let a project sit for days before the team meets.

> [!IMPORTANT]
> Do not start the spinup script before the kickoff meeting. Spinup commits real infrastructure. The brainstorm and team alignment happen first so the project starts on a shared foundation, not on assumptions.

---

## Step 4 — Government materials intake

Many proposals come with materials from the government — briefs, prior research, sample data, evaluation criteria, technical specifications, design assets. These materials are gold. They tell you what the agency cares about and where the user pain actually lives.

The lab has a structured process for handling these materials.

**Where they live in the project repo.** Every project spun up from the lab's project-template includes a `client-docs/` folder:

```
client-docs/
├── raw/                    Original materials, untouched
└── synthesized/            Output from Qori synthesis
```

The `raw/` folder holds materials exactly as the agency provided them. PDFs, Word docs, spreadsheets, original filenames preserved. Don't edit, rename, or reformat. They're the source of truth.

The `synthesized/` folder holds processed versions — the Qori output that turns 7 separate research files into a single comprehensive document the team can actually work from.

**The Qori workflow for synthesis.**

When the proposal includes prior research (which most federal proposals do), Qori is the research synthesis tool the lab uses:

1. The team member responsible for synthesis (Project Lead, designer, or researcher) uploads the government-provided documents to Qori through Slack.
2. Qori processes the documents — synthesizing themes, extracting findings, surfacing user needs, structuring the output by topic.
3. Qori writes the output to the `qori-studies` repo, organized by study.
4. The team member downloads the relevant synthesis files from `qori-studies` and adds them to the project's `client-docs/synthesized/` folder.

> [!NOTE]
> Qori outputs to `qori-studies`, not to the project repo. This is intentional — `qori-studies` is the central library of all research synthesis work the lab has done. Each project pulls a copy of its relevant synthesis into its own repo, which keeps the project self-contained while preserving Qori's central archive.

**When there's no prior research.**

Not every proposal comes with prior research. Some agencies issue a brief and expect the offeror to do their own research as part of the response. In that case:

- `client-docs/raw/` still holds whatever materials the agency provided (the brief itself, evaluation criteria, technical specs)
- `client-docs/synthesized/` holds whatever synthesis the team produces — research notes, interview summaries, competitive analysis
- The team can still use Qori, just on materials they generate rather than materials the agency provided

The intake step is the same shape. The materials may differ.

---

## Step 5 — Project setup

After the kickoff meeting and government materials intake, the team starts the technical workflow.

**The Project Lead opens Claude.ai** and sets up the orchestrator using the workflow described in [`01-creating-a-project.md`](01-creating-a-project.md). The brainstorm output from the kickoff meeting becomes early context for the planning conversation. The synthesized government materials inform the PRD, epics, and issue list.

**A designer or developer runs the spinup script** to provision infrastructure. Pick the project type (`prototype`, `federal`, `internal-tool`, etc.) based on what the proposal requires.

**The team creates the Slack channel for project communication** if it doesn't exist already.

**Government materials get added to the new project repo.** The `client-docs/raw/` folder receives the original files. The Qori synthesis gets downloaded from `qori-studies` and added to `client-docs/synthesized/`.

**Initial issue tickets get created.** The spinup script seeds a starter set of issue templates appropriate to the project type. The Project Lead reviews these against the project plan from Claude.ai and adjusts as needed — adds project-specific issues, removes ones that don't apply, sequences them by dependency.

> [!NOTE]
> The lab's default stack is Next.js + TypeScript + Tailwind + shadcn/ui + Supabase + Vercel. Some federal proposals require different stacks (e.g., the VA's Accredited Representative Portal requires React + Ruby on Rails using their `vets-api` and `vets-website` starter branches). When a proposal specifies a stack, that overrides the default. Stack-aware spinup is a tooling investment the lab is making over time — see "What's coming" below.

---

## Step 6 — Working cadence

For most lab projects, the cadence looks like:

- **Daily standups.** 15 minutes. What did you finish, what are you working on, what's blocked. Held in the project Slack channel as an async thread or a quick voice call, depending on team preference.
- **Slack throughout.** The project channel is where async work happens. Quick questions, design mockups, build progress, client material analysis. Keep the project channel busy with real work — don't sandbag updates for the standup.
- **Project Lead checks in with Claude.ai daily.** The orchestrated workflow assumes the Project Lead stays in the loop with project state. New issues, completed work, decisions, blockers — all get reflected back to Claude.ai so it has accurate context for the next prompt cycle.

For a 1-3 week proposal response, this cadence is enough. Longer projects may add a weekly all-hands or a midpoint Review Council check-in.

---

## Step 7 — The Review Council

The Review Council is the small group that reviews lab work before it goes to the client.

**Members:**

- **Lapedra (CEO)**
- **Director of Product & UX** (currently)
- **Director of Engineering** (when hired)

**When they review:**

- **Pre-demo review** — before any demo to the client or evaluators. Surfaces what would make the lab look bad and what would make it stand out.
- **Pre-submission review** — before any final submission package goes out. Confirms the brief is answered, the deliverables are complete, and the technical work is defensible.
- **Major decision points** — when the Project Lead needs leadership input on scope, approach, or tradeoffs.

**How to request a review:**

The Project Lead messages the Review Council in Slack with the project context, what's being reviewed, and the deadline. Reviews are scheduled within 24 hours when possible.

The Review Council is not a gate that slows work down. It's a forcing function for clarity — if you can't articulate what you've built and why to three people who care about the lab's reputation, you can't articulate it to a federal evaluator either.

---

## Step 8 — Preparing the submission package

For most lab work, the deliverable is a live URL plus whatever supporting materials the project calls for. For federal procurement responses, the submission package is substantially more involved.

A real federal example: the VA's Accredited Representative Portal challenge required:

- **Modified GitHub repos** shared to a specific GitHub account designated by the agency
- **README** with build and run instructions
- **Technical document, ≤10 pages**, covering frontend/backend design (architecture and UX), alternatives and trade-offs, new APIs, and demonstrated competence in: full-stack development, mocking dependencies, automated testing, exception handling, monitoring and observability, accessibility, GitHub usage
- **Pain point analysis, ≤8 pages**, with structured evidence-based prioritization
- **Management/staffing approach, ≤2 pages**
- **Docker setup** that builds from source (no pre-built images)
- **Compliance certifications** (SDVOSB certification 852.219-75, in the lab's case)
- **Live URL**, accessible without VPN
- **No hyperlinks or embedded attachments** in any volume

That's substantially more than a Figma file and a live URL. Federal submissions are multi-document deliverables with strict page limits, format requirements, and submission portals.

**What the Project Lead and Review Council do together:**

1. **Re-read the brief** to confirm every requirement has a deliverable. Use the brief as the checklist — line by line.
2. **Inventory what exists.** Live URL, codebase, project docs (project-overview, PRD, epics, ADRs), accessibility test results, Storybook deployment.
3. **Identify what needs to be created.** The technical document, the pain point analysis, the staffing approach, screenshots with annotations, the README at the level the agency requires.
4. **Draft each deliverable.** Use Claude (the chat assistant or CC) to draft from project context. The technical document, for example, can be drafted by pointing CC at the project's `/docs/` folder, the codebase, and the planning artifacts. The first draft comes from real project state, not blank pages.
5. **Review Council reviews.** Pre-submission. They read every deliverable, confirm the brief is answered, surface anything missing.
6. **Final assembly.** The package gets compiled per the agency's submission portal requirements (ATOMS for VA, others for other agencies). Page limits enforced. No prohibited elements (e.g., no hyperlinks for VA submissions). Cover pages and tables of contents added where required.
7. **Submit.** Through the agency's portal plus any required emails.

**Screenshots and annotations.** When the brief asks for visual proof of the prototype's behavior, screenshots are the standard format. Walk through the primary user flow, capture each screen, annotate what's happening (what the user just did, what the system is showing). Claude can help draft annotation copy. The screenshots themselves are captured manually by the Project Lead or designer.

**Demo videos.** When the brief asks for a video walkthrough, record a screen capture of the live URL with narration. Keep it short — usually 3-5 minutes covers the primary flow. Captions for accessibility.

This is the most complex submission scenario the lab handles. Smaller projects (proof-of-concept demos, internal tool prototypes) have lighter packages.

---

## What's coming

The lab is investing in tooling for federal work. These items are in development and will be added to the workflow as they're ready.

- **Stack-aware spinup.** Today the spinup script defaults to Next.js + Supabase + Vercel. Federal challenges sometimes require React + Rails + Docker (the VA's pattern, for example). The script is being expanded to support multiple stacks via a `--stack` flag. The first non-default stack (`rails-react`) will be added when a real project requires it.
- **Federal handoff skill.** A Claude skill that generates first drafts of submission package deliverables — technical document, README, pain point analysis, staffing approach — by reading the project's `/docs/` folder, codebase, and planning artifacts. Reduces the time between "build is done" and "submission package is ready for Review Council."
- **Templates Figma file.** The lab maintains a Templates Figma file with reusable page-level designs. As the lab handles more projects, common patterns are extracted into the Templates file so designers start from a meaningful baseline rather than blank pages.

When these are ready, the operational doc gets updated to reflect them.

---

## Things to figure out as we go

The lab is small, and some patterns aren't fully established yet. These are real open questions the team will work through on the first real projects:

- **Figma file convention per project.** Today, each project likely gets its own new file inside the lab's Figma folder rather than pages within one shared file. Confirm with the designer at kickoff. Document the chosen pattern in the project's `/docs/` folder so it's consistent for the next person.
- **Starter prompt → CC → Figma flow.** The lab maintains starter prompts in [`reference/prompts/`](../reference/prompts/) for common project types (challenge response, dashboard, form tool, etc.). The flow from prompt to Figma design via Claude Code with the Figma plugin needs to be tested end-to-end on a real project. Until tested, treat the prompts as starting points rather than complete recipes.
- **Issue ticket conventions.** The spinup script creates starter issues based on project type. These are scaffolding, not gospel. Project Leads should adjust them based on the actual project. Patterns will emerge over the first several projects.

These aren't blockers. They're the natural shape of a young lab figuring out its conventions in real work. Document what works as it works, and the next project benefits.

---

## What happens after this doc

Once the team has been assembled, kickoff has happened, government materials are synthesized, the project is set up, and the Slack channel is live: the technical execution begins.

For the technical execution lifecycle:
→ [`04-challenge-response.md`](04-challenge-response.md)

For the orchestrated build workflow:
→ [`01-creating-a-project.md`](01-creating-a-project.md)

For decommissioning when the project is done:
→ [`02-ending-a-project.md`](02-ending-a-project.md)

---

## Quick reference for the Project Lead

You've just been told a project is starting. Your first 24 hours:

1. Schedule the kickoff meeting (same day or next morning)
2. Review the brief and any provided materials yourself before the meeting
3. Identify who's on the team and notify them
4. At kickoff: align on brief, timeline, roles, communication, brainstorm
5. Create the project Slack channel
6. Run government materials through Qori (if research is provided)
7. Open Claude.ai, set up the orchestrator project, paste in the brainstorm output
8. Coordinate spinup with the designer/developer
9. Add government materials to `client-docs/` once the project repo exists
10. Review starter issues and adjust based on project plan
11. Daily standups begin

Welcome to the project. The lab has your back.

---

*This doc is part of the Friends Innovation Lab playbook. It covers the operational pre-execution phase. The technical execution phase is covered in [`04-challenge-response.md`](04-challenge-response.md).*
