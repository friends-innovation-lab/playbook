#!/bin/bash

# Friends Innovation Lab - Project Spinup Script v2.1
# Usage: spinup project-name "Client Display Name" [--db]
# Example: spinup acme-crm "Acme Corp CRM"
# Example: spinup acme-crm "Acme Corp CRM" --db  (includes Supabase)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check arguments
if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${RED}Usage: spinup project-name \"Client Display Name\" [--db]${NC}"
    echo -e "Example: spinup acme-crm \"Acme Corp CRM\""
    echo -e "Add --db flag to create Supabase database"
    exit 1
fi

PROJECT_SLUG=$1
PROJECT_NAME=$2
CREATE_DB=false
GITHUB_ORG="friends-innovation-lab"
TEMPLATE_REPO="project-template"
DOMAIN="${PROJECT_SLUG}.lab.cityfriends.tech"

# Check for --db flag
if [ "$3" == "--db" ]; then
    CREATE_DB=true
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Friends Innovation Lab - Project Spinup v2.1${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  Project:  ${GREEN}${PROJECT_NAME}${NC}"
echo -e "  Repo:     ${GREEN}${GITHUB_ORG}/${PROJECT_SLUG}${NC}"
echo -e "  Domain:   ${GREEN}${DOMAIN}${NC}"
echo -e "  Database: ${GREEN}${CREATE_DB}${NC}"
echo ""

# Check for required CLI tools
echo -e "${YELLOW}Checking requirements...${NC}"

if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed.${NC}"
    echo "Install it: brew install gh"
    exit 1
fi

if ! command -v vercel &> /dev/null; then
    echo -e "${RED}Error: Vercel CLI is not installed.${NC}"
    echo "Install it: npm install -g vercel"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo -e "${RED}Error: Not logged in to GitHub CLI.${NC}"
    echo "Run: gh auth login"
    exit 1
fi

echo -e "${GREEN}✓ All requirements met${NC}"
echo ""

# ════════════════════════════════════════════════════════════
# Step 1: Create GitHub repo from template
# ════════════════════════════════════════════════════════════
echo -e "${YELLOW}Step 1: Creating GitHub repository...${NC}"

gh repo create "${GITHUB_ORG}/${PROJECT_SLUG}" \
    --template "${GITHUB_ORG}/${TEMPLATE_REPO}" \
    --private \
    --clone

cd "${PROJECT_SLUG}"

echo -e "${GREEN}✓ Repository created and cloned${NC}"
echo ""

# ════════════════════════════════════════════════════════════
# Step 2: Create labels
# ════════════════════════════════════════════════════════════
echo -e "${YELLOW}Step 2: Creating labels...${NC}"

# Phase labels (blue)
gh label create "phase:ground" --color "0052CC" --description "Ground phase work" 2>/dev/null || true
gh label create "phase:sense" --color "0052CC" --description "Sense phase work" 2>/dev/null || true
gh label create "phase:shape" --color "0052CC" --description "Shape phase work" 2>/dev/null || true
gh label create "phase:test" --color "0052CC" --description "Test phase work" 2>/dev/null || true
gh label create "phase:embed" --color "0052CC" --description "Embed phase work" 2>/dev/null || true

# Type labels (green)
gh label create "type:research" --color "0E8A16" --description "Interviews, discovery, analysis" 2>/dev/null || true
gh label create "type:deliverable" --color "0E8A16" --description "Client-facing output" 2>/dev/null || true
gh label create "type:technical" --color "0E8A16" --description "Code, infrastructure, systems" 2>/dev/null || true
gh label create "type:internal" --color "0E8A16" --description "Internal task" 2>/dev/null || true

# Status labels
gh label create "blocked" --color "D93F0B" --description "Waiting on something" 2>/dev/null || true
gh label create "needs-review" --color "FBCA04" --description "Ready for internal review" 2>/dev/null || true
gh label create "client-review" --color "FBCA04" --description "Waiting on client" 2>/dev/null || true

echo -e "${GREEN}✓ Labels created${NC}"
echo ""

# ════════════════════════════════════════════════════════════
# Step 3: Create milestones
# ════════════════════════════════════════════════════════════
echo -e "${YELLOW}Step 3: Creating milestones...${NC}"

gh api repos/${GITHUB_ORG}/${PROJECT_SLUG}/milestones -f title="1. Ground" -f description="Establish legitimacy and constraints" -f state="open" 2>/dev/null || true
gh api repos/${GITHUB_ORG}/${PROJECT_SLUG}/milestones -f title="2. Sense" -f description="Develop shared understanding of users and systems" -f state="open" 2>/dev/null || true
gh api repos/${GITHUB_ORG}/${PROJECT_SLUG}/milestones -f title="3. Shape" -f description="Design viable pathways" -f state="open" 2>/dev/null || true
gh api repos/${GITHUB_ORG}/${PROJECT_SLUG}/milestones -f title="4. Test" -f description="Validate in real conditions" -f state="open" 2>/dev/null || true
gh api repos/${GITHUB_ORG}/${PROJECT_SLUG}/milestones -f title="5. Embed" -f description="Ensure work lasts beyond the project" -f state="open" 2>/dev/null || true

echo -e "${GREEN}✓ Milestones created${NC}"
echo ""

# ════════════════════════════════════════════════════════════
# Step 4: Create GitHub Project board
# ════════════════════════════════════════════════════════════
echo -e "${YELLOW}Step 4: Creating GitHub Project board...${NC}"

# Create project and capture the URL
PROJECT_URL=$(gh project create --owner "${GITHUB_ORG}" --title "${PROJECT_NAME}" --format json 2>/dev/null | jq -r '.url' || echo "")

if [ -n "$PROJECT_URL" ]; then
    echo -e "${GREEN}✓ Project board created: ${PROJECT_URL}${NC}"
else
    echo -e "${YELLOW}⚠ Could not create project board automatically. Create manually in GitHub.${NC}"
fi
echo ""

# ════════════════════════════════════════════════════════════
# Step 5: Create starter issues
# ════════════════════════════════════════════════════════════
echo -e "${YELLOW}Step 5: Creating starter issues...${NC}"

# ─────────────────────────────────────────────────────────────
# GROUND PHASE (8 issues)
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}  Creating Ground phase issues...${NC}"

