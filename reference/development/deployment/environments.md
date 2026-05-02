# Environments

*How we manage dev, staging, and production at Friends Innovation Lab.*

---

## Overview

| Environment | Purpose | URL Pattern |
|-------------|---------|-------------|
| **Development** | Local coding | `localhost:3000` |
| **Preview** | PR review | `[branch]-[project].vercel.app` |
| **Staging** | Pre-release testing | `staging.[project].lab.cityfriends.tech` |
| **Production** | Live users | `[project].lab.cityfriends.tech` |

---

## Development (Local)

### Setup

```bash
# Clone repo
git clone https://github.com/friends-from-the-city/[project].git
cd [project]

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env.local
# Fill in .env.local with dev values

# Start dev server
npm run dev
```

### Local Environment Variables

```bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=https://[dev-project].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...

NEXT_PUBLIC_APP_URL=http://localhost:3000

# Use test keys for external services
STRIPE_SECRET_KEY=sk_test_...
```

### Local Supabase (Optional)

For offline development or testing migrations:

```bash
# Start local Supabase
supabase start

# Use local URLs
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=[local-anon-key]
SUPABASE_SERVICE_ROLE_KEY=[local-service-key]
```

---

## Preview (PR Deployments)

Vercel automatically deploys every PR.

### How It Works

1. Push branch / open PR
2. Vercel builds and deploys
3. Preview URL appears in PR comments
4. Reviewers can test before merging

### Preview Environment Variables

Set in Vercel → Settings → Environment Variables:
- Select **Preview** environment
- Use test/staging API keys
- Never use production secrets

### Preview Database Strategy

**Option A: Shared Staging Database**
- All previews use same staging Supabase
- Simpler, but previews can affect each other

**Option B: Branch Databases (Advanced)**
- Create database branch per PR
- More isolation, more complexity
- Use Supabase branching or separate projects

We typically use **Option A** for simplicity.

---

## Staging

Pre-production environment for final testing.

### When to Use Staging

- Final QA before release
- Client demos
- Integration testing with external services
- Load testing

### Staging Setup

**Vercel:**
1. Create branch `staging`
2. In Vercel → Settings → Domains
3. Add `staging.[project].lab.cityfriends.tech`
4. Set branch to `staging`

**Or use Git Integration:**
```
main branch → production
staging branch → staging environment
```

### Staging Environment Variables

```bash
# Staging-specific values
NEXT_PUBLIC_APP_URL=https://staging.project.lab.cityfriends.tech

# Staging Supabase project (separate from prod)
NEXT_PUBLIC_SUPABASE_URL=https://[staging-project].supabase.co

# Test API keys
STRIPE_SECRET_KEY=sk_test_...
```

### Promoting to Production

```bash
# After testing on staging
git checkout main
git merge staging
git push origin main
# Vercel auto-deploys to production
```

---

## Production

Live environment for real users.

### Production Checklist

Before going live:

- [ ] All tests pass
- [ ] Staging thoroughly tested
- [ ] Environment variables set
- [ ] Custom domain configured
- [ ] SSL certificate active
- [ ] Error tracking enabled (Sentry)
- [ ] Uptime monitoring enabled
- [ ] Backup strategy in place

### Production Environment Variables

```bash
# Production values
NEXT_PUBLIC_APP_URL=https://project.lab.cityfriends.tech

# Production Supabase
NEXT_PUBLIC_SUPABASE_URL=https://[prod-project].supabase.co

# Live API keys
STRIPE_SECRET_KEY=sk_live_...
```

### Production Branch Protection

In GitHub → Settings → Branches → Add rule:

- Branch name: `main`
- [x] Require pull request before merging
- [x] Require status checks to pass
- [x] Require branches to be up to date
- [x] Do not allow bypassing

---

## Environment Variables by Environment

### Matrix

| Variable | Development | Preview | Staging | Production |
|----------|-------------|---------|---------|------------|
| `NEXT_PUBLIC_APP_URL` | localhost:3000 | Auto | staging.* | prod URL |
| `SUPABASE_URL` | Local or dev | Staging | Staging | Production |
| `STRIPE_SECRET_KEY` | sk_test_* | sk_test_* | sk_test_* | sk_live_* |
| `SENTRY_DSN` | (optional) | Same | Same | Same |

### Vercel Configuration

```
Vercel Dashboard → Project → Settings → Environment Variables

┌─────────────────────────┬─────────────┬─────────┬────────────┐
│ Variable                │ Production  │ Preview │ Development│
├─────────────────────────┼─────────────┼─────────┼────────────┤
│ SUPABASE_SERVICE_KEY    │ [prod key]  │ [stg]   │ [stg]      │
│ STRIPE_SECRET_KEY       │ sk_live_... │ sk_test │ sk_test    │
│ NEXT_PUBLIC_APP_URL     │ [prod url]  │ (auto)  │ localhost  │
└─────────────────────────┴─────────────┴─────────┴────────────┘
```

---

## Database Environments

### Supabase Projects

| Environment | Supabase Project |
|-------------|------------------|
| Development | Local or `[project]-dev` |
| Preview/Staging | `[project]-staging` |
| Production | `[project]-prod` |

### Why Separate Databases?

- **Data isolation** — Test data doesn't pollute production
- **Schema testing** — Test migrations before prod
- **Performance** — Dev/staging load doesn't affect prod
- **Security** — Limited access to production data

### Syncing Schema

```bash
# Pull schema from production
supabase db pull --linked

# Push to staging
supabase link --project-ref [staging-ref]
supabase db push

# Or use migrations
supabase migration new my_change
# Edit migration file
supabase db push
```

---

## Domain Configuration

### Our Domain Structure

```
lab.cityfriends.tech
├── [project].lab.cityfriends.tech          # Production
├── staging.[project].lab.cityfriends.tech  # Staging
└── (Vercel preview URLs for PRs)
```

### Adding a New Project Domain

1. **Vercel:** Add domain in Project → Settings → Domains
2. **DNS:** Add CNAME record pointing to `cname.vercel-dns.com`
3. **Wait:** SSL certificate auto-provisions (few minutes)

### Custom Client Domains

For client-facing projects:

```
client-app.com → Vercel project
```

1. Client adds CNAME: `@ → cname.vercel-dns.com`
2. Or A record: `@ → 76.76.21.21`
3. Add domain in Vercel
4. Verify and wait for SSL

---

## Quick Reference

### URLs

| Environment | URL |
|-------------|-----|
| Local | `http://localhost:3000` |
| Preview | `https://[branch]-[project].vercel.app` |
| Staging | `https://staging.[project].lab.cityfriends.tech` |
| Production | `https://[project].lab.cityfriends.tech` |

### Commands

```bash
# Local development
npm run dev

# Build locally (test production build)
npm run build && npm start

# Check which environment
echo $NEXT_PUBLIC_APP_URL
```

---

*See also: [CI/CD](ci-cd.md) · [Rollback](rollback.md)*
