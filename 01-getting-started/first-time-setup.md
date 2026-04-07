# First-Time Setup

Do this once when you join the lab. Takes about 30 minutes.

## 1. Core tools

Install these in order:

### Homebrew (Mac package manager)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Git
```bash
brew install git
```

### Node.js (v20 LTS)
Download from nodejs.org — use the LTS version.
Verify: `node --version` should show v20 or higher.

### GitHub CLI
```bash
brew install gh
gh auth login
```
Follow the prompts. Choose GitHub.com, HTTPS, and log in via browser.

### Supabase CLI
```bash
brew install supabase/tap/supabase
supabase login
```

### Vercel CLI
```bash
npm install -g vercel
vercel login
```

### jq (JSON processor — used by scripts)
```bash
brew install jq
```

### VS Code
Download from code.visualstudio.com

Recommended extensions (install from VS Code extensions panel):
- ESLint
- Prettier
- Tailwind CSS IntelliSense
- TypeScript and JavaScript Language Features (built in)
- GitLens

---

## 2. Environment variables

Add these to your shell profile. Open it with:
```bash
code ~/.zshrc
```

Add these lines at the bottom:
```bash
export VERCEL_TOKEN=           # vercel.com → Settings → Tokens → Create
export VERCEL_ORG_ID=          # vercel.com → Settings → General → Team ID
export GITHUB_ORG=friends-innovation-lab
export SUPABASE_ORG_ID=        # supabase.com → org settings → General
export SUPABASE_ACCESS_TOKEN=  # supabase.com → Account → Access Tokens → Generate
export LABS_DOMAIN=labs.cityfriends.tech
```

Save the file, then reload it:
```bash
source ~/.zshrc
```

---

## 3. Get access to team accounts

Ask Lapedra to add you to:
- GitHub org: `friends-innovation-lab`
- Vercel team: `friends-innovation-lab`
- Supabase org
- Figma org (if doing design work)
- Sentry org: `friends-innovation-lab`

---

## 4. Clone the playbook

```bash
git clone https://github.com/friends-innovation-lab/playbook.git
cd playbook
code .
```

---

## 5. Test the spinup script

Run a dry test to make sure everything is connected:
```bash
bash operations/automation/spinup.sh
```

It will run pre-flight checks and tell you if anything is missing.
You don't need to complete the full spinup — just verify the checks pass.

---

## You're ready

When all pre-flight checks pass, you're set up correctly.
Your next step is to read [what we build](what-we-build.md).