gh issue create --title "G1: Identify stakeholders to interview" \
    --body "## Task
Identify 5-8 stakeholders across these categories:
- Decision makers
- Day-to-day operators
- Subject matter experts
- Skeptics
- Beneficiaries

## Acceptance Criteria
- [ ] List of 5-8 names with roles
- [ ] Category assigned to each
- [ ] Contact info gathered
- [ ] Priority order determined

## Links
- [Ground Phase Guide](https://github.com/${GITHUB_ORG}/playbook/blob/main/methodology/ground/README.md)" \
    --label "phase:ground" --label "type:research" --milestone "1. Ground"

gh issue create --title "G2: Schedule stakeholder interviews" \
    --body "## Task
Schedule 45-60 minute interviews with identified stakeholders.

## Acceptance Criteria
- [ ] All interviews scheduled
- [ ] Calendar invites sent
- [ ] Interview guide prepared
- [ ] Note-taking template ready" \
    --label "phase:ground" --label "type:internal" --milestone "1. Ground"

gh issue create --title "G3: Conduct stakeholder interviews" \
    --body "## Task
Conduct all scheduled stakeholder interviews. Capture notes in \`/notes/interviews/\`.

## Acceptance Criteria
- [ ] All interviews completed
- [ ] Notes captured for each interview
- [ ] Key quotes highlighted
- [ ] Follow-up items noted" \
    --label "phase:ground" --label "type:research" --milestone "1. Ground"

gh issue create --title "G4: Technical discovery" \
    --body "## Task
Review existing systems, APIs, data, and technical constraints.

## Acceptance Criteria
- [ ] Existing systems documented
- [ ] Integration points identified
- [ ] Technical constraints listed
- [ ] Data sources mapped
- [ ] Access requirements noted" \
    --label "phase:ground" --label "type:technical" --milestone "1. Ground"

gh issue create --title "G5: Draft stakeholder alignment snapshot" \
    --body "## Task
Synthesize interview findings into stakeholder alignment snapshot.

## Acceptance Criteria
- [ ] All stakeholders listed with role/interest/influence
- [ ] Champions, supporters, neutral, skeptics categorized
- [ ] Decision authority mapped
- [ ] Alignment risks identified
- [ ] Internal review completed" \
    --label "phase:ground" --label "type:deliverable" --milestone "1. Ground"

gh issue create --title "G6: Draft constraint and opportunity map" \
    --body "## Task
Document constraints (policy, technical, budget, political, timeline) and opportunities.

## Acceptance Criteria
- [ ] Policy/legal constraints documented
- [ ] Technical constraints documented
- [ ] Budget/resource constraints documented
- [ ] Political/organizational constraints documented
- [ ] Opportunities identified
- [ ] Prior attempts documented
- [ ] Internal review completed" \
    --label "phase:ground" --label "type:deliverable" --milestone "1. Ground"

gh issue create --title "G7: Draft problem statement" \
    --body "## Task
Articulate the problem clearly, including tradeoffs any solution must navigate.

## Acceptance Criteria
- [ ] Problem described in plain language
- [ ] Affected groups identified with scale
- [ ] Root causes documented
- [ ] Success metrics defined
- [ ] Tradeoffs named
- [ ] Scope boundaries set
- [ ] Internal review completed" \
    --label "phase:ground" --label "type:deliverable" --milestone "1. Ground"

gh issue create --title "G8: Ground phase client sign-off" \
    --body "## Task
Present Ground phase findings to client and get sign-off to proceed to Sense.

## Acceptance Criteria
- [ ] Client presentation scheduled
- [ ] Deliverables presented
- [ ] Feedback incorporated
- [ ] Sign-off received
- [ ] Phase documented in /docs/ground/" \
    --label "phase:ground" --label "type:internal" --label "client-review" --milestone "1. Ground"

# ─────────────────────────────────────────────────────────────
# SENSE PHASE (8 issues)
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}  Creating Sense phase issues...${NC}"

gh issue create --title "S1: Plan user research" \
    --body "## Task
Design research plan including methods, participants, and timeline.

## Acceptance Criteria
- [ ] Research questions defined
- [ ] Methods selected (interviews, observation, surveys)
- [ ] Participant criteria defined
- [ ] Recruitment plan created
- [ ] Timeline established" \
    --label "phase:sense" --label "type:research" --milestone "2. Sense"

gh issue create --title "S2: Recruit research participants" \
    --body "## Task
Recruit 8-12 participants representing key user segments.

## Acceptance Criteria
- [ ] Screener created
- [ ] Outreach completed
- [ ] 8-12 participants confirmed
- [ ] Sessions scheduled
- [ ] Incentives arranged (if applicable)" \
    --label "phase:sense" --label "type:internal" --milestone "2. Sense"

gh issue create --title "S3: Conduct user research sessions" \
    --body "## Task
Conduct research sessions (interviews, observation, usability tests).

## Acceptance Criteria
- [ ] All sessions completed
- [ ] Notes/recordings captured
- [ ] Key observations highlighted
- [ ] Synthesis notes started" \
    --label "phase:sense" --label "type:research" --milestone "2. Sense"

gh issue create --title "S4: Map current state journey" \
    --body "## Task
Document how users currently accomplish their goals (pain points, workarounds).

## Acceptance Criteria
- [ ] Current journey mapped end-to-end
- [ ] Pain points identified
- [ ] Workarounds documented
- [ ] Touchpoints mapped
- [ ] Emotions/frustrations captured" \
    --label "phase:sense" --label "type:deliverable" --milestone "2. Sense"

gh issue create --title "S5: Document system architecture" \
    --body "## Task
Map the technical landscape (systems, data flows, integrations).

## Acceptance Criteria
- [ ] Systems inventory complete
- [ ] Data flows documented
- [ ] Integration points mapped
- [ ] Technical debt identified
- [ ] Constraints documented" \
    --label "phase:sense" --label "type:technical" --milestone "2. Sense"

gh issue create --title "S6: Synthesize research findings" \
    --body "## Task
Analyze research data to identify themes, insights, and opportunities.

## Acceptance Criteria
- [ ] All data reviewed
- [ ] Themes identified
- [ ] Key insights articulated
- [ ] Opportunities prioritized
- [ ] Evidence documented" \
    --label "phase:sense" --label "type:research" --milestone "2. Sense"

gh issue create --title "S7: Create user archetypes" \
    --body "## Task
Develop archetypes representing key user segments (not fictional personas).

## Acceptance Criteria
- [ ] Key segments identified
- [ ] Archetypes documented with goals/challenges
- [ ] Validated with research data
- [ ] Internal review completed" \
    --label "phase:sense" --label "type:deliverable" --milestone "2. Sense"

gh issue create --title "S8: Sense phase client sign-off" \
    --body "## Task
Present Sense phase findings to client and get sign-off to proceed to Shape.

## Acceptance Criteria
- [ ] Client presentation scheduled
- [ ] Research findings presented
- [ ] Journey maps shared
- [ ] Feedback incorporated
- [ ] Sign-off received" \
    --label "phase:sense" --label "type:internal" --label "client-review" --milestone "2. Sense"

# ─────────────────────────────────────────────────────────────
# SHAPE PHASE (8 issues)
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}  Creating Shape phase issues...${NC}"

gh issue create --title "SH1: Generate solution concepts" \
    --body "## Task
Brainstorm multiple approaches to address identified opportunities.

## Acceptance Criteria
- [ ] Divergent brainstorm completed
- [ ] 5-10 concepts generated
- [ ] Each concept sketched/described
- [ ] Team review completed" \
    --label "phase:shape" --label "type:research" --milestone "3. Shape"

gh issue create --title "SH2: Evaluate concepts against constraints" \
    --body "## Task
Assess concepts against constraints from Ground phase.

## Acceptance Criteria
- [ ] Evaluation criteria defined
- [ ] Each concept assessed
- [ ] Feasibility rated
- [ ] Risks identified
- [ ] 2-3 concepts selected for development" \
    --label "phase:shape" --label "type:research" --milestone "3. Shape"

gh issue create --title "SH3: Design future state journey" \
    --body "## Task
Map the ideal user experience for selected concepts.

## Acceptance Criteria
- [ ] Future journey mapped
- [ ] Improvements over current state highlighted
- [ ] New touchpoints designed
- [ ] Metrics defined
- [ ] Internal review completed" \
    --label "phase:shape" --label "type:deliverable" --milestone "3. Shape"

gh issue create --title "SH4: Create wireframes/prototypes" \
    --body "## Task
Design low-fidelity wireframes or clickable prototypes.

## Acceptance Criteria
- [ ] Key screens/flows wireframed
- [ ] Interactive prototype created (if needed)
- [ ] Covers happy path + edge cases
- [ ] Internal review completed
- [ ] Ready for user feedback" \
    --label "phase:shape" --label "type:deliverable" --milestone "3. Shape"

gh issue create --title "SH5: Define technical approach" \
    --body "## Task
Document technical architecture and implementation approach.

## Acceptance Criteria
- [ ] Architecture documented
- [ ] Technology choices justified
- [ ] Integration approach defined
- [ ] Data model sketched
- [ ] Risks/dependencies identified" \
    --label "phase:shape" --label "type:technical" --milestone "3. Shape"

gh issue create --title "SH6: Validate with users" \
    --body "## Task
Test prototypes with 3-5 users to gather feedback.

## Acceptance Criteria
- [ ] Test plan created
- [ ] Sessions conducted
- [ ] Feedback captured
- [ ] Key learnings documented
- [ ] Refinements identified" \
    --label "phase:shape" --label "type:research" --milestone "3. Shape"

gh issue create --title "SH7: Refine based on feedback" \
    --body "## Task
Iterate on designs based on user feedback.

## Acceptance Criteria
- [ ] Feedback analyzed
- [ ] Priority changes identified
- [ ] Designs updated
- [ ] Re-validated if needed
- [ ] Final version documented" \
    --label "phase:shape" --label "type:deliverable" --milestone "3. Shape"

gh issue create --title "SH8: Shape phase client sign-off" \
    --body "## Task
Present Shape phase designs to client and get sign-off to proceed to Test.

## Acceptance Criteria
- [ ] Client presentation scheduled
- [ ] Designs/prototypes presented
- [ ] Technical approach reviewed
- [ ] Feedback incorporated
- [ ] Sign-off received" \
    --label "phase:shape" --label "type:internal" --label "client-review" --milestone "3. Shape"

# ─────────────────────────────────────────────────────────────
# TEST PHASE (7 issues)
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}  Creating Test phase issues...${NC}"

gh issue create --title "T1: Set up development environment" \
    --body "## Task
Configure development environment and CI/CD pipeline.

## Acceptance Criteria
- [ ] Local dev environment documented
- [ ] CI/CD pipeline configured
- [ ] Staging environment ready
- [ ] Team access verified" \
    --label "phase:test" --label "type:technical" --milestone "4. Test"

gh issue create --title "T2: Build MVP/pilot version" \
    --body "## Task
Implement the minimum viable version for pilot testing.

## Acceptance Criteria
- [ ] Core functionality implemented
- [ ] Meets acceptance criteria
- [ ] Basic error handling
- [ ] Deployed to staging
- [ ] Internal QA completed" \
    --label "phase:test" --label "type:technical" --milestone "4. Test"

gh issue create --title "T3: Define pilot parameters" \
    --body "## Task
Define pilot scope, participants, timeline, and success metrics.

## Acceptance Criteria
- [ ] Pilot scope defined
- [ ] Participants identified
- [ ] Timeline established
- [ ] Success metrics defined
- [ ] Rollback plan documented" \
    --label "phase:test" --label "type:internal" --milestone "4. Test"

gh issue create --title "T4: Run pilot" \
    --body "## Task
Execute the pilot with real users in real conditions.

## Acceptance Criteria
- [ ] Participants onboarded
- [ ] Support available during pilot
- [ ] Issues tracked and triaged
- [ ] Usage data collected
- [ ] Feedback gathered" \
    --label "phase:test" --label "type:research" --milestone "4. Test"

gh issue create --title "T5: Monitor and support pilot" \
    --body "## Task
Actively monitor pilot performance and provide user support.

## Acceptance Criteria
- [ ] Monitoring dashboards active
- [ ] Support channels established
- [ ] Issues resolved promptly
- [ ] User feedback collected continuously" \
    --label "phase:test" --label "type:internal" --milestone "4. Test"

gh issue create --title "T6: Evaluate pilot results" \
    --body "## Task
Analyze pilot data against success metrics.

## Acceptance Criteria
- [ ] All metrics analyzed
- [ ] User feedback synthesized
- [ ] Technical performance reviewed
- [ ] Go/no-go recommendation made
- [ ] Improvements identified" \
    --label "phase:test" --label "type:deliverable" --milestone "4. Test"

gh issue create --title "T7: Test phase client sign-off" \
    --body "## Task
Present pilot results and get sign-off to proceed to Embed.

## Acceptance Criteria
- [ ] Pilot results presented
- [ ] Recommendation discussed
- [ ] Next steps agreed
- [ ] Sign-off received" \
    --label "phase:test" --label "type:internal" --label "client-review" --milestone "4. Test"

# ─────────────────────────────────────────────────────────────
# EMBED PHASE (8 issues)
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}  Creating Embed phase issues...${NC}"

gh issue create --title "E1: Address pilot findings" \
    --body "## Task
Implement improvements identified during pilot.

## Acceptance Criteria
- [ ] Priority fixes implemented
- [ ] Enhancements added
- [ ] Performance optimized
- [ ] Testing completed" \
    --label "phase:embed" --label "type:technical" --milestone "5. Embed"

gh issue create --title "E2: Plan rollout" \
    --body "## Task
Create rollout plan for broader deployment.

## Acceptance Criteria
- [ ] Rollout phases defined
- [ ] Communication plan created
- [ ] Training materials prepared
- [ ] Support plan established
- [ ] Rollback plan updated" \
    --label "phase:embed" --label "type:internal" --milestone "5. Embed"

gh issue create --title "E3: Create documentation" \
    --body "## Task
Document system for users, administrators, and developers.

## Acceptance Criteria
- [ ] User guide created
- [ ] Admin guide created
- [ ] Technical documentation complete
- [ ] FAQs documented
- [ ] Video tutorials (if applicable)" \
    --label "phase:embed" --label "type:deliverable" --milestone "5. Embed"

gh issue create --title "E4: Train users and administrators" \
    --body "## Task
Conduct training sessions for end users and system administrators.

## Acceptance Criteria
- [ ] Training materials finalized
- [ ] Sessions scheduled
- [ ] Training delivered
- [ ] Feedback collected
- [ ] Materials updated based on feedback" \
    --label "phase:embed" --label "type:internal" --milestone "5. Embed"

gh issue create --title "E5: Execute rollout" \
    --body "## Task
Deploy to production and roll out to users.

## Acceptance Criteria
- [ ] Production deployment completed
- [ ] Users onboarded per plan
- [ ] Communications sent
- [ ] Support in place
- [ ] Monitoring active" \
    --label "phase:embed" --label "type:technical" --milestone "5. Embed"

gh issue create --title "E6: Knowledge transfer" \
    --body "## Task
Transfer knowledge to client team for ongoing ownership.

## Acceptance Criteria
- [ ] Technical walkthrough completed
- [ ] Documentation reviewed
- [ ] Access transferred
- [ ] Questions answered
- [ ] Client team confident to maintain" \
    --label "phase:embed" --label "type:internal" --milestone "5. Embed"

gh issue create --title "E7: Establish ongoing support model" \
    --body "## Task
Define how the solution will be supported after project ends.

## Acceptance Criteria
- [ ] Support owner identified
- [ ] Escalation paths defined
- [ ] SLAs established (if applicable)
- [ ] Monitoring ownership transferred
- [ ] Documentation location confirmed" \
    --label "phase:embed" --label "type:internal" --milestone "5. Embed"

gh issue create --title "E8: Project closeout" \
    --body "## Task
Formally close the project with lessons learned.

## Acceptance Criteria
- [ ] All deliverables accepted
- [ ] Knowledge transfer complete
- [ ] Access transferred
- [ ] Client sign-off received
- [ ] Lessons learned captured
- [ ] Project archived" \
    --label "phase:embed" --label "type:internal" --label "client-review" --milestone "5. Embed"

echo -e "${GREEN}✓ 39 starter issues created${NC}"
echo ""

# ════════════════════════════════════════════════════════════
# Step 6: Update project files
# ════════════════════════════════════════════════════════════
echo -e "${YELLOW}Step 6: Updating project files...${NC}"

# Update package.json name
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\"name\": \"project-name\"/\"name\": \"${PROJECT_SLUG}\"/" package.json
else
    sed -i "s/\"name\": \"project-name\"/\"name\": \"${PROJECT_SLUG}\"/" package.json
fi

# Update README.md
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/# Project Name/# ${PROJECT_NAME}/" README.md
    sed -i '' "s/Brief project description./${PROJECT_NAME} - A Friends Innovation Lab project./" README.md
else
    sed -i "s/# Project Name/# ${PROJECT_NAME}/" README.md
    sed -i "s/Brief project description./${PROJECT_NAME} - A Friends Innovation Lab project./" README.md
fi

# Update CLAUDE.md
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\[PROJECT_NAME\]/${PROJECT_NAME}/" CLAUDE.md
    sed -i '' "s|\[Brief description\]|${PROJECT_NAME} - A Friends Innovation Lab project|" CLAUDE.md
    sed -i '' "s|\[URL\]|https://${DOMAIN}|" CLAUDE.md
    sed -i '' "s|\[GitHub URL\]|https://github.com/${GITHUB_ORG}/${PROJECT_SLUG}|" CLAUDE.md
else
    sed -i "s/\[PROJECT_NAME\]/${PROJECT_NAME}/" CLAUDE.md
    sed -i "s|\[Brief description\]|${PROJECT_NAME} - A Friends Innovation Lab project|" CLAUDE.md
    sed -i "s|\[URL\]|https://${DOMAIN}|" CLAUDE.md
    sed -i "s|\[GitHub URL\]|https://github.com/${GITHUB_ORG}/${PROJECT_SLUG}|" CLAUDE.md
fi

# Update src/app/layout.tsx metadata
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/title: 'Project Name'/title: '${PROJECT_NAME}'/" src/app/layout.tsx
    sed -i '' "s/description: 'Project description'/description: '${PROJECT_NAME}'/" src/app/layout.tsx
else
    sed -i "s/title: 'Project Name'/title: '${PROJECT_NAME}'/" src/app/layout.tsx
    sed -i "s/description: 'Project description'/description: '${PROJECT_NAME}'/" src/app/layout.tsx
fi

# Update src/app/page.tsx
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/>Project Name</>$PROJECT_NAME</" src/app/page.tsx
else
    sed -i "s/>Project Name</>$PROJECT_NAME</" src/app/page.tsx
fi

# Create .env.local from .env.example
cp .env.example .env.local

# Update .env.local with project values
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|NEXT_PUBLIC_APP_URL=http://localhost:3000|NEXT_PUBLIC_APP_URL=https://${DOMAIN}|" .env.local
else
    sed -i "s|NEXT_PUBLIC_APP_URL=http://localhost:3000|NEXT_PUBLIC_APP_URL=https://${DOMAIN}|" .env.local
fi

# Create docs folder structure for PIM phases
mkdir -p docs/ground docs/sense docs/shape docs/test docs/embed
mkdir -p notes/interviews notes/meetings notes/synthesis
mkdir -p assets

# Create placeholder READMEs
cat > docs/ground/README.md << 'EOF'
# Ground Phase Deliverables

Store Ground phase deliverables here:
- Stakeholder alignment snapshot
- Constraint and opportunity map
- Problem statement
EOF

cat > docs/sense/README.md << 'EOF'
# Sense Phase Deliverables

Store Sense phase deliverables here:
- User research findings
- Current state journey maps
- User archetypes
EOF

cat > docs/shape/README.md << 'EOF'
# Shape Phase Deliverables

Store Shape phase deliverables here:
- Future state journey maps
- Wireframes and prototypes
- Technical architecture
EOF

cat > docs/test/README.md << 'EOF'
# Test Phase Deliverables

Store Test phase deliverables here:
- Pilot plan
- Pilot results
- Go/no-go recommendation
EOF

cat > docs/embed/README.md << 'EOF'
# Embed Phase Deliverables

Store Embed phase deliverables here:
- Documentation
- Training materials
- Rollout plan
- Lessons learned
EOF

echo -e "${GREEN}✓ Project files updated${NC}"
echo ""

# ════════════════════════════════════════════════════════════
# Step 7: Supabase setup (if --db flag)
# ════════════════════════════════════════════════════════════
if [ "$CREATE_DB" = true ]; then
    echo -e "${YELLOW}Step 7: Supabase setup${NC}"
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo -e "  ${YELLOW}ACTION REQUIRED:${NC} Create Supabase project"
    echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "  1. Go to: https://supabase.com/dashboard"
    echo "  2. Select org: Friends Innovation Lab"
    echo "  3. Click 'New Project'"
    echo "  4. Name: ${PROJECT_SLUG}"
    echo "  5. Generate a password (save it somewhere)"
    echo "  6. Click 'Create new project'"
    echo "  7. Go to Settings → API"
    echo "  8. Copy the Project URL and anon/public key"
    echo ""

    read -p "Paste your Supabase Project URL: " SUPABASE_URL
    read -p "Paste your Supabase anon/public key: " SUPABASE_KEY

    # Update .env.local with Supabase credentials
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co|NEXT_PUBLIC_SUPABASE_URL=${SUPABASE_URL}|" .env.local
        sed -i '' "s|NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key|NEXT_PUBLIC_SUPABASE_ANON_KEY=${SUPABASE_KEY}|" .env.local
    else
        sed -i "s|NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co|NEXT_PUBLIC_SUPABASE_URL=${SUPABASE_URL}|" .env.local
        sed -i "s|NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key|NEXT_PUBLIC_SUPABASE_ANON_KEY=${SUPABASE_KEY}|" .env.local
    fi

    echo ""
    echo -e "${GREEN}✓ Supabase credentials saved${NC}"
    echo ""
else
    echo -e "${YELLOW}Step 7: Skipping Supabase (no --db flag)${NC}"
    SUPABASE_URL="(not configured)"
    SUPABASE_KEY=""
    echo ""
fi

# ════════════════════════════════════════════════════════════
# Step 8: Install dependencies
# ════════════════════════════════════════════════════════════
echo -e "${YELLOW}Step 8: Installing dependencies...${NC}"

npm install

echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# ════════════════════════════════════════════════════════════
# Step 9: Initialize Husky (git hooks)
# ════════════════════════════════════════════════════════════
echo -e "${YELLOW}Step 9: Initializing git hooks...${NC}"

npx husky init 2>/dev/null || true

# Ensure pre-commit hook has correct content
echo "npx lint-staged" > .husky/pre-commit

echo -e "${GREEN}✓ Git hooks configured${NC}"
echo ""

# ════════════════════════════════════════════════════════════
# Step 10: Deploy to Vercel
# ════════════════════════════════════════════════════════════
echo -e "${YELLOW}Step 10: Deploying to Vercel...${NC}"

# Link to Vercel
vercel link --yes

# Set environment variables in Vercel
vercel env add NEXT_PUBLIC_APP_URL production <<< "https://${DOMAIN}"

if [ "$CREATE_DB" = true ] && [ -n "$SUPABASE_URL" ] && [ "$SUPABASE_URL" != "(not configured)" ]; then
    vercel env add NEXT_PUBLIC_SUPABASE_URL production <<< "${SUPABASE_URL}"
    vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production <<< "${SUPABASE_KEY}"
fi

# Deploy
vercel --prod

echo -e "${GREEN}✓ Deployed to Vercel${NC}"
echo ""

# ════════════════════════════════════════════════════════════
# Step 11: Add custom domain
# ════════════════════════════════════════════════════════════
echo -e "${YELLOW}Step 11: Adding custom domain...${NC}"

vercel domains add "${DOMAIN}"

echo ""
echo -e "${GREEN}✓ Domain added${NC}"
echo ""

# ════════════════════════════════════════════════════════════
# Step 12: Commit and push
# ════════════════════════════════════════════════════════════
echo -e "${YELLOW}Step 12: Committing changes...${NC}"

git add .
git commit -m "Initial project setup for ${PROJECT_NAME}

- Updated project name and metadata
- Created docs/ and notes/ folder structure
- Configured environment variables
- Set up for PIM methodology"
git push

echo -e "${GREEN}✓ Changes pushed${NC}"
echo ""

# ════════════════════════════════════════════════════════════
# Done!
# ════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ Project setup complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${BLUE}Project:${NC}   ${PROJECT_NAME}"
echo -e "  ${BLUE}Repo:${NC}      https://github.com/${GITHUB_ORG}/${PROJECT_SLUG}"
echo -e "  ${BLUE}Live URL:${NC}  https://${DOMAIN}"
echo -e "  ${BLUE}Database:${NC}  ${SUPABASE_URL}"
echo ""
echo -e "  ${BLUE}Created:${NC}"
echo -e "    • 5 milestones (Ground → Embed)"
echo -e "    • 39 starter issues"
echo -e "    • 12 labels"
echo -e "    • Project board"
echo ""
echo -e "  ${BLUE}Local:${NC}     cd ${PROJECT_SLUG} && npm run dev"
echo ""
echo -e "  ${YELLOW}Manual steps remaining:${NC}"
echo "  1. Set up UptimeRobot monitor:"
echo "     URL: https://${DOMAIN}/api/health"
echo "     Interval: 5 minutes"
echo ""
echo "  2. Open GitHub Issues to see your project roadmap"
echo "  3. Set milestone due dates"
echo "  4. Start Ground phase!"
echo ""
