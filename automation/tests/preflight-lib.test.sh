#!/usr/bin/env bash
# preflight-lib.test.sh — Mocked-boundary tests for PLAT-01 provider context layer
#
# Runs without network access. All provider calls are replaced with
# fixture-returning stubs after sourcing preflight-lib.sh.
#
# Usage:
#   ./automation/tests/preflight-lib.test.sh
#
# Part of PLAT-01/WP1. See docs/specs/PLAT-01-provider-context-and-safe-scope-resolution.md

set -uo pipefail
# Note: -e is intentionally omitted. Many tests assert non-zero return
# codes from functions; set -e would abort the suite on those.

# ── Credential isolation ───────────────────────────────────────────────────
# Tests must not depend on the operator's shell environment. Unset all
# provider credentials at suite start. Each test sets them explicitly
# when the test scenario requires a credential to be present.
#
# This prevents ambient-state dependency: a test that passes because
# VERCEL_TOKEN happens to be set in the operator's shell would be a
# false positive for credential_missing coverage.

unset VERCEL_TOKEN 2>/dev/null || true
unset SUPABASE_ACCESS_TOKEN 2>/dev/null || true
unset GH_TOKEN 2>/dev/null || true
unset GITHUB_TOKEN 2>/dev/null || true

# ── Setup ──────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXTURE_DIR="${SCRIPT_DIR}/fixtures"
LIB_PATH="${SCRIPT_DIR}/../preflight-lib.sh"

if [[ ! -f "$LIB_PATH" ]]; then
    echo "FATAL: preflight-lib.sh not found at ${LIB_PATH}" >&2
    exit 1
fi

source "$LIB_PATH"

# ── Test framework ─────────────────────────────────────────────────────────

TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
FAILURES=""

_test_pass() {
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "  PASS: $1"
}

_test_fail() {
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    FAILURES="${FAILURES}\n  FAIL: $1"
    echo "  FAIL: $1 — $2"
}

assert_eq() {
    local label="$1" expected="$2" actual="$3"
    if [[ "$expected" == "$actual" ]]; then
        _test_pass "$label"
    else
        _test_fail "$label" "expected '${expected}', got '${actual}'"
    fi
}

assert_empty() {
    local label="$1" actual="$2"
    if [[ -z "$actual" ]]; then
        _test_pass "$label"
    else
        _test_fail "$label" "expected empty, got '${actual}'"
    fi
}

assert_not_empty() {
    local label="$1" actual="$2"
    if [[ -n "$actual" ]]; then
        _test_pass "$label"
    else
        _test_fail "$label" "expected non-empty, got empty"
    fi
}

assert_unset() {
    local label="$1" varname="$2"
    if [[ -z "${!varname+x}" ]]; then
        _test_pass "$label"
    else
        _test_fail "$label" "expected '${varname}' to be unset, but it is set to '${!varname}'"
    fi
}

assert_return() {
    local label="$1" expected="$2" actual="$3"
    if [[ "$expected" == "$actual" ]]; then
        _test_pass "$label"
    else
        _test_fail "$label" "expected return code ${expected}, got ${actual}"
    fi
}

# ── Provider wrapper stubs ─────────────────────────────────────────────────
# Each test replaces these as needed. Defaults return transport failure.

_reset_provider_stubs() {
    _provider_github_api() { return 1; }
    _provider_vercel_api() { echo ""; echo "000"; }
    _provider_vercel_cli() { return 1; }
    _provider_supabase_api() { echo ""; echo "000"; }
}

_reset_provider_stubs

# ════════════════════════════════════════════════════════════════════════════
echo ""
echo "══════════════════════════════════════════════════════"
echo "  PLAT-01/WP1 — preflight-lib.sh mocked-boundary tests"
echo "══════════════════════════════════════════════════════"
echo ""

# ════════════════════════════════════════════════════════════════════════════
# Section 1: Diagnostic model
# ════════════════════════════════════════════════════════════════════════════
echo "── Diagnostic model ──"

# 1a. set + clear
clear_preflight_error
set_preflight_error "credential_missing" "vercel" "test detail"
assert_eq "set_preflight_error sets code" "credential_missing" "$PREFLIGHT_ERROR_CODE"
assert_eq "set_preflight_error sets provider" "vercel" "$PREFLIGHT_ERROR_PROVIDER"
assert_eq "set_preflight_error sets detail" "test detail" "$PREFLIGHT_ERROR_DETAIL"

clear_preflight_error
assert_empty "clear_preflight_error clears code" "$PREFLIGHT_ERROR_CODE"
assert_empty "clear_preflight_error clears provider" "$PREFLIGHT_ERROR_PROVIDER"
assert_empty "clear_preflight_error clears detail" "$PREFLIGHT_ERROR_DETAIL"

# 1b. print_preflight_error renders each code
echo ""
echo "── Diagnostic code renderers (14 codes) ──"

ALL_CODES=(
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
)

for code in "${ALL_CODES[@]}"; do
    clear_preflight_error
    set_preflight_error "$code" "test_provider" "test detail for ${code}"
    output=$(print_preflight_error 2>&1)

    # Verify it renders the code name
    if echo "$output" | grep -q "$code"; then
        _test_pass "render ${code}: code appears in output"
    else
        _test_fail "render ${code}: code appears in output" "code not found in output"
    fi

    # Verify it renders an Action line
    if echo "$output" | grep -q "Action:"; then
        _test_pass "render ${code}: has Action line"
    else
        _test_fail "render ${code}: has Action line" "no Action line in output"
    fi
