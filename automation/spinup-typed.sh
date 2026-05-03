#!/usr/bin/env bash
# spinup-typed.sh — Type-aware project spinup for Friends Innovation Lab
#
# Creates a new project from the project-template, applies the appropriate
# lab-extensions based on the project type, provisions GitHub + Vercel +
# Supabase, and wires up a custom subdomain.
#
# Usage:
#   spinup-typed.sh --name <project-name> --type <type> [options]
#
# Types:
#   prototype     - Fast, lightweight. No extensions. Single env. (default)
#   internal-tool - Light enterprise. Audit log + soft deletes.
#   saas-web      - Full enterprise. Multi-tenancy + audit log + soft deletes + 3 envs.
#   ai-product    - SaaS-web + AI governance scaffolding (deferred — falls back to saas-web).
#   federal       - Audit log + soft deletes + USWDS scaffolding. Single-tenant by default.
#
# Options:
#   --name <name>           Project name (required, lowercase + hyphens)
#   --type <type>           Project type (default: prototype)
#   --description <text>    Repo description (default: derived from name + type)
#   --agency-theme <theme>  Agency theme: fftc, va, uswds, cms (default: fftc)
#   --skip-vercel           Don't provision Vercel project
#   --skip-supabase         Don't provision Supabase project
#   --supabase-org <id>     Supabase organization ID (overrides env var)
#   --skip-issues           Don't create starter issues
#   --dry-run               Print what would be done without doing it
#
# Environment variables required:
#   GITHUB_ORG              GitHub organization (default: friends-innovation-lab)
#   VERCEL_TOKEN            Vercel API token
#   VERCEL_ORG_ID           Vercel team/org ID
#   LAB_SUPABASE_ORG_ID     Supabase org ID (recommended: set to Friends Lab CI org)
#   SUPABASE_ORG_ID         Supabase org ID (fallback if LAB_SUPABASE_ORG_ID not set)
#   LABS_DOMAIN             Base domain (default: lab.cityfriends.tech)
#
# See also:
#   docs/spinup-typed.md — full guide with examples and troubleshooting
#   spinup.sh            — original interactive script (deprecated fallback)

set -euo pipefail

# ── Constants ───────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_REPO="project-template"
VERSION="1.0.0"

# ── Colors & output helpers ─────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

ok()      { echo -e "  ${GREEN}✓${NC} $1"; }
fail()    { echo -e "  ${RED}✗${NC} $1"; }
warn()    { echo -e "  ${YELLOW}⚠${NC} $1"; }
info()    { echo -e "  ${BLUE}→${NC} $1"; }
step()    { echo -e "\n${BOLD}${BLUE}── Step $1: $2 ──${NC}"; }
dry()     { echo -e "  ${YELLOW}[dry-run]${NC} $1"; }
skip_msg(){ echo -e "  ${GREEN}✓${NC} $1 (already exists, skipping)"; }

# ── Type → extension mapping ───────────────────────────────────────────────

extensions_for_type() {
    case "$1" in
        prototype)     echo "" ;;
        internal-tool) echo "audit-log soft-deletes" ;;
        saas-web)      echo "multi-tenancy audit-log soft-deletes" ;;
        ai-product)    echo "multi-tenancy audit-log soft-deletes" ;;
        federal)       echo "audit-log soft-deletes" ;;
        *)             echo "ERROR: unknown type: $1" >&2; return 1 ;;
    esac
}

# ── Type → starter issues template mapping ────────────────────────────────────
# TODO: prototype currently reuses government template — dedicated issues-prototype.txt to be added in follow-up
# TODO: saas-web and ai-product need their own templates

issues_template_for_type() {
    case "$1" in
        prototype)     echo "issues-government.txt" ;;  # Reuses government template for now
        internal-tool) echo "issues-internal.txt" ;;
        federal)       echo "issues-government.txt" ;;
        saas-web)      echo "" ;;  # No template yet
        ai-product)    echo "" ;;  # No template yet
        *)             echo "" ;;
    esac
}

# ── Argument parsing ───────────────────────────────────────────────────────

PROJECT_NAME=""
PROJECT_TYPE="prototype"
DESCRIPTION=""
AGENCY_THEME="fftc"
SUPABASE_ORG_ARG=""
SKIP_VERCEL=false
SKIP_SUPABASE=false
SKIP_ISSUES=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --name)        PROJECT_NAME="$2"; shift 2 ;;
        --type)        PROJECT_TYPE="$2"; shift 2 ;;
        --description) DESCRIPTION="$2"; shift 2 ;;
        --agency-theme) AGENCY_THEME="$2"; shift 2 ;;
        --supabase-org) SUPABASE_ORG_ARG="$2"; shift 2 ;;
        --skip-vercel)  SKIP_VERCEL=true; shift ;;
        --skip-supabase) SKIP_SUPABASE=true; shift ;;
        --skip-issues)  SKIP_ISSUES=true; shift ;;
        --dry-run)      DRY_RUN=true; shift ;;
        -h|--help)
            sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Run with --help for usage." >&2
            exit 1
            ;;
    esac
done

# ── Validate required args ─────────────────────────────────────────────────

if [[ -z "$PROJECT_NAME" ]]; then
    echo "Error: --name is required." >&2
    echo "Usage: spinup-typed.sh --name <project-name> --type <type>" >&2
    exit 1
fi

