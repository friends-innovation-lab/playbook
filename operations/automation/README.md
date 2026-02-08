# Automation Scripts

## spinup.sh - Project Spinup Script

Fully automated project creation that sets up GitHub, Vercel, and DNS in one command. Optionally creates a Supabase database.

### Usage

```bash
spinup project-slug "Client Display Name"
```

### Example

```bash
spinup acme-crm "Acme Corp CRM"
```

The script will prompt:
```
Create Supabase database? (y/N):
```

Press Enter for no database, or `y` for Supabase.

### What Gets Created

- **GitHub repo**: `friends-innovation-lab/[project-slug]` (from project-template)
- **Vercel deployment**: With environment variables configured
- **Custom domain**: `[project-slug].lab.cityfriends.tech`
- **GitHub issues**: Weekly milestone issues for the 4-week sprint
- **Supabase project** (optional): With auto-generated credentials

### Prerequisites

Install the required CLI tools:

```bash
# GitHub CLI
brew install gh
gh auth login

# Vercel CLI
npm install -g vercel
vercel login

# Supabase CLI (only needed if using database)
brew install supabase/tap/supabase
supabase login
```

### What It Does

| Step | Action |
|------|--------|
| 1 | Creates GitHub repo from `project-template` |
| 2 | Creates Supabase project (if selected) |
| 3 | Configures `.env.local` |
| 4 | Installs npm dependencies |
| 5 | Deploys to Vercel with environment variables |
| 6 | Creates GitHub issues for weekly milestones |
| 7 | Commits and pushes initial setup |

### Output

After completion, you'll have:

```
Project:   Acme Corp CRM
Repo:      https://github.com/friends-innovation-lab/acme-crm
Live URL:  https://acme-crm.lab.cityfriends.tech
Supabase:  https://[project-ref].supabase.co  (if database enabled)

Local dev: cd acme-crm && npm run dev
```

### Notes

- Domain DNS is automatic (Vercel manages `lab.cityfriends.tech` nameservers)
- Database password is saved locally in `.db-password` (not committed)
- The script will prompt for Supabase API keys if auto-retrieval fails

---

## Manual Steps After Spinup

The script cannot create everything automatically. After spinup completes:

1. **Create GitHub Project board manually:**
   - Go to https://github.com/orgs/friends-innovation-lab/projects
   - Click "New project"
   - Choose "Board" template
   - Name it the same as your project
   - Link the repo to the project

2. **Set up UptimeRobot monitor:**
   - URL: `https://[project-name].lab.cityfriends.tech/api/health`
   - Interval: 5 minutes

3. **Set milestone due dates** in GitHub Issues
