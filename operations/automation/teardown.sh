#!/bin/bash

# Friends Innovation Lab - Project Teardown Script
# This script decommissions a project and removes all associated infrastructure.
# Run it and follow the prompts.

set -e

# ─────────────────────────────────────────────────────────
# Colors
# ─────────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Resolve the directory where this script lives (for playbook repo path)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYBOOK_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# ─────────────────────────────────────────────────────────
# Helper functions
# ─────────────────────────────────────────────────────────
ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }

# ═════════════════════════════════════════════════════════
# STEP 0 — Welcome
# ═════════════════════════════════════════════════════════
echo ""
echo "╔════════════════════════════════════════════╗"
echo "║   Friends Innovation Lab — Project Teardown ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "This script will decommission a project and remove all"
echo "associated infrastructure."
echo ""
echo "This cannot be undone. Read every prompt carefully."
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

# --- Authentications ---

if gh auth status &>/dev/null 2>&1; then
  ok "GitHub CLI is logged in"
else
  fail "GitHub CLI is not logged in. Run: gh auth login"
  CHECKS_PASSED=false
fi

if vercel whoami &>/dev/null 2>&1; then
  ok "Vercel CLI is logged in"
else
  fail "Vercel CLI is not logged in. Run: vercel login"
  CHECKS_PASSED=false
fi

if supabase projects list &>/dev/null 2>&1; then
  ok "Supabase CLI is logged in"
else
  fail "Supabase CLI is not logged in. Run: supabase login"
  CHECKS_PASSED=false
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

if [ -n "$GITHUB_ORG" ]; then
  ok "GITHUB_ORG is set ($GITHUB_ORG)"
else
  fail "GITHUB_ORG is not set. Add this to your shell profile: export GITHUB_ORG=friends-innovation-lab"
  CHECKS_PASSED=false
fi

if [ -n "$SUPABASE_ACCESS_TOKEN" ]; then
  ok "SUPABASE_ACCESS_TOKEN is set"
else
  fail "SUPABASE_ACCESS_TOKEN is not set. Get a token at supabase.com → account → access tokens, then add to your shell profile."
  CHECKS_PASSED=false
fi

if [ -n "$LABS_DOMAIN" ]; then
  ok "LABS_DOMAIN is set ($LABS_DOMAIN)"
else
  fail "LABS_DOMAIN is not set. Add this to your shell profile: export LABS_DOMAIN=labs.cityfriends.tech"
  CHECKS_PASSED=false
fi

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

# Validate that the repo exists
if ! gh repo view "${GITHUB_ORG}/${PROJECT_NAME}" &>/dev/null 2>&1; then
  echo -e "${RED}No project called ${PROJECT_NAME} was found in GitHub.${NC}"
  echo "Check the name and try again."
  exit 1
fi

# Question 2 — Confirm the project
REPO_INFO=$(gh repo view "${GITHUB_ORG}/${PROJECT_NAME}" --json name,description,createdAt,updatedAt 2>/dev/null)

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
echo "  4. Local folder — delete local copy of the project"
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
  echo "Backing up database..."
  echo ""

  # 5a. Find the Supabase project ref
  SUPABASE_PROJECT_REF=$(supabase projects list --output json 2>/dev/null \
    | jq -r '.[] | select(.name=="'"$PROJECT_NAME"'") | .id')

  if [ -z "$SUPABASE_PROJECT_REF" ]; then
    echo "  No Supabase project found for ${PROJECT_NAME} — skipping database export."
    echo ""
    SUPABASE_RESULT="No project found — already deleted or never created"
  else
    # 5b. Export the database
    EXPORT_OK=true
    if ! supabase db dump --project-ref "$SUPABASE_PROJECT_REF" --file "$BACKUP_FILE" 2>/dev/null; then
      EXPORT_OK=false
      echo ""
      echo -e "${RED}Database export failed.${NC}"
      echo "Before continuing, manually export your data from:"
      echo "https://supabase.com/dashboard/project/${SUPABASE_PROJECT_REF}/editor"
      echo ""
      printf "Do you want to continue without a backup? (y/n) > "
      read -r CONTINUE_NO_BACKUP

      if [ "$CONTINUE_NO_BACKUP" != "y" ] && [ "$CONTINUE_NO_BACKUP" != "Y" ]; then
        echo ""
        echo "Teardown cancelled. Export your data manually, then run this script again."
        exit 1
      fi

      echo ""
      warn "Continuing without a database backup."
      echo ""
      BACKUP_RESULT="Export failed — continued without backup"
    fi

    if [ "$EXPORT_OK" = true ]; then
      ok "Database exported to: ${BACKUP_FILE}"
      BACKUP_RESULT="Database exported to: ${BACKUP_FILE}"
    fi

    # 5c. Delete the Supabase project
    curl -s -X DELETE \
      "https://api.supabase.com/v1/projects/${SUPABASE_PROJECT_REF}" \
      -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" >/dev/null

    sleep 3

    # Verify deletion
    STATUS=$(supabase projects list --output json 2>/dev/null \
      | jq -r '[.[] | select(.name=="'"$PROJECT_NAME"'")] | length')
    if [ "$STATUS" -eq 0 ]; then
      ok "Supabase project deleted"
      SUPABASE_RESULT="Data exported + project deleted"
    else
      warn "Supabase project may still be deleting. Check supabase.com/dashboard"
      SUPABASE_RESULT="Data exported, project deletion pending"
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
  echo "Removing Vercel project..."
  echo ""

  # 6a. Get the Vercel project ID
  VERCEL_RESPONSE=$(curl -s \
    "https://api.vercel.com/v10/projects/${PROJECT_NAME}" \
    -H "Authorization: Bearer $VERCEL_TOKEN")

  VERCEL_PROJECT_ID=$(echo "$VERCEL_RESPONSE" | jq -r '.id // empty')

  if [ -z "$VERCEL_PROJECT_ID" ]; then
    echo "  No Vercel project found for ${PROJECT_NAME}. It may have already been removed."
    echo "  Skipping."
    echo ""
    VERCEL_RESULT="No project found — already removed or never created"
  else
    # 6b. Remove the custom domain first
    curl -s -X DELETE \
      "https://api.vercel.com/v10/projects/${PROJECT_NAME}/domains/${PROJECT_NAME}.${LABS_DOMAIN}" \
      -H "Authorization: Bearer $VERCEL_TOKEN" >/dev/null

    ok "Subdomain removed: ${PROJECT_NAME}.${LABS_DOMAIN}"

    # 6c. Delete the Vercel project
    curl -s -X DELETE \
      "https://api.vercel.com/v10/projects/${VERCEL_PROJECT_ID}" \
      -H "Authorization: Bearer $VERCEL_TOKEN" >/dev/null

    ok "Vercel project deleted"
    VERCEL_RESULT="Project and domain removed"

    echo ""
    echo "Vercel teardown complete."
    echo ""
  fi
