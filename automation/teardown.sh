#!/bin/bash

# Friends Innovation Lab - Project Teardown Script
# This script decommissions a project and removes all associated infrastructure.
# Run it and follow the prompts.
#
# Usage:
#   ./teardown.sh              # Interactive teardown
#   ./teardown.sh --dry-run    # Preview what would happen without doing it

set -e

# ─────────────────────────────────────────────────────────
# Parse command-line arguments
# ─────────────────────────────────────────────────────────
DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=true
      ;;
    --help|-h)
      echo "Usage: ./teardown.sh [--dry-run]"
      echo ""
      echo "Options:"
      echo "  --dry-run    Preview what would happen without making changes"
      echo "  --help       Show this help message"
      exit 0
      ;;
  esac
done

# ─────────────────────────────────────────────────────────
# Colors
# ─────────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Resolve the directory where this script lives (for playbook repo path)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYBOOK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ─────────────────────────────────────────────────────────
# Helper functions
# ─────────────────────────────────────────────────────────
ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }
dry()  { echo -e "  ${YELLOW}[DRY RUN]${NC} Would: $1"; }

# ─────────────────────────────────────────────────────────
# JSON-safe command helpers (Layer 2 safety)
# ─────────────────────────────────────────────────────────

# Run a command and exit with clear error if it fails
# Usage: output=$(run_or_die "description" command arg1 arg2)
run_or_die() {
  local description="$1"
  shift
  local output
  output=$("$@" 2>&1)
  local exit_code=$?
  if [ $exit_code -ne 0 ]; then
    echo ""
    echo -e "${RED}ERROR during: $description${NC}"
    echo "Command: $*"
    echo "Exit code: $exit_code"
    echo "Output:"
    echo "$output"
    exit 1
  fi
  echo "$output"
}

# Validate input is JSON, exit with clear error if not
# Usage: validated=$(parse_json_or_die "description" "$raw_output")
parse_json_or_die() {
  local description="$1"
  local input="$2"
  if ! echo "$input" | jq empty 2>/dev/null; then
    echo ""
    echo -e "${RED}ERROR: Expected JSON for '$description' but got:${NC}"
    echo "$input" | head -20
    echo ""
    echo "This usually means the CLI printed a warning to stdout that"
    echo "contaminated the JSON output."
    exit 1
  fi
  echo "$input"
}

# ─────────────────────────────────────────────────────────
# State file helpers (Layer 3 idempotency)
# ─────────────────────────────────────────────────────────

# State file tracks teardown progress for resumability
# Format: key=value pairs, one per line
# Keys: supabase_backup, supabase_delete, vercel_delete, github_archive, local_delete
# Values: done, skipped

STATE_FILE=""  # Set after project name is known

# Check if a step is already complete in the state file
# Usage: if step_done "supabase_backup"; then skip; fi
step_done() {
  local step="$1"
  [ -f "$STATE_FILE" ] && grep -q "^${step}=done$" "$STATE_FILE"
}

# Mark a step as complete in the state file (no-op in dry-run mode)
# Usage: mark_done "supabase_backup"
mark_done() {
  local step="$1"
  if $DRY_RUN; then return 0; fi
  echo "${step}=done" >> "$STATE_FILE"
}

# Mark a step as skipped in the state file (no-op in dry-run mode)
# Usage: mark_skipped "supabase_backup"
mark_skipped() {
  local step="$1"
  if $DRY_RUN; then return 0; fi
  echo "${step}=skipped" >> "$STATE_FILE"
}

# ═════════════════════════════════════════════════════════
# STEP 0 — Welcome
# ═════════════════════════════════════════════════════════
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║   Friends Innovation Lab — Project Teardown ║"
echo "╚════════════════════════════════════════════╝"
echo ""
if $DRY_RUN; then
  echo -e "${YELLOW}DRY RUN MODE — no changes will be made${NC}"
  echo ""
  echo "This will preview what teardown would do without actually"
  echo "deleting anything. Use this to verify the script works"
  echo "before running for real."
else
  echo "This script will decommission a project and remove all"
  echo "associated infrastructure."
  echo ""
  echo "This cannot be undone. Read every prompt carefully."
fi
echo ""

# ═════════════════════════════════════════════════════════
# STEP 1 — Pre-flight checks
# ═════════════════════════════════════════════════════════
echo "Checking your setup..."
echo ""

CHECKS_PASSED=true

# --- CLI tools ---

if command -v gh &>/dev/null; then
  ok "gh (GitHub CLI)"
else
  fail "gh — GitHub CLI is not installed. Install it: brew install gh"
  CHECKS_PASSED=false
fi

if command -v supabase &>/dev/null; then
  ok "supabase (Supabase CLI)"
else
  fail "supabase — Supabase CLI is not installed. Install it: brew install supabase/tap/supabase"
  CHECKS_PASSED=false
fi

if command -v vercel &>/dev/null; then
  ok "vercel (Vercel CLI)"
else
  fail "vercel — Vercel CLI is not installed. Install it: npm install -g vercel"
  CHECKS_PASSED=false
fi

if command -v jq &>/dev/null; then
  ok "jq (JSON processor)"
else
  fail "jq — jq is not installed. Install it: brew install jq"
  CHECKS_PASSED=false
fi

if command -v curl &>/dev/null; then
  ok "curl"
else
  fail "curl — curl is not installed. It should come with macOS. Try: brew install curl"
  CHECKS_PASSED=false
fi

if command -v pg_dump &>/dev/null; then
  ok "pg_dump (PostgreSQL tools)"
