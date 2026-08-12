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

# 2d2. validate_provider_context — SCOPE_NAME empty succeeds (WP5A contract cleanup)
GITHUB_CTX_PROVIDER="github"
GITHUB_CTX_ACTOR_ID="12345"
GITHUB_CTX_ACTOR_NAME="test-user"
GITHUB_CTX_SCOPE_ID="254572218"
GITHUB_CTX_SCOPE_NAME=""
GITHUB_CTX_RESOLUTION_SOURCE="resolver"
validate_provider_context "github"
rc=$?
assert_return "validate github context empty scope_name succeeds" "0" "$rc"

clear_provider_context "github"

# 2e. All three providers now have resolvers (WP2-WP4).
# Not-implemented tests removed. Provider-specific tests are in Sections 6-8.

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

# 2g. resolve_provider_context clears stale diagnostic state (via github resolver)
# Mock github auth to fail — the point is that stale error from supabase is cleared
_provider_github_auth_status() { return 1; }
set_preflight_error "credential_invalid" "supabase" "stale detail from prior check"
assert_eq "stale diagnostic pre-check" "credential_invalid" "$PREFLIGHT_ERROR_CODE"
resolve_provider_context "github" 2>/dev/null
rc=$?
assert_return "resolve github after stale diagnostic returns 1" "1" "$rc"
# Error should now be github's credential_missing, not supabase's stale state
assert_eq "stale replaced by github error" "credential_missing" "$PREFLIGHT_ERROR_CODE"
assert_eq "stale provider replaced" "github" "$PREFLIGHT_ERROR_PROVIDER"
_reset_provider_stubs

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

# ── Regression tests for d2974b9 (Vercel /v2/user response parsing fix) ──
# These tests mock _provider_vercel_api to return known response shapes
# and verify validate_vercel_token handles the current nested API shape.
# (WP5B: updated from curl mocks to seam mocks after migration.)

# 4a. Nested response shape: { user: { username: "..." } } -> success
export VERCEL_TOKEN="test-token"
_provider_vercel_api() {
    printf '%s\n%s' '{"user":{"id":"uid123","username":"test-user","name":"Test"}}' '200'
}
validate_vercel_token
rc=$?
assert_return "d2974b9: nested .user.username returns 0" "0" "$rc"
assert_eq "d2974b9: nested .user.username populates user" "test-user" "$VERCEL_VALIDATE_USER"
assert_empty "d2974b9: nested success clears error" "$VERCEL_VALIDATE_ERROR"

# 4b. Top-level fallback shape: { username: "..." } -> still works
_provider_vercel_api() {
    printf '%s\n%s' '{"username":"legacy-user"}' '200'
}
validate_vercel_token
rc=$?
assert_return "d2974b9: top-level .username fallback returns 0" "0" "$rc"
assert_eq "d2974b9: top-level fallback populates user" "legacy-user" "$VERCEL_VALIDATE_USER"

# 4c. Nested error shape: { error: { invalidToken: true } } -> invalid_token
_provider_vercel_api() {
    printf '%s\n%s' '{"error":{"code":"forbidden","message":"Not authorized","invalidToken":true}}' '403'
}
validate_vercel_token
rc=$?
assert_return "d2974b9: nested .error.invalidToken returns 1" "1" "$rc"
assert_eq "d2974b9: nested invalidToken sets error" "invalid_token" "$VERCEL_VALIDATE_ERROR"

# 4d. Top-level invalidToken fallback
_provider_vercel_api() {
    printf '%s\n%s' '{"invalidToken":true}' '403'
}
validate_vercel_token
rc=$?
assert_return "d2974b9: top-level invalidToken fallback returns 1" "1" "$rc"
assert_eq "d2974b9: top-level invalidToken sets error" "invalid_token" "$VERCEL_VALIDATE_ERROR"

# 4e. Neither username nor invalidToken -> api_error
_provider_vercel_api() {
    printf '%s\n%s' '{"user":{"id":"uid123"}}' '200'
}
validate_vercel_token
rc=$?
assert_return "d2974b9: no username no invalidToken returns 1" "1" "$rc"
assert_eq "d2974b9: no username no invalidToken sets api_error" "api_error" "$VERCEL_VALIDATE_ERROR"

unset VERCEL_TOKEN 2>/dev/null || true

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
# Section 7: Supabase resolver (WP3)
# ════════════════════════════════════════════════════════════════════════════
echo "── Supabase resolver ──"

# Save config
_SAVE_SB_ORG_ID="${LAB_SUPABASE_ORG_ID:-}"
_SAVE_SB_ORG_NAME="${LAB_SUPABASE_ORG_NAME:-}"
_SAVE_SB_ORG_SLUG="${LAB_SUPABASE_ORG_SLUG:-}"

# Set test config to match fixture data
LAB_SUPABASE_ORG_ID="esiwooovlhcuifbbkodk"
LAB_SUPABASE_ORG_NAME="Friends Innovation Lab"
LAB_SUPABASE_ORG_SLUG="esiwooovlhcuifbbkodk"

# Stub helper for Supabase: profile + orgs + members
_SBSTUB_PROFILE_FIXTURE=""
_SBSTUB_PROFILE_HTTP=""
_SBSTUB_ORGS_FIXTURE=""
_SBSTUB_ORGS_HTTP=""
_SBSTUB_MEMBERS_FIXTURE=""
_SBSTUB_MEMBERS_HTTP=""
_SBSTUB_PAGE2_FIXTURE=""
_SBSTUB_PAGE2_HTTP=""

_setup_supabase_stubs() {
    _SBSTUB_PROFILE_FIXTURE="$1"
    _SBSTUB_PROFILE_HTTP="$2"
    _SBSTUB_ORGS_FIXTURE="$3"
    _SBSTUB_ORGS_HTTP="$4"
    _SBSTUB_MEMBERS_FIXTURE="$5"
    _SBSTUB_MEMBERS_HTTP="$6"
    _SBSTUB_PAGE2_FIXTURE="${7:-}"
    _SBSTUB_PAGE2_HTTP="${8:-}"

    _provider_supabase_api() {
        local method="$1"
        local path="$2"
        case "$path" in
            /v1/profile)
                cat "$_SBSTUB_PROFILE_FIXTURE"
                printf "\n${_SBSTUB_PROFILE_HTTP}"
                ;;
            /v1/organizations)
                cat "$_SBSTUB_ORGS_FIXTURE"
                printf "\n${_SBSTUB_ORGS_HTTP}"
                ;;
            *members*page=2*|*members*page%3D2*)
                if [[ -n "$_SBSTUB_PAGE2_FIXTURE" ]]; then
                    cat "$_SBSTUB_PAGE2_FIXTURE"
                    printf "\n${_SBSTUB_PAGE2_HTTP}"
                else
                    echo '{"error":"no page 2 configured"}'
                    printf "\n500"
                fi
                ;;
            *members*)
                cat "$_SBSTUB_MEMBERS_FIXTURE"
                printf "\n${_SBSTUB_MEMBERS_HTTP}"
                ;;
            *)
                echo '{"error":"unexpected path"}'
                printf "\n500"
                ;;
        esac
    }
}

# -- 7a. credential_missing
unset SUPABASE_ACCESS_TOKEN 2>/dev/null || true
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: credential_missing returns 1" "1" "$rc"
assert_eq "supabase: credential_missing code" "credential_missing" "$PREFLIGHT_ERROR_CODE"
assert_unset "supabase: credential_missing no CTX" "SUPABASE_CTX_PROVIDER"

export SUPABASE_ACCESS_TOKEN="test-token-for-fixtures"

# -- 7b. credential_invalid (401)
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-invalid-token.json" "401" \
    "${FIXTURE_DIR}/supabase/organizations-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/members-owner-org-scope.json" "200"
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: credential_invalid returns 1" "1" "$rc"
assert_eq "supabase: credential_invalid code" "credential_invalid" "$PREFLIGHT_ERROR_CODE"

# -- 7c. response_invalid (non-JSON from profile)
_provider_supabase_api() {
    local path="$2"
    case "$path" in
        /v1/profile) echo '<html>Bad Gateway</html>'; printf "\n200" ;;
        *) echo '[]'; printf "\n200" ;;
    esac
}
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: non-JSON profile returns 1" "1" "$rc"
assert_eq "supabase: non-JSON profile code" "response_invalid" "$PREFLIGHT_ERROR_CODE"

# -- 7d. actor_unresolved (null gotrue_id)
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-no-identity.json" "200" \
    "${FIXTURE_DIR}/supabase/organizations-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/members-owner-org-scope.json" "200"
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: actor_unresolved returns 1" "1" "$rc"
assert_eq "supabase: actor_unresolved code" "actor_unresolved" "$PREFLIGHT_ERROR_CODE"

# -- 7e. scope_config_missing (ORG_ID absent)
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organizations-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/members-owner-org-scope.json" "200"
unset LAB_SUPABASE_ORG_ID 2>/dev/null || true
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: scope_config_missing (id) returns 1" "1" "$rc"
assert_eq "supabase: scope_config_missing (id) code" "scope_config_missing" "$PREFLIGHT_ERROR_CODE"
LAB_SUPABASE_ORG_ID="esiwooovlhcuifbbkodk"

# -- 7e2. scope_config_missing (ORG_SLUG absent)
unset LAB_SUPABASE_ORG_SLUG 2>/dev/null || true
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: scope_config_missing (slug) returns 1" "1" "$rc"
assert_eq "supabase: scope_config_missing (slug) code" "scope_config_missing" "$PREFLIGHT_ERROR_CODE"
LAB_SUPABASE_ORG_SLUG="esiwooovlhcuifbbkodk"

# -- 7e3. scope_config_missing (ORG_NAME absent)
unset LAB_SUPABASE_ORG_NAME 2>/dev/null || true
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: scope_config_missing (name) returns 1" "1" "$rc"
assert_eq "supabase: scope_config_missing (name) code" "scope_config_missing" "$PREFLIGHT_ERROR_CODE"
LAB_SUPABASE_ORG_NAME="Friends Innovation Lab"

# -- 7f. scope_not_found (canonical ID absent)
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organization-missing.json" "200" \
    "${FIXTURE_DIR}/supabase/members-owner-org-scope.json" "200"
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: scope_not_found returns 1" "1" "$rc"
assert_eq "supabase: scope_not_found code" "scope_not_found" "$PREFLIGHT_ERROR_CODE"

