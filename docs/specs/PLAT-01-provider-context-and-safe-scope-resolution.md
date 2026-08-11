# PLAT-01 Provider Context and Safe Scope Resolution

Version: v1.0  
Status: Approved  
Depends on: None  

Change summary: Establishes canonical provider scope configuration, provider-context contracts, safe provider resolution, diagnostic classification, compatibility wrappers, rollback expectations, and test architecture. This specification changes `preflight-lib.sh` and related test/config assets only. It does not change `spinup-typed.sh`, `spinup.sh`, or `teardown.sh` behavior.

## Purpose

Create a safe, testable provider-context layer for GitHub, Vercel, and Supabase so later spinup, resume, and teardown work can operate against explicitly resolved provider scopes rather than ambient CLI state, project-name discovery, or current shell defaults.

This work is the platform safety foundation for subsequent lifecycle changes.

The design must:

- separate credential validation from scope validation
- resolve canonical provider scopes by immutable IDs
- distinguish actor identity, scope identity, access, and permission failures
- expose a common ProviderContext contract to later consumers
- prevent raw provider calls from bypassing the test seam inside resolver logic
- provide deterministic mocked-boundary tests for every diagnostic classification
- retain compatibility with current callers during transition
- avoid changing provisioning or teardown behavior in this work package

## Repository Ownership

### playbook

Owns:

- `automation/config/provider-scopes.sh`
- `automation/preflight-lib.sh`
- provider resolver logic
- provider-call seam
- diagnostic classification and remediation rendering
- unit tests and provider fixtures
- canonical-ID bootstrap utility
- healthy-path smoke-test procedure

### lab-standards

Not part of the provider safety runtime path.

PLAT-01 shall introduce no dependency on `lab-standards`.

### project-template

No changes in PLAT-01.

### spinup / teardown consumers

No behavior changes in PLAT-01.

Existing scripts may continue calling compatibility functions exposed by `preflight-lib.sh`.

## Scope

PLAT-01 includes:

1. canonical provider scope configuration
2. one-time canonical ID bootstrap utility
3. provider-call seam
4. shared diagnostic model
5. ProviderContext contract
6. GitHub provider resolver
7. Vercel provider resolver
8. Supabase provider resolver
9. compatibility wrappers for current preflight callers
10. mocked-boundary automated tests
11. healthy-path live smoke-test procedure
12. rollback requirements

PLAT-01 excludes:

- mutation migration
- state v2
- resume semantics
- teardown semantics
- legacy teardown behavior
- project-template changes
- spinup orchestration changes
- resource creation or destruction changes

## Sequencing Decision: WP0 Bootstrap

The canonical-ID bootstrap utility ships as the first work package inside PLAT-01.

It does not precede PLAT-01 as a separate initiative.

Reason:

- the bootstrap utility is part of establishing the authoritative provider-context contract
- resolvers cannot be accepted until canonical IDs exist
- keeping bootstrap and resolver work under one spec prevents a configuration artifact from being created without the validation rules that consume it

Execution order:

```text
PLAT-01/WP0  Bootstrap canonical provider IDs
PLAT-01/WP1  Shared context, diagnostics, provider-call seam
PLAT-01/WP2  Vercel resolver
PLAT-01/WP3  Supabase resolver
PLAT-01/WP4  GitHub resolver
PLAT-01/WP5  Compatibility wrappers + smoke procedure + release gate
```

WP0 blocks WP2, WP3, and WP4.

WP1 may be implemented in parallel with WP0 after the configuration contract is agreed, but resolver acceptance is blocked until WP0 values are reviewed and committed.

## Canonical Provider Configuration

Authoritative file:

```text
playbook/automation/config/provider-scopes.sh
```

This file shall contain only non-secret provider coordinates.

Required contract:

```bash
LAB_GITHUB_ORG="friends-innovation-lab"
LAB_GITHUB_ORG_ID="<canonical-github-org-id>"

LAB_VERCEL_TEAM_SLUG="<expected-vercel-team-slug>"
LAB_VERCEL_TEAM_ID="<canonical-vercel-team-id>"

LAB_SUPABASE_ORG_ID="<canonical-supabase-org-id>"
LAB_SUPABASE_ORG_NAME="<expected-supabase-org-name>"
```

