# Accessibility Standards

*How we build accessible applications at Friends Innovation Lab.*

---

## Why Accessibility Matters

1. **Legal requirement** — Government clients require WCAG 2.1 AA compliance (Section 508)
2. **Better for everyone** — Accessible design improves UX for all users
3. **Larger audience** — 15-20% of people have some form of disability
4. **SEO benefits** — Semantic HTML improves search rankings

---

## WCAG 2.1 AA Checklist

We target **WCAG 2.1 Level AA** for all projects.

### Perceivable

| Requirement | How We Meet It |
|-------------|----------------|
| Text alternatives for images | Always include `alt` text |
| Captions for video/audio | Provide transcripts |
| Content adaptable | Use semantic HTML |
| Distinguishable | Sufficient color contrast |

### Operable

| Requirement | How We Meet It |
|-------------|----------------|
| Keyboard accessible | All interactions work with keyboard |
| Enough time | No auto-advancing content without controls |
| No seizure triggers | No flashing content >3 times/second |
| Navigable | Clear focus indicators, skip links |

### Understandable

| Requirement | How We Meet It |
|-------------|----------------|
| Readable | Clear language, define abbreviations |
| Predictable | Consistent navigation, no unexpected changes |
| Input assistance | Clear error messages, labels |

### Robust

| Requirement | How We Meet It |
|-------------|----------------|
| Compatible | Valid HTML, works with assistive tech |

---

## Semantic HTML

Use the right element for the job.

### Document Structure

```tsx
// ✅ Semantic structure
<header>
  <nav aria-label="Main navigation">
    <ul>
      <li><a href="/">Home</a></li>
      <li><a href="/about">About</a></li>
    </ul>
  </nav>
</header>

<main>
  <article>
    <h1>Page Title</h1>
    <section aria-labelledby="intro-heading">
      <h2 id="intro-heading">Introduction</h2>
      <p>Content...</p>
    </section>
  </article>

  <aside aria-label="Related content">
    <h2>Related Articles</h2>
  </aside>
</main>

<footer>
  <p>© 2024 Company</p>
</footer>

// ❌ Div soup
<div class="header">
  <div class="nav">...</div>
</div>
<div class="main">
  <div class="content">...</div>
</div>
```

### Heading Hierarchy

Use headings in order. Don't skip levels.

```tsx
// ✅ Correct hierarchy
<h1>Page Title</h1>
  <h2>Section</h2>
    <h3>Subsection</h3>
    <h3>Subsection</h3>
  <h2>Section</h2>
    <h3>Subsection</h3>

// ❌ Skipped levels
<h1>Page Title</h1>
  <h3>Section</h3>  // Skipped h2!
  <h5>Subsection</h5>  // Skipped h4!
```

### Lists

```tsx
// Navigation
<nav>
  <ul>
    <li><a href="/">Home</a></li>
    <li><a href="/about">About</a></li>
  </ul>
</nav>

// Definition list
<dl>
  <dt>Term</dt>
  <dd>Definition</dd>
</dl>

// Ordered steps
<ol>
  <li>First step</li>
  <li>Second step</li>
</ol>
```

### Buttons vs Links

```tsx
// Links: navigation to a new page/location
<a href="/about">About Us</a>
<a href="#section">Jump to section</a>

// Buttons: actions that don't navigate
<button onClick={handleSave}>Save</button>
<button onClick={openModal}>Open Settings</button>

// ❌ Don't do this
<a onClick={handleSave}>Save</a>  // Should be button
<button onClick={() => router.push('/about')}>About</button>  // Should be link
```

---

## Keyboard Navigation

### All Interactive Elements Must Be Keyboard Accessible

```tsx
// ✅ Natively keyboard accessible
<button>Click me</button>
<a href="/page">Link</a>
<input type="text" />
<select>...</select>

// ⚠️ Needs tabindex and key handlers
<div
  role="button"
  tabIndex={0}
  onClick={handleClick}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      handleClick()
    }
  }}
>
  Custom button
</div>

// ✅ Better: just use a button
<button onClick={handleClick}>Custom button</button>
```

### Focus Management

```tsx
// Visible focus indicator (shadcn/ui handles this)
<Button className="focus-visible:ring-2 focus-visible:ring-ring">
  Focused Button
</Button>

// Skip link for keyboard users
<a
  href="#main-content"
  className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50 focus:px-4 focus:py-2 focus:bg-background"
>
  Skip to main content
</a>

<main id="main-content">
  ...
</main>
```

### Focus Trapping in Modals

shadcn/ui Dialog handles this automatically:

