# PR Template

*Standard pull request template for Friends Innovation Lab.*

---

## Setup

Create this file in your repository:

```
.github/
└── pull_request_template.md
```

GitHub will automatically use this template for new PRs.

---

## Standard PR Template

```markdown
## What

<!-- Brief description of what this PR does -->


## Why

<!-- Context, motivation, link to issue -->

Closes #

## How

<!-- Technical approach, key decisions made -->


## Testing

<!-- How you tested this change -->

- [ ] Manual testing
- [ ] Added/updated unit tests
- [ ] Added/updated integration tests
- [ ] Tested on mobile

## Screenshots

<!-- For UI changes, before/after screenshots -->

| Before | After |
|--------|-------|
|        |       |

## Checklist

- [ ] Self-reviewed the code
- [ ] No console errors or warnings
- [ ] Types are correct (no `any` unless necessary)
- [ ] Tests pass locally
- [ ] Documentation updated (if needed)
- [ ] Ready for review

## Notes for Reviewer

<!-- Anything specific you'd like reviewers to focus on -->

```

---

## Template Variations

### Simple Template (Small Changes)

```markdown
## What

<!-- Brief description -->


## Why

Closes #

## Testing

- [ ] Tested locally
- [ ] No console errors

## Checklist

- [ ] Self-reviewed
- [ ] Tests pass
```

### Feature Template (New Features)

```markdown
## What

<!-- Describe the new feature -->


## Why

<!-- User story or motivation -->

Closes #

## How

<!-- Technical approach -->

### Key Changes

-
-
-

### New Dependencies

<!-- List any new packages added -->

-

## Testing

- [ ] Manual testing completed
- [ ] Unit tests added
- [ ] Integration tests added
- [ ] Edge cases covered
- [ ] Mobile tested

## Screenshots / Demo

<!-- Screenshots or video of the feature -->

| Desktop | Mobile |
|---------|--------|
|         |        |

## Checklist

- [ ] Self-reviewed the code
- [ ] No TypeScript errors
- [ ] No ESLint warnings
- [ ] Tests pass
- [ ] Documentation updated
- [ ] Accessibility checked (keyboard, screen reader)

## Rollback Plan

<!-- How to revert if issues arise -->

```

### Bug Fix Template

```markdown
## Bug Description

<!-- What was the bug? -->


## Root Cause

<!-- Why did the bug occur? -->


## Fix

<!-- How does this PR fix it? -->


## Testing

<!-- How to verify the fix -->

**Steps to reproduce (before fix):**
1.
2.
3.

**Verification (after fix):**
1.
2.
3.

- [ ] Bug no longer reproducible
- [ ] No regressions introduced
- [ ] Added test to prevent recurrence

## Checklist

- [ ] Closes issue #
- [ ] Self-reviewed
- [ ] Tests pass
```

### Refactor Template

```markdown
## What

<!-- What is being refactored? -->


## Why

<!-- Motivation for refactoring -->

- [ ] Performance improvement
- [ ] Code clarity
- [ ] Reduce duplication
- [ ] Better architecture
- [ ] Prepare for future work

## Changes

<!-- Key changes made -->

### Before

```typescript
// Old approach
```

### After

```typescript
// New approach
```

## Testing

- [ ] All existing tests pass
- [ ] No behavior changes (unless intended)
- [ ] Manually verified functionality

## Checklist

- [ ] No functional changes (pure refactor)
- [ ] Tests pass
- [ ] Self-reviewed

## Notes

<!-- Any breaking changes or migration needed -->

```

### Hotfix Template

```markdown
## 🚨 HOTFIX

### Issue

<!-- What's broken in production? -->


### Fix

<!-- What does this PR do to fix it? -->


### Impact

<!-- What's affected? -->

- Users affected:
- Severity: Critical / High / Medium

### Testing

- [ ] Fix verified locally
- [ ] Tested the specific scenario

### Post-Deploy

- [ ] Monitor error rates
- [ ] Follow up with proper fix if needed

---

**Reviewer:** Please review ASAP. This is blocking production.
```

---

## Using Multiple Templates

For different PR types, create multiple templates:

```
.github/
├── pull_request_template.md           # Default
└── PULL_REQUEST_TEMPLATE/
    ├── feature.md
    ├── bugfix.md
    ├── refactor.md
    └── hotfix.md
```

Contributors can select a template when creating a PR by adding `?template=feature.md` to the URL.

---

## Tips for Good PRs

### Title Format

```
type: brief description

Examples:
feat: add user profile page
fix: resolve login redirect loop
refactor: simplify auth hook
docs: update API documentation
chore: upgrade dependencies
```

Types:
- `feat` — New feature
- `fix` — Bug fix
- `refactor` — Code change (no new feature or fix)
- `docs` — Documentation
- `test` — Tests
- `chore` — Maintenance

### Link to Issues

```markdown
Closes #123
Fixes #123
Resolves #123
```

GitHub auto-closes the issue when PR merges.

### Screenshots That Help

**Good screenshots:**
- Before/after comparison
- Full page context
- Mobile and desktop
- Error states
- Loading states

**Bad screenshots:**
- Tiny crops with no context
- Only the happy path
- Missing mobile view

### Self-Review Checklist

Before requesting review:

1. **Read your own diff** — Line by line
2. **Check for debugging code** — console.logs, TODO comments
3. **Verify the build** — Does it compile?
4. **Run tests** — Do they pass?
5. **Check the preview** — Does the Vercel preview work?
6. **Test on mobile** — Resize browser or use devtools

---

## PR Template File

Copy this into `.github/pull_request_template.md`:

```markdown
## What

<!-- Brief description of what this PR does -->


## Why

<!-- Context, motivation, link to issue -->

Closes #

## How

<!-- Technical approach, key decisions made -->


## Testing

<!-- How you tested this change -->

- [ ] Tested locally
- [ ] Added/updated tests
- [ ] Tested on mobile (if UI change)

## Screenshots

<!-- For UI changes (delete if not applicable) -->

## Checklist

- [ ] Self-reviewed the code
- [ ] No console errors or TypeScript issues
- [ ] Tests pass
- [ ] Documentation updated (if needed)

## Notes for Reviewer

<!-- Anything specific to call out (delete if not applicable) -->

```

---

*See also: [Code Review](code-review.md) · [Linting](linting.md)*
