# Starter Prompt — Facility Finder

Use for: location-based search tools, VA facility finder, provider lookup,
program site locators, service center directories.

---

## Prompt

```
Read CLAUDE.md. I'm building a facility/provider finder tool.

Stack: Next.js 14 App Router, TypeScript, Tailwind CSS, shadcn/ui,
Supabase, React Query. Follow all standards in CLAUDE.md.

Build the following:

1. SEARCH INTERFACE
   - Search input with location detection (zip code, city, or "use my location")
   - Filter panel: distance radius (5/10/25/50 miles), facility type,
     services offered, availability
   - Filters collapse into a sheet on mobile
   - Search results update as filters change (no separate submit button)

2. RESULTS LIST
   - Card-based results list showing: facility name, address, distance,
     key services, hours, phone number
   - Sort by: distance (default), name, rating
   - Pagination or infinite scroll for large result sets
   - "No results" empty state with suggestions to broaden search
   - Loading skeleton while results fetch

3. FACILITY DETAIL PAGE
   - Dynamic route: /facilities/[id]
   - Full facility information: name, address, phone, hours, services,
     accessibility features, directions link
   - "Get Directions" button that opens native maps app
   - Back to results button that preserves search state
   - Related facilities section at bottom

4. DATA
   - Supabase table: facilities (id, name, address, city, state, zip,
     lat, lng, phone, hours, services, facility_type, created_at)
   - Seed with 20+ realistic sample facilities
   - RLS: public read access, admin write
   - Full-text search on name, address, services

5. ACCESSIBILITY
   - Results list uses role="list" with meaningful aria-labels
   - Each result card is keyboard navigable
   - Distance and filter changes announced to screen readers via aria-live
   - Map alternative: all information available without map interaction
   - Touch targets minimum 44x44px

6. MOBILE
   - Single column layout at 375px
   - Filters in a bottom sheet or collapsible panel
   - Results cards stack vertically
   - Tap-to-call on phone numbers

Run npm run check when done. All must pass.
```

## Customizing after generation

After CC builds the shell, tell CC:
```
Now replace the sample facilities with [describe your specific
facility type]. Update the filter categories and detail fields
to match. Keep all the search, accessibility, and mobile logic.
```
