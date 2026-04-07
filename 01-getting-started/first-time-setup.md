# First-Time Setup

Do this once when you join the lab. Takes about 45 minutes.
Follow every step in order — do not skip anything.

When you are done, every pre-flight check in the spinup script
will pass and you will be ready to start your first project.

---

## Step 1 — Download and install VS Code

VS Code is the code editor the entire lab uses. You write and view
code inside it, and it connects to all the tools below.

1. Go to **code.visualstudio.com**
2. Click the big blue **Download for Mac** button
3. Open your Downloads folder and double-click the file that downloaded
4. Drag the VS Code icon into your Applications folder when prompted
5. Open VS Code from your Applications folder or Spotlight search

**Verify it worked:** VS Code opens and you see a welcome screen.

---

## Step 2 — Open Terminal

Terminal is the command-line interface on your Mac. You type commands
here to install tools, run scripts, and manage your projects.
You will use Terminal constantly when working on lab projects.

**How to open Terminal:**
1. Press **Command + Space** on your keyboard to open Spotlight search
2. Type `Terminal`
3. Press Enter
4. A window opens with a prompt that ends in `%` or `$`

Keep Terminal open. You will use it for every step below.

---

## Step 3 — Install Homebrew

Homebrew is a package manager for Mac. It lets you install developer
tools with a single command. Install it first — everything else
depends on it.

Paste this entire command into Terminal and press Enter:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

It will ask for your Mac password. Type it and press Enter.
Nothing appears as you type — that is normal.
The installation takes 2-5 minutes.

After the installation finishes, Homebrew will show a "Next steps" section.
You must run all three commands it shows. They look like this:

```bash
echo >> /Users/[yourname]/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> /Users/[yourname]/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv zsh)"
```

Copy and run each one exactly as shown in your terminal — do not skip the third one.
The third command activates Homebrew immediately in your current session.
Without it, you will see `zsh: command not found: brew` on the next step.

Then reload your shell profile:

```bash
source ~/.zprofile
```

**Verify it worked:**
```bash
brew --version
```
You should see `Homebrew 4.x.x`

**Note:** This extra step is only required on Macs with Apple Silicon (M1, M2, M3 chips).
If you are on an older Intel Mac you can skip straight to verifying the version.

---

## Step 4 — Install Git

Git tracks changes to code and lets the team share work.
Every project uses it.

```bash
brew install git
```

**Verify it worked:**
```bash
git --version
```
You should see something like `git version 2.x.x`

---

## Step 5 — Install Node.js

Node.js runs JavaScript on your computer. Every project in the lab
requires Node.js version 20 or higher.

1. Go to **nodejs.org**
2. Click the button labeled **LTS** (not Current)
3. Open the downloaded file and follow the installer steps
4. When it finishes, **close Terminal and reopen it**

**Verify it worked:**
```bash
node --version
```
You should see `v20.x.x` or higher.

---

## Step 6 — Install GitHub CLI

The GitHub CLI lets the spinup script create and manage GitHub repos
automatically on your behalf.

```bash
brew install gh
```

Then log in to GitHub:
```bash
gh auth login
```

Follow the prompts exactly:
- **What account?** → GitHub.com
- **What protocol?** → HTTPS
- **Authenticate Git with GitHub credentials?** → Yes
- **How to authenticate?** → Login with a web browser
- Copy the one-time code shown, press Enter
- Paste the code in the browser window that opens
- Click Authorize

**Verify it worked:**
```bash
gh auth status
```
You should see: `Logged in to github.com`

---

## Step 7 — Install Supabase CLI

The Supabase CLI lets the spinup script create and manage databases
automatically.

```bash
brew install supabase/tap/supabase
```

Then log in to Supabase:
```bash
supabase login
```

This opens a browser window. Log in to your Supabase account and
click Authorize.

**Verify it worked:**
```bash
supabase projects list
```
You should see a list of projects (or an empty list — both are fine).

---

## Step 8 — Install Vercel CLI

The Vercel CLI lets the spinup script create and deploy projects
automatically.

```bash
npm install -g vercel
```

Then log in to Vercel:
```bash
vercel login
```

Follow the prompts and log in with your email or GitHub account.

**Verify it worked:**
```bash
vercel whoami
```
You should see your Vercel username.

---

## Step 9 — Install jq

jq processes JSON data. The spinup script uses it internally.

```bash
brew install jq
```

**Verify it worked:**
```bash
jq --version
```
You should see `jq-1.x`

---

## Step 10 — Install PostgreSQL tools

The teardown script uses `pg_dump` to export database backups
before removing a project.

```bash
brew install postgresql
```

**Verify it worked:**
```bash
pg_dump --version
```
You should see a version number.

---

## Step 11 — Set up your environment variables

Environment variables are settings stored on your machine that
scripts use automatically. You set them once and they work
across every project forever.

They live in a file called `.zshrc` which Terminal reads every
time it opens.

### Open your shell profile in VS Code

```bash
code ~/.zshrc
```

If VS Code says "command not found", open VS Code manually,
press **Command + Shift + P**, type `shell command`, and click
**Shell Command: Install 'code' command in PATH**. Then try again.

### Add these lines at the bottom of the file

Copy and paste all of these:

```bash
# Friends Innovation Lab
export VERCEL_TOKEN=
export VERCEL_ORG_ID=
export GITHUB_ORG=friends-innovation-lab
export SUPABASE_ORG_ID=
export SUPABASE_ACCESS_TOKEN=
export LABS_DOMAIN=labs.cityfriends.tech

# Shared services — used across all projects
export RESEND_API_KEY=
export UPSTASH_REDIS_REST_URL=
export UPSTASH_REDIS_REST_TOKEN=
```

