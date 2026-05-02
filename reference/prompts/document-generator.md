# Starter Prompt — Document Generator

Use for: tools that take structured inputs and produce formatted document
output. Core pattern for Truebid-adjacent work and government document
generation (SOWs, reports, estimates).

---

## Prompt

```
Read CLAUDE.md. I'm building a document generator.

Stack: Next.js 14 App Router, TypeScript, Tailwind CSS, shadcn/ui,
Supabase, React Query. Follow all standards in CLAUDE.md.

Build the following:

1. INPUT FORM
   - Multi-section form (not multi-step — all sections visible, each collapsible)
   - Section 1: Document metadata (title, date, prepared by, version)
   - Section 2: Primary inputs (3 placeholder fields — these will be replaced)
   - Section 3: Additional details (notes, assumptions, attachments placeholder)
   - Auto-save to Supabase as the user types (debounced, 2 seconds)
   - "Last saved" timestamp shown near the top

2. DOCUMENT PREVIEW
   - Split-pane layout: form on left, live preview on right
   - Preview updates in real time as the user types
   - Preview is formatted as a professional document:
     - Header with title, date, version
     - Sections with proper headings
     - Clean typography, ready to print or export
   - On mobile: tabs to switch between form and preview

3. EXPORT
   - "Export as PDF" button — uses browser print to PDF
   - "Copy as text" button — copies the document content as plain text
   - Saved documents list — all previously generated documents for this user

4. DATA
   - Table: documents (id, created_at, updated_at, title, inputs jsonb,
     user_id)
   - RLS — users see only their own documents

Run npm run check when done. All must pass.
```
