# CI/CD Pipeline

*How we automate testing and deployment at Friends Innovation Lab.*

---

## Overview

Our CI/CD pipeline:

1. **On every push:** Lint, typecheck, test
2. **On PR:** All checks + Vercel preview deploy
3. **On merge to main:** All checks + production deploy

```
Push → Lint → Types → Test → Build → Deploy
```

---

## GitHub Actions Workflows

### Main CI Workflow

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, staging]
  pull_request:
    branches: [main, staging]

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run ESLint
        run: npm run lint

      - name: Check formatting
        run: npm run format:check

  typecheck:
    name: Type Check
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run TypeScript
        run: npm run typecheck

  test:
    name: Unit Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm run test:run

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        if: always()
        with:
          token: ${{ secrets.CODECOV_TOKEN }}

  build:
    name: Build
    runs-on: ubuntu-latest
    needs: [lint, typecheck, test]
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build
        env:
          NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.NEXT_PUBLIC_SUPABASE_URL }}
          NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.NEXT_PUBLIC_SUPABASE_ANON_KEY }}
```

### E2E Tests (Optional)

```yaml
# .github/workflows/e2e.yml
name: E2E Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  e2e:
    name: Playwright
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright browsers
        run: npx playwright install --with-deps

      - name: Run E2E tests
        run: npm run test:e2e
        env:
          BASE_URL: http://localhost:3000
          NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.NEXT_PUBLIC_SUPABASE_URL }}
          NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.NEXT_PUBLIC_SUPABASE_ANON_KEY }}

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 7
```

### Database Migrations (If Needed)

```yaml
# .github/workflows/migrate.yml
name: Database Migration

on:
  push:
    branches: [main]
    paths:
      - 'supabase/migrations/**'

jobs:
  migrate:
    name: Run Migrations
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: supabase/setup-cli@v1
        with:
          version: latest

      - name: Link Supabase project
        run: supabase link --project-ref ${{ secrets.SUPABASE_PROJECT_REF }}
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}

      - name: Run migrations
        run: supabase db push
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
```

---

## Vercel Deployment

Vercel handles deployments automatically via GitHub integration.

### Setup

1. Connect repo to Vercel
2. Vercel auto-detects Next.js
3. Configure environment variables
4. Every push deploys automatically

### Deployment Flow

```
PR opened/updated:
  → Vercel builds preview
  → Posts preview URL to PR

Merged to main:
  → Vercel builds production
  → Deploys to production domain
```

### Build Settings

In Vercel → Project → Settings → General:

| Setting | Value |
|---------|-------|
| Framework Preset | Next.js |
| Build Command | `npm run build` |
| Output Directory | `.next` |
| Install Command | `npm ci` |
| Node.js Version | 20.x |

### Environment Variables

Add in Vercel → Settings → Environment Variables:

| Variable | Production | Preview | Development |
|----------|------------|---------|-------------|
| `NEXT_PUBLIC_SUPABASE_URL` | prod | staging | staging |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | prod | staging | staging |
| `SUPABASE_SERVICE_ROLE_KEY` | prod | staging | staging |

---

## Branch Strategy

### Git Flow (Simplified)

```
main ────●────●────●────●────●──→  (production)
          \         /
staging ───●───●───●──→            (pre-release)
            \     /
feature ─────●───●──→              (development)
```

### Branch Rules

| Branch | Deploys To | Protection |
|--------|------------|------------|
| `main` | Production | PR required, checks must pass |
| `staging` | Staging | PR required |
| `feature/*` | Preview | None |

### Workflow

```bash
# Start feature
git checkout -b feature/my-feature
git push -u origin feature/my-feature

# Open PR → Preview deploys
# Get review, tests pass

# Merge to staging for QA
git checkout staging
git merge feature/my-feature
git push

# After QA approval, merge to main
git checkout main
git merge staging
git push
# → Production deploys
```

---

## Required Secrets

### GitHub Repository Secrets

Add in GitHub → Settings → Secrets and variables → Actions:

```
NEXT_PUBLIC_SUPABASE_URL      # For build
NEXT_PUBLIC_SUPABASE_ANON_KEY # For build
SUPABASE_ACCESS_TOKEN         # For migrations (optional)
SUPABASE_PROJECT_REF          # For migrations (optional)
CODECOV_TOKEN                 # For coverage (optional)
```

### How to Add

1. Go to repo → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add name and value
4. Save

---

## Status Checks

### Required Checks for PRs

In GitHub → Settings → Branches → Add rule for `main`:

- [x] Require status checks to pass
  - [x] CI / Lint
  - [x] CI / Type Check
  - [x] CI / Unit Tests
  - [x] CI / Build

### Check Status in PR

```
✓ CI / Lint — Passed
✓ CI / Type Check — Passed
✓ CI / Unit Tests — Passed
✓ CI / Build — Passed
✓ Vercel — Preview deployed
```

All must pass before merge is allowed.

---

## Caching

### npm Cache

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: 20
    cache: 'npm'  # Caches node_modules
```

### Next.js Build Cache

```yaml
- uses: actions/cache@v4
  with:
    path: |
      ~/.npm
      ${{ github.workspace }}/.next/cache
    key: ${{ runner.os }}-nextjs-${{ hashFiles('**/package-lock.json') }}-${{ hashFiles('**/*.js', '**/*.jsx', '**/*.ts', '**/*.tsx') }}
    restore-keys: |
      ${{ runner.os }}-nextjs-${{ hashFiles('**/package-lock.json') }}-
```

### Playwright Browser Cache

```yaml
- name: Cache Playwright browsers
  uses: actions/cache@v4
  with:
    path: ~/.cache/ms-playwright
    key: playwright-${{ runner.os }}-${{ hashFiles('**/package-lock.json') }}
```

---

## Notifications

### Slack Notifications (Optional)

```yaml
# Add to end of CI workflow
- name: Notify Slack on failure
  if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    payload: |
      {
        "text": "❌ CI failed on ${{ github.repository }}",
        "blocks": [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "❌ *CI Failed*\n*Repo:* ${{ github.repository }}\n*Branch:* ${{ github.ref_name }}\n*Commit:* ${{ github.sha }}"
            }
          }
        ]
      }
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

---

## Debugging CI

### View Logs

1. Go to repo → Actions
2. Click failed workflow run
3. Click failed job
4. Expand failed step

### Re-run Failed Jobs

1. Go to failed workflow run
2. Click "Re-run jobs"
3. Select "Re-run failed jobs"

### Run Locally

```bash
# Test what CI will run
npm run lint
npm run typecheck
npm run test:run
npm run build
```

### SSH Debug (Advanced)

```yaml
# Add to workflow for debugging
- name: Debug with SSH
  if: failure()
  uses: mxschmitt/action-tmate@v3
  with:
    limit-access-to-actor: true
```

---

## Quick Reference

### Workflow Files

```
.github/
└── workflows/
    ├── ci.yml        # Main CI (lint, types, test, build)
    ├── e2e.yml       # E2E tests (optional)
    └── migrate.yml   # Database migrations (optional)
```

### Common Fixes

| Issue | Fix |
|-------|-----|
| "npm ci" fails | Check package-lock.json is committed |
| Build fails | Check env vars are set in GitHub secrets |
| Tests fail | Run `npm test` locally first |
| Lint fails | Run `npm run lint:fix` locally |

### Commands

```bash
# Run same checks as CI
npm run lint && npm run typecheck && npm run test:run && npm run build
```

---

*See also: [Environments](environments.md) · [Rollback](rollback.md)*