If a provider exposes a stable slug that is preferable to a display name, the approved slug may be stored instead of the name.

Rules:

- canonical IDs are immutable coordinates for normal runtime resolution
- resolvers shall not derive canonical IDs from names/slugs during normal execution
- names/slugs are retained as human-readable identity checks
- no credentials or secrets may appear in this file
- provider config is owned by `playbook`
- provider safety shall not depend on another repository being present

## PLAT-01/WP0 Canonical ID Bootstrap

### Purpose

Resolve the currently prescribed provider names/slugs into immutable provider IDs exactly once and produce reviewed configuration values.

Bootstrap is an administrative operation, not normal preflight behavior.

### Utility

Create:

```text
playbook/automation/bootstrap-provider-scopes.sh
```

The utility shall:

1. validate the operator credential for each provider
2. resolve the explicitly prescribed provider name or slug
3. print the canonical ID
4. print the resolved human-readable name or slug
5. print the authenticated actor
6. require explicit human confirmation before emitting configuration output
7. perform no provisioning mutations
8. perform no automatic commit or configuration-file write

Conceptual functions:

```bash
bootstrap_github_scope <org_slug>
bootstrap_vercel_scope <team_slug>
bootstrap_supabase_scope <org_name_or_slug>
```

Required output:

```text
provider
requested name/slug
resolved canonical ID
resolved name/slug
authenticated actor
```

### Review Requirement

Each ID/name pair must be reviewed by a second person before merge into:

```text
automation/config/provider-scopes.sh
```

### Acceptance Criteria

- each prescribed provider scope resolves uniquely
- each resolved ID is reviewed before merge
- bootstrap performs no resource mutations
- bootstrap does not become a runtime dependency
- normal resolvers never replace missing IDs by deriving them from slugs
- unresolved or ambiguous scope identity blocks resolver rollout

## ProviderContext Contract

Each provider resolver shall populate a provider-specific context using a common conceptual contract.

Required fields:

```text
provider
actor_id
actor_name
scope_id
scope_name
scope_slug if provider supports one
permission_level or permission_summary
resolution_source
```

Conceptual shell variables:

```bash
<PROVIDER>_CTX_PROVIDER
<PROVIDER>_CTX_ACTOR_ID
<PROVIDER>_CTX_ACTOR_NAME
<PROVIDER>_CTX_SCOPE_ID
<PROVIDER>_CTX_SCOPE_NAME
<PROVIDER>_CTX_SCOPE_SLUG
<PROVIDER>_CTX_PERMISSION
<PROVIDER>_CTX_RESOLUTION_SOURCE
```

Examples:

```bash
VERCEL_CTX_SCOPE_ID
SUPABASE_CTX_SCOPE_ID
GITHUB_CTX_SCOPE_NAME
```

Rules:

- context is populated only after credential, identity, scope, access, and permission validation succeed
- partial context must not be treated as valid
- later consumers shall receive context values rather than re-reading central scope config
- PLAT-01 does not yet migrate consumers to these context variables

## Shared Diagnostic Model

Introduce the shared error state:

```bash
PREFLIGHT_ERROR_CODE=""
PREFLIGHT_ERROR_PROVIDER=""
PREFLIGHT_ERROR_DETAIL=""
```

Required functions:

```bash
clear_preflight_error
set_preflight_error <code> <provider> [detail]
print_preflight_error
```

Each failure shall set exactly one primary diagnostic code.

Required diagnostic codes:

```text
credential_missing
credential_invalid
actor_unresolved
scope_config_missing
scope_not_found
scope_identity_mismatch
scope_access_denied
permission_insufficient
provider_unavailable
response_invalid
state_missing
state_invalid
resource_not_found
resource_scope_mismatch
```

PLAT-01 resolver code directly exercises the provider-related codes.

State/resource codes are defined now so later lifecycle work uses one stable diagnostic vocabulary.

## Diagnostic Remediation Contract

Each diagnostic code shall have exactly one primary remediation renderer.

The renderer may include provider-specific detail, but the primary action must remain consistent.

### credential_missing

Primary remediation:

```text
Set or configure the required provider credential, then rerun preflight.
```

### credential_invalid

Primary remediation:

```text
Replace or refresh the provider credential, verify it with the provider, then rerun preflight.
```

### actor_unresolved

Primary remediation:

```text
Verify the credential resolves a usable authenticated actor identity; if not, reauthenticate or replace the credential.
```

### scope_config_missing

Primary remediation:

```text
Restore the required canonical provider scope configuration in automation/config/provider-scopes.sh.
```

### scope_not_found

Primary remediation:

```text
Verify the configured canonical scope still exists. Do not substitute a similarly named scope. Update canonical configuration only through the approved bootstrap/review process.
```

### scope_identity_mismatch

Primary remediation:

```text
Stop and verify the configured canonical ID/name pair. Resolve the discrepancy before any provider mutation.
```

### scope_access_denied

Primary remediation:

```text
Grant the authenticated actor access to the prescribed provider scope or use an authorized credential.
```

### permission_insufficient

Primary remediation:

```text
Grant the actor the provider permission required for the intended workflow or use a credential with the required permission.
```

### provider_unavailable

Primary remediation:

```text
Retry after confirming provider availability and network access. Do not change credentials or scope configuration solely to bypass an availability failure.
```

### response_invalid

Primary remediation:

```text
Stop and inspect the provider response/API compatibility. Do not infer success from malformed or structurally unexpected data.
```

### state_missing

Primary remediation:

```text
Follow the lifecycle policy for projects without persisted state. Do not fabricate historical provider context.
```

### state_invalid

Primary remediation:

```text
Stop and repair or explicitly migrate the persisted state using the approved lifecycle procedure. Do not treat malformed state as authoritative.
```

### resource_not_found

Primary remediation:

```text
Confirm the resource name or identifier inside the already validated provider scope. Do not broaden discovery to other scopes.
```

### resource_scope_mismatch

Primary remediation:

```text
Stop. The addressed resource belongs to a different provider scope. Do not modify or delete it through this workflow.
```

## Provider-Call Seam

All provider interaction inside resolver logic shall occur through overridable shell functions.

Resolver functions must not invoke raw provider commands directly.

Examples:

```bash
_provider_github_api() {
    gh api "$@"
}

_provider_vercel_api() {
    curl ...
}

_provider_supabase_api() {
    curl ...
}
```

Additional wrappers may exist for:

```text
vercel CLI
supabase CLI
provider-specific HTTP methods
```

Rules:

- resolver functions call only wrapper functions
- wrapper functions are the sole boundary for network/provider invocation in resolver logic
- tests may replace wrapper functions after sourcing `preflight-lib.sh`
- raw `curl`, `gh`, `vercel`, or `supabase` calls inside resolver functions are prohibited
- compatibility wrappers may call new resolver functions, but must not bypass the provider-call seam

Example test override:

```bash
_provider_vercel_api() {
    cat "$FIXTURE_DIR/vercel/team-access-denied.json"
    return 0
}
```

Transport failure example:

```bash
_provider_vercel_api() {
    return 1
}
```

## Resolver Interfaces

Required provider-neutral orchestration:

```bash
resolve_provider_context <provider>
validate_provider_context <provider>
clear_provider_context <provider>
```

Required provider-specific functions:

### Vercel

```bash
validate_vercel_credential
resolve_vercel_context
validate_vercel_permission
```

### Supabase

```bash
validate_supabase_credential
resolve_supabase_context
validate_supabase_permission
```

### GitHub

```bash
validate_github_credential
resolve_github_context
validate_github_permission
```

## Resolver Ordering

Every resolver shall enforce this order structurally:

```text
1. credential present
2. credential valid
3. actor resolved
4. canonical scope config present
5. canonical scope retrieved by ID
6. returned scope identity verified against expected name/slug
7. actor access to scope verified
8. required permission verified
9. ProviderContext populated
```

No scope lookup by human-readable name may replace step 5 during normal resolution.

No resource discovery occurs in PLAT-01.

## Vercel Resolver Requirements

`validate_vercel_credential` shall establish authenticated actor identity.

`resolve_vercel_context` shall:

1. require `LAB_VERCEL_TEAM_ID`
2. require expected Vercel team slug/name
3. retrieve exactly `LAB_VERCEL_TEAM_ID`
4. verify returned canonical ID
5. verify returned slug/name
6. verify actor access
7. verify permission needed for later project/environment/domain workflows
8. populate `VERCEL_CTX_*`

