# Troubleshooting

What to do when the spinup script runs but something doesn't
work correctly. Find your issue below and follow the steps.

---

## Homebrew not found after installation

*↩ Related to [Step 3 — Install Homebrew](../01-getting-started/01-first-time-setup.md#step-3--install-homebrew)*

**Symptom:** You run `brew --version` and see:
```
zsh: command not found: brew
```

**Why it happens:** On Apple Silicon Macs (M1, M2, M3), Homebrew installs
to `/opt/homebrew/` which is not in your PATH by default. The installer
shows "Next steps" commands that add it, but they are easy to miss.

**How to fix it:**

Run these three commands in Terminal:

```bash
echo >> ~/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
```

Then reload your shell profile:

```bash
source ~/.zprofile
```

Verify it worked:

```bash
brew --version
```

You should see `Homebrew 4.x.x`.

---

## Supabase keys are empty after spinup

*↩ Related to [Step 7 — Install Supabase CLI](../01-getting-started/01-first-time-setup.md#step-7--install-supabase-cli)*

**Symptom:** The spinup script completed but `.env.local` has
blank values for `NEXT_PUBLIC_SUPABASE_URL` and
`NEXT_PUBLIC_SUPABASE_ANON_KEY`. The dev server shows an error
about missing Supabase credentials.

**Why it happens:** Supabase sometimes takes longer than expected
to provision. The script tried to fetch the keys before they
were ready.

**How to fix it:**

1. Go to **supabase.com/dashboard**
2. Find your project — wait until the status shows a green dot
   and says **Active** (can take up to 2 minutes)
3. Click your project name
4. In the left sidebar click **Settings**
5. Click **API**
6. Copy these three values:
   - **Project URL** — this is your `NEXT_PUBLIC_SUPABASE_URL`
   - **anon / public** key — this is your `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - **service_role** key — this is your `SUPABASE_SERVICE_ROLE_KEY`
7. Open your project folder in VS Code
8. Open the file called `.env.local`
9. Paste each value after the matching variable name:
   ```
   NEXT_PUBLIC_SUPABASE_URL=https://yourprojectref.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
   SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
   ```
10. Save the file (Command + S)
11. Run the database migration:
    ```bash
    supabase db push --project-ref YOUR_PROJECT_REF
    ```
    Replace `YOUR_PROJECT_REF` with the ref shown in your
    Supabase dashboard URL. It looks like `abcdefghijklmnop`.
12. Restart the dev server:
    ```bash
    npm run dev
    ```

---

## Dev server crashes with Supabase error

*↩ Related to [Step 7 — Install Supabase CLI](../01-getting-started/01-first-time-setup.md#step-7--install-supabase-cli)*

**Symptom:** You run `npm run dev` and see:
```
Error: Your project's URL and Key are required to create a Supabase client
```

**Why it happens:** The Supabase environment variables in `.env.local`
are empty.

**How to fix it:** Follow the steps above in
**Supabase keys are empty after spinup**.

---

## Vercel environment variables not set

*↩ Related to [Step 11 — Set up your environment variables](../01-getting-started/01-first-time-setup.md#step-11--set-up-your-environment-variables)*

**Symptom:** The spinup script completed but when you open your
project on the live URL it shows errors that don't happen locally.

**Why it happens:** The Vercel API calls to set environment
variables may have failed silently.

**How to fix it:**

1. Go to **vercel.com**
2. Find your project
3. Click **Settings**
4. Click **Environment Variables**
5. Check that `NEXT_PUBLIC_SUPABASE_URL` and
   `NEXT_PUBLIC_SUPABASE_ANON_KEY` are listed
6. If they are missing, add them manually:
   - Click **Add**
   - Enter the key name
   - Enter the value from your `.env.local` file
   - Select all three environments (Production, Preview, Development)
   - Click **Save**
7. Redeploy the project:
   ```bash
   vercel deploy --prod
   ```

---

## Subdomain not resolving

*↩ Related to [Step 8 — Install Vercel CLI](../01-getting-started/01-first-time-setup.md#step-8--install-vercel-cli)*

**Symptom:** `[name].lab.cityfriends.tech` returns an error or
does not load.

**Why it happens:** DNS changes can take up to 24 hours to propagate,
or the domain was not configured correctly in Vercel.

**How to fix it:**

1. Go to vercel.com → your project → Settings → Domains
2. Check that `[name].lab.cityfriends.tech` is listed
3. If it shows a warning or error, click the domain and follow
   Vercel's instructions to verify it
4. If it is not listed at all, add it:
   ```bash
   curl -X POST "https://api.vercel.com/v10/projects/[name]/domains" \
     -H "Authorization: Bearer $VERCEL_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"name": "[name].lab.cityfriends.tech"}'
   ```
5. If it still does not work after 24 hours, message Lapedra —
   the DNS record may need updating at the domain registrar

---

## GitHub repo was not created

*↩ Related to [Step 6 — Install GitHub CLI](../01-getting-started/01-first-time-setup.md#step-6--install-github-cli)*

**Symptom:** The spinup script exited early or the GitHub repo
does not appear under `github.com/friends-innovation-lab`.

**How to fix it:**

1. Check if the repo exists already:
   ```bash
   gh repo view friends-innovation-lab/[name]
   ```
2. If it does not exist, create it manually:
   ```bash
   gh repo create friends-innovation-lab/[name] \
     --template friends-innovation-lab/project-template \
     --private \
     --description "your description"
   ```
3. Clone it locally:
   ```bash
   cd ~/projects
   git clone https://github.com/friends-innovation-lab/[name].git
   cd [name]
   ```
4. Run the rest of the spinup steps manually following the
   README in `automation/`

---

## Pre-flight checks fail after setup

*↩ Related to [Creating a project — Before you start](01-creating-a-project.md#before-you-start)*

**Symptom:** You ran through all of first-time-setup.md but
the spinup script still shows ✗ for some checks.

**Common causes and fixes:**

**Tool not found after installing:**
Close Terminal completely and reopen it. Some installs require
a fresh Terminal session to take effect.

**Environment variable shows blank:**
```bash
echo $VERCEL_TOKEN
```
If blank, your `.zshrc` was not saved or not reloaded. Open it
again, check the values are there, save, and run:
```bash
source ~/.zshrc
```

**GitHub CLI not authenticated:**
```bash
gh auth login
```
Follow the prompts again.

**Vercel CLI not authenticated:**
```bash
vercel login
```

**Supabase CLI not authenticated:**
```bash
supabase login
```

---

## Sentry DSN not set

*↩ Related to [Step 11 — Set up your environment variables](../01-getting-started/01-first-time-setup.md#step-11--set-up-your-environment-variables)*

**Symptom:** The app runs but errors are not appearing in Sentry,
or you see a warning about a missing DSN.

**Why it happens:** Sentry requires a project to be created manually
before the DSN is available. The spinup script cannot do this
automatically.

**How to fix it:**

1. Go to **sentry.io** and log in
2. Click **Projects** in the left sidebar
3. Click **Create Project**
4. Select **Next.js** as the platform
5. Name the project the same as your project name
6. Click **Create Project**
7. Sentry shows you a DSN — copy it
8. Add it to `.env.local` in your project:
   ```
   NEXT_PUBLIC_SENTRY_DSN=your-dsn-here
   ```
9. Add it to Vercel environment variables:
   - vercel.com → your project → Settings → Environment Variables
   - Add `NEXT_PUBLIC_SENTRY_DSN` with your DSN value
   - Select all three environments
   - Save and redeploy

---

## Vercel CLI install fails with permissions error

*↩ Related to [Step 8 — Install Vercel CLI](../01-getting-started/01-first-time-setup.md#step-8--install-vercel-cli)*

**Symptom:** You see this error when running `npm install -g vercel`:
```
npm error code: 'EACCES'
npm error syscall: 'mkdir'
npm error path: '/usr/local/lib/node_modules/vercel'
```

**Why it happens:** The global npm folder on your Mac requires admin
permissions to write to.

**How to fix it:**
```bash
sudo npm install -g vercel
```

It will ask for your Mac password. Type it and press Enter.
Nothing appears as you type — that is normal.

---

## Git commit fails — user identity not configured

*↩ Related to [Step 4 — Install Git](../01-getting-started/01-first-time-setup.md#step-4--install-git)*

**Symptom:** You try to commit and see:
```
Author identity unknown
*** Please tell me who you are.
```

**Why it happens:** Git requires a name and email before it will
create a commit. This is separate from your GitHub login.

**How to fix it:**

Run this in Terminal:

```bash
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

> [!IMPORTANT]
> Use the email address that is on your GitHub account.
> Ask Lapedra if you are not sure which email to use.

Then retry your commit.

---

## Spinup fails pushing develop branch

*↩ Related to [Creating a project — Spin up the project](01-creating-a-project.md#phase-3--spin-up-the-project)*

**Symptom:** The spinup script fails when trying to push the
`develop` branch. You see an error like:
```
error: src refspec develop does not match any
```

**Why it happens:** The repo was created but the initial commit
or branch setup did not complete correctly.

**How to fix it:**

Run these commands from inside your project folder:

```bash
git pull origin main
git checkout -b develop
git push origin develop
```

This pulls the latest from main, creates the develop branch
locally, and pushes it to GitHub.

---

## Figma MCP not connecting

*↩ Related to [If you are a builder — creating-a-project.md](01-creating-a-project.md#if-you-are-a-builder)*

**Symptom:** You run `/mcp` in Claude Code and don't see Figma
listed, or CC says it cannot access Figma files.

**Fix 1 — Restart Claude Code**
MCP connections initialize at startup. If you added the plugin
mid-session, restart Claude Code completely and try again.

**Fix 2 — Re-authenticate**
Run `/mcp` in Claude Code, select the Figma server, choose
Authenticate, and complete the OAuth flow in your browser.
Make sure you are logged into the correct Figma account.

**Fix 3 — Reinstall the plugin**
```bash
claude plugin install figma@claude-plugins-official
```

**Fix 4 — Check your Figma plan**
The Figma MCP has usage limits on free plans (6 tool calls per month).
If you have hit the limit, you will need a paid Figma seat.
Ask Lapedra about the lab's Figma plan.

---

## Claude Code not connecting

*↩ Related to [Step 15 — Install Claude Code in VS Code](../01-getting-started/01-first-time-setup.md#step-15--install-claude-code-in-vs-code)*

**Symptom:** You installed the Claude Code extension but the panel
shows a sign-in button even after logging in, or the Claude icon
does not appear in the sidebar.

**Fix 1 — Reload VS Code**
Press **Command + Shift + P**, type `Reload Window`, press Enter.
This restarts VS Code without closing it. Try signing in again.

**Fix 2 — Check you installed the right extension**
In the Extensions panel search for Claude Code and confirm it says
published by **Anthropic**. There are other Claude extensions —
make sure it is the official Anthropic one.

**Fix 3 — Sign out and back in**
In the Claude Code panel click the account menu and sign out.
Then click Sign in again and go through the browser flow.

**Fix 4 — Check your subscription**
Claude Code requires an active Anthropic account with a Claude
subscription. If your account does not have access, ask Lapedra
to check the team plan.

---

## Something else is wrong

*↩ Related to [Creating a project — Before you start](01-creating-a-project.md#before-you-start)*

If your issue is not listed here:

1. Check the terminal output from when you ran the spinup script
   — look for any lines starting with ✗ or ⚠
2. Search for the exact error message in the output
3. Bring the full terminal output to Lapedra or your project lead

When reporting an issue, always include:
- The exact error message
- Which step in the spinup script it happened at
- Your operating system and Node.js version (`node --version`)
