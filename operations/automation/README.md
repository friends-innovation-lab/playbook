# Automation Scripts

Two scripts that manage the full lifecycle of an Innovation Lab project.

## Prerequisites — one-time setup

Install required tools:
```bash
brew install gh supabase/tap/supabase git jq
npm install -g vercel
```

Log in to each service:
```bash
gh auth login
vercel login
supabase login
```

Add these to your shell profile (~/.zshrc or ~/.bashrc):
```bash
export VERCEL_TOKEN=         # vercel.com → Settings → Tokens
export VERCEL_ORG_ID=        # vercel.com → Settings → General → Team ID
export GITHUB_ORG=friends-innovation-lab
export SUPABASE_ORG_ID=      # supabase.com → org settings
export SUPABASE_ACCESS_TOKEN= # supabase.com → account → access tokens
export LABS_DOMAIN=labs.cityfriends.tech
```

Then reload your shell:
```bash
source ~/.zshrc
```

## Spinning up a project

From anywhere on your machine:
```bash
bash ~/path/to/playbook/operations/automation/spinup.sh
```

Follow the prompts. The script will ask you questions and do everything else.

## Tearing down a project

```bash
bash ~/path/to/playbook/operations/automation/teardown.sh
```

## What each script does

| Step | spinup.sh | teardown.sh |
|------|-----------|-------------|
| GitHub | Creates repo, branches, labels, issues | Archives repo |
| Supabase | Creates project, runs migration, configures auth | Exports data, deletes project |
| Vercel | Creates project, sets env vars, deploys | Removes project |
| Domain | Assigns subdomain | Removes subdomain |
| Local | Clones repo, installs deps, creates .env.local | Removes local folder (optional) |
