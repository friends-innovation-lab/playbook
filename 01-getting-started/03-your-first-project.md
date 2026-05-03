# Your First Project

This is your test run. You're going to spin up a real project, change three things in it with Claude Code, see those changes go live on the internet, and tear the whole thing down. No stakes. Just practice.

By the end, you'll have done the full lab loop once. The next time a real project lands, the steps will already be in your hands.

**Time:** about 45 minutes from start to finish.

> [!NOTE]
> For real projects, there's an additional planning step using Claude.ai as a project orchestrator — especially helpful for non-developers. That's covered in [`01-creating-a-project.md`](../02-running-a-project/01-creating-a-project.md). For this test project, we're keeping it simple and going direct so you can feel each piece of the loop work.

**Jump to:** [Spin up](#step-1--spin-up-the-project) · [Look around](#step-2--look-around-and-pull-the-code-locally) · [Supabase](#step-3--set-up-your-supabase-credentials) · [Make changes](#step-4--make-changes-with-cc) · [Pull request](#step-5--open-a-pull-request) · [See it live](#step-6--see-it-live) · [Tear down](#step-7--tear-it-down) · [Debrief](#debrief)

---

## A few things before you start

**Open VS Code.** Then open the built-in terminal: **View → Terminal** (or press `` Ctrl+` `` — that's the backtick key, just below the Escape key on most Macs). The terminal will appear at the bottom of the VS Code window. Every command in this doc gets typed into that terminal.

**Terminal cursor behavior.** You can't click in the middle of a line and move your cursor there. The terminal cursor stays at the end. To fix typos, use the left and right arrow keys. To delete, use backspace. This catches everyone the first time.

**Copy and paste is your friend.** Every command in this doc is in a code block with a copy button at the right edge. Click the button to copy the whole command, then paste it into the terminal. Copying is more reliable than typing — fewer mistakes.

**Where projects live on your computer.** All your lab projects live in a folder called `~/Projects/` on your Mac. The `~` is shorthand for your home folder. The lab playbook itself lives at `~/Projects/playbook/`. When you spin up a new project, you'll clone it into the same `~/Projects/` folder so you can find it easily.

**Why your project needs to be local.** When you make changes with Claude Code, CC reads the actual files on your computer. The site you see live on the internet is built from those files after you push them to GitHub. Local is where you change things; live is what the world sees.

OK. Let's go.

---

## Step 1 — Spin up the project

In your VS Code terminal, navigate to the playbook folder:

```bash
cd ~/Projects/playbook
```

Now run the spinup script. Copy the entire command below and paste it into the terminal:

```bash
./automation/spinup-typed.sh --type prototype --name=test-one
```

Press enter. The script will start running automatically — it doesn't ask any questions. It just goes.

**What happens first.** The script prints a banner showing what it's about to do — your project name, type, the extensions being applied (none for a prototype), the GitHub repo it'll create, the URL it'll deploy to. Read it. If anything looks wrong, press `Ctrl+C` to cancel before it starts.

**Pre-flight checks.** Next, the script verifies that all the tools and credentials it needs are in place — GitHub authentication, Vercel CLI, Supabase CLI, and your Supabase org ID. You'll see a list of green checkmarks scroll by.

> [!IMPORTANT]
> If any pre-flight check fails, the script will stop with a clear error message telling you what's missing. Read the message — it usually tells you exactly what to fix (a missing env var, an unauthenticated CLI, etc.). If you're stuck, ask Lapedra. Don't try to push past pre-flight failures.

**Provisioning.** Once pre-flight passes, the script does the real work. This takes 5-10 minutes the first time. You'll see step banners as it progresses through:

1. **GitHub** — Creates a new repository at `github.com/friends-innovation-lab/test-one` from the project-template
2. **Apply extensions** — For a prototype, none. (For other project types, this is where multi-tenancy, audit logging, etc. get added.)
3. **Vercel** — Creates a new Vercel project linked to the GitHub repo, configures environment variables, sets up the custom domain at `test-one.lab.cityfriends.tech`
4. **Supabase** — Creates a new database project in the Friends Lab CI org, retrieves connection details, runs initial migrations
5. **CI secrets** — Adds the credentials GitHub Actions needs for automated checks
6. **Starter issues** — Creates a few starter issues and a project board on GitHub

Don't close the terminal until it finishes. When it does, it'll print a success summary with the URLs you'll need:

- The GitHub repo URL
- The Vercel project URL
- The Supabase project URL
- The live site URL

Copy those four links somewhere you can find them — a sticky note, a scratch document, anywhere. You'll use them in the next step.

---

## Step 2 — Look around and pull the code locally

Before changing anything, take three minutes to see what you have.

**Open the live site.** Paste the live URL (the `lab.cityfriends.tech` one) into a browser. You'll see the project-template's default landing page. Generic but functional. This is what's running in production right now — yours, on the internet.

**Open the GitHub repo.** Paste the GitHub URL into a browser. You'll see the codebase, the README, the file structure. Notice the `/docs/standards/` folder — those are the lab standards, copied into your project automatically. You don't need to read them now.

**Open the Vercel dashboard.** Paste the Vercel URL into a browser. You'll see your project listed with a green checkmark indicating the latest deploy succeeded. The dashboard shows every deployment, deploy logs, and environment variables. You won't usually visit Vercel — it just runs in the background — but it's good to know it exists.

**Open the Supabase dashboard.** Paste the Supabase URL into a browser. You'll see your database project. The Tables view shows the database schema (mostly empty for a prototype, but the structure is there). The API view shows the connection details that were already added to your project's environment variables. You'll rarely visit Supabase directly — your application code talks to it — but knowing where to find it matters when something needs debugging.

**Now pull the code to your computer.** Back in your VS Code terminal, run these commands one at a time:

```bash
cd ~/Projects
```

```bash
git clone https://github.com/friends-innovation-lab/test-one.git
```

That second command downloads the project from GitHub onto your computer. You should see download progress, then a message that it finished.

```bash
cd test-one
```

That moves your terminal into the project folder. From here, every command you run will affect this project specifically.

```bash
code .
```

That last command opens this project in a new VS Code window. The dot means "the current folder." You'll now have two VS Code windows — the playbook one, and the test-one project one. Work in the test-one window for the rest of this doc.

> [!TIP]
> If `code .` gives you an error about command not found, you need to install VS Code's command-line shortcut. In any VS Code window: open the command palette (`Cmd+Shift+P`), type "shell command," and click "Install 'code' command in PATH." Then close VS Code and try again.

---

## Step 3 — Set up your Supabase credentials

Before you can run the project locally, you need to add your Supabase project credentials to a local environment file. The spinup script created a Supabase project for you but didn't populate the credentials into your project — you'll do that now.

> [!NOTE]
> This manual step will go away in a future update to the spinup script. For now, do it once per new project.

**Get your Supabase credentials.**

1. Go to [supabase.com/dashboard](https://supabase.com/dashboard) and sign in.
2. Click on the project that matches your test project name (e.g., `test-one`).
3. In the left sidebar, click the gear icon for **Project Settings**.
4. Click **API** in the settings menu.
5. You'll see your **Project URL** and several API keys. You need two values:
   - **Project URL** (looks like `https://xxxxxxxxxxxx.supabase.co`)
   - **`anon` `public` key** (a long string starting with `eyJ...`)

Keep this browser tab open — you'll copy these values in the next step.

**Create your local environment file.**

In your VS Code terminal (View → Terminal):

```bash
cp .env.example .env.local
```

This copies the template environment file to a local version. The `.env.local` file is gitignored, so your credentials never get committed.

**Add your Supabase values.**

Open `.env.local` in VS Code (it should appear in the file explorer on the left).

Find these two lines:

```
NEXT_PUBLIC_SUPABASE_URL=your-supabase-project-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
```

Paste your **Project URL** after `NEXT_PUBLIC_SUPABASE_URL=` (replacing `your-supabase-project-url`) and your **anon public key** after `NEXT_PUBLIC_SUPABASE_ANON_KEY=` (replacing `your-supabase-anon-key`). Save the file (Cmd+S).

Now you can run the dev server.

---

## Step 4 — Make changes with CC

Now you'll use Claude Code (CC) to make three changes to the landing page.

**Open CC inside the test-one VS Code window.** Look for the CC icon in the left toolbar — it looks like a sparkle or chat bubble. Click it. A chat panel opens on the right side of VS Code.

**Paste this prompt into CC.** Replace `[your name]` with your actual first name before sending.

```text
Make three changes to the landing page:

1. Change the main headline to "Hello from [your name]"
2. Change the "Get Started" button text to say "I changed this!"
3. Add a short bio section below the headline that says something
   like "Friend at Friends From The City. Building from the
   Treehouse." — feel free to write it in your own voice.

Use the project's existing components and design tokens. Don't
add new dependencies.
```

Press enter to send. CC will read the project files, figure out where the landing page lives, and propose changes. It'll show you a diff (a side-by-side view of what's there now vs. what it wants to change) before applying anything.

Review what CC proposes. If it looks reasonable, accept the changes. If something looks off — wrong file, unexpected modifications — tell CC what to adjust. CC will iterate.

**See your changes locally.** Once changes are applied, you need to start the local development server to see them. Back in the VS Code terminal (the one inside the test-one window):

```bash
npm install
```

This pulls down the project's dependencies. Takes about 30 seconds the first time. You'll see a lot of text scroll by — that's normal.

```bash
npm run dev
```

This starts the local development server. After a few seconds, you'll see a message that says something like "ready in 1.2s" with a URL: `http://localhost:3000`. Open that URL in a browser.

You should see your changes — your name in the headline, the "I changed this!" button, the new bio section.

> [!IMPORTANT]
> What you're looking at right now is local development. Only you can see it. The deployed site (the `lab.cityfriends.tech` URL from Step 1) hasn't been updated yet. That happens when you push the changes to GitHub.

If something looks broken or not quite right, ask CC to fix it. This is the iteration loop — change, see, adjust, see again. Take a few minutes here. Try changing the bio text. Try a different button color. Get a feel for what CC will do.

When you're happy with how it looks, stop the dev server: click in the terminal where it's running and press `Ctrl+C`.

---

## Step 5 — Open a pull request

> [!IMPORTANT]
> Run all the git commands in this step in your terminal — either Mac Terminal or VS Code's integrated terminal (View → Terminal). Don't paste git commands into Claude Code's chat panel; CC will describe what the commands do but won't execute them, which means your changes won't actually get committed or pushed.

Now you'll get the changes into the deployed site. The path is: branch → stage → commit → push → PR → CI → merge. Each of those is a small step. We'll do them one at a time.

**Switch to develop and create a feature branch.** The spinup script set up your project with two branches: `main` (protected, production-ready) and `develop` (where active work happens). For real projects, you always work on a feature branch off develop, never directly on main or develop. The test project follows the same pattern so you learn it once.

First, switch to develop:

```bash
git checkout develop
```

Then create a feature branch off develop:

```bash
git checkout -b feature/first-project-changes
```

That command creates a new branch called `feature/first-project-changes` and switches to it. Anything you commit from now on goes onto this branch, not onto develop or main.

**Stage.** Staging means telling git which files you want to include in your next commit. CC has changed several files; you want all of them in the commit. Stage them all:

```bash
git add .
```

The dot means "everything in this folder." git now knows what you're committing.

**Commit.** A commit is a snapshot of your changes with a message describing what you did. Commit your staged changes:

```bash
git commit -m "Personalize landing page for first project test"
```

The `-m` flag attaches a message. You'll see a confirmation that the commit was created.

**Push.** Pushing sends your local commit up to GitHub.

```bash
git push -u origin feature/first-project-changes
```

The `-u origin feature/first-project-changes` part tells git "push this branch to GitHub for the first time." Future pushes from this branch can just use `git push`.

**Open the pull request.** A pull request (PR) is how you propose merging your branch into another branch. For lab projects, feature branches always merge into develop (not directly into main). From the terminal:

```bash
gh pr create --base develop --title "First project test changes" --body "Personalizing the landing page as part of my first project walkthrough."
```

The `--base develop` part tells git the PR target is develop. For real projects, getting changes from develop into main happens later as a separate release step (covered in `02-running-a-project/01-creating-a-project.md`). For this test, merging to develop is enough.

The command will print a URL when it finishes. Open that URL in a browser. You're now looking at GitHub's pull request view.

**Watch the CI checks run.** Below your PR description you'll see a section called "Checks" with a spinning indicator. The lab runs eight or more automated checks on every PR — lint, type check, unit tests, build, accessibility, security scan, dependency scan, license check.

These take about 2-3 minutes total. Wait for them to finish.

> [!NOTE]
> Green checkmarks mean the checks passed and your PR is safe to merge. A red X means a check failed — click it to see what broke. For a small change like this, all checks should pass on the first try.

**Merge the PR.** When all checks are green, merge it. Two ways:

- **The easy way:** scroll down on the PR page and click the green "Merge pull request" button. Then click "Confirm merge."
- **The terminal way:** run `gh pr merge --merge --admin`

Either works. The `--admin` flag bypasses the branch protection requirement for code review (you don't have a reviewer for a test PR). On real projects, you'd ask a teammate to review first, then merge without `--admin`.

---

## Step 6 — See it live

> [!NOTE]
> When your project first deploys, Vercel may briefly show "Production Domain is not serving traffic." This is expected — Vercel is waiting for the CI checks to complete before serving the URL. Wait a few minutes and refresh; the URL will work.

Two things happen when your PR is created and then merged.

**While the PR is open, Vercel creates a preview deployment.** Every PR gets its own preview URL — separate from production, accessible to anyone with the link. Open the Vercel dashboard URL from Step 1. You'll see the preview deployment in progress, and once it finishes, the preview URL appears in the PR comments and on the Vercel dashboard. Click that URL — your changes are visible there.

**Once you merge the PR to develop**, Vercel deploys the develop branch to its own URL. For real projects, this is the staging URL where you can verify changes are integrated correctly before releasing to production.

For this test project, seeing your changes on the preview URL (or the develop deployment after merge) is enough to confirm the loop worked. The production URL at `https://test-one.lab.cityfriends.tech` would only update if you did a separate release from develop to main — which we won't do for the test.

This is the moment. From running one script to seeing your code live on a real preview URL: you just did the full Treehouse loop.

---

## Step 7 — Tear it down

A test project shouldn't keep running indefinitely. The teardown script removes everything you just created — GitHub repo, Vercel project, Supabase project, domain configuration. Clean slate.

In your VS Code terminal, head back to the playbook folder:

```bash
cd ~/Projects/playbook
```

Then run teardown:

```bash
./automation/teardown.sh --name=test-one
```

The script will list everything it's about to delete and ask you to confirm. Read the list, type `y`, and press enter.

> [!WARNING]
> Teardown is permanent. The GitHub repo and Supabase database get deleted, not archived. For real projects, only run teardown when you're sure the work is done and any data you wanted to keep has been exported. For this test project, you can teardown without worry — there's nothing to save.

Teardown takes about 2 minutes. When it finishes, the live URL will return a 404 (page not found), the GitHub repo will be gone, and Vercel will no longer list the project.

You can also delete your local copy:

```bash
cd ~/Projects
```

```bash
rm -rf test-one
```

That's it. The project is gone, and you've completed the full loop.

---

## Debrief

Look at what you did:

1. Spun up a real project with one command
2. Saw it live on the internet
3. Pulled the code to your computer and opened it in VS Code
4. Used Claude Code to make three changes at once
5. Saw the changes locally before pushing
6. Created a branch, staged changes, committed, pushed, and opened a pull request
7. Watched eight CI checks run on your code
8. Merged the PR
9. Saw the changes deploy automatically to the live site
10. Tore everything down

Whatever felt slow, confusing, or surprising — write it down. The team will meet up after your test project to talk about what worked and what didn't. The lab gets better from those conversations.

When a real project lands, this will all feel familiar. You won't be learning the tools at the same time as you're trying to build something. You'll already know the loop.

---

## What's next

You've finished the test. You're ready for real work.

When a real project comes, the detailed how-to is at [`01-creating-a-project.md`](../02-running-a-project/01-creating-a-project.md). That doc covers real-project work — including the orchestrated workflow with Claude.ai for project planning, PRDs, and ongoing operational guidance. The spin-up, build, and deploy steps are the same as what you just did.

Welcome to the Treehouse. For real this time.
