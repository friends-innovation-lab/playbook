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

## What gets removed

- **GitHub** — repo is archived (read-only, not deleted)
- **Supabase** — data exported to your Downloads folder, project deleted
- **Vercel** — project and subdomain removed
- **Local folder** — optionally deleted

---

## After teardown

- Check the teardown log saved to `operations/teardown-log/`
- Update Lapedra so she can track active vs. retired projects
- If the project had a Sentry project, archive it at sentry.io
