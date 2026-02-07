#!/bin/bash

# Friends Innovation Lab - Project Spinup Script v2.0
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
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Friends Innovation Lab - Project Spinup v2.0${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
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

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 1: Create GitHub repo from template
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}Step 1: Creating GitHub repository...${NC}"

gh repo create "${GITHUB_ORG}/${PROJECT_SLUG}" \
    --template "${GITHUB_ORG}/${TEMPLATE_REPO}" \
    --private \
    --clone

cd "${PROJECT_SLUG}"

echo -e "${GREEN}✓ Repository created and cloned${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 2: Create labels
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 3: Create milestones
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}Step 3: Creating milestones...${NC}"

gh api repos/${GITHUB_ORG}/${PROJECT_SLUG}/milestones -f title="1. Ground" -f description="Establish legitimacy and constraints" -f state="open" 2>/dev/null || true
gh api repos/${GITHUB_ORG}/${PROJECT_SLUG}/milestones -f title="2. Sense" -f description="Develop shared understanding of users and systems" -f state="open" 2>/dev/null || true
gh api repos/${GITHUB_ORG}/${PROJECT_SLUG}/milestones -f title="3. Shape" -f description="Design viable pathways" -f state="open" 2>/dev/null || true
gh api repos/${GITHUB_ORG}/${PROJECT_SLUG}/milestones -f title="4. Test" -f description="Validate in real conditions" -f state="open" 2>/dev/null || true
gh api repos/${GITHUB_ORG}/${PROJECT_SLUG}/milestones -f title="5. Embed" -f description="Ensure work lasts beyond the project" -f state="open" 2>/dev/null || true

echo -e "${GREEN}✓ Milestones created${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 4: Create GitHub Project board
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}Step 4: Creating GitHub Project board...${NC}"

# Create project and capture the URL
PROJECT_URL=$(gh project create --owner "${GITHUB_ORG}" --title "${PROJECT_NAME}" --format json 2>/dev/null | jq -r '.url' || echo "")

if [ -n "$PROJECT_URL" ]; then
    echo -e "${GREEN}✓ Project board created: ${PROJECT_URL}${NC}"
else
    echo -e "${YELLOW}⚠ Could not create project board automatically. Create manually in GitHub.${NC}"
fi
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 5: Create starter issues
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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
- [ ] Findings presented to client
- [ ] Client feedback incorporated
- [ ] Problem statement agreed upon
- [ ] Sign-off received
- [ ] Ready to proceed to Sense

## Deliverables to Present
- Stakeholder alignment snapshot
- Constraint and opportunity map
- Problem statement" \
    --label "phase:ground" --label "type:internal" --label "client-review" --milestone "1. Ground"

# ─────────────────────────────────────────────────────────────
# SENSE PHASE (8 issues)
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}  Creating Sense phase issues...${NC}"

gh issue create --title "S1: Define research questions" \
    --body "## Task
Define research questions tied to specific decisions. No research for research's sake.

## Acceptance Criteria
- [ ] Research questions documented
- [ ] Each question tied to a decision it will inform
- [ ] Methods selected for each question
- [ ] Sample size determined" \
    --label "phase:sense" --label "type:research" --milestone "2. Sense"

gh issue create --title "S2: Recruit research participants" \
    --body "## Task
Identify and recruit 5-8 participants per user segment.

## Acceptance Criteria
- [ ] User segments defined
- [ ] Recruitment criteria set
- [ ] Participants recruited (5-8 per segment)
- [ ] Sessions scheduled
- [ ] Incentives arranged (if applicable)

## User Segments to Consider
- Primary users
- Power users
- Edge cases
- Internal users
- Failed users" \
    --label "phase:sense" --label "type:research" --milestone "2. Sense"

gh issue create --title "S3: Conduct user research" \
    --body "## Task