Failures shall distinguish:

```text
credential_invalid
actor_unresolved
scope_config_missing
scope_not_found
scope_identity_mismatch
scope_access_denied
permission_insufficient
provider_unavailable
response_invalid
```

## Supabase Resolver Requirements

`validate_supabase_credential` shall establish credential validity and actor identity where exposed by the API.

`resolve_supabase_context` shall:

1. require `LAB_SUPABASE_ORG_ID`
2. require approved organization name/slug
3. retrieve or enumerate provider organizations through the provider seam
4. identify exactly the configured canonical organization ID
5. verify the returned name/slug
6. verify actor access
7. verify permission needed for later project workflows
8. populate `SUPABASE_CTX_*`

Name-only organization selection is prohibited.

If actor identity cannot be directly obtained from the API, the implementation plan shall document the provider-specific actor representation and how `actor_unresolved` is classified.

## GitHub Resolver Requirements

`validate_github_credential` shall establish the authenticated actor from the GitHub API.

`resolve_github_context` shall:

1. require `LAB_GITHUB_ORG_ID`
2. require `LAB_GITHUB_ORG`
3. retrieve the configured organization identity through the provider seam
4. verify canonical ID
5. verify organization slug/name
6. verify authenticated actor access
7. verify permission required for later repo workflows
8. populate `GITHUB_CTX_*`

Successful `gh api user` alone must never satisfy GitHub provider preflight.

## Compatibility Wrappers

### Purpose

Current consumers already call functions such as:

```bash
validate_vercel_token
validate_github_api
validate_supabase_token
print_vercel_token_help
```

PLAT-01 must not break current spinup or teardown behavior.

### Transition Rule

Existing public function names used by current scripts shall remain available as compatibility wrappers.

During PLAT-01:

```text
existing consumer
    -> compatibility wrapper
        -> new credential/resolver implementation where behavior is equivalent
```

Compatibility wrappers must:

- preserve existing return-code semantics
- preserve existing result variables expected by current scripts
- preserve existing user-facing behavior unless an incorrect diagnostic would be unsafe
- not require current consumers to adopt ProviderContext yet
- not cause spinup or teardown to fail on new scope checks unless the existing caller explicitly invokes the new resolver interface

This is critical.

PLAT-01 introduces the new safe interface without silently changing lifecycle behavior.

### Example

Conceptually:

```bash
validate_vercel_token() {
    # compatibility contract for current callers
    # delegates credential validation only
    validate_vercel_credential
    # map new result to legacy variables
}
```

It shall not call full `resolve_vercel_context` if doing so would introduce a new blocking scope requirement into current spinup or teardown before those consumers are migrated.

### Removal Criteria

Compatibility wrappers are removed only after:

1. `spinup-typed.sh` has migrated to ProviderContext
2. retained `spinup.sh` consumers have migrated or been retired
3. `teardown.sh` has migrated to ProviderContext
4. no production script references legacy function names
5. static search confirms no remaining caller
6. replacement behavior has passed unit and healthy-path smoke tests

Removal belongs to a later lifecycle migration work package, not PLAT-01.

## Rollback Strategy

Rollback shall be defined per work package.

The governing principle is:

> A defect in a new resolver must not leave production spinup or teardown dependent on that resolver before its consumer migration is explicitly accepted.

### WP0 Rollback

WP0 changes only:

```text
bootstrap utility
provider-scopes.sh
```

Rollback:

- revert the config/bootstrap commit
- current spinup/teardown behavior remains unchanged
- no generated project state depends on PLAT-01 canonical IDs yet

If a canonical ID is discovered to be wrong:

- do not substitute another ID ad hoc
- rerun bootstrap
- re-review the ID/name pair
- commit the corrected config

### WP1 Rollback

WP1 adds:

```text
shared diagnostic model
provider-call seam
ProviderContext scaffolding
tests
```

Rollback:

- revert WP1 commit(s)
- legacy validation functions remain available from the pre-WP1 version
- no consumer behavior has changed

If compatibility wrappers are part of the same merge, revert the wrapper layer with WP1.

