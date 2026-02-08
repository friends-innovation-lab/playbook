# Secrets Management

*How we handle secrets and environment variables at Friends Innovation Lab.*

---

## Golden Rules

1. **Never commit secrets** — Not even once, not even "temporarily"
2. **Never log secrets** — They end up in monitoring systems
3. **Never expose to client** — Browser code is public
4. **Rotate if exposed** — Assume it's compromised

---

## Environment Variables

### File Structure

```
project/
├── .env.example          # Template (committed)
├── .env.local            # Local development (NOT committed)
├── .env.development      # Dev overrides (NOT committed)
├── .env.production       # Prod values (NOT committed, set in Vercel)
└── .gitignore            # Must include .env*
```

### .env.example (Committed)

```bash
# .env.example
# Copy to .env.local and fill in values

# Supabase
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# Auth (if using external providers)
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=

# External APIs
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### .env.local (Never Committed)

```bash
# .env.local
# Actual values - NEVER COMMIT THIS FILE

NEXT_PUBLIC_SUPABASE_URL=https://abc123.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### .gitignore

```gitignore
# Environment variables
.env
.env.local
.env.development
.env.production
.env*.local

# Never commit these
*.pem
*.key
secrets/
```

---

## Next.js Environment Variables

### Public vs Private

| Prefix | Accessible | Use For |
|--------|------------|---------|
| `NEXT_PUBLIC_` | Client + Server | Public config (API URLs, feature flags) |
| (no prefix) | Server only | Secrets (API keys, DB credentials) |

```typescript
// ✅ Safe - server only
const apiKey = process.env.STRIPE_SECRET_KEY

// ✅ Safe - intentionally public
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL

// ❌ DANGER - secret exposed to browser!
const secret = process.env.NEXT_PUBLIC_STRIPE_SECRET_KEY
```

### Accessing Variables

```typescript
// Server Component / API Route
export async function GET() {
  const secretKey = process.env.STRIPE_SECRET_KEY // ✅ Works
  // ...
}

// Client Component
'use client'
export function Component() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL // ✅ Works
  const key = process.env.STRIPE_SECRET_KEY // ❌ undefined (server-only)
}
```

### Runtime Validation

```typescript
// lib/env.ts
import { z } from 'zod'

const envSchema = z.object({
  // Server-only
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1),
  STRIPE_SECRET_KEY: z.string().startsWith('sk_'),

  // Public
  NEXT_PUBLIC_SUPABASE_URL: z.string().url(),
  NEXT_PUBLIC_SUPABASE_ANON_KEY: z.string().min(1),
  NEXT_PUBLIC_APP_URL: z.string().url(),
})

export const env = envSchema.parse({
  SUPABASE_SERVICE_ROLE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY,
  STRIPE_SECRET_KEY: process.env.STRIPE_SECRET_KEY,
  NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
  NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  NEXT_PUBLIC_APP_URL: process.env.NEXT_PUBLIC_APP_URL,
})

// Usage
import { env } from '@/lib/env'
const stripe = new Stripe(env.STRIPE_SECRET_KEY)
```

This fails fast at startup if variables are missing.

---

## Vercel Environment Variables

### Setting Variables

1. Go to **Vercel Dashboard → Project → Settings → Environment Variables**
2. Add each variable
3. Select environments: **Production**, **Preview**, **Development**

### Best Practices

| Variable | Production | Preview | Development |
|----------|------------|---------|-------------|
| `STRIPE_SECRET_KEY` | Live key | Test key | Test key |
| `DATABASE_URL` | Prod DB | Staging DB | Local DB |
| `NEXT_PUBLIC_APP_URL` | https://app.com | Auto (preview URL) | http://localhost:3000 |

### Sensitive Variables

Check **"Sensitive"** for:
- API keys
- Database credentials
- OAuth secrets
- Webhook secrets

Sensitive variables are encrypted and hidden in logs.

---

## Supabase Secrets

### What Each Key Does

