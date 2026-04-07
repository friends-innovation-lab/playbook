# Design System

The visual foundation for every project the lab builds.

## Stack

Every project uses the same design stack:
- **Tailwind CSS** — utility-first styling
- **shadcn/ui** — component library built on Radix UI
- **FFTC design tokens** — colors, typography, spacing defined in `tailwind.config.ts`

This means every project starts from the same visual baseline.
Builders don't make color or typography decisions from scratch.

---

## Colors

Defined as CSS variables in `globals.css` and as Tailwind tokens in
`tailwind.config.ts`. Two palettes:

### Brand (primary actions, links, active states)
Built on indigo/purple — professional, modern, distinct from generic blue.

```
brand-500   #6366f1   Primary buttons, active nav, links
brand-600   #4f46e5   Button hover states
brand-700   #4338ca   Pressed states
```

### Government neutral (backgrounds, borders, text)
Slate-based — clean, readable, appropriate for government interfaces.

```
gov-50    #f8fafc   Page backgrounds
gov-100   #f1f5f9   Card backgrounds
gov-200   #e2e8f0   Borders
gov-400   #94a3b8   Placeholder text
gov-600   #475569   Secondary text
gov-800   #1e293b   Primary text
gov-900   #0f172a   Headings
```

### Status colors
```
success   #16a34a   Success states, confirmed actions
warning   #d97706   Warnings, attention needed
error     #dc2626   Errors, destructive actions
info      #0284c7   Informational
```

All color combinations used in the UI must meet WCAG 2.1 AA contrast
ratio (4.5:1 for normal text, 3:1 for large text).

---

## Accessibility and Color Usage

Not all FFTC brand color combinations meet WCAG 2.1 AA contrast
requirements. Follow these rules on every project — no exceptions
for government client work.

### What passes

| Combination | Contrast Ratio | Use for |
|---|---|---|
| fftc-black on fftc-white | 19.5:1 ✓ | Body text, headings |
| fftc-black on fftc-yellow | 12.6:1 ✓ | Button text, labels on yellow |
| fftc-white on fftc-black | 19.5:1 ✓ | Reversed text, dark headers |
| gov-900 on gov-50 | 16.2:1 ✓ | Body text on light backgrounds |
| gov-800 on gov-100 | 10.4:1 ✓ | Secondary text on cards |

### What fails — never use these

| Combination | Contrast Ratio | Problem |
|---|---|---|
| fftc-yellow on fftc-white | 1.8:1 ✗ | Yellow text on white fails badly |
| fftc-yellow on gov-50 | 1.7:1 ✗ | Yellow text on off-white fails |
| gov-400 on gov-50 | 2.9:1 ✗ | Placeholder text too light |

### Rules for buttons

- **Primary yellow button** — always use fftc-black text on fftc-yellow background ✓
- **Primary black button** — always use fftc-white text on fftc-black background ✓
- **Never** put yellow text on a white or light background

### Rules for secondary colors

The secondary colors (orange, pink, green, blue, red) are for
accents, badges, and category indicators — not for body text.
Always pair them with fftc-black or fftc-white text, never with
each other or on light backgrounds without checking contrast.

### How to check contrast

Use the free tool at **webaim.org/resources/contrastchecker** —
paste in any two hex values and it will tell you the ratio and
whether it passes AA or AAA.

---

## Typography

**Primary font:** Inter (loaded via `next/font/google`)
**Monospace font:** JetBrains Mono (for code, keys, technical labels)

Font scale defined in Tailwind — use standard classes (`text-sm`,
`text-base`, `text-lg`, etc.). Do not use arbitrary font sizes.

---

## Components

All UI components come from **shadcn/ui**. These are already installed
in every project spun up from the template:

avatar, badge, button, card, dialog, dropdown-menu, form, input, label,
navigation-menu, select, separator, sheet, skeleton, table, tabs,
textarea, toast, tooltip

Browse the full component API at **ui.shadcn.com**

To add a component not already installed:
```bash
npx shadcn@latest add [component-name]
```

---

## Shared components

Every project also includes these custom shared components in
`src/components/shared/`:

| Component | When to use |
|---|---|
| `EmptyState` | When a list or data view has no items |
| `ErrorState` | When a data fetch fails |
| `LoadingSkeleton` | While data is loading |
| `PageHeader` | Top of every dashboard page |
| `DataTable` | Any tabular data display |

Always use these before building something new. They handle
accessibility, loading, and error states correctly by default.

---

## Government prototype considerations

When building for a government client or procurement challenge:

- Use conservative, professional color choices — not playful or trendy
- Every form field must have a visible label (not just a placeholder)
- All interactive elements must be keyboard navigable
- Touch targets must be at least 44x44px
- Never rely on color alone to convey meaning (use icons or text too)
- Test on a real mobile device before any demo

---

## Phase 2 — Figma design system (coming)

A Figma component library that mirrors this code system 1:1 is in
development. When complete, designs will use the same tokens as the
code, meaning a color change in Figma will propagate to the live app.

Status: Phase 2 of the lab roadmap.
