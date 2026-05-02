# Design System Prompt Template

Use this prompt with Claude Code to generate a complete design system for a new project.

---

## The Prompt

Create a design system called "[Client Name] Design System" with:

1. Color palette
   - Primary, secondary, neutral (keep full scales in tailwind.config.ts)
   - Success, warning, error
   - On the demo page, display only 3-4 key shades per color (e.g., 100, 500, 700, 900)

2. Typography scale with meaningful example text:
   - H1: A tagline or mission statement
   - H2: A section title that might appear in the app
   - H3-H4: Subsection titles
   - Body: A real sentence a user would read
   - Small: Helper text example
   - Show font size, weight, and line-height for each

3. Buttons (primary, secondary, outline)
   - Show all states: default, hover, focus, disabled
   - Show sizes: sm, md, lg

4. Card component
   - Create 2 example cards with realistic content for this product
   - Include header, body, footer with actions

5. Form input
   - Show normal, focused, error, and disabled states
   - Include label, helper text, and error message examples

Context: [Describe the product and brand vibe]

---

## Example Context

"This is a permit management system for city residents. Brand vibe: Modern, trustworthy, slightly warm — government services that don't feel like government."

---

## Output

Claude Code will generate:
- tailwind.config.ts (colors, fonts)
- components/ui/typography.tsx
- components/ui/button.tsx
- components/ui/card.tsx
- components/ui/input.tsx
- app/design-system/page.tsx (demo page)

---

## When to Use

- Design stage: Creating initial design direction
- New project kickoff: Establishing visual language
- Client demos: Showing design capabilities

---