| Key | Access Level | Use In |
|-----|--------------|--------|
| `anon` key | Public, limited by RLS | Client-side |
| `service_role` key | Full access, bypasses RLS | Server-side only |

```typescript
// ❌ NEVER use service_role in client
const supabase = createClient(url, process.env.SUPABASE_SERVICE_ROLE_KEY)

// ✅ Use anon key in client
const supabase = createClient(url, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY)

// ✅ Service role only in server code
// lib/supabase/admin.ts (server only)
export const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)
```

### Rotating Supabase Keys

1. Go to **Supabase Dashboard → Settings → API**
2. Click **"Roll API Keys"**
3. Update in Vercel/local env
4. Redeploy

---

## API Keys

### Storage

| Key Type | Where to Store |
|----------|----------------|
| Development | `.env.local` |
| Production | Vercel Environment Variables |
| Shared/Team | 1Password or similar |

### Rotation Schedule

| Key Type | Rotation Frequency |
|----------|-------------------|
| Production API keys | Every 90 days |
| OAuth secrets | Every 90 days |
| Webhook secrets | On suspected compromise |
| Database passwords | Every 90 days |

### After Rotation

1. Update in Vercel
2. Redeploy all environments
3. Update in 1Password
4. Notify team

---

## What If Secrets Are Exposed?

### Immediate Actions

1. **Rotate immediately** — Generate new key
2. **Check for abuse** — Review logs, billing
3. **Update everywhere** — Vercel, local, team password manager
4. **Review git history** — Use BFG Repo Cleaner if committed

### Removing from Git History

If a secret was committed:

```bash
# Install BFG
brew install bfg

# Remove file containing secret
bfg --delete-files .env.local

# Or replace text
bfg --replace-text passwords.txt

# Clean up
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Force push (coordinate with team!)
git push --force
```

**Note:** Anyone who cloned the repo still has the old history. Rotate the secret regardless.

---

## Common Mistakes

| Mistake | Why It's Bad | Fix |
|---------|--------------|-----|
| Committing `.env.local` | Secrets in git history forever | Add to `.gitignore` before creating |
| `NEXT_PUBLIC_` on secrets | Exposed in browser bundle | Remove prefix, use server-only |
| Logging `process.env` | Secrets in logs | Log specific, non-secret values |
| Hardcoding for "quick test" | Forget to remove | Always use env vars |
| Same key for all environments | Prod breach affects everything | Separate keys per environment |
| Sharing keys via Slack/email | Insecure, no audit trail | Use 1Password or similar |

---

## Checklist

### New Project Setup

- [ ] `.env.example` created with all variables (no values)
- [ ] `.env.local` in `.gitignore`
- [ ] Variables set in Vercel for all environments
- [ ] Team has access to shared password manager

### Before Deploying

- [ ] No secrets in code (grep for API keys)
- [ ] No `NEXT_PUBLIC_` on sensitive values
- [ ] All required env vars set in Vercel
- [ ] Preview and production have different keys where needed

### Regular Maintenance

- [ ] Keys rotated on schedule
- [ ] Unused keys deleted
- [ ] Team access reviewed
- [ ] Audit logs checked (if available)

---

## Quick Reference

### Check for Exposed Secrets

```bash
# Search for potential secrets in codebase
grep -r "sk_live" .
grep -r "sk_test" .
grep -r "eyJhbGci" .  # JWT tokens
grep -r "password" . --include="*.ts" --include="*.tsx"
```

### Validate Environment

```typescript
// Add to app startup
function validateEnv() {
  const required = [
    'NEXT_PUBLIC_SUPABASE_URL',
    'NEXT_PUBLIC_SUPABASE_ANON_KEY',
    'SUPABASE_SERVICE_ROLE_KEY',
  ]

  const missing = required.filter(key => !process.env[key])

  if (missing.length > 0) {
    throw new Error(`Missing env vars: ${missing.join(', ')}`)
  }
}
```

---

*See also: [Input Validation](input-validation.md) · [Compliance](compliance.md)*
