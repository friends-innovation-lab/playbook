# Starter Prompt — Form Tool

Use for: multi-step intake forms, eligibility screening, application tools,
survey instruments, data collection for government workflows.

---

## Prompt

```
Read CLAUDE.md. I'm building a multi-step form tool.

Stack: Next.js 14 App Router, TypeScript, Tailwind CSS, shadcn/ui,
Supabase, react-hook-form, zod. Follow all standards in CLAUDE.md.

Build the following:

1. FORM SHELL
   - Multi-step form with progress indicator showing step X of Y
   - Each step is a separate component in src/components/forms/steps/
   - Navigation: Back and Next buttons. Next is disabled until current
     step validates. Final step has a Submit button.
   - Progress saves to Supabase as the user moves through steps so
     they can return to where they left off
   - Mobile-first layout — single column on 375px, comfortable on desktop

2. STEP STRUCTURE
   Create three placeholder steps as a starting point:
   - Step 1: Personal information (name, email, phone)
   - Step 2: Primary question set (3 placeholder fields)
   - Step 3: Review and confirm (summary of all answers before submit)

3. VALIDATION
   - All fields use zod schemas defined in src/lib/validations/
   - Inline error messages using accessible aria-describedby pattern
   - No field should submit blank without a clear error message

4. SUBMISSION
   - On submit, save complete form data to a Supabase table
   - Table name: form_submissions
   - RLS: users can only read their own submissions
   - Show a success confirmation screen after submit
   - Success screen includes a reference number (use Supabase row ID)
   - Email confirmation via Resend if RESEND_API_KEY is configured

5. ACCESSIBILITY
   - Every field has a visible label (not just a placeholder)
   - Error messages are announced to screen readers via role="alert"
   - Focus moves to the first field of each new step automatically
   - All interactive elements are keyboard navigable
   - Touch targets are minimum 44x44px

6. STATES REQUIRED
   - Loading state while submitting
   - Error state if submission fails (with retry option)
   - Success state after submission
   - Empty/start state on first load

Run npm run check when done. All must pass.
```

## Customizing after generation

After CC builds the shell, tell CC:
```
Now replace the placeholder steps with the actual form fields for
[describe your specific form]. Keep all the validation, accessibility,
and submission logic. Only change the fields and labels.
```
