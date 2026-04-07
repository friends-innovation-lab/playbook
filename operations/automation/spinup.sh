#!/bin/bash

# Friends Innovation Lab - Project Spinup Script
# This script creates a complete project across GitHub, Supabase, and Vercel.
# Run it and follow the prompts.

set -e

# ─────────────────────────────────────────────────────────
# Colors
# ─────────────────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Resolve the directory where this script lives (for template paths)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Track whether the build succeeded for the final summary
BUILD_OK=true

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
echo "║   Friends Innovation Lab — Project Spinup  ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "This script will create a new project across GitHub, Supabase,"
echo "and Vercel and have it live at a real URL in under 10 minutes."
echo ""
echo "Let's get started."
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

NODE_VERSION=$(node --version 2>/dev/null || echo "")
if [ -n "$NODE_VERSION" ]; then
  NODE_MAJOR=$(echo "$NODE_VERSION" | sed 's/v//' | cut -d. -f1)
  if [ "$NODE_MAJOR" -ge 18 ]; then
    ok "node ($NODE_VERSION)"
  else
    fail "node — Node.js 18 or higher is required. You have $NODE_VERSION. Download from nodejs.org"
    CHECKS_PASSED=false
  fi
else
  fail "node — Node.js is not installed. Download from nodejs.org"
  CHECKS_PASSED=false
fi

if command -v npm &>/dev/null; then
  ok "npm"
else
  fail "npm — npm is not installed. It comes with Node.js. Download from nodejs.org"
  CHECKS_PASSED=false
fi

if command -v git &>/dev/null; then
  ok "git"
else
  fail "git — git is not installed. Install it: brew install git"
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

if [ -n "$SUPABASE_ORG_ID" ]; then
  ok "SUPABASE_ORG_ID is set"
else
  fail "SUPABASE_ORG_ID is not set. Find it at supabase.com → org settings, then add to your shell profile."
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

echo "Everything looks good. Let's build."
echo ""

# ═════════════════════════════════════════════════════════
# STEP 2 — Collect project details
# ═════════════════════════════════════════════════════════