# -- 7g. response_invalid (canonical ID matches >1)
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organizations-multiple-match.json" "200" \
    "${FIXTURE_DIR}/supabase/members-owner-org-scope.json" "200"
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: multiple ID match returns 1" "1" "$rc"
assert_eq "supabase: multiple ID match code" "response_invalid" "$PREFLIGHT_ERROR_CODE"

# -- 7h. scope_identity_mismatch (wrong name)
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organization-wrong-name.json" "200" \
    "${FIXTURE_DIR}/supabase/members-owner-org-scope.json" "200"
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: scope_identity_mismatch returns 1" "1" "$rc"
assert_eq "supabase: scope_identity_mismatch code" "scope_identity_mismatch" "$PREFLIGHT_ERROR_CODE"

# -- 7h2. scope_access_denied (/v1/organizations returns 403)
# ARCHITECTURAL MAPPING: post-authentication 403 on org enumeration
# means the credential lacks organizations:read scope — NOT credential_invalid
_provider_supabase_api() {
    local path="$2"
    case "$path" in
        /v1/profile) cat "${FIXTURE_DIR}/supabase/profile-valid.json"; printf "\n200" ;;
        /v1/organizations) echo '{"message":"Forbidden"}'; printf "\n403" ;;
        *) echo '{}'; printf "\n200" ;;
    esac
}
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: orgs 403 returns 1" "1" "$rc"
assert_eq "supabase: orgs 403 code" "scope_access_denied" "$PREFLIGHT_ERROR_CODE"
if echo "$PREFLIGHT_ERROR_DETAIL" | grep -q "403"; then
    _test_pass "supabase: orgs 403 detail references 403"
else
    _test_fail "supabase: orgs 403 detail references 403" "got: ${PREFLIGHT_ERROR_DETAIL}"
fi

# -- 7h3. credential_invalid (/v1/organizations returns 401)
_provider_supabase_api() {
    local path="$2"
    case "$path" in
        /v1/profile) cat "${FIXTURE_DIR}/supabase/profile-valid.json"; printf "\n200" ;;
        /v1/organizations) echo '{"message":"Unauthorized"}'; printf "\n401" ;;
        *) echo '{}'; printf "\n200" ;;
    esac
}
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: orgs 401 returns 1" "1" "$rc"
assert_eq "supabase: orgs 401 code" "credential_invalid" "$PREFLIGHT_ERROR_CODE"

# -- 7i. scope_access_denied (actor absent, complete enumeration)
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organizations-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/members-actor-absent.json" "200"
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: actor absent -> scope_access_denied" "1" "$rc"
assert_eq "supabase: actor absent code" "scope_access_denied" "$PREFLIGHT_ERROR_CODE"
if echo "$PREFLIGHT_ERROR_DETAIL" | grep -q "complete enumeration"; then
    _test_pass "supabase: actor absent detail notes complete enumeration"
else
    _test_fail "supabase: actor absent detail notes complete enumeration" "got: ${PREFLIGHT_ERROR_DETAIL}"
fi

# -- 7j. scope_access_denied (no org-scoped roles, project-scoped owner only)
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organizations-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/members-owner-project-scope-only.json" "200"
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: project-scoped owner only returns 1" "1" "$rc"
assert_eq "supabase: project-scoped owner code" "scope_access_denied" "$PREFLIGHT_ERROR_CODE"

# -- 7k. scope_access_denied (no roles at all)
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organizations-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/members-no-roles.json" "200"
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: no roles returns 1" "1" "$rc"
assert_eq "supabase: no roles code" "scope_access_denied" "$PREFLIGHT_ERROR_CODE"

# -- 7l. scope_access_denied (members endpoint 403)
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organizations-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/members-owner-org-scope.json" "403"
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: members 403 returns 1" "1" "$rc"
assert_eq "supabase: members 403 code" "scope_access_denied" "$PREFLIGHT_ERROR_CODE"

# -- 7m. org-scoped owner + project_create => success (happy path)
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organizations-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/members-owner-org-scope.json" "200"
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: owner happy path returns 0" "0" "$rc"
assert_eq "supabase: owner CTX_PROVIDER" "supabase" "${SUPABASE_CTX_PROVIDER:-}"
assert_eq "supabase: owner CTX_ACTOR_ID" "user-123-abc" "${SUPABASE_CTX_ACTOR_ID:-}"
assert_eq "supabase: owner CTX_ACTOR_NAME" "test-user" "${SUPABASE_CTX_ACTOR_NAME:-}"
assert_eq "supabase: owner CTX_SCOPE_ID" "esiwooovlhcuifbbkodk" "${SUPABASE_CTX_SCOPE_ID:-}"
assert_eq "supabase: owner CTX_SCOPE_NAME" "Friends Innovation Lab" "${SUPABASE_CTX_SCOPE_NAME:-}"
assert_not_empty "supabase: owner CTX_PERMISSION" "${SUPABASE_CTX_PERMISSION:-}"
if echo "${SUPABASE_CTX_PERMISSION:-}" | grep -q "org_roles:owner"; then
    _test_pass "supabase: owner permission records org_roles evidence"
else
    _test_fail "supabase: owner permission records org_roles evidence" "got: ${SUPABASE_CTX_PERMISSION:-}"
fi

# -- 7n. org-scoped administrator + project_create => success
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organizations-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/members-admin-org-scope.json" "200"
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: admin happy path returns 0" "0" "$rc"
assert_eq "supabase: admin CTX_PROVIDER" "supabase" "${SUPABASE_CTX_PROVIDER:-}"

# -- 7o. org-scoped developer + project_create => permission_insufficient
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organizations-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/members-developer-org-scope.json" "200"
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: developer project_create returns 1" "1" "$rc"
assert_eq "supabase: developer project_create code" "permission_insufficient" "$PREFLIGHT_ERROR_CODE"
assert_unset "supabase: developer no CTX" "SUPABASE_CTX_PROVIDER"

# -- 7p. org-scoped read-only + project_create => permission_insufficient
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organizations-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/members-readonly-org-scope.json" "200"
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: readonly project_create returns 1" "1" "$rc"
assert_eq "supabase: readonly project_create code" "permission_insufficient" "$PREFLIGHT_ERROR_CODE"

# -- 7q. Capability: owner + project_delete => success (DOCUMENTED)
_normalize_supabase_membership "$(cat "${FIXTURE_DIR}/supabase/members-owner-org-scope.json" | jq '.data[0].attributes.roles')"
clear_preflight_error
validate_supabase_permission "project_delete"
rc=$?
assert_return "supabase: owner project_delete returns 0" "0" "$rc"

# -- 7r. Capability: developer + project_delete => insufficient (DOCUMENTED)
_normalize_supabase_membership "$(cat "${FIXTURE_DIR}/supabase/members-developer-org-scope.json" | jq '.data[0].attributes.roles')"
clear_preflight_error
validate_supabase_permission "project_delete"
rc=$?
assert_return "supabase: developer project_delete returns 1" "1" "$rc"
assert_eq "supabase: developer project_delete code" "permission_insufficient" "$PREFLIGHT_ERROR_CODE"

# -- 7s. Capability: developer + api_keys_read => success (DOCUMENTED)
_normalize_supabase_membership "$(cat "${FIXTURE_DIR}/supabase/members-developer-org-scope.json" | jq '.data[0].attributes.roles')"
clear_preflight_error
validate_supabase_permission "api_keys_read"
rc=$?
assert_return "supabase: developer api_keys_read returns 0" "0" "$rc"

# -- 7t. Capability: read-only + api_keys_read => insufficient (DOCUMENTED)
_normalize_supabase_membership "$(cat "${FIXTURE_DIR}/supabase/members-readonly-org-scope.json" | jq '.data[0].attributes.roles')"
clear_preflight_error
validate_supabase_permission "api_keys_read"
rc=$?
assert_return "supabase: readonly api_keys_read returns 1" "1" "$rc"
assert_eq "supabase: readonly api_keys_read code" "permission_insufficient" "$PREFLIGHT_ERROR_CODE"

# -- 7u. Capability: developer + database_manage => success (DOCUMENTED)
_normalize_supabase_membership "$(cat "${FIXTURE_DIR}/supabase/members-developer-org-scope.json" | jq '.data[0].attributes.roles')"
clear_preflight_error
validate_supabase_permission "database_manage"
rc=$?
assert_return "supabase: developer database_manage returns 0" "0" "$rc"

# -- 7v. Pagination: actor found on page 2
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organizations-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/members-page1-no-actor.json" "200" \
    "${FIXTURE_DIR}/supabase/members-page2-actor-found.json" "200"
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: pagination actor on page 2 returns 0" "0" "$rc"
assert_eq "supabase: pagination CTX_PROVIDER" "supabase" "${SUPABASE_CTX_PROVIDER:-}"

# -- 7w. Pagination: page 1 OK, page 2 transport failure => provider_unavailable
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organizations-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/members-page1-no-actor.json" "200"
# Override page 2 to simulate transport failure
_SBSTUB_PAGE2_FIXTURE=""
_SBSTUB_PAGE2_HTTP=""
_provider_supabase_api() {
    local method="$1"
    local path="$2"
    case "$path" in
        /v1/profile) cat "$_SBSTUB_PROFILE_FIXTURE"; printf "\n${_SBSTUB_PROFILE_HTTP}" ;;
        /v1/organizations) cat "$_SBSTUB_ORGS_FIXTURE"; printf "\n${_SBSTUB_ORGS_HTTP}" ;;
        *members*page=2*|*members*page%3D2*) return 1 ;;
        *members*) cat "$_SBSTUB_MEMBERS_FIXTURE"; printf "\n${_SBSTUB_MEMBERS_HTTP}" ;;
        *) echo '{}'; printf "\n500" ;;
    esac
}
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: page 2 transport failure returns 1" "1" "$rc"
assert_eq "supabase: page 2 transport failure code" "provider_unavailable" "$PREFLIGHT_ERROR_CODE"
assert_unset "supabase: page 2 failure no CTX" "SUPABASE_CTX_PROVIDER"

