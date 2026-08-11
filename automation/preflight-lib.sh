#!/usr/bin/env bash
# preflight-lib.sh — Shared credential validation for spinup and teardown scripts
#
# Source this file; do not execute directly.
# Twin consumers: spinup-typed.sh, spinup.sh, teardown.sh
#
# Each function returns 0 on success, 1 on failure, and sets result variables.
# Requires: curl, jq (or gh for GitHub validation).

# ── Vercel token validation ──────────────────────────────────────────────────

# Validate VERCEL_TOKEN against the Vercel API.
#   Sets VERCEL_VALIDATE_USER on success.
#   Sets VERCEL_VALIDATE_ERROR on failure ("not_set" | "invalid_token" | "api_error").
validate_vercel_token() {
    VERCEL_VALIDATE_USER=""
    VERCEL_VALIDATE_ERROR=""

    if [[ -z "${VERCEL_TOKEN:-}" ]]; then
        VERCEL_VALIDATE_ERROR="not_set"
        return 1
    fi

    local response
    response=$(curl -s -H "Authorization: Bearer $VERCEL_TOKEN" \
        https://api.vercel.com/v2/user 2>/dev/null) || {
        VERCEL_VALIDATE_ERROR="api_error"
        return 1
    }

    local username
    username=$(echo "$response" | jq -r '.username // empty' 2>/dev/null)
    if [[ -n "$username" ]]; then
        VERCEL_VALIDATE_USER="$username"
        return 0
    fi

    local invalid
    invalid=$(echo "$response" | jq -r '.invalidToken // empty' 2>/dev/null)
    if [[ "$invalid" == "true" ]]; then
        VERCEL_VALIDATE_ERROR="invalid_token"
    else
        VERCEL_VALIDATE_ERROR="api_error"
    fi
    return 1
}

# Print standard error guidance for a failed VERCEL_TOKEN.
# Call after validate_vercel_token returns 1.
print_vercel_token_help() {
    local error="${VERCEL_VALIDATE_ERROR:-unknown}"

    if [[ "$error" == "not_set" ]]; then
        echo "    VERCEL_TOKEN is not set."
        echo ""
        echo "    Generate your own token:"
        echo "      1. Go to vercel.com → Account Settings → Tokens"
        echo "      2. Scope = Friends Innovation Lab"
        echo "      3. Add to ~/.zshrc: export VERCEL_TOKEN=<your-token>"
        echo "    See first-time-setup.md Step 12 for full instructions."
    else
        echo "    VERCEL_TOKEN is set but failed validation — the token is"
        echo "    expired, revoked, or scoped to the wrong team."
        echo ""
        echo "    Regenerate your token:"
        echo "      1. Go to vercel.com → Account Settings → Tokens"
        echo "      2. Delete the old token and create a new one"
        echo "      3. Scope = Friends Innovation Lab"
        echo "      4. Update ~/.zshrc with the new value"
        echo ""
        echo "    A stale VERCEL_TOKEN overrides vercel login — after updating"
        echo "    ~/.zshrc, fully quit Terminal (Cmd+Q); source and exec zsh do"
        echo "    not clear the old value. Check for duplicates:"
        echo "      grep -n VERCEL_TOKEN ~/.zshrc"
        echo "    should return exactly one line."
    fi
}

# ── GitHub validation ────────────────────────────────────────────────────────

# Validate GitHub auth with a real API call (gh api user).
#   Sets GITHUB_VALIDATE_USER on success (the login name).
validate_github_api() {
    GITHUB_VALIDATE_USER=""

    local response
    response=$(gh api user 2>/dev/null) || return 1

    local login
    login=$(echo "$response" | jq -r '.login // empty' 2>/dev/null)
    if [[ -n "$login" ]]; then
        GITHUB_VALIDATE_USER="$login"
        return 0
    fi
    return 1
}

# ── Supabase token validation ────────────────────────────────────────────────