Now fill in the blank values using the steps below.

---

### VERCEL_TOKEN

This lets the spinup script create Vercel projects on your behalf.

1. Go to **vercel.com** and log in
2. Click your **profile picture** in the top right corner
3. Click **Account Settings**
4. In the left sidebar click **Tokens**
5. Click **Create Token**
6. Name: `fftc-lab`
7. Scope: **Friends Innovation Lab**
8. Expiration: **1 year**
9. Click **Create**
10. **Copy the token immediately** — Vercel only shows it once
11. Paste it after `VERCEL_TOKEN=` in your `.zshrc`

---

### VERCEL_ORG_ID

This tells the script which Vercel team to create projects under.

1. Stay on vercel.com → Account Settings
2. Click **General** in the left sidebar
3. Scroll down to find the field labeled **Team ID**
4. Copy that value
5. Paste it after `VERCEL_ORG_ID=` in your `.zshrc`

---

### SUPABASE_ACCESS_TOKEN

This lets the spinup script create Supabase projects on your behalf.

1. Go to **supabase.com** and log in
2. Click your **profile picture** in the top right corner
3. Click **Account**
4. In the left sidebar click **Access Tokens**
5. Click **Generate new token**
6. Name: `fftc-lab`
7. Click **Generate**
8. **Copy the token immediately** — Supabase only shows it once
9. Paste it after `SUPABASE_ACCESS_TOKEN=` in your `.zshrc`

---

### SUPABASE_ORG_ID

This tells the script which Supabase organization to create
projects under.

1. Stay on supabase.com
2. In the left sidebar click your **organization name**
3. Click **Settings**
4. Click **General**
5. Find the field labeled **Organization ID**
6. Copy that value
7. Paste it after `SUPABASE_ORG_ID=` in your `.zshrc`

---

### RESEND_API_KEY

Resend sends transactional emails. One key works across all projects.
Ask Lapedra for access to the Resend account first.

1. Go to **resend.com** and log in
2. Click **API Keys** in the left sidebar
3. Click **Create API Key**
4. Name: `fftc-lab`
5. Click **Add**
6. Copy the key immediately
7. Paste it after `RESEND_API_KEY=` in your `.zshrc`

---

### Upstash credentials

Upstash handles rate limiting. One database works across all projects.
Ask Lapedra for access to the Upstash account first.

1. Go to **upstash.com** and log in
2. Click your Redis database
3. Click the **REST API** tab
4. Copy the value next to **UPSTASH_REDIS_REST_URL**
5. Copy the value next to **UPSTASH_REDIS_REST_TOKEN**
6. Paste each after the matching variable in your `.zshrc`

---

### Save and reload

Save the file in VS Code with **Command + S**, then reload Terminal:

```bash
source ~/.zshrc
```

**Verify it worked:**
```bash
echo $VERCEL_TOKEN
echo $SUPABASE_ACCESS_TOKEN
```
Each should print its value — not blank.

---

## Step 12 — Create a projects folder

Keep all lab projects in one place.

```bash
mkdir ~/projects
```

This creates a `projects` folder in your home directory.
Every project you spin up will live here.

---

## Step 13 — Clone the playbook

The playbook is the lab's operational manual. You need a local copy
so the spinup and teardown scripts are available on your machine.

Cloning means downloading a copy of the repo so you can use it
and run scripts from it locally.

```bash
cd ~/projects
git clone https://github.com/friends-innovation-lab/playbook.git
```

Open it in VS Code:
```bash
cd playbook
code .
```

---

## Step 14 — Run the pre-flight checks

This confirms your machine is set up correctly.

```bash
bash ~/projects/playbook/operations/automation/spinup.sh
```

All checks should show a green ✓. If any show ✗, the script will
tell you exactly what to fix. Fix it and run the script again.

You do not need to complete a full spinup right now — just confirm
all the checks pass and then press Control + C to exit.

---

## Step 15 — Get added to team accounts

Ask Lapedra to add you to:

- GitHub org: `friends-innovation-lab`
- Vercel team: `friends-innovation-lab`
- Supabase org
- Figma org (if you are doing design work)
- Sentry org: `friends-innovation-lab`

Send her your GitHub username and the email you use for each service.

---

## Daily Git commands

You will use these every day on projects.
Run them from inside your project folder.

**Check what has changed:**
```bash
git status
```

**Stage your changes:**
```bash
git add .
```

**Save your changes with a message:**
```bash
git commit -m "describe what you changed"
```
Keep messages short and descriptive.
Examples: `"add login form"` or `"fix mobile layout on dashboard"`

**Push to GitHub:**
```bash
git push
```
This sends your commits to GitHub and triggers a Vercel deployment.

**Pull the latest changes from the team:**
```bash
git pull
```
Run this at the start of every work session.

**Switch to a branch:**
```bash
git checkout develop
```
Always work on `develop`, not `main`.
The spinup script sets this up automatically.

**Create a new branch for a feature:**
```bash
git checkout -b feature/your-feature-name
```
Use descriptive names like `feature/login-page` or `fix/mobile-nav`.

---

## You're ready

When all pre-flight checks pass you are set up correctly.

Your next step: read [what we build](what-we-build.md).

If anything goes wrong when you run the spinup script on a real
project, see [troubleshooting.md](troubleshooting.md).