# --- Question 1: Project name ---
while true; do
  echo "What do you want to call this project?"
  echo "(lowercase letters, numbers, and hyphens only — e.g. veteran-intake-tool)"
  printf "> "
  read -r PROJECT_NAME

  # Validate format
  if ! echo "$PROJECT_NAME" | grep -qE '^[a-z0-9][a-z0-9-]*[a-z0-9]$' || [ ${#PROJECT_NAME} -lt 3 ] || [ ${#PROJECT_NAME} -gt 40 ]; then
    echo ""
    echo -e "${RED}Project name must be 3–40 characters and contain only lowercase letters, numbers, and hyphens.${NC}"
    echo ""
    continue
  fi

  # Check if GitHub repo already exists
  if gh repo view "${GITHUB_ORG}/${PROJECT_NAME}" &>/dev/null 2>&1; then
    echo ""
    echo -e "${RED}A project called ${PROJECT_NAME} already exists in GitHub. Choose a different name.${NC}"
    echo ""
    continue
  fi

  # Check if Vercel project already exists
  VERCEL_CHECK=$(curl -s -o /dev/null -w "%{http_code}" \
    "https://api.vercel.com/v9/projects/${PROJECT_NAME}" \
    -H "Authorization: Bearer $VERCEL_TOKEN")
  if [ "$VERCEL_CHECK" = "200" ]; then
    echo ""
    echo -e "${RED}A Vercel project called ${PROJECT_NAME} already exists. Choose a different name.${NC}"
    echo ""
    continue
  fi

  break
done

echo ""

# --- Question 2: Project type ---
while true; do
  echo "What type of project is this?"
  echo ""
  echo "  1. Government / client-facing prototype"
  echo "  2. Internal tool"
  echo ""
  printf "> "
  read -r PROJECT_TYPE_NUM

  if [ "$PROJECT_TYPE_NUM" = "1" ] || [ "$PROJECT_TYPE_NUM" = "2" ]; then
    break
  fi
  echo ""
  echo -e "${RED}Please enter 1 or 2.${NC}"
  echo ""
done

if [ "$PROJECT_TYPE_NUM" = "1" ]; then
  PROJECT_TYPE="Government"
else
  PROJECT_TYPE="Internal"
fi

echo ""

# --- Question 3: Client or description ---
if [ "$PROJECT_TYPE" = "Government" ]; then
  echo "Who is this for? (e.g. Department of Veterans Affairs, HHS, internal FFTC)"
else
  echo "What does this tool do? (one sentence)"
fi
printf "> "
read -r PROJECT_FOR
echo ""

# --- Question 4: Database ---
while true; do
  echo "Does this project need a database?"
  echo ""
  echo "  1. Yes — set up Supabase"
  echo "  2. No — skip Supabase"
  echo ""
  printf "> "
  read -r DB_CHOICE

  if [ "$DB_CHOICE" = "1" ] || [ "$DB_CHOICE" = "2" ]; then
    break
  fi
  echo ""
  echo -e "${RED}Please enter 1 or 2.${NC}"
  echo ""
done

if [ "$DB_CHOICE" = "1" ]; then
  NEEDS_DB=true
  DB_DISPLAY="Yes — Supabase"
else
  NEEDS_DB=false
  DB_DISPLAY="No"
fi

echo ""

# --- Question 5: Confirm ---
SUPABASE_DISPLAY="skipped"
if [ "$NEEDS_DB" = true ]; then
  SUPABASE_DISPLAY="$PROJECT_NAME"
fi

echo "Here's what we're about to create:"
echo ""
echo "  Project name:   $PROJECT_NAME"
echo "  Type:           $PROJECT_TYPE"
echo "  For:            $PROJECT_FOR"
echo "  Database:       $DB_DISPLAY"
echo "  GitHub repo:    github.com/${GITHUB_ORG}/${PROJECT_NAME}"
echo "  Live URL:       https://${PROJECT_NAME}.${LABS_DOMAIN}"
echo "  Supabase:       $SUPABASE_DISPLAY"
echo ""
printf "Ready to go? (y/n) > "
read -r CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
  echo ""
  echo "No problem. Run the script again when you're ready."
  exit 0
fi

echo ""

# Save the starting directory so we can reference it later
START_DIR="$(pwd)"

# ═════════════════════════════════════════════════════════
# STEP 3 — GitHub setup
# ═════════════════════════════════════════════════════════
echo "Setting up GitHub..."
echo ""

# 3a. Create repo from template
if ! gh repo create "${GITHUB_ORG}/${PROJECT_NAME}" \
  --template "${GITHUB_ORG}/project-template" \
  --private \
  --description "$PROJECT_FOR"; then
  echo ""
  echo -e "${RED}Something went wrong creating the GitHub repo.${NC}"
  echo "A project called ${PROJECT_NAME} may already exist, or you may not have permission."
  exit 1
fi

sleep 3
ok "Repo created"

# 3b. Clone locally
if ! git clone "https://github.com/${GITHUB_ORG}/${PROJECT_NAME}.git"; then
  echo ""
  echo -e "${RED}Something went wrong cloning the repo.${NC}"
  echo "Check your internet connection and try: git clone https://github.com/${GITHUB_ORG}/${PROJECT_NAME}.git"
  exit 1
fi

cd "${PROJECT_NAME}"
PROJECT_DIR="$(pwd)"
ok "Cloned locally"

# 3c. Create and push develop branch
if ! git checkout -b develop; then
  echo ""
  echo -e "${RED}Something went wrong creating the develop branch.${NC}"
  exit 1
fi

if ! git push origin develop; then
  echo ""
  echo -e "${RED}Something went wrong pushing the develop branch.${NC}"
  echo "Check your GitHub permissions and try: git push origin develop"
  exit 1
fi

ok "develop branch created"

# 3d. Set develop as default branch
if ! gh repo edit "${GITHUB_ORG}/${PROJECT_NAME}" --default-branch develop; then
  echo ""
  echo -e "${RED}Something went wrong setting the default branch.${NC}"
  echo "You can set it manually at github.com/${GITHUB_ORG}/${PROJECT_NAME}/settings"
  exit 1
fi

ok "Default branch set to develop"

# 3e. Branch protection on main
if ! gh api "repos/${GITHUB_ORG}/${PROJECT_NAME}/branches/main/protection" \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["Lint, Typecheck & Test"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1}' \
  --field restrictions=null; then
  echo ""
  warn "Branch protection could not be set on main. You may need to set it manually."
fi

ok "Branch protection set on main"

# 3f. Create standard labels
gh label delete "bug" --yes 2>/dev/null || true
gh label delete "documentation" --yes 2>/dev/null || true
gh label delete "duplicate" --yes 2>/dev/null || true
gh label delete "enhancement" --yes 2>/dev/null || true
gh label delete "good first issue" --yes 2>/dev/null || true
gh label delete "help wanted" --yes 2>/dev/null || true
gh label delete "invalid" --yes 2>/dev/null || true
gh label delete "question" --yes 2>/dev/null || true
gh label delete "wontfix" --yes 2>/dev/null || true

gh label create "bug" --color "d73a4a" --description "Something isn't working"
gh label create "feature" --color "0075ca" --description "New feature or request"
gh label create "design" --color "e4e669" --description "Design work needed"
gh label create "blocked" --color "e11d48" --description "Blocked by something"
gh label create "in progress" --color "0052cc" --description "Currently being worked on"
gh label create "review needed" --color "8b5cf6" --description "Needs review before merging"
gh label create "accessibility" --color "1d9e75" --description "Accessibility related"
gh label create "good first issue" --color "7057ff" --description "Good for new contributors"

ok "Labels created"

# 3g. Create issues from template
if [ "$PROJECT_TYPE" = "Government" ]; then
  ISSUES_FILE="${SCRIPT_DIR}/templates/issues-government.txt"
else
  ISSUES_FILE="${SCRIPT_DIR}/templates/issues-internal.txt"
fi

if [ ! -f "$ISSUES_FILE" ]; then
  warn "Issue template file not found at $ISSUES_FILE. Skipping issue creation."
else
  # Collect unique weeks and create milestones
  WEEKS=$(jq -r '.[].week' "$ISSUES_FILE" | sort -u)
  for WEEK in $WEEKS; do
    gh api "repos/${GITHUB_ORG}/${PROJECT_NAME}/milestones" \
      --method POST \
      --field title="Week ${WEEK}" 2>/dev/null || true
  done

  # Get milestone IDs
  MILESTONES_JSON=$(gh api "repos/${GITHUB_ORG}/${PROJECT_NAME}/milestones" 2>/dev/null)

  # Create each issue
  ISSUE_COUNT=$(jq length "$ISSUES_FILE")
  for i in $(seq 0 $((ISSUE_COUNT - 1))); do
    TITLE=$(jq -r ".[$i].title" "$ISSUES_FILE")
    BODY=$(jq -r ".[$i].body" "$ISSUES_FILE")
    WEEK=$(jq -r ".[$i].week" "$ISSUES_FILE")
    LABELS=$(jq -r ".[$i].labels | join(\",\")" "$ISSUES_FILE")
    MILESTONE_NUMBER=$(echo "$MILESTONES_JSON" | jq -r ".[] | select(.title==\"Week ${WEEK}\") | .number")

    ISSUE_CMD="gh issue create --repo ${GITHUB_ORG}/${PROJECT_NAME} --title \"${TITLE}\" --body \"${BODY}\""

    if [ -n "$LABELS" ]; then
      ISSUE_CMD="$ISSUE_CMD --label \"${LABELS}\""
    fi

    if [ -n "$MILESTONE_NUMBER" ]; then
      ISSUE_CMD="$ISSUE_CMD --milestone \"Week ${WEEK}\""
    fi

    eval "$ISSUE_CMD" 2>/dev/null || true
  done

  ok "Project issues created"
fi

# 3h. Create project board
if ! gh project create --owner "${GITHUB_ORG}" --title "${PROJECT_NAME}" --format board 2>/dev/null; then
  warn "Could not create project board. You may need to create it manually."
fi

ok "Project board created"

echo ""
echo "GitHub setup complete."
echo ""

# ═════════════════════════════════════════════════════════
# STEP 4 — Supabase setup
# ═════════════════════════════════════════════════════════

SUPABASE_URL_VALUE=""
SUPABASE_ANON_KEY=""
SUPABASE_SERVICE_ROLE_KEY=""
SUPABASE_PROJECT_REF=""
SUPABASE_DB_PASSWORD=""

if [ "$NEEDS_DB" = true ]; then
  echo "Setting up Supabase..."
  echo ""

  # 4a. Generate password and create project
  SUPABASE_DB_PASSWORD=$(openssl rand -base64 32 | tr -dc 'A-Za-z0-9' | head -c 32)

  CREATE_OUTPUT=$(supabase projects create "${PROJECT_NAME}" \
    --org-id "$SUPABASE_ORG_ID" \
    --region us-east-1 \
    --db-password "$SUPABASE_DB_PASSWORD" 2>&1)

  if [ $? -ne 0 ]; then
    echo ""
    echo -e "${RED}Something went wrong creating the Supabase project.${NC}"
    echo "$CREATE_OUTPUT"
    echo "You may need to create it manually at supabase.com/dashboard"
    exit 1
  fi

  # Extract project ref from output
  SUPABASE_PROJECT_REF=$(echo "$CREATE_OUTPUT" | grep -oE '[a-z]{20}' | head -1)

  # If we couldn't parse the ref, try listing projects
  if [ -z "$SUPABASE_PROJECT_REF" ]; then
    sleep 3
    SUPABASE_PROJECT_REF=$(supabase projects list 2>/dev/null | grep "$PROJECT_NAME" | awk '{print $1}')
  fi

  if [ -z "$SUPABASE_PROJECT_REF" ]; then
    echo ""
    echo -e "${RED}Could not determine the Supabase project ID.${NC}"
    echo "Check supabase.com/dashboard for the project ref and set it manually."
    exit 1
  fi

  ok "Supabase project created"

  # 4b. Wait for provisioning
  echo "  Waiting for Supabase to finish setting up (this takes about 30 seconds)..."
  SUPABASE_READY=false
  for i in {1..12}; do
    sleep 5
    STATUS=$(supabase projects list 2>/dev/null | grep "$PROJECT_NAME" | awk '{print $NF}')
    if [ "$STATUS" = "ACTIVE_HEALTHY" ]; then
      SUPABASE_READY=true
      break
    fi
    echo "  Still waiting..."
  done

  if [ "$SUPABASE_READY" = false ]; then
    echo ""
    warn "Supabase is still setting up. This is normal and usually takes 1-2 minutes."
    echo ""
    echo "  Here's what to do:"
    echo "    1. Go to supabase.com/dashboard and watch for your project to show as Active"
    echo "    2. Once active, come back here and run:"
    echo "       supabase db push --project-ref ${SUPABASE_PROJECT_REF}"
    echo "    3. Then go to your project's .env.local and confirm these values are filled in:"
    echo "       NEXT_PUBLIC_SUPABASE_URL"
    echo "       NEXT_PUBLIC_SUPABASE_ANON_KEY"
    echo "       SUPABASE_SERVICE_ROLE_KEY"
    echo "    4. Get these values from: supabase.com/dashboard/project/${SUPABASE_PROJECT_REF}/settings/api"
    echo "    5. Once .env.local is updated, run: npm run dev"
    echo ""
    echo "  Your project is still set up correctly — Supabase just needs a few more minutes."
    echo ""
  else
    ok "Supabase is ready"
  fi

  # 4c. Get API keys
  SUPABASE_URL_VALUE="https://${SUPABASE_PROJECT_REF}.supabase.co"

  API_KEYS_OUTPUT=$(supabase projects api-keys --project-ref "$SUPABASE_PROJECT_REF" 2>/dev/null || echo "")

  if [ -n "$API_KEYS_OUTPUT" ]; then
    # Try JSON parsing first (newer CLI versions)
    SUPABASE_ANON_KEY=$(echo "$API_KEYS_OUTPUT" | jq -r '.[] | select(.name=="anon") | .api_key' 2>/dev/null || echo "")
    SUPABASE_SERVICE_ROLE_KEY=$(echo "$API_KEYS_OUTPUT" | jq -r '.[] | select(.name=="service_role") | .api_key' 2>/dev/null || echo "")

    # Fall back to table parsing if jq returned empty (CLI outputs table format)
    if [ -z "$SUPABASE_ANON_KEY" ]; then
      SUPABASE_ANON_KEY=$(echo "$API_KEYS_OUTPUT" | grep -i "anon" | awk '{print $2}')
    fi
    if [ -z "$SUPABASE_SERVICE_ROLE_KEY" ]; then
      SUPABASE_SERVICE_ROLE_KEY=$(echo "$API_KEYS_OUTPUT" | grep -i "service_role" | awk '{print $2}')
    fi
  fi

  # Verify keys were retrieved
  if [ -z "$SUPABASE_ANON_KEY" ] || [ -z "$SUPABASE_SERVICE_ROLE_KEY" ]; then
    echo ""
    warn "Could not retrieve Supabase API keys automatically."
    echo "  Get them manually from: supabase.com/dashboard/project/${SUPABASE_PROJECT_REF}/settings/api"
    echo ""
    echo "  Then add them to .env.local:"
    echo "    NEXT_PUBLIC_SUPABASE_URL=https://${SUPABASE_PROJECT_REF}.supabase.co"
    echo "    NEXT_PUBLIC_SUPABASE_ANON_KEY=[your anon key]"
    echo "    SUPABASE_SERVICE_ROLE_KEY=[your service role key]"
    echo ""
  else
    ok "API keys retrieved"
  fi

  # 4d. Run baseline migration (only if Supabase is ready)
  if [ "$SUPABASE_READY" = true ]; then
    if supabase db push --project-ref "$SUPABASE_PROJECT_REF" 2>/dev/null; then
      ok "Database schema applied"
    else
      warn "Could not apply database schema. Run manually: supabase db push --project-ref ${SUPABASE_PROJECT_REF}"
    fi
  fi

  # 4e. Configure auth redirect URLs
  if [ -n "$SUPABASE_ACCESS_TOKEN" ]; then
    AUTH_CONFIG=$(curl -s -X PATCH \
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
      }")

    ok "Auth configured"
  else
    warn "SUPABASE_ACCESS_TOKEN is not set. Skipping auth configuration."
    echo "  Set it in your shell profile and configure auth manually at supabase.com/dashboard."
  fi

  echo ""
  echo "Supabase setup complete."
  echo ""
fi

# ═════════════════════════════════════════════════════════
# STEP 5 — Generate CLAUDE.md
# ═════════════════════════════════════════════════════════

CLAUDE_TEMPLATE="${SCRIPT_DIR}/templates/claude-md.txt"

if [ -f "$CLAUDE_TEMPLATE" ]; then
  SUPABASE_URL_DISPLAY="Not configured"
  if [ -n "$SUPABASE_URL_VALUE" ]; then
    SUPABASE_URL_DISPLAY="$SUPABASE_URL_VALUE"
  fi

  STACK="Next.js 14, TypeScript, Tailwind CSS, shadcn/ui, Supabase, Vercel"
  TODAY=$(date +%Y-%m-%d)

  sed \
    -e "s|{{PROJECT_NAME}}|${PROJECT_NAME}|g" \
    -e "s|{{PROJECT_TYPE}}|${PROJECT_TYPE}|g" \
    -e "s|{{PROJECT_FOR}}|${PROJECT_FOR}|g" \
    -e "s|{{GITHUB_URL}}|https://github.com/${GITHUB_ORG}/${PROJECT_NAME}|g" \
    -e "s|{{VERCEL_URL}}|https://${PROJECT_NAME}.${LABS_DOMAIN}|g" \
    -e "s|{{SUPABASE_URL}}|${SUPABASE_URL_DISPLAY}|g" \
    -e "s|{{DATE_CREATED}}|${TODAY}|g" \
    -e "s|{{STACK}}|${STACK}|g" \
    "$CLAUDE_TEMPLATE" > CLAUDE.md

  git add CLAUDE.md
  git commit -m "chore: configure project for ${PROJECT_NAME}"
  git push origin develop

  ok "CLAUDE.md configured"
else
  warn "CLAUDE.md template not found at ${CLAUDE_TEMPLATE}. Skipping."
fi

echo ""

# ═════════════════════════════════════════════════════════
# STEP 6 — Create .env.local
# ═════════════════════════════════════════════════════════

cat > .env.local <<ENVEOF
# Supabase
NEXT_PUBLIC_SUPABASE_URL=${SUPABASE_URL_VALUE}
NEXT_PUBLIC_SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}
SUPABASE_SERVICE_ROLE_KEY=${SUPABASE_SERVICE_ROLE_KEY}

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME=${PROJECT_NAME}

# Sentry (fill in after creating Sentry project)
NEXT_PUBLIC_SENTRY_DSN=
SENTRY_ORG=friends-innovation-lab
SENTRY_PROJECT=${PROJECT_NAME}

# Resend (fill in if project uses email)
RESEND_API_KEY=
RESEND_FROM_EMAIL=noreply@${LABS_DOMAIN}

# Upstash (fill in after creating Upstash database)
UPSTASH_REDIS_REST_URL=
UPSTASH_REDIS_REST_TOKEN=

# Feature flags
NEXT_PUBLIC_ENABLE_ANALYTICS=true
NEXT_PUBLIC_MAINTENANCE_MODE=false
ENVEOF

ok ".env.local created"

# Verify Supabase values in .env.local
if [ "$NEEDS_DB" = true ]; then
  ENV_SUPABASE_URL=$(grep '^NEXT_PUBLIC_SUPABASE_URL=' .env.local | cut -d= -f2-)
  ENV_ANON_KEY=$(grep '^NEXT_PUBLIC_SUPABASE_ANON_KEY=' .env.local | cut -d= -f2-)
  ENV_SERVICE_KEY=$(grep '^SUPABASE_SERVICE_ROLE_KEY=' .env.local | cut -d= -f2-)

  if [ -z "$ENV_SUPABASE_URL" ] || [ -z "$ENV_ANON_KEY" ] || [ -z "$ENV_SERVICE_KEY" ]; then
    echo ""
    warn "Supabase keys could not be set automatically."
    [ -z "$ENV_SUPABASE_URL" ] && fail "NEXT_PUBLIC_SUPABASE_URL is empty"
    [ -z "$ENV_ANON_KEY" ] && fail "NEXT_PUBLIC_SUPABASE_ANON_KEY is empty"
    [ -z "$ENV_SERVICE_KEY" ] && fail "SUPABASE_SERVICE_ROLE_KEY is empty"
    echo ""
    echo "  Fill them in manually before running npm run dev."
    echo "  Get the values from: supabase.com/dashboard/project/${SUPABASE_PROJECT_REF}/settings/api"
    echo ""
  else
    ok "Supabase keys written to .env.local"
  fi
fi

echo ""

# ═════════════════════════════════════════════════════════
# STEP 7 — Install dependencies
# ═════════════════════════════════════════════════════════

if ! npm install; then
  echo ""
  echo -e "${RED}Dependency installation failed.${NC}"
  echo "Try running: npm install"
  echo "If it still fails, check that Node.js 18+ is installed: node --version"
  exit 1
fi

ok "Dependencies installed"
echo ""

# ═════════════════════════════════════════════════════════
# STEP 8 — Vercel setup
# ═════════════════════════════════════════════════════════
echo "Setting up Vercel..."
echo ""

# 8a. Create Vercel project via API (linked to GitHub repo)
VERCEL_CREATE=$(curl -s -X POST "https://api.vercel.com/v10/projects" \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"${PROJECT_NAME}\",
    \"framework\": \"nextjs\",
    \"gitRepository\": {
      \"type\": \"github\",
      \"repo\": \"${GITHUB_ORG}/${PROJECT_NAME}\"
    }
  }")

