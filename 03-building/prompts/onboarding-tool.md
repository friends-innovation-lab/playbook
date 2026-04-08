# Starter Prompt — Onboarding Tool

Use for: employee onboarding, program participant onboarding, training
completion tracking, certification requirements.

---

## Prompt

```
Read CLAUDE.md. I'm building an onboarding/training tracking tool.

Stack: Next.js 14 App Router, TypeScript, Tailwind CSS, shadcn/ui,
Supabase. Follow all standards in CLAUDE.md.

Build the following:

1. TASK CHECKLIST
   - List of onboarding tasks grouped by category (e.g. paperwork,
     training, access requests, orientation)
   - Progress ring or bar at the top showing overall completion percentage
   - Each task shows: name, category, due date, status (not started /
     in progress / complete), required vs optional badge
   - Clicking a task expands to show description, instructions, and
     any links or attachments needed

2. TASK DETAIL
   - Expanded task view with full instructions
   - "Mark as complete" button with confirmation
   - Upload field for tasks requiring documentation
   - Notes field for the participant
   - Due date with visual urgency (overdue = red, due soon = yellow)

3. PROGRESS DASHBOARD
   - Participant view: their own progress with completion states
   - Manager/admin view: table of all participants with progress bars,
     overdue count, and last activity date
   - Filter by: status, department, start date
   - Export to CSV for reporting

4. DATA
   - Supabase tables: onboarding_tasks (id, title, description, category,
     instructions, due_offset_days, is_required, sort_order),
     participant_progress (id, user_id, task_id, status, completed_at,
     notes, file_url)
   - Seed with 12+ realistic onboarding tasks across 3 categories
   - RLS: participants see their own progress, admins see all

5. ACCESSIBILITY
   - Checklist uses role="list" with checkbox semantics
   - Progress ring has aria-label with percentage
   - Completion state communicated via both icon and text
   - All interactive elements keyboard navigable
   - Touch targets minimum 44x44px

6. MOBILE
   - Single column layout at 375px
   - Progress ring stays visible at top
   - Task expansion works inline without navigation
   - Manager table switches to card layout on mobile

Run npm run check when done. All must pass.
```

## Customizing after generation

After CC builds the shell, tell CC:
```
Now replace the sample tasks with the actual onboarding steps for
[describe your specific program]. Update categories, due dates,
and required/optional flags. Keep all the progress tracking,
admin view, and accessibility logic.
```
