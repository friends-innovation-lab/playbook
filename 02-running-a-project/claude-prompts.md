# Claude Prompts — Starter Library

These are the copy-paste prompts used throughout the project lifecycle. Each is referenced by ID from [`01-creating-a-project.md`](01-creating-a-project.md). Fill in the `[BRACKETED]` placeholders before sending.

The prompts are numbered roughly in lifecycle order, but you'll use them throughout a project, not just sequentially. PROMPT_5 splits into 5a (prototype) and 5b (full-weight) — use the one matching your project type. PROMPT_7 happens between design and spinup. PROMPT_8 (CLAUDE.md) and PROMPT_9 (GitHub issues) happen during local setup — in that order. PROMPT_10 is for ongoing architectural decisions throughout the build.

> [!TIP]
> These prompts are starting points, not scripts. Adjust them to match your project's specifics. The structure matters more than the exact words.

---

## PROMPT_0 — Orient Claude.ai to the starter doc

**Use when:** Right after uploading the starter doc to a new Claude.ai project, before any brainstorming.

**Paste into:** Claude.ai

```markdown
Read the claude-ai-project-starter.md file in this project. Tell me what you understand about your role and how we'll work together. Then we'll start brainstorming the project.
```

**What to expect:** Claude.ai will summarize the role, the workflow, and the artifact discipline. If anything looks wrong or incomplete, ask Claude.ai to re-read the file.

