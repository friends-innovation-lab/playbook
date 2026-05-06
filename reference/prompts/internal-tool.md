# Starter Prompt — Internal Tool

Use for: FFTC admin panels, internal workflows, team dashboards,
anything that helps the lab or FFTC operate more efficiently.

---

## Prompt

```
Read CLAUDE.md. I'm building an internal tool for the FFTC team.

Stack: Next.js 14 App Router, TypeScript, Tailwind CSS, shadcn/ui,
Supabase, React Query. Follow all standards in CLAUDE.md.

This is an internal tool — users are FFTC team members, not clients
or the public. Build with that in mind: functional over fancy,
efficient over polished.

Build the following:

1. AUTH
   - Use the existing auth from the template
   - Add a simple role system: admin and member
   - Admins can see all data, members see only their own
   - Role is set in the profiles table

2. CORE FEATURE SHELL
   - Dashboard home with a summary of key information
   - A primary list view for the main data entity
   - Create/edit form for that entity
   - Basic search and filter

3. DATA
   - Create a placeholder table called `items` with: id, created_at,
     title, description, status, owner_id
   - RLS based on role: admins see all, members see their own

4. NAVIGATION
   - Keep it simple — sidebar with Dashboard and the primary entity
   - No complex nested navigation

Run npm run check when done. All must pass.
```