else
  fail "pg_dump — PostgreSQL tools are not installed. Install them: brew install postgresql"
  CHECKS_PASSED=false
fi

# --- Authentications (using the same invocation patterns as downstream usage) ---

# GitHub: Test with --json to match how we use it downstream
GH_AUTH_OUTPUT=$(gh auth status 2>&1) || true
if echo "$GH_AUTH_OUTPUT" | grep -q "Logged in"; then
  ok "GitHub CLI is logged in"
else
  fail "GitHub CLI is not logged in. Run: gh auth login"
  echo "$GH_AUTH_OUTPUT" | head -5
  CHECKS_PASSED=false
fi

# Vercel: Test whoami which is what we use to verify auth
VERCEL_AUTH_OUTPUT=$(vercel whoami 2>&1) || true
VERCEL_AUTH_EXIT=$?
if [ $VERCEL_AUTH_EXIT -eq 0 ]; then
  ok "Vercel CLI is logged in"
else
  fail "Vercel CLI is not logged in. Run: vercel login"
  echo "$VERCEL_AUTH_OUTPUT" | head -5
  CHECKS_PASSED=false
fi

# Supabase: Use --output json and validate the response is actually JSON
# Note: Supabase CLI may print warnings to stderr (e.g., "Cannot find project ref")
# We capture stderr separately so it doesn't contaminate the JSON validation
SUPABASE_STDERR_FILE=$(mktemp)
trap 'rm -f "$SUPABASE_STDERR_FILE"' EXIT
SUPABASE_AUTH_OUTPUT=$(supabase projects list --output json 2>"$SUPABASE_STDERR_FILE") || true
SUPABASE_AUTH_EXIT=$?
SUPABASE_AUTH_STDERR=$(cat "$SUPABASE_STDERR_FILE")
rm -f "$SUPABASE_STDERR_FILE"

if [ $SUPABASE_AUTH_EXIT -ne 0 ]; then
  fail "Supabase CLI failed (exit code $SUPABASE_AUTH_EXIT). Run: supabase login"
  [ -n "$SUPABASE_AUTH_STDERR" ] && echo "$SUPABASE_AUTH_STDERR" | head -5
  [ -n "$SUPABASE_AUTH_OUTPUT" ] && echo "$SUPABASE_AUTH_OUTPUT" | head -5
  CHECKS_PASSED=false
elif ! echo "$SUPABASE_AUTH_OUTPUT" | jq empty 2>/dev/null; then
  fail "Supabase CLI returned output that isn't valid JSON."
  echo "  The CLI may be authenticated but printing warnings to stdout."
  echo "  Raw stdout:"
  echo "$SUPABASE_AUTH_OUTPUT" | head -10
  [ -n "$SUPABASE_AUTH_STDERR" ] && echo "  Stderr:" && echo "$SUPABASE_AUTH_STDERR" | head -5
  echo ""
  echo "  Common fix: run 'supabase unlink' in this folder, or run teardown"
  echo "  from a folder without a stale Supabase link."
  CHECKS_PASSED=false
else
  ok "Supabase CLI is logged in and returning clean JSON"
  # Cache the project list for later use in existence checks
  SUPABASE_PROJECTS_CACHE="$SUPABASE_AUTH_OUTPUT"
fi

# --- Environment variables ---

if [ -n "$VERCEL_TOKEN" ]; then
  ok "VERCEL_TOKEN is set"
else
  fail "VERCEL_TOKEN is not set. Get a token at vercel.com → Settings → Tokens, then add to your shell profile."
  CHECKS_PASSED=false
fi

if [ -n "$VERCEL_ORG_ID" ]; then
  ok "VERCEL_ORG_ID is set"
else
  fail "VERCEL_ORG_ID is not set. Find it at vercel.com → Settings → General → Team ID, then add to your shell profile."
  CHECKS_PASSED=false
fi

# GITHUB_ORG is optional — defaults to friends-innovation-lab (same as spinup-typed.sh)
GITHUB_ORG="${GITHUB_ORG:-friends-innovation-lab}"
ok "GITHUB_ORG: $GITHUB_ORG"

if [ -n "$SUPABASE_ACCESS_TOKEN" ]; then
  ok "SUPABASE_ACCESS_TOKEN is set"
else
  fail "SUPABASE_ACCESS_TOKEN is not set. Get a token at supabase.com → account → access tokens, then add to your shell profile."
  CHECKS_PASSED=false
fi

# LAB_DOMAIN is optional — defaults to lab.cityfriends.tech (same as spinup-typed.sh)
LAB_DOMAIN="${LAB_DOMAIN:-lab.cityfriends.tech}"
ok "LAB_DOMAIN: $LAB_DOMAIN"

echo ""

if [ "$CHECKS_PASSED" = false ]; then
  echo "Some things need to be set up before we can continue."
  echo "Fix the issues above and run this script again."
  exit 1
fi

echo "Everything looks good. Let's continue."
echo ""

# ═════════════════════════════════════════════════════════
# STEP 2 — Identify the project
# ═════════════════════════════════════════════════════════

# Question 1 — Project name
echo "What is the name of the project you want to tear down?"
echo "(This is the GitHub repo name, e.g. veteran-intake-tool)"
printf "> "
read -r PROJECT_NAME

echo ""

# ─────────────────────────────────────────────────────────
# Project existence checks across all systems
# ─────────────────────────────────────────────────────────

FOUND_IN_GITHUB=false
FOUND_IN_SUPABASE=false
FOUND_IN_VERCEL=false
SUPABASE_PROJECT_REF_CACHE=""