VERCEL_PROJECT_ID=$(echo "$VERCEL_CREATE" | jq -r '.id // empty')

if [ -z "$VERCEL_PROJECT_ID" ]; then
  echo ""
  echo -e "${RED}Something went wrong creating the Vercel project.${NC}"
  echo "$VERCEL_CREATE"
  exit 1
fi

# Link locally
vercel link --yes --project "$PROJECT_NAME" --scope "$VERCEL_ORG_ID" 2>/dev/null || true

ok "Vercel project created"

# 8b. Set environment variables
VERCEL_ENV_ERRORS=0

set_vercel_env() {
  local KEY=$1
  local VALUE=$2
  local TARGETS=$3  # JSON array like '["production","preview","development"]'

  local RESPONSE
  RESPONSE=$(curl -s -X POST "https://api.vercel.com/v10/projects/${PROJECT_NAME}/env" \
    -H "Authorization: Bearer $VERCEL_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"key\": \"${KEY}\",
      \"value\": \"${VALUE}\",
      \"type\": \"encrypted\",
      \"target\": ${TARGETS}
    }")

  local ERROR_CODE
  ERROR_CODE=$(echo "$RESPONSE" | jq -r '.error.code // empty' 2>/dev/null)

  if [ -n "$ERROR_CODE" ]; then
    local ERROR_MSG
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error.message // "Unknown error"' 2>/dev/null)
    fail "Failed to set ${KEY}: ${ERROR_MSG}"
    VERCEL_ENV_ERRORS=$((VERCEL_ENV_ERRORS + 1))
  fi
}

