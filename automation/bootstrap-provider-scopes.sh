#!/usr/bin/env bash
# bootstrap-provider-scopes.sh — One-time canonical provider ID bootstrap
#
# Resolves prescribed provider names/slugs into immutable provider IDs.
# This is an administrative operation, not normal preflight behavior.
#
# Usage:
#   ./automation/bootstrap-provider-scopes.sh
#
# Prerequisites:
#   - gh CLI authenticated (gh auth login)
#   - VERCEL_TOKEN set
#   - SUPABASE_ACCESS_TOKEN set
#
# This script:
#   - validates each provider credential
#   - resolves the prescribed scope by name/slug
#   - prints the canonical ID, resolved name/slug, and authenticated actor
#   - requires human confirmation before emitting configuration output
#   - performs NO provisioning mutations
#   - does NOT write to provider-scopes.sh automatically
#
# Part of PLAT-01/WP0. See docs/specs/PLAT-01-provider-context-and-safe-scope-resolution.md

set -euo pipefail

# ── Prescribed scopes ──────────────────────────────────────────────────────
# These are the names/slugs we expect to resolve. They are inputs to
# bootstrap, not outputs.

PRESCRIBED_GITHUB_ORG="friends-innovation-lab"
PRESCRIBED_VERCEL_TEAM_SLUG="friends-innovation-lab"
PRESCRIBED_SUPABASE_ORG_ID="esiwooovlhcuifbbkodk"

# ── Colors & output ────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; }
info() { echo -e "  ${BLUE}→${NC} $1"; }

# ── Provider-call wrappers ─────────────────────────────────────────────────
# All provider interaction goes through these functions. They are the
# bootstrap-time equivalent of the PLAT-01 provider-call seam.
# Tests or later refactoring can replace these.

_bootstrap_gh_api() {
    gh api "$@" 2>/dev/null
}

_bootstrap_vercel_api() {
    local method="$1"
    local path="$2"
    shift 2
    curl -s -w "\n%{http_code}" -X "$method" \
        "https://api.vercel.com${path}" \
        -H "Authorization: Bearer $VERCEL_TOKEN" \
        "$@"
}

_bootstrap_supabase_api() {
    local method="$1"
    local path="$2"
    shift 2
    curl -s -w "\n%{http_code}" -X "$method" \
        "https://api.supabase.com${path}" \
        -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" \
        "$@"
}

# ── Helper: split curl response into body + http_code ──────────────────────

_split_response() {
    local response="$1"
    RESP_CODE=$(echo "$response" | tail -1)
    RESP_BODY=$(echo "$response" | sed '$d')
}

# ── Banner ─────────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   PLAT-01/WP0 — Canonical Provider ID Bootstrap            ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "This utility resolves prescribed provider names/slugs into"
echo "immutable canonical IDs. It performs no mutations."
echo ""

# ── Track results ──────────────────────────────────────────────────────────

BOOTSTRAP_FAILED=false

GITHUB_ACTOR=""
GITHUB_ORG_ID=""
GITHUB_ORG_LOGIN=""
GITHUB_ORG_NAME=""
GITHUB_MEMBERSHIP_ROLE=""
GITHUB_MEMBERSHIP_STATE=""

VERCEL_ACTOR=""
VERCEL_ACTOR_UID=""
VERCEL_TEAM_ID=""
VERCEL_TEAM_SLUG=""
VERCEL_TEAM_NAME=""
VERCEL_MEMBERSHIP_ROLE=""
VERCEL_MEMBERSHIP_PERMISSIONS=""

SUPABASE_ACTOR=""
SUPABASE_ACTOR_ID=""
SUPABASE_ORG_ID=""
SUPABASE_ORG_SLUG=""
SUPABASE_ORG_NAME=""
SUPABASE_MEMBER_ROLES=""

# ════════════════════════════════════════════════════════════════════════════
# GitHub
# ════════════════════════════════════════════════════════════════════════════

echo -e "${BOLD}── GitHub ──${NC}"
echo ""

# 1. Validate credential + resolve actor
info "Validating GitHub credential..."
GH_USER_RESPONSE=$(_bootstrap_gh_api /user) || {
    fail "GitHub credential validation failed — gh api /user returned error"
    fail "Run: gh auth login"
    BOOTSTRAP_FAILED=true
}