# Check GitHub
if gh repo view "${GITHUB_ORG}/${PROJECT_NAME}" &>/dev/null 2>&1; then
  FOUND_IN_GITHUB=true
fi

# Check Supabase (use cached project list from pre-flight)
if [ -n "$SUPABASE_PROJECTS_CACHE" ]; then
  SUPABASE_PROJECT_REF_CACHE=$(echo "$SUPABASE_PROJECTS_CACHE" | jq -r ".[] | select(.name==\"$PROJECT_NAME\") | .id" 2>/dev/null)
  if [ -n "$SUPABASE_PROJECT_REF_CACHE" ]; then
    FOUND_IN_SUPABASE=true
  fi
fi

# Check Vercel
VERCEL_CHECK_OUTPUT=$(curl -s \
  "https://api.vercel.com/v10/projects/${PROJECT_NAME}" \
  -H "Authorization: Bearer $VERCEL_TOKEN" 2>/dev/null)
# Only parse if response is valid JSON
if echo "$VERCEL_CHECK_OUTPUT" | jq empty 2>/dev/null; then
  VERCEL_PROJECT_ID_CACHE=$(echo "$VERCEL_CHECK_OUTPUT" | jq -r '.id // empty')
  if [ -n "$VERCEL_PROJECT_ID_CACHE" ]; then
    FOUND_IN_VERCEL=true
  fi
fi

# Build list of where project was found
FOUND_SYSTEMS=""
NOT_FOUND_SYSTEMS=""
if [ "$FOUND_IN_GITHUB" = true ]; then
  FOUND_SYSTEMS="${FOUND_SYSTEMS}GitHub, "
else
  NOT_FOUND_SYSTEMS="${NOT_FOUND_SYSTEMS}GitHub, "
fi
if [ "$FOUND_IN_SUPABASE" = true ]; then
  FOUND_SYSTEMS="${FOUND_SYSTEMS}Supabase, "
else
  NOT_FOUND_SYSTEMS="${NOT_FOUND_SYSTEMS}Supabase, "
fi
if [ "$FOUND_IN_VERCEL" = true ]; then
  FOUND_SYSTEMS="${FOUND_SYSTEMS}Vercel, "
else
  NOT_FOUND_SYSTEMS="${NOT_FOUND_SYSTEMS}Vercel, "
fi

# Trim trailing comma and space
FOUND_SYSTEMS="${FOUND_SYSTEMS%, }"
NOT_FOUND_SYSTEMS="${NOT_FOUND_SYSTEMS%, }"

# Handle different scenarios
if [ "$FOUND_IN_GITHUB" = false ] && [ "$FOUND_IN_SUPABASE" = false ] && [ "$FOUND_IN_VERCEL" = false ]; then
  echo -e "${RED}No project called ${PROJECT_NAME} was found in any system.${NC}"
  echo "Checked: GitHub, Supabase, Vercel"
  echo "Check the project name and try again."
  exit 1
fi

# Partial state: project exists in some systems but not others
if [ -n "$FOUND_SYSTEMS" ] && [ -n "$NOT_FOUND_SYSTEMS" ]; then
  echo ""
  echo -e "${YELLOW}Partial state detected:${NC}"
  echo "  Found in:     $FOUND_SYSTEMS"
  echo "  Not found in: $NOT_FOUND_SYSTEMS"
  echo ""
  echo "This looks like a partial teardown from a previous run."
  printf "Continue with cleanup of remaining systems? (y/N) > "
  read -r CONTINUE_PARTIAL
  if [ "$CONTINUE_PARTIAL" != "y" ] && [ "$CONTINUE_PARTIAL" != "Y" ]; then
    echo ""
    echo "Teardown cancelled."
    exit 0
  fi
  echo ""
fi

# Question 2 — Confirm the project (only if GitHub exists)
if [ "$FOUND_IN_GITHUB" = true ]; then
  REPO_INFO=$(gh repo view "${GITHUB_ORG}/${PROJECT_NAME}" --json name,description,createdAt,updatedAt 2>&1)

  # Validate JSON response
  if ! echo "$REPO_INFO" | jq empty 2>/dev/null; then
    echo ""
    echo -e "${RED}ERROR: GitHub CLI returned non-JSON response:${NC}"
    echo "$REPO_INFO" | head -10
    exit 1
  fi

  REPO_DESC=$(echo "$REPO_INFO" | jq -r '.description // "No description"')
  REPO_CREATED=$(echo "$REPO_INFO" | jq -r '.createdAt' | cut -d'T' -f1)
  REPO_UPDATED=$(echo "$REPO_INFO" | jq -r '.updatedAt' | cut -d'T' -f1)

  echo "Found this project:"
  echo ""
  echo "  Name:         $PROJECT_NAME"
  echo "  Description:  $REPO_DESC"
  echo "  Created:      $REPO_CREATED"
  echo "  Last updated: $REPO_UPDATED"
  echo ""
  printf "Is this the right project? (y/n) > "
  read -r CONFIRM_PROJECT

  if [ "$CONFIRM_PROJECT" != "y" ] && [ "$CONFIRM_PROJECT" != "Y" ]; then
    echo ""
    echo "No problem. Run the script again with the correct project name."
    exit 0
  fi
else
  # GitHub doesn't exist, but other systems do
  # Partial state was already confirmed above, so just acknowledge and proceed
  echo "Project found in: $FOUND_SYSTEMS"
  echo "(GitHub repo not found — may have been archived/deleted already)"
fi

echo ""

# ═════════════════════════════════════════════════════════
# STEP 3 — Choose what to remove
# ═════════════════════════════════════════════════════════