# Validate SUPABASE_ACCESS_TOKEN with a real API call.
#   Sets SUPABASE_VALIDATE_ERROR on failure ("not_set" | "invalid_token" | "api_error").
validate_supabase_token() {
    SUPABASE_VALIDATE_ERROR=""

    if [[ -z "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
        SUPABASE_VALIDATE_ERROR="not_set"
        return 1
    fi

    local response
    response=$(curl -s -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" \
        https://api.supabase.com/v1/organizations 2>/dev/null) || {
        SUPABASE_VALIDATE_ERROR="api_error"
        return 1
    }

    if echo "$response" | jq -e 'type == "array"' &>/dev/null; then
        return 0
    fi

    SUPABASE_VALIDATE_ERROR="invalid_token"
    return 1
}

# ════════════════════════════════════════════════════════════════════════════
# PLAT-01 Provider Context Layer
#
# Everything below is new infrastructure added by PLAT-01/WP1.
# The legacy public functions above are NOT modified.
# ════════════════════════════════════════════════════════════════════════════

# ── Canonical provider configuration ───────────────────────────────────────
# Source provider-scopes.sh if present. Missing config is non-fatal here;
# legacy functions do not depend on it. New resolver functions classify
# missing config as scope_config_missing.

_PREFLIGHT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_PROVIDER_SCOPES="${_PREFLIGHT_DIR}/config/provider-scopes.sh"
if [[ -f "$_PROVIDER_SCOPES" ]]; then
    source "$_PROVIDER_SCOPES"
fi

# ── Provider-call seam ─────────────────────────────────────────────────────
# All new resolver logic calls providers exclusively through these wrappers.
# Tests replace them after sourcing this file. Legacy functions above are
# exempt — they predate the seam and are unchanged in PLAT-01.

# ── GitHub status-aware provider seam ──────────────────────────────────────
# Calls gh api --include to capture HTTP status, headers, and body.
# Normalizes the result into shell variables for resolver consumption.
# Resolver functions read normalized variables, never re-parse raw output.

_GITHUB_API_STATUS=""
_GITHUB_API_BODY=""
_GITHUB_API_HEADERS=""
_GITHUB_API_EXIT=""
_GITHUB_API_LINK=""
_GITHUB_API_RATELIMIT_REMAINING=""
_GITHUB_API_RATELIMIT_RESET=""
_GITHUB_API_RETRY_AFTER=""

_provider_github_api() {
    # Clear all prior state
    _GITHUB_API_STATUS=""
    _GITHUB_API_BODY=""
    _GITHUB_API_HEADERS=""
    _GITHUB_API_EXIT=""
    _GITHUB_API_LINK=""
    _GITHUB_API_RATELIMIT_REMAINING=""
    _GITHUB_API_RATELIMIT_RESET=""
    _GITHUB_API_RETRY_AFTER=""

    local raw_stdout raw_stderr
    raw_stderr=$(mktemp 2>/dev/null || echo "/tmp/_gh_api_err_$$")
    raw_stdout=$(gh api --include "$@" 2>"$raw_stderr")
    _GITHUB_API_EXIT=$?
    rm -f "$raw_stderr"

    # Parse status line: HTTP/<version> <code> <reason>
    local first_line
    first_line=$(echo "$raw_stdout" | head -1)
    _GITHUB_API_STATUS=$(echo "$first_line" | sed -n 's|^HTTP/[^ ]* \([0-9][0-9]*\).*|\1|p')

    if [[ -z "$_GITHUB_API_STATUS" ]]; then
        # No HTTP status parseable — transport/CLI failure
        return 1
    fi

    # Split headers and body on blank line
    # Headers: everything between status line and first blank line
    # Body: everything after the first blank line
    local in_headers=true
    local headers_block=""
    local body_block=""

    while IFS= read -r line; do
        if $in_headers; then
            if [[ -z "$line" || "$line" == $'\r' ]]; then
                in_headers=false
            else
                headers_block="${headers_block}${line}
"
            fi
        else
            body_block="${body_block}${line}
"
        fi
    done <<< "$(echo "$raw_stdout" | tail -n +2)"

    _GITHUB_API_HEADERS="$headers_block"
    # Trim trailing newline from body
    _GITHUB_API_BODY="${body_block%
}"

    # Extract normalized header fields (case-insensitive grep)
    _GITHUB_API_LINK=$(echo "$_GITHUB_API_HEADERS" | grep -i '^Link:' | sed 's/^[Ll]ink: *//' | head -1)
    _GITHUB_API_RATELIMIT_REMAINING=$(echo "$_GITHUB_API_HEADERS" | grep -i '^X-RateLimit-Remaining:' | sed 's/^[^:]*: *//' | tr -d '[:space:]' | head -1)
    _GITHUB_API_RATELIMIT_RESET=$(echo "$_GITHUB_API_HEADERS" | grep -i '^X-RateLimit-Reset:' | sed 's/^[^:]*: *//' | tr -d '[:space:]' | head -1)
    _GITHUB_API_RETRY_AFTER=$(echo "$_GITHUB_API_HEADERS" | grep -i '^Retry-After:' | sed 's/^[^:]*: *//' | tr -d '[:space:]' | head -1)

    return 0
}

# GitHub auth-status seam — overridable for tests
_provider_github_auth_status() {
    gh auth status --active --hostname github.com >/dev/null 2>&1
    return $?
}

_provider_vercel_api() {
    local method="$1"
    local path="$2"
    shift 2
    curl -s -w "\n%{http_code}" -X "$method" \
        "https://api.vercel.com${path}" \
        -H "Authorization: Bearer ${VERCEL_TOKEN:-}" \
        ${@+"$@"}
}

_provider_vercel_cli() {
    vercel "$@"
}

_provider_supabase_api() {
    local method="$1"
    local path="$2"
    shift 2
    curl -s -w "\n%{http_code}" -X "$method" \
        "https://api.supabase.com${path}" \
        -H "Authorization: Bearer ${SUPABASE_ACCESS_TOKEN:-}" \
        ${@+"$@"}
}

# Helper: split a curl -w "\n%{http_code}" response into body + code.
# Sets _RESP_BODY and _RESP_CODE.
_split_provider_response() {
    _RESP_CODE=$(echo "$1" | tail -1)
    _RESP_BODY=$(echo "$1" | sed '$d')
}

# ── Shared diagnostic model ───────────────────────────────────────────────

PREFLIGHT_ERROR_CODE=""
PREFLIGHT_ERROR_PROVIDER=""
PREFLIGHT_ERROR_DETAIL=""

clear_preflight_error() {
    PREFLIGHT_ERROR_CODE=""
    PREFLIGHT_ERROR_PROVIDER=""
    PREFLIGHT_ERROR_DETAIL=""
}

set_preflight_error() {
    PREFLIGHT_ERROR_CODE="$1"
    PREFLIGHT_ERROR_PROVIDER="$2"
    PREFLIGHT_ERROR_DETAIL="${3:-}"
}

print_preflight_error() {
    local code="${PREFLIGHT_ERROR_CODE}"
    local provider="${PREFLIGHT_ERROR_PROVIDER}"
    local detail="${PREFLIGHT_ERROR_DETAIL}"

    if [[ -z "$code" ]]; then
        return 0
    fi

    echo "  Diagnostic: ${code} (${provider})"
    if [[ -n "$detail" ]]; then
        echo "  Detail: ${detail}"
    fi

    case "$code" in
        credential_missing)
            echo "  Action: Set or configure the required provider credential, then rerun preflight."
            ;;
        credential_invalid)
            echo "  Action: Replace or refresh the provider credential, verify it with the provider, then rerun preflight."
            ;;
        actor_unresolved)
            echo "  Action: Verify the credential resolves a usable authenticated actor identity; if not, reauthenticate or replace the credential."
            ;;
        scope_config_missing)
            echo "  Action: Restore the required canonical provider scope configuration in automation/config/provider-scopes.sh."
            ;;
        scope_not_found)
            echo "  Action: Verify the configured canonical scope still exists. Do not substitute a similarly named scope. Update canonical configuration only through the approved bootstrap/review process."
            ;;
        scope_identity_mismatch)
            echo "  Action: Stop and verify the configured canonical ID/name pair. Resolve the discrepancy before any provider mutation."
            ;;
        scope_access_denied)
            echo "  Action: Grant the authenticated actor access to the prescribed provider scope or use an authorized credential."
            ;;
        permission_insufficient)
            echo "  Action: Grant the actor the provider permission required for the intended workflow or use a credential with the required permission."
            ;;
        provider_unavailable)
            echo "  Action: Retry after confirming provider availability and network access. Do not change credentials or scope configuration solely to bypass an availability failure."
            ;;
        response_invalid)
            echo "  Action: Stop and inspect the provider response/API compatibility. Do not infer success from malformed or structurally unexpected data."
            ;;
        state_missing)
            echo "  Action: Follow the lifecycle policy for projects without persisted state. Do not fabricate historical provider context."
            ;;
        state_invalid)
            echo "  Action: Stop and repair or explicitly migrate the persisted state using the approved lifecycle procedure. Do not treat malformed state as authoritative."
            ;;
        resource_not_found)
            echo "  Action: Confirm the resource name or identifier inside the already validated provider scope. Do not broaden discovery to other scopes."
            ;;
        resource_scope_mismatch)
            echo "  Action: Stop. The addressed resource belongs to a different provider scope. Do not modify or delete it through this workflow."
            ;;
        *)
            echo "  Action: Unknown diagnostic code '${code}'. Inspect manually."
            ;;
    esac
}

# ── ProviderContext contract ───────────────────────────────────────────────
#
# Each provider resolver populates:
#   <PROVIDER>_CTX_PROVIDER
#   <PROVIDER>_CTX_ACTOR_ID
#   <PROVIDER>_CTX_ACTOR_NAME
#   <PROVIDER>_CTX_SCOPE_ID
#   <PROVIDER>_CTX_SCOPE_NAME
#   <PROVIDER>_CTX_SCOPE_SLUG        (optional — provider-specific)
#   <PROVIDER>_CTX_PERMISSION         (optional — provider-specific)
#   <PROVIDER>_CTX_RESOLUTION_SOURCE
#
# Context is populated only after full resolver success.

# List of known providers for dispatch.
_PLAT01_PROVIDERS="GITHUB VERCEL SUPABASE"

clear_provider_context() {
    local provider
    provider=$(echo "$1" | tr '[:lower:]' '[:upper:]')

    unset "${provider}_CTX_PROVIDER"
    unset "${provider}_CTX_ACTOR_ID"
    unset "${provider}_CTX_ACTOR_NAME"
    unset "${provider}_CTX_SCOPE_ID"
    unset "${provider}_CTX_SCOPE_NAME"
    unset "${provider}_CTX_SCOPE_SLUG"
    unset "${provider}_CTX_PERMISSION"
    unset "${provider}_CTX_RESOLUTION_SOURCE"
}

validate_provider_context() {
    local provider
    provider=$(echo "$1" | tr '[:lower:]' '[:upper:]')

    # Common required fields only. SCOPE_NAME, SCOPE_SLUG, and PERMISSION
    # are optional at the common level — provider-specific resolvers may
    # enforce additional requirements.
    # SCOPE_NAME is optional because GitHub's org.name may be null even
    # when canonical scope resolution fully succeeds (WP4 live observation).
    local field val
    for field in PROVIDER ACTOR_ID ACTOR_NAME SCOPE_ID RESOLUTION_SOURCE; do
        eval "val=\${${provider}_CTX_${field}:-}"
        if [[ -z "$val" ]]; then
            return 1
        fi
    done
    return 0
}

resolve_provider_context() {
    local provider
    provider=$(echo "$1" | tr '[:lower:]' '[:upper:]')

    clear_preflight_error
    clear_provider_context "$provider"

    case "$provider" in
        VERCEL)
            resolve_vercel_context
            return $?
            ;;
        SUPABASE)
            resolve_supabase_context
            return $?
            ;;
        GITHUB)
            resolve_github_context
            return $?
            ;;
        *)
            echo "resolve_provider_context: unknown provider '${provider}'" >&2
            return 1
            ;;
    esac
}

# ── Vercel resolver (PLAT-01/WP2) ─────────────────────────────────────────
#
# API calls:
#   GET /v2/user              — credential validation + actor identity
#   GET /v2/teams/{teamId}    — canonical scope + membership + permission
#
# Documented RBAC basis: https://vercel.com/docs/rbac/access-roles
# API reference: https://vercel.com/docs/rest-api/teams/get-a-team
#
# KNOWN GAP: resolve_vercel_context validates project_create only.
# Spinup additionally requires env_manage, domain_manage, and
# deployment_create. Until WP7 wires per-capability checks into
# consumers, a passing Vercel preflight does not guarantee a spinup will
# complete. Documented, not fixed, in WP2.

# ── Normalized membership evidence ────────────────────────────────────────
# Populated by _normalize_vercel_membership. Read by validate_vercel_permission.

