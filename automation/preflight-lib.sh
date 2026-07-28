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