done

# 1c. print_preflight_error with no error set
clear_preflight_error
output=$(print_preflight_error 2>&1)
assert_empty "print with no error produces no output" "$output"

echo ""

# ════════════════════════════════════════════════════════════════════════════
# Section 2: ProviderContext contract
# ════════════════════════════════════════════════════════════════════════════
echo "── ProviderContext contract ──"

# 2a. clear_provider_context removes all fields
VERCEL_CTX_PROVIDER="vercel"
VERCEL_CTX_ACTOR_ID="uid_123"
VERCEL_CTX_ACTOR_NAME="test-user"
VERCEL_CTX_SCOPE_ID="team_abc"
VERCEL_CTX_SCOPE_NAME="Test Team"
VERCEL_CTX_SCOPE_SLUG="test-team"
VERCEL_CTX_PERMISSION="OWNER"
VERCEL_CTX_RESOLUTION_SOURCE="bootstrap"

clear_provider_context "vercel"

assert_unset "clear vercel CTX_PROVIDER" "VERCEL_CTX_PROVIDER"
assert_unset "clear vercel CTX_ACTOR_ID" "VERCEL_CTX_ACTOR_ID"
assert_unset "clear vercel CTX_ACTOR_NAME" "VERCEL_CTX_ACTOR_NAME"
assert_unset "clear vercel CTX_SCOPE_ID" "VERCEL_CTX_SCOPE_ID"
assert_unset "clear vercel CTX_SCOPE_NAME" "VERCEL_CTX_SCOPE_NAME"
assert_unset "clear vercel CTX_SCOPE_SLUG" "VERCEL_CTX_SCOPE_SLUG"
assert_unset "clear vercel CTX_PERMISSION" "VERCEL_CTX_PERMISSION"
assert_unset "clear vercel CTX_RESOLUTION_SOURCE" "VERCEL_CTX_RESOLUTION_SOURCE"

# 2b. validate_provider_context — valid context
GITHUB_CTX_PROVIDER="github"
GITHUB_CTX_ACTOR_ID="12345"
GITHUB_CTX_ACTOR_NAME="test-user"
GITHUB_CTX_SCOPE_ID="254572218"
GITHUB_CTX_SCOPE_NAME="Friends Innovation Lab"
GITHUB_CTX_RESOLUTION_SOURCE="resolver"

validate_provider_context "github"
rc=$?
assert_return "validate valid github context" "0" "$rc"

# 2c. validate_provider_context — missing required field
unset GITHUB_CTX_SCOPE_ID
validate_provider_context "github"
rc=$?
assert_return "validate github context missing scope_id" "1" "$rc"

# 2d. validate_provider_context — optional fields don't cause failure
GITHUB_CTX_SCOPE_ID="254572218"
# scope_slug and permission are optional — not set
unset GITHUB_CTX_SCOPE_SLUG 2>/dev/null || true
unset GITHUB_CTX_PERMISSION 2>/dev/null || true
validate_provider_context "github"
rc=$?
assert_return "validate github context optional fields absent" "0" "$rc"

clear_provider_context "github"

# 2e. resolve_provider_context — not-yet-implemented providers (github, supabase)
for test_provider in github supabase; do
    clear_preflight_error
    stderr_output=$(resolve_provider_context "$test_provider" 2>&1 >/dev/null)
    rc=$?
    assert_return "resolve ${test_provider} returns 1 (not implemented)" "1" "$rc"
    assert_empty "resolve ${test_provider}: no diagnostic code" "$PREFLIGHT_ERROR_CODE"
    if echo "$stderr_output" | grep -q "not yet implemented"; then
        _test_pass "resolve ${test_provider}: stderr says not yet implemented"
    else
        _test_fail "resolve ${test_provider}: stderr says not yet implemented" "got: ${stderr_output}"
    fi
    uc_prov=$(echo "$test_provider" | tr '[:lower:]' '[:upper:]')
    assert_unset "resolve ${test_provider}: no partial CTX_SCOPE_ID" "${uc_prov}_CTX_SCOPE_ID"
done

# 2f. resolve_provider_context — unknown provider
clear_preflight_error
stderr_output=$(resolve_provider_context "bogus_provider" 2>&1 >/dev/null)
rc=$?
assert_return "resolve unknown provider returns 1" "1" "$rc"
assert_empty "resolve unknown: no diagnostic code set" "$PREFLIGHT_ERROR_CODE"
if echo "$stderr_output" | grep -q "unknown provider"; then
    _test_pass "resolve unknown: stderr says unknown provider"
else
    _test_fail "resolve unknown: stderr says unknown provider" "got: ${stderr_output}"
fi

