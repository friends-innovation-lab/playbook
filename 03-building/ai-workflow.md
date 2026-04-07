# AI Workflow — Working with CC

CC (Claude Code) is the primary builder on every project. This doc explains
how to work with CC effectively so you get high-quality output fast.

---

## The most important thing

CC reads `CLAUDE.md` in the project root before doing anything. That file
is CC's context — it tells CC the project name, stack, standards, and
current focus. Keep it updated. A stale `CLAUDE.md` means CC works with
wrong assumptions.

**Update `## Current Focus` in CLAUDE.md every time priorities change.**

---

## How to start a session with CC

Always orient CC at the start of a session:

```
Read CLAUDE.md first, then tell me what you understand about this project
before we start.
```

This forces CC to confirm it has the right context before writing any code.

---

## Starter prompts

For new projects or new features, use the starter prompts in
[prompts/](prompts/). These get you 50% there by encoding the right
stack, standards, and structure into the prompt.

```
Read CLAUDE.md. Then read [prompts/form-tool.md] from the playbook.
I need to build [specific description]. Follow the starter prompt structure.
```

---

## Review Council

The `CLAUDE.md` in every project includes a Review Council — a set of
perspectives CC uses to evaluate work. Use it:

```
Review this as the full council. I want perspectives from: PM, UX Designer,
UI Designer, Accessibility, Frontend Dev, and QA. Be critical — this is
going to a government client.
```

```
Review this as if the demo is in 1 hour. What would make us look bad?
What would make us look great? Prioritize the fixes.
```

```
Review this for government readiness: Accessibility Specialist, Security
Reviewer, and ATO Compliance. What would block us from shipping to a
federal client?
```

---

## Quality gates

Before telling CC a task is done, run:

```bash
npm run check
```

This runs lint + typecheck + unit tests. All must pass. If CC wrote code
that fails this check, ask CC to fix it before moving on.

```
npm run check is failing with these errors: [paste errors]
Fix them without changing any other functionality.
```

---

## Common patterns

### Building a new feature
```
Read CLAUDE.md. I need to build [feature description].
Requirements:
- [list specific requirements]
- Mobile-first — must work at 375px
- Loading, error, and empty states required
- Keyboard navigable
Run npm run check when done and confirm it passes.
```

### Fixing a bug
```
Read CLAUDE.md. There is a bug: [describe exactly what is wrong and
how to reproduce it]. Fix only the bug — do not change anything else.
Run npm run check when done.
```

### Pre-demo polish
```
Read CLAUDE.md. The demo is in [X hours]. Do a pre-demo review:
1. Check for console errors
2. Test all happy paths
3. Check mobile at 375px
4. Run npm run test:a11y
5. List everything that needs fixing, prioritized
```

---

## What CC is not good at

- **Design decisions** — CC will produce functional UI but won't make
  opinionated visual choices. You or a designer needs to direct aesthetics.
- **Business context** — CC doesn't know the client's political environment,
  procurement constraints, or organizational dynamics. You do.
- **Testing on real devices** — CC can't do this. You have to.
- **Judgment calls on scope** — CC will build what you ask. It's your job
  to decide what to ask for.
