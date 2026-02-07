# QA Checklist

*Manual testing checklist before release at Friends Innovation Lab.*

---

## Overview

This checklist covers manual testing to perform before demos, releases, or client handoffs. Automated tests catch regressions; this checklist catches UX issues, edge cases, and polish problems.

---

## Pre-Demo Checklist

Run through this before any client demo or presentation.

### Critical Path Testing

- [ ] **Happy path works** — Complete the main user journey end-to-end
- [ ] **Auth flow** — Sign up, login, logout all work
- [ ] **Core features** — Test the 3-5 most important features
- [ ] **Data saves** — Create, update, delete operations persist correctly
- [ ] **No console errors** — Check browser console for errors/warnings

### Performance

- [ ] **Cold start** — First load completes in reasonable time (<3 seconds)
- [ ] **No loading spinners stuck** — All loading states resolve
- [ ] **Images load** — All images appear (no broken images)
- [ ] **No layout shift** — Page doesn't jump around while loading

### Basic Responsiveness

- [ ] **Mobile view** — Key pages work on phone-sized screen
- [ ] **Tablet view** — Key pages work on tablet-sized screen
- [ ] **No horizontal scroll** — Page doesn't overflow horizontally

---

## Full QA Checklist

Use this for releases and thorough testing.

### Functionality

#### Forms
- [ ] All required fields show validation errors when empty
- [ ] Validation messages are helpful (not just "Invalid")
- [ ] Form submits successfully with valid data
- [ ] Success message or redirect after submit
- [ ] Cannot double-submit (button disables)
- [ ] Form works with keyboard only (Tab, Enter)
- [ ] Autofill works correctly

#### Data Operations
- [ ] Create — New items appear in list
- [ ] Read — Data displays correctly
- [ ] Update — Changes persist after refresh
- [ ] Delete — Items removed, confirmation if destructive
- [ ] Empty states — Helpful message when no data

#### Authentication
- [ ] Sign up creates account
- [ ] Email verification (if enabled)
- [ ] Login works
- [ ] Logout clears session
- [ ] Password reset flow works
- [ ] Protected routes redirect to login
- [ ] Session persists on refresh
- [ ] Session expires appropriately

#### Navigation
- [ ] All links work (no 404s)
- [ ] Back button works correctly
- [ ] Deep links work (copy/paste URL)
- [ ] Active states show current page

### Visual & UX

#### Layout
- [ ] No overlapping elements
- [ ] Consistent spacing throughout
- [ ] Content doesn't overflow containers
- [ ] Modals/dialogs center correctly
- [ ] Footer at bottom (not floating mid-page)

#### Typography
- [ ] Text is readable (size, contrast)
- [ ] Long text truncates or wraps appropriately
- [ ] No orphaned words in headings
- [ ] Links are visually distinct

#### Loading States
- [ ] Loading indicators show during fetches
- [ ] Skeleton screens for slow content
- [ ] No flash of wrong content
- [ ] Smooth transitions between states

#### Error States
- [ ] Error messages are user-friendly
- [ ] Errors don't crash the page
- [ ] Users can recover from errors
- [ ] 404 page exists and is helpful
- [ ] API errors show appropriate message

#### Empty States
- [ ] Empty lists show helpful message
- [ ] Call to action to add first item
- [ ] No confusing blank areas

### Responsive Design

#### Mobile (< 768px)
- [ ] Navigation works (hamburger menu, etc.)
- [ ] Touch targets are large enough (44px+)
- [ ] Text is readable without zooming
- [ ] Forms are usable
- [ ] Tables scroll horizontally or stack
- [ ] Modals fit on screen

#### Tablet (768px - 1024px)
- [ ] Layout adjusts appropriately
- [ ] Nothing breaks at this width
- [ ] Touch and mouse both work

#### Desktop (> 1024px)
- [ ] Content doesn't stretch too wide
- [ ] Layout uses space well
- [ ] Hover states work

### Browser Testing

- [ ] Chrome (latest)
- [ ] Firefox (latest)
- [ ] Safari (latest)
- [ ] Edge (latest)
- [ ] Mobile Safari (iOS)
- [ ] Mobile Chrome (Android)

### Accessibility

#### Keyboard
- [ ] Can Tab through all interactive elements
- [ ] Focus is visible at all times
- [ ] Can activate buttons/links with Enter/Space
- [ ] Can close modals with Escape
- [ ] Tab order is logical

#### Screen Reader
- [ ] Page has proper heading hierarchy
- [ ] Images have alt text
- [ ] Form inputs have labels
- [ ] Buttons have accessible names
- [ ] Dynamic content is announced