← [Back to Phase 1 — Plan with Claude.ai](01-creating-a-project.md#phase-1--plan-with-claudeai)

---

## PROMPT_1 — Open the brainstorm

**Use when:** Right after Claude.ai confirms it has read the starter doc, to start brainstorming the project.

**Paste into:** Claude.ai

```markdown
I'm starting a new project called [PROJECT NAME]. Here's what I know so far:

- What it is: [ONE SENTENCE]
- Who it's for: [WHO WILL USE IT]
- Where the brief came from: [CLIENT / RFP / INTERNAL / OUR IDEA]
- What success looks like: [WHAT WOULD MAKE THIS A WIN]
- What I'm uncertain about: [WHAT I DON'T KNOW YET]

Help me think through this. Don't produce artifacts yet — I want to brainstorm first. Push back on anything that's vague, ask the questions I haven't thought of, and tell me what I'm missing. Assume I have not thought this through enough.
```

**What to expect:** Claude.ai will ask several clarifying questions and push back on assumptions. Answer them. Send follow-ups. Expect 5–10 turns before the project feels real.

← [Back to Phase 1 — Plan with Claude.ai](01-creating-a-project.md#phase-1--plan-with-claudeai)

---

## PROMPT_2 — Stress-test the project shape

**Use when:** Mid-brainstorm, before committing to the project direction. Catches weak points before they get baked into artifacts.

**Paste into:** Claude.ai

```markdown
Before I commit to this direction, stress-test it. Tell me:

1. What's the weakest part of this project as currently framed?
2. What am I assuming that might not be true?
3. What's the most likely way this project fails?
4. What would a senior [DESIGNER / ENGINEER / RESEARCHER / DOMAIN EXPERT] say is missing?
5. Is there a simpler version that gets 80% of the value?

Be direct. I'd rather hear the hard thing now than after we've built it.
```

**What to expect:** Claude.ai will push back. Some of its pushback will be wrong, some will be right. Argue with it. Update your thinking where it's right, defend where it's wrong. Repeat.

← [Back to Phase 1 — Plan with Claude.ai](01-creating-a-project.md#phase-1--plan-with-claudeai)

---

## PROMPT_3 — Generate the planning artifacts

**Use when:** Brainstorming is done and the project shape feels real. This kicks off the five-artifact generation including the Domain Model.

**Paste into:** Claude.ai

```markdown
I think we have enough to commit. Produce the planning artifacts in this order, one at a time, pausing for my review between each:

1. **Project overview** — one page covering what this is, who it's for, what success looks like, what's out of scope
2. **PRD** — features, technical constraints, success criteria
3. **Domain model** — entities, relationships, IDs, and the API contract. This is the source of truth that both Claude Design and Claude Code will conform to. Be specific: field names, types, required vs optional, relationship cardinality, ID format. Use realistic, stable ID formats. Do not flatten relationships. If you're uncertain about a field, list it as an open question rather than inventing it.
4. **Epic breakdown** — how the work decomposes, sequenced by dependency
5. **Initial issue list** — each issue small enough for one CC session

Start with the project overview.
```

**What to expect:** Claude.ai will produce one artifact at a time and wait for your review. Read each carefully. Push back on anything that feels off. Save each artifact to the Claude.ai project files before moving to the next.

← [Back to Phase 1 — Plan with Claude.ai](01-creating-a-project.md#phase-1--plan-with-claudeai)

---

## PROMPT_4 — Brief Claude Design

**Use when:** At the start of a Claude Design session. Attach the Domain Model file before sending.

**Paste into:** Claude Design

```markdown
I'm designing [FEATURE OR SCREEN SET] for [PROJECT NAME]. The domain model is attached as a file — read it first and tell me what entities, fields, and relationships you see before we start designing.

When you produce mock data for screens:
- Conform to the entity shapes and field names in the domain model exactly
- Use realistic, stable IDs in the format specified in the model (not "id-1", "id-2")
- Do not invent fields that aren't in the domain model
- Do not flatten relationships — if an entity has a related entity, show it as a related entity in the data
- If you think the model is missing a field a screen needs, flag it as an open question; do not add it silently

For every screen you design, include all relevant system states:
- Loading states (skeletons, spinners) for any data fetch
- Empty states (no data yet, search returned no results)
- Error states (failed load, validation errors, network errors)
- Success states (toasts, confirmation messages, completion screens)
- Hover, focus, and disabled states for all interactive elements
- Mobile/responsive variants for any screen that will be used on a phone

Don't design only the happy path. The system states are part of the design, not an afterthought.

Once you've confirmed you understand the domain model, here's what I want to design: [BRIEF DESCRIPTION].
```

**What to expect:** Claude Design will summarize the Domain Model back to you. Verify the summary is correct before letting it design anything. If it gets entity names or relationships wrong, correct it before continuing.

← [Back to Phase 2 — Design](01-creating-a-project.md#phase-2--design)

---

## PROMPT_5a — First CC build session (prototype, lightweight)

**Use when:** First CC session on a prototype project (project type `prototype`). For SaaS/AI/federal projects, use PROMPT_5b instead.

**Paste into:** Claude Code

```markdown
Read CLAUDE.md, /docs/project-overview.md, /docs/prd.md, and /docs/domain-model.md. Tell me what you understand about the project and the domain model before we start.

This is a prototype. We don't need a real database, migrations, or a deployed API. We need a working frontend with realistic data shapes that mirror what the real backend would return.

Once oriented, the build order is domain-first but lightweight:

1. TypeScript types matching the domain model
2. A `/fixtures` folder with typed mock data conforming to the domain model
3. A thin data-access layer (functions that return fixtures, can be swapped for real API later)

Verify the data layer works — types compile, fixtures conform — before any UI work begins. Screens come later as the presentation layer.

Produce a plan covering only the data layer before implementing anything. List the files you'll create or modify and any new dependencies. Wait for my approval before writing code.
```

**What to expect:** CC will summarize the project and produce a lightweight plan focused on types and fixtures. Paste the plan into Claude.ai using PROMPT_6 before letting CC proceed.

← [Back to Phase 5 — Build the domain first](01-creating-a-project.md#build-the-domain-first-then-mount-the-design)

---

## PROMPT_5b — First CC build session (full-weight)

**Use when:** First CC session on an `internal-tool`, `saas-web`, `ai-product`, or `federal` project. For prototypes, use PROMPT_5a instead.

**Paste into:** Claude Code

```markdown
Read CLAUDE.md, /docs/project-overview.md, /docs/prd.md, and /docs/domain-model.md. Tell me what you understand about the project and the domain model before we start.

Once oriented, the build order for this project is domain-first:

1. Database schema and migrations matching the domain model
2. TypeScript types generated from the schema
3. API stubs returning contract-shaped data
4. A `/fixtures` folder with typed mock data conforming to the domain model

Verify the domain layer works end-to-end — entities persist with stable IDs, API stubs return the right shapes — before any UI work begins. Screens come later as the presentation layer; right now we're building the foundation they'll sit on.

Produce a plan covering only the domain layer before implementing anything. List the files you'll create or modify and any new dependencies. Wait for my approval before writing code.
```

**What to expect:** CC will summarize the project and produce a plan covering schema, types, API stubs, and fixtures. Paste the plan into Claude.ai using PROMPT_6 before letting CC proceed.

← [Back to Phase 5 — Build the domain first](01-creating-a-project.md#build-the-domain-first-then-mount-the-design)

---

## PROMPT_6 — Validate CC's plan via Claude.ai

**Use when:** CC has produced a plan and is waiting for approval. This is step 5 of the orchestrated loop in Phase 5.

**Paste into:** Claude.ai

```markdown
Claude Code just produced this plan for [WHAT WE ASKED IT TO BUILD]:

[PASTE CC'S PLAN HERE]

Validate it. Specifically:
1. Does this match the intent of [THE ISSUE / FEATURE]?
2. Does it conform to the domain model in /docs/domain-model.md?
3. Are there missing considerations — files it should touch but didn't list, dependencies it should add, edge cases it skipped?
4. Will it conflict with anything we've already built?
5. Should I tell CC to proceed, or are there adjustments first?

Be specific. If you say "proceed," I'm pasting that straight back to CC.
```

**What to expect:** Claude.ai will either say "proceed" or list specific adjustments. If adjustments, paste them back to CC and ask CC to revise the plan. Loop until Claude.ai says proceed.

← [Back to Phase 5 — The orchestrated loop](01-creating-a-project.md#the-orchestrated-loop)

---

## PROMPT_7 — Claude.ai reviews the Claude Design handoff

**Use when:** End of Phase 2, after downloading the handoff from Claude Design. Upload the handoff's `/fixtures/` directory contents and the README to your Claude.ai project files first, then paste this prompt.

**Paste into:** Claude.ai

```markdown
I've uploaded the Claude Design handoff. Review it against the domain model in our project files. Specifically:

1. Do the fixtures conform to the entity shapes and field names in the Domain Model?
2. Are there any invented fields that aren't in the Domain Model?
3. Are any relationships flattened that should be nested?
4. Are the IDs realistic and stable (not "id-1", "id-2")?
5. Are there entities referenced in the handoff that aren't in the Domain Model?
6. Are all system states represented (loading, empty, error, success, hover, focus, disabled, mobile)?

For each issue you find, tell me:
- What's wrong
- Whether the fix is in Claude Design (re-design) or in the Domain Model (update the contract)
- How critical (blocker for build, or fixable later)

If the handoff is clean to proceed, say so explicitly.
```

**What to expect:** Claude.ai will list any conformance issues. If clean, you can proceed to spinup. If issues exist, either fix in Claude Design and re-export the handoff, or update the Domain Model and reconcile (project lead's call).

← [Back to Phase 2 — Design](01-creating-a-project.md#design-with-claude-design)

---

## PROMPT_8 — Fill in the project's CLAUDE.md

**Use when:** Phase 4, after planning artifacts are saved to `/docs/`. The spinup script creates a CLAUDE.md with placeholder sections; this prompt fills them in. Do this before any other CC work on the project.

**Paste into:** Claude Code

```markdown
Read the existing CLAUDE.md in this project root. It has placeholder sections from the spinup template.

Now read /docs/project-overview.md, /docs/prd.md, /docs/domain-model.md, and /docs/epics.md.

Fill in CLAUDE.md with project-specific context:
- Project name and one-line description
- The stack (already in the template — verify it's correct for this project type)
- Key entities from the Domain Model (summary only — full model lives in /docs/domain-model.md)
- Current focus (what we're building first)
- Any lab standards that apply specifically to this project
- Anything else from the planning artifacts that future-CC will need to orient quickly

Don't rewrite the template's stack section unless it's wrong. Don't duplicate the full Domain Model — reference it. Keep CLAUDE.md scannable; details live in /docs/.

Show me the proposed CLAUDE.md before saving. Wait for approval.
```

**What to expect:** CC will read the planning docs and draft a filled-in CLAUDE.md. Review carefully — this file shapes every future CC session's behavior. Push back on anything inaccurate before approving.

← [Back to Phase 4 — Fill in CLAUDE.md](01-creating-a-project.md#fill-in-the-projects-claudemd)

---

## PROMPT_9 — Create GitHub issues from the issue list

**Use when:** In Phase 4, after CLAUDE.md is filled in and planning artifacts and design handoff are saved to the repo.

**Paste into:** Claude Code

```markdown
Read /docs/epics.md and the issue list from /docs/prd.md (or wherever the initial issue list lives — confirm with me first if you can't find it).

For each issue, create a GitHub issue in this repo using the `gh` CLI. Include:
- A clear title
- A description with acceptance criteria from the issue list
- The relevant epic as a label or in the body
- Any sequencing notes (depends on issue #X, blocks issue #Y)

Show me the first issue you'll create and wait for my confirmation before creating the rest. Then proceed through the list, showing the `gh` command for each before running it.
```

**What to expect:** CC will draft the first issue, wait for approval, then work through the list. You can interrupt and adjust at any point.

← [Back to Phase 4 — Create GitHub issues](01-creating-a-project.md#create-github-issues-from-the-issue-list)

---

## PROMPT_10 — Create an Architecture Decision Record (ADR)

**Use when:** A significant architectural decision was just made — choosing between two approaches, picking a library, designing a data relationship, deviating from the project-template's defaults, deciding on a strategy.

**Paste into:** Claude Code

```markdown
We just decided [DECISION]. Create an ADR documenting it.

Use the existing ADR template in /docs/decisions/ (or create one based on the standard Markdown ADR format if none exists). Save the new ADR as `/docs/decisions/[next-number]-[short-title].md`.

The ADR should cover:
- Context — what problem we were trying to solve
- The decision — what we chose
- Alternatives considered — what else we looked at and why we didn't choose them
- Consequences — what this decision makes easier and harder going forward
- Status — Proposed / Accepted / Superseded

Be concise but specific. The ADR is for future-team-members trying to understand why the project is the way it is.

Show me the proposed ADR before saving.
```

**What to expect:** CC will draft the ADR, propose a filename, and wait for approval. Once approved, CC saves it to `/docs/decisions/`.

← [Back to Phase 5 — Architecture Decision Records](01-creating-a-project.md#architecture-decision-records-adrs)

---

## When prompts don't work

<details>
<summary>If Claude.ai's response feels generic or off-target</summary>

- Check that the starter doc is actually in the Claude.ai project files
- Verify Claude.ai has read it (paste PROMPT_0 again)
- Reload the conversation and start fresh if context feels muddled

</details>

<details>
<summary>If Claude Design invents fields or ignores the Domain Model</summary>

- Verify the Domain Model file was attached before you sent PROMPT_4
- Ask Claude Design to summarize the Domain Model back to you
- If it still invents, simplify your request — design fewer screens at once

</details>

<details>
<summary>If Claude Code starts implementing without a plan</summary>

- Stop it. Ask explicitly: "Show me your plan first. List files, changes, dependencies. Wait for approval."
- If it still skips planning, your prompt may be missing the plan-first instruction — check that PROMPT_5a, PROMPT_5b, or a similar plan-required prompt was used

</details>
