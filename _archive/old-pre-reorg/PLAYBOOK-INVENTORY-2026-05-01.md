# Playbook Inventory Report

**Generated:** 2026-05-01
**Purpose:** Read-only inventory for Session B restructure planning
**Audience:** Preparing playbook for FFTC employee self-service launch

---

## Executive Summary

The playbook contains **~70 files** across 10 directories. The core content is strong, but **staleness has crept in** since the introduction of `spinup-typed.sh`. Multiple files still reference the deprecated `spinup.sh` workflow, creating confusion for new employees trying to stand up projects independently.

### Critical Issues

1. **Stale spinup references** — 5+ files reference deprecated `spinup.sh` instead of `spinup-typed.sh`
2. **Missing env var documentation** — `LAB_SUPABASE_ORG_ID` not documented in first-time setup
3. **Content duplication** — First-time setup exists in two locations with different content
4. **Broken navigation** — Several cross-references point to non-existent or moved files
5. **Inconsistent domain** — Mix of `lab.cityfriends.tech` and `labs.cityfriends.tech`

### Strengths

- Strong writing voice in core docs (good models for rewrites)
- Comprehensive starter prompts for all project types
- Review Council in CLAUDE.md is excellent
- Type-aware spinup script is well-documented in `docs/spinup-typed.md`

---

## Inventory by Directory

### Root (`/`)

| File | Lines | Purpose | Currency | Issues |
|------|-------|---------|----------|--------|
| `README.md` | 77 | Main entry point, navigation | CURRENT | References correct files |
| `CLAUDE.md` | 313 | AI assistant instructions, Review Council | CURRENT | Strong writing, good model |

**Writing quality:** Excellent. Clear, direct, scannable.

---

### `01-getting-started/`

| File | Lines | Purpose | Currency | Issues |
|------|-------|---------|----------|--------|
| `README.md` | 20 | Directory index | CURRENT | — |
| `01-first-time-setup.md` | 542 | Onboarding, tool installation | STALE | Missing `LAB_SUPABASE_ORG_ID` env var |
| `02-what-we-build.md` | 78 | Lab mission, project types | CURRENT | — |
| `03-lab-standards-primer.md` | 149 | 9 lab standards overview | CURRENT | — |
| `04-creating-a-project.md` | 270 | Project creation guide | STALE | References `spinup.sh` not `spinup-typed.sh` |
| `05-ending-a-project.md` | 89 | Teardown process | CURRENT | — |
| `06-ai-workflow.md` | 156 | CC workflow basics | CURRENT | Duplicate of `03-building/ai-workflow.md` |

**Critical staleness:** `04-creating-a-project.md` is the primary blocker for employee self-service. It sends users to the wrong script.

**Writing quality:** Strong. `01-first-time-setup.md` is a good voice model.

---

### `02-spinup/`

| File | Lines | Purpose | Currency | Issues |
|------|-------|---------|----------|--------|
| `README.md` | 36 | Spinup/teardown overview | STALE | Only mentions `spinup.sh`, no `spinup-typed.sh` |

**Critical staleness:** This entire directory may be redundant. The authoritative spinup docs are now in `docs/spinup-typed.md`.

---

### `docs/`

| File | Lines | Purpose | Currency | Issues |
|------|-------|---------|----------|--------|
| `spinup-typed.md` | 230 | Type-aware spinup guide | CURRENT | Authoritative, well-written |

**Writing quality:** Excellent. Decision tree, clear tables, troubleshooting. Best example of structured documentation.

---

### `03-building/`

| File | Lines | Purpose | Currency | Issues |
|------|-------|---------|----------|--------|
| `README.md` | 31 | Building index | CURRENT | — |
| `ai-workflow.md` | 156 | CC workflow | CURRENT | Duplicated in `01-getting-started/` |
| `design-system.md` | 198 | Design system overview | CURRENT | — |
| `design-tokens.md` | 115 | Token system docs | CURRENT | — |
| `agency-theming.md` | 189 | Agency token sets | CURRENT | — |
| `storybook.md` | 87 | Storybook usage | CURRENT | — |