if ! echo "$PROJECT_NAME" | grep -qE '^[a-z0-9][a-z0-9-]*[a-z0-9]$' || \
   [[ ${#PROJECT_NAME} -lt 3 ]] || [[ ${#PROJECT_NAME} -gt 40 ]]; then
    echo "Error: Project name must be 3–40 characters, lowercase letters, numbers, and hyphens only." >&2
    exit 1
fi

# Validate type
EXTENSIONS="$(extensions_for_type "$PROJECT_TYPE")" || exit 1

# Default description
if [[ -z "$DESCRIPTION" ]]; then
    DESCRIPTION="Friends Innovation Lab $PROJECT_TYPE project: $PROJECT_NAME"
fi

# Deferred type notices
if [[ "$PROJECT_TYPE" == "ai-product" ]]; then
    warn "ai-product type: ai-governance extension is not yet implemented."
    warn "Falling back to saas-web extensions (multi-tenancy + audit-log + soft-deletes)."
    echo ""
fi
if [[ "$PROJECT_TYPE" == "federal" ]]; then
    warn "federal type: federal-uswds extension is not yet implemented."
    warn "Applying audit-log + soft-deletes. USWDS theme will be set via agency-theme."
    AGENCY_THEME="uswds"
    echo ""
fi

# ── Environment defaults ───────────────────────────────────────────────────

GITHUB_ORG="${GITHUB_ORG:-friends-innovation-lab}"
LABS_DOMAIN="${LABS_DOMAIN:-lab.cityfriends.tech}"

# Resolve Supabase org ID: --supabase-org flag > LAB_SUPABASE_ORG_ID > SUPABASE_ORG_ID
if [[ -n "$SUPABASE_ORG_ARG" ]]; then
    RESOLVED_SUPABASE_ORG="$SUPABASE_ORG_ARG"
elif [[ -n "${LAB_SUPABASE_ORG_ID:-}" ]]; then
    RESOLVED_SUPABASE_ORG="$LAB_SUPABASE_ORG_ID"
elif [[ -n "${SUPABASE_ORG_ID:-}" ]]; then
    RESOLVED_SUPABASE_ORG="$SUPABASE_ORG_ID"
else
    RESOLVED_SUPABASE_ORG=""
fi

# ── Banner ──────────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   Friends Innovation Lab — Type-Aware Project Spinup       ║${NC}"
echo -e "${BOLD}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}║${NC} Name:        ${BOLD}$PROJECT_NAME${NC}"
echo -e "${BOLD}║${NC} Type:        $PROJECT_TYPE"
echo -e "${BOLD}║${NC} Extensions:  ${EXTENSIONS:-none}"
echo -e "${BOLD}║${NC} Theme:       $AGENCY_THEME"
echo -e "${BOLD}║${NC} Supabase org: ${RESOLVED_SUPABASE_ORG:-not set}"
echo -e "${BOLD}║${NC} Repo:        ${GITHUB_ORG}/${PROJECT_NAME}"
echo -e "${BOLD}║${NC} URL:         https://${PROJECT_NAME}.${LABS_DOMAIN}"
if $DRY_RUN; then
echo -e "${BOLD}║${NC} Mode:        ${YELLOW}DRY RUN${NC}"
fi
echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"

# Track what was created for error recovery reporting
CREATED_RESOURCES=()

report_created() {
    if [[ ${#CREATED_RESOURCES[@]} -gt 0 ]]; then
        echo ""
        echo -e "${BOLD}Resources created so far:${NC}"
        for r in "${CREATED_RESOURCES[@]}"; do
            echo "  - $r"
        done
        echo ""
        echo "Manual cleanup may be needed for these resources."
    fi
}
trap 'if [[ $? -ne 0 ]]; then echo ""; fail "Script failed. See error above."; report_created; fi' EXIT

# ════════════════════════════════════════════════════════════════════════════
# STEP 1 — Pre-flight checks
# ════════════════════════════════════════════════════════════════════════════

step "1" "Pre-flight checks"

CHECKS_PASSED=true

# CLI tools
for tool in gh git jq curl; do
    if command -v "$tool" &>/dev/null; then
        ok "$tool"
    else
        fail "$tool is not installed"
        CHECKS_PASSED=false
    fi
done

if ! $SKIP_SUPABASE; then
    if command -v supabase &>/dev/null; then
        ok "supabase CLI"
    else
        fail "supabase CLI not installed (use --skip-supabase to skip)"
        CHECKS_PASSED=false
    fi
fi

if ! $SKIP_VERCEL; then
    if command -v vercel &>/dev/null; then
        ok "vercel CLI"
    else
        fail "vercel CLI not installed (use --skip-vercel to skip)"
        CHECKS_PASSED=false
    fi
fi

# Auth checks
if gh auth status &>/dev/null 2>&1; then
    ok "GitHub authenticated"
else
    fail "GitHub not authenticated (run: gh auth login)"
    CHECKS_PASSED=false
fi

if ! $SKIP_VERCEL; then
    if [[ -n "${VERCEL_TOKEN:-}" ]]; then
        ok "VERCEL_TOKEN set"
    else
        fail "VERCEL_TOKEN not set"
        CHECKS_PASSED=false
    fi
    if [[ -n "${VERCEL_ORG_ID:-}" ]]; then
        ok "VERCEL_ORG_ID set"
    else
        fail "VERCEL_ORG_ID not set"
        CHECKS_PASSED=false
    fi
fi

if ! $SKIP_SUPABASE; then
    if [[ -n "$RESOLVED_SUPABASE_ORG" ]]; then
        ok "Supabase org ID resolved ($RESOLVED_SUPABASE_ORG)"
    else
        fail "No Supabase org ID found."
        echo ""
        echo "  Set one of:"
        echo "    --supabase-org <id>                  (per-spinup)"
        echo "    export LAB_SUPABASE_ORG_ID=<id>      (recommended: Friends Lab CI org)"
        echo "    export SUPABASE_ORG_ID=<id>          (fallback)"
        echo ""
        echo "  Available Supabase orgs:"
        supabase orgs list 2>/dev/null || echo "    (could not list — run: supabase orgs list)"
        echo ""
        CHECKS_PASSED=false
    fi
fi

if ! $CHECKS_PASSED; then
    echo ""
    fail "Pre-flight checks failed. Fix the issues above and try again."
    exit 1
fi

ok "All pre-flight checks passed"

if $DRY_RUN; then
    echo ""
    echo -e "${BOLD}── Dry-run plan ──${NC}"
    echo ""
    dry "Create GitHub repo: ${GITHUB_ORG}/${PROJECT_NAME} (from ${GITHUB_ORG}/${TEMPLATE_REPO})"
    dry "Clone to working directory"
    if [[ -n "$EXTENSIONS" ]]; then
        for ext in $EXTENSIONS; do
            dry "Apply extension: $ext (copy from lab-extensions/$ext/)"
        done
    else
        dry "No extensions to apply (prototype type)"
    fi
    dry "Remove lab-extensions/ from new project"
    dry "Update CLAUDE.md with project context"
    dry "Update package.json name to $PROJECT_NAME"
    dry "Create develop branch, set as default"
    dry "Set branch protection on main"
    dry "Commit and push: chore: initial project setup (type: $PROJECT_TYPE)"
    if ! $SKIP_VERCEL; then
        dry "Create Vercel project linked to GitHub repo"
        dry "Set Vercel environment variables"
        dry "Configure custom domain: ${PROJECT_NAME}.${LABS_DOMAIN}"
    else
        dry "Skip Vercel provisioning (--skip-vercel)"
    fi
    if ! $SKIP_SUPABASE; then
        dry "Create Supabase project: $PROJECT_NAME"
        dry "Wait for Supabase provisioning"
        dry "Retrieve API keys"
        dry "Push database migrations"
    else
        dry "Skip Supabase provisioning (--skip-supabase)"
    fi
    dry "Set GitHub secrets for CI"
    if ! $SKIP_ISSUES; then
        ISSUES_TEMPLATE="$(issues_template_for_type "$PROJECT_TYPE")"
        if [[ -n "$ISSUES_TEMPLATE" ]]; then
            dry "Create starter issues from $ISSUES_TEMPLATE"
        else
            dry "Skip starter issues (no template for $PROJECT_TYPE yet)"
        fi
        dry "Create project board"
    fi
    dry "Output success summary"
    echo ""
    echo -e "${GREEN}Dry run complete. No resources were created.${NC}"
    exit 0
fi

# ════════════════════════════════════════════════════════════════════════════
# STEP 2 — Create GitHub repo from template
# ════════════════════════════════════════════════════════════════════════════

step "2" "GitHub repository"

if gh repo view "${GITHUB_ORG}/${PROJECT_NAME}" &>/dev/null 2>&1; then
    skip_msg "GitHub repo ${GITHUB_ORG}/${PROJECT_NAME}"
    REPO_EXISTS=true
else
    gh repo create "${GITHUB_ORG}/${PROJECT_NAME}" \
        --template "${GITHUB_ORG}/${TEMPLATE_REPO}" \
        --private \
        --description "$DESCRIPTION"

    ok "Repo created: ${GITHUB_ORG}/${PROJECT_NAME}"
    CREATED_RESOURCES+=("GitHub repo: https://github.com/${GITHUB_ORG}/${PROJECT_NAME}")
    REPO_EXISTS=false

    # Wait for template copy to complete
    sleep 3
fi

# ════════════════════════════════════════════════════════════════════════════
# STEP 3 — Clone and apply extensions
# ════════════════════════════════════════════════════════════════════════════

step "3" "Clone and apply extensions"

WORK_DIR="/tmp/spinup-${PROJECT_NAME}-$$"
if [[ -d "$WORK_DIR" ]]; then
    rm -rf "$WORK_DIR"
fi

git clone "https://github.com/${GITHUB_ORG}/${PROJECT_NAME}.git" "$WORK_DIR"
ok "Cloned to $WORK_DIR"

cd "$WORK_DIR"

# Apply extensions
if [[ -n "$EXTENSIONS" ]]; then
    EXT_DIR="$WORK_DIR/lab-extensions"
    if [[ ! -d "$EXT_DIR" ]]; then
        fail "lab-extensions/ directory not found in template. Cannot apply extensions."
        echo "  Ensure ${GITHUB_ORG}/${TEMPLATE_REPO} has a lab-extensions/ directory."
        exit 1
    fi

    for ext in $EXTENSIONS; do
        EXT_SRC="$EXT_DIR/$ext"
        if [[ ! -d "$EXT_SRC" ]]; then
            warn "Extension directory not found: lab-extensions/$ext/ — skipping"
            continue
        fi

        info "Applying extension: $ext"

        # Copy migrations
        if [[ -d "$EXT_SRC/migrations" ]]; then
            mkdir -p "$WORK_DIR/supabase/migrations"
            cp "$EXT_SRC/migrations/"*.sql "$WORK_DIR/supabase/migrations/" 2>/dev/null || true
            ok "  Migrations copied"
        fi

        # Copy lib code
        if [[ -d "$EXT_SRC/lib" ]]; then
            mkdir -p "$WORK_DIR/src/lib"
            cp "$EXT_SRC/lib/"* "$WORK_DIR/src/lib/" 2>/dev/null || true
            ok "  Lib code copied"
        fi

        # Copy components
        if [[ -d "$EXT_SRC/components" ]]; then
            mkdir -p "$WORK_DIR/src/components"
            cp "$EXT_SRC/components/"* "$WORK_DIR/src/components/" 2>/dev/null || true
            ok "  Components copied"
        fi

        # Copy tests
        if [[ -d "$EXT_SRC/tests" ]]; then
            mkdir -p "$WORK_DIR/tests"
            cp "$EXT_SRC/tests/"* "$WORK_DIR/tests/" 2>/dev/null || true
            ok "  Tests copied"
        fi

        # Copy RLS policies if present
        if [[ -d "$EXT_SRC/lib" ]] && ls "$EXT_SRC/lib/"*.sql &>/dev/null; then
            mkdir -p "$WORK_DIR/supabase"
            cp "$EXT_SRC/lib/"*.sql "$WORK_DIR/supabase/" 2>/dev/null || true
            ok "  SQL policies copied"
        fi
    done
else
    info "No extensions to apply (prototype type)"
fi

# Remove lab-extensions/ from the new project (it's source, not active code)
if [[ -d "$WORK_DIR/lab-extensions" ]]; then
    rm -rf "$WORK_DIR/lab-extensions"
    ok "Removed lab-extensions/ from project (source files, not active code)"
fi

# Remove the template's spinup.sh if it exists in the new project
if [[ -f "$WORK_DIR/operations/automation/spinup.sh" ]]; then
    rm -rf "$WORK_DIR/operations"
    ok "Removed operations/ directory (spinup lives in playbook, not projects)"
fi

# ════════════════════════════════════════════════════════════════════════════
# STEP 4 — Customize project files
# ════════════════════════════════════════════════════════════════════════════

step "4" "Customize project files"

# Update CLAUDE.md with project-specific context
if [[ -f "$WORK_DIR/CLAUDE.md" ]]; then
    GITHUB_URL="https://github.com/${GITHUB_ORG}/${PROJECT_NAME}"
    DEPLOY_URL="https://${PROJECT_NAME}.${LABS_DOMAIN}"

    # Replace all known placeholders
    # macOS sed uses -i '' while GNU sed uses -i (try both)
    _sed_inplace() {
        sed -i '' "$@" 2>/dev/null || sed -i "$@" 2>/dev/null || true
    }
    _sed_inplace "s/\[PROJECT_NAME\]/${PROJECT_NAME}/g" "$WORK_DIR/CLAUDE.md"
    _sed_inplace "s|\[GitHub URL\]|${GITHUB_URL}|g" "$WORK_DIR/CLAUDE.md"
    _sed_inplace "s|\[URL\]|${DEPLOY_URL}|g" "$WORK_DIR/CLAUDE.md"

    # Substitute [Brief description] with --description if provided, otherwise leave a TODO
    if [[ -n "$DESCRIPTION" && "$DESCRIPTION" != "Friends Innovation Lab"* ]]; then
        _sed_inplace "s/\[Brief description\]/${DESCRIPTION}/g" "$WORK_DIR/CLAUDE.md"
    else
        _sed_inplace "s/\[Brief description\]/TODO: Add project description/g" "$WORK_DIR/CLAUDE.md"
    fi

    # Add project type and extensions info
    EXTENSIONS_LIST="${EXTENSIONS:-none}"
    {
        echo ""
        echo "## Project Setup"
        echo ""
        echo "- **Type:** $PROJECT_TYPE"
        echo "- **Extensions:** $EXTENSIONS_LIST"
        echo "- **Theme:** $AGENCY_THEME"
        echo "- **Created:** $(date +%Y-%m-%d) by spinup-typed.sh v${VERSION}"
    } >> "$WORK_DIR/CLAUDE.md"

    ok "CLAUDE.md updated with project context"
fi

# Update package.json name
if [[ -f "$WORK_DIR/package.json" ]]; then
    # Use jq to update the name field
    TMP_PKG="$(mktemp)"
    jq --arg name "$PROJECT_NAME" '.name = $name' "$WORK_DIR/package.json" > "$TMP_PKG" && \
        mv "$TMP_PKG" "$WORK_DIR/package.json"
    ok "package.json name set to $PROJECT_NAME"
fi

# Set agency theme in .env.example if it exists
if [[ -f "$WORK_DIR/.env.example" ]]; then
    sed -i '' "s/NEXT_PUBLIC_AGENCY_THEME=.*/NEXT_PUBLIC_AGENCY_THEME=${AGENCY_THEME}/" "$WORK_DIR/.env.example" 2>/dev/null || \
    sed -i "s/NEXT_PUBLIC_AGENCY_THEME=.*/NEXT_PUBLIC_AGENCY_THEME=${AGENCY_THEME}/" "$WORK_DIR/.env.example" 2>/dev/null || true
    ok "Agency theme set to $AGENCY_THEME in .env.example"
fi

# ════════════════════════════════════════════════════════════════════════════
# STEP 5 — Git setup (develop branch, protection, initial commit)
# ════════════════════════════════════════════════════════════════════════════

step "5" "Git configuration"

cd "$WORK_DIR"

# Stage and commit extension changes
if [[ -n "$(git status --porcelain)" ]]; then
    git add -A
    git commit -m "chore: initial project setup (type: ${PROJECT_TYPE}, extensions: ${EXTENSIONS:-none})"
    ok "Initial setup committed"
fi

git push origin main
ok "Pushed to main"

# Create and push develop branch
if git ls-remote --heads origin develop | grep -q develop; then
    skip_msg "develop branch"
else
    git checkout -b develop
    git push -u origin develop
    ok "develop branch created and pushed"
fi

# Set develop as default branch
gh repo edit "${GITHUB_ORG}/${PROJECT_NAME}" --default-branch develop 2>/dev/null || true
ok "Default branch set to develop"

# Branch protection on main
if gh api "repos/${GITHUB_ORG}/${PROJECT_NAME}/branches/main/protection" &>/dev/null 2>&1; then
    skip_msg "Branch protection on main"
else
    PROTECTION_PAYLOAD="$(cat <<PROTEOF
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
PROTEOF
)"
    if echo "$PROTECTION_PAYLOAD" | gh api "repos/${GITHUB_ORG}/${PROJECT_NAME}/branches/main/protection" \
        --method PUT --input - 2>/dev/null; then
        ok "Branch protection set on main"
    else
        warn "Could not set branch protection on main — set manually"
    fi
fi

# ════════════════════════════════════════════════════════════════════════════
# STEP 6 — Supabase setup
# ════════════════════════════════════════════════════════════════════════════

SUPABASE_URL_VALUE=""
SUPABASE_ANON_KEY=""
SUPABASE_SERVICE_ROLE_KEY=""
SUPABASE_PROJECT_REF=""

if $SKIP_SUPABASE; then
    step "6" "Supabase (skipped)"
    info "Skipping Supabase provisioning (--skip-supabase)"
else
    step "6" "Supabase"

    # Check if project already exists
    EXISTING_REF="$(supabase projects list 2>/dev/null | grep "$PROJECT_NAME" | awk '{print $1}' || echo "")"

    if [[ -n "$EXISTING_REF" ]]; then
        skip_msg "Supabase project $PROJECT_NAME (ref: $EXISTING_REF)"
        SUPABASE_PROJECT_REF="$EXISTING_REF"
    else
        SUPABASE_DB_PASSWORD="$(openssl rand -base64 32 | tr -dc 'A-Za-z0-9' | head -c 32)"

        CREATE_OUTPUT="$(supabase projects create "${PROJECT_NAME}" \
            --org-id "$RESOLVED_SUPABASE_ORG" \
            --region us-east-1 \
            --db-password "$SUPABASE_DB_PASSWORD" 2>&1)"

        if [[ $? -ne 0 ]]; then
            fail "Supabase project creation failed"
            echo "$CREATE_OUTPUT"
            exit 1
        fi

        # Extract project ref
        SUPABASE_PROJECT_REF="$(echo "$CREATE_OUTPUT" | grep -oE '[a-z]{20}' | head -1)"
        if [[ -z "$SUPABASE_PROJECT_REF" ]]; then
            sleep 3
            SUPABASE_PROJECT_REF="$(supabase projects list 2>/dev/null | grep "$PROJECT_NAME" | awk '{print $1}')"
        fi

        if [[ -z "$SUPABASE_PROJECT_REF" ]]; then
            fail "Could not determine Supabase project ref"
            exit 1
        fi

        ok "Supabase project created (ref: $SUPABASE_PROJECT_REF)"
        CREATED_RESOURCES+=("Supabase project: $SUPABASE_PROJECT_REF ($PROJECT_NAME)")
    fi

    SUPABASE_URL_VALUE="https://${SUPABASE_PROJECT_REF}.supabase.co"

    # Wait for provisioning
    info "Waiting for Supabase to provision..."
    SUPABASE_READY=false
    for _ in {1..12}; do
        STATUS="$(supabase projects list 2>/dev/null | grep "$PROJECT_NAME" | awk '{print $NF}')"
        if [[ "$STATUS" == "ACTIVE_HEALTHY" ]]; then
            SUPABASE_READY=true
            break
        fi
        sleep 5
    done

    if $SUPABASE_READY; then
        ok "Supabase is ready"
    else
        warn "Supabase not yet ready — API keys and migrations may fail"
    fi

    # Get API keys
    info "Fetching API keys..."
    for attempt in {1..10}; do
        SUPABASE_ANON_KEY="$(supabase projects api-keys \
            --project-ref "$SUPABASE_PROJECT_REF" \
            --output json 2>/dev/null \
            | jq -r '.[] | select(.name=="anon") | .api_key' 2>/dev/null || echo "")"

        SUPABASE_SERVICE_ROLE_KEY="$(supabase projects api-keys \
            --project-ref "$SUPABASE_PROJECT_REF" \
            --output json 2>/dev/null \
            | jq -r '.[] | select(.name=="service_role") | .api_key' 2>/dev/null || echo "")"

        if [[ -n "$SUPABASE_ANON_KEY" && -n "$SUPABASE_SERVICE_ROLE_KEY" ]]; then
            ok "API keys retrieved (attempt $attempt)"
            break
        fi
        sleep 5
    done

    if [[ -z "$SUPABASE_ANON_KEY" ]]; then
        warn "Could not retrieve Supabase API keys. Get them manually from:"
        echo "  https://supabase.com/dashboard/project/${SUPABASE_PROJECT_REF}/settings/api"
    fi

    # Push migrations (includes extension migrations if applied)
    if $SUPABASE_READY && [[ -d "$WORK_DIR/supabase/migrations" ]]; then
        cd "$WORK_DIR"
        if supabase link --project-ref "$SUPABASE_PROJECT_REF" 2>/dev/null && \
           supabase db push --project-ref "$SUPABASE_PROJECT_REF" 2>/dev/null; then
            ok "Database migrations applied (including extensions)"
        else
            warn "Could not apply migrations. Run manually:"
            echo "  supabase link --project-ref $SUPABASE_PROJECT_REF"
            echo "  supabase db push"
        fi
    fi

    # Configure auth redirect URLs
    if [[ -n "${SUPABASE_ACCESS_TOKEN:-}" ]]; then
        curl -s -X PATCH \
            "https://api.supabase.com/v1/projects/${SUPABASE_PROJECT_REF}/config/auth" \
            -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{
                \"site_url\": \"https://${PROJECT_NAME}.${LABS_DOMAIN}\",
                \"additional_redirect_urls\": [
                    \"https://${PROJECT_NAME}.${LABS_DOMAIN}/auth/callback\",
                    \"https://*.vercel.app/auth/callback\",
                    \"http://localhost:3000/auth/callback\"
                ],
                \"disable_signup\": false,
                \"mailer_autoconfirm\": true
            }" >/dev/null 2>&1
        ok "Auth redirect URLs configured"
    else
        warn "SUPABASE_ACCESS_TOKEN not set — configure auth redirects manually"
    fi

    # Write Supabase credentials to .env.local for local development
    if [[ -n "$SUPABASE_ANON_KEY" ]]; then
        ENV_LOCAL_PATH="${WORK_DIR}/.env.local"

        # Create .env.local from .env.example if it exists, otherwise create empty
        if [[ -f "${WORK_DIR}/.env.example" && ! -f "$ENV_LOCAL_PATH" ]]; then
            cp "${WORK_DIR}/.env.example" "$ENV_LOCAL_PATH"
            info "Created .env.local from .env.example"
        elif [[ ! -f "$ENV_LOCAL_PATH" ]]; then
            touch "$ENV_LOCAL_PATH"
        fi

        # Append Supabase credentials
        cat >> "$ENV_LOCAL_PATH" <<EOF

# Supabase (auto-populated by spinup-typed.sh)
NEXT_PUBLIC_SUPABASE_URL=${SUPABASE_URL_VALUE}
NEXT_PUBLIC_SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
EOF
        ok "Supabase credentials added to .env.local"
    else
        warn "Could not write Supabase credentials to .env.local (keys not available)"
        echo "  Add them manually from: https://supabase.com/dashboard/project/${SUPABASE_PROJECT_REF}/settings/api"
    fi
fi

# ════════════════════════════════════════════════════════════════════════════
# STEP 7 — Vercel setup
# ════════════════════════════════════════════════════════════════════════════

VERCEL_PROJECT_ID=""

if $SKIP_VERCEL; then
    step "7" "Vercel (skipped)"
    info "Skipping Vercel provisioning (--skip-vercel)"
else
    step "7" "Vercel"

    # Check if project exists
    VERCEL_CHECK="$(curl -s -o /dev/null -w "%{http_code}" \
        "https://api.vercel.com/v9/projects/${PROJECT_NAME}" \
        -H "Authorization: Bearer $VERCEL_TOKEN")"

    if [[ "$VERCEL_CHECK" == "200" ]]; then
        skip_msg "Vercel project $PROJECT_NAME"
        VERCEL_PROJECT_ID="$(curl -s \
            "https://api.vercel.com/v9/projects/${PROJECT_NAME}" \
            -H "Authorization: Bearer $VERCEL_TOKEN" | jq -r '.id')"
    else
        VERCEL_CREATE="$(curl -s -X POST "https://api.vercel.com/v10/projects" \
            -H "Authorization: Bearer $VERCEL_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{
                \"name\": \"${PROJECT_NAME}\",
                \"framework\": \"nextjs\",
                \"gitRepository\": {
                    \"type\": \"github\",
                    \"repo\": \"${GITHUB_ORG}/${PROJECT_NAME}\"
                }
            }")"

        VERCEL_PROJECT_ID="$(echo "$VERCEL_CREATE" | jq -r '.id // empty')"

        if [[ -z "$VERCEL_PROJECT_ID" ]]; then
            fail "Vercel project creation failed"
            echo "$VERCEL_CREATE" | jq '.error' 2>/dev/null || echo "$VERCEL_CREATE"
            exit 1
        fi

        ok "Vercel project created"
        CREATED_RESOURCES+=("Vercel project: $PROJECT_NAME (ID: $VERCEL_PROJECT_ID)")
    fi

    # Set environment variables
    info "Setting environment variables..."
    VERCEL_ENV_ERRORS=0

    set_vercel_env() {
        local key="$1" value="$2" targets="$3"
        local response
        response="$(curl -s -X POST "https://api.vercel.com/v10/projects/${PROJECT_NAME}/env" \
            -H "Authorization: Bearer $VERCEL_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{\"key\":\"${key}\",\"value\":\"${value}\",\"type\":\"encrypted\",\"target\":${targets}}")"

        local error_code
        error_code="$(echo "$response" | jq -r '.error.code // empty' 2>/dev/null)"
        if [[ -n "$error_code" && "$error_code" != "ENV_ALREADY_EXISTS" ]]; then
            VERCEL_ENV_ERRORS=$((VERCEL_ENV_ERRORS + 1))
        fi
    }

    ALL='["production","preview","development"]'
    PROD='["production"]'
    PREVIEW='["preview"]'
    DEV='["development"]'

    # Supabase vars
    if [[ -n "$SUPABASE_URL_VALUE" ]]; then
        set_vercel_env "NEXT_PUBLIC_SUPABASE_URL" "$SUPABASE_URL_VALUE" "$ALL"
        set_vercel_env "NEXT_PUBLIC_SUPABASE_ANON_KEY" "$SUPABASE_ANON_KEY" "$ALL"
        set_vercel_env "SUPABASE_SERVICE_ROLE_KEY" "$SUPABASE_SERVICE_ROLE_KEY" "$ALL"
    fi

    # App vars
    set_vercel_env "NEXT_PUBLIC_APP_NAME" "$PROJECT_NAME" "$ALL"
    set_vercel_env "NEXT_PUBLIC_AGENCY_THEME" "$AGENCY_THEME" "$ALL"
    set_vercel_env "NEXT_PUBLIC_APP_URL" "https://${PROJECT_NAME}.${LABS_DOMAIN}" "$PROD"
    set_vercel_env "NEXT_PUBLIC_APP_URL" "https://${PROJECT_NAME}-*.vercel.app" "$PREVIEW"
    set_vercel_env "NEXT_PUBLIC_APP_URL" "http://localhost:3000" "$DEV"
    set_vercel_env "NEXT_PUBLIC_ENABLE_ANALYTICS" "true" "$ALL"
    set_vercel_env "NEXT_PUBLIC_MAINTENANCE_MODE" "false" "$ALL"
    set_vercel_env "SENTRY_ORG" "friends-innovation-lab" "$ALL"
    set_vercel_env "SENTRY_PROJECT" "$PROJECT_NAME" "$ALL"
    set_vercel_env "RESEND_FROM_EMAIL" "noreply@${LABS_DOMAIN}" "$ALL"

    if [[ $VERCEL_ENV_ERRORS -gt 0 ]]; then
        warn "$VERCEL_ENV_ERRORS env var(s) failed to set — check Vercel dashboard"
    else
        ok "Environment variables set"
    fi

    # Custom domain
    curl -s -X POST "https://api.vercel.com/v10/projects/${PROJECT_NAME}/domains" \
        -H "Authorization: Bearer $VERCEL_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"${PROJECT_NAME}.${LABS_DOMAIN}\"}" >/dev/null 2>&1

    ok "Custom domain configured: ${PROJECT_NAME}.${LABS_DOMAIN}"
    CREATED_RESOURCES+=("Vercel domain: ${PROJECT_NAME}.${LABS_DOMAIN}")
