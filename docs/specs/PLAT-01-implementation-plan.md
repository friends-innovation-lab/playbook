# PLAT-01 Implementation Plan

Answers to the 10 Implementation Plan Questions required by the spec,
plus the 6 investigation items requested for this session.

---

## Verification Status Legend

- **VERIFIED**: Confirmed from provider documentation fetched this session
- **VERIFIED-CODE**: Confirmed by reading actual source code
- **UNVERIFIED**: Inferred from training data; needs live confirmation before code

---

## 1. Call-Site Map

**Status: VERIFIED-CODE** (grep of all consumers in `automation/`)

### Public functions in `preflight-lib.sh`

| Function | Return | Side-effect variables |
|---|---|---|
| `validate_vercel_token()` | 0=ok, 1=fail | `VERCEL_VALIDATE_USER` (success), `VERCEL_VALIDATE_ERROR` (failure: `not_set` / `invalid_token` / `api_error`) |
| `print_vercel_token_help()` | void | Reads `VERCEL_VALIDATE_ERROR` |
| `validate_github_api()` | 0=ok, 1=fail | `GITHUB_VALIDATE_USER` (success) |
| `validate_supabase_token()` | 0=ok, 1=fail | `SUPABASE_VALIDATE_ERROR` (failure: `not_set` / `invalid_token` / `api_error`) |

### spinup-typed.sh

| Location | Function | Expectation |
|---|---|---|
| L555-560 | `source "$_PREFLIGHT_LIB"` | Defines all four functions; path resolved via `BASH_SOURCE` |
| L563 | `validate_github_api` | Return code checked; reads `GITHUB_VALIDATE_USER` for display |
| L572 | `validate_vercel_token` | Return code checked; reads `VERCEL_VALIDATE_USER` for display |
| L576 | `print_vercel_token_help` | Called on token failure |
| L588 | `validate_supabase_token` | Return code checked |
| L591 | `SUPABASE_VALIDATE_ERROR` | Read directly for `not_set` vs. other failure branching |

**Resume path (L204-482):** Branches before L555. Never sources `preflight-lib.sh`. No validation functions are available in resume mode.

### spinup.sh (deprecated)

| Location | Function | Expectation |
|---|---|---|
| L132-137 | `source "$_PREFLIGHT_LIB"` | Same path resolution pattern |
| L139 | `validate_github_api` | Return code + `GITHUB_VALIDATE_USER` |
| L146 | `validate_vercel_token` | Return code + `VERCEL_VALIDATE_USER` |
| L150 | `print_vercel_token_help` | Called on failure |
| L212 | `validate_supabase_token` | Return code checked |
| L215 | `SUPABASE_VALIDATE_ERROR` | Read directly for `not_set` branching |

### teardown.sh

| Location | Function | Expectation |
|---|---|---|
| L205-210 | `source "$_PREFLIGHT_LIB"` | Same path resolution pattern |
| L213 | `validate_github_api` | Return code + `GITHUB_VALIDATE_USER` |
| L264 | `validate_vercel_token` | Return code + `VERCEL_VALIDATE_USER` |
| L268 | `print_vercel_token_help` | Called on failure |
| L283 | `validate_supabase_token` | Return code checked |
| L286 | `SUPABASE_VALIDATE_ERROR` | Read directly for `not_set` branching (uses `${SUPABASE_VALIDATE_ERROR:-}` defensive form) |

---

## 2. Which functions remain as compatibility wrappers

All four public functions must remain:

| Legacy function | Wraps (PLAT-01) | Notes |
|---|---|---|
| `validate_vercel_token()` | `validate_vercel_credential` | Credential-only; must NOT call `resolve_vercel_context` |
| `print_vercel_token_help()` | New diagnostic renderer (filtered to credential codes) | Must preserve existing output for `not_set` / other branching |
| `validate_github_api()` | `validate_github_credential` | Credential-only |
| `validate_supabase_token()` | `validate_supabase_credential` | Credential-only |