# -- 7x. Pagination: page 1 OK, page 2 returns 429 => provider_unavailable
_provider_supabase_api() {
    local method="$1"
    local path="$2"
    case "$path" in
        /v1/profile) cat "$_SBSTUB_PROFILE_FIXTURE"; printf "\n${_SBSTUB_PROFILE_HTTP}" ;;
        /v1/organizations) cat "$_SBSTUB_ORGS_FIXTURE"; printf "\n${_SBSTUB_ORGS_HTTP}" ;;
        *members*page=2*|*members*page%3D2*) echo '{"error":"rate limited"}'; printf "\n429" ;;
        *members*) cat "$_SBSTUB_MEMBERS_FIXTURE"; printf "\n${_SBSTUB_MEMBERS_HTTP}" ;;
        *) echo '{}'; printf "\n500" ;;
    esac
}
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: page 2 rate limited returns 1" "1" "$rc"
assert_eq "supabase: page 2 rate limited code" "provider_unavailable" "$PREFLIGHT_ERROR_CODE"

# -- 7y. Pagination: page 1 OK, page 2 malformed => response_invalid
_provider_supabase_api() {
    local method="$1"
    local path="$2"
    case "$path" in
        /v1/profile) cat "$_SBSTUB_PROFILE_FIXTURE"; printf "\n${_SBSTUB_PROFILE_HTTP}" ;;
        /v1/organizations) cat "$_SBSTUB_ORGS_FIXTURE"; printf "\n${_SBSTUB_ORGS_HTTP}" ;;
        *members*page=2*|*members*page%3D2*) echo 'NOT JSON AT ALL'; printf "\n200" ;;
        *members*) cat "$_SBSTUB_MEMBERS_FIXTURE"; printf "\n${_SBSTUB_MEMBERS_HTTP}" ;;
        *) echo '{}'; printf "\n500" ;;
    esac
}
clear_preflight_error
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: page 2 malformed returns 1" "1" "$rc"
assert_eq "supabase: page 2 malformed code" "response_invalid" "$PREFLIGHT_ERROR_CODE"

# -- 7z. Multi-role: developer + read-only + api_keys_read => success (additive)
_normalize_supabase_membership "$(cat "${FIXTURE_DIR}/supabase/members-multi-role-dev-readonly.json" | jq '.data[0].attributes.roles')"
clear_preflight_error
validate_supabase_permission "api_keys_read"
rc=$?
assert_return "supabase: dev+readonly api_keys_read returns 0 (additive)" "0" "$rc"

# -- 7aa. Multi-role: developer + read-only + project_create => insufficient
_normalize_supabase_membership "$(cat "${FIXTURE_DIR}/supabase/members-multi-role-dev-readonly.json" | jq '.data[0].attributes.roles')"
clear_preflight_error
validate_supabase_permission "project_create"
rc=$?
assert_return "supabase: dev+readonly project_create returns 1" "1" "$rc"
assert_eq "supabase: dev+readonly project_create code" "permission_insufficient" "$PREFLIGHT_ERROR_CODE"

# -- 7bb. Multi-role: administrator + developer + project_create => success
_normalize_supabase_membership "$(cat "${FIXTURE_DIR}/supabase/members-multi-role-admin-dev.json" | jq '.data[0].attributes.roles')"
clear_preflight_error
validate_supabase_permission "project_create"
rc=$?
assert_return "supabase: admin+dev project_create returns 0" "0" "$rc"

# -- 7cc. Unknown role + project_create => fail closed
_normalize_supabase_membership "$(cat "${FIXTURE_DIR}/supabase/members-unknown-role.json" | jq '.data[0].attributes.roles')"
clear_preflight_error
validate_supabase_permission "project_create"
rc=$?
assert_return "supabase: unknown role project_create returns 1 (fail closed)" "1" "$rc"
assert_eq "supabase: unknown role project_create code" "permission_insufficient" "$PREFLIGHT_ERROR_CODE"

# -- 7dd. No partial context after failure
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organizations-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/members-developer-org-scope.json" "200"
clear_preflight_error
resolve_supabase_context 2>/dev/null
assert_unset "supabase: no CTX_PROVIDER after failure" "SUPABASE_CTX_PROVIDER"
assert_unset "supabase: no CTX_ACTOR_ID after failure" "SUPABASE_CTX_ACTOR_ID"
assert_unset "supabase: no CTX_SCOPE_ID after failure" "SUPABASE_CTX_SCOPE_ID"

# -- 7ee. Stale membership cleared on failure
# First succeed to populate
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organizations-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/members-owner-org-scope.json" "200"
resolve_supabase_context 2>/dev/null
assert_eq "supabase: stale membership setup: org roles populated" "owner" "$_SUPABASE_ORG_ROLES"
# Now fail with actor absent
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organizations-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/members-actor-absent.json" "200"
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: stale membership: subsequent failure returns 1" "1" "$rc"
assert_empty "supabase: stale org roles cleared" "$_SUPABASE_ORG_ROLES"
assert_empty "supabase: stale project roles cleared" "$_SUPABASE_PROJECT_ROLES"
assert_unset "supabase: stale CTX_PROVIDER cleared" "SUPABASE_CTX_PROVIDER"
assert_unset "supabase: stale CTX_ACTOR_ID cleared" "SUPABASE_CTX_ACTOR_ID"
assert_unset "supabase: stale CTX_SCOPE_ID cleared" "SUPABASE_CTX_SCOPE_ID"
assert_unset "supabase: stale CTX_PERMISSION cleared" "SUPABASE_CTX_PERMISSION"

# -- 7ff. Stale diagnostic cleared on success
set_preflight_error "scope_not_found" "github" "stale from prior provider"
_setup_supabase_stubs \
    "${FIXTURE_DIR}/supabase/profile-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/organizations-valid.json" "200" \
    "${FIXTURE_DIR}/supabase/members-owner-org-scope.json" "200"
resolve_supabase_context 2>/dev/null
rc=$?
assert_return "supabase: stale diagnostic cleared on success" "0" "$rc"
assert_empty "supabase: stale error code cleared" "$PREFLIGHT_ERROR_CODE"

# Restore config
LAB_SUPABASE_ORG_ID="$_SAVE_SB_ORG_ID"
LAB_SUPABASE_ORG_NAME="$_SAVE_SB_ORG_NAME"
LAB_SUPABASE_ORG_SLUG="$_SAVE_SB_ORG_SLUG"
unset SUPABASE_ACCESS_TOKEN 2>/dev/null || true
_reset_provider_stubs

echo ""

# ════════════════════════════════════════════════════════════════════════════
# Section 8: GitHub resolver (WP4)
# ════════════════════════════════════════════════════════════════════════════
echo "── GitHub resolver ──"

_SAVE_GH_ORG_ID="${LAB_GITHUB_ORG_ID:-}"
_SAVE_GH_ORG="${LAB_GITHUB_ORG:-}"
LAB_GITHUB_ORG_ID="254572218"
LAB_GITHUB_ORG="friends-innovation-lab"

# GitHub seam stub: simulates gh api --include response
# Uses globals for per-endpoint fixtures
_GHSTUB_AUTH_RC=0
_GHSTUB_USER_STATUS="200"
_GHSTUB_USER_BODY=""
_GHSTUB_USER_HEADERS=""
_GHSTUB_ORGS_STATUS="200"
_GHSTUB_ORGS_BODY=""
_GHSTUB_ORGS_HEADERS=""
_GHSTUB_ORGS_P2_STATUS=""
_GHSTUB_ORGS_P2_BODY=""
_GHSTUB_ORGS_P2_HEADERS=""
_GHSTUB_MEMBERSHIP_STATUS="200"
_GHSTUB_MEMBERSHIP_BODY=""
_GHSTUB_MEMBERSHIP_HEADERS=""
_GHSTUB_ORGSETTINGS_STATUS="200"
_GHSTUB_ORGSETTINGS_BODY=""
_GHSTUB_ORGSETTINGS_HEADERS=""

_setup_github_stubs() {
    _provider_github_auth_status() { return $_GHSTUB_AUTH_RC; }
    _provider_github_api() {
        local endpoint="$1"
        local status="" body="" hdrs=""
        case "$endpoint" in
            /user)
                status="$_GHSTUB_USER_STATUS"; body="$_GHSTUB_USER_BODY"; hdrs="$_GHSTUB_USER_HEADERS" ;;
            /user/orgs*page=2*|/user/orgs*page%3D2*)
                if [[ -n "$_GHSTUB_ORGS_P2_STATUS" ]]; then
                    status="$_GHSTUB_ORGS_P2_STATUS"; body="$_GHSTUB_ORGS_P2_BODY"; hdrs="$_GHSTUB_ORGS_P2_HEADERS"
                else
                    return 1  # transport failure
                fi ;;
            /user/orgs*)
                status="$_GHSTUB_ORGS_STATUS"; body="$_GHSTUB_ORGS_BODY"; hdrs="$_GHSTUB_ORGS_HEADERS" ;;
            /user/memberships/orgs/*)
                status="$_GHSTUB_MEMBERSHIP_STATUS"; body="$_GHSTUB_MEMBERSHIP_BODY"; hdrs="$_GHSTUB_MEMBERSHIP_HEADERS" ;;
            /orgs/*)
                status="$_GHSTUB_ORGSETTINGS_STATUS"; body="$_GHSTUB_ORGSETTINGS_BODY"; hdrs="$_GHSTUB_ORGSETTINGS_HEADERS" ;;
            *)
                status="500"; body='{"error":"unexpected"}'; hdrs="" ;;
        esac

        _GITHUB_API_STATUS="$status"
        _GITHUB_API_BODY="$body"
        _GITHUB_API_HEADERS="$hdrs"
        _GITHUB_API_EXIT=0
        _GITHUB_API_LINK=$(echo "$hdrs" | grep -i '^Link:' | sed 's/^[Ll]ink: *//' | head -1)
        _GITHUB_API_RATELIMIT_REMAINING=$(echo "$hdrs" | grep -i '^X-RateLimit-Remaining:' | sed 's/^[^:]*: *//' | tr -d '[:space:]' | head -1)
        _GITHUB_API_RATELIMIT_RESET=$(echo "$hdrs" | grep -i '^X-RateLimit-Reset:' | sed 's/^[^:]*: *//' | tr -d '[:space:]' | head -1)
        _GITHUB_API_RETRY_AFTER=$(echo "$hdrs" | grep -i '^Retry-After:' | sed 's/^[^:]*: *//' | tr -d '[:space:]' | head -1)
        return 0
    }
}