if [[ "$BOOTSTRAP_FAILED" != true ]]; then
    GITHUB_ACTOR=$(echo "$GH_USER_RESPONSE" | jq -r '.login // empty')
    GITHUB_ACTOR_ID=$(echo "$GH_USER_RESPONSE" | jq -r '.id // empty')

    if [[ -z "$GITHUB_ACTOR" ]]; then
        fail "GitHub credential valid but actor identity could not be resolved"
        BOOTSTRAP_FAILED=true
    else
        ok "Authenticated as: ${GITHUB_ACTOR} (id: ${GITHUB_ACTOR_ID})"
    fi
fi

# 2. Resolve prescribed org
if [[ "$BOOTSTRAP_FAILED" != true ]]; then
    info "Resolving GitHub org: ${PRESCRIBED_GITHUB_ORG}"

    GH_ORG_RESPONSE=$(_bootstrap_gh_api "/orgs/${PRESCRIBED_GITHUB_ORG}") || {
        fail "Could not resolve GitHub org '${PRESCRIBED_GITHUB_ORG}'"
        fail "GitHub returns 404 for both missing and inaccessible orgs"
        BOOTSTRAP_FAILED=true
    }

    if [[ "$BOOTSTRAP_FAILED" != true ]]; then
        GITHUB_ORG_ID=$(echo "$GH_ORG_RESPONSE" | jq -r '.id // empty')
        GITHUB_ORG_LOGIN=$(echo "$GH_ORG_RESPONSE" | jq -r '.login // empty')
        GITHUB_ORG_NAME=$(echo "$GH_ORG_RESPONSE" | jq -r '.name // empty')

        if [[ -z "$GITHUB_ORG_ID" ]]; then
            fail "Org resolved but no ID in response"
            BOOTSTRAP_FAILED=true
        else
            ok "Org ID: ${GITHUB_ORG_ID}"
            ok "Org login: ${GITHUB_ORG_LOGIN}"
            ok "Org name: ${GITHUB_ORG_NAME}"
        fi
    fi
fi

# 3. Check membership + role
if [[ "$BOOTSTRAP_FAILED" != true ]]; then
    info "Checking membership in ${PRESCRIBED_GITHUB_ORG}..."

    GH_MEMBERSHIP_RESPONSE=$(_bootstrap_gh_api "/user/memberships/orgs/${PRESCRIBED_GITHUB_ORG}") || {
        fail "Could not retrieve membership for ${PRESCRIBED_GITHUB_ORG}"
        fail "You may not be a member of this org"
        BOOTSTRAP_FAILED=true
    }

    if [[ "$BOOTSTRAP_FAILED" != true ]]; then
        GITHUB_MEMBERSHIP_ROLE=$(echo "$GH_MEMBERSHIP_RESPONSE" | jq -r '.role // empty')
        GITHUB_MEMBERSHIP_STATE=$(echo "$GH_MEMBERSHIP_RESPONSE" | jq -r '.state // empty')

        if [[ -z "$GITHUB_MEMBERSHIP_ROLE" ]]; then
            fail "Membership response missing role"
            BOOTSTRAP_FAILED=true
        else
            ok "Role: ${GITHUB_MEMBERSHIP_ROLE} (state: ${GITHUB_MEMBERSHIP_STATE})"
        fi
    fi
fi

echo ""

# ════════════════════════════════════════════════════════════════════════════
# Vercel
# ════════════════════════════════════════════════════════════════════════════

echo -e "${BOLD}── Vercel ──${NC}"
echo ""

VERCEL_FAILED=false

# 1. Validate credential + resolve actor
if [[ -z "${VERCEL_TOKEN:-}" ]]; then
    fail "VERCEL_TOKEN is not set"
    VERCEL_FAILED=true
    BOOTSTRAP_FAILED=true
fi