_VERCEL_MEMBERSHIP_ROLE=""
_VERCEL_MEMBERSHIP_PERMISSIONS=""   # comma-separated, e.g. "CreateProject,EnvVariableManager"
_VERCEL_MEMBERSHIP_ROLES=""         # comma-separated

_clear_vercel_membership() {
    _VERCEL_MEMBERSHIP_ROLE=""
    _VERCEL_MEMBERSHIP_PERMISSIONS=""
    _VERCEL_MEMBERSHIP_ROLES=""
}

_normalize_vercel_membership() {
    local membership_json="$1"
    _clear_vercel_membership
    _VERCEL_MEMBERSHIP_ROLE=$(echo "$membership_json" | jq -r '.role // empty' 2>/dev/null)
    _VERCEL_MEMBERSHIP_PERMISSIONS=$(echo "$membership_json" | jq -r \
        '[.teamPermissions[]?] | join(",")' 2>/dev/null)
    _VERCEL_MEMBERSHIP_ROLES=$(echo "$membership_json" | jq -r \
        '[.teamRoles[]?] | join(",")' 2>/dev/null)
}

_has_vercel_permission() {
    local perm="$1"
    [[ -n "$_VERCEL_MEMBERSHIP_PERMISSIONS" ]] && \
        echo ",$_VERCEL_MEMBERSHIP_PERMISSIONS," | grep -q ",$perm,"
}

# ── validate_vercel_credential ────────────────────────────────────────────
# Calls GET /v2/user via seam. On success sets _VERCEL_ACTOR_ID and
# _VERCEL_ACTOR_NAME. On failure sets diagnostic.

_VERCEL_ACTOR_ID=""
_VERCEL_ACTOR_NAME=""

validate_vercel_credential() {
    _VERCEL_ACTOR_ID=""
    _VERCEL_ACTOR_NAME=""

    # Step 1: credential present
    if [[ -z "${VERCEL_TOKEN:-}" ]]; then
        set_preflight_error "credential_missing" "vercel" \
            "VERCEL_TOKEN is not set"
        return 1
    fi

    # Step 2: credential valid + Step 3: actor resolved
    local raw_response
    raw_response=$(_provider_vercel_api GET /v2/user 2>/dev/null) || {
        set_preflight_error "provider_unavailable" "vercel" \
            "Transport failure calling GET /v2/user"
        return 1
    }

    _split_provider_response "$raw_response"

    # Check HTTP status
    case "$_RESP_CODE" in
        200)
            # Validate JSON
            if ! echo "$_RESP_BODY" | jq empty 2>/dev/null; then
                set_preflight_error "response_invalid" "vercel" \
                    "GET /v2/user returned HTTP 200 but body is not valid JSON"
                return 1
            fi

            local actor_id actor_name
            actor_id=$(echo "$_RESP_BODY" | jq -r '.user.id // empty' 2>/dev/null)
            actor_name=$(echo "$_RESP_BODY" | jq -r '.user.username // empty' 2>/dev/null)

            if [[ -z "$actor_id" ]]; then
                set_preflight_error "actor_unresolved" "vercel" \
                    "GET /v2/user returned 200 but user.id is null or absent"
                return 1
            fi

            _VERCEL_ACTOR_ID="$actor_id"
            _VERCEL_ACTOR_NAME="$actor_name"
            return 0
            ;;
        401)
            set_preflight_error "credential_invalid" "vercel" \
                "GET /v2/user returned 401 (documented: request is not authorized)"
            return 1
            ;;
        403)
            # Check for invalidToken field (observed in WP0)
            local invalid_token
            invalid_token=$(echo "$_RESP_BODY" | jq -r '.error.invalidToken // empty' 2>/dev/null)
            if [[ "$invalid_token" == "true" ]]; then
                set_preflight_error "credential_invalid" "vercel" \
                    "GET /v2/user returned 403 with invalidToken=true (observed WP0 token-rejection)"
                return 1
            fi
            # Bare 403 without invalidToken: classified as credential_invalid
            # because /v2/user resolves the authenticated actor — a 403 here
            # means the credential cannot establish actor identity.
            # ASSUMPTION: no documented non-credential 403 case for /v2/user.
            # If Vercel introduces one, this mapping must be revisited.
            set_preflight_error "credential_invalid" "vercel" \
                "GET /v2/user returned 403 without invalidToken (classified as credential failure at actor-resolution stage; invalidToken field absent — this is an architectural assumption, not documented Vercel behavior)"
            return 1
            ;;
        5[0-9][0-9])
            set_preflight_error "provider_unavailable" "vercel" \
                "GET /v2/user returned HTTP ${_RESP_CODE}"
            return 1
            ;;
        *)
            set_preflight_error "response_invalid" "vercel" \
                "GET /v2/user returned unexpected HTTP ${_RESP_CODE}"
            return 1
            ;;
    esac
}

# ── validate_vercel_permission ────────────────────────────────────────────
# Capability-specific permission validation against normalized membership.
#
# Usage: validate_vercel_permission <capability>
# Reads: _VERCEL_MEMBERSHIP_ROLE, _VERCEL_MEMBERSHIP_PERMISSIONS
#
# Supported capabilities:
#   project_create, project_delete, env_manage, domain_manage, deployment_create
#
# Returns 0 on success, 1 on failure with diagnostic set.
# For project_delete (UNVERIFIED policy): returns 1, no diagnostic code,
# stderr message. Callers distinguish unverified-policy (empty error code +
# non-zero return) from permission-denied (permission_insufficient).

validate_vercel_permission() {
    local capability="$1"
    local role="$_VERCEL_MEMBERSHIP_ROLE"

    case "$capability" in
        project_create)
            # Documented: Owner and Member include Create Project.
            # Developer requires explicit CreateProject extended permission.
            # Source: https://vercel.com/docs/rbac/access-roles (Permission groups)
            case "$role" in
                OWNER)
                    return 0 ;;
                MEMBER)
                    return 0 ;;
                DEVELOPER)
                    if [[ -z "$_VERCEL_MEMBERSHIP_PERMISSIONS" ]]; then
                        set_preflight_error "permission_insufficient" "vercel" \
                            "Developer role requires explicit CreateProject extended permission but teamPermissions was not returned by the API — cannot infer capability from absence"
                        return 1
                    fi
                    if _has_vercel_permission "CreateProject"; then
                        return 0
                    fi
                    set_preflight_error "permission_insufficient" "vercel" \
                        "Developer role lacks CreateProject extended permission (documented requirement: https://vercel.com/docs/rbac/access-roles)"
                    return 1
                    ;;
                *)
                    set_preflight_error "permission_insufficient" "vercel" \
                        "Role '${role}' is not documented as having project creation capability"
                    return 1
                    ;;
            esac
            ;;

        project_delete)
            # UNVERIFIED: No Vercel documentation establishes which roles
            # can delete projects. Not in the permission groups table.
            # Do not fabricate a permission rule. Do not classify
            # documentation silence as permission_insufficient.
            # Clear any prior diagnostic so stale state doesn't survive.
            clear_preflight_error
            echo "validate_vercel_permission: project_delete policy is not established from Vercel documentation — do not rely on this validation until resolved" >&2
            return 1
            ;;

        env_manage)
            # Documented: Owner unrestricted. Member includes EnvVariableManager.
            # Developer: "restricted from altering production environment variables"
            # Source: https://vercel.com/docs/rbac/access-roles
            case "$role" in
                OWNER)
                    return 0 ;;
                MEMBER)
                    return 0 ;;
                DEVELOPER)
                    # Documented restriction: Developer cannot alter production
                    # env vars. Lab spinup sets env vars for all targets including
                    # production. This is a documented limitation.
                    set_preflight_error "permission_insufficient" "vercel" \
                        "Developer role is documented as restricted from altering production environment variables (source: https://vercel.com/docs/rbac/access-roles). Lab spinup requires all-target env var management."
                    return 1
                    ;;
                *)
                    set_preflight_error "permission_insufficient" "vercel" \
                        "Role '${role}' is not documented as having environment variable management capability"
                    return 1
                    ;;
            esac
            ;;

        domain_manage)
            # Documented: Owner unrestricted. Member: "manage project-specific domains."
            # Developer: role docs say "Manage project domains" but there is
            # no permission group for domain management (unlike CreateProject
            # or FullProductionDeployment). The prose-only evidence is the
            # same class as the env_manage restriction prose. Fail closed for
            # Developer until a permission group or clearer documentation
            # establishes this capability.
            # Source: https://vercel.com/docs/rbac/access-roles
            case "$role" in
                OWNER|MEMBER)
                    return 0 ;;
                DEVELOPER)
                    set_preflight_error "permission_insufficient" "vercel" \
                        "Developer domain management rests on role-description prose only — no permission group exists. Failing closed until explicit documentation or permission group establishes this capability."
                    return 1
                    ;;
                *)
                    set_preflight_error "permission_insufficient" "vercel" \
                        "Role '${role}' is not documented as having domain management capability"
                    return 1
                    ;;
            esac
            ;;

        deployment_create)
            # Documented: Owner and Member include Full Production Deployment.
            # Developer requires FullProductionDeployment extended permission
            # for API/CLI production deployment. Git-based production deploy
            # (merge to main) is documented as available to Developer.
            # Lab spinup triggers API deployment — requires the extended permission.
            # Source: https://vercel.com/docs/rbac/access-roles (Permission groups)
            case "$role" in
                OWNER)
                    return 0 ;;
                MEMBER)
                    return 0 ;;
                DEVELOPER)
                    if [[ -z "$_VERCEL_MEMBERSHIP_PERMISSIONS" ]]; then
                        set_preflight_error "permission_insufficient" "vercel" \
                            "Developer role requires explicit FullProductionDeployment extended permission for API-triggered production deployment but teamPermissions was not returned by the API"
                        return 1
                    fi
                    if _has_vercel_permission "FullProductionDeployment"; then
                        return 0
                    fi
                    set_preflight_error "permission_insufficient" "vercel" \
                        "Developer role lacks FullProductionDeployment extended permission (required for API/CLI production deployment; documented: https://vercel.com/docs/rbac/access-roles)"
                    return 1
                    ;;
                *)
                    set_preflight_error "permission_insufficient" "vercel" \
                        "Role '${role}' is not documented as having deployment creation capability"
                    return 1
                    ;;
            esac
            ;;

        *)
            echo "validate_vercel_permission: unknown capability '${capability}'" >&2
            return 1
            ;;
    esac
}

