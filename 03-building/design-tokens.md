# Design Tokens

Design tokens are the single source of truth for all visual values
in the system — colors, typography, spacing, and border radius.
They live in tokens.json in every project and feed directly into
Tailwind CSS.

---

## What tokens.json is

Every project spun up from the template includes a tokens.json
file in the root. This file contains all FFTC brand values in a
standard format. Tailwind reads from this file instead of
hardcoded values — so changing a token value in tokens.json
automatically updates every component that uses it on the next build.

---

## Current FFTC tokens

### Primary colors
- fftc/yellow — #FFD230 — Primary CTAs, active states, progress bars
- fftc/black — #0D0D0D — Headers, primary text, dark backgrounds
- fftc/white — #FEFAF1 — Page backgrounds, reversed text

### Secondary colors (NYC subway inspired)
- secondary/orange — #FF6A00
- secondary/pink — #FC4FAC
- secondary/green — #58DF55
- secondary/blue — #1E72EF
- secondary/red — #FA3C2F

### Government neutral scale
- gov/50 through gov/950 — Slate-based neutral scale for
  government-appropriate backgrounds, borders, and text

### Status colors
- status/success — #16a34a
- status/warning — #d97706
- status/error — #dc2626
- status/info — #0284c7

### Typography
- font/sans — Helvetica Neue, Helvetica, Arial, sans-serif
- font/mono — JetBrains Mono, monospace

### Border radius
- radius/sm — 4px
- radius/default — 8px
- radius/lg — 12px
- radius/xl — 16px
- radius/full — 9999px

---

## How to update a token

Open tokens.json in the project root and change the value directly:
```json
"fftc": {
  "yellow": { "value": "#FFD230", "type": "color" }
}
```

Change the hex value, save the file, and rebuild. Every component
that uses fftc-yellow will update automatically.

> [!IMPORTANT]
> After changing tokens.json, also update the matching variable
> in the Figma Tokens file so the design system stays in sync.
> Figma Tokens file:
> https://www.figma.com/design/MgWiTmboj3YSTUK8xRKzRt/Tokens

---

## Adding a new token

Add it to tokens.json following the same structure:
```json
"fftc": {
  "yellow": { "value": "#FFD230", "type": "color" },
  "new-color": { "value": "#HEXVALUE", "type": "color" }
}
```

Then add it to tailwind.config.ts:
```typescript
'fftc-new-color': tokens.fftc['new-color'].value,
```

Then add it as a variable in the Figma Tokens file.

---

## Coming next

### Tokens Studio (automation layer)
When Tokens Studio is configured with GitHub sync, tokens.json
will be updated automatically when a designer changes values in
Figma. The manual update process above will no longer be needed.
The tokens.json file is already structured in the format Tokens
Studio expects — connecting the plugin is the only remaining step.

### Agency token sets
The token system is designed to support multiple agencies. When
building a prototype for a specific agency — VA, HHS, CMS — an
agency-specific token set can be applied that overrides the FFTC
brand tokens with the agency's colors and typography. The prototype
instantly looks like it belongs in that agency's ecosystem without
any code changes.

Agency token sets are coming. Ask Lapedra about the timeline.