**Subdirectory: `prompts/`**

| File | Lines | Purpose | Currency |
|------|-------|---------|----------|
| `README.md` | 89 | Prompt index | CURRENT |
| `01-new-feature.md` | 67 | Feature prompt | CURRENT |
| `02-bug-fix.md` | 54 | Bug fix prompt | CURRENT |
| `03-api-endpoint.md` | 71 | API prompt | CURRENT |
| `04-database-migration.md` | 68 | Migration prompt | CURRENT |
| `05-component-library.md` | 76 | Component prompt | CURRENT |
| `06-form-validation.md` | 62 | Form prompt | CURRENT |
| `07-auth-flow.md` | 73 | Auth prompt | CURRENT |
| `08-data-table.md` | 65 | Table prompt | CURRENT |
| `09-dashboard.md` | 71 | Dashboard prompt | CURRENT |

**Writing quality:** Prompts are well-structured and actionable. Good templates.

---

### `04-delivering/`

| File | Lines | Purpose | Currency | Issues |
|------|-------|---------|----------|--------|
| `README.md` | 24 | Delivering index | CURRENT | — |
| `demo-standards.md` | 187 | Demo preparation | CURRENT | — |
| `submission-checklist.md` | 234 | Submission prep | CURRENT | — |
| `handoff-guide.md` | 156 | Client handoff | CURRENT | — |
| `presentation-templates.md` | 98 | Slide templates | CURRENT | — |

**Writing quality:** Solid. Actionable checklists.

---

### `05-operations/`

| File | Lines | Purpose | Currency | Issues |
|------|-------|---------|----------|--------|
| `README.md` | 28 | Operations index | CURRENT | — |
| `prototype-lifecycle.md` | 178 | Project phases | CURRENT | — |
| `cost-tracking.md` | 134 | Cost management | CURRENT | — |
| `offboarding.md` | 112 | Team offboarding | CURRENT | — |

**Writing quality:** Good. Practical operations content.

---

### `operations/`

| File | Lines | Purpose | Currency | Issues |
|------|-------|---------|----------|--------|
| `README.md` | 469 | Project operations | STALE | Uses old spinup patterns |
| `first-time-setup.md` | 287 | Duplicate setup guide | STALE | Duplicates `01-getting-started/01-first-time-setup.md` |

**Subdirectory: `automation/`**

| File | Lines | Purpose | Currency | Issues |
|------|-------|---------|----------|--------|
| `README.md` | 156 | Script documentation | STALE | Focuses on `spinup.sh` |
| `spinup.sh` | 1075 | Deprecated interactive spinup | DEPRECATED | Should not be primary reference |
| `spinup-typed.sh` | 903 | Type-aware spinup | CURRENT | Recommended script |
| `teardown.sh` | 234 | Project teardown | CURRENT | — |
| `first-time-setup.md` | 189 | Another setup duplicate | STALE | Third copy of setup content |

**Subdirectory: `design/`**

| File | Lines | Purpose | Currency | Issues |
|------|-------|---------|----------|--------|
| `ui-ux-guide.md` | 2427 | Comprehensive UI/UX guide | CURRENT | Very large, may need splitting |

**Critical issue:** Three copies of first-time setup content exist with varying levels of currency.

---

### `development/`

