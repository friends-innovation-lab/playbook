# First-Time Setup

Do this once when you join the lab. Takes about 45 minutes.
Follow every step in order — do not skip anything.

When you are done, every pre-flight check in the spinup script
will pass and you will be ready to start your first project.

> [!NOTE]
> **All commands in this guide are run in Terminal.**
> If you closed Terminal, reopen it before continuing.
> Press **Command + Space**, type `Terminal`, press Enter.

> [!IMPORTANT]
> **Before you start, make sure you have accounts at all of these services and that Lapedra has added you to the relevant Friends Innovation Lab organizations:**
>
> - **GitHub** — account at github.com, added to the `friends-innovation-lab` org
> - **Vercel** — account at vercel.com, added to the Friends Innovation Lab Vercel team
> - **Supabase** — account at supabase.com, added to the Friends Innovation Lab Supabase organization
> - **Figma** — account at figma.com, added to the FFTC Figma team (especially important for designers)
>
> If any of these are missing, message Lapedra before continuing. Without them, you won't be able to retrieve the credentials you need to provision projects or access design files.

---

## Step 1 — Open Terminal

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

## Step 2 — Install Homebrew (2–5 minutes)

Homebrew is a package manager for Mac. It lets you install developer
tools with a single command. Install it first — everything else
depends on it.

Run this in Terminal:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

> [!NOTE]
> macOS may show a security warning when you paste this command into Terminal,
> and it may specifically say the command "could be malware." That's normal
> macOS caution about pasted terminal commands — not an actual threat.
> It is safe to click **Paste Anyway** and proceed.

It will ask for your Mac password. Type it and press Enter.

> [!NOTE]
> Nothing appears as you type your password — no dots, no asterisks, no
> movement at all. This is normal. macOS hides password input in the
> terminal for security. Type your password and press Enter.
The installation takes 2-5 minutes.

After the installation finishes, Homebrew will show a "Next steps" section.

**Note:** If you are on a Mac with Apple Silicon (M1, M2, M3), you must run
the three commands shown below after the installer finishes. If you are on
an older Intel Mac, skip to **Verify it worked**.

> [!IMPORTANT]
> Copy these commands from YOUR terminal, not from this page. After the
> installer finishes, it will print a "Next steps" section with the exact
> commands you need to run — including your real username. Scroll up in
> your terminal to find them and copy each one from there.

The commands look like this:

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
You should see a version number — any recent version of Homebrew (4.x or 5.x) works fine. If you see "command not found," Homebrew didn't install correctly.

> [!TIP]
> Having trouble? See [Homebrew installation issues](../02-running-a-project/03-troubleshooting.md#homebrew-not-found-after-installation)

---

## Step 3 — Install Git

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

Now set your Git identity so your commits are linked to your GitHub account.

> [!IMPORTANT]
> Use the email address that is on your GitHub account.
> Ask Lapedra if you are not sure which email to use.
> This is required before your first commit. You only need to do it once.

Run this in Terminal:

```bash
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

**Verify your git config saved correctly:**

```bash
git config --global user.name
git config --global user.email
```

These should return your name and email. If they return nothing, the previous step didn't save — try the config commands again.

> [!TIP]
> Having trouble? See [Git identity not configured](../02-running-a-project/03-troubleshooting.md#git-commit-fails--user-identity-not-configured)

---

## Step 4 — Install Node.js (1–2 minutes)

Node.js runs JavaScript on your computer. Every project in the lab
requires Node.js version 20 or higher.

Run this in Terminal:

```bash
brew install node
```

This installs the latest LTS version of Node.js. It also installs
`npm`, the package manager you will use to install project dependencies.

**Verify it worked:**
```bash
node --version
```
You should see `v20.0.0` or higher (any version starting with `v20`, `v22`, `v24`, or above is fine). If your version is below v20, you need to update.

---

## Step 5 — Install VS Code and Claude Code (5–10 minutes)

VS Code is the editor you'll use for working on lab projects. Claude Code is the AI coding assistant that runs inside VS Code. Install both now.

### Install VS Code

1. Go to **[code.visualstudio.com](https://code.visualstudio.com)**
2. Click the big white button that says **Download for macOS**
3. Open your Downloads folder and double-click the file that downloaded
4. Drag the VS Code icon into your Applications folder when prompted. If no window appears asking you to drag, that's fine — just double-click VS Code from your Downloads folder to open it. Once it opens, it may offer to move itself to Applications automatically. Click **Move to Applications** if it does.
5. Open VS Code from your Applications folder or Spotlight search

**Verify it worked:** VS Code opens and you see a welcome screen.

### Set up the `code` command in your terminal

VS Code installs the visual editor, but it doesn't automatically add a terminal command for opening files. You need to add this once.

1. Open VS Code (the application)
2. Press `Cmd+Shift+P` to open the Command Palette
3. Type: `Shell Command: Install 'code' command in PATH`
4. Press Enter

> [!NOTE]
> macOS will show a password prompt from "osascript." This is macOS asking
> permission to modify your system PATH so the `code` command works from
> any terminal. Enter your Mac password and proceed.

### Open VS Code's built-in terminal

Now that the `code` command works, open VS Code's built-in terminal:

1. In VS Code, go to **View → Terminal** (or press `` Ctrl+` ``)
2. A terminal panel appears at the bottom of the VS Code window
3. Use this terminal for the rest of the playbook