fi

# ════════════════════════════════════════════════════════════════════════════
# STEP 8 — GitHub secrets for CI
# ════════════════════════════════════════════════════════════════════════════

step "8" "GitHub secrets"

if [[ -n "$SUPABASE_URL_VALUE" ]]; then
    echo "$SUPABASE_URL_VALUE" | gh secret set NEXT_PUBLIC_SUPABASE_URL \
        --repo "${GITHUB_ORG}/${PROJECT_NAME}" 2>/dev/null && \
        ok "NEXT_PUBLIC_SUPABASE_URL" || warn "Could not set NEXT_PUBLIC_SUPABASE_URL secret"
fi

if [[ -n "$SUPABASE_ANON_KEY" ]]; then
    echo "$SUPABASE_ANON_KEY" | gh secret set NEXT_PUBLIC_SUPABASE_ANON_KEY \
        --repo "${GITHUB_ORG}/${PROJECT_NAME}" 2>/dev/null && \
        ok "NEXT_PUBLIC_SUPABASE_ANON_KEY" || warn "Could not set NEXT_PUBLIC_SUPABASE_ANON_KEY secret"
fi

if [[ -n "${VERCEL_TOKEN:-}" ]]; then
    echo "$VERCEL_TOKEN" | gh secret set VERCEL_TOKEN \
        --repo "${GITHUB_ORG}/${PROJECT_NAME}" 2>/dev/null && \
        ok "VERCEL_TOKEN" || warn "Could not set VERCEL_TOKEN secret"
