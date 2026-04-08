# Challenge Response Playbook

The full lifecycle of a government procurement challenge response —
from brief to teardown. Every step, who does what, and why.

---

## Why design comes before spinup

The spinup script creates real infrastructure — a GitHub repo, a
Supabase database, a Vercel deployment, a live URL. That means
costs accruing and resources allocated from the moment you run it.

The Figma design phase is free. CC draws screens, you change
direction, throw things away, start over — nothing is committed.
By the time you run spinup you know exactly what you're building,
which means less rework and a faster build.

---

## The 12 steps

### Step 1 — Brief arrives

The challenge brief lands. Read the entire document before doing
anything else. Highlight:
- Who is the end user
- What the primary user action is
- What the evaluation criteria are
- What the deadline is
- Any mandatory technical requirements (508, FedRAMP, etc.)

### Step 2 — Discuss and extract requirements

Meet with the team (or yourself) and pull out:
- One-sentence summary of what we are building
- 3–5 core screens the prototype needs
- The "wow" moment — what makes the evaluator stop and pay attention
- Non-negotiable requirements from the brief
- Any ambiguities to resolve

### Step 3 — Design in Figma

Open CC and use the design system files to design screens:
- Tokens: https://www.figma.com/design/MgWiTmboj3YSTUK8xRKzRt/Tokens
- Components: https://www.figma.com/design/zZFKdl9JDitNfnZkTGJYKR/Components
- Templates: https://www.figma.com/design/vqKtu40TwBNNUYnPH87PvB/Templates

Use the challenge-response starter prompt to orient CC:
→ [03-building/prompts/challenge-response.md](../03-building/prompts/challenge-response.md)

Iterate until you are confident in the layout, flow, and copy.
This is the cheapest time to change direction.

### Step 4 — Review and decide

Walk through every screen. Check:
- Does the flow make sense in under 3 minutes?
- Is there a clear landing page → action → result arc?
- Are labels in plain language?
- Would an evaluator understand what this does in 10 seconds?

Lock the design. After this point, changes should be small.

### Step 5 — Spinup

Run the spinup script from `~/projects`:
```bash
bash ~/projects/playbook/operations/automation/spinup.sh
```

After spinup, install the accessibility test browser:
```bash
npx playwright install chromium
```

### Step 6 — Build from Figma designs

Open the project in VS Code. Start CC with:
```
Read CLAUDE.md first, then tell me what you understand about
this project before we start.
```

Then paste the challenge-response starter prompt. CC builds the
prototype from the locked Figma designs. The build should take
the prototype from zero to 80% in one session.

### Step 7 — Polish and accessibility

Run the accessibility tests:
```bash
npm run test:a11y
```

Fix every violation. Then check:
- Every screen at 375px (mobile)
- All loading states, error states, empty states
- No console errors in the browser
- No lorem ipsum or placeholder text anywhere
- Demo credentials work (demo@example.gov / Demo1234!)

### Step 8 — Internal review

Run a pre-demo review with the Review Council:
```
Review this as if the client demo is in 1 hour. What would make
us look bad in front of a federal evaluation panel? What would
make us stand out? List everything, prioritized.
```

Fix the critical items. The nice-to-haves can wait.

### Step 9 — Qori integration

If this challenge response includes Qori (the AI-powered assessment
engine), integrate it at this stage:
- Connect Qori endpoints to the prototype
- Ensure Qori responses render correctly in the UI
- Test the full flow end to end: user input → Qori processing → result display
- Verify that Qori responses meet accessibility standards
- Add appropriate loading states for Qori API calls (they may take longer)

If Qori is not part of this response, skip this step.

### Step 10 — Final check

Run all checks:
```bash
npm run check
npm run test:a11y
```

Both must pass with zero errors. Then:
- Test the live URL (not just localhost)
- Test on an actual phone
- Have someone who has not seen the prototype try the flow cold
- Verify the submission format matches what the brief requires

### Step 11 — Submit or demo

Package the deliverable per the challenge requirements:
- Live URL
- Source code (if required)
- Written narrative (if required)
- Screenshots or video walkthrough (if required)

For demo format:
→ [demo-standards.md](demo-standards.md)

For submission checklist:
→ [submission-checklist.md](submission-checklist.md)

### Step 12 — Teardown

After the challenge response is submitted and the evaluation
period ends, decommission the project:
→ [01-getting-started/05-ending-a-project.md](../01-getting-started/05-ending-a-project.md)

Do not tear down until you have confirmed the evaluation is
complete and no further demos or revisions are needed.

---

## Integrated workflow

```
Brief arrives
│
├─ Read brief, extract requirements
├─ Identify end user, primary action, evaluation criteria
│
▼
Design in Figma (free — no infrastructure)
│
├─ Use design system tokens + components + templates
├─ CC draws screens from starter prompt
├─ Iterate until confident
│
▼
Review + lock design
│
▼
Spinup → infrastructure created
│
├─ GitHub repo + Vercel deployment + Supabase database
├─ Live URL active
│
▼
CC builds from Figma → working prototype
│
├─ 80% built in first session
├─ Follows CLAUDE.md standards
│
▼
Polish + accessibility
│
├─ npm run test:a11y → zero violations
├─ Mobile at 375px
├─ All states implemented
│
▼
Qori integration (if applicable)
│
▼
Internal review (Review Council)
│
▼
Final check → submit or demo
│
▼
Teardown (after evaluation ends)
```

---

*This playbook is part of the Friends Innovation Lab operational guide.
See [04-delivering/](../04-delivering/) for related delivery standards.*