# ── resolve_vercel_context ────────────────────────────────────────────────
# Full Vercel resolver: credential → actor → scope config → canonical team
# → identity verification → access → baseline permission → context.
#
# Baseline capability: project_create
# This does NOT validate env_manage, domain_manage, or deployment_create.
# See KNOWN GAP at top of Vercel resolver section.

resolve_vercel_context() {
    clear_preflight_error
    clear_provider_context "VERCEL"
    _clear_vercel_membership

    # Step 1-3: Credential + actor
    validate_vercel_credential || return 1

    # Step 4: Canonical scope config present
    if [[ -z "${LAB_VERCEL_TEAM_ID:-}" || -z "${LAB_VERCEL_TEAM_SLUG:-}" ]]; then
        set_preflight_error "scope_config_missing" "vercel" \
            "LAB_VERCEL_TEAM_ID or LAB_VERCEL_TEAM_SLUG not set in provider-scopes.sh"
        return 1
    fi

    # Step 5: Canonical scope retrieved by ID
    local raw_response
    raw_response=$(_provider_vercel_api GET "/v2/teams/${LAB_VERCEL_TEAM_ID}" 2>/dev/null) || {
        set_preflight_error "provider_unavailable" "vercel" \
            "Transport failure calling GET /v2/teams/${LAB_VERCEL_TEAM_ID}"
        return 1
    }

    _split_provider_response "$raw_response"

    case "$_RESP_CODE" in
        200) ;;
        401)
            set_preflight_error "credential_invalid" "vercel" \
                "GET /v2/teams returned 401 (token may have been revoked between calls)"
            return 1
            ;;
        403)
            set_preflight_error "scope_access_denied" "vercel" \
                "GET /v2/teams/${LAB_VERCEL_TEAM_ID} returned 403 (documented: not authorized to access the team)"
            return 1
            ;;
        404)
            set_preflight_error "scope_not_found" "vercel" \
                "GET /v2/teams/${LAB_VERCEL_TEAM_ID} returned 404 (documented: team was not found)"
            return 1
            ;;
        5[0-9][0-9])
            set_preflight_error "provider_unavailable" "vercel" \
                "GET /v2/teams returned HTTP ${_RESP_CODE}"
            return 1
            ;;
        *)
            set_preflight_error "response_invalid" "vercel" \
                "GET /v2/teams returned unexpected HTTP ${_RESP_CODE}"
            return 1
            ;;
    esac

    # Validate JSON
    if ! echo "$_RESP_BODY" | jq empty 2>/dev/null; then
        set_preflight_error "response_invalid" "vercel" \
            "GET /v2/teams returned HTTP 200 but body is not valid JSON"
        return 1
    fi

    # Step 6: Verify returned slug matches expected
    local team_id team_slug team_name
    team_id=$(echo "$_RESP_BODY" | jq -r '.id // empty' 2>/dev/null)
    team_slug=$(echo "$_RESP_BODY" | jq -r '.slug // empty' 2>/dev/null)
    team_name=$(echo "$_RESP_BODY" | jq -r '.name // empty' 2>/dev/null)

    if [[ "$team_slug" != "$LAB_VERCEL_TEAM_SLUG" ]]; then
        set_preflight_error "scope_identity_mismatch" "vercel" \
            "Canonical ID ${LAB_VERCEL_TEAM_ID} resolved to slug '${team_slug}', expected '${LAB_VERCEL_TEAM_SLUG}'"
        return 1
    fi

    # Step 7: Verify actor access (membership present)
    local membership_json
    membership_json=$(echo "$_RESP_BODY" | jq '.membership // empty' 2>/dev/null)
    if [[ -z "$membership_json" || "$membership_json" == "null" ]]; then
        set_preflight_error "scope_access_denied" "vercel" \
            "GET /v2/teams returned 200 but membership field is absent — actor is not a team member"
        return 1
    fi

    # Normalize membership evidence
    _normalize_vercel_membership "$membership_json"

    if [[ -z "$_VERCEL_MEMBERSHIP_ROLE" ]]; then
        set_preflight_error "scope_access_denied" "vercel" \
            "Membership present but role is empty"
        return 1
    fi

    # Step 8: Baseline permission check (project_create only)
    validate_vercel_permission "project_create" || return 1

    # Step 9: Populate ProviderContext
    # Build permission evidence string from normalized membership
    local perm_evidence="role:${_VERCEL_MEMBERSHIP_ROLE}"
    if [[ -n "$_VERCEL_MEMBERSHIP_PERMISSIONS" ]]; then
        perm_evidence="${perm_evidence},permissions:${_VERCEL_MEMBERSHIP_PERMISSIONS}"
    fi

    VERCEL_CTX_PROVIDER="vercel"
    VERCEL_CTX_ACTOR_ID="$_VERCEL_ACTOR_ID"
    VERCEL_CTX_ACTOR_NAME="$_VERCEL_ACTOR_NAME"
    VERCEL_CTX_SCOPE_ID="$team_id"
    VERCEL_CTX_SCOPE_NAME="$team_name"
    VERCEL_CTX_SCOPE_SLUG="$team_slug"
    VERCEL_CTX_PERMISSION="$perm_evidence"
    VERCEL_CTX_RESOLUTION_SOURCE="api:/v2/teams/${LAB_VERCEL_TEAM_ID}"

    return 0
}

# ── Supabase resolver (PLAT-01/WP3) ───────────────────────────────────────
#
# API calls:
#   GET /v1/profile                           — credential + actor identity
#   GET /v1/organizations                     — canonical org by ID + metadata
#   GET /v2/organizations/{slug}/members      — membership + org-scoped roles
#
# Documented RBAC basis: https://supabase.com/docs/guides/platform/access-control
#
# KNOWN GAP: resolve_supabase_context validates project_create only.
# Spinup additionally requires api_keys_read, project_settings_update,
# and database_manage. Until WP7 wires per-capability checks, a passing
# Supabase preflight does not guarantee spinup completion.
#
# ARCHITECTURAL ASSUMPTION: Multiple organization-scoped roles are
# evaluated additively — any qualifying role grants the capability.
# Supabase does not document conflict/precedence semantics for combined
# role assignments. Fail closed when no org-scoped role qualifies.
#
# WP8 scoped project discovery contract:
#   GET /v1/organizations/{SUPABASE_CTX_SCOPE_SLUG}/projects?search={name}
#   Verify exact name match. Zero matches -> resource_not_found.
#   Endpoint is org-scoped; do not fall back to global GET /v1/projects.

# ── Normalized Supabase membership ────────────────────────────────────────

