# Development Standards

*How we build software at Friends Innovation Lab.*

---

## Our Stack

| Layer | Technology | Why |
|-------|------------|-----|
| **Framework** | Next.js 14+ (App Router) | Full-stack React, great DX, Vercel integration |
| **Language** | TypeScript | Type safety, better tooling, fewer bugs |
| **Styling** | Tailwind CSS + shadcn/ui | Utility-first CSS + accessible, customizable components |
| **Database** | Supabase (PostgreSQL) | Managed Postgres, auth, realtime, generous free tier |
| **Hosting** | Vercel | Zero-config deploys, edge functions, preview URLs |
| **AI Coding** | Claude Code | Accelerated development with AI assistance |

### Why shadcn/ui?

- **Not a dependency** — Components are copied into your project, you own the code
- **Accessible by default** — Built on Radix UI primitives
- **Tailwind-native** — Styled with Tailwind, easy to customize
- **Copy what you need** — No bloat, only add components you use

---

## Principles

### 1. Boring Technology

Choose proven tools over shiny new ones. Our clients need reliability, not experiments.

| ✅ Do | ❌ Don't |
|-------|---------|
| Use well-documented libraries | Chase the latest framework |
| Stick to the stack | Add dependencies for one feature |
| Copy patterns that work | Invent new architectures |

### 2. Ship Small, Ship Often

Small changes are easier to review, test, and roll back.

| ✅ Do | ❌ Don't |
|-------|---------|
| One feature per PR | Giant PRs with multiple features |
| Deploy to preview on every PR | Wait until "it's all done" |
| Get feedback early | Big reveal at the end |

### 3. Optimize for Readability

Code is read more than it's written. Future you (and your teammates) will thank you.

| ✅ Do | ❌ Don't |
|-------|---------|
| Clear variable names | Clever one-liners |
| Comments explaining "why" | Comments explaining "what" |
| Consistent patterns | Different approaches per file |

### 4. Fail Gracefully

Things will break. Plan for it.

| ✅ Do | ❌ Don't |
|-------|---------|
| Handle loading states | Show blank screens |
| Show helpful error messages | Show stack traces to users |
| Log errors for debugging | Swallow errors silently |
| Have a rollback plan | YOLO deploy on Friday |

### 5. Secure by Default

Government clients require it. Build the habit now.

| ✅ Do | ❌ Don't |
|-------|---------|
| Validate all inputs | Trust user data |
| Use environment variables | Commit secrets |
| Apply least privilege | Give admin access to everything |
| Enable RLS on all tables | Leave database open |

### 6. Accessible Always

Public sector work must be accessible. It's also just good practice.

| ✅ Do | ❌ Don't |
|-------|---------|
| Semantic HTML | Divs for everything |
| Keyboard navigation | Mouse-only interactions |
| Sufficient color contrast | Light gray on white |
| Test with screen reader | Assume it works |

---

## Project Structure

Standard Next.js App Router structure with shadcn/ui:

```
project-name/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── layout.tsx          # Root layout
│   │   ├── page.tsx            # Home page
│   │   ├── (routes)/           # Route groups
│   │   └── api/                # API routes
│   ├── components/
│   │   ├── ui/                 # shadcn/ui components (Button, Input, Card, etc.)
│   │   └── features/           # Feature-specific components
│   ├── lib/
│   │   ├── supabase.ts         # Supabase client
│   │   ├── utils.ts            # Utility functions (includes shadcn cn() helper)
│   │   └── constants.ts        # App constants
│   ├── hooks/                  # Custom React hooks
│   └── types/                  # TypeScript types
├── public/                     # Static assets
├── docs/                       # Project documentation (PIM deliverables)
├── notes/                      # Internal notes
├── tests/                      # Test files
├── components.json             # shadcn/ui configuration
├── .env.local                  # Local environment variables
├── .env.example                # Example env file (committed)
├── CLAUDE.md                   # AI coding guidelines
└── README.md                   # Project overview
```

---

## File Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Components | PascalCase | `UserProfile.tsx` |
| Utilities | camelCase | `formatDate.ts` |
| Hooks | camelCase with `use` prefix | `useAuth.ts` |
| Types | PascalCase | `User.ts` or in `types/index.ts` |
| API routes | lowercase with hyphens | `api/send-email/route.ts` |
| Pages | lowercase with hyphens | `app/user-profile/page.tsx` |

---

## Environment Variables

### Naming

```bash
# Public (exposed to browser) - prefix with NEXT_PUBLIC_
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_APP_NAME=Project Name

# Private (server-only) - no prefix
SUPABASE_SERVICE_ROLE_KEY=xxx
API_SECRET=xxx
```

