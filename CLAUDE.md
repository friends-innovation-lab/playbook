# Friends Innovation Lab - Playbook Standards

> This file defines how Claude Code should work on Friends Innovation Lab projects.
> It includes code standards, review personas, and quality gates.

---

## Project Context

This is a **Friends Innovation Lab** playbook. We build fast, high-quality prototypes for small businesses and government agencies. Our standards:

- **Speed matters** — We ship in weeks, not months
- **Quality matters more** — Clients judge us on first impressions
- **Government-ready** — Even small business projects follow federal best practices
- **Founder-built** — No hand-offs to junior devs. Every line of code matters.

---

## Code Standards

### Tech Stack
- **Framework**: Next.js 14+ (App Router)
- **Language**: TypeScript (strict mode)
- **Styling**: Tailwind CSS
- **Database**: Supabase (PostgreSQL)
- **Hosting**: Vercel
- **Components**: shadcn/ui preferred

### File Structure
```
app/
├── (auth)/           # Auth-required routes
├── (public)/         # Public routes
├── api/              # API routes (use sparingly)
├── layout.tsx
└── page.tsx          # Must be static (no server redirects!)

components/
├── ui/               # shadcn/ui components
├── forms/            # Form components
├── layouts/          # Layout components
└── [feature]/        # Feature-specific components

lib/
├── api.ts            # All API calls
├── supabase.ts       # Supabase client
├── utils.ts          # Utility functions
└── types.ts          # TypeScript types

hooks/                # Custom React hooks
context/              # React context providers
```

### Critical Rules

1. **No server-side redirects on landing pages**
   ```typescript
   // ❌ NEVER do this - causes cold start delays
   import { redirect } from 'next/navigation'
   export default function Page() { redirect('/login') }

   // ✅ Use next.config.js redirects instead (edge, instant)
   ```

2. **Lazy-load API calls** — Don't fetch data until the user needs it

3. **Type everything** — No `any` types without a comment explaining why

4. **Error states are required** — Every data fetch needs loading, error, and empty states

5. **Mobile-first** — All layouts must work on 375px width

---

## Review Council

When asked to review code, UI, or features, evaluate from these perspectives:

### 🎯 Product Manager
- Does this meet the stated requirements?
- What edge cases are unhandled?
- Is this the MVP or are we over-engineering?
- What would make the client say "wow"?
- What would make the client complain?
- Is this shippable for a demo tomorrow?

### 💼 Business Analyst
- Does this solve the user's actual problem?
- What assumptions are we making about user behavior?
- Is there a simpler way to achieve the same outcome?
- What's the ROI of this feature vs. effort to build it?

### 🔬 UX Researcher
- What user need does this address?
- What research or evidence supports this design decision?
- What assumptions are we making that we should validate?
- Who are the edge-case users we might be forgetting?
- What would a usability test reveal?

### 🧭 UX Designer
- Can a user complete their goal in 3 clicks or less?
- Is the information architecture intuitive?
- Are there unnecessary friction points?
- Is the cognitive load reasonable?
- Are error messages helpful and actionable?
- Does the flow match user mental models?

### 🎨 UI Designer
- Is the visual hierarchy clear? (What do you see first, second, third?)
- Are spacing and alignment consistent?
- Does typography guide the eye appropriately?
- Are interactive elements obviously clickable/tappable?
- Is there appropriate use of color for meaning?
- Does this feel polished or rushed?
- Is it consistent with the rest of the app?

### ♿ Accessibility Specialist
- Does this meet WCAG 2.1 AA standards?
- Is color contrast sufficient (4.5:1 for text)?
- Can this be navigated with keyboard only?
- Are there appropriate ARIA labels?
- Do focus states exist and make sense?
- Will this work with a screen reader?
- Are touch targets at least 44x44px?

### 💻 Frontend Developer
- Is the code clean and maintainable?
- Are components appropriately sized (not too big, not too granular)?
- Is state management appropriate for the complexity?
- Are there performance concerns? (re-renders, bundle size)
- Is this following React/Next.js best practices?
- Would a new developer understand this code?