# 2g. resolve_provider_context clears stale diagnostic state (not-implemented provider)
set_preflight_error "credential_invalid" "supabase" "stale detail from prior check"
assert_eq "stale diagnostic pre-check" "credential_invalid" "$PREFLIGHT_ERROR_CODE"
resolve_provider_context "github" 2>/dev/null
rc=$?
assert_return "resolve github after stale diagnostic returns 1" "1" "$rc"
assert_empty "stale PREFLIGHT_ERROR_CODE cleared" "$PREFLIGHT_ERROR_CODE"
assert_empty "stale PREFLIGHT_ERROR_PROVIDER cleared" "$PREFLIGHT_ERROR_PROVIDER"
assert_empty "stale PREFLIGHT_ERROR_DETAIL cleared" "$PREFLIGHT_ERROR_DETAIL"

# 2h. resolve_provider_context clears stale diagnostic state (unknown provider)
set_preflight_error "scope_not_found" "github" "stale detail"
assert_eq "stale diagnostic pre-check (unknown)" "scope_not_found" "$PREFLIGHT_ERROR_CODE"
resolve_provider_context "nonexistent" 2>/dev/null
rc=$?
assert_return "resolve unknown after stale diagnostic returns 1" "1" "$rc"
assert_empty "stale code cleared by unknown provider" "$PREFLIGHT_ERROR_CODE"
assert_empty "stale provider cleared by unknown provider" "$PREFLIGHT_ERROR_PROVIDER"
assert_empty "stale detail cleared by unknown provider" "$PREFLIGHT_ERROR_DETAIL"

echo ""

# ════════════════════════════════════════════════════════════════════════════
# Section 3: Provider-call seam
# ════════════════════════════════════════════════════════════════════════════
echo "── Provider-call seam ──"

# 3a. Verify seam functions are replaceable
_provider_vercel_api() {
    cat "${FIXTURE_DIR}/vercel/actor-valid.json"
    printf "\n200"
}
output=$(_provider_vercel_api GET /v2/user)
_split_provider_response "$output"

if echo "$_RESP_BODY" | jq -e '.user.username == "test-user"' &>/dev/null; then
    _test_pass "vercel seam returns fixture data"
else
    _test_fail "vercel seam returns fixture data" "unexpected body: $_RESP_BODY"
fi
assert_eq "vercel seam returns fixture http code" "200" "$_RESP_CODE"

# 3b. Transport failure via seam
_provider_github_api() { return 1; }
_provider_github_api /user 2>/dev/null
rc=$?
assert_return "github seam transport failure" "1" "$rc"

# 3c. Supabase seam
_provider_supabase_api() {
    cat "${FIXTURE_DIR}/supabase/profile-valid.json"
    printf "\n200"
}
output=$(_provider_supabase_api GET /v1/profile)
_split_provider_response "$output"
if echo "$_RESP_BODY" | jq -e '.username == "test-user"' &>/dev/null; then
    _test_pass "supabase seam returns fixture data"
else
    _test_fail "supabase seam returns fixture data" "unexpected body"
fi

_reset_provider_stubs

echo ""

# ════════════════════════════════════════════════════════════════════════════
# Section 4: Legacy function compatibility
# ════════════════════════════════════════════════════════════════════════════
echo "── Legacy function compatibility ──"

# Verify all 4 legacy public functions still exist and are callable.
# We don't test their network behavior (that's unchanged) — just that
# sourcing preflight-lib.sh still defines them.

if declare -f validate_vercel_token &>/dev/null; then
    _test_pass "validate_vercel_token is defined"
else
    _test_fail "validate_vercel_token is defined" "function not found"
fi

if declare -f print_vercel_token_help &>/dev/null; then
    _test_pass "print_vercel_token_help is defined"
else
    _test_fail "print_vercel_token_help is defined" "function not found"
fi

if declare -f validate_github_api &>/dev/null; then
    _test_pass "validate_github_api is defined"
else
    _test_fail "validate_github_api is defined" "function not found"
fi

if declare -f validate_supabase_token &>/dev/null; then
    _test_pass "validate_supabase_token is defined"
else
    _test_fail "validate_supabase_token is defined" "function not found"
fi

# Verify legacy functions still set their expected variables.
# credential_missing path (no network needed).
unset VERCEL_TOKEN 2>/dev/null || true
validate_vercel_token
rc=$?
assert_return "legacy validate_vercel_token returns 1 when unset" "1" "$rc"
assert_eq "legacy VERCEL_VALIDATE_ERROR" "not_set" "$VERCEL_VALIDATE_ERROR"

unset SUPABASE_ACCESS_TOKEN 2>/dev/null || true
validate_supabase_token
rc=$?
assert_return "legacy validate_supabase_token returns 1 when unset" "1" "$rc"
assert_eq "legacy SUPABASE_VALIDATE_ERROR" "not_set" "$SUPABASE_VALIDATE_ERROR"

echo ""

# ════════════════════════════════════════════════════════════════════════════
# Section 5: Config sourcing
# ════════════════════════════════════════════════════════════════════════════
echo "── Config sourcing ──"

# Verify canonical IDs are available from provider-scopes.sh
if [[ -n "${LAB_GITHUB_ORG_ID:-}" ]]; then
    _test_pass "LAB_GITHUB_ORG_ID sourced from config"
else
    _test_fail "LAB_GITHUB_ORG_ID sourced from config" "not set"
fi

if [[ -n "${LAB_VERCEL_TEAM_ID:-}" ]]; then
    _test_pass "LAB_VERCEL_TEAM_ID sourced from config"