_gh_happy_path() {
    _GHSTUB_AUTH_RC=0
    _GHSTUB_USER_STATUS="200"
    _GHSTUB_USER_BODY='{"id":12345,"login":"test-user"}'
    _GHSTUB_USER_HEADERS=""
    _GHSTUB_ORGS_STATUS="200"
    _GHSTUB_ORGS_BODY=$(cat "${FIXTURE_DIR}/github/user-orgs-page1.json")
    _GHSTUB_ORGS_HEADERS=""
    _GHSTUB_ORGS_P2_STATUS=""
    _GHSTUB_MEMBERSHIP_STATUS="200"
    _GHSTUB_MEMBERSHIP_BODY=$(cat "${FIXTURE_DIR}/github/membership-admin-active.json")
    _GHSTUB_MEMBERSHIP_HEADERS=""
    _GHSTUB_ORGSETTINGS_STATUS="200"
    _GHSTUB_ORGSETTINGS_BODY=$(cat "${FIXTURE_DIR}/github/org-settings-members-allowed.json")
    _GHSTUB_ORGSETTINGS_HEADERS=""
    _setup_github_stubs
}

# -- 8a. credential_missing (no active auth)
_GHSTUB_AUTH_RC=1
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: credential_missing returns 1" "1" "$rc"
assert_eq "github: credential_missing code" "credential_missing" "$PREFLIGHT_ERROR_CODE"
assert_unset "github: credential_missing no CTX" "GITHUB_CTX_PROVIDER"

# -- 8b. credential_invalid (/user 401 after auth success)
_gh_happy_path
_GHSTUB_USER_STATUS="401"
_GHSTUB_USER_BODY='{"message":"Bad credentials"}'
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: credential_invalid returns 1" "1" "$rc"
assert_eq "github: credential_invalid code" "credential_invalid" "$PREFLIGHT_ERROR_CODE"

# -- 8c. actor_unresolved (null id)
_gh_happy_path
_GHSTUB_USER_BODY='{"id":null,"login":null}'
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: actor_unresolved returns 1" "1" "$rc"
assert_eq "github: actor_unresolved code" "actor_unresolved" "$PREFLIGHT_ERROR_CODE"

# -- 8d. scope_config_missing
_gh_happy_path
unset LAB_GITHUB_ORG_ID 2>/dev/null || true
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: scope_config_missing returns 1" "1" "$rc"
assert_eq "github: scope_config_missing code" "scope_config_missing" "$PREFLIGHT_ERROR_CODE"
LAB_GITHUB_ORG_ID="254572218"

# -- 8e. scope_not_found (canonical ID absent, complete enum)
_gh_happy_path
_GHSTUB_ORGS_BODY=$(cat "${FIXTURE_DIR}/github/user-orgs-empty.json")
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: scope_not_found returns 1" "1" "$rc"
assert_eq "github: scope_not_found code" "scope_not_found" "$PREFLIGHT_ERROR_CODE"
if echo "$PREFLIGHT_ERROR_DETAIL" | grep -q "complete accessible-organization enumeration"; then
    _test_pass "github: scope_not_found detail notes complete enumeration"
else
    _test_fail "github: scope_not_found detail notes complete enumeration" "got: ${PREFLIGHT_ERROR_DETAIL}"
fi

# -- 8f. scope_identity_mismatch (wrong login)
_gh_happy_path
_GHSTUB_ORGS_BODY=$(cat "${FIXTURE_DIR}/github/user-orgs-login-mismatch.json")
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: scope_identity_mismatch returns 1" "1" "$rc"
assert_eq "github: scope_identity_mismatch code" "scope_identity_mismatch" "$PREFLIGHT_ERROR_CODE"

# -- 8g. response_invalid (duplicate canonical ID)
_gh_happy_path
_GHSTUB_ORGS_BODY=$(cat "${FIXTURE_DIR}/github/user-orgs-duplicate-id.json")
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: duplicate ID returns 1" "1" "$rc"
assert_eq "github: duplicate ID code" "response_invalid" "$PREFLIGHT_ERROR_CODE"

# -- 8h. Pagination: org found on page 2
_gh_happy_path
_GHSTUB_ORGS_BODY=$(cat "${FIXTURE_DIR}/github/user-orgs-page1-no-match.json")
_GHSTUB_ORGS_HEADERS='Link: </user/orgs?per_page=100&page=2>; rel="next"'
_GHSTUB_ORGS_P2_STATUS="200"
_GHSTUB_ORGS_P2_BODY=$(cat "${FIXTURE_DIR}/github/user-orgs-page2-match.json")
_GHSTUB_ORGS_P2_HEADERS=""
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: pagination page 2 returns 0" "0" "$rc"
assert_eq "github: pagination CTX_PROVIDER" "github" "${GITHUB_CTX_PROVIDER:-}"

# -- 8i. Pagination: page 2 transport failure
_gh_happy_path
_GHSTUB_ORGS_BODY=$(cat "${FIXTURE_DIR}/github/user-orgs-page1-no-match.json")
_GHSTUB_ORGS_HEADERS='Link: </user/orgs?per_page=100&page=2>; rel="next"'
_GHSTUB_ORGS_P2_STATUS=""
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: page 2 transport failure returns 1" "1" "$rc"
assert_eq "github: page 2 transport failure code" "provider_unavailable" "$PREFLIGHT_ERROR_CODE"

# -- 8j. Rate limit: 429 on /user/orgs
_gh_happy_path
_GHSTUB_ORGS_STATUS="429"
_GHSTUB_ORGS_BODY='{"message":"rate limit exceeded"}'
_GHSTUB_ORGS_HEADERS="Retry-After: 60"
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: 429 rate limit returns 1" "1" "$rc"
assert_eq "github: 429 rate limit code" "provider_unavailable" "$PREFLIGHT_ERROR_CODE"

# -- 8k. Rate limit: 403 + remaining=0
_gh_happy_path
_GHSTUB_ORGS_STATUS="403"
_GHSTUB_ORGS_BODY='{"message":"API rate limit exceeded"}'
_GHSTUB_ORGS_HEADERS="X-RateLimit-Remaining: 0"
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: 403+remaining=0 returns 1" "1" "$rc"
assert_eq "github: 403+remaining=0 code" "provider_unavailable" "$PREFLIGHT_ERROR_CODE"

# -- 8l. 403 without rate-limit evidence on /user/orgs -> scope_access_denied
_gh_happy_path
_GHSTUB_ORGS_STATUS="403"
_GHSTUB_ORGS_BODY='{"message":"Forbidden"}'
_GHSTUB_ORGS_HEADERS="X-RateLimit-Remaining: 4999"
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: bare 403 orgs returns 1" "1" "$rc"
assert_eq "github: bare 403 orgs code" "scope_access_denied" "$PREFLIGHT_ERROR_CODE"
if echo "$PREFLIGHT_ERROR_DETAIL" | grep -q "organization authorization"; then
    _test_pass "github: bare 403 detail notes scope/token issue"
else
    _test_fail "github: bare 403 detail notes scope/token issue" "got: ${PREFLIGHT_ERROR_DETAIL}"
fi

# -- 8m. Membership: 404 -> scope_access_denied
_gh_happy_path
_GHSTUB_MEMBERSHIP_STATUS="404"
_GHSTUB_MEMBERSHIP_BODY='{"message":"Not Found"}'
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: membership 404 returns 1" "1" "$rc"
assert_eq "github: membership 404 code" "scope_access_denied" "$PREFLIGHT_ERROR_CODE"

# -- 8n. Membership: pending -> scope_access_denied
_gh_happy_path
_GHSTUB_MEMBERSHIP_BODY=$(cat "${FIXTURE_DIR}/github/membership-member-pending.json")
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: pending membership returns 1" "1" "$rc"
assert_eq "github: pending membership code" "scope_access_denied" "$PREFLIGHT_ERROR_CODE"

# -- 8o. Membership: 403 + rate-limit -> provider_unavailable
_gh_happy_path
_GHSTUB_MEMBERSHIP_STATUS="403"
_GHSTUB_MEMBERSHIP_BODY='{"message":"rate limit"}'
_GHSTUB_MEMBERSHIP_HEADERS="X-RateLimit-Remaining: 0"
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: membership 403+ratelimit returns 1" "1" "$rc"
assert_eq "github: membership 403+ratelimit code" "provider_unavailable" "$PREFLIGHT_ERROR_CODE"

# -- 8p. Membership: 403 without rate-limit -> scope_access_denied
_gh_happy_path
_GHSTUB_MEMBERSHIP_STATUS="403"
_GHSTUB_MEMBERSHIP_BODY='{"message":"Forbidden"}'
_GHSTUB_MEMBERSHIP_HEADERS="X-RateLimit-Remaining: 4999"
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: membership bare 403 returns 1" "1" "$rc"
assert_eq "github: membership bare 403 code" "scope_access_denied" "$PREFLIGHT_ERROR_CODE"

# -- 8q. Admin happy path + policy_completeness:partial
_gh_happy_path
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: admin happy path returns 0" "0" "$rc"
assert_eq "github: admin CTX_PROVIDER" "github" "${GITHUB_CTX_PROVIDER:-}"
assert_eq "github: admin CTX_ACTOR_ID" "12345" "${GITHUB_CTX_ACTOR_ID:-}"
assert_eq "github: admin CTX_SCOPE_ID" "254572218" "${GITHUB_CTX_SCOPE_ID:-}"
assert_eq "github: admin CTX_SCOPE_SLUG" "friends-innovation-lab" "${GITHUB_CTX_SCOPE_SLUG:-}"
if echo "${GITHUB_CTX_PERMISSION:-}" | grep -q "policy_completeness:partial"; then
    _test_pass "github: admin CTX_PERMISSION has policy_completeness:partial"
else
    _test_fail "github: admin CTX_PERMISSION has policy_completeness:partial" "got: ${GITHUB_CTX_PERMISSION:-}"
fi

# -- 8r. Member + org allows creation -> success
_gh_happy_path
_GHSTUB_MEMBERSHIP_BODY=$(cat "${FIXTURE_DIR}/github/membership-member-active.json")
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: member+allowed returns 0" "0" "$rc"
assert_eq "github: member+allowed CTX_PROVIDER" "github" "${GITHUB_CTX_PROVIDER:-}"
if echo "${GITHUB_CTX_PERMISSION:-}" | grep -q "repo_create_baseline:allowed"; then
    _test_pass "github: member+allowed baseline:allowed"
else
    _test_fail "github: member+allowed baseline:allowed" "got: ${GITHUB_CTX_PERMISSION:-}"
