#!/bin/bash

# Friends Innovation Lab - Project Spinup Script v2.1
# Fully automated: GitHub + Vercel + DNS (+ optional Supabase)
# Usage: spinup project-name "Client Display Name" [--db]
# Example: spinup acme-crm "Acme Corp CRM"          # No database
# Example: spinup acme-crm "Acme Corp CRM" --db    # With Supabase database

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
GITHUB_ORG="friends-innovation-lab"
TEMPLATE_REPO="project-template"
SUPABASE_ORG_ID="esiwooovlhcuifbbkodk"  # Friends Innovation Lab
SUPABASE_REGION="us-east-1"               # Default region

# Parse arguments
WITH_DB=false
if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${RED}Usage: spinup project-name \"Client Display Name\" [--db]${NC}"
    echo -e "Example: spinup acme-crm \"Acme Corp CRM\"          # No database"
    echo -e "Example: spinup acme-crm \"Acme Corp CRM\" --db    # With Supabase database"
    exit 1
fi

PROJECT_SLUG=$1
PROJECT_NAME=$2

# Check for --db flag
if [ "$3" = "--db" ]; then
    WITH_DB=true
fi

DOMAIN="${PROJECT_SLUG}.lab.cityfriends.tech"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Friends Innovation Lab - Project Spinup v2.1${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Project:  ${GREEN}${PROJECT_NAME}${NC}"
echo -e "  Repo:     ${GREEN}${GITHUB_ORG}/${PROJECT_SLUG}${NC}"
echo -e "  Domain:   ${GREEN}${DOMAIN}${NC}"
if [ "$WITH_DB" = true ]; then
    echo -e "  Database: ${GREEN}Supabase (enabled)${NC}"
else
    echo -e "  Database: ${YELLOW}None (use --db to enable)${NC}"
fi
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Check requirements
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}Checking requirements...${NC}"

MISSING_TOOLS=""

if ! command -v gh &> /dev/null; then
    MISSING_TOOLS="${MISSING_TOOLS}\n  - GitHub CLI: brew install gh"
fi

if ! command -v vercel &> /dev/null; then
    MISSING_TOOLS="${MISSING_TOOLS}\n  - Vercel CLI: npm install -g vercel"
fi

if [ "$WITH_DB" = true ]; then
    if ! command -v supabase &> /dev/null; then
        MISSING_TOOLS="${MISSING_TOOLS}\n  - Supabase CLI: brew install supabase/tap/supabase"
    fi
fi

if [ -n "$MISSING_TOOLS" ]; then
    echo -e "${RED}Missing required tools:${MISSING_TOOLS}${NC}"
    exit 1
fi

# Check authentication
if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: Not logged in to GitHub CLI. Run: gh auth login${NC}"
    exit 1
fi

if [ "$WITH_DB" = true ]; then
    # Check Supabase auth by trying to list projects
    if ! supabase projects list &> /dev/null; then
        echo -e "${RED}Error: Not logged in to Supabase CLI. Run: supabase login${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓ All requirements met${NC}"
echo ""

# Determine total steps
if [ "$WITH_DB" = true ]; then
    TOTAL_STEPS=7
else
    TOTAL_STEPS=6
fi
CURRENT_STEP=0

next_step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    echo -e "${YELLOW}Step ${CURRENT_STEP}/${TOTAL_STEPS}: $1${NC}"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step: Create GitHub repo from template
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
next_step "Creating GitHub repository..."

gh repo create "${GITHUB_ORG}/${PROJECT_SLUG}" \
    --template "${GITHUB_ORG}/${TEMPLATE_REPO}" \
    --private \
    --clone

cd "${PROJECT_SLUG}"

echo -e "${GREEN}✓ Repository created and cloned${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step: Create Supabase project (only if --db flag)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [ "$WITH_DB" = true ]; then
    next_step "Creating Supabase project..."

    # Generate a secure database password
    DB_PASSWORD=$(openssl rand -base64 24 | tr -dc 'a-zA-Z0-9' | head -c 24)

    # Create the Supabase project
    supabase projects create "${PROJECT_SLUG}" \
        --org-id "${SUPABASE_ORG_ID}" \
        --db-password "${DB_PASSWORD}" \
        --region "${SUPABASE_REGION}"

    echo -e "  Waiting for project to initialize..."
    sleep 30  # Supabase needs time to provision

    # Get the project ref (ID) from the project list
    PROJECT_REF=$(supabase projects list --json 2>/dev/null | grep -o "\"id\":\"[^\"]*\"" | grep -o "[a-z]*-[a-z]*-[a-z]*" | head -1)

    # Alternative: extract from projects list output
    if [ -z "$PROJECT_REF" ]; then
        PROJECT_REF=$(supabase projects list 2>/dev/null | grep "${PROJECT_SLUG}" | awk '{print $1}')
    fi

    if [ -z "$PROJECT_REF" ]; then
        echo -e "${RED}Error: Could not get Supabase project reference${NC}"
        echo "Please check your Supabase dashboard and get the project URL manually."
        read -p "Paste your Supabase Project URL: " SUPABASE_URL
        read -p "Paste your Supabase anon/public key: " SUPABASE_KEY
    else
        # Construct the URL and get API keys
        SUPABASE_URL="https://${PROJECT_REF}.supabase.co"

        # Get the anon key using the API keys command
        SUPABASE_KEY=$(supabase projects api-keys --project-ref "${PROJECT_REF}" 2>/dev/null | grep "anon" | awk '{print $2}')

        if [ -z "$SUPABASE_KEY" ]; then
            echo -e "${YELLOW}Could not auto-retrieve API key. Getting from dashboard...${NC}"
            read -p "Paste your Supabase anon/public key: " SUPABASE_KEY
        fi
    fi

    echo -e "${GREEN}✓ Supabase project created${NC}"
    echo -e "  URL: ${SUPABASE_URL}"
    echo ""
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step: Update project files
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
next_step "Configuring project files..."