else
    _test_fail "LAB_VERCEL_TEAM_ID sourced from config" "not set"
fi

if [[ -n "${LAB_SUPABASE_ORG_ID:-}" ]]; then
    _test_pass "LAB_SUPABASE_ORG_ID sourced from config"
else
    _test_fail "LAB_SUPABASE_ORG_ID sourced from config" "not set"
fi

echo ""

# ════════════════════════════════════════════════════════════════════════════
# Section 6: Vercel resolver (WP2)
# ════════════════════════════════════════════════════════════════════════════
echo "── Vercel resolver ──"

# Helper: configure seam stubs for Vercel resolver tests.
# Uses global variables because bash 3.2 doesn't have closures.
_VSTUB_USER_FIXTURE=""
_VSTUB_USER_HTTP=""
_VSTUB_TEAM_FIXTURE=""
_VSTUB_TEAM_HTTP=""

_setup_vercel_stubs() {
    _VSTUB_USER_FIXTURE="$1"
    _VSTUB_USER_HTTP="$2"
    _VSTUB_TEAM_FIXTURE="$3"
    _VSTUB_TEAM_HTTP="$4"

    _provider_vercel_api() {
        local method="$1"
        local path="$2"
        case "$path" in
            /v2/user)
                cat "$_VSTUB_USER_FIXTURE"
                printf "\n${_VSTUB_USER_HTTP}"
                ;;
            /v2/teams/*)
                cat "$_VSTUB_TEAM_FIXTURE"
                printf "\n${_VSTUB_TEAM_HTTP}"
                ;;
            *)
                echo '{"error":"unexpected path"}'
                printf "\n500"
                ;;
        esac
    }
}

# Save canonical config — tests may unset/override these
_SAVE_VERCEL_TEAM_ID="${LAB_VERCEL_TEAM_ID:-}"
_SAVE_VERCEL_TEAM_SLUG="${LAB_VERCEL_TEAM_SLUG:-}"

# Set test slug to match fixture data (all test fixtures use slug "test-team")
LAB_VERCEL_TEAM_SLUG="test-team"

# -- 6a. credential_missing (VERCEL_TOKEN unset)
unset VERCEL_TOKEN 2>/dev/null || true
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: credential_missing returns 1" "1" "$rc"
assert_eq "vercel: credential_missing code" "credential_missing" "$PREFLIGHT_ERROR_CODE"
assert_unset "vercel: credential_missing no partial CTX" "VERCEL_CTX_PROVIDER"

# Set a dummy token for remaining tests
export VERCEL_TOKEN="test-token-for-fixture-tests"

# -- 6b. credential_invalid (invalidToken=true)
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/invalid-token.json" "403" \
    "${FIXTURE_DIR}/vercel/team-valid.json" "200"
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: credential_invalid returns 1" "1" "$rc"
assert_eq "vercel: credential_invalid code" "credential_invalid" "$PREFLIGHT_ERROR_CODE"
assert_unset "vercel: credential_invalid no partial CTX" "VERCEL_CTX_PROVIDER"

# -- 6c. credential_invalid (401)
_provider_vercel_api() {
    local path="$2"
    case "$path" in
        /v2/user) echo '{"error":{"code":"unauthorized"}}'; printf "\n401" ;;
        *) echo '{}'; printf "\n200" ;;
    esac
}
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: 401 returns 1" "1" "$rc"
assert_eq "vercel: 401 code" "credential_invalid" "$PREFLIGHT_ERROR_CODE"

# -- 6d. credential_invalid (bare 403 without invalidToken)
_provider_vercel_api() {
    local path="$2"
    case "$path" in
        /v2/user) echo '{"error":{"code":"forbidden","message":"Not authorized"}}'; printf "\n403" ;;
        *) echo '{}'; printf "\n200" ;;
    esac
}
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: bare 403 returns 1" "1" "$rc"
assert_eq "vercel: bare 403 code" "credential_invalid" "$PREFLIGHT_ERROR_CODE"
# Verify detail preserves the bare-403 assumption
if echo "$PREFLIGHT_ERROR_DETAIL" | grep -q "architectural assumption"; then
    _test_pass "vercel: bare 403 detail notes assumption"
else
    _test_fail "vercel: bare 403 detail notes assumption" "got: ${PREFLIGHT_ERROR_DETAIL}"
fi

# -- 6e. provider_unavailable (5xx)
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/server-error.json" "500" \
    "${FIXTURE_DIR}/vercel/team-valid.json" "200"
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: 5xx returns 1" "1" "$rc"
assert_eq "vercel: 5xx code" "provider_unavailable" "$PREFLIGHT_ERROR_CODE"

# -- 6f. response_invalid (non-JSON from /v2/user)
_provider_vercel_api() {
    local path="$2"
    case "$path" in
        /v2/user) echo '<html>Bad Gateway</html>'; printf "\n200" ;;
        *) echo '{}'; printf "\n200" ;;
    esac
}
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: non-JSON returns 1" "1" "$rc"
assert_eq "vercel: non-JSON code" "response_invalid" "$PREFLIGHT_ERROR_CODE"

# -- 6g. actor_unresolved (user.id null)
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/actor-no-identity.json" "200" \
    "${FIXTURE_DIR}/vercel/team-valid.json" "200"
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: actor_unresolved returns 1" "1" "$rc"
assert_eq "vercel: actor_unresolved code" "actor_unresolved" "$PREFLIGHT_ERROR_CODE"

# -- 6h. scope_config_missing
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/actor-valid.json" "200" \
    "${FIXTURE_DIR}/vercel/team-valid.json" "200"
unset LAB_VERCEL_TEAM_ID 2>/dev/null || true
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: scope_config_missing returns 1" "1" "$rc"
assert_eq "vercel: scope_config_missing code" "scope_config_missing" "$PREFLIGHT_ERROR_CODE"
# Restore config (keep test slug, not real slug)
LAB_VERCEL_TEAM_ID="$_SAVE_VERCEL_TEAM_ID"
LAB_VERCEL_TEAM_SLUG="test-team"

# -- 6i. scope_not_found (404)
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/actor-valid.json" "200" \
    "${FIXTURE_DIR}/vercel/team-not-found.json" "404"
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: scope_not_found returns 1" "1" "$rc"
assert_eq "vercel: scope_not_found code" "scope_not_found" "$PREFLIGHT_ERROR_CODE"

# -- 6j. scope_access_denied (403 on teams)
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/actor-valid.json" "200" \
    "${FIXTURE_DIR}/vercel/team-access-denied.json" "403"
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: scope_access_denied returns 1" "1" "$rc"
assert_eq "vercel: scope_access_denied code" "scope_access_denied" "$PREFLIGHT_ERROR_CODE"

# -- 6k. scope_access_denied (membership absent)
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/actor-valid.json" "200" \
    "${FIXTURE_DIR}/vercel/team-no-membership.json" "200"
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: no membership returns 1" "1" "$rc"
assert_eq "vercel: no membership code" "scope_access_denied" "$PREFLIGHT_ERROR_CODE"

# -- 6l. scope_identity_mismatch (wrong slug)
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/actor-valid.json" "200" \
    "${FIXTURE_DIR}/vercel/team-wrong-slug.json" "200"
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: scope_identity_mismatch returns 1" "1" "$rc"
assert_eq "vercel: scope_identity_mismatch code" "scope_identity_mismatch" "$PREFLIGHT_ERROR_CODE"

# -- 6m. OWNER + project_create => success (happy path)
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/actor-valid.json" "200" \
    "${FIXTURE_DIR}/vercel/team-owner-no-permissions.json" "200"
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: OWNER happy path returns 0" "0" "$rc"
assert_eq "vercel: OWNER CTX_PROVIDER" "vercel" "${VERCEL_CTX_PROVIDER:-}"
assert_eq "vercel: OWNER CTX_ACTOR_ID" "usr_abc123" "${VERCEL_CTX_ACTOR_ID:-}"
assert_eq "vercel: OWNER CTX_ACTOR_NAME" "test-user" "${VERCEL_CTX_ACTOR_NAME:-}"
assert_eq "vercel: OWNER CTX_SCOPE_ID" "team_test123" "${VERCEL_CTX_SCOPE_ID:-}"
assert_eq "vercel: OWNER CTX_SCOPE_SLUG" "test-team" "${VERCEL_CTX_SCOPE_SLUG:-}"
assert_not_empty "vercel: OWNER CTX_PERMISSION" "${VERCEL_CTX_PERMISSION:-}"
assert_not_empty "vercel: OWNER CTX_RESOLUTION_SOURCE" "${VERCEL_CTX_RESOLUTION_SOURCE:-}"
# Verify CTX_PERMISSION records role evidence, not lifecycle claim
if echo "${VERCEL_CTX_PERMISSION:-}" | grep -q "role:OWNER"; then
    _test_pass "vercel: OWNER permission records role evidence"
else
    _test_fail "vercel: OWNER permission records role evidence" "got: ${VERCEL_CTX_PERMISSION:-}"
fi

# -- 6n. MEMBER + project_create => success
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/actor-valid.json" "200" \
    "${FIXTURE_DIR}/vercel/team-member-no-permissions.json" "200"
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: MEMBER happy path returns 0" "0" "$rc"
assert_eq "vercel: MEMBER CTX_PROVIDER" "vercel" "${VERCEL_CTX_PROVIDER:-}"
if echo "${VERCEL_CTX_PERMISSION:-}" | grep -q "role:MEMBER"; then
    _test_pass "vercel: MEMBER permission records role evidence"
else
    _test_fail "vercel: MEMBER permission records role evidence" "got: ${VERCEL_CTX_PERMISSION:-}"
fi

# -- 6o. DEVELOPER + CreateProject => success
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/actor-valid.json" "200" \
    "${FIXTURE_DIR}/vercel/team-developer-with-create-project.json" "200"
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: DEVELOPER+CreateProject returns 0" "0" "$rc"
assert_eq "vercel: DEVELOPER+CreateProject CTX_PROVIDER" "vercel" "${VERCEL_CTX_PROVIDER:-}"
if echo "${VERCEL_CTX_PERMISSION:-}" | grep -q "role:DEVELOPER" && echo "${VERCEL_CTX_PERMISSION:-}" | grep -q "CreateProject"; then
    _test_pass "vercel: DEVELOPER permission records role+permissions evidence"
else
    _test_fail "vercel: DEVELOPER permission records role+permissions evidence" "got: ${VERCEL_CTX_PERMISSION:-}"
fi

# -- 6p. DEVELOPER without CreateProject => permission_insufficient
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/actor-valid.json" "200" \
    "${FIXTURE_DIR}/vercel/team-developer-no-create-project.json" "200"
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: DEVELOPER no CreateProject returns 1" "1" "$rc"
assert_eq "vercel: DEVELOPER no CreateProject code" "permission_insufficient" "$PREFLIGHT_ERROR_CODE"
assert_unset "vercel: DEVELOPER no CreateProject no partial CTX" "VERCEL_CTX_PROVIDER"

# -- 6q. DEVELOPER without teamPermissions field => permission_insufficient
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/actor-valid.json" "200" \
    "${FIXTURE_DIR}/vercel/team-developer-no-permissions-field.json" "200"
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: DEVELOPER no permissions field returns 1" "1" "$rc"
assert_eq "vercel: DEVELOPER no permissions field code" "permission_insufficient" "$PREFLIGHT_ERROR_CODE"

# -- 6r. VIEWER => permission_insufficient
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/actor-valid.json" "200" \
    "${FIXTURE_DIR}/vercel/team-viewer-role.json" "200"
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: VIEWER returns 1" "1" "$rc"
assert_eq "vercel: VIEWER code" "permission_insufficient" "$PREFLIGHT_ERROR_CODE"
assert_unset "vercel: VIEWER no partial CTX" "VERCEL_CTX_PROVIDER"

# -- 6s. Capability-specific: DEVELOPER + env_manage => production restriction
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/actor-valid.json" "200" \
    "${FIXTURE_DIR}/vercel/team-developer-with-create-project.json" "200"
_normalize_vercel_membership "$(cat "${FIXTURE_DIR}/vercel/team-developer-with-create-project.json" | jq '.membership')"
clear_preflight_error
validate_vercel_permission "env_manage"
rc=$?
assert_return "vercel: DEVELOPER+env_manage returns 1 (production restriction)" "1" "$rc"
assert_eq "vercel: DEVELOPER+env_manage code" "permission_insufficient" "$PREFLIGHT_ERROR_CODE"
if echo "$PREFLIGHT_ERROR_DETAIL" | grep -q "production environment variables"; then
    _test_pass "vercel: DEVELOPER+env_manage detail cites production restriction"
else
    _test_fail "vercel: DEVELOPER+env_manage detail cites production restriction" "got: ${PREFLIGHT_ERROR_DETAIL}"
fi

# -- 6t. Capability-specific: MEMBER + env_manage => success
_normalize_vercel_membership "$(cat "${FIXTURE_DIR}/vercel/team-member-no-permissions.json" | jq '.membership')"
clear_preflight_error
validate_vercel_permission "env_manage"
rc=$?
assert_return "vercel: MEMBER+env_manage returns 0" "0" "$rc"

# -- 6u. Capability-specific: OWNER + domain_manage => success
_normalize_vercel_membership "$(cat "${FIXTURE_DIR}/vercel/team-owner-no-permissions.json" | jq '.membership')"
clear_preflight_error
validate_vercel_permission "domain_manage"
rc=$?
assert_return "vercel: OWNER+domain_manage returns 0" "0" "$rc"

# -- 6v. Capability-specific: DEVELOPER + domain_manage => fail closed (prose-only)
_normalize_vercel_membership "$(cat "${FIXTURE_DIR}/vercel/team-developer-with-create-project.json" | jq '.membership')"
clear_preflight_error
validate_vercel_permission "domain_manage"
rc=$?
assert_return "vercel: DEVELOPER+domain_manage returns 1 (fail closed)" "1" "$rc"
assert_eq "vercel: DEVELOPER+domain_manage code" "permission_insufficient" "$PREFLIGHT_ERROR_CODE"

# -- 6w. Capability-specific: MEMBER + deployment_create => success
_normalize_vercel_membership "$(cat "${FIXTURE_DIR}/vercel/team-member-no-permissions.json" | jq '.membership')"
clear_preflight_error
validate_vercel_permission "deployment_create"
rc=$?
assert_return "vercel: MEMBER+deployment_create returns 0" "0" "$rc"

# -- 6x. Capability-specific: DEVELOPER without FullProductionDeployment => insufficient
_normalize_vercel_membership "$(cat "${FIXTURE_DIR}/vercel/team-developer-with-create-project.json" | jq '.membership')"
clear_preflight_error
validate_vercel_permission "deployment_create"
rc=$?
assert_return "vercel: DEVELOPER no FullProdDeploy returns 1" "1" "$rc"
assert_eq "vercel: DEVELOPER no FullProdDeploy code" "permission_insufficient" "$PREFLIGHT_ERROR_CODE"

# -- 6y. project_delete with unresolved policy
_normalize_vercel_membership "$(cat "${FIXTURE_DIR}/vercel/team-owner-no-permissions.json" | jq '.membership')"
clear_preflight_error
validate_vercel_permission "project_delete" 2>/dev/null
rc=$?
assert_return "vercel: project_delete returns 1 (unverified policy)" "1" "$rc"
assert_empty "vercel: project_delete no diagnostic code (not permission_insufficient)" "$PREFLIGHT_ERROR_CODE"

# -- 6z. Successful project_create must NOT imply project_delete success
_normalize_vercel_membership "$(cat "${FIXTURE_DIR}/vercel/team-owner-no-permissions.json" | jq '.membership')"
clear_preflight_error
validate_vercel_permission "project_create"
rc_create=$?
clear_preflight_error
validate_vercel_permission "project_delete" 2>/dev/null
rc_delete=$?
assert_return "vercel: project_create succeeds" "0" "$rc_create"
assert_return "vercel: project_delete still fails despite project_create success" "1" "$rc_delete"
_test_pass "vercel: project_create does not imply project_delete"

# -- 6aa. No partial context after failure
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/actor-valid.json" "200" \
    "${FIXTURE_DIR}/vercel/team-viewer-role.json" "200"
clear_preflight_error
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: failure leaves no partial CTX (rc)" "1" "$rc"
assert_unset "vercel: no partial CTX_PROVIDER after failure" "VERCEL_CTX_PROVIDER"
assert_unset "vercel: no partial CTX_ACTOR_ID after failure" "VERCEL_CTX_ACTOR_ID"
assert_unset "vercel: no partial CTX_SCOPE_ID after failure" "VERCEL_CTX_SCOPE_ID"

# -- 6bb. Stale diagnostic cleared by resolve_vercel_context
set_preflight_error "scope_not_found" "supabase" "stale from prior provider"
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/actor-valid.json" "200" \
    "${FIXTURE_DIR}/vercel/team-owner-no-permissions.json" "200"
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: stale diagnostic cleared, succeeds" "0" "$rc"
assert_empty "vercel: stale error code cleared on success" "$PREFLIGHT_ERROR_CODE"

# -- 6cc. Stale normalized membership does not survive failed resolution
# First: resolve successfully as OWNER to populate membership state
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/actor-valid.json" "200" \
    "${FIXTURE_DIR}/vercel/team-owner-no-permissions.json" "200"
resolve_vercel_context 2>/dev/null
assert_eq "vercel: stale membership setup: role populated" "OWNER" "$_VERCEL_MEMBERSHIP_ROLE"
# Now: resolve with membership absent — must clear prior OWNER evidence
_setup_vercel_stubs \
    "${FIXTURE_DIR}/vercel/actor-valid.json" "200" \
    "${FIXTURE_DIR}/vercel/team-no-membership.json" "200"
resolve_vercel_context 2>/dev/null
rc=$?
assert_return "vercel: stale membership: fails" "1" "$rc"
assert_empty "vercel: stale membership role cleared" "$_VERCEL_MEMBERSHIP_ROLE"
assert_empty "vercel: stale membership permissions cleared" "$_VERCEL_MEMBERSHIP_PERMISSIONS"
assert_empty "vercel: stale membership roles cleared" "$_VERCEL_MEMBERSHIP_ROLES"
assert_unset "vercel: stale membership: no partial CTX_PROVIDER" "VERCEL_CTX_PROVIDER"

# -- 6dd. Stale diagnostic cleared by project_delete (unverified policy)
# Set a prior operational diagnostic
set_preflight_error "permission_insufficient" "vercel" "stale from prior capability check"
assert_eq "vercel: project_delete stale pre-check" "permission_insufficient" "$PREFLIGHT_ERROR_CODE"
# Call project_delete — must clear stale state
_normalize_vercel_membership "$(cat "${FIXTURE_DIR}/vercel/team-owner-no-permissions.json" | jq '.membership')"
validate_vercel_permission "project_delete" 2>/dev/null
rc=$?
assert_return "vercel: project_delete returns 1 (unverified)" "1" "$rc"
assert_empty "vercel: project_delete clears stale PREFLIGHT_ERROR_CODE" "$PREFLIGHT_ERROR_CODE"
assert_empty "vercel: project_delete clears stale PREFLIGHT_ERROR_PROVIDER" "$PREFLIGHT_ERROR_PROVIDER"
assert_empty "vercel: project_delete clears stale PREFLIGHT_ERROR_DETAIL" "$PREFLIGHT_ERROR_DETAIL"

# -- 6ee. domain_manage for DEVELOPER fails closed (prose-only evidence)
_normalize_vercel_membership "$(cat "${FIXTURE_DIR}/vercel/team-developer-with-create-project.json" | jq '.membership')"
clear_preflight_error
validate_vercel_permission "domain_manage"
rc=$?
assert_return "vercel: DEVELOPER+domain_manage returns 1 (fail closed)" "1" "$rc"
assert_eq "vercel: DEVELOPER+domain_manage code" "permission_insufficient" "$PREFLIGHT_ERROR_CODE"
if echo "$PREFLIGHT_ERROR_DETAIL" | grep -q "prose only"; then
    _test_pass "vercel: DEVELOPER+domain_manage detail cites prose-only evidence"
else
    _test_fail "vercel: DEVELOPER+domain_manage detail cites prose-only evidence" "got: ${PREFLIGHT_ERROR_DETAIL}"
fi

# Restore config
LAB_VERCEL_TEAM_ID="$_SAVE_VERCEL_TEAM_ID"
LAB_VERCEL_TEAM_SLUG="$_SAVE_VERCEL_TEAM_SLUG"
unset VERCEL_TOKEN 2>/dev/null || true
_reset_provider_stubs

echo ""

# ════════════════════════════════════════════════════════════════════════════
# Section 7: Static safety checks
# ════════════════════════════════════════════════════════════════════════════
echo "── Static safety checks ──"

# Static provider-call seam enforcement.
#
# Method: name-based, not position-based. Uses `declare -f` to extract
# each function body (bash-native, handles nesting). Enumerates all
# functions defined in preflight-lib.sh, subtracts the explicitly allowed
# set, then checks each remaining function for raw provider invocations.
#
# Allowed raw-invocation locations (explicit names):
#   Seam wrappers:  _provider_github_api, _provider_vercel_api,
#                   _provider_vercel_cli, _provider_supabase_api
#   Legacy compat:  validate_vercel_token, print_vercel_token_help,
#                   validate_github_api, validate_supabase_token
#
# Decision: "Static enforcement is based on explicit allowed legacy/seam
# function names, not source-file position."

# Functions allowed to contain raw provider calls
ALLOWED_RAW=(
    _provider_github_api
    _provider_vercel_api
    _provider_vercel_cli
    _provider_supabase_api
    validate_vercel_token
    print_vercel_token_help
    validate_github_api
    validate_supabase_token
)

# Get all function names defined after sourcing preflight-lib.sh.
# Filter to functions that are actually defined in the lib (not builtins,
# not test helpers from this file). We use grep on the source file.
ALL_LIB_FUNCTIONS=$(grep -oE '^[a-zA-Z_][a-zA-Z_0-9]*\(\)' "$LIB_PATH" | sed 's/()//' | sort -u)

CHECKED_COUNT=0
SEAM_VIOLATIONS=""

for fn in $ALL_LIB_FUNCTIONS; do
    # Skip allowed functions
    skip=false
    for allowed in "${ALLOWED_RAW[@]}"; do
        if [[ "$fn" == "$allowed" ]]; then
            skip=true
            break
        fi
    done
    if $skip; then continue; fi

    # Extract function body via declare -f (bash-native, nesting-safe)
    fn_body=$(declare -f "$fn" 2>/dev/null) || continue
    CHECKED_COUNT=$((CHECKED_COUNT + 1))

    # Check for raw provider invocations (skip comment lines)
    violations=""
    raw_curl=$(echo "$fn_body" | grep -v '^ *#' | grep '\bcurl\b' || true)
    raw_gh=$(echo "$fn_body" | grep -v '^ *#' | grep '\bgh api\b\|\bgh repo\b' || true)
    raw_vercel_cli=$(echo "$fn_body" | grep -v '^ *#' | grep '\bvercel \b' || true)
    raw_supabase_cli=$(echo "$fn_body" | grep -v '^ *#' | grep '\bsupabase \b' || true)

    if [[ -n "$raw_curl" ]]; then violations="${violations}curl "; fi
    if [[ -n "$raw_gh" ]]; then violations="${violations}gh "; fi
    if [[ -n "$raw_vercel_cli" ]]; then violations="${violations}vercel "; fi
    if [[ -n "$raw_supabase_cli" ]]; then violations="${violations}supabase "; fi

    if [[ -n "$violations" ]]; then
        SEAM_VIOLATIONS="${SEAM_VIOLATIONS}${fn}(${violations%% }) "
    fi
done

if [[ $CHECKED_COUNT -eq 0 ]]; then
    _test_fail "seam check: functions inspected" "no non-allowed functions found — check cannot verify anything"
else
    _test_pass "seam check: inspected ${CHECKED_COUNT} non-allowed functions"
fi

if [[ -z "$SEAM_VIOLATIONS" ]]; then
    _test_pass "seam check: no raw provider calls outside allowed functions"
else
    _test_fail "seam check: no raw provider calls outside allowed functions" "violations: ${SEAM_VIOLATIONS}"
fi

# Verify provider-scopes.sh contains no credentials
if grep -qE '(Bearer|vcp_|ghp_|gho_|github_pat_|sk-|password)' "${SCRIPT_DIR}/../config/provider-scopes.sh" 2>/dev/null; then
    _test_fail "provider-scopes.sh has no credentials" "possible credential found"
else
    _test_pass "provider-scopes.sh has no credentials"
fi

# Verify legacy functions remain defined
for fn in validate_vercel_token print_vercel_token_help validate_github_api validate_supabase_token; do
    if declare -f "$fn" &>/dev/null; then
        _test_pass "legacy function ${fn} still defined"
    else
        _test_fail "legacy function ${fn} still defined" "not found after sourcing"
    fi
done

echo ""

# ════════════════════════════════════════════════════════════════════════════
# Summary
# ════════════════════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════"
echo "  Results: ${TESTS_PASSED} passed, ${TESTS_FAILED} failed, ${TESTS_RUN} total"
echo "══════════════════════════════════════════════════════"

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo ""
    echo "Failures:"
    echo -e "$FAILURES"
    echo ""
    exit 1
fi

echo ""
echo "All tests passed."
exit 0