if [[ "$VERCEL_FAILED" != true ]]; then
    info "Validating Vercel credential..."

    VERCEL_USER_RAW=$(_bootstrap_vercel_api GET /v2/user)
    _split_response "$VERCEL_USER_RAW"

    if [[ "$RESP_CODE" != "200" ]]; then
        invalid_token=$(echo "$RESP_BODY" | jq -r '.error.invalidToken // empty' 2>/dev/null)
        if [[ "$invalid_token" == "true" ]]; then
            fail "VERCEL_TOKEN is invalid (expired, revoked, or malformed)"
            fail "Regenerate at vercel.com → Account Settings → Tokens"
        else
            fail "Vercel credential validation failed (HTTP ${RESP_CODE})"
        fi
        VERCEL_FAILED=true
        BOOTSTRAP_FAILED=true
    else
        # /v2/user returns { user: { id, username, ... } }
        # Note: .user.uid is null in current API; .user.id is the actor ID
        VERCEL_ACTOR=$(echo "$RESP_BODY" | jq -r '.user.username // empty')
        VERCEL_ACTOR_UID=$(echo "$RESP_BODY" | jq -r '.user.id // empty')

        if [[ -z "$VERCEL_ACTOR" ]]; then
            fail "Vercel credential valid but actor identity could not be resolved"
            VERCEL_FAILED=true
            BOOTSTRAP_FAILED=true
        else
            ok "Authenticated as: ${VERCEL_ACTOR} (uid: ${VERCEL_ACTOR_UID})"
        fi
    fi
fi

# 2. List teams to find prescribed slug
if [[ "$VERCEL_FAILED" != true ]]; then
    info "Looking up team slug: ${PRESCRIBED_VERCEL_TEAM_SLUG}"

    VERCEL_TEAMS_RAW=$(_bootstrap_vercel_api GET "/v2/teams?limit=100")
    _split_response "$VERCEL_TEAMS_RAW"

    if [[ "$RESP_CODE" != "200" ]]; then
        fail "Could not list Vercel teams (HTTP ${RESP_CODE})"
        VERCEL_FAILED=true
        BOOTSTRAP_FAILED=true
    else
        VERCEL_TEAM_ID=$(echo "$RESP_BODY" | jq -r \
            ".teams[] | select(.slug==\"${PRESCRIBED_VERCEL_TEAM_SLUG}\") | .id // empty")

        if [[ -z "$VERCEL_TEAM_ID" ]]; then
            fail "Team slug '${PRESCRIBED_VERCEL_TEAM_SLUG}' not found in accessible teams"
            VERCEL_FAILED=true
            BOOTSTRAP_FAILED=true
        else
            ok "Team ID resolved from team list: ${VERCEL_TEAM_ID}"
        fi
    fi
fi

# 3. Verify by direct ID lookup + get membership/permissions
if [[ "$VERCEL_FAILED" != true ]]; then
    info "Verifying team by canonical ID: ${VERCEL_TEAM_ID}"

    VERCEL_TEAM_RAW=$(_bootstrap_vercel_api GET "/v2/teams/${VERCEL_TEAM_ID}")
    _split_response "$VERCEL_TEAM_RAW"

    if [[ "$RESP_CODE" != "200" ]]; then
        fail "Direct team lookup by ID failed (HTTP ${RESP_CODE})"
        VERCEL_FAILED=true
        BOOTSTRAP_FAILED=true
    else
        VERCEL_TEAM_SLUG=$(echo "$RESP_BODY" | jq -r '.slug // empty')
        VERCEL_TEAM_NAME=$(echo "$RESP_BODY" | jq -r '.name // empty')
        VERCEL_MEMBERSHIP_ROLE=$(echo "$RESP_BODY" | jq -r '.membership.role // empty')
        VERCEL_MEMBERSHIP_PERMISSIONS=$(echo "$RESP_BODY" | jq -r \
            '[.membership.teamPermissions[]?] | join(", ")')

        # OWNER role has all permissions implicitly — Vercel does not
        # enumerate them in the response. Record this explicitly.
        if [[ -z "$VERCEL_MEMBERSHIP_PERMISSIONS" && "$VERCEL_MEMBERSHIP_ROLE" == "OWNER" ]]; then
            VERCEL_MEMBERSHIP_PERMISSIONS="all (implicit — OWNER role)"
        fi

        if [[ "$VERCEL_TEAM_SLUG" != "$PRESCRIBED_VERCEL_TEAM_SLUG" ]]; then
            fail "ID ${VERCEL_TEAM_ID} resolved to slug '${VERCEL_TEAM_SLUG}', expected '${PRESCRIBED_VERCEL_TEAM_SLUG}'"
            VERCEL_FAILED=true
            BOOTSTRAP_FAILED=true
        else
            ok "Slug verified: ${VERCEL_TEAM_SLUG}"
            ok "Team name: ${VERCEL_TEAM_NAME}"
            ok "Membership role: ${VERCEL_MEMBERSHIP_ROLE}"
            ok "Permissions: ${VERCEL_MEMBERSHIP_PERMISSIONS:-none enumerated}"
        fi
    fi