_SUPABASE_ORG_ROLES=""       # comma-separated org-scoped roles
_SUPABASE_PROJECT_ROLES=""   # comma-separated project-scoped roles (for future use)

_clear_supabase_membership() {
    _SUPABASE_ORG_ROLES=""
    _SUPABASE_PROJECT_ROLES=""
}

_normalize_supabase_membership() {
    local roles_json="$1"
    _clear_supabase_membership

    # Separate organization-scoped from project-scoped roles
    _SUPABASE_ORG_ROLES=$(echo "$roles_json" | jq -r \
        '[.[] | select(.scope=="organization") | .name] | join(",")' 2>/dev/null)
    _SUPABASE_PROJECT_ROLES=$(echo "$roles_json" | jq -r \
        '[.[] | select(.scope!="organization") | .name] | join(",")' 2>/dev/null)
}

_has_supabase_org_role() {
    local role="$1"
    [[ -n "$_SUPABASE_ORG_ROLES" ]] && \
        echo ",$_SUPABASE_ORG_ROLES," | grep -q ",$role,"
}

# ── validate_supabase_credential ──────────────────────────────────────────

_SUPABASE_ACTOR_ID=""
_SUPABASE_ACTOR_NAME=""

validate_supabase_credential() {
    _SUPABASE_ACTOR_ID=""
    _SUPABASE_ACTOR_NAME=""

    if [[ -z "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
        set_preflight_error "credential_missing" "supabase" \
            "SUPABASE_ACCESS_TOKEN is not set"
        return 1
    fi

    local raw_response
    raw_response=$(_provider_supabase_api GET /v1/profile 2>/dev/null) || {
        set_preflight_error "provider_unavailable" "supabase" \
            "Transport failure calling GET /v1/profile"
        return 1
    }

    _split_provider_response "$raw_response"

    case "$_RESP_CODE" in
        200)
            if ! echo "$_RESP_BODY" | jq empty 2>/dev/null; then
                set_preflight_error "response_invalid" "supabase" \
                    "GET /v1/profile returned HTTP 200 but body is not valid JSON"
                return 1
            fi

            local actor_id actor_name
            actor_id=$(echo "$_RESP_BODY" | jq -r '.gotrue_id // empty' 2>/dev/null)
            actor_name=$(echo "$_RESP_BODY" | jq -r '.username // empty' 2>/dev/null)

            if [[ -z "$actor_id" ]]; then
                set_preflight_error "actor_unresolved" "supabase" \
                    "GET /v1/profile returned 200 but gotrue_id is null or absent"
                return 1
            fi

            _SUPABASE_ACTOR_ID="$actor_id"
            _SUPABASE_ACTOR_NAME="$actor_name"
            return 0
            ;;
        401)
            set_preflight_error "credential_invalid" "supabase" \
                "GET /v1/profile returned 401 (documented: unauthorized)"
            return 1
            ;;
        403)
            # ASSUMPTION: 403 at profile endpoint means credential cannot
            # establish actor identity. No documented non-credential 403 case.
            set_preflight_error "credential_invalid" "supabase" \
                "GET /v1/profile returned 403 (classified as credential failure at actor-resolution stage; this is an architectural assumption)"
            return 1
            ;;
        429)
            set_preflight_error "provider_unavailable" "supabase" \
                "GET /v1/profile returned 429 (rate limited)"
            return 1
            ;;
        5[0-9][0-9])
            set_preflight_error "provider_unavailable" "supabase" \
                "GET /v1/profile returned HTTP ${_RESP_CODE}"
            return 1
            ;;
        *)
            set_preflight_error "response_invalid" "supabase" \
                "GET /v1/profile returned unexpected HTTP ${_RESP_CODE}"
            return 1
            ;;
    esac
}

# ── validate_supabase_permission ──────────────────────────────────────────
# Capability-specific. Reads _SUPABASE_ORG_ROLES only.
# Project-scoped roles never authorize organization-wide operations.
#
# Documented basis: https://supabase.com/docs/guides/platform/access-control
#
# Multi-role semantics: evaluated additively. Any qualifying org-scoped
# role grants the capability. This is an ARCHITECTURAL ASSUMPTION — Supabase
# does not document conflict/precedence for combined roles.

validate_supabase_permission() {
    local capability="$1"

    case "$capability" in
        project_create|project_delete)
            # DOCUMENTED: Owner and Administrator can create/delete projects.
            # Developer and Read-Only cannot.
            if _has_supabase_org_role "owner" || _has_supabase_org_role "administrator"; then
                return 0
            fi
            set_preflight_error "permission_insufficient" "supabase" \
                "Capability '${capability}' requires organization-scoped owner or administrator role (documented: https://supabase.com/docs/guides/platform/access-control). Current org roles: ${_SUPABASE_ORG_ROLES:-none}"
            return 1
            ;;

        api_keys_read|database_manage)
            # DOCUMENTED: Owner, Administrator, or Developer.
            if _has_supabase_org_role "owner" || _has_supabase_org_role "administrator" || \
               _has_supabase_org_role "developer"; then
                return 0
            fi
            set_preflight_error "permission_insufficient" "supabase" \
                "Capability '${capability}' requires organization-scoped owner, administrator, or developer role (documented). Current org roles: ${_SUPABASE_ORG_ROLES:-none}"
            return 1
            ;;

        project_settings_update)
            # DOCUMENTED: Owner and Administrator.
            if _has_supabase_org_role "owner" || _has_supabase_org_role "administrator"; then
                return 0
            fi
            set_preflight_error "permission_insufficient" "supabase" \
                "Capability '${capability}' requires organization-scoped owner or administrator role (documented). Current org roles: ${_SUPABASE_ORG_ROLES:-none}"
            return 1
            ;;

        *)
            echo "validate_supabase_permission: unknown capability '${capability}'" >&2
            return 1
            ;;
    esac
}

# ── resolve_supabase_context ──────────────────────────────────────────────
# Full resolver: credential → actor → scope config → canonical org
# → identity verification → membership → permission → context.
#
# Baseline capability: project_create