#### Visual
- [ ] Color contrast passes (4.5:1 for text)
- [ ] Don't rely on color alone for meaning
- [ ] Text can be resized to 200%
- [ ] Animations respect reduced motion

### Performance

- [ ] First Contentful Paint < 2s
- [ ] Time to Interactive < 4s
- [ ] No large layout shifts
- [ ] Images are optimized (WebP, proper sizes)
- [ ] JavaScript bundle is reasonable
- [ ] No memory leaks (long sessions)

### Security

- [ ] Sensitive data not in URLs
- [ ] No secrets in client-side code
- [ ] Proper authentication on API routes
- [ ] Cannot access other users' data
- [ ] XSS protection (user input is sanitized)
- [ ] HTTPS only (no mixed content)

---

## Device Testing Matrix

### Desktop

| Browser | Windows | macOS |
|---------|---------|-------|
| Chrome | ✓ | ✓ |
| Firefox | ✓ | ✓ |
| Safari | — | ✓ |
| Edge | ✓ | ✓ |

### Mobile

| Device | Browser |
|--------|---------|
| iPhone (recent) | Safari |
| iPhone (recent) | Chrome |
| Android (recent) | Chrome |
| iPad | Safari |

### Test at These Breakpoints

| Breakpoint | Width | Device |
|------------|-------|--------|
| Mobile | 375px | iPhone SE/13 mini |
| Mobile Large | 428px | iPhone 13 Pro Max |
| Tablet | 768px | iPad Mini |
| Tablet Large | 1024px | iPad Pro |
| Desktop | 1280px | Laptop |
| Desktop Large | 1536px+ | External monitor |

---

## Feature-Specific Checklists

### File Upload
- [ ] Accepts correct file types
- [ ] Rejects wrong file types with message
- [ ] Shows upload progress
- [ ] Handles large files appropriately
- [ ] Can cancel upload
- [ ] Shows preview (images)
- [ ] Works on mobile

### Search
- [ ] Returns relevant results
- [ ] Handles empty search
- [ ] Handles no results
- [ ] Debounces input (doesn't spam API)
- [ ] Clear button works
- [ ] Recent searches (if applicable)

### Pagination / Infinite Scroll
- [ ] First page loads correctly
- [ ] Can navigate to other pages
- [ ] Correct item count shown
- [ ] Edge: page 1 of 1
- [ ] Edge: large number of pages
- [ ] URL updates with page (shareable)

### Tables
- [ ] Columns align correctly
- [ ] Sorting works
- [ ] Filtering works
- [ ] Row actions work
- [ ] Responsive on mobile
- [ ] Empty state

### Modals / Dialogs
- [ ] Opens correctly
- [ ] Closes on X button
- [ ] Closes on backdrop click
- [ ] Closes on Escape
- [ ] Focus trapped inside
- [ ] Focus returns on close
- [ ] Scrollable if content is long

### Notifications / Toasts
- [ ] Appear when expected
- [ ] Auto-dismiss after delay
- [ ] Can be manually dismissed
- [ ] Accessible (announced to screen readers)
- [ ] Don't block important content
- [ ] Multiple can stack

---

## Bug Report Template

When you find an issue:

```markdown
## Bug Description
[Clear, concise description]

## Steps to Reproduce
1. Go to [page]
2. Click on [element]
3. Enter [data]
4. See error

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Screenshots
[If applicable]

## Environment
- Browser: Chrome 120
- OS: macOS 14
- Device: Desktop
- Screen size: 1440x900

## Severity
- [ ] Critical (blocks release)
- [ ] High (major feature broken)
- [ ] Medium (workaround exists)
- [ ] Low (minor issue)
```

---

## Pre-Release Sign-Off

Before any release:

### Development
- [ ] All automated tests pass
- [ ] No TypeScript errors
- [ ] No ESLint errors
- [ ] Build succeeds

### Testing
- [ ] QA checklist complete
- [ ] Critical bugs fixed
- [ ] Known issues documented

### Documentation
- [ ] README updated
- [ ] API docs updated (if changed)
- [ ] Changelog updated

### Deployment
- [ ] Environment variables set
- [ ] Database migrations run
- [ ] Preview deployment tested
- [ ] Rollback plan in place

---

## Quick Smoke Test

5-minute check for urgent deploys:

1. [ ] App loads (no white screen)
2. [ ] Can log in
3. [ ] Main feature works
4. [ ] No console errors
5. [ ] Mobile view renders

---

*See also: [Unit Testing](unit.md) · [Integration Testing](integration.md) · [E2E Testing](e2e.md)*