Conduct user interviews, observations, or other research methods. Capture notes in \`/notes/interviews/\`.

## Acceptance Criteria
- [ ] All sessions completed
- [ ] Notes captured for each session
- [ ] Daily debriefs held
- [ ] Key insights flagged
- [ ] Quotes captured" \
    --label "phase:sense" --label "type:research" --milestone "2. Sense"

gh issue create --title "S4: Create journey map" \
    --body "## Task
Map the current user journey in FigJam, including pain points and bright spots.

## Acceptance Criteria
- [ ] All journey stages mapped
- [ ] Touchpoints identified
- [ ] Pain points marked (🔴)
- [ ] Bright spots marked (🟢)
- [ ] Emotional journey captured
- [ ] Exported to \`/assets/\`" \
    --label "phase:sense" --label "type:deliverable" --milestone "2. Sense"

gh issue create --title "S5: Create system map" \
    --body "## Task
Map how the current system works: user journey, service delivery, and technology layers.

## Acceptance Criteria
- [ ] User journey layer complete
- [ ] Service delivery layer complete
- [ ] Technology layer complete
- [ ] Handoffs and wait times marked
- [ ] Constraints annotated
- [ ] Reviewed with Builder
- [ ] Exported to \`/assets/\`" \
    --label "phase:sense" --label "type:deliverable" --label "type:technical" --milestone "2. Sense"

gh issue create --title "S6: Draft research findings" \
    --body "## Task
Synthesize research into findings with decision implications.

## Acceptance Criteria
- [ ] Key findings documented (3-5)
- [ ] Each finding has evidence
- [ ] Each finding has decision implication
- [ ] User segments described
- [ ] Journey pain points summarized
- [ ] Equity considerations documented
- [ ] Internal review completed" \
    --label "phase:sense" --label "type:deliverable" --milestone "2. Sense"

gh issue create --title "S7: Draft risk/impact register" \
    --body "## Task
Document current state risks, change risks, equity risks, and dependencies.

## Acceptance Criteria
- [ ] Current state risks documented
- [ ] Change risks documented
- [ ] Equity risks documented
- [ ] Dependencies identified
- [ ] Mitigations proposed
- [ ] Internal review completed" \
    --label "phase:sense" --label "type:deliverable" --milestone "2. Sense"

gh issue create --title "S8: Sense phase client sign-off" \
    --body "## Task
Present Sense phase findings to client and get sign-off to proceed to Shape.

## Acceptance Criteria
- [ ] Findings presented to client
- [ ] Client feedback incorporated
- [ ] Agreement on key insights
- [ ] Sign-off received
- [ ] Ready to proceed to Shape

## Deliverables to Present
- Research findings
- Journey map
- System map
- Risk/impact register" \
    --label "phase:sense" --label "type:internal" --label "client-review" --milestone "2. Sense"

# ─────────────────────────────────────────────────────────────
# SHAPE PHASE (8 issues)
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}  Creating Shape phase issues...${NC}"

gh issue create --title "SH1: Run ideation session" \
    --body "## Task
Facilitate ideation session to generate solution concepts.

## Acceptance Criteria
- [ ] Session scheduled (2-3 hours)
- [ ] Team reviewed Sense findings beforehand
- [ ] HMW questions prepared
- [ ] Session facilitated
- [ ] Concepts clustered into approaches
- [ ] Notes captured" \
    --label "phase:shape" --label "type:research" --milestone "3. Shape"

gh issue create --title "SH2: Develop solution options" \
    --body "## Task
Develop 2-3 viable options from ideation output.

## Acceptance Criteria
- [ ] 2-3 options selected
- [ ] Each option documented (summary, how it works, UX, ops impact)
- [ ] Effort and timeline estimated
- [ ] Risks identified
- [ ] Tradeoffs named" \
    --label "phase:shape" --label "type:deliverable" --milestone "3. Shape"

gh issue create --title "SH3: Feasibility assessment" \
    --body "## Task
Builder assesses technical feasibility of each option.

## Acceptance Criteria
- [ ] Each option assessed (1-2 hours each)
- [ ] Stack fit evaluated
- [ ] Integrations identified
- [ ] Build estimate created
- [ ] Skills gaps identified
- [ ] Risks documented
- [ ] Options compared" \
    --label "phase:shape" --label "type:technical" --milestone "3. Shape"

gh issue create --title "SH4: Create prototypes" \
    --body "## Task
Create low-to-medium fidelity prototypes for each option in Figma.

## Acceptance Criteria
- [ ] Prototype for each option
- [ ] Key user flows covered
- [ ] Real content (not lorem ipsum)
- [ ] Differentiation between options clear
- [ ] Presentation-ready" \
    --label "phase:shape" --label "type:deliverable" --milestone "3. Shape"

gh issue create --title "SH5: Tradeoff analysis" \
    --body "## Task
Map tradeoffs across options so client can make informed decision.

## Acceptance Criteria
- [ ] Evaluation criteria defined
- [ ] Each option scored
- [ ] Tradeoffs made explicit
- [ ] Comparison matrix complete" \
    --label "phase:shape" --label "type:deliverable" --milestone "3. Shape"

gh issue create --title "SH6: Draft recommendation" \
    --body "## Task
Draft Solution Options document and Recommendation Brief.

## Acceptance Criteria
- [ ] Solution Options document complete
- [ ] Recommendation Brief (one-pager) complete
- [ ] Rationale tied to findings
- [ ] Risks and mitigations included
- [ ] Internal review completed" \
    --label "phase:shape" --label "type:deliverable" --milestone "3. Shape"

gh issue create --title "SH7: Present options to client" \
    --body "## Task
Present options to client for decision.

## Acceptance Criteria
- [ ] Presentation prepared
- [ ] Internal rehearsal completed
- [ ] Options presented to client
- [ ] Questions answered
- [ ] Feedback captured" \
    --label "phase:shape" --label "type:internal" --label "client-review" --milestone "3. Shape"

gh issue create --title "SH8: Shape phase client decision" \
    --body "## Task
Get client decision on which option to pursue.

## Acceptance Criteria
- [ ] Client selects option
- [ ] Decision documented
- [ ] Scope for pilot agreed
- [ ] Sign-off received
- [ ] Ready to proceed to Test" \
    --label "phase:shape" --label "type:internal" --label "client-review" --milestone "3. Shape"

# ─────────────────────────────────────────────────────────────
# TEST PHASE (7 issues)
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}  Creating Test phase issues...${NC}"

gh issue create --title "T1: Write build brief" \
    --body "## Task
Distill Shape outputs into CC-ready Build Brief.

## Acceptance Criteria
- [ ] What we're building documented
- [ ] Pilot scope defined (in/out)
- [ ] Design links included
- [ ] Technical decisions documented
- [ ] Constraints listed
- [ ] Success criteria defined
- [ ] Open questions listed" \
    --label "phase:test" --label "type:deliverable" --milestone "4. Test"

gh issue create --title "T2: Build pilot" \
    --body "## Task
Build MVP pilot based on Build Brief.

## Acceptance Criteria
- [ ] All in-scope features built
- [ ] Internal testing completed
- [ ] Critical bugs fixed
- [ ] Monitoring in place
- [ ] Rollback plan documented
- [ ] Ready for pilot launch" \
    --label "phase:test" --label "type:technical" --milestone "4. Test"

gh issue create --title "T3: Launch pilot" \
    --body "## Task
Deploy pilot to target users.

## Acceptance Criteria
- [ ] Pilot deployed to production
- [ ] Target users have access
- [ ] Baseline metrics captured
- [ ] Support channels ready
- [ ] Monitoring active" \
    --label "phase:test" --label "type:technical" --milestone "4. Test"

gh issue create --title "T4: Monitor and collect feedback" \
    --body "## Task
Monitor pilot performance and collect user/staff feedback.

## Acceptance Criteria
- [ ] Daily monitoring completed
- [ ] User interviews conducted
- [ ] Staff feedback collected
- [ ] Issues tracked and resolved
- [ ] Mid-pilot check completed" \
    --label "phase:test" --label "type:research" --milestone "4. Test"

gh issue create --title "T5: Compile test results" \
    --body "## Task
Compile quantitative and qualitative results from pilot.

## Acceptance Criteria
- [ ] Quantitative metrics compiled
- [ ] Qualitative findings synthesized
- [ ] Technical performance documented
- [ ] Issues summarized
- [ ] Internal review completed" \
    --label "phase:test" --label "type:deliverable" --milestone "4. Test"

gh issue create --title "T6: Go/no-go recommendation" \
    --body "## Task
Prepare evidence-based go/no-go recommendation.

## Acceptance Criteria
- [ ] Recommendation drafted (Go/Iterate/No-Go)
- [ ] Evidence supports recommendation
- [ ] Risks for scaling documented
- [ ] Requirements for next step listed" \
    --label "phase:test" --label "type:deliverable" --milestone "4. Test"

gh issue create --title "T7: Test phase client decision" \
    --body "## Task
Present results and get client decision.

## Acceptance Criteria
- [ ] Results presented
- [ ] Questions answered
- [ ] Decision made (Go/Iterate/No-Go)
- [ ] Next steps agreed
- [ ] Ready to proceed to Embed (if Go)" \
    --label "phase:test" --label "type:internal" --label "client-review" --milestone "4. Test"

# ─────────────────────────────────────────────────────────────
# EMBED PHASE (8 issues)
# ─────────────────────────────────────────────────────────────
echo -e "${CYAN}  Creating Embed phase issues...${NC}"

gh issue create --title "E1: Technical documentation" \
    --body "## Task
Document architecture, deployment, database, integrations, and troubleshooting.

## Acceptance Criteria
- [ ] Architecture documented
- [ ] Environments documented
- [ ] Deployment process documented
- [ ] Database schema documented
- [ ] Integrations documented
- [ ] Monitoring/alerts documented
- [ ] Common issues and fixes documented
- [ ] Internal review completed" \
    --label "phase:embed" --label "type:deliverable" --label "type:technical" --milestone "5. Embed"

gh issue create --title "E2: Operational runbook" \
    --body "## Task
Document how to operate the solution day-to-day.

## Acceptance Criteria
- [ ] Roles and responsibilities defined
- [ ] Daily/weekly/monthly tasks documented
- [ ] User management procedures documented
- [ ] Common requests documented
- [ ] Troubleshooting guide created
- [ ] Escalation paths defined
- [ ] Internal review completed" \
    --label "phase:embed" --label "type:deliverable" --milestone "5. Embed"

gh issue create --title "E3: Design documentation" \
    --body "## Task
Document design files, design system, decisions, and future recommendations.

## Acceptance Criteria
- [ ] Design files linked
- [ ] Design system documented (colors, typography, components)
- [ ] Key decisions and rationale documented
- [ ] Accessibility notes included
- [ ] Future recommendations listed
- [ ] Internal review completed" \
    --label "phase:embed" --label "type:deliverable" --milestone "5. Embed"

gh issue create --title "E4: Training" \
    --body "## Task
Train client team to operate and maintain the solution.

## Acceptance Criteria
- [ ] Training plan created
- [ ] Technical walkthrough completed
- [ ] Operational training completed
- [ ] Admin training completed (if applicable)
- [ ] Training materials delivered
- [ ] Recordings saved (if applicable)" \
    --label "phase:embed" --label "type:internal" --milestone "5. Embed"

gh issue create --title "E5: Transfer access" \
    --body "## Task
Transfer all accounts, credentials, and access to client.

## Acceptance Criteria
- [ ] GitHub repo transferred/access granted
- [ ] Vercel account transferred/access granted
- [ ] Supabase access transferred (if applicable)
- [ ] All API keys documented
- [ ] Third-party accounts transferred
- [ ] Client can deploy independently" \
    --label "phase:embed" --label "type:technical" --milestone "5. Embed"

gh issue create --title "E6: Sustainability plan" \
    --body "## Task
Document ownership, funding, maintenance, and evolution plan.

## Acceptance Criteria
- [ ] Owner identified
- [ ] Funding documented
- [ ] Maintenance tasks assigned
- [ ] Evolution recommendations listed
- [ ] Risks documented
- [ ] Sunset criteria defined
- [ ] Internal review completed" \
    --label "phase:embed" --label "type:deliverable" --milestone "5. Embed"

gh issue create --title "E7: Measurement framework" \
    --body "## Task
Define how success will be tracked after engagement ends.

## Acceptance Criteria
- [ ] Success metrics defined
- [ ] Data collection plan created
- [ ] Reporting cadence set
- [ ] Review cadence set
- [ ] Owners assigned
- [ ] Internal review completed" \
    --label "phase:embed" --label "type:deliverable" --milestone "5. Embed"

gh issue create --title "E8: Engagement closeout" \
    --body "## Task
Get final sign-off and close engagement.

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

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 6: Update project files
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}Step 6: Updating project files...${NC}"

# Update package.json name
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/\"name\": \".*\"/\"name\": \"${PROJECT_SLUG}\"/" package.json
else
    sed -i "s/\"name\": \".*\"/\"name\": \"${PROJECT_SLUG}\"/" package.json
fi

# Create .env.local template
if [ "$CREATE_DB" = true ]; then
    cat > .env.local << EOF
# Supabase
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=

# App
NEXT_PUBLIC_APP_NAME=${PROJECT_NAME}
NEXT_PUBLIC_APP_URL=https://${DOMAIN}
EOF
else
    cat > .env.local << EOF
# App
NEXT_PUBLIC_APP_NAME=${PROJECT_NAME}
NEXT_PUBLIC_APP_URL=https://${DOMAIN}

# Database (add if needed)
# NEXT_PUBLIC_SUPABASE_URL=
# NEXT_PUBLIC_SUPABASE_ANON_KEY=
EOF
fi

# Create docs folder structure
mkdir -p docs/ground docs/sense docs/shape docs/test docs/embed
mkdir -p notes/interviews notes/meetings notes/synthesis
mkdir -p assets

# Create placeholder READMEs
echo "# Ground Phase Deliverables" > docs/ground/README.md
echo "# Sense Phase Deliverables" > docs/sense/README.md
echo "# Shape Phase Deliverables" > docs/shape/README.md
echo "# Test Phase Deliverables" > docs/test/README.md
echo "# Embed Phase Deliverables" > docs/embed/README.md

echo -e "${GREEN}✓ Project files updated${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 7: Supabase setup (if --db flag)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if [ "$CREATE_DB" = true ]; then
    echo -e "${YELLOW}Step 7: Supabase setup${NC}"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${YELLOW}ACTION REQUIRED:${NC} Create Supabase project"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
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
        sed -i '' "s|NEXT_PUBLIC_SUPABASE_URL=|NEXT_PUBLIC_SUPABASE_URL=${SUPABASE_URL}|" .env.local
        sed -i '' "s|NEXT_PUBLIC_SUPABASE_ANON_KEY=|NEXT_PUBLIC_SUPABASE_ANON_KEY=${SUPABASE_KEY}|" .env.local
    else
        sed -i "s|NEXT_PUBLIC_SUPABASE_URL=|NEXT_PUBLIC_SUPABASE_URL=${SUPABASE_URL}|" .env.local
        sed -i "s|NEXT_PUBLIC_SUPABASE_ANON_KEY=|NEXT_PUBLIC_SUPABASE_ANON_KEY=${SUPABASE_KEY}|" .env.local
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

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 8: Install dependencies
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}Step 8: Installing dependencies...${NC}"

npm install

echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 9: Deploy to Vercel
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}Step 9: Deploying to Vercel...${NC}"

# Link to Vercel
vercel link --yes

# Set environment variables in Vercel
vercel env add NEXT_PUBLIC_APP_NAME production <<< "${PROJECT_NAME}"
vercel env add NEXT_PUBLIC_APP_URL production <<< "https://${DOMAIN}"

if [ "$CREATE_DB" = true ]; then
    vercel env add NEXT_PUBLIC_SUPABASE_URL production <<< "${SUPABASE_URL}"
    vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production <<< "${SUPABASE_KEY}"
fi

# Deploy
vercel --prod

echo -e "${GREEN}✓ Deployed to Vercel${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 10: Add custom domain
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}Step 10: Adding custom domain...${NC}"

vercel domains add "${DOMAIN}"

echo ""
echo -e "${GREEN}✓ Domain added${NC}"
echo ""

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Step 11: Commit and push
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo -e "${YELLOW}Step 11: Committing changes...${NC}"

git add .
git commit -m "Initial project setup for ${PROJECT_NAME}

- Created docs/ and notes/ folder structure
- Configured environment variables
- Set up for PIM methodology"
git push

echo -e "${GREEN}✓ Changes pushed${NC}"
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
echo -e "  ${YELLOW}Next steps:${NC}"
echo "  1. Open GitHub Issues to see your project roadmap"
echo "  2. Set milestone due dates"
echo "  3. Start Ground phase!"
echo ""