resolve_supabase_context() {
    clear_preflight_error
    clear_provider_context "SUPABASE"
    _clear_supabase_membership
    _SUPABASE_ACTOR_ID=""
    _SUPABASE_ACTOR_NAME=""

    # Step 1-3: Credential + actor
    validate_supabase_credential || return 1

    # Step 4: Canonical scope config present
    if [[ -z "${LAB_SUPABASE_ORG_ID:-}" || -z "${LAB_SUPABASE_ORG_NAME:-}" || -z "${LAB_SUPABASE_ORG_SLUG:-}" ]]; then
        set_preflight_error "scope_config_missing" "supabase" \
            "LAB_SUPABASE_ORG_ID, LAB_SUPABASE_ORG_NAME, or LAB_SUPABASE_ORG_SLUG not set in provider-scopes.sh"
        return 1
    fi

    # Step 5: Enumerate accessible orgs, exact-match canonical ID
    local raw_response
    raw_response=$(_provider_supabase_api GET /v1/organizations 2>/dev/null) || {
        set_preflight_error "provider_unavailable" "supabase" \
            "Transport failure calling GET /v1/organizations"
        return 1
    }

    _split_provider_response "$raw_response"

    case "$_RESP_CODE" in
        200) ;;
        401)
            set_preflight_error "credential_invalid" "supabase" \
                "GET /v1/organizations returned 401"
            return 1
            ;;
        403)
            # ARCHITECTURAL MAPPING: token accepted by /v1/profile but
            # rejected by /v1/organizations — treat as credential scope issue
            set_preflight_error "scope_access_denied" "supabase" \
                "GET /v1/organizations returned 403 (architectural mapping: credential accepted for profile but rejected for org enumeration)"
            return 1
            ;;
        429)
            set_preflight_error "provider_unavailable" "supabase" \
                "GET /v1/organizations returned 429 (rate limited)"
            return 1
            ;;
        5[0-9][0-9])
            set_preflight_error "provider_unavailable" "supabase" \
                "GET /v1/organizations returned HTTP ${_RESP_CODE}"
            return 1
            ;;
        *)
            set_preflight_error "response_invalid" "supabase" \
                "GET /v1/organizations returned unexpected HTTP ${_RESP_CODE}"
            return 1
            ;;
    esac

    # Validate response is a JSON array
    if ! echo "$_RESP_BODY" | jq -e 'type == "array"' &>/dev/null; then
        set_preflight_error "response_invalid" "supabase" \
            "GET /v1/organizations returned HTTP 200 but body is not a JSON array"
        return 1
    fi

    # Exact-match canonical ID
    local match_count
    match_count=$(echo "$_RESP_BODY" | jq \
        "[.[] | select(.id==\"${LAB_SUPABASE_ORG_ID}\")] | length" 2>/dev/null)

    if [[ "$match_count" -eq 0 ]]; then
        set_preflight_error "scope_not_found" "supabase" \
            "Canonical org ID '${LAB_SUPABASE_ORG_ID}' not found in accessible organizations. Either the org was deleted or access was revoked — verify with an admin."
        return 1
    fi

    if [[ "$match_count" -gt 1 ]]; then
        set_preflight_error "response_invalid" "supabase" \
            "Canonical org ID '${LAB_SUPABASE_ORG_ID}' matched ${match_count} entries (expected exactly 1)"
        return 1
    fi

    # Step 6: Verify returned name and slug
    local org_id org_name org_slug
    org_id=$(echo "$_RESP_BODY" | jq -r \
        ".[] | select(.id==\"${LAB_SUPABASE_ORG_ID}\") | .id" 2>/dev/null)
    org_name=$(echo "$_RESP_BODY" | jq -r \
        ".[] | select(.id==\"${LAB_SUPABASE_ORG_ID}\") | .name // empty" 2>/dev/null)
    org_slug=$(echo "$_RESP_BODY" | jq -r \
        ".[] | select(.id==\"${LAB_SUPABASE_ORG_ID}\") | .slug // empty" 2>/dev/null)

    if [[ "$org_name" != "$LAB_SUPABASE_ORG_NAME" || "$org_slug" != "$LAB_SUPABASE_ORG_SLUG" ]]; then
        set_preflight_error "scope_identity_mismatch" "supabase" \
            "Canonical ID ${LAB_SUPABASE_ORG_ID} resolved to name='${org_name}' slug='${org_slug}', expected name='${LAB_SUPABASE_ORG_NAME}' slug='${LAB_SUPABASE_ORG_SLUG}'"
        return 1
    fi

    # Step 7: Resolve actor membership via v2 members endpoint
    # Uses verified slug from step 6. Paginate until actor found or exhausted.
    local members_path="/v2/organizations/${org_slug}/members"
    local actor_roles_json=""
    local page_url="$members_path"
    local enumeration_complete=false

    while [[ -n "$page_url" ]]; do
        local members_raw
        members_raw=$(_provider_supabase_api GET "$page_url" 2>/dev/null) || {
            set_preflight_error "provider_unavailable" "supabase" \
                "Transport failure calling GET ${page_url}"
            return 1
        }

        _split_provider_response "$members_raw"

        case "$_RESP_CODE" in
            200) ;;
            401)
                set_preflight_error "credential_invalid" "supabase" \
                    "GET ${page_url} returned 401"
                return 1
                ;;
            403)
                set_preflight_error "scope_access_denied" "supabase" \
                    "GET ${page_url} returned 403 (documented: forbidden)"
                return 1
                ;;
            429)
                set_preflight_error "provider_unavailable" "supabase" \
                    "GET ${page_url} returned 429 (rate limited)"
                return 1
                ;;
            5[0-9][0-9])
                set_preflight_error "provider_unavailable" "supabase" \
                    "GET ${page_url} returned HTTP ${_RESP_CODE}"
                return 1
                ;;
            *)
                set_preflight_error "response_invalid" "supabase" \
                    "GET ${page_url} returned unexpected HTTP ${_RESP_CODE}"
                return 1
                ;;
        esac

        # Validate page structure
        if ! echo "$_RESP_BODY" | jq -e '.data' &>/dev/null; then
            set_preflight_error "response_invalid" "supabase" \
                "GET ${page_url} returned 200 but response lacks .data array"
            return 1
        fi

        # Search for actor by gotrue_id
        actor_roles_json=$(echo "$_RESP_BODY" | jq -c \
            ".data[] | select(.id==\"${_SUPABASE_ACTOR_ID}\") | .attributes.roles" 2>/dev/null)

        if [[ -n "$actor_roles_json" && "$actor_roles_json" != "null" ]]; then
            break
        fi

        # Check pagination: get next page URL
        local next_url
        next_url=$(echo "$_RESP_BODY" | jq -r '.links.next // empty' 2>/dev/null)

        if [[ -z "$next_url" ]]; then
            enumeration_complete=true
            break
        fi

        # Validate next URL is structurally reasonable
        if ! echo "$next_url" | grep -q '/v2/organizations/'; then
            set_preflight_error "response_invalid" "supabase" \
                "Pagination links.next has unexpected structure: ${next_url}"
            return 1
        fi

        page_url="$next_url"
    done

    # Actor not found after complete enumeration
    if [[ -z "$actor_roles_json" || "$actor_roles_json" == "null" ]]; then
        if $enumeration_complete; then
            set_preflight_error "scope_access_denied" "supabase" \
                "Authenticated actor (gotrue_id: ${_SUPABASE_ACTOR_ID}) not found in organization member list after complete enumeration"
            return 1
        fi
        # Should not reach here — incomplete enumeration returns earlier
        set_preflight_error "response_invalid" "supabase" \
            "Member enumeration ended without finding actor and without completing"
        return 1
    fi

    # Normalize membership: separate org-scoped from project-scoped roles
    _normalize_supabase_membership "$actor_roles_json"

    if [[ -z "$_SUPABASE_ORG_ROLES" ]]; then
        set_preflight_error "scope_access_denied" "supabase" \
            "Actor found in member list but has no organization-scoped roles (project-scoped roles: ${_SUPABASE_PROJECT_ROLES:-none}). Organization-wide capability requires organization-scoped role assignment."
        return 1
    fi

    # Step 8: Baseline permission check (project_create only)
    validate_supabase_permission "project_create" || return 1

    # Step 9: Populate ProviderContext
    SUPABASE_CTX_PROVIDER="supabase"
    SUPABASE_CTX_ACTOR_ID="$_SUPABASE_ACTOR_ID"
    SUPABASE_CTX_ACTOR_NAME="$_SUPABASE_ACTOR_NAME"
    SUPABASE_CTX_SCOPE_ID="$org_id"
    SUPABASE_CTX_SCOPE_NAME="$org_name"
    SUPABASE_CTX_SCOPE_SLUG="$org_slug"
    SUPABASE_CTX_PERMISSION="org_roles:${_SUPABASE_ORG_ROLES}"
    SUPABASE_CTX_RESOLUTION_SOURCE="api:/v1/organizations+/v2/organizations/${org_slug}/members"

    return 0
}

# ── GitHub resolver (PLAT-01/WP4) ─────────────────────────────────────────
#
# API calls (all via _provider_github_api status-aware seam):
#   GET /user                          — credential + actor identity
#   GET /user/orgs?per_page=100        — canonical org enumeration (paginated)
#   GET /user/memberships/orgs/{org}   — membership role + state
#   GET /orgs/{org}                    — org settings for repo-creation policy
#
# Documented RBAC: https://docs.github.com/en/organizations/managing-organization-settings/restricting-repository-creation-in-your-organization
# Enterprise policy: https://docs.github.com/en/admin/enforcing-policies/enforcing-policies-for-your-enterprise/enforcing-repository-management-policies-in-your-enterprise
#
# repo_create classification: PARTIALLY EVALUABLE
# Observable: actor role, org-level creation settings
# Not observable: enterprise/repository policy restrictions
# policy_completeness is always "partial"
#
# KNOWN GAP: resolve_github_context validates repo_create baseline only.
# Spinup additionally requires branch protection, secrets, issue creation.
# Teardown requires repo archival. Until WP7, a passing preflight does not
# guarantee spinup/teardown completion.

# ── Rate-limit detection ──────────────────────────────────────────────────

_is_github_rate_limited() {
    if [[ "$_GITHUB_API_STATUS" == "429" ]]; then
        return 0
    fi
    if [[ "$_GITHUB_API_STATUS" == "403" ]]; then
        if [[ "$_GITHUB_API_RATELIMIT_REMAINING" == "0" ]]; then
            return 0
        fi
        if [[ -n "$_GITHUB_API_RETRY_AFTER" ]]; then
            return 0
        fi
    fi
    return 1
}

# ── Normalized GitHub membership ──────────────────────────────────────────

_GITHUB_MEMBERSHIP_ROLE=""
_GITHUB_MEMBERSHIP_STATE=""
_GITHUB_ORG_REPO_CREATION=""
_GITHUB_ORG_MEMBERS_CAN_CREATE=""

