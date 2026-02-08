# Rollback Procedures

*How we recover from bad deployments at Friends Innovation Lab.*

---

## Overview

Things go wrong. When they do:

1. **Stay calm** — Panic makes it worse
2. **Assess impact** — How bad is it?
3. **Rollback fast** — Restore service first
4. **Fix forward** — Then investigate and fix properly

---

## Vercel Instant Rollback

Vercel keeps all deployments. Rolling back takes 30 seconds.

### Via Dashboard

1. Go to **Vercel Dashboard** → Project → **Deployments**
2. Find the last working deployment
3. Click the **⋮** menu → **Promote to Production**
4. Confirm

### Via CLI

```bash
# List recent deployments
vercel ls

# Rollback to specific deployment
vercel rollback [deployment-url]

# Or promote a specific deployment
vercel promote [deployment-url]
```

### What Gets Rolled Back

| Rolled Back | NOT Rolled Back |
|-------------|-----------------|
| Application code | Database changes |
| Environment variables (at deploy time) | External service state |
| Serverless functions | Supabase schema |
| Static assets | Third-party integrations |

---

## Database Rollback

### Supabase Point-in-Time Recovery

**Pro plan required.** Restores entire database to a point in time.

1. Go to **Supabase Dashboard** → Project → **Settings** → **Database**
2. Find **Point in Time Recovery**
3. Select timestamp before the problem
4. Restore (creates new project or restores in place)

⚠️ **Warning:** This affects ALL data, not just schema.

### Manual Migration Rollback

If you have rollback migrations:

```bash
# Revert last migration (if you wrote a down migration)
supabase migration revert

# Or apply a specific rollback migration
supabase db push
```

### Rollback Migration Example

```sql
-- migrations/20240115_add_column.sql (UP)
ALTER TABLE users ADD COLUMN nickname TEXT;

-- migrations/20240115_add_column_rollback.sql (DOWN)
ALTER TABLE users DROP COLUMN nickname;
```

**Best practice:** Always write reversible migrations.

### Emergency: Direct SQL Fix

If you need to fix data immediately:

```sql
-- Connect to Supabase SQL Editor

-- Revert a column addition
ALTER TABLE users DROP COLUMN IF EXISTS problematic_column;

-- Restore deleted data from backup (if you have it)
INSERT INTO users SELECT * FROM users_backup WHERE deleted_at > '2024-01-15';

-- Fix corrupted data
UPDATE orders SET status = 'pending' WHERE status = 'corrupted_value';
```

---

## Git Rollback

### Revert a Merge

If bad code was merged:

```bash
# Find the merge commit
git log --oneline

# Revert the merge commit
git revert -m 1 <merge-commit-hash>

# Push (triggers new deployment)
git push origin main
```

### Reset to Previous State

**⚠️ Destructive — coordinate with team:**

```bash
# Reset to specific commit
git reset --hard <commit-hash>

# Force push
git push --force origin main
```

### Hotfix Branch

For quick fixes without full rollback:

```bash
# Create hotfix from last good state
git checkout -b hotfix/fix-issue <last-good-commit>

# Make minimal fix
# ... edit files ...

# Commit and push
git add .
git commit -m "hotfix: fix critical issue"
git push origin hotfix/fix-issue

# Merge to main (fast-track review)
# Or cherry-pick to main
git checkout main
git cherry-pick <hotfix-commit>
git push origin main
```

---

## Rollback Decision Tree

```
Is the site down?
├── YES → Vercel instant rollback (30 sec)
│         Then investigate
│
└── NO → Is data corrupted?
         ├── YES → Is it fixable with SQL?
         │         ├── YES → Direct SQL fix
         │         └── NO → Point-in-time recovery
         │
         └── NO → Is it a code bug?
                  ├── Minor → Hotfix forward
                  └── Major → Vercel rollback + Git revert
```

---

## Rollback Checklist

### Before Rolling Back

- [ ] Confirm the issue (not just your browser cache)
- [ ] Identify when it started working
- [ ] Find last known good deployment/commit
- [ ] Notify team you're rolling back

### During Rollback

- [ ] Perform rollback (Vercel/Git/Database)
- [ ] Verify site is working
- [ ] Check critical paths manually
- [ ] Monitor error tracking

### After Rollback

- [ ] Notify team rollback complete
- [ ] Update status page (if public)
- [ ] Create incident ticket
- [ ] Schedule post-mortem
- [ ] Fix issue on a branch before re-deploying

---

## Prevention

### Deploy Safely

```bash
# Always build locally first
npm run build

# Run tests
npm run test:run

# Check TypeScript
npm run typecheck
```

### Use Preview Deployments

Every PR gets a preview. Test there before merging.

### Feature Flags

For risky features:

```typescript
// lib/flags.ts
export const FLAGS = {
  NEW_CHECKOUT: process.env.NEXT_PUBLIC_FLAG_NEW_CHECKOUT === 'true',
}

// Usage
if (FLAGS.NEW_CHECKOUT) {
  return <NewCheckout />
} else {
  return <OldCheckout />
}
```

Disable flag instead of rolling back entire deployment.

### Database Migration Safety

```sql
-- ✅ Safe: Additive change
ALTER TABLE users ADD COLUMN nickname TEXT;

-- ⚠️ Risky: Removing column
-- First: Stop using column in code
-- Then: Deploy code change
-- Finally: Remove column in separate migration
ALTER TABLE users DROP COLUMN old_field;

-- ✅ Safe: Add with default (no table lock on modern Postgres)
ALTER TABLE users ADD COLUMN status TEXT DEFAULT 'active';

-- ⚠️ Risky: Changing column type
-- Create new column, migrate data, swap in code, then drop old
```

---

## Emergency Contacts

### Vercel Issues

- Status: [vercel-status.com](https://vercel-status.com)
- Support: Vercel Dashboard → Help

### Supabase Issues

- Status: [status.supabase.com](https://status.supabase.com)
- Support: Supabase Dashboard → Support

### Internal

- Primary on-call: [Team Lead]
- Backup: [Team Member]
- Escalation: [Lapedra]

---

## Incident Log Template

Keep a log during incidents:

```markdown
## Incident: [Brief Description]
**Date:** YYYY-MM-DD
**Severity:** Critical / High / Medium / Low

### Timeline
- HH:MM - Issue reported
- HH:MM - Investigation started
- HH:MM - Root cause identified
- HH:MM - Rollback initiated
- HH:MM - Service restored
- HH:MM - Fix deployed

### What Happened
[Description]

### What We Did
[Actions taken]

### Root Cause
[Why it happened]

### Prevention
[How to prevent recurrence]
```

---

## Quick Reference

### Vercel Rollback

```bash
# Via CLI
vercel rollback

# Via Dashboard
Deployments → Previous → Promote to Production
```

### Git Rollback

```bash
# Revert merge (safe)
git revert -m 1 <merge-commit>
git push

# Reset (destructive)
git reset --hard <commit>
git push --force
```

### Database Rollback

```bash
# Revert migration (if supported)
supabase migration revert

# Point-in-time (Supabase Pro)
Dashboard → Settings → Database → PITR
```

### Verify After Rollback

```bash
# Quick smoke test
curl -I https://your-app.vercel.app/api/health

# Check critical page
curl -I https://your-app.vercel.app/
```

---

*See also: [Environments](environments.md) · [CI/CD](ci-cd.md) · [Monitoring](../performance/monitoring.md)*
