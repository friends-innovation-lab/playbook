# Your First Project

This is your test run. You're going to spin up a real project, change three things in it with Claude Code, see those changes go live on the internet, and tear the whole thing down. No stakes. Just practice.

By the end, you'll have done the full lab loop once. The next time a real project lands, the steps will already be in your hands.

**Time:** about 35 minutes from start to finish.

> [!NOTE]
> For real projects, there's an additional planning step using Claude.ai as a project orchestrator — especially helpful for non-developers. That's covered in [`01-creating-a-project.md`](../02-running-a-project/01-creating-a-project.md). For this test project, we're keeping it simple and going direct so you can feel each piece of the loop work.

**Jump to:** [Spin up](#step-1--spin-up-the-project) · [Look around](#step-2--look-around-and-open-in-vs-code) · [Make changes](#step-3--make-changes-with-cc) · [Pull request](#step-4--open-a-pull-request) · [See it live](#step-5--see-it-live) · [Tear down](#step-6--tear-it-down) · [Debrief](#debrief)

---

## A few things before you start

A few things to know before you start.

**Open VS Code and the terminal**

- Open VS Code, then open the built-in terminal: **View → Terminal** (or press `` Ctrl+` ``)
- The backtick is the key just below Escape on most Macs
- The terminal appears at the bottom of the VS Code window
- Every command in this doc gets typed into that terminal

**Terminal cursor behavior**

- You can't click in the middle of a line and move your cursor there
- The terminal cursor stays at the end
- Use left/right arrow keys to move; backspace to delete
- This catches everyone the first time

**Copy and paste is your friend**

- Every command in this doc is in a code block with a copy button
- Click the button, paste into the terminal — fewer mistakes than typing

**Where projects live on your computer**

- All your lab projects live in `~/Projects/` on your Mac
- The `~` is shorthand for your home folder
- The lab playbook itself lives at `~/Projects/playbook/`
- New projects clone into `~/Projects/` so they're easy to find

**Why your project needs to be local**

- When you make changes with Claude Code, CC reads the actual files on your computer
- The site you see live on the internet is built from those files after you push them to GitHub
- Local is where you change things; live is what the world sees

OK. Let's go.

---

## Step 1 — Spin up the project

In your VS Code terminal, navigate to the playbook folder:

```bash
cd ~/Projects/playbook
```

Now run the spinup script. Copy the entire command below and paste it into the terminal:

```bash
./automation/spinup-typed.sh --type prototype --name test-one
```

Press enter. The script runs automatically — it doesn't ask any questions.

**The script runs in three phases:**

1. **Banner** — Prints what it's about to do: project name, type, extensions being applied, GitHub repo to create, URL to deploy to. Read it. If anything looks wrong, press `Ctrl+C` to cancel.

2. **Pre-flight checks** — Verifies all tools and credentials are in place: GitHub authentication, Vercel CLI, Supabase CLI, Supabase org ID. You'll see green checkmarks scroll by.

3. **Provisioning** — Does the real work. Takes 5-10 minutes the first time. The script walks through:

   1. **GitHub** — Creates a repo at `github.com/friends-innovation-lab/test-one` from the project-template
   2. **Apply extensions** — For a prototype, none. (Other project types add multi-tenancy, audit logging, etc.)
   3. **Vercel** — Creates a Vercel project linked to the GitHub repo, configures env vars, sets up the custom domain
   4. **Supabase** — Creates a database project in the Friends Lab CI org, retrieves connection details, runs initial migrations
   5. **CI secrets** — Adds credentials GitHub Actions needs for automated checks
   6. **Starter issues** — Creates a few starter issues and a project board on GitHub

> [!IMPORTANT]
> If any pre-flight check fails, the script stops with a clear error message. Read it — it usually tells you exactly what to fix (a missing env var, an unauthenticated CLI, etc.). If you're stuck, ask Lapedra. Don't push past pre-flight failures.

Don't close the terminal until it finishes. When it does, it'll print a success summary with the URLs you'll need:

- The GitHub repo URL
- The Vercel project URL
- The Supabase project URL
- The live site URL

Copy those four links somewhere you can find them — a sticky note, a scratch document, anywhere. You'll use them in the next step.

---

## Step 2 — Look around and open in VS Code

Before changing anything, take three minutes to see what you have.

**Open each of these in a new browser tab:**

- **Live site** (the `lab.cityfriends.tech` URL) — The default landing page from the project-template. Generic but functional. This is what's running in production right now — yours, on the internet.

- **GitHub repo** — The codebase, README, and file structure. Notice `/docs/standards/` — those are the lab standards copied into your project automatically. You don't need to read them now.

- **Vercel dashboard** — Your project listed with a green checkmark for the latest deploy. Shows every deployment, deploy logs, and environment variables. You won't usually visit Vercel — it just runs in the background.

- **Supabase dashboard** — Your database project. The Tables view shows the schema (mostly empty for a prototype). The API view shows connection details already wired into your project's env vars. You'll rarely visit Supabase directly.

**Now open the project in VS Code.** The spinup script already cloned the project to your computer at `~/Projects/test-one` and configured the local environment file (`.env.local`) with the Supabase credentials your app needs to run. Open it:

```bash
cd ~/Projects/test-one
```

```bash
code .
```

That last command opens this project in a new VS Code window. The dot means "the current folder." You'll now have two VS Code windows — the playbook one, and the test-one project one. Work in the test-one window for the rest of this doc.

> [!TIP]
> If `code .` gives you an error about command not found, you need to install VS Code's command-line shortcut. In any VS Code window: open the command palette (`Cmd+Shift+P`), type "shell command," and click "Install 'code' command in PATH." Then close VS Code and try again.

---

## Step 3 — Make changes with CC

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

## Step 4 — Open a pull request

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

## Step 5 — See it live

> [!NOTE]
> When your project first deploys, Vercel may briefly show "Production Domain is not serving traffic." This is expected — Vercel is waiting for CI checks to complete before serving the URL. Wait a few minutes and refresh; the URL will work.

Two deployments happen during the PR cycle:

**While the PR is open: preview deployment**

- Vercel creates a preview URL for every pull request
- Separate from production; accessible to anyone with the link
- The preview URL appears automatically in PR comments and on the Vercel dashboard
- Click it — your changes are visible there

**After you merge the PR to develop: develop deployment**

- Vercel deploys the develop branch to its own URL
- For real projects, this is the staging URL where you verify changes are integrated correctly before releasing to production

**Production stays untouched until release**

- The production URL at `https://test-one.lab.cityfriends.tech` only updates when you do a separate release from develop to main
- We won't do that for this test
- Seeing your changes on the preview URL (or the develop deployment after merge) is enough to confirm the loop worked

This is the moment. From running one script to seeing your code live on a real preview URL: you just did the full Treehouse loop.

---

## Step 6 — Tear it down

A test project shouldn't keep running indefinitely. The teardown script removes everything you just created — GitHub repo, Vercel project, Supabase project, domain configuration. Clean slate.

In your VS Code terminal, head back to the playbook folder:

```bash
cd ~/Projects/playbook
```

Then run teardown:

```bash
./automation/teardown.sh --name test-one
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
3. Opened the project in VS Code
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