echo "What do you want to remove? Select all that apply."
echo "Press Enter to select all (recommended)."
echo ""
echo "  1. GitHub — archive the repo"
echo "  2. Supabase — export data and delete project"
echo "  3. Vercel — remove deployment and domain"
echo "  4. Local folder — delete local copy (will prompt for confirmation)"
echo ""
printf "Enter numbers separated by commas, or press Enter for all: > "
read -r SELECTIONS

DO_GITHUB=false
DO_SUPABASE=false
DO_VERCEL=false
DO_LOCAL=false

if [ -z "$SELECTIONS" ]; then
  DO_GITHUB=true
  DO_SUPABASE=true
  DO_VERCEL=true
  DO_LOCAL=true
else
  if echo "$SELECTIONS" | grep -q "1"; then DO_GITHUB=true; fi
  if echo "$SELECTIONS" | grep -q "2"; then DO_SUPABASE=true; fi
  if echo "$SELECTIONS" | grep -q "3"; then DO_VERCEL=true; fi
  if echo "$SELECTIONS" | grep -q "4"; then DO_LOCAL=true; fi
fi

echo ""

# ═════════════════════════════════════════════════════════
# STEP 4 — Final confirmation
# ═════════════════════════════════════════════════════════

# Determine local folder path for display
LOCAL_PATH=""
if [[ "$PWD" == *"/${PROJECT_NAME}"* ]]; then
  LOCAL_PATH="$PWD"
elif [ -d "$PWD/$PROJECT_NAME" ]; then
  LOCAL_PATH="$PWD/$PROJECT_NAME"
fi

BACKUP_FILE="$HOME/Downloads/${PROJECT_NAME}-backup-$(date +%Y%m%d).sql"

# ─────────────────────────────────────────────────────────
# Pre-flight summary
# ─────────────────────────────────────────────────────────
echo "Pre-flight checks passed:"
echo -e "  ${GREEN}✓${NC} jq installed"
echo -e "  ${GREEN}✓${NC} GitHub CLI authenticated"
echo -e "  ${GREEN}✓${NC} Supabase CLI authenticated (clean JSON)"
echo -e "  ${GREEN}✓${NC} Vercel CLI authenticated"
echo -e "  ${GREEN}✓${NC} Project ${PROJECT_NAME} found in: ${FOUND_SYSTEMS:-all systems}"
echo ""

echo -e "${YELLOW}⚠️  You are about to permanently remove:${NC}"
echo ""
if [ "$DO_GITHUB" = true ]; then
  echo "  GitHub:    github.com/${GITHUB_ORG}/${PROJECT_NAME} → will be archived"
fi
if [ "$DO_SUPABASE" = true ]; then
  echo "  Supabase:  ${PROJECT_NAME} project → data will be exported then deleted"
fi
if [ "$DO_VERCEL" = true ]; then
  echo "  Vercel:    ${PROJECT_NAME} project → deployment and domain will be removed"
fi
if [ "$DO_LOCAL" = true ]; then
  if [ -n "$LOCAL_PATH" ]; then
    echo "  Local:     ${LOCAL_PATH} → will be deleted"
  else
    echo "  Local:     no local folder found — will be skipped"
  fi
fi
echo ""
if [ "$DO_SUPABASE" = true ]; then
  echo "The database will be exported to:"
  echo "  ${BACKUP_FILE}"
  echo ""
fi
echo "This cannot be undone. Type the project name to confirm:"
printf "> "
read -r CONFIRM_NAME

if [ "$CONFIRM_NAME" != "$PROJECT_NAME" ]; then
  echo ""
  echo "Project name doesn't match. Teardown cancelled."
  exit 1
fi

echo ""

# ─────────────────────────────────────────────────────────
# State file setup (Layer 3 idempotency)
# ─────────────────────────────────────────────────────────

TODAY=$(date +%Y-%m-%d)
STATE_FILE_DIR="${PLAYBOOK_DIR}/operations/teardown-log"
if [ ! -d "$PLAYBOOK_DIR/operations" ]; then
  STATE_FILE_DIR="$HOME/Downloads"
fi
mkdir -p "$STATE_FILE_DIR"
STATE_FILE="${STATE_FILE_DIR}/${PROJECT_NAME}-${TODAY}.state"

# Check for existing incomplete state file
if [ -f "$STATE_FILE" ] && ! grep -q "^teardown_complete=true$" "$STATE_FILE"; then
  echo ""
  echo -e "${YELLOW}Found incomplete teardown from earlier today.${NC}"
  echo "Already completed:"

  # Show what's done
  if step_done "supabase_backup"; then echo -e "  ${GREEN}✓${NC} Database backed up"; fi
  if step_done "supabase_delete"; then echo -e "  ${GREEN}✓${NC} Supabase project deleted"; fi
  if step_done "vercel_delete"; then echo -e "  ${GREEN}✓${NC} Vercel project deleted"; fi
  if step_done "github_archive"; then echo -e "  ${GREEN}✓${NC} GitHub repo archived"; fi
  if step_done "local_delete"; then echo -e "  ${GREEN}✓${NC} Local folder deleted"; fi

  echo ""
  printf "Continue and finish the teardown? (y/N) > "
  read -r CONTINUE_RESUME
  if [ "$CONTINUE_RESUME" != "y" ] && [ "$CONTINUE_RESUME" != "Y" ]; then
    echo ""
    echo "Teardown cancelled. State file preserved at:"
    echo "  $STATE_FILE"
    exit 0
  fi
  echo ""
  echo "Resuming teardown..."
  echo ""