fi

echo ""

# ════════════════════════════════════════════════════════════════════════════
# Supabase
# ════════════════════════════════════════════════════════════════════════════

echo -e "${BOLD}── Supabase ──${NC}"
echo ""

SUPABASE_FAILED=false

# 1. Validate credential + resolve actor
if [[ -z "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
    fail "SUPABASE_ACCESS_TOKEN is not set"
    SUPABASE_FAILED=true
    BOOTSTRAP_FAILED=true
fi

if [[ "$SUPABASE_FAILED" != true ]]; then
    info "Validating Supabase credential..."

    SUPABASE_PROFILE_RAW=$(_bootstrap_supabase_api GET /v1/profile)
    _split_response "$SUPABASE_PROFILE_RAW"

    if [[ "$RESP_CODE" != "200" ]]; then
        fail "Supabase credential validation failed (HTTP ${RESP_CODE})"
        SUPABASE_FAILED=true
        BOOTSTRAP_FAILED=true
    else
        SUPABASE_ACTOR=$(echo "$RESP_BODY" | jq -r '.username // empty')
        SUPABASE_ACTOR_ID=$(echo "$RESP_BODY" | jq -r '.gotrue_id // empty')

        if [[ -z "$SUPABASE_ACTOR_ID" ]]; then
            fail "Supabase credential valid but actor identity could not be resolved"
            SUPABASE_FAILED=true
            BOOTSTRAP_FAILED=true
        else
            ok "Authenticated as: ${SUPABASE_ACTOR:-<no username>} (gotrue_id: ${SUPABASE_ACTOR_ID})"
        fi
    fi
fi

# 2. Enumerate orgs, filter by prescribed ID
if [[ "$SUPABASE_FAILED" != true ]]; then
    info "Looking up Supabase org by ID: ${PRESCRIBED_SUPABASE_ORG_ID}"

    SUPABASE_ORGS_RAW=$(_bootstrap_supabase_api GET /v1/organizations)
    _split_response "$SUPABASE_ORGS_RAW"

    if [[ "$RESP_CODE" != "200" ]]; then
        fail "Could not list Supabase organizations (HTTP ${RESP_CODE})"
        SUPABASE_FAILED=true
        BOOTSTRAP_FAILED=true
    else
        MATCH_COUNT=$(echo "$RESP_BODY" | jq \
            "[.[] | select(.id==\"${PRESCRIBED_SUPABASE_ORG_ID}\")] | length")

        if [[ "$MATCH_COUNT" -eq 0 ]]; then
            fail "Org ID '${PRESCRIBED_SUPABASE_ORG_ID}' not found in accessible organizations"
            echo "  Accessible orgs:"
            echo "$RESP_BODY" | jq -r '.[] | "    \(.id)  \(.name)"'
            SUPABASE_FAILED=true
            BOOTSTRAP_FAILED=true
        elif [[ "$MATCH_COUNT" -gt 1 ]]; then
            fail "Org ID '${PRESCRIBED_SUPABASE_ORG_ID}' matched ${MATCH_COUNT} entries (expected exactly 1)"
            SUPABASE_FAILED=true
            BOOTSTRAP_FAILED=true
        else
            SUPABASE_ORG_ID=$(echo "$RESP_BODY" | jq -r \
                ".[] | select(.id==\"${PRESCRIBED_SUPABASE_ORG_ID}\") | .id")
            SUPABASE_ORG_SLUG=$(echo "$RESP_BODY" | jq -r \
                ".[] | select(.id==\"${PRESCRIBED_SUPABASE_ORG_ID}\") | .slug // empty")
            SUPABASE_ORG_NAME=$(echo "$RESP_BODY" | jq -r \
                ".[] | select(.id==\"${PRESCRIBED_SUPABASE_ORG_ID}\") | .name // empty")

            ok "Org ID: ${SUPABASE_ORG_ID}"
            ok "Org slug: ${SUPABASE_ORG_SLUG:-<none>}"
            ok "Org name: ${SUPABASE_ORG_NAME}"
        fi
    fi
fi

# 3. Check member role via /v2/organizations/{slug}/members
if [[ "$SUPABASE_FAILED" != true && -n "$SUPABASE_ORG_SLUG" ]]; then
    info "Checking Supabase membership role..."

    SUPABASE_MEMBERS_RAW=$(_bootstrap_supabase_api GET "/v2/organizations/${SUPABASE_ORG_SLUG}/members")
    _split_response "$SUPABASE_MEMBERS_RAW"

    if [[ "$RESP_CODE" != "200" ]]; then
        fail "Could not retrieve Supabase org members (HTTP ${RESP_CODE})"
        info "Permission check will be documented as unverified"
        SUPABASE_MEMBER_ROLES="UNVERIFIED (HTTP ${RESP_CODE})"
    else
        # Find the authenticated user in the member list by gotrue_id
        SUPABASE_MEMBER_ROLES=$(echo "$RESP_BODY" | jq -r \
            ".data[]? | select(.id==\"${SUPABASE_ACTOR_ID}\") | [.attributes.roles[]?.name] | join(\", \")")

        if [[ -z "$SUPABASE_MEMBER_ROLES" ]]; then
            # Try matching by username if ID match fails
            SUPABASE_MEMBER_ROLES=$(echo "$RESP_BODY" | jq -r \
                ".data[]? | select(.attributes.username==\"${SUPABASE_ACTOR}\") | [.attributes.roles[]?.name] | join(\", \")")
        fi

        if [[ -n "$SUPABASE_MEMBER_ROLES" ]]; then
            ok "Member roles: ${SUPABASE_MEMBER_ROLES}"
        else
            info "Could not match authenticated user in member list"
            SUPABASE_MEMBER_ROLES="UNVERIFIED (user not found in member list)"
        fi
    fi
elif [[ "$SUPABASE_FAILED" != true ]]; then
    info "No org slug available — skipping member role check"
    SUPABASE_MEMBER_ROLES="UNVERIFIED (no slug)"
fi

echo ""

# ════════════════════════════════════════════════════════════════════════════
# Summary
# ════════════════════════════════════════════════════════════════════════════

echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   Bootstrap Results                                        ║${NC}"
echo -e "${BOLD}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}║${NC}"
echo -e "${BOLD}║${NC} ${BOLD}GitHub${NC}"
echo -e "${BOLD}║${NC}   Requested org:   ${PRESCRIBED_GITHUB_ORG}"
echo -e "${BOLD}║${NC}   Canonical ID:    ${GITHUB_ORG_ID:-FAILED}"
echo -e "${BOLD}║${NC}   Resolved login:  ${GITHUB_ORG_LOGIN:-FAILED}"
echo -e "${BOLD}║${NC}   Resolved name:   ${GITHUB_ORG_NAME:-FAILED}"
echo -e "${BOLD}║${NC}   Actor:           ${GITHUB_ACTOR:-FAILED} (id: ${GITHUB_ACTOR_ID:-?})"
echo -e "${BOLD}║${NC}   Membership:      ${GITHUB_MEMBERSHIP_ROLE:-FAILED} (${GITHUB_MEMBERSHIP_STATE:-?})"
echo -e "${BOLD}║${NC}"
echo -e "${BOLD}║${NC} ${BOLD}Vercel${NC}"
echo -e "${BOLD}║${NC}   Requested slug:  ${PRESCRIBED_VERCEL_TEAM_SLUG}"
echo -e "${BOLD}║${NC}   Canonical ID:    ${VERCEL_TEAM_ID:-FAILED}"
echo -e "${BOLD}║${NC}   Resolved slug:   ${VERCEL_TEAM_SLUG:-FAILED}"
echo -e "${BOLD}║${NC}   Resolved name:   ${VERCEL_TEAM_NAME:-FAILED}"
echo -e "${BOLD}║${NC}   Actor:           ${VERCEL_ACTOR:-FAILED} (uid: ${VERCEL_ACTOR_UID:-?})"
echo -e "${BOLD}║${NC}   Membership role: ${VERCEL_MEMBERSHIP_ROLE:-FAILED}"
echo -e "${BOLD}║${NC}   Permissions:     ${VERCEL_MEMBERSHIP_PERMISSIONS:-FAILED}"
echo -e "${BOLD}║${NC}"
echo -e "${BOLD}║${NC} ${BOLD}Supabase${NC}"
echo -e "${BOLD}║${NC}   Requested ID:    ${PRESCRIBED_SUPABASE_ORG_ID}"
echo -e "${BOLD}║${NC}   Canonical ID:    ${SUPABASE_ORG_ID:-FAILED}"
echo -e "${BOLD}║${NC}   Resolved slug:   ${SUPABASE_ORG_SLUG:-FAILED}"
echo -e "${BOLD}║${NC}   Resolved name:   ${SUPABASE_ORG_NAME:-FAILED}"
echo -e "${BOLD}║${NC}   Actor:           ${SUPABASE_ACTOR:-FAILED} (gotrue_id: ${SUPABASE_ACTOR_ID:-?})"
echo -e "${BOLD}║${NC}   Member roles:    ${SUPABASE_MEMBER_ROLES:-FAILED}"
echo -e "${BOLD}║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ "$BOOTSTRAP_FAILED" == true ]]; then
    echo -e "${RED}Bootstrap failed. Fix the issues above and try again.${NC}"
    exit 1
fi

# ════════════════════════════════════════════════════════════════════════════
# Confirmation + config output
# ════════════════════════════════════════════════════════════════════════════

echo "Review the values above carefully."
echo ""
echo "If correct, the following configuration block should be"
echo "committed to: automation/config/provider-scopes.sh"
echo ""
echo -e "${YELLOW}This script will NOT write the file automatically.${NC}"
echo ""
printf "Print the configuration block? (y/n) > "
read -r CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo ""
    echo "Bootstrap complete. No configuration emitted."
    exit 0
fi

echo ""
echo -e "${BOLD}── Copy this to automation/config/provider-scopes.sh ──${NC}"
echo ""
cat <<EOF
#!/usr/bin/env bash
# provider-scopes.sh — Canonical provider scope configuration
#
# Non-secret provider coordinates resolved by bootstrap-provider-scopes.sh
# and reviewed before merge. Do not edit manually without re-running bootstrap.
#
# Part of PLAT-01. See docs/specs/PLAT-01-provider-context-and-safe-scope-resolution.md
#
# Bootstrapped: $(date -u +%Y-%m-%dT%H:%M:%SZ)
# Actor: GitHub=${GITHUB_ACTOR}, Vercel=${VERCEL_ACTOR}, Supabase=${SUPABASE_ACTOR:-<no-username>}

# GitHub
LAB_GITHUB_ORG="${GITHUB_ORG_LOGIN}"
LAB_GITHUB_ORG_ID="${GITHUB_ORG_ID}"

# Vercel
LAB_VERCEL_TEAM_SLUG="${VERCEL_TEAM_SLUG}"
LAB_VERCEL_TEAM_ID="${VERCEL_TEAM_ID}"

# Supabase
LAB_SUPABASE_ORG_ID="${SUPABASE_ORG_ID}"
LAB_SUPABASE_ORG_NAME="${SUPABASE_ORG_NAME}"
EOF

# If Supabase exposes a slug, include it as a note
if [[ -n "$SUPABASE_ORG_SLUG" ]]; then
    echo "LAB_SUPABASE_ORG_SLUG=\"${SUPABASE_ORG_SLUG}\""
fi

echo ""
echo -e "${BOLD}── Permission findings (document in implementation plan) ──${NC}"
echo ""
echo "GitHub:"
echo "  Role: ${GITHUB_MEMBERSHIP_ROLE} (state: ${GITHUB_MEMBERSHIP_STATE})"
echo "  Implication: '${GITHUB_MEMBERSHIP_ROLE}' role with '${GITHUB_MEMBERSHIP_STATE}' state"
echo "  Repo creation: depends on org settings (not verifiable via API)"
echo ""
echo "Vercel:"
echo "  Role: ${VERCEL_MEMBERSHIP_ROLE}"
echo "  Permissions: ${VERCEL_MEMBERSHIP_PERMISSIONS:-none enumerated}"
echo "  Project deletion: check if permissions include a deletion capability"
echo ""
echo "Supabase:"
echo "  Roles: ${SUPABASE_MEMBER_ROLES}"
echo "  Project creation: depends on role (not documented by Supabase)"
echo ""
echo -e "${GREEN}Bootstrap complete.${NC} Copy the config block above into:"
echo "  automation/config/provider-scopes.sh"
echo ""
echo "Then have a second person review the ID/name pairs before merging."
