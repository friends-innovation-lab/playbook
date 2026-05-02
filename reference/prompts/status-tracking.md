# Starter Prompt — Status Tracking

Use for: application status, claim tracking, permit status, anything
where a user submitted something and needs to see where it stands.

---

## Prompt

```
Read CLAUDE.md. I'm building a status tracking tool.

Stack: Next.js 14 App Router, TypeScript, Tailwind CSS, shadcn/ui,
Supabase. Follow all standards in CLAUDE.md.

Build the following:

1. STATUS TIMELINE
   - Vertical stepper showing all stages of the process
   - Current step highlighted with fftc-yellow accent
   - Completed steps show a checkmark
   - Future steps are dimmed but visible so the user knows what comes next
   - Each step shows: step name, date completed (or estimated), brief description

2. CURRENT STEP DETAIL
   - Expanded view of the current step at the top of the page
   - What is happening now (plain language explanation)
   - What the user needs to do (if anything) — clearly called out
   - Estimated timeline for this step
   - Who to contact if there is a problem

3. APPLICATION SUMMARY
   - Reference number prominently displayed
   - Submission date
   - Key details from the original submission (name, type, etc.)
   - Link to view full submission details

4. NOTIFICATIONS
   - Toggle for email notifications when status changes
   - Toggle for SMS notifications (if phone number on file)
   - Notification preferences saved to Supabase
   - Show last notification sent with timestamp

5. DATA
   - Supabase tables: applications (id, user_id, reference_number, type,
     status, submitted_at, data), application_steps (id, application_id,
     step_name, step_order, status, completed_at, estimated_at, description)
   - Seed with 3 sample applications at different stages
   - RLS: users can only view their own applications

6. ACCESSIBILITY
   - Timeline uses aria-current="step" on the active step
   - Step status communicated via both color and text/icon
   - All interactive elements keyboard navigable
   - Status changes use aria-live="polite" for screen readers
   - Touch targets minimum 44x44px

7. MOBILE
   - Timeline switches to compact vertical layout at 375px
   - Current step detail is always visible without scrolling
   - Reference number easy to copy on mobile

Run npm run check when done. All must pass.
```

## Customizing after generation

After CC builds the shell, tell CC:
```
Now replace the placeholder steps with the actual stages for
[describe your specific process]. Update field names and labels.
Keep all the timeline, notification, and accessibility logic.
```
