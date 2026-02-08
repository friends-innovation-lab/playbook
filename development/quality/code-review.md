# Code Review Standards

*How we review code at Friends Innovation Lab.*

---

## Overview

Code review ensures quality, shares knowledge, and catches issues before they reach production. Every change goes through review before merging.

---

## Goals of Code Review

1. **Catch bugs** — Find logic errors, edge cases, security issues
2. **Maintain quality** — Ensure code meets our standards
3. **Share knowledge** — Spread understanding of the codebase
4. **Improve code** — Suggest better approaches
5. **Mentor** — Help team members grow

---

## Review Process

### For Authors

#### Before Requesting Review

- [ ] Code builds without errors
- [ ] All tests pass
- [ ] No linting errors
- [ ] Self-reviewed the diff
- [ ] PR description is complete
- [ ] Linked to issue/ticket
- [ ] Screenshots for UI changes

#### PR Size Guidelines

| Size | Lines Changed | Review Time |
|------|---------------|-------------|
| Small | < 100 | < 30 min |
| Medium | 100-300 | 30-60 min |
| Large | 300-500 | 1-2 hours |
| Too Large | > 500 | **Split it up** |

**Smaller PRs get better reviews.** Break large features into smaller, reviewable chunks.

#### Writing Good PR Descriptions

```markdown
## What

[Brief description of the change]

## Why

[Context, motivation, link to issue]

## How

[Technical approach, key decisions]

## Testing

[How you tested this]

## Screenshots

[For UI changes]

## Checklist

- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No console errors
- [ ] Tested on mobile
```

### For Reviewers

#### Review Checklist

**Functionality**
- [ ] Code does what the PR claims
- [ ] Edge cases handled
- [ ] Error handling is appropriate
- [ ] No obvious bugs

**Code Quality**
- [ ] Code is readable and clear
- [ ] No unnecessary complexity
- [ ] Follows project conventions
- [ ] No code duplication
- [ ] Good naming (variables, functions)

**Architecture**
- [ ] Changes make sense in context
- [ ] No obvious performance issues
- [ ] Dependencies are appropriate
- [ ] API design is sensible

**Testing**
- [ ] Tests cover the changes
- [ ] Tests are meaningful (not just coverage)
- [ ] Edge cases tested

**Security**
- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] Auth/permissions correct
- [ ] No SQL injection / XSS risks

**Documentation**
- [ ] Code comments where needed
- [ ] README updated if needed
- [ ] Types/interfaces documented

---

## Giving Feedback

### Comment Types

Use prefixes to clarify intent:

| Prefix | Meaning | Action Required |
|--------|---------|-----------------|
| `nit:` | Minor nitpick | Optional to fix |
| `suggestion:` | Possible improvement | Consider it |
| `question:` | Need clarification | Please explain |
| `issue:` | Problem to fix | Must address |
| `blocker:` | Cannot merge until fixed | Must fix |

### Examples

```
nit: Could rename `data` to `users` for clarity, but not blocking.
```

```
suggestion: Consider using `useMemo` here since this computation
runs on every render. Not required but might help performance.
```

```
question: Why did we choose to fetch this client-side instead
of in the server component? Just want to understand the tradeoff.
```

```
issue: This doesn't handle the case where `user` is null.
We should add a null check or early return.
```

```
blocker: This exposes the API key in client-side code.
Must move to server-side before merging.
```

### Tone Guidelines

**Do:**
- Be specific and actionable
- Explain *why* not just *what*
- Acknowledge good code
- Ask questions when unsure
- Suggest alternatives, not just problems

**Don't:**
- Be condescending
- Use "you" accusingly ("You broke this")
- Leave vague comments ("This is wrong")
- Nitpick excessively
- Review when frustrated

### Good vs Bad Feedback

```
❌ "This is wrong."

✅ "This will throw if `items` is empty. Consider adding a
   length check or using optional chaining: `items?.[0]`"
```

```
❌ "Why would you do it this way?"

✅ "question: I'm curious about the approach here. Was there a
   specific reason to use reduce instead of filter + map?
   Either works, just want to understand."
```

