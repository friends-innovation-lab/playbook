# Starter Prompt — Research Tool

Use for: participant management, note-taking, research synthesis,
user research operations. Core pattern for Qori-adjacent work.

---

## Prompt

```
Read CLAUDE.md. I'm building a research operations tool.

Stack: Next.js 14 App Router, TypeScript, Tailwind CSS, shadcn/ui,
Supabase, React Query. Follow all standards in CLAUDE.md.

Build the following:

1. PARTICIPANT MANAGEMENT
   - List view of research participants with status (recruited, scheduled,
     completed, declined)
   - Add participant form: name, email, phone, recruitment source, notes
   - Participant detail page showing all sessions and notes for that person
   - Status can be updated inline from the list

2. SESSION NOTES
   - Each participant can have multiple research sessions
   - Session record: date, duration, facilitator, notes (rich text),
     tags, and a rating (1–5)
   - Notes editor: simple textarea with markdown support — use a basic
     markdown renderer, nothing complex
   - Tags are free-form and shared across the project

3. SYNTHESIS VIEW
   - A separate view listing all tags used across all sessions
   - Clicking a tag shows all session notes that use that tag
   - This is the basic synthesis pattern — finding themes across sessions

4. SEARCH
   - Global search across participant names and session notes
   - Results show which participant and session the match came from

5. DATA
   - Tables: participants, sessions, tags, session_tags (junction)
   - RLS on all tables — users see only their project's data
   - React Query for all data fetching

Run npm run check when done. All must pass.
```
