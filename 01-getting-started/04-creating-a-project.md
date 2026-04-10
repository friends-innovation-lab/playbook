# Creating a Project

Run this when you are ready to start a new project.
Do not run this as part of first-time setup — only run it when
you have a real project to spin up.

---

> [!IMPORTANT]
> Spinup credentials are set up by Lapedra when you join the lab
> as a developer or project lead. If your role does not require
> spinning up new projects — for example if you are joining an
> existing project as a researcher or designer — you will not
> need these credentials and can skip this doc entirely.
> Ask Lapedra which sections apply to your role.

## The build loop

Every project follows this loop:

```
Brief arrives
↓
Discuss + extract requirements
↓
CC designs screens in Figma using starter prompt + design system
↓
You review and iterate in Figma until decisions are made
↓
Spinup script → infrastructure created
↓
CC builds from Figma designs → working prototype
↓
Polish + accessibility
↓
Submit or demo
```

Design comes before spinup because the spinup script creates
real infrastructure — a live database, deployed app, costs
accruing. The Figma design phase is free — CC draws screens,
you change direction, nothing is committed. By the time you
run spinup you know exactly what you're building.

---

## Before you start

Make sure you have completed [first-time-setup.md](01-first-time-setup.md)
and all pre-flight checks pass. If you are not sure, run:
```bash
bash ~/projects/playbook/operations/automation/spinup.sh
```

The script will check everything before doing anything.

---

## Before your first spinup

Before running the spinup script for the first time you need two
shared credentials added to your shell profile. These are managed
by Lapedra and shared across all lab projects — you only set them
once and every project uses them automatically.

Ask Lapedra for:
- `RESEND_API_KEY` — used for transactional emails
- `UPSTASH_REDIS_REST_URL` — used for rate limiting
- `UPSTASH_REDIS_REST_TOKEN` — used for rate limiting

Once she gives you the values, open your shell profile:
```bash
code ~/.zshrc
```

Add these lines at the bottom:
```bash
# Shared lab services
export RESEND_API_KEY=
export UPSTASH_REDIS_REST_URL=
export UPSTASH_REDIS_REST_TOKEN=
```

Paste each value after the `=` sign, save the file, then reload:
```bash
source ~/.zshrc
```

> [!IMPORTANT]
> Do this before running the spinup script for the first time.
> The script will automatically inject these into every project
> you create from that point forward.

---

## If you are a builder

Builders work directly with CC to design and build prototypes.
If that is your role, you need two additional things set up
before your first project.

### 1. Install the Figma plugin for Claude Code

This lets CC read and write to Figma files directly — designing
screens, creating components, and updating tokens without manual work.

Open the terminal in VS Code (View → Terminal) and run:
```bash
claude plugin install figma@claude-plugins-official
```

Follow the prompts to authenticate with your Figma account.

> [!IMPORTANT]
> Make sure you are logged into the correct Figma account before
> clicking Allow — the one connected to the Innovation Lab org.
> Ask Lapedra to confirm which account to use.

**Verify it worked:**
Type `claude` in the terminal to open CC, then type `/mcp` and
look for `figma` in the installed list.

> [!TIP]
> Having trouble? See [Figma MCP not connecting](06-troubleshooting.md#figma-mcp-not-connecting)

### 2. Get access to the Innovation Lab Design System in Figma

Ask Lapedra to add you to the Innovation Lab Figma org so you
can access:

- **Tokens file** — design variables (colors, typography, spacing)
- **Components file** — Button, Input, Badge, Card, Avatar
- **Templates file** — page-level designs for each prototype type

You will reference these files when asking CC to build or design
anything. Always paste the Figma file URL into your CC prompt so
it knows which design system to use.

The three files:
- Tokens: https://www.figma.com/design/MgWiTmboj3YSTUK8xRKzRt/Tokens
- Components: https://www.figma.com/design/zZFKdl9JDitNfnZkTGJYKR/Components
- Templates: https://www.figma.com/design/vqKtu40TwBNNUYnPH87PvB/Templates

---

## Spinning up a project

Make sure you are in your projects folder first:
```bash
cd ~/projects
```

> [!WARNING]
> Do not run the spinup script from inside the playbook folder
> or any other project folder. Always run it from `~/projects`

Then run:
```bash
bash ~/projects/playbook/operations/automation/spinup.sh
```

The script will ask you a few questions and handle everything else.
It takes under 10 minutes. When it finishes you will have:

- A GitHub repo under `friends-innovation-lab`
- A live URL at `[name].labs.cityfriends.tech`
- A Supabase database (if selected)
- A Vercel deployment
- A local project folder with everything configured

For full details on what the script does:
→ [operations/automation/README.md](../operations/automation/README.md)

> [!NOTE]
> Run this once after spinup to install the accessibility test browser:
> ```bash
> npx playwright install chromium
> ```

---

## Daily Git commands

Use these every day when working on a project.
Run them from inside your project folder in the VS Code terminal.

To open the terminal inside VS Code: click **View** in the top
menu then click **Terminal**.

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

**Switch to the develop branch:**
```bash
git checkout develop
```

> [!IMPORTANT]
> Always work on the `develop` branch, not `main`.
> The spinup script sets this up automatically.

**Create a new branch for a feature:**
```bash
git checkout -b feature/your-feature-name
```
Use descriptive names like `feature/login-page` or `fix/mobile-nav`.

---

## Working with CC

Once your project is open in VS Code, here is how to work with CC.

**Open CC:**
Click the **Claude icon** in the left sidebar.

**Start every session the same way:**
Before asking CC to build anything, always orient it to the project first:
Read CLAUDE.md first, then tell me what you understand
about this project before we start.

This makes CC read the project context — the stack, standards,
and current focus — before writing any code. Without this step
CC may make incorrect assumptions.

**Keep CLAUDE.md updated:**
The `## Current Focus` section at the bottom of CLAUDE.md is
the most important part. Update it every time priorities change.
A stale CLAUDE.md means CC works with wrong assumptions.

**Starter prompts:**
For new features use the starter prompts in the playbook to get
50% of the way there fast:
→ [03-building/prompts/](../03-building/prompts/README.md)

> [!TIP]
> Having trouble with CC? See [Claude Code not connecting](06-troubleshooting.md#claude-code-not-connecting)

---

## Something not working after spinup?

→ [Troubleshooting](06-troubleshooting.md)