| File | Lines | Purpose | Currency | Issues |
|------|-------|---------|----------|--------|
| `README.md` | 313 | Development standards index | CURRENT | — |
| `code-quality.md` | 267 | Linting, formatting | CURRENT | — |
| `testing.md` | 312 | Test standards | CURRENT | — |
| `security.md` | 289 | Security practices | CURRENT | — |
| `deployment.md` | 198 | Vercel deployment | CURRENT | — |
| `git-workflow.md` | 176 | Branch strategy | CURRENT | — |
| `performance.md` | 234 | Performance standards | CURRENT | — |
| `accessibility.md` | 287 | WCAG compliance | CURRENT | — |
| `api-design.md` | 198 | API conventions | CURRENT | — |
| `database.md` | 245 | Supabase patterns | CURRENT | — |
| `error-handling.md` | 167 | Error patterns | CURRENT | — |
| `logging.md` | 134 | Logging standards | CURRENT | — |
| `monitoring.md` | 156 | Observability | CURRENT | — |
| `ci-cd.md` | 189 | Pipeline config | CURRENT | — |
| `environment-variables.md` | 145 | Env var management | STALE | Missing `LAB_SUPABASE_ORG_ID` |
| `typescript.md` | 198 | TS conventions | CURRENT | — |
| `react-patterns.md` | 234 | React best practices | CURRENT | — |
| `nextjs.md` | 212 | Next.js patterns | CURRENT | — |
| `tailwind.md` | 167 | Tailwind usage | CURRENT | — |
| `supabase-client.md` | 189 | Client patterns | CURRENT | — |
| `forms.md` | 178 | Form handling | CURRENT | — |
| `data-fetching.md` | 198 | Fetch patterns | CURRENT | — |
| `state-management.md` | 156 | State patterns | CURRENT | — |
| `component-patterns.md` | 187 | Component design | CURRENT | — |

**Writing quality:** Technical and thorough. Well-organized reference material.

---

### `products/`

| File | Lines | Purpose | Currency | Issues |
|------|-------|---------|----------|--------|
| `README.md` | 45 | Products index | CURRENT | — |
| `qori.md` | 234 | Qori product docs | CURRENT | — |
| `truebid.md` | 189 | Truebid product docs | CURRENT | — |

---

### `templates/`

| File | Lines | Purpose | Currency | Issues |
|------|-------|---------|----------|--------|
| `CLAUDE.md.template` | 156 | Project CLAUDE.md template | CURRENT | — |
| `README.md.template` | 89 | Project README template | CURRENT | — |
| `PR_TEMPLATE.md` | 67 | PR template | CURRENT | — |

---

## Cross-Reference Analysis

### Broken or Stale Links

| Source File | Link | Issue |
|-------------|------|-------|
| `01-getting-started/04-creating-a-project.md` | `operations/automation/spinup.sh` | Should be `spinup-typed.sh` |
| `02-spinup/README.md` | `spinup.sh` | Should reference `spinup-typed.sh` |
| `operations/automation/README.md` | `spinup.sh` as primary | Should be `spinup-typed.sh` |
| `operations/README.md` | Old spinup syntax | Needs update to typed syntax |

### Content Duplication

| Content | Location 1 | Location 2 | Location 3 |
|---------|-----------|-----------|-----------|
| First-time setup | `01-getting-started/01-first-time-setup.md` | `operations/first-time-setup.md` | `operations/automation/first-time-setup.md` |
| AI workflow | `01-getting-started/06-ai-workflow.md` | `03-building/ai-workflow.md` | — |
| Operations overview | `05-operations/README.md` | `operations/README.md` | — |

### Missing Prerequisites

| File | Missing Reference |
|------|-------------------|
| `01-getting-started/01-first-time-setup.md` | `LAB_SUPABASE_ORG_ID` env var |
| `development/environment-variables.md` | `LAB_SUPABASE_ORG_ID` env var |
| Multiple files | Project type selection guidance |

### Domain Inconsistency

| File | Uses |
|------|------|
| `docs/spinup-typed.md` | `labs.cityfriends.tech` (correct) |
| `README.md` | `labs.cityfriends.tech` (correct) |
| `operations/README.md` | `lab.cityfriends.tech` (incorrect) |

---

## Lab Standards References

Files that reference `friends-innovation-lab/lab-standards`:

- `CLAUDE.md` — references v1.0.0
- `01-getting-started/03-lab-standards-primer.md` — overview of 9 standards
- `docs/spinup-typed.md` — references retrofit playbook

Files that reference `friends-innovation-lab/project-template`:

- `docs/spinup-typed.md` — references lab-extensions
- `operations/automation/spinup-typed.sh` — clones from template

---

## Top-Level Findings

### 1. Spinup Path is Broken for Self-Service

An employee following the playbook from `01-getting-started/` will be directed to `spinup.sh` (deprecated) instead of `spinup-typed.sh` (current). This is the **primary blocker** for employee self-service.

**Affected files:**
- `01-getting-started/04-creating-a-project.md`
- `02-spinup/README.md`
- `operations/automation/README.md`

### 2. Environment Variable Documentation Gap

`LAB_SUPABASE_ORG_ID` is required by `spinup-typed.sh` but not documented in first-time setup. Employees will hit errors during spinup.

**Affected files:**
- `01-getting-started/01-first-time-setup.md`
- `development/environment-variables.md`

### 3. Three Copies of First-Time Setup

Content drift has occurred across three setup documents. Employees may find different (and conflicting) information depending on their entry point.

**Consolidation needed:**
- Keep: `01-getting-started/01-first-time-setup.md` (most complete)
- Remove or redirect: `operations/first-time-setup.md`
- Remove or redirect: `operations/automation/first-time-setup.md`

### 4. `02-spinup/` Directory May Be Redundant

The authoritative spinup documentation is now `docs/spinup-typed.md`. The `02-spinup/` directory adds confusion about where to look.

**Options:**
- Redirect `02-spinup/README.md` to `docs/spinup-typed.md`
- Move `docs/spinup-typed.md` into `02-spinup/` and update all references

### 5. Strong Writing Models Exist

For Session B rewrites, use these files as voice/tone references:
- `docs/spinup-typed.md` — best structured documentation
- `01-getting-started/01-first-time-setup.md` — friendly onboarding voice
- `03-building/prompts/` — action-oriented templates
- `CLAUDE.md` Review Council — comprehensive but scannable

---

## Recommendations for Session B

### Priority 1: Fix the Golden Path

1. Update `01-getting-started/04-creating-a-project.md` to reference `spinup-typed.sh`
2. Add `LAB_SUPABASE_ORG_ID` to `01-getting-started/01-first-time-setup.md`
3. Update `02-spinup/README.md` to redirect to `docs/spinup-typed.md`

### Priority 2: Eliminate Duplication

1. Consolidate first-time setup to single source of truth
2. Consolidate AI workflow to single location
3. Clarify relationship between `05-operations/` and `operations/`

### Priority 3: Deprecation Cleanup

1. Add deprecation notice to `spinup.sh`
2. Update `operations/automation/README.md` to lead with `spinup-typed.sh`
3. Fix domain inconsistency (`labs.cityfriends.tech` everywhere)

### Priority 4: Navigation Simplification

1. Consider flattening `docs/` into appropriate numbered directory
2. Evaluate whether `operations/` and `05-operations/` should merge
3. Add "you are here" breadcrumbs to key docs

---

## File Counts by Directory

| Directory | Files | Lines (approx) |
|-----------|-------|----------------|
| Root | 2 | 390 |
| `01-getting-started/` | 7 | 1,304 |
| `02-spinup/` | 1 | 36 |
| `docs/` | 1 | 230 |
| `03-building/` | 16 | 1,400 |
| `04-delivering/` | 5 | 699 |
| `05-operations/` | 4 | 452 |
| `operations/` | 8 | 4,817 |
| `development/` | 25 | 4,800 |
| `products/` | 3 | 468 |
| `templates/` | 3 | 312 |
| **Total** | **~75** | **~15,000** |

---

## Appendix: Files Not Inventoried

Per instructions, these were excluded:
- `_archive/` — retired content
- `.git/` — version control

---

*This inventory was generated for Session B restructure planning. No files were modified.*