```tsx
import {
  Dialog,
  DialogContent,
  DialogTitle,
} from "@/components/ui/dialog"

// Focus is automatically trapped inside
// Escape key closes the dialog
// Focus returns to trigger when closed
<Dialog>
  <DialogTrigger>Open</DialogTrigger>
  <DialogContent>
    <DialogTitle>Modal Title</DialogTitle>
    {/* Focus trapped here */}
  </DialogContent>
</Dialog>
```

### Tab Order

```tsx
// Natural tab order follows DOM order
<form>
  <input name="first" />   {/* Tab 1 */}
  <input name="second" />  {/* Tab 2 */}
  <button>Submit</button>  {/* Tab 3 */}
</form>

// Avoid positive tabindex
<input tabIndex={2} />  // ❌ Don't do this

// Use tabIndex="0" to add to tab order
// Use tabIndex="-1" to remove from tab order (but allow programmatic focus)
```

---

## Forms

### Labels

Every input needs a label.

```tsx
// ✅ Explicit label association
<Label htmlFor="email">Email</Label>
<Input id="email" type="email" />

// ✅ Implicit association (label wraps input)
<label>
  Email
  <input type="email" />
</label>

// ❌ No label
<Input type="email" placeholder="Email" />

// ⚠️ Placeholder is not a label
// Placeholders disappear when typing
<Input placeholder="Email" />  // Still needs a label!
```

### Required Fields

```tsx
<div className="space-y-2">
  <Label htmlFor="email">
    Email <span className="text-destructive">*</span>
  </Label>
  <Input
    id="email"
    type="email"
    required
    aria-required="true"
  />
</div>
```

### Error Messages

```tsx
<div className="space-y-2">
  <Label htmlFor="email">Email</Label>
  <Input
    id="email"
    type="email"
    aria-invalid={!!error}
    aria-describedby={error ? "email-error" : undefined}
    className={error ? "border-destructive" : ""}
  />
  {error && (
    <p id="email-error" className="text-sm text-destructive">
      {error}
    </p>
  )}
</div>
```

### Field Descriptions

```tsx
<div className="space-y-2">
  <Label htmlFor="password">Password</Label>
  <Input
    id="password"
    type="password"
    aria-describedby="password-hint"
  />
  <p id="password-hint" className="text-sm text-muted-foreground">
    Must be at least 8 characters with one number.
  </p>
</div>
```

### Fieldsets for Groups

```tsx
<fieldset>
  <legend className="text-lg font-medium">Notification Preferences</legend>
  <div className="mt-4 space-y-2">
    <div className="flex items-center gap-2">
      <Checkbox id="email-notif" />
      <Label htmlFor="email-notif">Email notifications</Label>
    </div>
    <div className="flex items-center gap-2">
      <Checkbox id="sms-notif" />
      <Label htmlFor="sms-notif">SMS notifications</Label>
    </div>
  </div>
</fieldset>
```

---

## Images

### Alt Text

```tsx
// Informative image - describe the content
<Image
  src="/chart.png"
  alt="Bar chart showing sales increased 25% from Q1 to Q2"
/>

// Decorative image - empty alt
<Image
  src="/decorative-pattern.png"
  alt=""
  aria-hidden="true"
/>

// Image as link - describe destination
<a href="/profile">
  <Image src="/avatar.jpg" alt="View your profile" />
</a>

// Complex image - provide long description
<figure>
  <Image
    src="/complex-diagram.png"
    alt="System architecture diagram"
    aria-describedby="diagram-desc"
  />
  <figcaption id="diagram-desc">
    The system consists of three layers: presentation (React),
    API (Next.js), and database (Supabase)...
  </figcaption>
</figure>
```

### Icons

```tsx
// Decorative icon (with text)
<Button>
  <PlusIcon aria-hidden="true" className="h-4 w-4 mr-2" />
  Add Item
</Button>

// Meaningful icon (no text) - needs label
<Button variant="ghost" size="icon" aria-label="Delete item">
  <TrashIcon className="h-4 w-4" />
</Button>

// Icon with tooltip
<TooltipProvider>
  <Tooltip>
    <TooltipTrigger asChild>
      <Button variant="ghost" size="icon" aria-label="Settings">
        <SettingsIcon className="h-4 w-4" />
      </Button>
    </TooltipTrigger>
    <TooltipContent>Settings</TooltipContent>
  </Tooltip>
</TooltipProvider>
```

---

## Color and Contrast

### Minimum Contrast Ratios (WCAG AA)

| Element | Ratio | Example |
|---------|-------|---------|
| Normal text | 4.5:1 | Body copy |
| Large text (18px+ bold or 24px+) | 3:1 | Headings |
| UI components | 3:1 | Buttons, inputs |