ALL_ENVS='["production","preview","development"]'
PROD_ONLY='["production"]'
PREVIEW_ONLY='["preview"]'
DEV_ONLY='["development"]'

# Supabase vars (all environments)
if [ -n "$SUPABASE_URL_VALUE" ]; then
  set_vercel_env "NEXT_PUBLIC_SUPABASE_URL" "$SUPABASE_URL_VALUE" "$ALL_ENVS"
  set_vercel_env "NEXT_PUBLIC_SUPABASE_ANON_KEY" "$SUPABASE_ANON_KEY" "$ALL_ENVS"
  set_vercel_env "SUPABASE_SERVICE_ROLE_KEY" "$SUPABASE_SERVICE_ROLE_KEY" "$ALL_ENVS"
fi

# App name (all environments)
set_vercel_env "NEXT_PUBLIC_APP_NAME" "$PROJECT_NAME" "$ALL_ENVS"

# App URL (per environment)
set_vercel_env "NEXT_PUBLIC_APP_URL" "https://${PROJECT_NAME}.${LABS_DOMAIN}" "$PROD_ONLY"
set_vercel_env "NEXT_PUBLIC_APP_URL" "https://${PROJECT_NAME}-*.vercel.app" "$PREVIEW_ONLY"
set_vercel_env "NEXT_PUBLIC_APP_URL" "http://localhost:3000" "$DEV_ONLY"