### WP2 / WP3 / WP4 Resolver Rollback

Each provider resolver shall land independently where practical.

Before consumer migration:

```text
resolver defect
    -> revert that provider resolver
    -> current production consumers remain on compatibility behavior
```

No current spinup or teardown script may require the new full resolver merely because the resolver exists.

This is the main compatibility guarantee for PLAT-01.

### WP5 Compatibility/Release Rollback

If wrapper mapping introduces a regression:

- revert the wrapper change
- restore previous public validation implementation
- keep new resolver code unused until corrected

No state migration is required because PLAT-01 writes no execution state and changes no project resource ownership.

### Rollback Validation

Each work package PR shall document:

```text
files changed
public functions added/changed
legacy functions affected
rollback commit or revert boundary
proof that current spinup/teardown behavior remains available
```

## Test Architecture

### Mocked Boundary Tests

All diagnostic classification tests shall run without network access.

Tests shall replace provider-call wrapper functions.

Fixtures represent provider responses, not resolver output.

Recommended layout:

```text
automation/tests/
  preflight-lib.test.sh
  fixtures/
    vercel/
      actor-valid.json
      invalid-token.json
      team-valid.json
      team-not-found.json
      team-access-denied.json
      team-wrong-slug.json

    github/
      actor-valid.json
      org-valid.json
      org-not-found.json
      org-access-denied.json
      permission-insufficient.json

    supabase/
      organizations-valid.json
      organization-missing.json
      organization-access-denied.json
      organization-wrong-name.json
```

Malformed responses shall use intentionally malformed or structurally invalid fixtures.

Transport failures shall be represented by provider wrappers returning non-zero.

## Required Diagnostic Test Matrix

All 14 codes shall have automated classification coverage.

### credential_missing

Test using absent environment credential.

### credential_invalid

Test using mocked provider rejection.

### actor_unresolved

Test successful auth response without usable actor identity.

### scope_config_missing

Test with missing canonical config.

### scope_not_found

Test canonical ID absent from provider response or provider 404 equivalent.

### scope_identity_mismatch

Test canonical ID resolving to unexpected name/slug.

### scope_access_denied

Test valid credential with inaccessible prescribed scope.

### permission_insufficient

Test accessible scope with insufficient workflow permission.

### provider_unavailable

Test mocked transport error or provider 5xx.

### response_invalid

Test malformed/unexpected response.

### state_missing

Test filesystem absence through diagnostic helper tests.

### state_invalid

Test malformed/version-invalid state fixture through diagnostic helper tests.

### resource_not_found

Test diagnostic helper classification with validated scope and absent target resource.

### resource_scope_mismatch

Test diagnostic helper classification for directly addressed resource owned by another scope.

The last four codes are vocabulary/renderer tests in PLAT-01. Their lifecycle-specific orchestration is implemented later.

## Test Isolation Requirements

- unit tests require no production credentials
- tests must not revoke real tokens
- tests must not alter real organization membership
- tests must not modify real provider scope IDs
- tests must not weaken permissions
- tests must not depend on provider availability
- provider wrappers must be replaceable after sourcing `preflight-lib.sh`

## Healthy-Path Live Smoke Tests

Live-provider verification is separate from automated unit testing.

It uses normal authorized staff credentials.

For each provider, verify only:

```text
credential accepted
actor identified
canonical scope resolves by configured ID
resolved identity matches expected name/slug
actor has scope access
required permission validation succeeds
ProviderContext is populated
```

Live smoke tests shall not intentionally create failure states.

They shall not:

- revoke credentials
- remove users from organizations
- alter team/org IDs
- create scope mismatches
- lower permissions
- create or destroy application resources

The smoke procedure shall be documented in:

```text
automation/tests/SMOKE-TESTS.md
```

## Static Safety Checks

Automated/static inspection shall verify:

- resolver functions do not invoke raw `curl`
- resolver functions do not invoke raw `gh`
- resolver functions do not invoke raw `vercel`
- resolver functions do not invoke raw `supabase`
- provider config contains no obvious credential values
- no `lab-standards` path is sourced by provider resolver code
- canonical IDs are read from `automation/config/provider-scopes.sh`
- legacy public validation functions remain defined during PLAT-01

## Work Package Acceptance Criteria

