# Agency Theming

Every project is built on the FFTC brand by default. When building
a prototype for a specific government agency, an agency token set
can be applied that overrides the visual layer to match the agency's
design system. The prototype looks like it belongs in their ecosystem
without any structural code changes.

---

## How it works

When you run the spinup script and select a government project type,
it asks which agency the prototype is for. Based on your answer it
sets NEXT_PUBLIC_AGENCY_THEME in your environment. Every color,
font, and CTA style then reads from the agency's token set instead
of the FFTC brand tokens.

Available themes:

| Theme | Agency | Primary color |
|---|---|---|
| fftc | Default — FFTC brand | #FFD230 yellow |
| va | Department of Veterans Affairs | #003e73 dark blue |
| cms | Centers for Medicare and Medicaid Services | #0071bc blue |
| uswds | USWDS baseline — HHS, GSA, other federal | #005EA2 blue |

---

## Switching themes manually

To change the agency theme on an existing project, update
NEXT_PUBLIC_AGENCY_THEME in .env.local:

```
NEXT_PUBLIC_AGENCY_THEME=va
```

Then restart the dev server:

```
npm run dev
```

To deploy with a different theme, update the environment variable
in Vercel and redeploy.

---

## Previewing themes in Storybook

The Storybook toolbar has a theme switcher. Click the paintbrush
icon in the top toolbar and select any agency to preview all
components in that agency's visual context.

This is useful for:
- Showing a client their familiar design language
- Checking component accessibility in agency colors
- Demoing the same prototype in multiple agency contexts

---

## Using agency colors in code

When building a component that should respond to the active agency
theme, use the agency CSS variables instead of hardcoded FFTC values:

```css
/* Responds to active agency theme */
background-color: var(--agency-cta);
color: var(--agency-cta-text);

/* Always FFTC brand regardless of theme */
background-color: #FFD230;
```

Or use the Tailwind classes:

```
bg-agency-cta text-agency-cta-text
```

---

## Adding a new agency

If a new agency is needed, add it in four places:

1. Create tokens.[agency].json in the project template root
2. Add the theme to src/lib/tokens.ts
3. Add it to .storybook/themes/index.ts
4. Add it as an option in the spinup script agency question

Ask Lapedra before adding new agency themes.

---

## Token sources

Agency token values are drawn from publicly documented design systems:
- USWDS: designsystem.digital.gov/design-tokens
- VA Design System: design.va.gov/foundation/design-tokens
- CMS Design System: design.cms.gov

When building for a specific agency challenge, verify current token
values against their official documentation before submitting.
