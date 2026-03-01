# First-Time Setup

One-time setup before you can run `spinup.sh`. Do this once per machine.

---

## Quick Reference

Already set up? Here's what you need:

```bash
# PIM client project (phases, milestones, starter issues)
spinup project-slug "Client Display Name"

# PIM client project with database
spinup project-slug "Client Display Name" --db

# Non-PIM project (just infrastructure, no phases)
spinup project-slug "Project Name" --lite

# Non-PIM project with database
spinup project-slug "Project Name" --lite --db
```

Your project will be live at `https://project-slug.lab.cityfriends.tech`.

If this is your first time, keep reading.

---

## Step 1: Get Access

You need accounts on these services before anything else:

| Service | What You Need | Who Grants Access |
|---------|---------------|-------------------|
| **GitHub** | Member of `friends-innovation-lab` org | Project Lead |
| **Vercel** | Member of Friends Innovation Lab team | Project Lead |
| **Supabase** | Member of Friends Innovation Lab org | Project Lead (only if using `--db`) |
| **UptimeRobot** | Your own account (free tier works) | Self-signup |

Don't move on until you have GitHub and Vercel access confirmed.

---

## Step 2: Install Tools

You need three CLI tools. Install them in order.

### Node.js

```bash
# Check if already installed
node --version

# If not, install with Homebrew
brew install node
```

### GitHub CLI

```bash
# Install
brew install gh

# Log in (opens browser for auth)
gh auth login

# Add repo delete permission (needed if a spinup fails and you need to clean up)
gh auth refresh -h github.com -s delete_repo
```

### Vercel CLI

```bash
# Install globally
sudo npm install -g vercel

# Log in (opens browser for auth)
vercel login
```

---

## Step 3: Configure Git

Set your identity (must match your GitHub account):

```bash
git config --global user.email "your-email@cityfriends.tech"
git config --global user.name "Your Name"
```

---

## Step 4: Verify Everything Works

Run all three. If any fail, go back and fix that step.

```bash
node --version      # Should print a version number
gh auth status      # Should show "Logged in to github.com"
vercel whoami       # Should show your username
```

---

## Step 5: Create the Spinup Alias

The spinup script lives in the playbook repo. Set up an alias so you can run it from anywhere:

```bash
# Add this line to your shell profile (~/.zshrc or ~/.bashrc)
alias spinup="~/playbook/operations/automation/spinup.sh"
```

Then reload your shell:

```bash
source ~/.zshrc   # or source ~/.bashrc
```

Now you can run `spinup` from any directory.

---

## Step 6: Run Your First Project

```bash
cd ~/projects  # or wherever you keep project folders

# For a PIM client project
spinup project-slug "Client Display Name"

# For a non-PIM project (no phases, milestones, or starter issues)
spinup project-slug "Project Name" --lite
```

Add `--db` to either command if you need a Supabase database.

The script will create your GitHub repo, deploy to Vercel, configure the domain, and (for PIM projects) set up milestones, labels, and starter issues. When it finishes, your project is live at `https://project-slug.lab.cityfriends.tech`.

**After the script finishes, you still need to manually:**

1. Set up UptimeRobot monitoring for `https://project-slug.lab.cityfriends.tech/api/health` (5-minute interval)
2. Set milestone due dates in GitHub (PIM projects only)

---

## Troubleshooting

### npm Permission Errors

If you see `EACCES` or permission denied:

```bash
sudo chown -R $(whoami) ~/.npm
npm cache clean --force
```

### Vercel Permission Errors

If Vercel can't install or update:

```bash
sudo npm install -g vercel@latest
```

### Spinup Failed Partway Through

If the script errors out mid-run, clean up before retrying:

```bash
# Delete the GitHub repo
gh repo delete friends-innovation-lab/project-slug --yes

# Delete the local folder
rm -rf project-slug
```

If the script got far enough to create Supabase or Vercel projects, delete those manually:

- **Supabase:** https://supabase.com/dashboard → select project → Settings → General → Delete project
- **Vercel:** https://vercel.com/friends-innovation-lab → select project → Settings → Advanced → Delete project

---

## Keeping Tools Updated

Run these periodically:

```bash
brew upgrade gh
sudo npm install -g vercel@latest
```
