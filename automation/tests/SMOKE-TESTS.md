# PLAT-01 Healthy-Path Live Smoke Tests

Read-only provider verification using authorized staff credentials.
These tests verify the happy path only — they do not create failure states.

## Requirements

- Authorized staff credentials for each provider
- No resource mutations (all calls are GET-only)
- Run under bash (`/bin/bash`), not zsh
- Do not revoke credentials, remove users, alter IDs, or create scope mismatches

## Vercel

```bash
/bin/bash -c '
export VERCEL_TOKEN="<your-vercel-token>"
source ./automation/preflight-lib.sh
resolve_provider_context vercel 2>/dev/null
echo "rc=$?"
echo "error=${PREFLIGHT_ERROR_CODE:-<empty>}"
echo "actor=${VERCEL_CTX_ACTOR_NAME:-<empty>}"
echo "scope_id=${VERCEL_CTX_SCOPE_ID:-<empty>}"
echo "scope_slug=${VERCEL_CTX_SCOPE_SLUG:-<empty>}"
echo "permission=${VERCEL_CTX_PERMISSION:-<empty>}"
'
```

Expected:
- rc=0
- scope_id = `team_fsGOVzcYUm5XwV8xJ7VeZbkv`
- scope_slug = `friends-innovation-lab`
- permission contains `role:` evidence

## Supabase

```bash
/bin/bash -c '
export SUPABASE_ACCESS_TOKEN="<your-supabase-token>"
source ./automation/preflight-lib.sh
resolve_provider_context supabase 2>/dev/null
echo "rc=$?"
echo "error=${PREFLIGHT_ERROR_CODE:-<empty>}"
echo "actor=${SUPABASE_CTX_ACTOR_NAME:-<empty>}"
echo "scope_id=${SUPABASE_CTX_SCOPE_ID:-<empty>}"
echo "scope_name=${SUPABASE_CTX_SCOPE_NAME:-<empty>}"
echo "permission=${SUPABASE_CTX_PERMISSION:-<empty>}"
echo "org_roles=${_SUPABASE_ORG_ROLES:-<empty>}"
'
```

Expected:
- rc=0
- scope_id = `esiwooovlhcuifbbkodk`
- scope_name = `Friends Innovation Lab`
- permission contains `org_roles:` evidence

## GitHub

```bash
/bin/bash -c '
source ./automation/preflight-lib.sh
resolve_provider_context github 2>/dev/null
echo "rc=$?"
echo "error=${PREFLIGHT_ERROR_CODE:-<empty>}"
echo "actor=${GITHUB_CTX_ACTOR_NAME:-<empty>}"
echo "scope_id=${GITHUB_CTX_SCOPE_ID:-<empty>}"
echo "scope_slug=${GITHUB_CTX_SCOPE_SLUG:-<empty>}"
echo "permission=${GITHUB_CTX_PERMISSION:-<empty>}"
'
```

Expected:
- rc=0
- scope_id = `254572218`
- scope_slug = `friends-innovation-lab`
- permission contains `role:` and `policy_completeness:partial`

## Notes

- GitHub `SCOPE_NAME` may show `friends-innovation-lab` (the login) rather
  than a display name. This is a REPRESENTATION FALLBACK — `org.name` was
  observed as null for this org. Do not treat this as display-name evidence.
- Vercel `teamPermissions` may be absent from the response for OWNER role.
  This is documented WP0/WP2 observed behavior.
- All smoke tests must run under `/bin/bash` due to the bash shebang on
  `preflight-lib.sh`. Running under zsh causes `curl` resolution failures.