### Files

| File | Purpose | Committed? |
|------|---------|------------|
| `.env.local` | Local development secrets | ❌ Never |
| `.env.example` | Template showing required vars | ✅ Yes |
| Vercel dashboard | Production secrets | N/A |

### Rules

1. **Never commit secrets** — `.env.local` is in `.gitignore`
2. **Always have `.env.example`** — Shows what vars are needed
3. **Use descriptive names** — `DATABASE_URL` not `DB`
4. **Document in README** — What each variable is for

---

## Git Workflow

### Branch Naming

```
feature/short-description    # New feature
fix/short-description        # Bug fix
chore/short-description      # Maintenance, deps, config
```

### Commit Messages

```
feat: add user authentication
fix: resolve login redirect loop
chore: update dependencies
docs: add API documentation
style: format code with prettier
refactor: simplify auth logic
test: add unit tests for utils
```

### Pull Request Flow

1. Create branch from `main`
2. Make changes, commit often
3. Push and open PR
4. Vercel creates preview deployment
5. Review (self-review + team if available)
6. Merge to `main`
7. Vercel auto-deploys to production

---

## Code Quality Tools

### Required in Every Project

| Tool | Purpose | Config File |
|------|---------|-------------|
| **TypeScript** | Type checking | `tsconfig.json` |
| **ESLint** | Code linting | `.eslintrc.json` |
| **Prettier** | Code formatting | `.prettierrc` |
| **shadcn/ui** | UI components | `components.json` |

### Recommended

| Tool | Purpose | When to Add |
|------|---------|-------------|
| **Husky** | Git hooks (pre-commit) | When team grows |
| **lint-staged** | Lint only changed files | When team grows |
| **Vitest** | Unit testing | When project has logic |
| **Playwright** | E2E testing | When project has critical flows |

---

## Development Workflow

### Daily

1. Pull latest `main`
2. Create feature branch
3. Build feature
4. Test locally
5. Open PR with preview
6. Self-review
7. Merge

### Before Client Demo

1. Test all critical paths manually
2. Check mobile responsiveness
3. Verify error states
4. Test with slow network (DevTools)
5. Check console for errors
6. Verify cold start is handled

### Before Handoff

1. All tests pass
2. Documentation complete
3. No TODO comments left
4. Environment variables documented
5. Client has access to all systems

---

## Quick Reference

### Start Development

```bash
cd project-name
npm install
npm run dev
# Open http://localhost:3000
```

### Common Commands

```bash
npm run dev          # Start dev server
npm run build        # Production build
npm run start        # Start production server
npm run lint         # Run ESLint
npm run type-check   # Run TypeScript compiler
npm test             # Run tests (if configured)

# shadcn/ui
npx shadcn@latest init          # Initialize shadcn in project
npx shadcn@latest add button    # Add a component
npx shadcn@latest add -a        # Add all components
```

### Useful Links

- [Next.js Docs](https://nextjs.org/docs)
- [shadcn/ui Docs](https://ui.shadcn.com)
- [Tailwind CSS Docs](https://tailwindcss.com/docs)
- [Radix UI Primitives](https://www.radix-ui.com/primitives)
- [Supabase Docs](https://supabase.com/docs)
- [Vercel Docs](https://vercel.com/docs)

---

## Standards Index

| Area | Guide |
|------|-------|
| **Architecture** | [Solutions Architecture](solutions-architecture.md) |
| **Frontend** | [React](frontend/react.md) · [Next.js](frontend/nextjs.md) · [Styling & shadcn/ui](frontend/styling.md) · [Accessibility](frontend/accessibility.md) |
| **Backend** | [API Routes](backend/api.md) · [Database](backend/database.md) · [Auth](backend/auth.md) |
| **Testing** | [Overview](testing/overview.md) · [Unit](testing/unit.md) · [Integration](testing/integration.md) · [E2E](testing/e2e.md) · [QA Checklist](testing/qa-checklist.md) |
| **Quality** | [Code Review](quality/code-review.md) · [Linting](quality/linting.md) · [PR Template](quality/pr-template.md) |
| **Security** | [Secrets](security/secrets.md) · [Validation](security/input-validation.md) · [Compliance](security/compliance.md) |
| **Performance** | [Optimization](performance/optimization.md) · [Cold Start](performance/cold-start.md) · [Monitoring](performance/monitoring.md) |
| **Deployment** | [Environments](deployment/environments.md) · [CI/CD](deployment/ci-cd.md) · [Rollback](deployment/rollback.md) |

---

*These standards apply to all Friends Innovation Lab projects. Project-specific exceptions should be documented in that project's CLAUDE.md.*