else
  # Create new state file (skip in dry-run mode)
  if $DRY_RUN; then
    echo -e "${YELLOW}[DRY RUN]${NC} Would create state file: $STATE_FILE"
  else
    cat > "$STATE_FILE" << EOF
# Teardown state for ${PROJECT_NAME}
# Started: $(date '+%Y-%m-%d %H:%M:%S')
# This file tracks progress for resumability after failures
EOF
  fi
fi

# Track results for the final summary
GITHUB_RESULT="Skipped"
SUPABASE_RESULT="Skipped"
VERCEL_RESULT="Skipped"
LOCAL_RESULT="Skipped"
BACKUP_RESULT="No database backup — Supabase not configured or skipped"

# ═════════════════════════════════════════════════════════
# STEP 5 — Export Supabase data
# ═════════════════════════════════════════════════════════

SUPABASE_PROJECT_REF=""

if [ "$DO_SUPABASE" = true ]; then
  echo "Supabase teardown..."
  echo ""

  # 5a. Find the Supabase project ref
  # Use cached value from pre-flight if available, otherwise fetch with error handling
  if [ -n "$SUPABASE_PROJECT_REF_CACHE" ]; then
    SUPABASE_PROJECT_REF="$SUPABASE_PROJECT_REF_CACHE"
  else
    SUPABASE_RAW=$(run_or_die "Fetching Supabase projects" supabase projects list --output json)
    SUPABASE_RAW=$(parse_json_or_die "Supabase project list" "$SUPABASE_RAW")
    SUPABASE_PROJECT_REF=$(echo "$SUPABASE_RAW" | jq -r ".[] | select(.name==\"$PROJECT_NAME\") | .id")
  fi

  if [ -z "$SUPABASE_PROJECT_REF" ]; then
    echo "  No Supabase project found for ${PROJECT_NAME} — skipping."
    echo ""
    SUPABASE_RESULT="No project found — already deleted or never created"
    mark_skipped "supabase_backup"
    mark_skipped "supabase_delete"
  else
    # 5b. Export the database via Management API (idempotent: skip if already done)
    if step_done "supabase_backup"; then
      echo -e "  ${GREEN}✓${NC} Database backup already complete (from previous run)"
      BACKUP_RESULT="Database backup completed in previous run"
    elif $DRY_RUN; then
      dry "Export database to ${BACKUP_FILE}"
      BACKUP_RESULT="[DRY RUN] Would export database"
    else
      echo "  Exporting database..."

      curl -s \
        "https://api.supabase.com/v1/projects/${SUPABASE_PROJECT_REF}/database/backups/download" \
        -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" \
        --output "$BACKUP_FILE"

      if [ -s "$BACKUP_FILE" ]; then
        ok "Database exported to: ${BACKUP_FILE}"
        BACKUP_RESULT="Database exported to: ${BACKUP_FILE}"
        mark_done "supabase_backup"
      else
        rm -f "$BACKUP_FILE"
        echo ""
        warn "Automatic export failed."
        echo "  Manually export from:"
        echo "  https://supabase.com/dashboard/project/${SUPABASE_PROJECT_REF}/settings/database"
        echo ""
        printf "Do you want to continue without a backup? (y/n) > "
        read -r CONTINUE_NO_BACKUP

        if [ "$CONTINUE_NO_BACKUP" != "y" ] && [ "$CONTINUE_NO_BACKUP" != "Y" ]; then
          echo ""
          echo "Teardown cancelled. Export your data manually, then run this script again."
          echo "Progress saved to: $STATE_FILE"
          exit 1
        fi

        echo ""
        warn "Continuing without a database backup."
        echo ""
        BACKUP_RESULT="Export failed — continued without backup"
        mark_skipped "supabase_backup"
      fi
    fi

    # 5c. Delete the Supabase project (idempotent: check existence first)
    if step_done "supabase_delete"; then
      echo -e "  ${GREEN}✓${NC} Supabase project already deleted (from previous run)"
      SUPABASE_RESULT="Project deleted in previous run"
    else
      # Check if project still exists before trying to delete
      # Layer 6: Fail-safe existence check — abort on uncertainty, don't assume "gone"
      VERIFY_STDERR_FILE=$(mktemp)
      VERIFY_EXISTS=$(supabase projects list --output json 2>"$VERIFY_STDERR_FILE") || true
      VERIFY_STDERR_CONTENT=$(cat "$VERIFY_STDERR_FILE")
      rm -f "$VERIFY_STDERR_FILE"

      if ! echo "$VERIFY_EXISTS" | jq empty 2>/dev/null; then
        echo ""
        echo -e "${RED}ERROR: Could not verify Supabase project state.${NC}"
        echo "The CLI returned invalid JSON. Cannot safely proceed."
        echo ""
        echo "Raw output:"
        echo "$VERIFY_EXISTS" | head -10
        [ -n "$VERIFY_STDERR_CONTENT" ] && echo "Stderr: $VERIFY_STDERR_CONTENT"
        echo ""
        echo "Check the project manually at:"
        echo "  https://supabase.com/dashboard"
        echo ""
        echo "Then re-run teardown if the project still exists."
        echo "Progress saved to: $STATE_FILE"
        exit 1
      fi

      EXISTS_COUNT=$(echo "$VERIFY_EXISTS" | jq -r "[.[] | select(.name==\"$PROJECT_NAME\")] | length")
      if [ "$EXISTS_COUNT" -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Supabase project already gone"
        SUPABASE_RESULT="Project already deleted"
        mark_done "supabase_delete"
      elif $DRY_RUN; then
        dry "Delete Supabase project: ${SUPABASE_PROJECT_REF}"
        SUPABASE_RESULT="[DRY RUN] Would delete project"
      else
        echo "  Deleting Supabase project..."
        curl -s -X DELETE \
          "https://api.supabase.com/v1/projects/${SUPABASE_PROJECT_REF}" \
          -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" >/dev/null

        sleep 3

        # Verify deletion (non-fatal if this check fails)
        # Separate stderr to avoid JSON contamination in verification
        VERIFY_POST_STDERR=$(mktemp)
        VERIFY_RAW=$(supabase projects list --output json 2>"$VERIFY_POST_STDERR") || true
        rm -f "$VERIFY_POST_STDERR"
        if echo "$VERIFY_RAW" | jq empty 2>/dev/null; then
          STATUS=$(echo "$VERIFY_RAW" | jq -r "[.[] | select(.name==\"$PROJECT_NAME\")] | length")
          if [ "$STATUS" -eq 0 ]; then
            ok "Supabase project deleted"
            SUPABASE_RESULT="Data exported + project deleted"
            mark_done "supabase_delete"
          else
            warn "Supabase project may still be deleting. Check supabase.com/dashboard"
            SUPABASE_RESULT="Data exported, project deletion pending"
            # Don't mark done — let user re-run to verify
          fi
        else
          warn "Could not verify deletion (CLI returned non-JSON). Check supabase.com/dashboard"
          SUPABASE_RESULT="Data exported, deletion verification failed"
          # Don't mark done — let user re-run to verify
        fi
      fi
    fi

    echo ""
    echo "Supabase teardown complete."
    echo ""
  fi
fi

# ═════════════════════════════════════════════════════════
# STEP 6 — Remove Vercel project
# ═════════════════════════════════════════════════════════

if [ "$DO_VERCEL" = true ]; then
  # Check if already done from previous run
  if step_done "vercel_delete"; then
    echo -e "${GREEN}✓${NC} Vercel project already deleted (from previous run)"
    VERCEL_RESULT="Project deleted in previous run"
  else
    echo "Removing Vercel project..."
    echo ""

    # 6a. Get the Vercel project ID
    # Layer 6: Fail-safe existence check — distinguish "not found" from other errors
    # Use cached value from pre-flight if available, otherwise fetch with error handling
    VERCEL_PROJECT_ID=""
    VERCEL_SKIP_DELETION=false

    if [ -n "$VERCEL_PROJECT_ID_CACHE" ]; then
      VERCEL_PROJECT_ID="$VERCEL_PROJECT_ID_CACHE"
    else
      VERCEL_RESPONSE=$(curl -s \
        "https://api.vercel.com/v10/projects/${PROJECT_NAME}" \
        -H "Authorization: Bearer $VERCEL_TOKEN")

      # Validate JSON response
      if ! echo "$VERCEL_RESPONSE" | jq empty 2>/dev/null; then
        echo ""
        echo -e "${RED}ERROR: Vercel API returned non-JSON response:${NC}"
        echo "$VERCEL_RESPONSE" | head -10
        echo "Progress saved to: $STATE_FILE"
        exit 1
      fi

      # Check for error response before extracting project ID
      VERCEL_ERROR_CODE=$(echo "$VERCEL_RESPONSE" | jq -r '.error.code // empty')
      if [ -n "$VERCEL_ERROR_CODE" ]; then
        if [ "$VERCEL_ERROR_CODE" = "not_found" ]; then
          echo "  No Vercel project found for ${PROJECT_NAME} — already removed or never created."
          echo ""
          VERCEL_RESULT="No project found — already removed or never created"
          mark_skipped "vercel_delete"
          VERCEL_SKIP_DELETION=true
        else
          echo ""
          echo -e "${RED}ERROR: Could not verify Vercel project state.${NC}"
          echo "API returned error code: ${VERCEL_ERROR_CODE}"
          echo ""
          echo "Full response:"
          echo "$VERCEL_RESPONSE" | jq . 2>/dev/null || echo "$VERCEL_RESPONSE"
          echo ""
          echo "Check the project manually at:"
          echo "  https://vercel.com/dashboard"
          echo ""
          echo "If you've verified manually that the project is already deleted,"
          echo "you can mark this step complete by editing:"
          echo "  $STATE_FILE"
          echo "and adding the line: vercel_delete=done"
          echo ""
          echo "Then re-run teardown to continue."
          exit 1
        fi
      else
        VERCEL_PROJECT_ID=$(echo "$VERCEL_RESPONSE" | jq -r '.id // empty')
        if [ -z "$VERCEL_PROJECT_ID" ]; then
          echo ""
          echo -e "${RED}ERROR: Could not verify Vercel project state.${NC}"
          echo "API returned unexpected response (no project ID, no error code)."
          echo ""
          echo "Response:"
          echo "$VERCEL_RESPONSE" | jq . 2>/dev/null || echo "$VERCEL_RESPONSE"
          echo ""
          echo "Check the project manually at:"
          echo "  https://vercel.com/dashboard"
          echo ""
          echo "If you've verified manually that the project is already deleted,"
          echo "you can mark this step complete by editing:"
          echo "  $STATE_FILE"
          echo "and adding the line: vercel_delete=done"
          echo ""
          echo "Then re-run teardown to continue."
          exit 1
        fi
      fi
    fi

    if [ "$VERCEL_SKIP_DELETION" = true ]; then
      : # Already handled above, skip to next section
    elif $DRY_RUN; then
      dry "Remove subdomain: ${PROJECT_NAME}.${LAB_DOMAIN}"
      dry "Delete Vercel project: ${VERCEL_PROJECT_ID}"
      VERCEL_RESULT="[DRY RUN] Would delete project and domain"
    else
      # 6b. Remove the custom domain first
      curl -s -X DELETE \
        "https://api.vercel.com/v10/projects/${PROJECT_NAME}/domains/${PROJECT_NAME}.${LAB_DOMAIN}" \
        -H "Authorization: Bearer $VERCEL_TOKEN" >/dev/null

      ok "Subdomain removed: ${PROJECT_NAME}.${LAB_DOMAIN}"

      # 6c. Delete the Vercel project
      curl -s -X DELETE \
        "https://api.vercel.com/v10/projects/${VERCEL_PROJECT_ID}" \
        -H "Authorization: Bearer $VERCEL_TOKEN" >/dev/null

      ok "Vercel project deleted"
      VERCEL_RESULT="Project and domain removed"
      mark_done "vercel_delete"

      echo ""
      echo "Vercel teardown complete."
      echo ""
    fi
  fi
fi

# ═════════════════════════════════════════════════════════
# STEP 7 — Archive GitHub repo
# ═════════════════════════════════════════════════════════

if [ "$DO_GITHUB" = true ]; then
  # Check if already done from previous run
  if step_done "github_archive"; then
    echo -e "${GREEN}✓${NC} GitHub repo already archived (from previous run)"
    GITHUB_RESULT="Archived in previous run"
  else
    echo "Archiving GitHub repo..."
    echo ""

    # Layer 6: Fail-safe existence check — distinguish "not found" from other errors
    # We capture stderr and check for the specific "not found" message because:
    #   - gh CLI doesn't have distinct exit codes for "not found" vs other errors
    #   - A network error or auth failure should NOT be treated as "repo doesn't exist"
    #
    # FRAGILITY NOTE: We match on "Could not resolve to a Repository" which is the
    # current gh CLI error message for non-existent repos. If this breaks in a future
    # gh version, update the string match below. Ideally gh would provide structured
    # error output (--json errors) but as of 2024 it doesn't for repo view failures.
    GH_VIEW_STDERR=$(mktemp)
    GH_VIEW_OUTPUT=$(gh repo view "${GITHUB_ORG}/${PROJECT_NAME}" --json name 2>"$GH_VIEW_STDERR") || true
    GH_VIEW_EXIT=$?
    GH_VIEW_STDERR_CONTENT=$(cat "$GH_VIEW_STDERR")
    rm -f "$GH_VIEW_STDERR"

    if [ $GH_VIEW_EXIT -ne 0 ]; then
      if echo "$GH_VIEW_STDERR_CONTENT" | grep -qi "Could not resolve to a Repository"; then
        echo "  No GitHub repo found for ${PROJECT_NAME} — already archived/deleted or never created."
        echo ""
        GITHUB_RESULT="No repo found — already archived or deleted"
        mark_skipped "github_archive"
      else
        echo ""
        echo -e "${RED}ERROR: Could not verify GitHub repo state.${NC}"
        echo "gh repo view failed with exit code $GH_VIEW_EXIT"
        echo ""
        [ -n "$GH_VIEW_STDERR_CONTENT" ] && echo "Error: $GH_VIEW_STDERR_CONTENT"
        echo ""
        echo "Check the repo manually at:"
        echo "  https://github.com/${GITHUB_ORG}/${PROJECT_NAME}"
        echo ""
        echo "If you've verified manually that the repo is already archived/deleted,"
        echo "you can mark this step complete by editing:"
        echo "  $STATE_FILE"
        echo "and adding the line: github_archive=done"
        echo ""
        echo "Then re-run teardown to continue."
        exit 1
      fi
    elif $DRY_RUN; then
      dry "Archive GitHub repo: ${GITHUB_ORG}/${PROJECT_NAME}"
      GITHUB_RESULT="[DRY RUN] Would archive repo"
    else
      if ! gh repo archive "${GITHUB_ORG}/${PROJECT_NAME}" --yes; then
        echo ""
        echo -e "${RED}Something went wrong archiving the GitHub repo.${NC}"
        echo "You can archive it manually at github.com/${GITHUB_ORG}/${PROJECT_NAME}/settings"
        GITHUB_RESULT="Archive failed — do it manually"
        # Don't mark done — let user re-run or do manually
      else
        ok "GitHub repo archived (read-only, preserved for reference)"
        GITHUB_RESULT="Archived — still readable at github.com/${GITHUB_ORG}/${PROJECT_NAME}"
        mark_done "github_archive"
      fi
    fi

    echo ""
    echo "GitHub teardown complete."
    echo ""
  fi
fi

# ═════════════════════════════════════════════════════════
# STEP 8 — Remove local folder
# ═════════════════════════════════════════════════════════

if [ "$DO_LOCAL" = true ]; then
  # Check if already done from previous run
  if step_done "local_delete"; then
    echo -e "${GREEN}✓${NC} Local folder already deleted (from previous run)"
    LOCAL_RESULT="Deleted in previous run"
  else
    # Re-check local folder path
    LOCAL_PATH=""
    if [[ "$PWD" == *"/${PROJECT_NAME}"* ]]; then
      LOCAL_PATH="$PWD"
    elif [ -d "$PWD/$PROJECT_NAME" ]; then
      LOCAL_PATH="$PWD/$PROJECT_NAME"
    fi

    if [ -z "$LOCAL_PATH" ]; then
      echo "  No local folder found for ${PROJECT_NAME} — skipping."
      echo ""
      LOCAL_RESULT="No local folder found"
      mark_skipped "local_delete"
    elif $DRY_RUN; then
      echo "Found local folder at: ${LOCAL_PATH}"
      dry "Would prompt to delete local folder"
      LOCAL_RESULT="[DRY RUN] Would prompt for deletion"
    else
      echo "Found local folder at: ${LOCAL_PATH}"
      echo ""
      printf "Delete it? This will permanently remove all local files. (y/n) > "
      read -r DELETE_LOCAL

      if [ "$DELETE_LOCAL" = "y" ] || [ "$DELETE_LOCAL" = "Y" ]; then
        # If we're inside the project folder, cd out first
        if [[ "$PWD" == *"/${PROJECT_NAME}"* ]]; then
          cd "$(echo "$PWD" | sed "s|/${PROJECT_NAME}.*||")"
        fi
        rm -rf "$LOCAL_PATH"
        ok "Local folder deleted"
        LOCAL_RESULT="Deleted"
        mark_done "local_delete"
      else
        echo "  Kept local folder at: ${LOCAL_PATH}"
        LOCAL_RESULT="Kept at ${LOCAL_PATH}"
        mark_skipped "local_delete"
      fi
      echo ""
    fi
  fi
fi

# ═════════════════════════════════════════════════════════
# STEP 9 — Create teardown record
# ═════════════════════════════════════════════════════════

# Get GitHub username for the log (non-fatal if this fails)
GH_USER_RAW=$(gh api user 2>&1) || true
if echo "$GH_USER_RAW" | jq empty 2>/dev/null; then
  GH_USER=$(echo "$GH_USER_RAW" | jq -r '.login // "unknown"')
else
  GH_USER="unknown"
fi

# Determine where to save the teardown log
TEARDOWN_LOG_DIR="${PLAYBOOK_DIR}/operations/teardown-log"
TEARDOWN_LOG="${TEARDOWN_LOG_DIR}/${PROJECT_NAME}-${TODAY}.md"

if [ ! -d "$PLAYBOOK_DIR/operations" ]; then
  # Playbook repo not found at expected path — save to Downloads
  TEARDOWN_LOG_DIR="$HOME/Downloads"
  TEARDOWN_LOG="${TEARDOWN_LOG_DIR}/${PROJECT_NAME}-teardown-${TODAY}.md"
  if ! $DRY_RUN; then
    warn "Playbook repo not found at expected path. Saving teardown record to ~/Downloads instead."
  fi
fi

if $DRY_RUN; then
  dry "Create teardown record at: ${TEARDOWN_LOG}"
else
  mkdir -p "$TEARDOWN_LOG_DIR"

  cat > "$TEARDOWN_LOG" << EOF
# Teardown Record: ${PROJECT_NAME}

- **Date:** ${TODAY}
- **Project:** ${PROJECT_NAME}
- **Removed by:** ${GH_USER}

## What was removed

- GitHub: ${GITHUB_RESULT}
- Supabase: ${SUPABASE_RESULT}
- Vercel: ${VERCEL_RESULT}
- Local folder: ${LOCAL_RESULT}

## Data backup

${BACKUP_RESULT}

## Notes

Add any notes about why this project was decommissioned here.
EOF

  ok "Teardown record saved to: ${TEARDOWN_LOG}"
fi
echo ""

# Mark teardown as complete and rename state file (skip in dry-run mode)
if ! $DRY_RUN; then
  echo "teardown_complete=true" >> "$STATE_FILE"
  mv "$STATE_FILE" "${STATE_FILE%.state}.state.complete" 2>/dev/null || true
fi

# ═════════════════════════════════════════════════════════
# STEP 10 — Final summary
# ═════════════════════════════════════════════════════════

if $DRY_RUN; then
  echo "╔════════════════════════════════════════════╗"
  echo "║   Dry run complete.                         ║"
  echo "╚════════════════════════════════════════════╝"
else
  echo "╔════════════════════════════════════════════╗"
  echo "║   Teardown complete.                        ║"
  echo "╚════════════════════════════════════════════╝"
fi
echo ""
echo "PROJECT"
echo "  Name:      ${PROJECT_NAME}"
echo "  Removed:   ${TODAY}"
echo ""
if $DRY_RUN; then
  echo "WHAT WOULD HAPPEN"
else
  echo "WHAT HAPPENED"
fi
echo "  GitHub:    ${GITHUB_RESULT}"
echo "  Supabase:  ${SUPABASE_RESULT}"
echo "  Vercel:    ${VERCEL_RESULT}"
echo "  Local:     ${LOCAL_RESULT}"
echo ""
if $DRY_RUN; then
  echo "RECORD"
  echo "  Would save teardown log to: ${TEARDOWN_LOG}"
  echo ""
  echo "This was a dry run. No changes were made."
  echo "Run without --dry-run to actually tear down the project."
else
  echo "RECORD"
  echo "  Teardown log saved to: ${TEARDOWN_LOG}"
  echo ""
  echo "ABOUT THE GITHUB ARCHIVE"
  echo "  Archived repos remain visible in github.com/${GITHUB_ORG} with"
  echo "  an 'archived' tag. They preserve project history but cannot"
  echo "  receive new commits, PRs, or issues. This is intentional —"
  echo "  archives keep the work accessible without consuming active"
  echo "  resources. If you ever need permanent deletion, do it manually"
  echo "  through GitHub repo settings."
  echo ""
  echo "All done. Nothing is running and no costs are accruing for this project."
fi
