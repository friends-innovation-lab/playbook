# Type-Aware Project Spinup Guide

`spinup-typed.sh` creates a new Friends Innovation Lab project with the right
extensions applied based on project type. It replaces the interactive
`spinup.sh` with a non-interactive, flag-driven, idempotent script.

---

## When to use which type

| Type | Use when | Extensions |
|---|---|---|
| `prototype` | Fast demo, hackathon, POC. No compliance needs. | none |
| `internal-tool` | FFTC internal tooling. Needs audit trail + data safety. | audit-log, soft-deletes |
| `saas-web` | Multi-tenant SaaS product. Full enterprise stack. | multi-tenancy, audit-log, soft-deletes |
| `ai-product` | AI-powered product (e.g., Qori). SaaS-web + AI governance. | multi-tenancy, audit-log, soft-deletes (ai-governance deferred) |
| `federal` | Government agency project. Single-tenant + compliance. | audit-log, soft-deletes (federal-uswds deferred) |

**Decision tree:**

1. Is this a quick prototype or demo? → `prototype`
2. Is this an internal FFTC tool? → `internal-tool`
3. Does it need multi-tenancy (multiple orgs/customers)? → `saas-web`
4. Is it AI-powered with model governance needs? → `ai-product`
5. Is it for a federal agency? → `federal`

---

## Prerequisites

### CLI tools

Install all of these before running the script:

```bash
brew install gh jq
brew install supabase/tap/supabase
npm install -g vercel
```

### Authentication

```bash
gh auth login
vercel login
supabase login
```

### Environment variables

Add these to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
export GITHUB_ORG=friends-innovation-lab
export VERCEL_TOKEN=your-vercel-token            # vercel.com → Settings → Tokens
export VERCEL_ORG_ID=your-vercel-team-id         # vercel.com → Settings → General
export LAB_SUPABASE_ORG_ID=your-ci-org-id        # recommended: Friends Lab CI org
export SUPABASE_ORG_ID=your-supabase-org-id      # fallback if LAB_SUPABASE_ORG_ID not set
export LABS_DOMAIN=labs.cityfriends.tech
export SUPABASE_ACCESS_TOKEN=your-token          # optional, for auth config
```

**Supabase org selection:** The script resolves the Supabase org in this order:
1. `--supabase-org <id>` flag (per-spinup override)
2. `LAB_SUPABASE_ORG_ID` env var (recommended default — set to Friends Lab CI org for prototypes/tests)
3. `SUPABASE_ORG_ID` env var (fallback)

If none are set, the script lists available orgs and exits. For production projects, override with `--supabase-org <production-org-id>`.

---

## Usage

### Basic usage

```bash
# Prototype (fastest, no extensions)
./spinup-typed.sh --name my-prototype --type prototype

# Internal tool (audit-log + soft-deletes)
./spinup-typed.sh --name ops-dashboard --type internal-tool

# SaaS web app (full enterprise)
./spinup-typed.sh --name client-portal --type saas-web

# Federal project (audit + soft-deletes, USWDS theme)
./spinup-typed.sh --name va-intake --type federal

# AI product
./spinup-typed.sh --name qori-web --type ai-product
```

### All options

```bash
./spinup-typed.sh \
  --name <project-name> \       # Required. Lowercase, hyphens, 3-40 chars.
  --type <type> \               # Default: prototype
  --description "Project desc" \# Default: auto-generated
  --agency-theme <theme> \      # fftc (default), va, uswds, cms
  --supabase-org <id> \         # Override Supabase org (see env vars above)
  --skip-vercel \               # Don't provision Vercel
  --skip-supabase \             # Don't provision Supabase
  --skip-issues \               # Don't create starter issues
  --dry-run                     # Print plan without doing anything