# Update package.json name
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\"name\": \".*\"/\"name\": \"${PROJECT_SLUG}\"/" package.json
else
    sed -i "s/\"name\": \".*\"/\"name\": \"${PROJECT_SLUG}\"/" package.json
fi

# Create .env.local
if [ "$WITH_DB" = true ]; then
    cat > .env.local << EOF
# Supabase
NEXT_PUBLIC_SUPABASE_URL=${SUPABASE_URL}
NEXT_PUBLIC_SUPABASE_ANON_KEY=${SUPABASE_KEY}

# App
NEXT_PUBLIC_APP_NAME=${PROJECT_NAME}
NEXT_PUBLIC_APP_URL=https://${DOMAIN}
EOF

    # Save DB password securely (for reference only - not committed)
    echo "${DB_PASSWORD}" > .db-password
    echo ".db-password" >> .gitignore
else
    cat > .env.local << EOF
# Supabase - Add credentials if needed later
# NEXT_PUBLIC_SUPABASE_URL=
# NEXT_PUBLIC_SUPABASE_ANON_KEY=

# App
NEXT_PUBLIC_APP_NAME=${PROJECT_NAME}
NEXT_PUBLIC_APP_URL=https://${DOMAIN}
EOF
fi

echo -e "${GREEN}✓ Project files configured${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step: Install dependencies
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
next_step "Installing dependencies..."

npm install

echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step: Deploy to Vercel with domain
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
next_step "Deploying to Vercel..."

# Link to Vercel
vercel link --yes

# Set environment variables
if [ "$WITH_DB" = true ]; then
    vercel env add NEXT_PUBLIC_SUPABASE_URL production <<< "${SUPABASE_URL}"
    vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production <<< "${SUPABASE_KEY}"
fi
vercel env add NEXT_PUBLIC_APP_NAME production <<< "${PROJECT_NAME}"
vercel env add NEXT_PUBLIC_APP_URL production <<< "https://${DOMAIN}"

# Deploy
vercel --prod

# Add custom domain (DNS auto-configured since Vercel manages nameservers)
echo -e "  Adding custom domain..."
vercel domains add "${DOMAIN}"

echo -e "${GREEN}✓ Deployed to Vercel with custom domain${NC}"
echo -e "  ${BLUE}Note: Domain is automatically configured (no manual DNS needed!)${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step: Create GitHub issues
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
next_step "Creating GitHub issues..."

gh issue create --title "Week 1: Discovery & Setup" --body "- [ ] Kickoff call with client
- [ ] Review requirements/goals
- [ ] Set up database schema
- [ ] Create initial wireframes
- [ ] Client approval on direction" --label "phase:discovery" 2>/dev/null || true

gh issue create --title "Week 2: Core Build" --body "- [ ] Build primary user flows
- [ ] Implement core features
- [ ] Set up authentication (if needed)
- [ ] Mid-point check-in with client" --label "phase:build" 2>/dev/null || true

gh issue create --title "Week 3: Iteration" --body "- [ ] Client feedback incorporated
- [ ] Secondary features
- [ ] Polish UI/UX
- [ ] Bug fixes" --label "phase:iteration" 2>/dev/null || true

gh issue create --title "Week 4: Delivery" --body "- [ ] Final client review
- [ ] Documentation
- [ ] Handoff prep
- [ ] Deploy to production" --label "phase:delivery" 2>/dev/null || true

echo -e "${GREEN}✓ GitHub issues created${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step: Commit and push
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
next_step "Committing changes..."

git add .
git commit -m "Initial project setup for ${PROJECT_NAME}"
git push

echo -e "${GREEN}✓ Changes pushed to GitHub${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Done!
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✓ Project setup complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BLUE}Project:${NC}   ${PROJECT_NAME}"
echo -e "  ${BLUE}Repo:${NC}      https://github.com/${GITHUB_ORG}/${PROJECT_SLUG}"
echo -e "  ${BLUE}Live URL:${NC}  https://${DOMAIN}"
if [ "$WITH_DB" = true ]; then
    echo -e "  ${BLUE}Supabase:${NC}  ${SUPABASE_URL}"
fi
echo ""
echo -e "  ${BLUE}Local dev:${NC} cd ${PROJECT_SLUG} && npm run dev"
echo ""
echo -e "  ${YELLOW}The site should be live in 1-2 minutes.${NC}"
echo ""