# Feature flags (all environments)
set_vercel_env "NEXT_PUBLIC_ENABLE_ANALYTICS" "true" "$ALL_ENVS"
set_vercel_env "NEXT_PUBLIC_MAINTENANCE_MODE" "false" "$ALL_ENVS"

# Sentry (all environments)
set_vercel_env "SENTRY_ORG" "friends-innovation-lab" "$ALL_ENVS"
set_vercel_env "SENTRY_PROJECT" "$PROJECT_NAME" "$ALL_ENVS"

# Resend (all environments)
set_vercel_env "RESEND_FROM_EMAIL" "noreply@${LABS_DOMAIN}" "$ALL_ENVS"

if [ "$VERCEL_ENV_ERRORS" -gt 0 ]; then
  warn "${VERCEL_ENV_ERRORS} environment variable(s) failed to set in Vercel."
  echo "  Check the errors above and set them manually at:"
  echo "  vercel.com/${GITHUB_ORG}/${PROJECT_NAME}/settings/environment-variables"
else
  ok "Environment variables set"
fi

# 8c. Set custom subdomain
DOMAIN_RESULT=$(curl -s -X POST "https://api.vercel.com/v10/projects/${PROJECT_NAME}/domains" \
  -H "Authorization: Bearer $VERCEL_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"${PROJECT_NAME}.${LABS_DOMAIN}\"}")