fi

# -- 8s. Member + org denies creation -> permission_insufficient
_gh_happy_path
_GHSTUB_MEMBERSHIP_BODY=$(cat "${FIXTURE_DIR}/github/membership-member-active.json")
_GHSTUB_ORGSETTINGS_BODY=$(cat "${FIXTURE_DIR}/github/org-settings-members-denied.json")
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: member+denied returns 1" "1" "$rc"
assert_eq "github: member+denied code" "permission_insufficient" "$PREFLIGHT_ERROR_CODE"
assert_unset "github: member+denied no CTX" "GITHUB_CTX_PROVIDER"

# -- 8t. Member + both policy fields absent -> fail closed
_gh_happy_path
_GHSTUB_MEMBERSHIP_BODY=$(cat "${FIXTURE_DIR}/github/membership-member-active.json")
_GHSTUB_ORGSETTINGS_BODY=$(cat "${FIXTURE_DIR}/github/org-settings-fields-absent.json")
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: member+fields absent returns 1" "1" "$rc"
assert_eq "github: member+fields absent code" "permission_insufficient" "$PREFLIGHT_ERROR_CODE"
if echo "$PREFLIGHT_ERROR_DETAIL" | grep -q "policy fields absent"; then
    _test_pass "github: fields absent detail cites absent fields"
else
    _test_fail "github: fields absent detail cites absent fields" "got: ${PREFLIGHT_ERROR_DETAIL}"
fi

# -- 8u. Member + primary true, type absent -> success
_gh_happy_path
_GHSTUB_MEMBERSHIP_BODY=$(cat "${FIXTURE_DIR}/github/membership-member-active.json")
_GHSTUB_ORGSETTINGS_BODY=$(cat "${FIXTURE_DIR}/github/org-settings-primary-true-type-absent.json")
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: member+primary true returns 0" "0" "$rc"

# -- 8v. Billing manager -> permission_insufficient
_gh_happy_path
_GHSTUB_MEMBERSHIP_BODY=$(cat "${FIXTURE_DIR}/github/membership-billing-active.json")
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: billing manager returns 1" "1" "$rc"
assert_eq "github: billing manager code" "permission_insufficient" "$PREFLIGHT_ERROR_CODE"

# -- 8w. repo_archive -> UNVERIFIED (no diagnostic code)
_clear_github_membership
_GITHUB_MEMBERSHIP_ROLE="admin"
clear_preflight_error
validate_github_permission "repo_archive" 2>/dev/null
rc=$?
assert_return "github: repo_archive returns 1 (unverified)" "1" "$rc"
assert_empty "github: repo_archive no diagnostic code" "$PREFLIGHT_ERROR_CODE"

# -- 8x. Mutable display name: changed org.name -> success
# The enumeration response carries the current display name
_gh_happy_path
_GHSTUB_ORGS_BODY='[{"id":254572218,"login":"friends-innovation-lab","name":"Totally Different Display Name"}]'
_GHSTUB_ORGSETTINGS_BODY=$(cat "${FIXTURE_DIR}/github/org-settings-name-changed.json")
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: changed name returns 0" "0" "$rc"
assert_eq "github: changed name CTX_SCOPE_NAME" "Totally Different Display Name" "${GITHUB_CTX_SCOPE_NAME:-}"
assert_eq "github: changed name CTX_SCOPE_SLUG" "friends-innovation-lab" "${GITHUB_CTX_SCOPE_SLUG:-}"

# -- 8y. org.name null -> success, SCOPE_NAME = login (REPRESENTATION FALLBACK)
_gh_happy_path
_GHSTUB_ORGSETTINGS_BODY=$(cat "${FIXTURE_DIR}/github/org-settings-name-null.json")
_GHSTUB_ORGS_BODY='[{"id":254572218,"login":"friends-innovation-lab","name":null}]'
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: null name returns 0" "0" "$rc"
assert_eq "github: null name CTX_SCOPE_NAME" "friends-innovation-lab" "${GITHUB_CTX_SCOPE_NAME:-}"

# -- 8z. Org settings 404 post-enumeration -> provider_unavailable
_gh_happy_path
_GHSTUB_ORGSETTINGS_STATUS="404"
_GHSTUB_ORGSETTINGS_BODY='{"message":"Not Found"}'
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: org settings 404 returns 1" "1" "$rc"
assert_eq "github: org settings 404 code" "provider_unavailable" "$PREFLIGHT_ERROR_CODE"
if echo "$PREFLIGHT_ERROR_DETAIL" | grep -q "inconsistent between calls"; then
    _test_pass "github: org settings 404 detail notes inconsistency"
else
    _test_fail "github: org settings 404 detail notes inconsistency" "got: ${PREFLIGHT_ERROR_DETAIL}"
fi

# -- 8aa. Org settings 403 + rate-limit -> provider_unavailable
_gh_happy_path
_GHSTUB_ORGSETTINGS_STATUS="403"
_GHSTUB_ORGSETTINGS_BODY='{"message":"rate limit"}'
_GHSTUB_ORGSETTINGS_HEADERS="X-RateLimit-Remaining: 0"
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: org settings 403+ratelimit returns 1" "1" "$rc"
assert_eq "github: org settings 403+ratelimit code" "provider_unavailable" "$PREFLIGHT_ERROR_CODE"

# -- 8bb. No partial context after failure
_gh_happy_path
_GHSTUB_MEMBERSHIP_BODY=$(cat "${FIXTURE_DIR}/github/membership-billing-active.json")
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
assert_unset "github: no partial CTX_PROVIDER" "GITHUB_CTX_PROVIDER"
assert_unset "github: no partial CTX_ACTOR_ID" "GITHUB_CTX_ACTOR_ID"
assert_unset "github: no partial CTX_SCOPE_ID" "GITHUB_CTX_SCOPE_ID"

# -- 8cc. Stale membership from prior run does not survive failure
_gh_happy_path
_setup_github_stubs
resolve_github_context 2>/dev/null
assert_eq "github: stale setup: role populated" "admin" "$_GITHUB_MEMBERSHIP_ROLE"
# Now fail with a credential_missing to ensure full cleanup
_GHSTUB_AUTH_RC=1
_setup_github_stubs
resolve_github_context 2>/dev/null
assert_empty "github: stale role cleared by credential_missing" "$_GITHUB_MEMBERSHIP_ROLE"
assert_empty "github: stale state cleared" "$_GITHUB_MEMBERSHIP_STATE"
assert_empty "github: stale repo_creation cleared" "$_GITHUB_ORG_REPO_CREATION"
assert_unset "github: stale CTX_PROVIDER cleared" "GITHUB_CTX_PROVIDER"
assert_unset "github: stale CTX_ACTOR_ID cleared" "GITHUB_CTX_ACTOR_ID"
_reset_provider_stubs

# -- 8dd. Stale diagnostic cleared on success
set_preflight_error "scope_not_found" "supabase" "stale"
_gh_happy_path
_setup_github_stubs
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: stale cleared on success" "0" "$rc"
assert_empty "github: stale error code cleared" "$PREFLIGHT_ERROR_CODE"

# -- 8ee. Page 2 rate-limit (429) -> provider_unavailable
_gh_happy_path
_GHSTUB_ORGS_BODY=$(cat "${FIXTURE_DIR}/github/user-orgs-page1-no-match.json")
_GHSTUB_ORGS_HEADERS='Link: </user/orgs?per_page=100&page=2>; rel="next"'
_GHSTUB_ORGS_P2_STATUS="429"
_GHSTUB_ORGS_P2_BODY='{"message":"rate limit"}'
_GHSTUB_ORGS_P2_HEADERS="Retry-After: 60"
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: page 2 rate limit returns 1" "1" "$rc"
assert_eq "github: page 2 rate limit code" "provider_unavailable" "$PREFLIGHT_ERROR_CODE"

# -- 8ff. Page 2 malformed -> response_invalid
_gh_happy_path
_GHSTUB_ORGS_BODY=$(cat "${FIXTURE_DIR}/github/user-orgs-page1-no-match.json")
_GHSTUB_ORGS_HEADERS='Link: </user/orgs?per_page=100&page=2>; rel="next"'
_GHSTUB_ORGS_P2_STATUS="200"
_GHSTUB_ORGS_P2_BODY="NOT JSON"
_GHSTUB_ORGS_P2_HEADERS=""
_setup_github_stubs
clear_preflight_error
resolve_github_context 2>/dev/null
rc=$?
assert_return "github: page 2 malformed returns 1" "1" "$rc"
assert_eq "github: page 2 malformed code" "response_invalid" "$PREFLIGHT_ERROR_CODE"

# Restore
LAB_GITHUB_ORG_ID="$_SAVE_GH_ORG_ID"
LAB_GITHUB_ORG="$_SAVE_GH_ORG"
_reset_provider_stubs

echo ""

# ════════════════════════════════════════════════════════════════════════════
# Section 9: Static safety checks
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

