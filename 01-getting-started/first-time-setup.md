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

Open your shell profile in an editor:
```bash
code ~/.zshrc
```

You'll add each variable below to the bottom of this file. Follow the steps for each one to get the value.

### VERCEL_TOKEN

1. Go to [vercel.com](https://vercel.com) and log in
2. Click your profile picture (top right)
3. Click **Account Settings**
4. Click **Tokens** in the left sidebar
5. Click **Create Token**
6. Name it `fftc-lab`, set scope to **Friends Innovation Lab**, expiration to **1 year**
7. Copy the token immediately — it only shows once
8. Add to your shell profile:
   ```bash
   export VERCEL_TOKEN=paste-your-token-here
   ```

### VERCEL_ORG_ID

1. Stay on [vercel.com](https://vercel.com) → **Settings**
2. Click **General** in the left sidebar
3. Scroll down to find **Team ID**
4. Copy that value
5. Add to your shell profile:
   ```bash
   export VERCEL_ORG_ID=paste-your-team-id-here
   ```

### GITHUB_ORG

This one is already set for you — just add it:
```bash
export GITHUB_ORG=friends-innovation-lab
```

### SUPABASE_ACCESS_TOKEN

1. Go to [supabase.com](https://supabase.com) and log in
2. Click your profile picture (top right)
3. Click **Account**
4. Click **Access Tokens** in the left sidebar
5. Click **Generate new token**
6. Name it `fftc-lab`
7. Copy the token immediately — it only shows once
8. Add to your shell profile:
   ```bash
   export SUPABASE_ACCESS_TOKEN=paste-your-token-here
   ```

### SUPABASE_ORG_ID

1. Go to [supabase.com](https://supabase.com)
2. Click your org name in the left sidebar
3. Click **Settings**
4. Click **General**
5. Copy the **Organization ID**
6. Add to your shell profile:
   ```bash
   export SUPABASE_ORG_ID=paste-your-org-id-here
   ```

### LABS_DOMAIN

This one is already set for you — just add it:
```bash
export LABS_DOMAIN=labs.cityfriends.tech
```

### Reload your profile

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

## If Supabase isn't ready after spinup

Sometimes Supabase takes longer than the spinup script waits. This is normal and usually takes 1-2 minutes. Here's what to do:

1. Go to [supabase.com/dashboard](https://supabase.com/dashboard) and watch for your project to show as **Active**
2. Once active, come back to your terminal and run:
   ```bash
   supabase db push --project-ref <your-project-ref>
   ```
3. Then go to your project's `.env.local` and confirm these values are filled in:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `SUPABASE_SERVICE_ROLE_KEY`
4. Get these values from: `supabase.com/dashboard/project/<your-project-ref>/settings/api`
5. Once `.env.local` is updated, run:
   ```bash
   npm run dev
   ```

Your project is still set up correctly — Supabase just needs a few more minutes.

---

## You're ready

When all pre-flight checks pass, you're set up correctly.
Your next step is to read [what we build](what-we-build.md).