### 🏗️ Solutions Architect
- Is this the right technical approach for the problem?
- Will this scale if usage grows 10x?
- Are we creating technical debt we'll regret?
- How does this integrate with existing systems?
- Are there simpler alternatives we should consider?

### 🔧 DevOps Engineer
- Will this deploy cleanly?
- Are there cold start concerns?
- Is error logging/monitoring in place?
- Are environment variables handled correctly?
- Is this secure in production?

### 🔒 Security Reviewer
- Is authentication/authorization handled correctly?
- Is user input validated and sanitized?
- Are there any data exposure risks?
- Is sensitive data encrypted/protected?
- Would this pass a basic penetration test?

### 🧪 QA Tester
- What happens if the user does something unexpected?
- What if the API is slow or fails?
- What if the user has no data yet (empty states)?
- What if the user has tons of data (pagination, performance)?
- What happens on slow/offline connections?
- Have all the happy paths been tested?
- Have all the sad paths been tested?

### 📝 Technical Writer
- Is this feature documented?
- Could someone else maintain this code?
- Are complex functions commented?
- Is the README up to date?
- Would a handoff to another team be smooth?

### 🤝 Client Success Manager
- Will the client understand how to use this?
- What questions will they ask?
- Does this look professional enough for a client demo?
- What will impress them? What might disappoint them?
- Is there anything that needs explanation before they see it?

---

## Government-Specific Reviews

When building for government clients, also consider:

### 📋 Contracting Officer Perspective
- Does this align with the Statement of Work?
- Are there any scope creep concerns?
- Would this raise questions during a contract review?
- Is the deliverable clearly defined?

### 🏛️ Federal User Advocate
- Government employees have specific constraints (older browsers, locked-down machines)
- They may have limited tech savviness
- They're risk-averse — anything confusing will get escalated
- They need to justify their decisions to supervisors

### 🛡️ ATO/Compliance Reviewer
- Is this FedRAMP-ready (or on a path to it)?
- Does it meet Section 508 accessibility requirements?
- Is there an audit trail for sensitive actions?
- How is PII handled?
- Is the data residency appropriate?

---

## Review Commands

Use these commands to trigger specific reviews:

### Full Council Review
```
Review this as the full council. I want perspectives from: PM, UX Designer,
UI Designer, Accessibility, Frontend Dev, and QA. Be critical — this is
going to a client.
```

### Quick Design Review
```
Review this UI as a designer council: UX Designer, UI Designer, and
Accessibility Specialist. Focus on what would make a user frustrated.
```

### Code Review
```
Review this code as: Frontend Developer, Solutions Architect, and Security
Reviewer. Flag anything that would embarrass us in a code review.
```

### Pre-Demo Review
```
Review this as if the client demo is in 1 hour. What would make us look
bad? What would make us look great? Prioritize the fixes.
```

### Government Compliance Review
```
Review this for government readiness: Accessibility Specialist, Security
Reviewer, and ATO Compliance. What would block us from shipping to a
federal client?
```

---

## Quality Gates

Before marking any feature complete:

### Must Have (Blocking)
- [ ] No TypeScript errors
- [ ] No console errors in browser
- [ ] Works on mobile (375px)
- [ ] Loading states for all async operations
- [ ] Error states for all async operations
- [ ] Empty states where applicable
- [ ] Basic keyboard navigation works

### Should Have (Pre-Demo)
- [ ] Passes Lighthouse accessibility audit (90+)
- [ ] No obvious UI jank or layout shifts
- [ ] Copy is proofread (no lorem ipsum, no typos)
- [ ] All links work
- [ ] Tested in Chrome and Safari

### Nice to Have (Polish)
- [ ] Smooth animations/transitions
- [ ] Optimistic UI updates
- [ ] Thoughtful micro-interactions
- [ ] Dark mode support (if applicable)

---

## Playbook Navigation

- **Methodology**: See `methodology/` for PIM phases
- **Operations**: See `operations/` for project management
- **Development**: See `development/` for technical standards

---

*Last updated: February 2025*
