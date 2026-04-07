# Spinup and Teardown

Two scripts that manage the full lifecycle of a project.

## Spin up a new project

```bash
bash operations/automation/spinup.sh
```

The script will ask you a few questions and handle everything else:
- Creates the GitHub repo from the project template
- Sets up Supabase (if needed) with the baseline schema
- Deploys to Vercel with all environment variables configured
- Assigns a live URL at `[name].labs.cityfriends.tech`
- Creates GitHub issues based on project type
- Generates a project-specific `CLAUDE.md`

See the full script documentation:
→ [operations/automation/README.md](../operations/automation/README.md)

## Tear down a project

```bash
bash operations/automation/teardown.sh
```

Run this when a prototype engagement ends or an internal tool is retired.
The script exports data, archives the repo, removes Vercel and Supabase
projects, and creates a teardown record.

## Before you run either script

Make sure your machine is set up correctly:
→ [First-time setup](../01-getting-started/first-time-setup.md)
