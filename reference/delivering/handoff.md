# Handoff

What to prepare when handing a project to a client or another team.

## What every handoff includes

### 1. Live URL
The prototype stays live at `[name].lab.cityfriends.tech` until the
client confirms they no longer need it. Confirm how long it should
stay active before running teardown.

### 2. GitHub repo
Transfer or add the client as a collaborator. Ensure the README is
current and explains how to run the project locally.

### 3. Environment variables
Provide the client with a copy of `.env.local` values they'll need
if they plan to run the project themselves. Never share service role
keys over email — use a secure method.

### 4. Supabase access
Add the client to the Supabase project or transfer ownership.
Before handoff, verify RLS is correctly configured.

### 5. Documentation
- `CLAUDE.md` — complete and up to date
- `DECISIONS.md` — if major architecture decisions were made, document them
- `README.md` — how to run locally, environment variable descriptions

## What to confirm before handoff

- [ ] Client has been added to GitHub repo
- [ ] Client has Supabase access
- [ ] Client has Vercel access (or project has been transferred)
- [ ] All environment variables documented and shared securely
- [ ] README is accurate
- [ ] Walkthrough call scheduled

## If the project is being decommissioned instead

Run the teardown script:
```bash
bash automation/teardown.sh
```

This exports data, archives the repo, and removes all infrastructure.
