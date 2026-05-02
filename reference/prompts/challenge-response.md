# Starter Prompt — Government Challenge Response

Use for: federal procurement challenge responses where a working
prototype must be submitted and demo-ready within a tight timeline.

This prompt is more opinionated than others because challenge responses
have specific requirements: they must look real, work end-to-end, be
accessible, and be defensible under evaluator scrutiny.

---

## Pre-prompt checklist

Before running this prompt, have answers to:
- What is the challenge asking for? (one sentence)
- Who is the end user? (e.g. veterans, case workers, program managers)
- What is the primary user action? (e.g. submit an application, view a report)
- What agency is this for?
- What is the demo date?

---

## Prompt

```
Read CLAUDE.md. I'm building a prototype for a government procurement challenge.

Challenge: [paste challenge description or your one-sentence summary]
End user: [who uses this]
Primary action: [what the user does]
Agency: [which agency]
Demo date: [date]

Stack: Next.js 14 App Router, TypeScript, Tailwind CSS, shadcn/ui,
Supabase. Follow all standards in CLAUDE.md.
Reference the project Storybook for component variants and states:
https://storybook.[name].lab.cityfriends.tech
(Replace [name] with the actual project name)

VISUAL INTENT

Reference Storybook component stories for exact variant and
state implementations before building any UI.

This prototype must look bold and high contrast — not safe or generic.
Landing page: fftc-black (#0D0D0D) background, white headline,
yellow (#FFD230) CTA button with black text.
App pages (forms, steps, results): fftc-white (#FEFAF1) warm
off-white background, fftc-black text.
Headers: always full-width fftc-black on every screen.
Progress indicators: fftc-yellow.
Selected/active states: fftc-yellow border and tint.
Read the Visual Design Rules in CLAUDE.md before building any UI.

This prototype will be evaluated by a federal panel. Every detail matters.
Build the following:

1. LANDING PAGE
   - Professional, clean landing page that explains what this tool does
   - Clear call-to-action to get started or sign in
   - Appropriate for a government context — no playful copy, no clip art
   - Agency context should be visible (reference the agency name)
   - "Built by Friends Innovation Lab for [Agency]" in the footer

2. CORE USER FLOW (3–5 screens)
   - Build the complete primary user flow end to end
   - Every screen must work — no placeholder "coming soon" states
   - Flow should be completable in under 3 minutes
   - Show a meaningful result or confirmation at the end

3. AUTHENTICATION
   - Email/password login and signup
   - Demo credentials must work: demo@example.gov / Demo1234!
   - New signups work too

4. DATA
   - Real data saves to Supabase — nothing is faked
   - RLS on all tables
   - If the prototype collects form data, it must actually save and be
     retrievable

5. ACCESSIBILITY — NON-NEGOTIABLE
   - Run npm run test:a11y — zero violations before done
   - Every form field has a visible label
   - All interactive elements are keyboard navigable
   - Color contrast meets 4.5:1 on all text
   - Focus states are visible

6. MOBILE
   - Must work on iPhone 12 screen size (390px)
   - Test every screen at 375px before declaring done

7. POLISH
   - No lorem ipsum anywhere
   - No console errors in browser
   - Loading states on all data operations
   - Meaningful error messages if something fails
   - Consistent spacing and alignment throughout

Run npm run check and npm run test:a11y when done. Both must pass.
```

## After CC builds the shell

```
Do a pre-demo review as the full Review Council. The demo is in
[X days]. What would make us look bad in front of a federal evaluation
panel? What would make us stand out? List everything, prioritized.
```