```
❌ "Fix the formatting."

✅ "nit: The linter should catch this, but there's inconsistent
   spacing on line 42. Running `npm run lint:fix` should handle it."
```

---

## Responding to Feedback

### For Authors

- **Don't take it personally** — Feedback is about code, not you
- **Assume good intent** — Reviewers want to help
- **Explain your reasoning** — If you disagree, discuss it
- **Learn from feedback** — Patterns you'll avoid next time
- **Say thanks** — Reviewing takes time

### Disagreements

When you disagree with feedback:

1. **Understand first** — Make sure you understand their point
2. **Explain your view** — Share your reasoning
3. **Find common ground** — Look for a middle solution
4. **Escalate if needed** — Get a third opinion
5. **Commit to decision** — Once decided, move forward

```
Reviewer: "We should use React Query for this data fetching."

Author: "I considered that, but since we only fetch once on mount
and don't need caching/revalidation, I thought a simple useEffect
was sufficient. The component is small and won't be reused.
Open to adding React Query if you feel strongly though!"
```

---

## Review Turnaround

### Expectations

| Priority | First Review | Full Approval |
|----------|--------------|---------------|
| Urgent (blocking) | < 2 hours | Same day |
| Normal | < 24 hours | 1-2 days |
| Low priority | < 48 hours | 3-5 days |

### Tips for Fast Reviews

**Authors:**
- Keep PRs small
- Write clear descriptions
- Self-review first
- Tag specific reviewers

**Reviewers:**
- Review in batches (not one-off)
- Start with quick wins
- Don't block on nits
- Approve with minor comments

---

## Approval & Merging

### Approval Requirements

- **1 approval** — Standard changes
- **2 approvals** — Large changes, critical paths, security
- **Team lead approval** — Architecture changes, new dependencies

### Merge Rules

- All required checks pass (CI, tests, linting)
- All blocking comments resolved
- Required approvals obtained
- Branch is up to date with main

### Merge Strategy

We use **Squash and Merge**:
- Keeps main history clean
- One commit per PR
- PR title becomes commit message

---

## Special Cases

### Urgent Hotfixes

For production issues:
1. Create PR with `[HOTFIX]` prefix
2. Get one quick review
3. Merge immediately
4. Follow up with proper review if rushed

### WIP / Draft PRs

Use draft PRs for:
- Early feedback on approach
- Showing work in progress
- Pairing / collaboration

Mark as ready when complete.

### Refactoring PRs

For large refactors:
- Separate from feature work
- Include before/after examples
- Run full test suite
- Document any behavior changes

---

## Automated Checks

PRs must pass:

| Check | Tool | Required |
|-------|------|----------|
| Build | Next.js | ✓ |
| Types | TypeScript | ✓ |
| Lint | ESLint | ✓ |
| Format | Prettier | ✓ |
| Tests | Vitest | ✓ |
| Preview | Vercel | ✓ |

These run automatically on every PR.

---

## Review Etiquette

### Dos

- Review promptly
- Be thorough but not slow
- Praise good code
- Ask questions, don't assume
- Approve when ready (don't over-polish)

### Don'ts

- Let PRs sit for days
- Request changes for style preferences
- Approve without reading
- Comment on every line
- Ghost after requesting changes

---

## Quick Reference

### PR Author Checklist

```markdown
- [ ] PR is reasonably sized (< 300 lines ideal)
- [ ] Description explains what/why/how
- [ ] Linked to issue
- [ ] Self-reviewed the diff
- [ ] Tests added/updated
- [ ] All checks pass
- [ ] Screenshots for UI changes
```

### Reviewer Checklist

```markdown
- [ ] Understand the context/goal
- [ ] Code does what it claims
- [ ] No obvious bugs or security issues
- [ ] Tests are adequate
- [ ] Code is readable/maintainable
- [ ] Provide actionable feedback
- [ ] Approve or request changes clearly
```

---

*See also: [PR Template](pr-template.md) · [Linting](linting.md)*
