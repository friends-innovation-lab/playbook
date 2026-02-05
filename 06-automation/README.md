# Automation Scripts

## spinup.sh - Project Spinup Script

Fully automated project creation that sets up GitHub, Supabase, Vercel, and DNS in one command.

### Usage

```bash
./spinup.sh project-slug "Client Display Name"
```

### Example

```bash
./spinup.sh acme-crm "Acme Corp CRM"
```

This creates:
- **GitHub repo**: `friends-innovation-lab/acme-crm` (from project-template)
- **Supabase project**: `acme-crm` with auto-generated credentials
- **Vercel deployment**: With environment variables configured
- **Custom domain**: `acme-crm.lab.cityfriends.tech`
- **GitHub issues**: Weekly milestone issues for the 4-week sprint

### Prerequisites

Install the required CLI tools:

```bash
# GitHub CLI
brew install gh
gh auth login

# Vercel CLI
npm install -g vercel
vercel login

# Supabase CLI
brew install supabase/tap/supabase
supabase login
```

### What It Does

| Step | Action |
|------|--------|
| 1 | Creates GitHub repo from `project-template` |
| 2 | Creates Supabase project with secure DB password |
| 3 | Configures `.env.local` with Supabase credentials |
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
Supabase:  https://[project-ref].supabase.co

Local dev: cd acme-crm && npm run dev
```

### Notes

- Domain DNS is automatic (Vercel manages `lab.cityfriends.tech` nameservers)
- Database password is saved locally in `.db-password` (not committed)
- The script will prompt for Supabase API keys if auto-retrieval fails
