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

_provider_github_api() {
    gh api "$@"
}

_provider_vercel_api() {
    local method="$1"
    local path="$2"
    shift 2
    curl -s -w "\n%{http_code}" -X "$method" \
        "https://api.vercel.com${path}" \
        -H "Authorization: Bearer ${VERCEL_TOKEN:-}" \
        "$@"
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
        "$@"
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

    # Common required fields only. Provider-specific resolvers may
    # enforce additional requirements.
    local field val
    for field in PROVIDER ACTOR_ID ACTOR_NAME SCOPE_ID SCOPE_NAME RESOLUTION_SOURCE; do
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

    local provider_lower
    provider_lower=$(echo "$provider" | tr '[:upper:]' '[:lower:]')

    case "$provider" in
        GITHUB|VERCEL|SUPABASE)
            # Provider-specific resolvers are implemented in WP2-WP4.
            # Until then, this function fails clearly without assigning
            # a false operational diagnostic code. No diagnostic code is
            # set — this is a developer-facing scaffold condition, not an
            # operational failure. Callers should check the return code.
            echo "resolve_provider_context: resolver for ${provider} is not yet implemented (requires WP2-WP4)" >&2
            return 1
            ;;
        *)
            echo "resolve_provider_context: unknown provider '${provider}'" >&2
            return 1
            ;;
    esac
}