fi

# ════════════════════════════════════════════════════════════════════════════
# STEP 9 — Labels and issues (optional)
# ════════════════════════════════════════════════════════════════════════════

if $SKIP_ISSUES; then
    step "9" "Issues (skipped)"
    info "Skipping issue creation (--skip-issues)"
else
    step "9" "Labels and issues"

    cd "$WORK_DIR"

    # Clean default labels and add lab-standard labels
    for label in bug documentation duplicate enhancement "good first issue" "help wanted" invalid question wontfix; do
        gh label delete "$label" --repo "${GITHUB_ORG}/${PROJECT_NAME}" --yes 2>/dev/null || true
    done

    gh label create "bug" --color "d73a4a" --description "Something isn't working" --repo "${GITHUB_ORG}/${PROJECT_NAME}" 2>/dev/null || true
    gh label create "feature" --color "0075ca" --description "New feature or request" --repo "${GITHUB_ORG}/${PROJECT_NAME}" 2>/dev/null || true
    gh label create "design" --color "e4e669" --description "Design work needed" --repo "${GITHUB_ORG}/${PROJECT_NAME}" 2>/dev/null || true
    gh label create "blocked" --color "e11d48" --description "Blocked by something" --repo "${GITHUB_ORG}/${PROJECT_NAME}" 2>/dev/null || true
    gh label create "in progress" --color "0052cc" --description "Currently being worked on" --repo "${GITHUB_ORG}/${PROJECT_NAME}" 2>/dev/null || true
    gh label create "review needed" --color "8b5cf6" --description "Needs review before merging" --repo "${GITHUB_ORG}/${PROJECT_NAME}" 2>/dev/null || true
    gh label create "accessibility" --color "1d9e75" --description "Accessibility related" --repo "${GITHUB_ORG}/${PROJECT_NAME}" 2>/dev/null || true

    ok "Labels configured"

    # Create starter issues from template
    # Note: template includes a "week" field that's currently unused
    # Future enhancement: use week to schedule issues across time
    ISSUES_TEMPLATE="$(issues_template_for_type "$PROJECT_TYPE")"
    ISSUES_TEMPLATE_PATH="${SCRIPT_DIR}/templates/${ISSUES_TEMPLATE}"

    if [[ -n "$ISSUES_TEMPLATE" && -f "$ISSUES_TEMPLATE_PATH" ]]; then
        info "Creating starter issues from ${ISSUES_TEMPLATE}..."
        ISSUE_COUNT=0
        ISSUE_ERRORS=0

        # Parse JSON template and create issues
        # Each issue: { "title": "...", "body": "...", "labels": [...], "week": N }
        ISSUE_ITEMS="$(jq -c '.[]' "$ISSUES_TEMPLATE_PATH" 2>/dev/null)"

        while IFS= read -r issue; do
            ISSUE_TITLE="$(echo "$issue" | jq -r '.title')"
            ISSUE_BODY="$(echo "$issue" | jq -r '.body')"
            ISSUE_LABELS="$(echo "$issue" | jq -r '.labels | join(",")')"

            # Handle empty labels defensively
            if [[ -n "$ISSUE_LABELS" ]]; then
                LABEL_FLAG="--label $ISSUE_LABELS"
            else
                LABEL_FLAG=""
            fi

            ISSUE_ERROR_OUTPUT=$(gh issue create \
                --repo "${GITHUB_ORG}/${PROJECT_NAME}" \
                --title "$ISSUE_TITLE" \
                --body "$ISSUE_BODY" \
                $LABEL_FLAG 2>&1)

            if [[ $? -eq 0 ]]; then
                ISSUE_COUNT=$((ISSUE_COUNT + 1))
            else
                ISSUE_ERRORS=$((ISSUE_ERRORS + 1))
                warn "Failed to create issue: $ISSUE_TITLE"
                warn "  Error: $ISSUE_ERROR_OUTPUT"
            fi
        done <<< "$ISSUE_ITEMS"

        if [[ $ISSUE_ERRORS -gt 0 ]]; then
            warn "Created $ISSUE_COUNT issues ($ISSUE_ERRORS failed)"
        else
            ok "Created $ISSUE_COUNT starter issues"
        fi
    elif [[ -n "$ISSUES_TEMPLATE" && ! -f "$ISSUES_TEMPLATE_PATH" ]]; then
        warn "Starter issues template not found: ${ISSUES_TEMPLATE}"
    else
        # No template for this type (saas-web, ai-product)
        # TODO: Create templates for saas-web and ai-product types
        info "No starter issues template for ${PROJECT_TYPE} yet — skipping issue creation"
    fi

    # Create project board
    gh project create --owner "${GITHUB_ORG}" --title "${PROJECT_NAME}" --format board 2>/dev/null || true
    ok "Project board created"