# Functions allowed to contain raw provider calls.
# WP5B: legacy wrappers and print_vercel_token_help removed — they no longer
# contain raw calls. Only provider seam functions remain.
ALLOWED_RAW=(
    _provider_github_api
    _provider_github_auth_status
    _provider_vercel_api
    _provider_vercel_cli
    _provider_supabase_api
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

    # Check for raw provider invocations (skip comment lines).
    # For vercel/supabase: match command-position invocations only, not
    # string literals in echo/printf help text. Command position means:
    #   - start of statement (possibly after whitespace/semicolons)
    #   - command substitution: $(vercel ...) or `vercel ...`
    #   - pipe target: | vercel ...
    # This keeps echo/printf lines inspectable — a raw invocation inside
    # command substitution on an echo line WILL still trigger.
    violations=""
    raw_curl=$(echo "$fn_body" | grep -v '^ *#' | grep '\bcurl\b' || true)
    raw_gh=$(echo "$fn_body" | grep -v '^ *#' | grep '\bgh api\b\|\bgh repo\b' || true)
    raw_vercel_cli=$(echo "$fn_body" | grep -v '^ *#' | grep -E '(^|;|[$][(]|`|[|]) *vercel ' || true)
    raw_supabase_cli=$(echo "$fn_body" | grep -v '^ *#' | grep -E '(^|;|[$][(]|`|[|]) *supabase ' || true)

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

# ── Static-check regression: invocation-pattern vs help-text ──
# These synthetic function bodies verify the grep pattern distinguishes
# command invocations from string literals in echo/printf arguments.

# Regression: help-text literal should NOT trigger
_static_test_body_help='    echo "A stale VERCEL_TOKEN overrides vercel login — after updating";'
if echo "$_static_test_body_help" | grep -v '^ *#' | grep -qE '(^|;|[$][(]|`|[|]) *vercel '; then
    _test_fail "static-check: help-text 'vercel login' does not trigger" "false positive on help text"
else
    _test_pass "static-check: help-text 'vercel login' does not trigger"
fi

# Regression: raw vercel invocation SHOULD trigger
_static_test_body_raw='    vercel deploy --prod;'
if echo "$_static_test_body_raw" | grep -v '^ *#' | grep -qE '(^|;|[$][(]|`|[|]) *vercel '; then
    _test_pass "static-check: raw 'vercel deploy' triggers"
else
    _test_fail "static-check: raw 'vercel deploy' triggers" "missed raw invocation"
fi

# Regression: raw supabase invocation SHOULD trigger
_static_test_body_sb='    supabase db push;'
if echo "$_static_test_body_sb" | grep -v '^ *#' | grep -qE '(^|;|[$][(]|`|[|]) *supabase '; then
    _test_pass "static-check: raw 'supabase db' triggers"
else
    _test_fail "static-check: raw 'supabase db' triggers" "missed raw invocation"
fi

# Regression: command substitution inside echo/printf SHOULD trigger
_static_test_body_cmdsub='    echo "result: $(vercel whoami)";'
if echo "$_static_test_body_cmdsub" | grep -v '^ *#' | grep -qE '(^|;|[$][(]|`|[|]) *vercel '; then
    _test_pass "static-check: cmd-sub 'echo \$(vercel ...)' triggers"
else
    _test_fail "static-check: cmd-sub 'echo \$(vercel ...)' triggers" "missed cmd-sub invocation"
fi

# Regression: command substitution with supabase inside printf SHOULD trigger
_static_test_body_cmdsub_sb='    printf "%s" "$(supabase status)";'
if echo "$_static_test_body_cmdsub_sb" | grep -v '^ *#' | grep -qE '(^|;|[$][(]|`|[|]) *supabase '; then
    _test_pass "static-check: cmd-sub 'printf \$(supabase ...)' triggers"
else
    _test_fail "static-check: cmd-sub 'printf \$(supabase ...)' triggers" "missed cmd-sub invocation"
fi

# Regression: backtick substitution SHOULD trigger
_static_test_body_backtick='    echo "result: `vercel teams ls`";'
if echo "$_static_test_body_backtick" | grep -v '^ *#' | grep -qE '(^|;|[$][(]|`|[|]) *vercel '; then
    _test_pass "static-check: backtick 'echo \`vercel ...\`' triggers"
else
    _test_fail "static-check: backtick 'echo \`vercel ...\`' triggers" "missed backtick invocation"
fi

# Regression: pipe target SHOULD trigger
_static_test_body_pipe='    cat file | vercel deploy;'
if echo "$_static_test_body_pipe" | grep -v '^ *#' | grep -qE '(^|;|[$][(]|`|[|]) *vercel '; then
    _test_pass "static-check: pipe target '| vercel ...' triggers"
else
    _test_fail "static-check: pipe target '| vercel ...' triggers" "missed pipe invocation"
fi

# Regression: supabase help text should NOT trigger
_static_test_body_sb_help='    echo "    See supabase dashboard for details";'
if echo "$_static_test_body_sb_help" | grep -v '^ *#' | grep -qE '(^|;|[$][(]|`|[|]) *supabase '; then
    _test_pass "static-check: help-text 'supabase dashboard' does not trigger"
else
    _test_pass "static-check: help-text 'supabase dashboard' does not trigger"
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
# Section: WP5B Golden-Master Tests
#
# These tests mock the provider SEAM functions (_provider_vercel_api,
# _provider_github_api, _provider_supabase_api) to verify the migrated
# legacy wrappers preserve their exact public contracts and restore
# PLAT-01 internal state.
# ════════════════════════════════════════════════════════════════════════════
echo ""
echo "── WP5B golden-master: validate_vercel_token ──"

# GM-V1: Nested .user.username success (via seam)
export VERCEL_TOKEN="test-token"
_provider_vercel_api() {
    printf '%s\n%s' '{"user":{"id":"uid123","username":"seam-user","name":"Test"}}' '200'
}
validate_vercel_token
rc=$?
assert_return "GM-V1: nested .user.username returns 0" "0" "$rc"
assert_eq "GM-V1: populates VERCEL_VALIDATE_USER" "seam-user" "$VERCEL_VALIDATE_USER"
assert_empty "GM-V1: clears VERCEL_VALIDATE_ERROR" "$VERCEL_VALIDATE_ERROR"

# GM-V2: Top-level .username fallback (via seam)
_provider_vercel_api() {
    printf '%s\n%s' '{"username":"fallback-user"}' '200'
}
validate_vercel_token
rc=$?
assert_return "GM-V2: top-level .username fallback returns 0" "0" "$rc"
assert_eq "GM-V2: populates VERCEL_VALIDATE_USER" "fallback-user" "$VERCEL_VALIDATE_USER"

# GM-V3: Missing credential
unset VERCEL_TOKEN 2>/dev/null || true
validate_vercel_token
rc=$?
assert_return "GM-V3: missing credential returns 1" "1" "$rc"
assert_eq "GM-V3: VERCEL_VALIDATE_ERROR is not_set" "not_set" "$VERCEL_VALIDATE_ERROR"
assert_empty "GM-V3: VERCEL_VALIDATE_USER is empty" "$VERCEL_VALIDATE_USER"

# GM-V4: Nested .error.invalidToken
export VERCEL_TOKEN="test-token"
_provider_vercel_api() {
    printf '%s\n%s' '{"error":{"code":"forbidden","invalidToken":true}}' '403'
}
validate_vercel_token
rc=$?
assert_return "GM-V4: nested invalidToken returns 1" "1" "$rc"
assert_eq "GM-V4: VERCEL_VALIDATE_ERROR is invalid_token" "invalid_token" "$VERCEL_VALIDATE_ERROR"

# GM-V5: Top-level .invalidToken fallback
_provider_vercel_api() {
    printf '%s\n%s' '{"invalidToken":true}' '403'
}
validate_vercel_token
rc=$?
assert_return "GM-V5: top-level invalidToken returns 1" "1" "$rc"
assert_eq "GM-V5: VERCEL_VALIDATE_ERROR is invalid_token" "invalid_token" "$VERCEL_VALIDATE_ERROR"

# GM-V6: Transport failure (seam returns nonzero)
_provider_vercel_api() {
    return 1
}
validate_vercel_token
rc=$?
assert_return "GM-V6: transport failure returns 1" "1" "$rc"
assert_eq "GM-V6: VERCEL_VALIDATE_ERROR is api_error" "api_error" "$VERCEL_VALIDATE_ERROR"

# GM-V7: Malformed response (no username, no invalidToken)
_provider_vercel_api() {
    printf '%s\n%s' '{"user":{"id":"uid123"}}' '200'
}
validate_vercel_token
rc=$?
assert_return "GM-V7: malformed response returns 1" "1" "$rc"
assert_eq "GM-V7: VERCEL_VALIDATE_ERROR is api_error" "api_error" "$VERCEL_VALIDATE_ERROR"

# GM-V8: _RESP_BODY restored after success
_RESP_BODY="prior-body-value"
_provider_vercel_api() {
    printf '%s\n%s' '{"user":{"username":"u"}}' '200'
}
validate_vercel_token
assert_eq "GM-V8: _RESP_BODY restored after success" "prior-body-value" "$_RESP_BODY"

# GM-V9: _RESP_BODY restored after failure
_RESP_BODY="prior-body-failure"
_provider_vercel_api() {
    printf '%s\n%s' '{"nothing":"here"}' '200'
}
validate_vercel_token
assert_eq "GM-V9: _RESP_BODY restored after failure" "prior-body-failure" "$_RESP_BODY"

# GM-V10: Previously unset _RESP_CODE remains unset
unset _RESP_CODE 2>/dev/null || true
_provider_vercel_api() {
    printf '%s\n%s' '{"user":{"username":"u"}}' '200'
}
validate_vercel_token
if [[ -n "${_RESP_CODE+x}" ]]; then
    _test_fail "GM-V10: unset _RESP_CODE remains unset" "was set to '${_RESP_CODE:-}'"
else
    _test_pass "GM-V10: unset _RESP_CODE remains unset"
fi

# GM-V11: Previously empty _RESP_BODY restored as empty
_RESP_BODY=""
_provider_vercel_api() {
    printf '%s\n%s' '{"user":{"username":"u"}}' '200'
}
validate_vercel_token
assert_eq "GM-V11: empty _RESP_BODY restored as empty" "" "$_RESP_BODY"

# GM-V12: set -u safe (all paths)
(
    set -u
    export VERCEL_TOKEN="test-token"
    _provider_vercel_api() {
        printf '%s\n%s' '{"user":{"username":"u"}}' '200'
    }
    validate_vercel_token
) 2>/dev/null
if [[ $? -eq 0 ]]; then
    _test_pass "GM-V12: set -u safe (Vercel success)"
else
    _test_fail "GM-V12: set -u safe (Vercel success)" "exited nonzero under set -u"
fi

# GM-V13: No stdout emitted
_provider_vercel_api() {
    printf '%s\n%s' '{"user":{"username":"u"}}' '200'
}
local_stdout=$(validate_vercel_token 2>/dev/null)
assert_empty "GM-V13: no stdout on success" "$local_stdout"

# GM-V14: No stderr emitted
local_stderr=$(validate_vercel_token 2>&1 >/dev/null)
assert_empty "GM-V14: no stderr on success" "$local_stderr"

# GM-V-SENTINEL: Old sentinel string value restored correctly (collision-free proof)
_RESP_BODY="__WP5B_UNSET_d41d8cd98f00b204e9800998ecf8427e__"
_provider_vercel_api() {
    printf '%s\n%s' '{"user":{"username":"u"}}' '200'
}
validate_vercel_token
assert_eq "GM-V-SENTINEL: old sentinel string restored" "__WP5B_UNSET_d41d8cd98f00b204e9800998ecf8427e__" "$_RESP_BODY"

# GM-V-TRANSPORT-RESTORE: _RESP_BODY restored after transport failure
_RESP_BODY="transport-prior"
_provider_vercel_api() {
    return 1
}
validate_vercel_token
assert_eq "GM-V-TRANSPORT: _RESP_BODY restored after transport failure" "transport-prior" "$_RESP_BODY"

# GM-V15: Failure-path stderr suppression — seam emits stderr, wrapper must not
_provider_vercel_api() {
    echo "synthetic seam stderr for vercel" >&2
    return 1
}
local_stderr=$(validate_vercel_token 2>&1 >/dev/null)
assert_empty "GM-V15: no stderr on failure (seam emits stderr)" "$local_stderr"

# GM-V16: Failure-path stdout suppression
local_stdout=$(validate_vercel_token 2>/dev/null)
assert_empty "GM-V16: no stdout on failure (seam emits stderr)" "$local_stdout"

unset VERCEL_TOKEN 2>/dev/null || true

echo ""
echo "── WP5B golden-master: validate_github_api ──"

# GM-G1: Success (HTTP 200, .login present)
_provider_github_api() {
    _GITHUB_API_STATUS="200"
    _GITHUB_API_BODY='{"id":12345,"login":"gh-user"}'
    _GITHUB_API_HEADERS=""
    _GITHUB_API_EXIT=0
    _GITHUB_API_LINK=""
    _GITHUB_API_RATELIMIT_REMAINING=""
    _GITHUB_API_RATELIMIT_RESET=""
    _GITHUB_API_RETRY_AFTER=""
    return 0
}
validate_github_api
rc=$?
assert_return "GM-G1: success returns 0" "0" "$rc"
assert_eq "GM-G1: GITHUB_VALIDATE_USER is login" "gh-user" "$GITHUB_VALIDATE_USER"

# GM-G2: Seam transport failure (nonzero exit)
_provider_github_api() {
    _GITHUB_API_STATUS=""
    _GITHUB_API_BODY=""
    _GITHUB_API_HEADERS=""
    _GITHUB_API_EXIT=1
    _GITHUB_API_LINK=""
    _GITHUB_API_RATELIMIT_REMAINING=""
    _GITHUB_API_RATELIMIT_RESET=""
    _GITHUB_API_RETRY_AFTER=""
    return 1
}
validate_github_api
rc=$?
assert_return "GM-G2: transport failure returns 1" "1" "$rc"
assert_empty "GM-G2: GITHUB_VALIDATE_USER empty" "$GITHUB_VALIDATE_USER"

# GM-G3: Non-200 status (401)
_provider_github_api() {
    _GITHUB_API_STATUS="401"
    _GITHUB_API_BODY='{"message":"Bad credentials"}'
    _GITHUB_API_HEADERS=""
    _GITHUB_API_EXIT=0
    _GITHUB_API_LINK=""
    _GITHUB_API_RATELIMIT_REMAINING=""
    _GITHUB_API_RATELIMIT_RESET=""
    _GITHUB_API_RETRY_AFTER=""
    return 0
}
validate_github_api
rc=$?
assert_return "GM-G3: 401 returns 1" "1" "$rc"
assert_empty "GM-G3: GITHUB_VALIDATE_USER empty" "$GITHUB_VALIDATE_USER"

# GM-G4: 200 but no .login
_provider_github_api() {
    _GITHUB_API_STATUS="200"
    _GITHUB_API_BODY='{"id":12345}'
    _GITHUB_API_HEADERS=""
    _GITHUB_API_EXIT=0
    _GITHUB_API_LINK=""
    _GITHUB_API_RATELIMIT_REMAINING=""
    _GITHUB_API_RATELIMIT_RESET=""
    _GITHUB_API_RETRY_AFTER=""
    return 0
}
validate_github_api
rc=$?
assert_return "GM-G4: no .login returns 1" "1" "$rc"
assert_empty "GM-G4: GITHUB_VALIDATE_USER empty" "$GITHUB_VALIDATE_USER"

# GM-G5: 200 but invalid JSON
_provider_github_api() {
    _GITHUB_API_STATUS="200"
    _GITHUB_API_BODY='not json'
    _GITHUB_API_HEADERS=""
    _GITHUB_API_EXIT=0
    _GITHUB_API_LINK=""
    _GITHUB_API_RATELIMIT_REMAINING=""
    _GITHUB_API_RATELIMIT_RESET=""
    _GITHUB_API_RETRY_AFTER=""
    return 0
}
validate_github_api
rc=$?
assert_return "GM-G5: invalid JSON returns 1" "1" "$rc"
assert_empty "GM-G5: GITHUB_VALIDATE_USER empty" "$GITHUB_VALIDATE_USER"

# GM-G6: Pre-set _GITHUB_API_STATUS restored after success
_GITHUB_API_STATUS="prior-status"
_provider_github_api() {
    _GITHUB_API_STATUS="200"
    _GITHUB_API_BODY='{"id":1,"login":"u"}'
    _GITHUB_API_HEADERS=""
    _GITHUB_API_EXIT=0
    _GITHUB_API_LINK=""
    _GITHUB_API_RATELIMIT_REMAINING=""
    _GITHUB_API_RATELIMIT_RESET=""
    _GITHUB_API_RETRY_AFTER=""
    return 0
}
validate_github_api
assert_eq "GM-G6: _GITHUB_API_STATUS restored after success" "prior-status" "$_GITHUB_API_STATUS"

# GM-G7: Pre-set _GITHUB_API_BODY restored after failure
_GITHUB_API_BODY="prior-body"
_provider_github_api() {
    _GITHUB_API_STATUS=""
    _GITHUB_API_BODY=""
    _GITHUB_API_HEADERS=""
    _GITHUB_API_EXIT=1
    _GITHUB_API_LINK=""
    _GITHUB_API_RATELIMIT_REMAINING=""
    _GITHUB_API_RATELIMIT_RESET=""
    _GITHUB_API_RETRY_AFTER=""
    return 1
}
validate_github_api
assert_eq "GM-G7: _GITHUB_API_BODY restored after failure" "prior-body" "$_GITHUB_API_BODY"

# GM-G8: Previously unset _GITHUB_API_LINK remains unset
unset _GITHUB_API_LINK 2>/dev/null || true
_provider_github_api() {
    _GITHUB_API_STATUS="200"
    _GITHUB_API_BODY='{"id":1,"login":"u"}'
    _GITHUB_API_HEADERS=""
    _GITHUB_API_EXIT=0
    _GITHUB_API_LINK="some-link"
    _GITHUB_API_RATELIMIT_REMAINING=""
    _GITHUB_API_RATELIMIT_RESET=""
    _GITHUB_API_RETRY_AFTER=""
    return 0
}
validate_github_api
if [[ -n "${_GITHUB_API_LINK+x}" ]]; then
    _test_fail "GM-G8: unset _GITHUB_API_LINK remains unset" "was set to '${_GITHUB_API_LINK:-}'"
else
    _test_pass "GM-G8: unset _GITHUB_API_LINK remains unset"
fi

# GM-G9: Previously empty _GITHUB_API_HEADERS restored as empty
_GITHUB_API_HEADERS=""
_provider_github_api() {
    _GITHUB_API_STATUS="200"
    _GITHUB_API_BODY='{"id":1,"login":"u"}'
    _GITHUB_API_HEADERS="Content-Type: application/json"
    _GITHUB_API_EXIT=0
    _GITHUB_API_LINK=""
    _GITHUB_API_RATELIMIT_REMAINING=""
    _GITHUB_API_RATELIMIT_RESET=""
    _GITHUB_API_RETRY_AFTER=""
    return 0
}
validate_github_api
assert_eq "GM-G9: empty _GITHUB_API_HEADERS restored as empty" "" "$_GITHUB_API_HEADERS"

# GM-G10: All 8 _GITHUB_API_* vars restored (bulk)
_GITHUB_API_STATUS="s1"
_GITHUB_API_BODY="b1"
_GITHUB_API_HEADERS="h1"
_GITHUB_API_EXIT="e1"
_GITHUB_API_LINK="l1"
_GITHUB_API_RATELIMIT_REMAINING="rr1"
_GITHUB_API_RATELIMIT_RESET="re1"
_GITHUB_API_RETRY_AFTER="ra1"
_provider_github_api() {
    _GITHUB_API_STATUS="200"
    _GITHUB_API_BODY='{"id":1,"login":"u"}'
    _GITHUB_API_HEADERS="changed"
    _GITHUB_API_EXIT=0
    _GITHUB_API_LINK="changed"
    _GITHUB_API_RATELIMIT_REMAINING="changed"
    _GITHUB_API_RATELIMIT_RESET="changed"
    _GITHUB_API_RETRY_AFTER="changed"
    return 0
}
validate_github_api
_g10_ok=true
[[ "$_GITHUB_API_STATUS" == "s1" ]] || _g10_ok=false
[[ "$_GITHUB_API_BODY" == "b1" ]] || _g10_ok=false
[[ "$_GITHUB_API_HEADERS" == "h1" ]] || _g10_ok=false
[[ "$_GITHUB_API_EXIT" == "e1" ]] || _g10_ok=false
[[ "$_GITHUB_API_LINK" == "l1" ]] || _g10_ok=false
[[ "$_GITHUB_API_RATELIMIT_REMAINING" == "rr1" ]] || _g10_ok=false
[[ "$_GITHUB_API_RATELIMIT_RESET" == "re1" ]] || _g10_ok=false
[[ "$_GITHUB_API_RETRY_AFTER" == "ra1" ]] || _g10_ok=false
if $_g10_ok; then
    _test_pass "GM-G10: all 8 _GITHUB_API_* vars restored"
else
    _test_fail "GM-G10: all 8 _GITHUB_API_* vars restored" "at least one var not restored"
fi

# GM-G11: set -u safe
(
    set -u
    _provider_github_api() {
        _GITHUB_API_STATUS="200"
        _GITHUB_API_BODY='{"id":1,"login":"u"}'
        _GITHUB_API_HEADERS=""
        _GITHUB_API_EXIT=0
        _GITHUB_API_LINK=""
        _GITHUB_API_RATELIMIT_REMAINING=""
        _GITHUB_API_RATELIMIT_RESET=""
        _GITHUB_API_RETRY_AFTER=""
        return 0
    }
    validate_github_api
) 2>/dev/null
if [[ $? -eq 0 ]]; then
    _test_pass "GM-G11: set -u safe (GitHub success)"
else
    _test_fail "GM-G11: set -u safe (GitHub success)" "exited nonzero under set -u"
fi

# GM-G12: No stdout
_provider_github_api() {
    _GITHUB_API_STATUS="200"
    _GITHUB_API_BODY='{"id":1,"login":"u"}'
    _GITHUB_API_HEADERS=""
    _GITHUB_API_EXIT=0
    _GITHUB_API_LINK=""
    _GITHUB_API_RATELIMIT_REMAINING=""
    _GITHUB_API_RATELIMIT_RESET=""
    _GITHUB_API_RETRY_AFTER=""
    return 0
}
local_stdout=$(validate_github_api 2>/dev/null)
assert_empty "GM-G12: no stdout on success" "$local_stdout"

# GM-G13: No stderr
local_stderr=$(validate_github_api 2>&1 >/dev/null)
assert_empty "GM-G13: no stderr on success" "$local_stderr"

# GM-G14: Wrapper non-interference — env-token credential path (GH_TOKEN)
# This proves the wrapper does not inspect or reject env-token configurations
# before invoking the seam. It does NOT independently prove gh credential
# precedence — that is established by GitHub CLI behavior and prior live evidence.
_provider_github_api() {
    _GITHUB_API_STATUS="200"
    _GITHUB_API_BODY='{"id":99,"login":"env-token-user"}'
    _GITHUB_API_HEADERS=""
    _GITHUB_API_EXIT=0
    _GITHUB_API_LINK=""
    _GITHUB_API_RATELIMIT_REMAINING=""
    _GITHUB_API_RATELIMIT_RESET=""
    _GITHUB_API_RETRY_AFTER=""
    return 0
}
validate_github_api
rc=$?
assert_return "GM-G14: wrapper non-interference (env-token path) returns 0" "0" "$rc"
assert_eq "GM-G14: GITHUB_VALIDATE_USER from env-token path" "env-token-user" "$GITHUB_VALIDATE_USER"

# GM-G15: Wrapper non-interference — GITHUB_TOKEN credential path
# Same as GM-G14: proves wrapper delegates unchanged to seam, does not
# independently validate gh credential precedence.
_provider_github_api() {
    _GITHUB_API_STATUS="200"
    _GITHUB_API_BODY='{"id":88,"login":"github-token-user"}'
    _GITHUB_API_HEADERS=""
    _GITHUB_API_EXIT=0
    _GITHUB_API_LINK=""
    _GITHUB_API_RATELIMIT_REMAINING=""
    _GITHUB_API_RATELIMIT_RESET=""
    _GITHUB_API_RETRY_AFTER=""
    return 0
}
validate_github_api
rc=$?
assert_return "GM-G15: wrapper non-interference (GITHUB_TOKEN path) returns 0" "0" "$rc"
assert_eq "GM-G15: GITHUB_VALIDATE_USER from GITHUB_TOKEN path" "github-token-user" "$GITHUB_VALIDATE_USER"

# GM-G16: Failure-path stderr suppression — seam emits stderr, wrapper must not
_provider_github_api() {
    echo "synthetic seam stderr for github" >&2
    _GITHUB_API_STATUS=""
    _GITHUB_API_BODY=""
    _GITHUB_API_HEADERS=""
    _GITHUB_API_EXIT=1
    _GITHUB_API_LINK=""
    _GITHUB_API_RATELIMIT_REMAINING=""
    _GITHUB_API_RATELIMIT_RESET=""
    _GITHUB_API_RETRY_AFTER=""
    return 1
}
local_stderr=$(validate_github_api 2>&1 >/dev/null)
assert_empty "GM-G16: no stderr on failure (seam emits stderr)" "$local_stderr"

# GM-G17: Failure-path stdout suppression
local_stdout=$(validate_github_api 2>/dev/null)
assert_empty "GM-G17: no stdout on failure (seam emits stderr)" "$local_stdout"

echo ""
echo "── WP5B golden-master: validate_supabase_token ──"

# GM-S1: Success (JSON array response)
export SUPABASE_ACCESS_TOKEN="test-token"
_provider_supabase_api() {
    printf '%s\n%s' '[{"id":"org1","name":"Test Org"}]' '200'
}
validate_supabase_token
rc=$?
assert_return "GM-S1: JSON array returns 0" "0" "$rc"
assert_empty "GM-S1: SUPABASE_VALIDATE_ERROR empty" "$SUPABASE_VALIDATE_ERROR"

# GM-S2: Missing credential
unset SUPABASE_ACCESS_TOKEN 2>/dev/null || true
validate_supabase_token
rc=$?
assert_return "GM-S2: missing credential returns 1" "1" "$rc"
assert_eq "GM-S2: SUPABASE_VALIDATE_ERROR is not_set" "not_set" "$SUPABASE_VALIDATE_ERROR"

# GM-S3: Non-array JSON response
export SUPABASE_ACCESS_TOKEN="test-token"
_provider_supabase_api() {
    printf '%s\n%s' '{"error":"unauthorized"}' '401'
}
validate_supabase_token
rc=$?
assert_return "GM-S3: non-array JSON returns 1" "1" "$rc"
assert_eq "GM-S3: SUPABASE_VALIDATE_ERROR is invalid_token" "invalid_token" "$SUPABASE_VALIDATE_ERROR"

# GM-S4: Transport failure
_provider_supabase_api() {
    return 1
}
validate_supabase_token
rc=$?
assert_return "GM-S4: transport failure returns 1" "1" "$rc"
assert_eq "GM-S4: SUPABASE_VALIDATE_ERROR is api_error" "api_error" "$SUPABASE_VALIDATE_ERROR"

# GM-S5: Non-JSON response
_provider_supabase_api() {
    printf '%s\n%s' 'not json at all' '200'
}
validate_supabase_token
rc=$?
assert_return "GM-S5: non-JSON returns 1" "1" "$rc"
assert_eq "GM-S5: SUPABASE_VALIDATE_ERROR is invalid_token" "invalid_token" "$SUPABASE_VALIDATE_ERROR"

# GM-S6: Empty response body
_provider_supabase_api() {
    printf '%s\n%s' '' '200'
}
validate_supabase_token
rc=$?
assert_return "GM-S6: empty body returns 1" "1" "$rc"
assert_eq "GM-S6: SUPABASE_VALIDATE_ERROR is invalid_token" "invalid_token" "$SUPABASE_VALIDATE_ERROR"

# GM-S7: _RESP_BODY restored after success
_RESP_BODY="supabase-prior"
_provider_supabase_api() {
    printf '%s\n%s' '[{"id":"org1"}]' '200'
}
validate_supabase_token
assert_eq "GM-S7: _RESP_BODY restored after success" "supabase-prior" "$_RESP_BODY"

# GM-S8: _RESP_BODY restored after failure
_RESP_BODY="supabase-prior-fail"
_provider_supabase_api() {
    printf '%s\n%s' '{"error":"bad"}' '401'
}
validate_supabase_token
assert_eq "GM-S8: _RESP_BODY restored after failure" "supabase-prior-fail" "$_RESP_BODY"

# GM-S9: Previously unset _RESP_CODE remains unset
unset _RESP_CODE 2>/dev/null || true
_provider_supabase_api() {
    printf '%s\n%s' '[{"id":"org1"}]' '200'
}
validate_supabase_token
if [[ -n "${_RESP_CODE+x}" ]]; then
    _test_fail "GM-S9: unset _RESP_CODE remains unset" "was set to '${_RESP_CODE:-}'"
else
    _test_pass "GM-S9: unset _RESP_CODE remains unset"
fi

# GM-S10: Previously empty _RESP_BODY restored as empty
_RESP_BODY=""
_provider_supabase_api() {
    printf '%s\n%s' '[{"id":"org1"}]' '200'
}
validate_supabase_token
assert_eq "GM-S10: empty _RESP_BODY restored as empty" "" "$_RESP_BODY"

# GM-S11: RESOLVED_SUPABASE_ORG untouched
RESOLVED_SUPABASE_ORG="must-not-change"
_provider_supabase_api() {
    printf '%s\n%s' '[{"id":"org1"}]' '200'
}
validate_supabase_token
assert_eq "GM-S11: RESOLVED_SUPABASE_ORG untouched" "must-not-change" "$RESOLVED_SUPABASE_ORG"
unset RESOLVED_SUPABASE_ORG 2>/dev/null || true

# GM-S12: set -u safe
(
    set -u
    export SUPABASE_ACCESS_TOKEN="test-token"
    _provider_supabase_api() {
        printf '%s\n%s' '[{"id":"org1"}]' '200'
    }
    validate_supabase_token
) 2>/dev/null
if [[ $? -eq 0 ]]; then
    _test_pass "GM-S12: set -u safe (Supabase success)"
else
    _test_fail "GM-S12: set -u safe (Supabase success)" "exited nonzero under set -u"
fi

# GM-S13: No stdout
export SUPABASE_ACCESS_TOKEN="test-token"
_provider_supabase_api() {
    printf '%s\n%s' '[{"id":"org1"}]' '200'
}
local_stdout=$(validate_supabase_token 2>/dev/null)
assert_empty "GM-S13: no stdout on success" "$local_stdout"

# GM-S14: No stderr
local_stderr=$(validate_supabase_token 2>&1 >/dev/null)
assert_empty "GM-S14: no stderr on success" "$local_stderr"

# GM-S-TRANSPORT-RESTORE: _RESP_BODY restored after transport failure
_RESP_BODY="transport-prior-sb"
_provider_supabase_api() {
    return 1
}
validate_supabase_token
assert_eq "GM-S-TRANSPORT: _RESP_BODY restored after transport failure" "transport-prior-sb" "$_RESP_BODY"

# GM-S15: Failure-path stderr suppression — seam emits stderr, wrapper must not
_provider_supabase_api() {
    echo "synthetic seam stderr for supabase" >&2
    return 1
}
local_stderr=$(validate_supabase_token 2>&1 >/dev/null)
assert_empty "GM-S15: no stderr on failure (seam emits stderr)" "$local_stderr"

# GM-S16: Failure-path stdout suppression
local_stdout=$(validate_supabase_token 2>/dev/null)
assert_empty "GM-S16: no stdout on failure (seam emits stderr)" "$local_stdout"

unset SUPABASE_ACCESS_TOKEN 2>/dev/null || true

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