```

### Dry run

Always do a dry run first to verify your plan:

```bash
./spinup-typed.sh --name my-project --type saas-web --dry-run
```

This prints every step the script would take without creating any resources.

---

## What the script provisions

| Resource | Created by script | Manual after |
|---|---|---|
| GitHub repo (from template) | Yes | — |
| develop branch + default | Yes | — |
| Branch protection on main | Yes | — |
| Labels | Yes | — |
| Project board | Yes | — |
| Supabase project | Yes (unless --skip) | Sentry, Resend, Upstash |
| Supabase migrations | Yes (including extensions) | — |
| Supabase auth redirects | Yes (if SUPABASE_ACCESS_TOKEN set) | Manual otherwise |
| Vercel project | Yes (unless --skip) | — |
| Vercel env vars | Yes | Sentry DSN, Resend key |
| Custom subdomain | Yes | DNS propagation ~5 min |
| Extension code (lib, migrations, tests) | Yes | Review + customize |
| CLAUDE.md context | Yes | — |
| GitHub secrets for CI | Yes | — |

---

## What extensions add

### audit-log

- `supabase/migrations/001_audit_log.sql` — audit_log table with append-only constraint
- `src/lib/audit.ts` — TypeScript helper for recording audit events
- `tests/audit.test.ts` — Integration tests

### soft-deletes

- `supabase/migrations/001_soft_delete_helpers.sql` — soft_delete/restore/hard_delete functions
- `src/lib/soft-delete.ts` — TypeScript query helpers
- `tests/soft-delete.test.ts` — Integration tests

### multi-tenancy

- `supabase/migrations/001_organizations_and_org_id.sql` — organizations + org_members tables
- `src/lib/org-context.ts` — Organization context management
- `src/components/OrgSwitcher.tsx` — UI component for switching orgs
- `supabase/rls-policies.sql` — Row-level security policies
- `tests/multi-tenancy.test.ts` — Integration tests

---

## Troubleshooting

### "Pre-flight checks failed"

The script checks for all required CLI tools and environment variables before
doing anything. Fix the listed issues and re-run. The script is idempotent,
so re-running is safe.

### "Supabase project creation failed"

- Check `supabase projects list` — you may be at the free tier project limit
- Verify `SUPABASE_ORG_ID` is correct
- Try creating the project manually at supabase.com, then re-run with `--skip-supabase`

### "Vercel project creation failed"

- Check that `VERCEL_TOKEN` has the right scopes
- Verify `VERCEL_ORG_ID` matches your team
- Try `--skip-vercel` and create the project manually

### Script failed partway through

The script prints which resources were created before the failure. You can:

1. Fix the issue and re-run — each step checks if the action was already done
2. Clean up manually using `teardown.sh` or the individual service dashboards

The script does NOT auto-rollback. This is intentional — you may want to
inspect the partial state before deciding what to do.

### "lab-extensions/ directory not found"

The project template doesn't have the lab-extensions directory. Make sure
`friends-innovation-lab/project-template` has been updated to Phase 2
(the version with lab-extensions/).

---

## Migration from spinup.sh

The original `spinup.sh` is preserved as a deprecated fallback. Key differences:

| Feature | spinup.sh | spinup-typed.sh |
|---|---|---|
| Interface | Interactive prompts | CLI flags |
| Project types | Government / Internal | 5 types with extensions |
| Extensions | None | Applies lab-extensions |
| Idempotent | No | Yes (safe to re-run) |
| Dry run | No | Yes |
| Lab standards | Not integrated | Integrated |

**When to use spinup.sh:** Only if `spinup-typed.sh` has a bug and you need to
unblock immediately. File an issue if this happens.

**When to switch:** After one successful project has been spun up with
`spinup-typed.sh`, we'll mark `spinup.sh` as officially deprecated.

---

## References

- [Lab standards](https://github.com/friends-innovation-lab/lab-standards) — the 9 standards
- [Project template](https://github.com/friends-innovation-lab/project-template) — base template + extensions
- [RETROFIT-PLAYBOOK.md](https://github.com/friends-innovation-lab/lab-standards/blob/main/RETROFIT-PLAYBOOK.md) — for existing projects
- [audit-project.sh](https://github.com/friends-innovation-lab/lab-standards/tree/main/lab-templates/scripts/audit-project.sh) — gap analysis for existing projects
