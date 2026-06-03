# Claude Prompts — Starter Library

These are the copy-paste prompts used throughout the project lifecycle. Each is referenced by ID from [`01-creating-a-project.md`](01-creating-a-project.md). Fill in the `[BRACKETED]` placeholders before sending.

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

Once you've confirmed you understand the model, here's what I want to design: [BRIEF DESCRIPTION].
```

**What to expect:** Claude Design will summarize the Domain Model back to you. Verify the summary is correct before letting it design anything. If it gets entity names or relationships wrong, correct it before continuing.

---

## PROMPT_5 — First CC build session (domain-first)

**Use when:** For the very first CC session on a new project, right after spinup. This enforces domain-first build order.

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

**What to expect:** CC will summarize the project and produce a plan. Paste the plan into Claude.ai using PROMPT_6 before letting CC proceed.

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
- If it still skips planning, your prompt may be missing the plan-first instruction — check that PROMPT_5 (or a similar plan-required prompt) was used

</details>