Now you can open any file from the terminal with `code [filename]`. Verify it works:

```bash
code --version
```

You should see version info. If you see "command not found," go back through the steps above.

### Install Claude Code

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

> [!TIP]
> Having trouble? See [Claude Code not connecting](../02-running-a-project/03-troubleshooting.md#claude-code-not-connecting)

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

A browser window will open automatically. You'll see a GitHub page asking you to authorize the GitHub CLI. Click **Authorize github**. Switch back to Terminal — you should see a confirmation that says "Authentication complete." If the browser window doesn't open automatically, copy the URL Terminal shows and paste it into your browser manually.

**Verify it worked:**
```bash
gh auth status
```
You should see: `Logged in to github.com`

**Add the `delete_repo` scope (lab leads and admins only):**

```bash
gh auth refresh -h github.com -s delete_repo
```

> **Note:** Regular contributors should skip this step. The `delete_repo`
> scope is only needed to manually delete a repository if a spinup fails
> partway through and leaves behind a partially created repo. The regular
> teardown process (`teardown.sh`) uses `gh repo archive`, which does not
> require this scope.

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

This opens a browser window. If you are not already logged in, log in to
your Supabase account. The browser window will then show you a code to copy.
Copy that code, switch back to Terminal, paste it in, and press Enter.
You should see "You are now logged in. Happy coding!"

**Verify it worked:**
```bash
supabase projects list
```
You should see a list of projects (or an empty list — both are fine).

You may see a warning that says "Cannot find project ref. Have you run supabase link?" — ignore it. That warning appears because you're not inside a linked project folder. It does not mean anything is wrong. What matters is that the table of projects appears below it without an "Unauthorized" error. If you see `Unauthorized`, your login didn't complete — run `supabase login` again.

---

## Step 8 — Install Vercel CLI

The Vercel CLI lets the spinup script create and deploy projects
automatically.

**Install the Vercel CLI:**

```bash
npm install -g vercel
```

> [!NOTE]
> npm may print warnings during installation — including BADENGINE warnings
> about unsupported Node versions and deprecation notices. These are normal
> and do not mean the installation failed. As long as the install completes
> and `vercel --version` works, you can ignore them.

If you get a permissions error, use this instead:

```bash
sudo npm install -g vercel
```

You'll be prompted for your Mac password. Type it (the cursor won't move as you type — that's normal) and press Enter.

> [!NOTE]
> After login, Vercel may ask if you want to install the Vercel Plugin for Claude Code. **Answer no** — it's optional and unnecessary for lab work. If a warning appears saying the plugin failed to install, ignore it.

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
> Having trouble? See [Vercel CLI permissions error](../02-running-a-project/03-troubleshooting.md#vercel-cli-install-fails-with-permissions-error)

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
You should see something like `jq-1.7.1`. The exact version doesn't matter — any version works.

---

## Step 10 — Install PostgreSQL tools (1–2 minutes)

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
You should see something like `pg_dump (PostgreSQL) 16.x`. The exact version doesn't matter. Note: Homebrew may print messages about background services and cleanup after this install — you can safely ignore them.

---

## Step 11 — Set up your environment variables (10–15 minutes)

Environment variables are settings stored on your machine that
scripts use automatically. You set them once and they work
across every project forever.

They live in a file called `.zshrc` which Terminal reads every
time it opens.

### Open your shell profile in VS Code

> [!NOTE]
> It doesn't matter which folder you're in when running this command. The `~/` part of the path always points to your home directory, no matter where you are in the file system.

Run this in Terminal:

```bash
code ~/.zshrc
```

### Add the Friends Innovation Lab environment variables

With `~/.zshrc` open in VS Code, scroll to the bottom of the file. The file may already have content from other tools you've installed — don't delete or replace anything that's there. You're adding new lines at the bottom.

Before filling in these values, read the [Security Policy](04-security-policy.md) so you understand how to handle them safely.

Add these lines:

```bash
# Friends Innovation Lab
export VERCEL_TOKEN=
export VERCEL_ORG_ID=
export GITHUB_ORG=friends-innovation-lab
export LAB_SUPABASE_ORG_ID=
export SUPABASE_ACCESS_TOKEN=
```

The blank values (`=` with nothing after) get filled in below. Save the file (Cmd+S in VS Code) but leave it open — you'll come back to add the actual values.

---

### VERCEL_TOKEN

This is a shared team token that lets the spinup script create Vercel projects. Do not generate your own.

> [!NOTE]
> Contact Lapedra to get the VERCEL_TOKEN and SUPABASE_ACCESS_TOKEN values. These are shared team tokens — do not generate your own.

**Paste the token into your shell profile.**

Switch back to VS Code, where `~/.zshrc` should still be open from earlier. Find the line you added that says:

```bash
export VERCEL_TOKEN=
```

Paste the token value after the `=` sign so it looks like:

```bash
export VERCEL_TOKEN=your-actual-token-value-here
```

Save the file (Cmd+S in VS Code).

> [!IMPORTANT]
> Copy the token immediately. Vercel only shows it once — if you
> close the page without copying, you will need to create a new token.

---

### VERCEL_ORG_ID

This tells the script which Vercel team to create projects under.

1. Go to **vercel.com**
2. In the top left, switch to the **Friends Innovation Lab** team using
   the team selector dropdown
3. Go to **Settings** → **General**
4. Scroll down to find the field labeled **Team ID**
5. Copy that value

**Paste into your shell profile.** Switch to VS Code, find `export VERCEL_ORG_ID=`, and paste the Team ID after the `=` sign. Save the file.

---

### SUPABASE_ACCESS_TOKEN

This is a shared team token — do not generate your own.

Contact Lapedra to get the `SUPABASE_ACCESS_TOKEN` value. She will send it to you securely via Rippling RPASS.

Once you have it, switch to VS Code, find `export SUPABASE_ACCESS_TOKEN=`, and paste the value after the `=` sign. Save the file.

**Why it's shared:** The spinup script creates Supabase projects on behalf of the Friends Innovation Lab org. This requires Owner-level access to the org. Rather than making everyone an Owner, we use a single shared service account token that has the right permissions. See [Security Policy](04-security-policy.md) for details on how this token is managed.

---

### LAB_SUPABASE_ORG_ID

This tells the script which Supabase organization to create projects under. The lab uses a single shared org, so the value is the same for everyone:

```
esiwooovlhcuifbbkodk
```

**Paste into your shell profile.** Switch to VS Code, find `export LAB_SUPABASE_ORG_ID=`, and paste the value after the `=` sign so it looks like:

```bash
export LAB_SUPABASE_ORG_ID=esiwooovlhcuifbbkodk
```

Save the file.

> [!TIP]
> You can verify this is correct by running `supabase orgs list` — look for the org named **Friends Innovation Lab** and confirm the ID matches.

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
Each command should print the token value — a long string of random characters. If either prints nothing (a blank line), the variable wasn't saved correctly. Open `~/.zshrc` in VS Code again, check that the value is on the same line as the `export` statement with no spaces around the `=` sign, save, and run `source ~/.zshrc` again.

> [!TIP]
> Having trouble? See [Environment variable shows blank](../02-running-a-project/03-troubleshooting.md#environment-variable-shows-blank)

---

## Step 12 — Create a projects folder

Keep all lab projects in one place.

Run this in Terminal to create the folder:

```bash
mkdir ~/Projects
```

This creates a folder called `Projects` in your home directory.
You only need to do this once.

---

## Step 13 — Clone the playbook

The playbook is the lab's operational manual. You need a local copy
so the spinup and teardown scripts are available on your machine.

Cloning means downloading a copy of the repo so you can use it
and run scripts from it locally.

> [!WARNING]
> **Before cloning, make sure you are in your Projects
> folder, not inside another project or the playbook folder.**
> Run this first to confirm where you are:
> ```bash
> pwd
> ```
> You should see `/Users/[yourname]/Projects`
> If you see anything else, run:
> ```bash
> cd ~/Projects
> ```
> Then continue with the steps below.

Run this in Terminal:

```bash
cd ~/Projects
git clone https://github.com/friends-innovation-lab/playbook.git
```

Now open the playbook in VS Code so you can read it and run scripts from it:

```bash
cd playbook
code .
```

VS Code will open a new window showing the playbook folder in the left sidebar. You should see folders like `01-getting-started`, `02-running-a-project`, and `automation`. If VS Code shows a modal asking "Do you trust the authors of the files in this folder?" — click **Yes, I trust the authors**. If you see an empty window with no files, the clone didn't complete correctly — go back to the `git clone` step and try again.

---

## You're set up

You're ready to use the lab. Next, read the lab orientation to understand how the lab works:

→ [Lab orientation](02-lab-orientation.md)

---

## If a Spinup Fails Partway Through

The script stops immediately when something goes wrong and lists
everything it created before failing. You need to manually delete
those resources before re-running — otherwise the script will fail
again trying to create things that already exist.

### Delete the GitHub repo

```bash
gh repo delete friends-innovation-lab/project-name --yes
```

Replace `project-name` with the slug you used (e.g. `test-one`).

### Delete the local folder

```bash
rm -rf ~/Projects/project-name
```

### Delete the Vercel project (if it was created)

1. Go to vercel.com → Friends Innovation Lab
2. Select the project
3. Settings → Advanced → Delete Project

### Delete the Supabase project (if it was created)

1. Go to supabase.com → Friends Innovation Lab org
2. Select the project
3. Settings → General → Delete Project

Once everything is cleaned up, re-run the spinup script from your
projects folder.

> **Tip:** The script output tells you exactly what was created
> before it failed under "Resources created so far." Only delete
> what's listed there.