### WP0

- canonical IDs resolve uniquely
- second-person review completed
- IDs committed to `provider-scopes.sh`
- bootstrap performs no mutations
- no runtime resolver derives IDs from names

### WP1

- ProviderContext contract implemented
- all 14 diagnostic codes defined
- each code has exactly one primary remediation renderer
- provider-call seam implemented
- resolver tests can replace provider wrappers
- no network required for automated tests

### WP2 Vercel

- credential, actor, scope identity, access, and permission are independently classified
- canonical team ID is authoritative
- slug/name mismatch fails
- context populated only after full success
- tests cover all Vercel-relevant diagnostic classes

### WP3 Supabase

- canonical organization ID is authoritative
- name-only selection is prohibited
- access and permission failures are distinguishable
- context populated only after full success
- tests cover all Supabase-relevant diagnostic classes

### WP4 GitHub

- user authentication alone cannot satisfy provider resolution
- organization ID and slug/name are both validated
- org access and permission failures are distinguishable
- context populated only after full success
- tests cover all GitHub-relevant diagnostic classes

### WP5 Compatibility and Release

- current spinup/teardown scripts remain operational without adopting ProviderContext
- compatibility wrappers preserve legacy contracts
- live healthy-path smoke procedure documented
- rollback path demonstrated for each provider resolver
- static safety checks pass

## Release Gate

PLAT-01 is complete when:

```text
[ ] canonical provider IDs reviewed and committed
[ ] provider-call seam exists
[ ] ProviderContext contract exists
[ ] all 14 diagnostic codes exist
[ ] each diagnostic has one primary remediation renderer
[ ] all 14 diagnostic classifications have automated tests
[ ] Vercel resolver tests pass
[ ] Supabase resolver tests pass
[ ] GitHub resolver tests pass
[ ] tests run without network access
[ ] healthy-path Vercel smoke passes
[ ] healthy-path Supabase smoke passes
[ ] healthy-path GitHub smoke passes
[ ] legacy validation functions remain available
[ ] current spinup behavior has not changed
[ ] current teardown behavior has not changed
[ ] rollback procedure is documented for each WP
[ ] provider safety path has no lab-standards dependency
```

## Implementation Plan Questions

Before implementation begins, the Claude Code implementation plan must answer:

1. Which existing public functions in `preflight-lib.sh` are called by each current consumer?
2. Which of those functions will remain compatibility wrappers?
3. How will each provider expose a stable actor ID and display name?
4. What exact provider API call proves canonical scope identity by ID?
5. What exact API or role check proves required workflow permission?
6. How will provider 401/403/404/5xx responses be distinguished where the API response shape overlaps?
7. How will raw provider invocation be statically prevented or detected inside resolvers?
8. How will `provider-scopes.sh` be sourced safely from current script locations?
9. What is the rollback boundary for each WP?
10. What evidence proves current spinup and teardown behavior did not change?

Any provider limitation that prevents one of these contracts from being implemented exactly must be surfaced before code changes begin.

## Architecture Review Checkpoint

Before PLAT-01 is accepted, provide:

- final `provider-scopes.sh`
- bootstrap output and review evidence
- ProviderContext variable contract
- provider-call seam implementation
- diagnostic code/renderer mapping
- Vercel resolver contract
- Supabase resolver contract
- GitHub resolver contract
- compatibility-wrapper map
- full mocked test results
- healthy-path smoke-test results
- static safety-check results
- rollback evidence for each WP
- known deviations
- list of decisions that constrain the later spinup/teardown migration

The architecture review will focus on whether PLAT-01 creates a safe provider-resolution foundation without introducing a hidden behavioral change into current lab lifecycle operations.

## Out of Scope

Do not implement in PLAT-01:

- changes to `spinup-typed.sh` orchestration
- changes to `spinup.sh` orchestration
- changes to `teardown.sh` orchestration
- state v2
- `.spinup-state` changes
- strict resume
- legacy teardown migration
- scoped mutation migration
- generated-project template changes
- lab-standards runtime integration
- resource creation/deletion changes

## Implementation Evidence

- Commit(s):
- Test results:
- Smoke-test results:
- Static safety checks:
- Rollback verification:
- ADRs:
- Known deviations:
