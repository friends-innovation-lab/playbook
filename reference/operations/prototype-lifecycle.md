# Prototype Lifecycle

Every project follows this lifecycle. Know where your project is.

---

## Stage 1 — Spinup

**Duration:** Under 10 minutes

**What happens:**
- Run `bash automation/spinup.sh`
- GitHub repo, Supabase project, and Vercel deployment created automatically
- Live URL assigned at `[name].labs.cityfriends.tech`
- CLAUDE.md generated with project context
- GitHub issues created for the first sprint

**Done when:** Live URL is accessible and `npm run check` passes.

---

## Stage 2 — Build

**Duration:** 1–2 weeks depending on project type

**What happens:**
- Features built using CC with starter prompts as starting points
- PRs merged from `develop` into `main` via GitHub
- Vercel auto-deploys every merge to `main`
- `CLAUDE.md ## Current Focus` updated weekly

**Done when:** Demo standards checklist is complete.

---

## Stage 3 — Demo

**Duration:** 1–3 days of prep

**What happens:**
- Run through demo standards checklist in full
- Rehearse the live demo flow
- Verify the live change test (receive → change → deploy → show)

**Done when:** All items on the demo standards checklist are checked.

---

## Stage 4 — Decision point

After demo or submission, one of three outcomes:

**A. Not selected / project ends**
→ Move to Stage 5 (decommission) within 30 days

**B. Selected / continuing**
→ Update `CLAUDE.md` with next phase details
→ Continue to Stage 2 with new requirements

**C. Handoff to client**
→ Follow the [handoff process](../delivering/handoff.md)
→ Move to Stage 5 after handoff is confirmed complete

---

## Stage 5 — Decommission

**Duration:** Under 10 minutes

**What happens:**
- Run `bash automation/teardown.sh`
- Database exported and saved locally
- GitHub repo archived (still readable, not deleted)
- Vercel project removed
- Subdomain released
- Teardown record saved to `automation/teardown-log/`

**Done when:** Teardown script completes and record is saved.

---

## Tracking active projects

Check GitHub for active repos under `friends-innovation-lab` org.
Any repo that is not archived is an active project with running
infrastructure and potentially accruing costs.

Run the teardown script on anything that has been idle for 30+ days
without a clear next step.