Critical constraint: wrappers must set the same side-effect variables (`VERCEL_VALIDATE_USER`, `VERCEL_VALIDATE_ERROR`, `GITHUB_VALIDATE_USER`, `SUPABASE_VALIDATE_ERROR`) with the same values for the same conditions. Consumer scripts read these variables directly.

---

## 3. How each provider exposes actor ID and display name

### GitHub — VERIFIED

- **API call:** `GET /user` (via `gh api user`)
- **Actor ID:** `.id` (numeric integer)
- **Actor name:** `.login` (string)
- **Source:** https://docs.github.com/en/rest/users/users#get-the-authenticated-user

### Vercel — VERIFIED

- **API call:** `GET /v2/user`
- **Actor ID:** `.user.uid` (string)
- **Actor name:** `.user.username` (string)
- **Source:** https://vercel.com/docs/rest-api/endpoints/user

Current `validate_vercel_token()` already does this (L25-35 of preflight-lib.sh) using `.username` from the response. The response path may be `.user.username` or `.username` depending on API version — **needs live verification** during WP2.

### Supabase — VERIFIED

- **API call:** `GET /v1/profile`
- **Actor ID:** `.gotrue_id` (string)
- **Actor name:** `.username` (string)
- **Source:** https://supabase.com/docs/reference/api/v1-get-profile

This is new — the current `validate_supabase_token()` does not call `/v1/profile`. It calls `GET /v1/organizations` and checks for an array response. The new resolver will use `/v1/profile` for actor identity.

---

## 4. Exact API call proving canonical scope identity by ID

### Vercel — VERIFIED

**Call:** `GET /v2/teams/{LAB_VERCEL_TEAM_ID}`

- Accepts `team_xxx` ID as path parameter
- Returns `id`, `slug`, `name` (all required fields)
- Returns `membership` object inline with authenticated user's `role` and `teamPermissions`
- HTTP 401 = not authorized, 403 = no access to team, 404 = team not found
- **Source:** https://vercel.com/docs/rest-api/teams/get-a-team

This is the ideal endpoint: one call proves scope identity, scope access, and permission. Identity verification is `response.id === LAB_VERCEL_TEAM_ID` and `response.slug === LAB_VERCEL_TEAM_SLUG`.

### Supabase — PROVIDER LIMITATION

**There is no `GET /v1/organizations/{id}` endpoint.**

The documented endpoint is `GET /v1/organizations/{slug}` — it takes the org **slug**, not the org ID.

- Returns `id`, `name`, `plan` (no `slug` in response per docs)
- **Source:** https://supabase.com/docs/reference/api/v1-get-an-organization

**Impact on spec:** The spec requires "canonical scope retrieved by ID" (Resolver Ordering step 5) and "No scope lookup by human-readable name may replace step 5."

**Available workaround (two options):**

1. **Enumerate + filter:** Call `GET /v1/organizations` (returns all orgs), filter by `id === LAB_SUPABASE_ORG_ID`. This retrieves by ID from the list, never looks up by name. The list endpoint returns `id`, `slug`, `name` per org.

2. **Slug lookup + ID verification:** Call `GET /v1/organizations/{slug}`, verify `response.id === LAB_SUPABASE_ORG_ID`. This uses the slug as a lookup key but the canonical ID is the verification authority.

**Recommendation:** Option 1 (enumerate + filter). It satisfies the spec literally — the canonical ID is the selection criterion, not the slug. The list is bounded (a user belongs to a small number of orgs). Option 2 technically violates the spec's prohibition on name-based lookup replacing step 5.

**This must be approved before WP3 proceeds.**

### GitHub — PROVIDER LIMITATION

**There is no `GET /organizations/{org_id}` endpoint in the documented REST API.**

The documented endpoint is `GET /orgs/{org}` — it takes the org **login/slug**, not the numeric ID.

- Returns `id` (integer), `login` (string), `name` (string)
- **Source:** https://docs.github.com/en/rest/orgs/orgs#get-an-organization

**UNVERIFIED:** GitHub may have an undocumented `GET /organizations/{org_id}` endpoint (common in older GitHub API usage). This needs live verification:

```bash
gh api /organizations/$(gh api /orgs/friends-innovation-lab --jq '.id')
```

If that works, we have a direct ID-based lookup. If not:

**Available workaround (same pattern as Supabase):**

1. **Enumerate + filter:** Call `GET /user/orgs` (via `gh api /user/orgs`), filter by `id === LAB_GITHUB_ORG_ID`.

2. **Slug lookup + ID verification:** Call `GET /orgs/{slug}`, verify `response.id === LAB_GITHUB_ORG_ID`.

**Additional complication:** GitHub returns 404 for both "org doesn't exist" and "you don't have access" — the `scope_not_found` vs. `scope_access_denied` distinction cannot be made from this endpoint alone. See section 6 below.

**Recommendation:** Try the undocumented endpoint first during WP0 bootstrap. If it works, use it. If not, use Option 1 (enumerate + filter via `/user/orgs`). Either way, the GitHub limitation on 404 ambiguity is a separate issue that must be documented as a known deviation.

**This must be verified live and approved before WP4 proceeds.**

---

## 5. Exact API call or role check proving required workflow permission

### Vercel — VERIFIED

**No separate call needed.** `GET /v2/teams/{teamId}` returns `membership.teamPermissions` inline.

Required permissions for spinup/teardown workflows:
- `CreateProject` — project creation
- `EnvVariableManager` — environment variable management
- `FullProductionDeployment` — production deployments

Available roles (from docs): `OWNER`, `MEMBER`, `DEVELOPER`, `CONTRIBUTOR`, `VIEWER`, `BILLING`, `SECURITY`, `VIEWER_FOR_PLUS`

**Permission check:** Verify `membership.teamPermissions` array contains `CreateProject` (minimum for spinup). The exact required set for teardown (project deletion) is **UNVERIFIED** — deletion permissions are not listed in `teamPermissions` enum. This needs live verification:

```bash
curl -s -H "Authorization: Bearer $VERCEL_TOKEN" \
  "https://api.vercel.com/v2/teams/${TEAM_ID}" | jq '.membership.teamPermissions'
```

**If project deletion permission is not enumerable:** The resolver can verify `CreateProject` as a proxy for "has project-level write access." Flag as known limitation.

### Supabase — PARTIAL VERIFICATION

**Call:** `GET /v2/organizations/{slug}/members` — returns all members with roles.

- Each member has `roles[].name` (e.g., `"developer"`, `"owner"`)
- To find the authenticated user's role: filter by matching `data[].id` against the `gotrue_id` from `GET /v1/profile`
- **Source:** https://supabase.com/docs/reference/api/v2-list-organization-members

**UNVERIFIED:** What role is required for `supabase projects create`? The Supabase docs don't enumerate permission-to-role mappings. Likely `owner` or `developer` but this needs live testing.

**Alternative:** `GET /v2/organizations/{slug}/roles` lists available roles in the org but does NOT return which role the current user has. Not useful for permission checking.

**Provider limitation:** There is no "check my permissions" endpoint. The only way to determine the authenticated user's role is to:
1. Get actor identity via `GET /v1/profile` (get `gotrue_id`)
2. Enumerate org members via `GET /v2/organizations/{slug}/members`
3. Filter for matching member
4. Read `roles[].name`

This is functional but requires two calls and paginated member enumeration. For small orgs (ours), pagination is not a concern.

### GitHub — VERIFIED

**Call:** `GET /user/memberships/orgs/{org}` — returns the authenticated user's membership in a specific org.

- Returns `role` (`admin`, `member`, `billing_manager`) and `state` (`active`, `pending`)
- **Source:** https://docs.github.com/en/rest/orgs/members

For repo creation, `member` role with active state is sufficient (assuming org settings allow member repo creation — **UNVERIFIED** for the friends-innovation-lab org specifically).

**Alternative:** `GET /orgs/{org}/memberships/{username}` returns the same data but requires knowing the username (available from step 3).

---

## 6. How 401/403/404/5xx are distinguished per provider

### Vercel — VERIFIED (clean separation)