ok "Subdomain configured: ${PROJECT_NAME}.${LABS_DOMAIN}"

# 8d. Trigger first deployment
if vercel deploy --prod --yes 2>/dev/null; then
  ok "First deployment triggered"
else
  warn "Automatic deployment could not be triggered. Vercel will deploy on the next push."
fi

echo ""
echo "Vercel setup complete."
echo ""

# ═════════════════════════════════════════════════════════
# STEP 9 — Verify build locally
# ═════════════════════════════════════════════════════════

if ! npm run build 2>/dev/null; then
  echo ""
  echo -e "${YELLOW}The local build failed. This usually means a missing environment variable.${NC}"
  echo "Check your .env.local file and make sure all required values are filled in."
  echo "Run: npm run build"
  echo "to try again."
  echo ""
  BUILD_OK=false
else
  ok "Local build succeeded"
  echo ""
fi

# ═════════════════════════════════════════════════════════
# STEP 10 — Final summary
# ═════════════════════════════════════════════════════════

SUPABASE_DASHBOARD="skipped"
if [ -n "$SUPABASE_PROJECT_REF" ]; then
  SUPABASE_DASHBOARD="https://supabase.com/dashboard/project/${SUPABASE_PROJECT_REF}"
fi

echo ""
echo "╔════════════════════════════════════════════╗"
echo "║   All done. Here's your project.           ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "PROJECT"
echo "  Name:          ${PROJECT_NAME}"
echo "  Type:          ${PROJECT_TYPE}"
echo "  Created:       $(date +%Y-%m-%d)"
echo ""
echo "LINKS"
echo "  Live URL:      https://${PROJECT_NAME}.${LABS_DOMAIN}"
echo "  GitHub:        https://github.com/${GITHUB_ORG}/${PROJECT_NAME}"
echo "  Vercel:        https://vercel.com/${GITHUB_ORG}/${PROJECT_NAME}"
echo "  Supabase:      ${SUPABASE_DASHBOARD}"
echo ""
echo "LOCAL"
echo "  Folder:        ${PROJECT_DIR}"
echo "  Dev server:    npm run dev → http://localhost:3000"
echo ""

if [ "$BUILD_OK" = false ]; then
  echo -e "${YELLOW}NOTE: The local build failed. Check .env.local for missing values.${NC}"
  echo ""
fi

echo "NEXT STEPS"
echo "  1. Open the project in VS Code: code ."
echo "  2. Fill in missing values in .env.local (Sentry, Resend, Upstash)"
echo "  3. Start the dev server: npm run dev"
echo "  4. Read CLAUDE.md before asking CC to build anything"
echo ""
echo "STILL NEEDS MANUAL SETUP"
echo "  [ ] Create a Sentry project at sentry.io and add the DSN to .env.local"
echo "  [ ] Create an Upstash Redis database at upstash.com and add keys to .env.local"
echo "  [ ] Add Resend API key if this project sends emails"
echo ""
printf "Run the dev server now? (y/n) > "
read -r RUN_DEV

if [ "$RUN_DEV" = "y" ] || [ "$RUN_DEV" = "Y" ]; then
  open "http://localhost:3000"
  npm run dev
fi