fi

# ═════════════════════════════════════════════════════════
# STEP 7 — Archive GitHub repo
# ═════════════════════════════════════════════════════════

if [ "$DO_GITHUB" = true ]; then
  echo "Archiving GitHub repo..."
  echo ""

  if ! gh repo view "${GITHUB_ORG}/${PROJECT_NAME}" &>/dev/null 2>&1; then
    echo "  No GitHub repo found for ${PROJECT_NAME}. It may have already been archived or deleted."
    echo "  Skipping."
    echo ""
    GITHUB_RESULT="No repo found — already archived or deleted"
  else
    if ! gh repo archive "${GITHUB_ORG}/${PROJECT_NAME}" --yes; then
      echo ""
      echo -e "${RED}Something went wrong archiving the GitHub repo.${NC}"
      echo "You can archive it manually at github.com/${GITHUB_ORG}/${PROJECT_NAME}/settings"
      GITHUB_RESULT="Archive failed — do it manually"
    else
      ok "GitHub repo archived (read-only, preserved for reference)"
      GITHUB_RESULT="Archived — still readable at github.com/${GITHUB_ORG}/${PROJECT_NAME}"
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
    else
      echo "  Kept local folder at: ${LOCAL_PATH}"
      LOCAL_RESULT="Kept at ${LOCAL_PATH}"
    fi
    echo ""
  fi
fi

# ═════════════════════════════════════════════════════════
# STEP 9 — Create teardown record
# ═════════════════════════════════════════════════════════

TODAY=$(date +%Y-%m-%d)
GH_USER=$(gh api user 2>/dev/null | jq -r '.login // "unknown"')

# Determine where to save the teardown log
TEARDOWN_LOG_DIR="${PLAYBOOK_DIR}/operations/teardown-log"
TEARDOWN_LOG="${TEARDOWN_LOG_DIR}/${PROJECT_NAME}-${TODAY}.md"

if [ ! -d "$PLAYBOOK_DIR/operations" ]; then
  # Playbook repo not found at expected path — save to Downloads
  TEARDOWN_LOG_DIR="$HOME/Downloads"
  TEARDOWN_LOG="${TEARDOWN_LOG_DIR}/${PROJECT_NAME}-teardown-${TODAY}.md"
  warn "Playbook repo not found at expected path. Saving teardown record to ~/Downloads instead."
fi

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
echo ""

# ═════════════════════════════════════════════════════════
# STEP 10 — Final summary
# ═════════════════════════════════════════════════════════

echo "╔════════════════════════════════════════════╗"
echo "║   Teardown complete.                        ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "PROJECT"
echo "  Name:      ${PROJECT_NAME}"
echo "  Removed:   ${TODAY}"
echo ""
echo "WHAT HAPPENED"
echo "  GitHub:    ${GITHUB_RESULT}"
echo "  Supabase:  ${SUPABASE_RESULT}"
echo "  Vercel:    ${VERCEL_RESULT}"
echo "  Local:     ${LOCAL_RESULT}"
echo ""
echo "RECORD"
echo "  Teardown log saved to: ${TEARDOWN_LOG}"
echo ""
echo "All done. Nothing is running and no costs are accruing for this project."