| HTTP Code | Meaning | Response shape | Diagnostic code |
|---|---|---|---|
| 200 | Success | `{ id, slug, name, membership, ... }` | — |
| 401 | Invalid/missing token | `{ error: { code: "...", message: "..." } }` | `credential_invalid` |
| 403 | Token valid, no team access | `{ error: { code: "...", message: "..." } }` | `scope_access_denied` |
| 404 | Team ID doesn't exist | `{ error: { code: "...", message: "..." } }` | `scope_not_found` |
| 5xx | Server error | varies | `provider_unavailable` |

All error responses have a consistent `error.code` / `error.message` structure. `curl -s` exits 0 on HTTP errors, so the resolver must check `http_code` from `-w "%{http_code}"` and parse the body.

### Supabase — VERIFIED (clean separation for listed codes)

The `GET /v1/organizations` endpoint documents:

| HTTP Code | Meaning | Diagnostic code |
|---|---|---|
| 200 | Success | — |
| 401 | Invalid/expired token | `credential_invalid` |
| 403 | Token valid, insufficient scope | `scope_access_denied` |
| 429 | Rate limited | `provider_unavailable` |
| 500 | Server error | `provider_unavailable` |

**UNVERIFIED:** The response body shape for 401/403/500 errors. Supabase API docs don't show error response schemas. Needs live testing to determine whether a JSON error body is returned or a plain text message.

**Provider limitation:** Since org lookup is by enumeration (`GET /v1/organizations`), the `scope_not_found` case is determined by the canonical ID being absent from the returned array — not by an HTTP 404. This is clean and unambiguous.

### GitHub — PROVIDER LIMITATION (404 ambiguity)

| HTTP Code | Meaning | Diagnostic code |
|---|---|---|
| 200 | Success | — |
| 401 | Bad credentials | `credential_invalid` |
| 404 | Org not found **OR** no access | **AMBIGUOUS** |
| 403 | Rate limited / forbidden | context-dependent |

**The critical limitation:** GitHub deliberately returns 404 for private/inaccessible resources to avoid leaking existence. This means `scope_not_found` and `scope_access_denied` are indistinguishable from `GET /orgs/{org}`.

**Workaround:** If using the enumerate approach (`GET /user/orgs`, filter by ID), the ambiguity doesn't arise:
- Canonical ID found in list → scope exists and is accessible
- Canonical ID not found in list → could be "doesn't exist" or "no access"

Since the canonical IDs are bootstrapped and reviewed (WP0), a "not found" at runtime means access was revoked, not that the org disappeared. The resolver can safely classify this as `scope_access_denied` with a detail note: "Canonical org ID not found in your accessible organizations. Either access was revoked or the org was deleted — verify with an admin."

**This deviation from exact `scope_not_found` vs. `scope_access_denied` separation must be documented as a known limitation.**

---

## 7. How raw provider invocation will be statically prevented/detected inside resolvers

The spec requires provider-call seam functions. Static detection:

**Approach:** A shell script (`automation/tests/static-checks.sh`) that greps resolver function bodies for raw provider calls.

```text
Prohibited patterns inside resolver functions:
  - curl (raw HTTP)
  - gh api / gh repo / gh ... (raw GitHub CLI)
  - vercel (raw Vercel CLI)
  - supabase (raw Supabase CLI)

Allowed:
  - _provider_github_api
  - _provider_vercel_api
  - _provider_vercel_cli
  - _provider_supabase_api
```

**Implementation:** Parse `preflight-lib.sh` to extract function bodies between resolver function definitions. Grep each body for prohibited patterns. This is fragile for complex shell but sufficient for the controlled codebase.

**Alternative (recommended):** Place resolver functions in a separate sourced file (`automation/resolvers.sh`) with a header comment convention, and grep the entire file for raw calls. Simpler, less fragile. But the spec places everything in `preflight-lib.sh` — this alternative would need spec approval.

**Decision needed:** Does the spec permit splitting resolvers into a separate file sourced by `preflight-lib.sh`, or must all code live in one file?

---

## 8. How `provider-scopes.sh` gets sourced safely from current script locations

### File location