### Don't Rely on Color Alone

```tsx
// ❌ Color only
<span className="text-red-500">Error</span>
<span className="text-green-500">Success</span>

// ✅ Color + icon/text
<span className="text-destructive flex items-center gap-1">
  <AlertCircle className="h-4 w-4" />
  Error: Please fix this field
</span>

<span className="text-green-600 flex items-center gap-1">
  <CheckCircle className="h-4 w-4" />
  Success
</span>

// ✅ Color + pattern (for charts)
// Use different patterns/shapes in addition to colors
```

### Testing Contrast

Use these tools:
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- Chrome DevTools (Inspect element → color picker shows ratio)
- [Stark](https://www.getstark.co/) browser extension

---

## ARIA

### When to Use ARIA

1. First, use semantic HTML (covers 90% of cases)
2. Add ARIA only when HTML isn't enough

```tsx
// ❌ Unnecessary ARIA
<button role="button">Click</button>  // button already has this role
<nav role="navigation">...</nav>  // nav already implies this

// ✅ Necessary ARIA
<div role="tablist">
  <button role="tab" aria-selected="true">Tab 1</button>
  <button role="tab" aria-selected="false">Tab 2</button>
</div>
```

### Common ARIA Attributes

```tsx
// Label for screen readers (when no visible label)
<button aria-label="Close dialog">
  <XIcon />
</button>

// Reference another element as label
<dialog aria-labelledby="dialog-title">
  <h2 id="dialog-title">Confirm Delete</h2>
</dialog>

// Additional description
<input aria-describedby="hint" />
<p id="hint">Enter your full legal name</p>

// Current state
<a href="/dashboard" aria-current="page">Dashboard</a>

// Expanded state (accordion, dropdown)
<button aria-expanded={isOpen} aria-controls="panel">
  Toggle
</button>
<div id="panel" hidden={!isOpen}>Content</div>

// Invalid state
<input aria-invalid="true" />

// Live regions (for dynamic updates)
<div aria-live="polite">  {/* Announces when content changes */}
  {statusMessage}
</div>

<div aria-live="assertive">  {/* Interrupts to announce */}
  {errorMessage}
</div>
```

### ARIA Roles for Custom Components

```tsx
// Tabs
<div role="tablist">
  <button role="tab" aria-selected={active === 0} aria-controls="panel-0">
    Tab 1
  </button>
  <button role="tab" aria-selected={active === 1} aria-controls="panel-1">
    Tab 2
  </button>
</div>
<div role="tabpanel" id="panel-0">Content 1</div>
<div role="tabpanel" id="panel-1" hidden>Content 2</div>

// Alert
<div role="alert">
  Something went wrong!
</div>

// Status (less urgent than alert)
<div role="status">
  3 items in cart
</div>
```

---

## Screen Reader Only Text

Use `.sr-only` for content only screen readers should see:

```tsx
// Tailwind's sr-only class
<span className="sr-only">Loading, please wait</span>

// Common uses:

// Icon button label
<Button variant="ghost" size="icon">
  <TrashIcon aria-hidden="true" />
  <span className="sr-only">Delete item</span>
</Button>

// Additional context
<a href="/blog/post-1">
  Read more <span className="sr-only">about accessibility best practices</span>
</a>

// Table context
<th>
  <span className="sr-only">Actions</span>
</th>
```

The `sr-only` class:
```css
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border-width: 0;
}
```

---

## Loading States

```tsx
// Spinner with announcement
<div role="status" aria-live="polite">
  <Loader2 className="h-4 w-4 animate-spin" aria-hidden="true" />
  <span className="sr-only">Loading...</span>
</div>

// Button loading state
<Button disabled>
  <Loader2 className="mr-2 h-4 w-4 animate-spin" aria-hidden="true" />
  <span>Saving...</span>
</Button>

// Skeleton with aria-busy
<div aria-busy="true" aria-label="Loading content">
  <Skeleton className="h-4 w-full" />
  <Skeleton className="h-4 w-3/4" />
</div>

// Progress indicator
<div
  role="progressbar"
  aria-valuenow={75}
  aria-valuemin={0}
  aria-valuemax={100}
  aria-label="Upload progress"
>
  <div className="h-2 bg-primary" style={{ width: '75%' }} />
</div>
```

---

## Tables

```tsx
<table>
  <caption className="sr-only">User accounts and their status</caption>
  <thead>
    <tr>
      <th scope="col">Name</th>
      <th scope="col">Email</th>
      <th scope="col">Status</th>
      <th scope="col">
        <span className="sr-only">Actions</span>
      </th>
    </tr>
  </thead>
  <tbody>
    {users.map(user => (
      <tr key={user.id}>
        <td>{user.name}</td>
        <td>{user.email}</td>
        <td>
          <Badge variant={user.active ? "default" : "secondary"}>
            {user.active ? "Active" : "Inactive"}
          </Badge>
        </td>
        <td>
          <Button variant="ghost" size="icon" aria-label={`Edit ${user.name}`}>
            <EditIcon className="h-4 w-4" />
          </Button>
        </td>
      </tr>
    ))}
  </tbody>
</table>
```

---

## Motion and Animation

### Respect User Preferences

```tsx
// In Tailwind, use motion-safe/motion-reduce
<div className="motion-safe:animate-bounce">
  Bounces only if user hasn't reduced motion
</div>

// In CSS/globals.css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

// In React
const prefersReducedMotion = window.matchMedia(
  '(prefers-reduced-motion: reduce)'
).matches

<motion.div
  animate={{ x: 100 }}
  transition={{ duration: prefersReducedMotion ? 0 : 0.3 }}
/>
```

---

## Testing Accessibility

### Automated Testing

```tsx
// In tests with jest-axe
import { axe, toHaveNoViolations } from 'jest-axe'

expect.extend(toHaveNoViolations)

test('page has no accessibility violations', async () => {
  const { container } = render(<MyComponent />)
  const results = await axe(container)
  expect(results).toHaveNoViolations()
})
```

### Manual Testing Checklist

| Test | How |
|------|-----|
| Keyboard navigation | Tab through entire page |
| Focus visibility | Can you see where focus is? |
| Screen reader | Test with VoiceOver (Mac) or NVDA (Windows) |
| Zoom | Works at 200% zoom? |
| Color contrast | Use contrast checker |
| No mouse | Complete all tasks keyboard-only |

### Tools

| Tool | Purpose |
|------|---------|
| [axe DevTools](https://www.deque.com/axe/devtools/) | Chrome extension for audits |
| [WAVE](https://wave.webaim.org/) | Web accessibility evaluator |
| [Lighthouse](https://developer.chrome.com/docs/lighthouse/) | Built into Chrome DevTools |
| VoiceOver | macOS screen reader (Cmd+F5) |
| NVDA | Free Windows screen reader |

### Quick Keyboard Test

1. Press `Tab` — can you reach all interactive elements?
2. Press `Enter` / `Space` — do buttons and links work?
3. Press `Escape` — do modals close?
4. Press arrow keys — do menus and tabs navigate?
5. Can you see focus at all times?

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Missing alt text | Screen readers say "image" | Add descriptive alt |
| Placeholder as label | Disappears on input | Use real labels |
| Low contrast | Hard to read | Meet 4.5:1 ratio |
| Click handlers on divs | Not keyboard accessible | Use button or link |
| Missing focus styles | Can't see keyboard focus | Keep or enhance focus ring |
| Auto-playing media | Disruptive | Require user interaction |
| Removing outlines | Breaks keyboard navigation | Use `focus-visible` instead |
| Color alone for meaning | Colorblind users miss it | Add icons/text |
| Missing form errors | Users don't know what's wrong | Clear error messages |
| No skip link | Keyboard users stuck in nav | Add skip to main |

---

## Accessibility in shadcn/ui

shadcn/ui is built on Radix UI, which handles many accessibility concerns:

| Component | Built-in A11y |
|-----------|---------------|
| Dialog | Focus trap, Escape to close, aria attributes |
| Dropdown | Keyboard navigation, ARIA roles |
| Tabs | Arrow key navigation, ARIA roles |
| Select | Keyboard navigation, screen reader support |
| Checkbox/Radio | Proper labeling, keyboard support |
| Toast | aria-live announcements |

**Still need to add:**
- Descriptive labels
- Error messages
- Skip links
- Alt text for images
- Custom aria-labels for icon buttons

---

## Quick Reference

### Must Have

- [ ] All images have alt text (or alt="" if decorative)
- [ ] All form inputs have labels
- [ ] Color contrast meets 4.5:1 (text) / 3:1 (UI)
- [ ] All functionality works with keyboard
- [ ] Focus is always visible
- [ ] Page has proper heading hierarchy
- [ ] Errors are clearly communicated
- [ ] No content flashes more than 3 times/second

### Nice to Have

- [ ] Skip link to main content
- [ ] Landmarks (header, nav, main, footer)
- [ ] Reduced motion support
- [ ] Touch targets at least 44x44px

---

*See also: [React](react.md) · [Next.js](nextjs.md) · [Styling & shadcn/ui](styling.md)*