_clear_github_membership() {
    _GITHUB_MEMBERSHIP_ROLE=""
    _GITHUB_MEMBERSHIP_STATE=""
    _GITHUB_ORG_REPO_CREATION=""
    _GITHUB_ORG_MEMBERS_CAN_CREATE=""
}

_GITHUB_ACTOR_ID=""
_GITHUB_ACTOR_NAME=""

# ── validate_github_credential ────────────────────────────────────────────

validate_github_credential() {
    _GITHUB_ACTOR_ID=""
    _GITHUB_ACTOR_NAME=""

    # Step 1: credential present — use auth-status seam
    _provider_github_auth_status
    if [[ $? -ne 0 ]]; then
        set_preflight_error "credential_missing" "github" \
            "No active authenticated GitHub account for github.com. Run: gh auth login"
        return 1
    fi

    # Step 2-3: credential valid + actor resolved
    _provider_github_api /user
    if [[ $? -ne 0 ]]; then
        set_preflight_error "provider_unavailable" "github" \
            "Transport failure calling GET /user — no HTTP response received"
        return 1
    fi

    # Rate-limit check first
    if _is_github_rate_limited; then
        set_preflight_error "provider_unavailable" "github" \
            "Rate limited on GET /user (HTTP ${_GITHUB_API_STATUS}, X-RateLimit-Remaining: ${_GITHUB_API_RATELIMIT_REMAINING:-?})"
        return 1
    fi

    case "$_GITHUB_API_STATUS" in
        200)
            if ! echo "$_GITHUB_API_BODY" | jq empty 2>/dev/null; then
                set_preflight_error "response_invalid" "github" \
                    "GET /user returned HTTP 200 but body is not valid JSON"
                return 1
            fi

            local actor_id actor_name
            actor_id=$(echo "$_GITHUB_API_BODY" | jq -r '.id // empty' 2>/dev/null)
            actor_name=$(echo "$_GITHUB_API_BODY" | jq -r '.login // empty' 2>/dev/null)

            if [[ -z "$actor_id" ]]; then
                set_preflight_error "actor_unresolved" "github" \
                    "GET /user returned 200 but id is null or absent"
                return 1
            fi

            _GITHUB_ACTOR_ID="$actor_id"
            _GITHUB_ACTOR_NAME="$actor_name"
            return 0
            ;;
        401)
            set_preflight_error "credential_invalid" "github" \
                "GET /user returned 401 — auth status passed but API rejected credentials"
            return 1
            ;;
        403)
            # Non-rate-limited 403 after auth-status success
            set_preflight_error "credential_invalid" "github" \
                "GET /user returned 403 without rate-limit evidence after auth-status success"
            return 1
            ;;
        5[0-9][0-9])
            set_preflight_error "provider_unavailable" "github" \
                "GET /user returned HTTP ${_GITHUB_API_STATUS}"
            return 1
            ;;
        *)
            set_preflight_error "response_invalid" "github" \
                "GET /user returned unexpected HTTP ${_GITHUB_API_STATUS}"
            return 1
            ;;
    esac
}

# ── validate_github_permission ────────────────────────────────────────────
# Capability-specific. Reads _GITHUB_MEMBERSHIP_ROLE and org settings.
#
# repo_create is PARTIALLY EVALUABLE — observable baseline only.
# Enterprise policy may still restrict creation.

validate_github_permission() {
    local capability="$1"
    local role="$_GITHUB_MEMBERSHIP_ROLE"

    case "$capability" in
        repo_create)
            case "$role" in
                admin)
                    # DOCUMENTED: org owners/admins can always create
                    return 0
                    ;;
                member)
                    # Evaluate org-level settings
                    # Both fields are optional/nullable in GitHub schema
                    if [[ "$_GITHUB_ORG_MEMBERS_CAN_CREATE" == "true" ]]; then
                        return 0
                    fi
                    if [[ "$_GITHUB_ORG_MEMBERS_CAN_CREATE" == "false" ]]; then
                        set_preflight_error "permission_insufficient" "github" \
                            "Organization setting members_can_create_repositories is false (documented: org restricts member repo creation)"
                        return 1
                    fi
                    # Primary field absent — check type field
                    if [[ "$_GITHUB_ORG_REPO_CREATION" == "none" ]]; then
                        set_preflight_error "permission_insufficient" "github" \
                            "Organization setting members_allowed_repository_creation_type is 'none' (documented: org disallows member repo creation)"
                        return 1
                    fi
                    if [[ "$_GITHUB_ORG_REPO_CREATION" == "all" || "$_GITHUB_ORG_REPO_CREATION" == "private" ]]; then
                        return 0
                    fi
                    # Both fields absent/null — fail closed
                    set_preflight_error "permission_insufficient" "github" \
                        "Organization repository-creation policy fields absent from API response. These fields are optional in GitHub's schema. Cannot establish baseline creation permission without observable evidence."
                    return 1
                    ;;
                billing_manager)
                    set_preflight_error "permission_insufficient" "github" \
                        "billing_manager role cannot create repositories (documented: billing only)"
                    return 1
                    ;;
                *)
                    set_preflight_error "permission_insufficient" "github" \
                        "Role '${role}' is not recognized for repository creation"
                    return 1
                    ;;
            esac
            ;;

        repo_archive|repo_settings_manage)
            # UNVERIFIED policy
            clear_preflight_error
            echo "validate_github_permission: ${capability} policy is not established from GitHub documentation — do not rely on this validation until resolved" >&2
            return 1
            ;;

        *)
            echo "validate_github_permission: unknown capability '${capability}'" >&2
            return 1
            ;;
    esac
}

# ── resolve_github_context ────────────────────────────────────────────────