```text
automation/config/provider-scopes.sh
```

### Source paths

All three consumers resolve `SCRIPT_DIR` identically:

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

This resolves to the `automation/` directory. So `provider-scopes.sh` is at:

```bash
"${SCRIPT_DIR}/config/provider-scopes.sh"
```

### Sourcing strategy

`preflight-lib.sh` sources `provider-scopes.sh` relative to its own location (not the consumer's `SCRIPT_DIR`):

```bash
# Inside preflight-lib.sh
_PREFLIGHT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_PROVIDER_SCOPES="${_PREFLIGHT_DIR}/config/provider-scopes.sh"
```

This works regardless of which consumer sources `preflight-lib.sh`, because `BASH_SOURCE[0]` inside `preflight-lib.sh` resolves to `preflight-lib.sh` itself, not the consumer.

### Resume path problem

**VERIFIED-CODE:** The resume path in `spinup-typed.sh` (L204-482) exits before `preflight-lib.sh` is sourced (L555-560). This means:

- During PLAT-01: No impact. Compatibility wrappers are not called in resume mode. Resume mode uses raw `curl` calls directly.
- During later migration: Resume mode must be fixed to source `preflight-lib.sh` (and therefore `provider-scopes.sh`) before using any resolver or ProviderContext. This is explicitly out of scope for PLAT-01.

For PLAT-01, `provider-scopes.sh` is sourced eagerly when `preflight-lib.sh` loads. Resolver functions check for required canonical IDs and fail with `scope_config_missing` if absent. No new code path in resume mode calls resolver functions.

---

## 9. Rollback boundary per WP

### WP0 — Bootstrap

**Files changed:**
- `automation/bootstrap-provider-scopes.sh` (new)
- `automation/config/provider-scopes.sh` (new)

**Rollback:** `git revert <WP0-commit>`. Deletes both files. No existing script references them. Zero impact on spinup/teardown.

**Mid-migration state:** If WP0 is committed but WP1-5 are not, the config file exists but nothing reads it. Harmless.

### WP1 — Shared context, diagnostics, provider-call seam

**Files changed:**
- `automation/preflight-lib.sh` (modified: new functions added, no existing functions changed)
- `automation/tests/preflight-lib.test.sh` (new)
- `automation/tests/fixtures/**` (new)

**Rollback:** `git revert <WP1-commit>`. Removes new functions. Existing public functions are unchanged in WP1, so revert is clean. Tests and fixtures are deleted.

**What reverting WP1 alone looks like:** `preflight-lib.sh` returns to its pre-PLAT-01 state. Provider-scopes.sh still exists (from WP0) but is not sourced. No consumer behavior changes.

### WP2 — Vercel resolver

**Files changed:**
- `automation/preflight-lib.sh` (modified: Vercel resolver functions added)
- `automation/tests/preflight-lib.test.sh` (modified: Vercel test cases added)
- `automation/tests/fixtures/vercel/**` (new)

**Rollback:** `git revert <WP2-commit>`. Removes Vercel resolver functions and test cases. Compatibility wrapper `validate_vercel_token()` is unaffected because WP2 adds the resolver alongside it, not behind it. The wrapper delegates to the new credential function only in WP5.

**What reverting WP2 alone looks like:** Vercel resolver functions disappear. WP1 scaffolding remains. WP3/WP4 resolvers (if committed) are unaffected. Compatibility wrappers still call original logic.

### WP3 — Supabase resolver

Same pattern as WP2. Independent revert removes Supabase resolver. No cross-dependency with WP2 or WP4.

### WP4 — GitHub resolver

Same pattern. Independent revert.

### WP5 — Compatibility wrappers + smoke + release

**Files changed:**
- `automation/preflight-lib.sh` (modified: existing public functions become thin wrappers)
- `automation/tests/SMOKE-TESTS.md` (new)
- `automation/tests/preflight-lib.test.sh` (modified: update static-check allowed list)

**Rollback:** `git revert <WP5-commit>`. Restores original implementation inside public functions. New resolver code (from WP2-4) still exists but is now uncalled.

**WP5 prerequisite — static-check allowed-list update:** The WP1 static seam check exempts four legacy functions from raw-provider-call enforcement: `validate_vercel_token`, `print_vercel_token_help`, `validate_github_api`, `validate_supabase_token`. When WP5 migrates these to the seam (making them thin wrappers that delegate to resolver functions), they must be removed from the `ALLOWED_RAW` array in `preflight-lib.test.sh`. Leaving them in would silently exempt functions that no longer need the exemption.

**This is the riskiest revert.** If WP5 is reverted but WP2-4 remain, the resolvers exist but are unused. Compatibility wrappers revert to original `curl`-based validation. This is the correct state — the spec's main compatibility guarantee.

---

## 10. Evidence proving current spinup/teardown behavior did not change

### Test 1: Compatibility wrapper output comparison

**Method:** Before WP5 (wrapper migration), capture baseline output. After WP5, compare.

```bash
# Before PLAT-01 (baseline)
source automation/preflight-lib.sh

# Valid credentials
validate_vercel_token; echo "rc=$? user=${VERCEL_VALIDATE_USER} err=${VERCEL_VALIDATE_ERROR}"
validate_github_api; echo "rc=$? user=${GITHUB_VALIDATE_USER}"
validate_supabase_token; echo "rc=$? err=${SUPABASE_VALIDATE_ERROR}"

# Invalid credentials (unset token)
unset VERCEL_TOKEN
validate_vercel_token; echo "rc=$? user=${VERCEL_VALIDATE_USER} err=${VERCEL_VALIDATE_ERROR}"

# Save all output to baseline.txt
```

Run the same after PLAT-01. Diff must be empty for return codes and variable values.

### Test 2: Dry-run comparison

```bash
# Before PLAT-01
./automation/spinup-typed.sh --name test-plat01 --type prototype --dry-run 2>&1 | tee spinup-baseline.txt

# After PLAT-01
./automation/spinup-typed.sh --name test-plat01 --type prototype --dry-run 2>&1 | tee spinup-after.txt

diff spinup-baseline.txt spinup-after.txt
```

Dry-run exercises the full preflight path without mutations. Diff must be empty (or show only cosmetic changes like timestamps).

### Test 3: Teardown dry-run comparison

```bash
# Before PLAT-01
./automation/teardown.sh --dry-run 2>&1 | tee teardown-baseline.txt
# (enter a known project name when prompted)

# After PLAT-01
./automation/teardown.sh --dry-run 2>&1 | tee teardown-after.txt

diff teardown-baseline.txt teardown-after.txt
```

### Test 4: Static verification

```bash
# Verify all legacy function names still exist
grep -c '^validate_vercel_token()' automation/preflight-lib.sh    # must be 1
grep -c '^print_vercel_token_help()' automation/preflight-lib.sh  # must be 1
grep -c '^validate_github_api()' automation/preflight-lib.sh      # must be 1
grep -c '^validate_supabase_token()' automation/preflight-lib.sh  # must be 1
```

### Test 5: Automated unit tests (mocked boundary)

All 14 diagnostic codes tested without network. Provider wrappers replaced with fixture-returning functions. Each test verifies:
- Correct diagnostic code is set
- Correct return code
- Correct remediation message rendered
- No partial ProviderContext populated on failure

---

## Provider Limitations Summary

These must be resolved or accepted before code changes begin:

### 1. GitHub: No org-by-ID endpoint (documented)

**Impact:** Spec step 5 ("canonical scope retrieved by ID") cannot be implemented via direct API lookup.
**Workaround:** Enumerate via `GET /user/orgs`, filter by ID. Bootstrap used `GET /orgs/{slug}` for resolution, then verified the returned ID. Resolvers will use enumerate-and-filter.
**Status:** VERIFIED — confirmed during WP0 bootstrap. No undocumented `/organizations/{id}` endpoint was tested; enumerate approach approved.

### 2. GitHub: 404 ambiguity (scope_not_found vs. scope_access_denied)

**Impact:** Cannot distinguish "org doesn't exist" from "no access" on single-org lookup.
**Workaround:** Enumerate approach avoids the issue. Classify absent canonical ID as `scope_access_denied` with explanatory detail.
**Status:** VERIFIED — documented GitHub behavior.

### 3. Supabase: No org-by-ID endpoint

**Impact:** Same as GitHub limitation #1.
**Workaround:** Enumerate via `GET /v1/organizations`, filter by ID. The slug-based endpoint (`GET /v1/organizations/{slug}`) exists but violates the spec's ID-first requirement.
**Status:** VERIFIED — confirmed from API docs.

### 4. Supabase: Permission check requires two calls + member enumeration

**Impact:** No "check my permissions" endpoint. Must call `GET /v1/profile` for actor identity, then `GET /v2/organizations/{slug}/members` and filter.
**Status:** VERIFIED — confirmed from API docs.

### 5. Supabase: Error response body shapes unverified

**Impact:** 401/403 response bodies may not follow a consistent JSON structure. Diagnostic classification may need to rely on HTTP status code alone.
**Status:** UNVERIFIED — needs live testing.

### 6. Vercel: OWNER role does not enumerate explicit permissions

**Impact:** `GET /v2/teams/{teamId}` returns `membership.role: "OWNER"` but `membership.teamPermissions` and `membership.teamRoles` are absent from the response. OWNER has all permissions implicitly. Individual permission fields (CreateProject, EnvVariableManager, etc.) are only populated for non-OWNER roles.
**Status:** VERIFIED — confirmed by live bootstrap (2026-08-11). Project deletion permission is not explicitly enumerable for any role. Teardown permission check must either accept OWNER as sufficient or test with a non-OWNER account.

### 7. Supabase: Required role for project creation unverified

**Impact:** We don't know whether `developer` role is sufficient for `supabase projects create`, or if `owner` is required. Bootstrap confirmed `owner` role works.
**Status:** PARTIALLY VERIFIED — `owner` confirmed working. Minimum role (developer vs. owner) remains unverified. Would require a test account with `developer` role.

### 8. Vercel: Actor ID field is `.user.id`, not `.user.uid`

**Impact:** `GET /v2/user` returns `uid: null` and `id: "<actual-id>"`. Training data and older docs reference `.uid`; live API returns the actor ID in `.id`.
**Status:** VERIFIED — confirmed by live bootstrap (2026-08-11). Bootstrap script corrected.

---

## Items requiring decision before implementation

1. **GitHub org-by-ID:** Accept enumerate-and-filter, or verify undocumented endpoint first?
2. **Supabase org-by-ID:** Accept enumerate-and-filter (recommended)?
3. **GitHub 404 ambiguity:** Accept combined `scope_access_denied` classification with detail text?
4. **Resolver file location:** All in `preflight-lib.sh` (spec says so), or split into a sourced `resolvers.sh` for cleaner static checks?
5. **Supabase permission proxy:** What role name constitutes `permission_insufficient` — is `developer` sufficient, or must it be `owner`?
6. **Vercel deletion permission:** Accept OWNER as sufficient, or require testing with a non-OWNER account to discover explicit permission name?

---

## WP0 Bootstrap Evidence (2026-08-11)

### Canonical IDs Resolved

| Provider | Canonical ID | Requested | Resolved name/slug |
|---|---|---|---|
| GitHub | `254572218` | `friends-innovation-lab` | login: `friends-innovation-lab`, name: `Friends Innovation Lab` |
| Vercel | `team_fsGOVzcYUm5XwV8xJ7VeZbkv` | `friends-innovation-lab` | slug: `friends-innovation-lab`, name: `Friends Innovation Lab` |
| Supabase | `esiwooovlhcuifbbkodk` | `esiwooovlhcuifbbkodk` | slug: `esiwooovlhcuifbbkodk`, name: `Friends Innovation Lab` |

### Actors Observed

| Provider | Actor | Actor ID |
|---|---|---|
| GitHub | `CityFriends` | `81870102` |
| Vercel | `cityfriends-lab` | `0qekofTAxYcm2RaMk3wH170a` |
| Supabase | `lab-friends` | `33f998cd-5569-4912-a0ce-32f0efd55aa6` (gotrue_id) |

### Known-Working Roles and Permissions

| Provider | Role | Permission fields from API | Workflows succeed? |
|---|---|---|---|
| GitHub | `admin` (state: `active`) | None (GitHub membership API has no per-capability fields) | Yes — repo create/delete, branch protection, secrets |
| Vercel | `OWNER` | `teamPermissions`: absent from response; `teamRoles`: absent from response | Yes — project/env/domain/deploy CRUD |
| Supabase | `owner` | None (Supabase member API has no per-capability fields) | Yes — project create/delete |

### Permission Findings

**a. Known-working current role:**
- GitHub: `admin` role, `active` state — repo create/delete, branch protection, secrets management all succeed with this role.
- Vercel: `OWNER` role — project/env/domain/deploy CRUD all succeed with this role.
- Supabase: `owner` role — project creation succeeds with this role.

**b. API-observed permission fields:**
- Vercel: `GET /v2/teams/{teamId}` returned `membership.role: "OWNER"`. The `membership.teamPermissions` field was **absent from the response** (not empty array — absent). The `membership.teamRoles` field was also **absent from the response**. This is a provider behavior: the Vercel API does not populate `teamPermissions` or `teamRoles` for OWNER accounts. The documented enum values (`CreateProject`, `EnvVariableManager`, `EnvironmentManager`, `FullProductionDeployment`, `IntegrationManager`, `OrgAdmin`, etc.) apply to non-OWNER roles only. Whether OWNER implies all permissions is not established by this API response — it is a reasonable inference but not API evidence.
- GitHub: `GET /user/memberships/orgs/{org}` returned `role: "admin"`, `state: "active"`. No per-capability permission fields exist in the GitHub org membership API.
- Supabase: `GET /v2/organizations/{slug}/members` returned `roles: [{ name: "owner" }]` for the authenticated actor. No per-capability permission fields exist in the Supabase member API.

**c. Minimum role still unverified (carried forward to resolver WPs):**
- GitHub: Whether `member` role (vs. `admin`) can create repos depends on org settings. UNVERIFIED.
- Vercel: What `teamPermissions` are returned for non-OWNER roles, and which are required for project creation, deletion, env management, and domain management. UNVERIFIED — requires testing with a non-OWNER account.
- Supabase: Whether `developer` role (vs. `owner`) can create projects. UNVERIFIED.

### Requests Made (read-only only)

All bootstrap requests were GET:
- `GET /user` (GitHub — via `gh api`)
- `GET /orgs/friends-innovation-lab` (GitHub — via `gh api`)
- `GET /user/memberships/orgs/friends-innovation-lab` (GitHub — via `gh api`)
- `GET /v2/user` (Vercel)
- `GET /v2/teams?limit=100` (Vercel)
- `GET /v2/teams/team_fsGOVzcYUm5XwV8xJ7VeZbkv` (Vercel)
- `GET /v1/profile` (Supabase)
- `GET /v1/organizations` (Supabase)
- `GET /v2/organizations/esiwooovlhcuifbbkodk/members` (Supabase)

No POST, PUT, PATCH, or DELETE requests were made. No resources were created, modified, or destroyed.

### GitHub Display-Name Mutability Observation

During the bootstrap session, the GitHub org `friends-innovation-lab` (canonical ID `254572218`) returned display name `Treehouse Innovation Lab` on the first bootstrap run, then `Friends Innovation Lab` on the second run. The display name was changed between runs via the GitHub dashboard.

This is architecturally significant:
- `scope_name` / display name is **mutable** — it can change at any time via provider dashboard
- `scope_id` (`254572218`) is the **authoritative immutable identifier** — it did not change
- Name/slug is used as an **identity validation check** (does this ID still correspond to the expected org?), not as the primary selection key

This validates the spec's design: resolvers must select by canonical ID and verify the returned name/slug, never the reverse.

### Second-Person Review

Second-person review waived by Lapedra on 2026-08-11 for this single-operator session.
