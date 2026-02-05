#!/bin/bash

# Friends Innovation Lab - Project Spinup Script v2.0
# Fully automated: GitHub + Supabase + Vercel + DNS
# Usage: spinup project-name "Client Display Name"
# Example: spinup acme-crm "Acme Corp CRM"

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

# Check arguments
if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${RED}Usage: spinup project-name \"Client Display Name\"${NC}"
    echo -e "Example: spinup acme-crm \"Acme Corp CRM\""
    exit 1
fi

PROJECT_SLUG=$1
PROJECT_NAME=$2
DOMAIN="${PROJECT_SLUG}.lab.cityfriends.tech"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Friends Innovation Lab - Project Spinup v2.0${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Project: ${GREEN}${PROJECT_NAME}${NC}"
echo -e "  Repo:    ${GREEN}${GITHUB_ORG}/${PROJECT_SLUG}${NC}"
echo -e "  Domain:  ${GREEN}${DOMAIN}${NC}"
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

if ! command -v supabase &> /dev/null; then
    MISSING_TOOLS="${MISSING_TOOLS}\n  - Supabase CLI: brew install supabase/tap/supabase"
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

# Check Supabase auth by trying to list projects
if ! supabase projects list &> /dev/null; then
    echo -e "${RED}Error: Not logged in to Supabase CLI. Run: supabase login${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All requirements met${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 1: Create GitHub repo from template
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}Step 1/7: Creating GitHub repository...${NC}"

gh repo create "${GITHUB_ORG}/${PROJECT_SLUG}" \
    --template "${GITHUB_ORG}/${TEMPLATE_REPO}" \
    --private \
    --clone

cd "${PROJECT_SLUG}"

echo -e "${GREEN}✓ Repository created and cloned${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 2: Create Supabase project
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}Step 2/7: Creating Supabase project...${NC}"

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

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 3: Update project files
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}Step 3/7: Configuring project files...${NC}"

# Update package.json name
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\"name\": \".*\"/\"name\": \"${PROJECT_SLUG}\"/" package.json
else
    sed -i "s/\"name\": \".*\"/\"name\": \"${PROJECT_SLUG}\"/" package.json
fi

# Create .env.local with Supabase credentials
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

echo -e "${GREEN}✓ Project files configured${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 4: Install dependencies
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}Step 4/7: Installing dependencies...${NC}"

npm install

echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 5: Deploy to Vercel with domain
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}Step 5/7: Deploying to Vercel...${NC}"

# Link to Vercel
vercel link --yes

# Set environment variables
vercel env add NEXT_PUBLIC_SUPABASE_URL production <<< "${SUPABASE_URL}"
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production <<< "${SUPABASE_KEY}"
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
# Step 6: Create GitHub issues
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}Step 6/7: Creating GitHub issues...${NC}"

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
# Step 7: Commit and push
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}Step 7/7: Committing changes...${NC}"

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
echo -e "  ${BLUE}Supabase:${NC}  ${SUPABASE_URL}"
echo ""
echo -e "  ${BLUE}Local dev:${NC} cd ${PROJECT_SLUG} && npm run dev"
echo ""
echo -e "  ${YELLOW}The site should be live in 1-2 minutes.${NC}"
echo ""
