# Ending a Project

Run this when a project is finished — after a prototype engagement
ends, a challenge response is submitted, or an internal tool is retired.

> [!CAUTION]
> This script permanently removes infrastructure. Read every prompt
> carefully before confirming. The database will be exported before
> deletion but everything else is irreversible.

---

## Before you run teardown

Confirm with Lapedra that the project is ready to be decommissioned.
Make sure:
- All work is committed and pushed to GitHub
- The client or team has confirmed they no longer need the live URL
- Any data that needs to be preserved has been exported or handed off

---

## Running the teardown script

Make sure you are in your projects folder:
```bash
cd ~/projects
```

Then run:
```bash
bash ~/projects/playbook/automation/teardown.sh
```

The script will ask you which project to remove and what to tear down.
It will export the database before deleting anything.

For full details on what the script does:
→ [automation/README.md](../automation/README.md)

---

## What teardown does

The teardown script removes most project resources but is intentionally conservative with two things.

**The GitHub repo is archived, not deleted.**

Teardown archives the repo rather than deleting it. The repo remains visible in the `friends-innovation-lab` GitHub org with an "archived" tag. This is intentional:

- Archived repos preserve project history (commits, PRs, issues, discussions) for future reference
- They cannot receive new commits, PRs, or issues
- They don't consume active resources or appear in active project lists
- If the project ever needs to be resurrected, the archive can be unarchived

If you specifically need the repo permanently deleted (rare — usually for compliance or client agreement reasons), do that manually through GitHub's repo settings page after teardown completes.

**Local cleanup requires confirmation.**

When teardown finds a local clone of the project on your machine, it asks: "Delete it? This will permanently remove all local files. (y/n)".

- Answer "y" to delete the local folder
- Answer "n" to keep the local folder

Local cleanup is interactive (not automatic) so you don't accidentally lose local work you might still want.

**Summary of what gets removed:**

- **GitHub** — repo is archived (read-only, not deleted)
- **Supabase** — data exported to your Downloads folder, project deleted
- **Vercel** — project and subdomain removed
- **Local folder** — deleted only if you confirm with "y"

---

## After teardown

- Check the teardown log saved to `operations/teardown-log/`
- Update Lapedra so she can track active vs. retired projects
- If the project had a Sentry project, archive it at sentry.io
