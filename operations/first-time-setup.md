# First-Time Setup

One-time setup before you can run `spinup.sh`. Do this once per machine.

---

## Prerequisites

You need accounts with access to:

| Service | What You Need |
|---------|---------------|
| **GitHub** | Member of `friends-innovation-lab` org |
| **Vercel** | Member of Friends Innovation Lab team |
| **Supabase** | Member of Friends Innovation Lab org (if using `--db`) |
| **UptimeRobot** | Account for monitoring (free tier works) |

---

## Install Required Tools

### 1. Node.js

```bash
# Check if installed
node --version

# If not installed, use Homebrew (macOS)
brew install node
```

### 2. GitHub CLI

```bash
# Install
brew install gh

# Log in (opens browser)
gh auth login

# Add delete permission (needed for cleanup)
gh auth refresh -h github.com -s delete_repo
```

### 3. Vercel CLI

```bash
# Install globally
sudo npm install -g vercel

# Log in (opens browser)
vercel login
```

### 4. Verify Everything Works

```bash
# Should all return versions or status
node --version
gh auth status
vercel whoami
```

---

## Configure Git

Set your real email (must match your GitHub account):

```bash
git config --global user.email "your-email@cityfriends.tech"
git config --global user.name "Your Name"
```

---

## Fix Common Issues

### npm Permission Errors

If you see `EACCES` or permission denied errors:

```bash
sudo chown -R $(whoami) ~/.npm
npm cache clean --force
```

### Vercel Permission Errors

If Vercel can't install updates:

```bash
sudo npm install -g vercel@latest
```

---

## You're Ready

Once all tools are installed and configured:

```bash
cd ~/projects  # or wherever you keep projects
# Run spinup from the playbook's automation folder
~/playbook/operations/automation/spinup.sh project-slug "Project Display Name"
```

Or create an alias in your shell profile:
```bash
alias spinup="~/playbook/operations/automation/spinup.sh"
```

Then you can simply run: `spinup project-slug "Project Display Name"`

See [Getting Started Guide](getting-started-guide.md) for the full project walkthrough.

---

## Cleanup Commands

If a spinup fails partway through and you need to start fresh:

### Delete GitHub Repo

```bash
gh repo delete friends-innovation-lab/project-name --yes
```

### Delete Local Folder

```bash
rm -rf project-name
```

### Delete Supabase Project

1. Go to https://supabase.com/dashboard
2. Select the project
3. Settings → General → Delete project

### Delete Vercel Project

1. Go to https://vercel.com/friends-innovation-lab
2. Select the project
3. Settings → Advanced → Delete project

---

## Upgrading Tools

Keep CLIs updated periodically:

```bash
brew upgrade gh
sudo npm install -g vercel@latest
```
