# Starter Prompt — Dashboard

Use for: program management views, data reporting, administrative panels,
anything where a user needs to see, filter, and act on a list of records.

---

## Prompt

```
Read CLAUDE.md. I'm building a data dashboard.

Stack: Next.js 14 App Router, TypeScript, Tailwind CSS, shadcn/ui,
Supabase, React Query, TanStack Table. Follow all standards in CLAUDE.md.

Build the following:

1. DASHBOARD LAYOUT
   - Use the existing sidebar and header from src/components/layout/
   - Main content area with a PageHeader component at the top
   - Summary metrics row: 3–4 stat cards showing key numbers
   - Below metrics: a data table taking up the rest of the page

2. DATA TABLE
   - Use the DataTable component from src/components/shared/
   - Columns: include a checkbox column, at least 4 data columns,
     and an actions column with a dropdown menu
   - Sorting on all data columns
   - Search/filter bar above the table
   - Pagination at the bottom (10 rows default, options for 25 and 50)
   - Row click opens a detail view (slide-over sheet, not a new page)

3. DATA
   - Create a placeholder Supabase table called `records`
   - Include these fields: id, created_at, title, status, owner, metadata (jsonb)
   - RLS enabled — users see only their own records
   - Fetch data using React Query with proper loading and error states
   - Optimistic updates when status changes

4. EMPTY AND LOADING STATES
   - Empty state: EmptyState component with a call-to-action to create
     the first record
   - Loading state: table skeleton while data fetches
   - Error state: ErrorState component with a retry button

5. ACCESSIBILITY
   - Table uses proper semantic markup with scope on headers
   - Sortable columns announce sort direction to screen readers
   - All actions are keyboard accessible
   - Status badges use icons in addition to color

Run npm run check when done. All must pass.
```
