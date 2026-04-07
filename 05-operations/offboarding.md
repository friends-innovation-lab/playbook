# Offboarding

What to do when a contractor or team member leaves the lab.

## When someone leaves

Complete this checklist within 24 hours of their last day.

### GitHub
- [ ] Remove from `friends-innovation-lab` org
- Go to github.com/orgs/friends-innovation-lab/people
- Find the person and click "Remove from organization"

### Vercel
- [ ] Remove from `friends-innovation-lab` team
- Go to vercel.com → Settings → Members
- Find the person and remove them

### Supabase
- [ ] Remove from org
- Go to supabase.com/dashboard → org settings → members
- Find the person and remove them

### Figma
- [ ] Remove from org
- Go to figma.com → org settings → members

### Sentry
- [ ] Remove from org
- Go to sentry.io → Settings → Members

### Slack
- [ ] Deactivate account

### Notion
- [ ] Remove from workspace

## Rotating credentials after departure

If the departing team member had access to any of the following,
rotate them immediately:

- `SUPABASE_SERVICE_ROLE_KEY` — generate a new one in Supabase dashboard
- `VERCEL_TOKEN` — revoke in Vercel settings and generate a new one
- `RESEND_API_KEY` — revoke and generate a new one
- `UPSTASH_REDIS_REST_TOKEN` — rotate in Upstash dashboard

After rotating, update the environment variables in:
1. Your local shell profile (`~/.zshrc`)
2. All active Vercel projects (environment variables section)
3. Notify remaining team members to update their local env vars

## Contractor handoff

When a contractor's engagement ends:
1. Complete the offboarding checklist above
2. Ensure their work is committed and pushed before their last day
3. Run a code review on their last PRs before archiving
4. Update `CLAUDE.md` on any projects they worked on to reflect
   the current state and who owns it going forward