resolve_github_context() {
    clear_preflight_error
    clear_provider_context "GITHUB"
    _clear_github_membership
    _GITHUB_ACTOR_ID=""
    _GITHUB_ACTOR_NAME=""

    # Step 1-3: Credential + actor
    validate_github_credential || return 1

    # Step 4: Canonical scope config present
    if [[ -z "${LAB_GITHUB_ORG_ID:-}" || -z "${LAB_GITHUB_ORG:-}" ]]; then
        set_preflight_error "scope_config_missing" "github" \
            "LAB_GITHUB_ORG_ID or LAB_GITHUB_ORG not set in provider-scopes.sh"
        return 1
    fi

    # Step 5: Enumerate accessible orgs, exact-match canonical ID
    # Explicit page iteration through status-aware seam
    local org_page_url="/user/orgs?per_page=100"
    local found_org_json=""
    local enumeration_complete=false

    while [[ -n "$org_page_url" ]]; do
        _provider_github_api "$org_page_url"
        if [[ $? -ne 0 ]]; then
            set_preflight_error "provider_unavailable" "github" \
                "Transport failure enumerating organizations at ${org_page_url}"
            return 1
        fi

        # Rate-limit check
        if _is_github_rate_limited; then
            set_preflight_error "provider_unavailable" "github" \
                "Rate limited enumerating organizations (HTTP ${_GITHUB_API_STATUS}, X-RateLimit-Remaining: ${_GITHUB_API_RATELIMIT_REMAINING:-?})"
            return 1
        fi

        case "$_GITHUB_API_STATUS" in
            200) ;;
            401)
                set_preflight_error "credential_invalid" "github" \
                    "GET ${org_page_url} returned 401"
                return 1
                ;;
            403)
                # Non-rate-limited 403 after successful /user auth
                set_preflight_error "scope_access_denied" "github" \
                    "Authenticated GitHub actor could not enumerate accessible organizations. The credential may lack the organization authorization or token scope required for this operation."
                return 1
                ;;
            5[0-9][0-9])
                set_preflight_error "provider_unavailable" "github" \
                    "GET ${org_page_url} returned HTTP ${_GITHUB_API_STATUS}"
                return 1
                ;;
            *)
                set_preflight_error "response_invalid" "github" \
                    "GET ${org_page_url} returned unexpected HTTP ${_GITHUB_API_STATUS}"
                return 1
                ;;
        esac

        # Validate JSON array
        if ! echo "$_GITHUB_API_BODY" | jq -e 'type == "array"' &>/dev/null; then
            set_preflight_error "response_invalid" "github" \
                "GET ${org_page_url} returned HTTP 200 but body is not a JSON array"
            return 1
        fi

        # Search for canonical org ID
        local match
        match=$(echo "$_GITHUB_API_BODY" | jq -c \
            ".[] | select(.id==${LAB_GITHUB_ORG_ID})" 2>/dev/null)
        if [[ -n "$match" ]]; then
            found_org_json="$match"
            break
        fi

        # Check for next page via Link header
        local next_url=""
        if [[ -n "$_GITHUB_API_LINK" ]]; then
            next_url=$(echo "$_GITHUB_API_LINK" | tr ',' '\n' | grep 'rel="next"' | sed 's/.*<\(.*\)>.*/\1/' | head -1)
        fi

        if [[ -z "$next_url" ]]; then
            enumeration_complete=true
            break
        fi

        org_page_url="$next_url"
    done

    if [[ -z "$found_org_json" ]]; then
        if $enumeration_complete; then
            set_preflight_error "scope_not_found" "github" \
                "Canonical GitHub organization ID ${LAB_GITHUB_ORG_ID} was not found in the authenticated actor's complete accessible-organization enumeration. This may mean the organization no longer exists or the actor no longer has visibility/access."
            return 1
        fi
        set_preflight_error "response_invalid" "github" \
            "Organization enumeration ended without finding canonical ID and without completing"
        return 1
    fi

    # Check for duplicate canonical ID matches
    # (would have been caught on the page where the first match was found)
    local match_count
    match_count=$(echo "$_GITHUB_API_BODY" | jq \
        "[.[] | select(.id==${LAB_GITHUB_ORG_ID})] | length" 2>/dev/null)
    if [[ "$match_count" -gt 1 ]]; then
        set_preflight_error "response_invalid" "github" \
            "Canonical org ID ${LAB_GITHUB_ORG_ID} matched ${match_count} entries on a single page"
        return 1
    fi

    # Step 6: Verify returned login matches expected
    local org_id org_login org_name
    org_id=$(echo "$found_org_json" | jq -r '.id' 2>/dev/null)
    org_login=$(echo "$found_org_json" | jq -r '.login // empty' 2>/dev/null)
    org_name=$(echo "$found_org_json" | jq -r '.name // empty' 2>/dev/null)

    if [[ "$org_login" != "$LAB_GITHUB_ORG" ]]; then
        set_preflight_error "scope_identity_mismatch" "github" \
            "Canonical ID ${LAB_GITHUB_ORG_ID} resolved to login '${org_login}', expected '${LAB_GITHUB_ORG}'"
        return 1
    fi

    # Step 7: Verify actor membership
    _provider_github_api "/user/memberships/orgs/${LAB_GITHUB_ORG}"
    if [[ $? -ne 0 ]]; then
        set_preflight_error "provider_unavailable" "github" \
            "Transport failure checking membership for ${LAB_GITHUB_ORG}"
        return 1
    fi

    if _is_github_rate_limited; then
        set_preflight_error "provider_unavailable" "github" \
            "Rate limited checking membership (HTTP ${_GITHUB_API_STATUS})"
        return 1
    fi

    case "$_GITHUB_API_STATUS" in
        200) ;;
        403)
            set_preflight_error "scope_access_denied" "github" \
                "GET /user/memberships/orgs/${LAB_GITHUB_ORG} returned 403 (documented: GitHub App blocked by org)"
            return 1
            ;;
        404)
            set_preflight_error "scope_access_denied" "github" \
                "GET /user/memberships/orgs/${LAB_GITHUB_ORG} returned 404 (documented: actor not affiliated with the organization. GitHub returns 404 for both non-affiliation and nonexistent orgs at this endpoint.)"
            return 1
            ;;
        5[0-9][0-9])
            set_preflight_error "provider_unavailable" "github" \
                "GET /user/memberships/orgs/${LAB_GITHUB_ORG} returned HTTP ${_GITHUB_API_STATUS}"
            return 1
            ;;
        *)
            set_preflight_error "response_invalid" "github" \
                "GET /user/memberships/orgs/${LAB_GITHUB_ORG} returned unexpected HTTP ${_GITHUB_API_STATUS}"
            return 1
            ;;
    esac

    if ! echo "$_GITHUB_API_BODY" | jq empty 2>/dev/null; then
        set_preflight_error "response_invalid" "github" \
            "Membership response is not valid JSON"
        return 1
    fi

    _GITHUB_MEMBERSHIP_ROLE=$(echo "$_GITHUB_API_BODY" | jq -r '.role // empty' 2>/dev/null)
    _GITHUB_MEMBERSHIP_STATE=$(echo "$_GITHUB_API_BODY" | jq -r '.state // empty' 2>/dev/null)

    if [[ "$_GITHUB_MEMBERSHIP_STATE" != "active" ]]; then
        set_preflight_error "scope_access_denied" "github" \
            "Membership state is '${_GITHUB_MEMBERSHIP_STATE}' — accept the organization invitation first"
        return 1
    fi

    # Step 8: Retrieve org settings for repo-creation policy
    _provider_github_api "/orgs/${LAB_GITHUB_ORG}"
    if [[ $? -ne 0 ]]; then
        set_preflight_error "provider_unavailable" "github" \
            "Transport failure retrieving org settings for ${LAB_GITHUB_ORG}"
        return 1
    fi

    if _is_github_rate_limited; then
        set_preflight_error "provider_unavailable" "github" \
            "Rate limited retrieving org settings (HTTP ${_GITHUB_API_STATUS})"
        return 1
    fi

    case "$_GITHUB_API_STATUS" in
        200) ;;
        404|403)
            # Post-enumeration inconsistency — org was accessible during
            # enumeration but not accessible for settings retrieval.
            set_preflight_error "provider_unavailable" "github" \
                "Organization was accessible during enumeration but GET /orgs/${LAB_GITHUB_ORG} returned HTTP ${_GITHUB_API_STATUS}. Resolution became inconsistent between calls."
            return 1
            ;;
        5[0-9][0-9])
            set_preflight_error "provider_unavailable" "github" \
                "GET /orgs/${LAB_GITHUB_ORG} returned HTTP ${_GITHUB_API_STATUS}"
            return 1
            ;;
        *)
            set_preflight_error "response_invalid" "github" \
                "GET /orgs/${LAB_GITHUB_ORG} returned unexpected HTTP ${_GITHUB_API_STATUS}"
            return 1
            ;;
    esac

    if ! echo "$_GITHUB_API_BODY" | jq empty 2>/dev/null; then
        set_preflight_error "response_invalid" "github" \
            "Org settings response is not valid JSON"
        return 1
    fi

    _GITHUB_ORG_MEMBERS_CAN_CREATE=$(echo "$_GITHUB_API_BODY" | jq -r \
        '.members_can_create_repositories // empty' 2>/dev/null)
    _GITHUB_ORG_REPO_CREATION=$(echo "$_GITHUB_API_BODY" | jq -r \
        '.members_allowed_repository_creation_type // empty' 2>/dev/null)

    # Step 8b: Baseline permission check (repo_create only, PARTIALLY EVALUABLE)
    validate_github_permission "repo_create" || return 1

    # Step 9: Populate ProviderContext
    # org.name is mutable (WP0 evidence: changed from "Treehouse Innovation Lab"
    # to "Friends Innovation Lab"). Record as informational metadata.
    # REPRESENTATION FALLBACK: if org.name is null, use org.login
    local scope_name="${org_name}"
    if [[ -z "$scope_name" ]]; then
        scope_name="$org_login"
    fi

    local repo_create_baseline="denied"
    if [[ "$_GITHUB_MEMBERSHIP_ROLE" == "admin" ]]; then
        repo_create_baseline="allowed"
    elif [[ "$_GITHUB_ORG_MEMBERS_CAN_CREATE" == "true" ]] || \
         [[ "$_GITHUB_ORG_REPO_CREATION" == "all" ]] || \
         [[ "$_GITHUB_ORG_REPO_CREATION" == "private" ]]; then
        repo_create_baseline="allowed"
    fi

    GITHUB_CTX_PROVIDER="github"
    GITHUB_CTX_ACTOR_ID="$_GITHUB_ACTOR_ID"
    GITHUB_CTX_ACTOR_NAME="$_GITHUB_ACTOR_NAME"
    GITHUB_CTX_SCOPE_ID="$org_id"
    GITHUB_CTX_SCOPE_NAME="$scope_name"
    GITHUB_CTX_SCOPE_SLUG="$org_login"
    GITHUB_CTX_PERMISSION="role:${_GITHUB_MEMBERSHIP_ROLE},repo_create_baseline:${repo_create_baseline},policy_completeness:partial"
    GITHUB_CTX_RESOLUTION_SOURCE="api:/user/orgs+/user/memberships/orgs/${LAB_GITHUB_ORG}+/orgs/${LAB_GITHUB_ORG}"

    return 0
}