fi

# ════════════════════════════════════════════════════════════════════════════
# STEP 10 — Success summary
# ════════════════════════════════════════════════════════════════════════════

step "10" "Complete"

SUPABASE_DASHBOARD="(skipped)"
if [[ -n "$SUPABASE_PROJECT_REF" ]]; then
    SUPABASE_DASHBOARD="https://supabase.com/dashboard/project/${SUPABASE_PROJECT_REF}"
fi

VERCEL_DASH="(skipped)"
if [[ -n "$VERCEL_PROJECT_ID" ]]; then
    VERCEL_DASH="https://vercel.com/${GITHUB_ORG}/${PROJECT_NAME}"
fi

echo ""
echo -e "${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   Project created successfully                             ║${NC}"
echo -e "${BOLD}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${BOLD}║${NC} ${BOLD}PROJECT${NC}"
echo -e "${BOLD}║${NC}   Name:          $PROJECT_NAME"
echo -e "${BOLD}║${NC}   Type:          $PROJECT_TYPE"
echo -e "${BOLD}║${NC}   Extensions:    ${EXTENSIONS:-none}"
echo -e "${BOLD}║${NC}   Theme:         $AGENCY_THEME"
echo -e "${BOLD}║${NC}"
echo -e "${BOLD}║${NC} ${BOLD}LINKS${NC}"
echo -e "${BOLD}║${NC}   GitHub:        https://github.com/${GITHUB_ORG}/${PROJECT_NAME}"
echo -e "${BOLD}║${NC}   Live URL:      https://${PROJECT_NAME}.${LABS_DOMAIN}"
echo -e "${BOLD}║${NC}   Vercel:        $VERCEL_DASH"
echo -e "${BOLD}║${NC}   Supabase:      $SUPABASE_DASHBOARD"
echo -e "${BOLD}║${NC}"
echo -e "${BOLD}║${NC} ${BOLD}LOCAL${NC}"
echo -e "${BOLD}║${NC}   Working dir:   $WORK_DIR"
echo -e "${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo "  1. cd $WORK_DIR"
echo "  2. Your .env.local has Supabase credentials. You can run 'npm run dev' immediately."
echo "  3. npm install"
echo "  4. npm run dev"
echo "  5. Read CLAUDE.md before asking CC to build anything"
echo ""
if [[ -n "$EXTENSIONS" ]]; then
    echo -e "${BOLD}Extensions applied:${NC}"
    for ext in $EXTENSIONS; do
        echo "  - $ext (see lab-standards for documentation)"
    done
    echo ""
fi
echo -e "${BOLD}Manual setup still needed:${NC}"
echo "  [ ] Create Sentry project and add DSN to .env.local"
echo "  [ ] Add Resend API key if project sends emails"
if [[ -n "$EXTENSIONS" ]]; then
    echo "  [ ] Review extension migrations in supabase/migrations/"
    echo "  [ ] Run extension tests: npm test"
fi
echo ""
echo -e "${GREEN}Done!${NC} Project $PROJECT_NAME is ready."
