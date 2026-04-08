# Starter Prompt — Scheduling

Use for: appointment booking, resource scheduling, facility reservations,
callback scheduling.

---

## Prompt

```
Read CLAUDE.md. I'm building a scheduling/appointment booking tool.

Stack: Next.js 14 App Router, TypeScript, Tailwind CSS, shadcn/ui,
Supabase. Follow all standards in CLAUDE.md.

Build the following:

1. DATE PICKER
   - Calendar view showing available dates
   - Unavailable dates are visually dimmed and not selectable
   - Current date highlighted
   - Month navigation with previous/next
   - Mobile-friendly touch targets on date cells

2. TIME SLOT SELECTION
   - After selecting a date, show available time slots in a grid
   - Slots show the time and duration
   - Selected slot highlighted with fftc-yellow
   - Unavailable/booked slots clearly marked
   - Timezone displayed and adjustable

3. CONFIRMATION SCREEN
   - Summary of selected date, time, location (if applicable), and purpose
   - Edit buttons to go back and change selections
   - Confirm button to finalize booking
   - After confirmation: reference number, calendar export (.ics download),
     and option to add to Google Calendar
   - Email confirmation sent via Resend if RESEND_API_KEY is configured

4. CANCELLATION FLOW
   - Cancel button on the confirmation/detail screen
   - Cancellation reason dropdown (optional)
   - Confirm cancellation with clear warning
   - Slot becomes available again after cancellation

5. REMINDER PREFERENCES
   - Toggle for email reminders (24 hours before, 1 hour before)
   - Toggle for SMS reminders (if phone number on file)
   - Preferences saved to Supabase per user

6. DATA
   - Supabase tables: available_slots (id, date, start_time, end_time,
     location, capacity, booked_count), appointments (id, user_id,
     slot_id, status, purpose, reference_number, created_at, cancelled_at,
     cancel_reason), reminder_preferences (id, user_id, email_24h,
     email_1h, sms_24h)
   - Seed with 2 weeks of available slots
   - RLS: users can only view/modify their own appointments,
     public read on available_slots

7. ACCESSIBILITY
   - Calendar uses role="grid" with proper aria-labels on each cell
   - Selected date announced via aria-live
   - Time slots use radio group semantics
   - All interactive elements keyboard navigable
   - Touch targets minimum 44x44px

8. MOBILE
   - Calendar fits within 375px without horizontal scroll
   - Time slots stack in a single column
   - Confirmation screen is scrollable single column
   - Tap-to-add-to-calendar works on iOS and Android

Run npm run check when done. All must pass.
```

## Customizing after generation

After CC builds the shell, tell CC:
```
Now configure the scheduling for [describe your specific use case].
Update slot durations, locations, and purpose categories. Keep all
the calendar, confirmation, cancellation, and accessibility logic.
```
