# First-Time Setup

Do this once when you join the lab. Takes about 45 minutes.
Follow every step in order — do not skip anything.

When you are done, every pre-flight check in the spinup script
will pass and you will be ready to start your first project.

> [!NOTE]
> **All commands in this guide are run in Terminal.**
> If you closed Terminal, reopen it before continuing.
> Press **Command + Space**, type `Terminal`, press Enter.

---

## Step 1 — Download and install VS Code

VS Code is the code editor the entire lab uses. You write and view
code inside it, and it connects to all the tools below.

1. Go to **[code.visualstudio.com](https://code.visualstudio.com)**
2. Click the big white button that says **Download for macOS**
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

Run this in Terminal:

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

> [!TIP]
> Having trouble? See [Homebrew installation issues](troubleshooting.md#homebrew-not-found-after-installation)

---

## Step 4 — Install Git

Git tracks changes to code and lets the team share work.
Every project uses it.

Run this in Terminal:

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

> [!IMPORTANT]
> You must close Terminal completely and reopen it after installing
> Node.js. The `node` command will not work until you do.

**Verify it worked:**
```bash
node --version
```
You should see `v20.x.x` or higher.

---

## Step 6 — Install GitHub CLI

The GitHub CLI lets the spinup script create and manage GitHub repos
automatically on your behalf.

Run this in Terminal:

```bash
brew install gh
```

Then log in to GitHub:

Run this in Terminal:

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

Run this in Terminal:

```bash
brew install supabase/tap/supabase
```

Then log in to Supabase:

Run this in Terminal:

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

Run this in Terminal:

```bash
npm install -g vercel
```

If you see a permissions error, run it with sudo instead:

Run this in Terminal:

```bash
sudo npm install -g vercel
```

Then log in to Vercel:

Run this in Terminal:

```bash
vercel login
```

Follow the prompts and log in with your email or GitHub account.

**Verify it worked:**
```bash
vercel whoami
```
You should see your Vercel username.

> [!TIP]
> Having trouble? See [Vercel CLI permissions error](troubleshooting.md#vercel-cli-install-fails-with-permissions-error)

---

## Step 9 — Install jq

jq processes JSON data. The spinup script uses it internally.

Run this in Terminal:

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

Run this in Terminal:

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

Run this in Terminal:

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
```

Now fill in the blank values using the steps below.

---

### VERCEL_TOKEN

This lets the spinup script create Vercel projects on your behalf.

1. Go to **vercel.com** and log in
2. In the search bar at the top of the page type **Tokens**
3. Click **Tokens** when it appears in the results
4. Click **Create Token**
5. Name: `fftc-lab`
6. Scope: **Friends Innovation Lab**
7. Expiration: **1 year**
8. Click **Create**
9. **Copy the token immediately** — Vercel only shows it once
10. Paste it after `VERCEL_TOKEN=` in your `.zshrc`

> [!IMPORTANT]
> Copy the token immediately. Vercel only shows it once — if you
> close the page without copying, you will need to create a new token.

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

> [!IMPORTANT]
> Copy the token immediately. Supabase only shows it once — if you
> close the page without copying, you will need to generate a new token.

---

### SUPABASE_ORG_ID

This tells the script which Supabase organization to create projects under.

1. Go to **supabase.com** and log in
2. In the left sidebar click your **organization name**
3. Click **Settings**
4. Click **General**
5. Find the field labeled **Organization ID** or **Slug** —
   these are the same value, just labeled differently depending
   on your Supabase version
6. Copy that value
7. Paste it after `SUPABASE_ORG_ID=` in your `.zshrc`

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

> [!TIP]
> Having trouble? See [Environment variable shows blank](troubleshooting.md#pre-flight-checks-fail-after-setup)

---

## Step 12 — Create a projects folder

Keep all lab projects in one place.

Run this in Terminal to create the folder:

```bash
mkdir ~/projects
```

This creates a folder called `projects` in your home directory.
You only need to do this once.

---

## Step 13 — Clone the playbook

The playbook is the lab's operational manual. You need a local copy
so the spinup and teardown scripts are available on your machine.

Cloning means downloading a copy of the repo so you can use it
and run scripts from it locally.

> [!WARNING]
> **Before cloning, make sure you are in your projects
> folder, not inside another project or the playbook folder.**
> Run this first to confirm where you are:
> ```bash
> pwd
> ```
> You should see `/Users/[yourname]/projects`
> If you see anything else, run:
> ```bash
> cd ~/projects
> ```
> Then continue with the steps below.

Run this in Terminal:

```bash
cd ~/projects
git clone https://github.com/friends-innovation-lab/playbook.git
```

Open it in VS Code:

Run this in Terminal:

```bash
cd playbook
code .
```

---

## Step 14 — Get added to team accounts

Ask Lapedra to add you to:

- GitHub org: `friends-innovation-lab`
- Vercel team: `friends-innovation-lab`
- Supabase org
- Figma org (if you are doing design work)
- Sentry org: `friends-innovation-lab`

Send her your GitHub username and the email you use for each service.

---

## Step 15 — Install Claude Code in VS Code

Claude Code (CC) is the AI assistant the lab uses to build projects.
It works directly inside VS Code with full access to your project files.

**Install the Claude Code extension:**
1. Open VS Code
2. Click the **Extensions** icon in the left sidebar —
   it looks like four small squares stacked together
3. A search bar appears at the top of the Extensions panel
4. Type `Claude Code` in the search bar
5. Look for the extension named **Claude Code** published by **Anthropic**
6. Click the blue **Install** button next to it
7. Wait for it to finish installing

**Connect to your Anthropic account:**
1. After installing, look at the left sidebar in VS Code —
   you will see a new icon that looks like the Claude logo
   (a small diamond/sparkle shape)
2. Click that icon
3. A panel opens on the left side of VS Code
4. Click **Sign in to Claude**
5. A browser window opens automatically
6. Log in with your Anthropic account email and password
7. Click **Authorize** when prompted
8. Switch back to VS Code — you should now see Claude Code
   is connected and ready

**Verify it worked:**
You should see your account email or name at the top of the
Claude Code panel in VS Code. If you see a sign-in button
it means the connection did not complete — try step 4 again.

**How to use CC on a project:**
1. Open your project folder in VS Code
2. Click the Claude icon in the left sidebar
3. Type your request in the chat panel
4. Always start by telling CC to read the project context:
   `Read CLAUDE.md first, then tell me what you understand
   about this project before we start.`

> [!TIP]
> Having trouble? See [Claude Code not connecting](troubleshooting.md#claude-code-not-connecting)

---

## You're ready

When all the steps above are complete your machine is set up correctly.
You will not need to do any of this again.

**What's next depends on what you need to do:**

→ Starting a new project? See [Creating a project](creating-a-project.md)
→ Wrapping up a project? See [Ending a project](ending-a-project.md)
→ Something not working? See [Troubleshooting](troubleshooting.md)
