# Next.js Standards

*How we use Next.js at Friends Innovation Lab.*

---

## App Router (Not Pages)

We use the **App Router** (Next.js 13+), not the legacy Pages Router.

```
src/app/                    # ✅ App Router
src/pages/                  # ❌ Don't use
```

---

## Routing

### File-Based Routing

| File | URL | Purpose |
|------|-----|---------|
| `app/page.tsx` | `/` | Home page |
| `app/about/page.tsx` | `/about` | About page |
| `app/users/page.tsx` | `/users` | Users list |
| `app/users/[id]/page.tsx` | `/users/123` | User detail (dynamic) |
| `app/users/[id]/edit/page.tsx` | `/users/123/edit` | Edit user |

### Route Groups

Use `(folder)` to organize without affecting URL.

```
app/
├── (marketing)/           # Group - doesn't appear in URL
│   ├── page.tsx           # /
│   ├── about/page.tsx     # /about
│   └── pricing/page.tsx   # /pricing
├── (dashboard)/           # Group
│   ├── layout.tsx         # Shared dashboard layout
│   ├── projects/page.tsx  # /projects
│   └── settings/page.tsx  # /settings
└── (auth)/                # Group
    ├── login/page.tsx     # /login
    └── signup/page.tsx    # /signup
```

### Dynamic Routes

```tsx
// app/users/[id]/page.tsx
interface Props {
  params: { id: string }
}

export default function UserPage({ params }: Props) {
  return <div>User ID: {params.id}</div>
}
```

### Catch-All Routes

```tsx
// app/docs/[...slug]/page.tsx
// Matches /docs/a, /docs/a/b, /docs/a/b/c

interface Props {
  params: { slug: string[] }
}

export default function DocsPage({ params }: Props) {
  // /docs/getting-started/intro → slug = ['getting-started', 'intro']
  return <div>{params.slug.join(' / ')}</div>
}
```

---

## Special Files

| File | Purpose |
|------|---------|
| `page.tsx` | UI for a route (required for route to be accessible) |
| `layout.tsx` | Shared UI that wraps children |
| `loading.tsx` | Loading UI (Suspense fallback) |
| `error.tsx` | Error UI (Error Boundary) |
| `not-found.tsx` | 404 UI |
| `route.ts` | API endpoint |

### Layout

Layouts wrap child pages and persist across navigation.

```tsx
// app/layout.tsx (Root layout - required)
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata = {
  title: 'My App',
  description: 'App description',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <Header />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  )
}
```

### Loading

Automatic loading state with Suspense.

```tsx
// app/dashboard/loading.tsx
import { Skeleton } from '@/components/ui/skeleton'

export default function Loading() {
  return (
    <div className="space-y-4">
      <Skeleton className="h-8 w-48" />
      <Skeleton className="h-32 w-full" />
    </div>
  )
}
```

### Error

Automatic error boundary.

```tsx
// app/dashboard/error.tsx
'use client'

import { Button } from '@/components/ui/button'

export default function Error({
  error,
  reset,
}: {
  error: Error
  reset: () => void
}) {
  return (
    <div className="p-4">
      <h2>Something went wrong</h2>
      <p>{error.message}</p>
      <Button onClick={reset}>Try again</Button>
    </div>
  )
}
```

### Not Found

Custom 404 page.

```tsx
// app/not-found.tsx
import Link from 'next/link'
import { Button } from '@/components/ui/button'

export default function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <h1 className="text-4xl font-bold">404</h1>
      <p className="mt-2 text-muted-foreground">Page not found</p>
      <Button asChild className="mt-4">
        <Link href="/">Go home</Link>
      </Button>
    </div>
  )
}
```

---

## Server vs Client Components

### Default: Server Components

Components are Server Components by default. They:
- Run on the server only
- Can directly fetch data
- Can access backend resources
- Cannot use hooks or browser APIs

```tsx
// This is a Server Component (default)
async function UserList() {
  const users = await db.users.findMany() // Direct DB access

  return (
    <ul>
      {users.map(user => <li key={user.id}>{user.name}</li>)}
    </ul>
  )
}
```

### Client Components

Add `'use client'` directive for:
- Interactivity (onClick, onChange)
- Hooks (useState, useEffect)
- Browser APIs (localStorage, window)

```tsx
'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'

export function Counter() {
  const [count, setCount] = useState(0)

  return (
    <Button onClick={() => setCount(c => c + 1)}>
      Count: {count}
    </Button>
  )
}
```

### When to Use Each

| Server Component | Client Component |
|------------------|------------------|
| Fetch data | User interactions |
| Access backend | useState, useEffect |
| Render static content | Browser APIs |
| Keep secrets secure | Event listeners |
| Reduce JS bundle | Real-time updates |

### Pattern: Server Parent, Client Child

Keep data fetching in Server Components, pass to Client Components.

```tsx
// app/users/page.tsx (Server Component)
import { UserList } from './UserList'

export default async function UsersPage() {
  const users = await getUsers() // Server-side fetch

  return <UserList users={users} /> // Pass to client
}

// app/users/UserList.tsx (Client Component)
'use client'

import { useState } from 'react'

export function UserList({ users }: { users: User[] }) {
  const [filter, setFilter] = useState('')

  const filtered = users.filter(u => u.name.includes(filter))

  return (
    <>
      <input value={filter} onChange={e => setFilter(e.target.value)} />
      <ul>
        {filtered.map(user => <li key={user.id}>{user.name}</li>)}
      </ul>
    </>
  )
}
```

---

## Data Fetching

### Server Components (Preferred)

Fetch directly in Server Components. No useEffect needed.

```tsx
// app/users/page.tsx
async function getUsers() {
  const res = await fetch('https://api.example.com/users', {
    cache: 'no-store', // Always fresh
  })
  return res.json()
}

export default async function UsersPage() {
  const users = await getUsers()

  return <UserList users={users} />
}
```

### Caching Options

```tsx
// Always fetch fresh (no cache)
fetch(url, { cache: 'no-store' })

// Cache indefinitely (default)
fetch(url, { cache: 'force-cache' })

// Revalidate every 60 seconds
fetch(url, { next: { revalidate: 60 } })
```

### With Supabase

```tsx
// lib/supabase/server.ts
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export function createClient() {
  const cookieStore = cookies()

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) => {
            cookieStore.set(name, value, options)
          })
        },
      },
    }
  )
}

// app/users/page.tsx
import { createClient } from '@/lib/supabase/server'

export default async function UsersPage() {
  const supabase = createClient()
  const { data: users } = await supabase.from('users').select()

  return <UserList users={users} />
}
```

### Client-Side Fetching

For real-time or user-triggered fetches, use client components with SWR or React Query.

```tsx
'use client'

import useSWR from 'swr'

const fetcher = (url: string) => fetch(url).then(r => r.json())

export function UserList() {
  const { data, error, isLoading } = useSWR('/api/users', fetcher)

  if (isLoading) return <Skeleton />
  if (error) return <Error message={error.message} />

  return <ul>{data.map(user => <li key={user.id}>{user.name}</li>)}</ul>
}
```

---

## API Routes

### Basic API Route

```tsx
// app/api/users/route.ts
import { NextResponse } from 'next/server'

export async function GET() {
  const users = await db.users.findMany()
  return NextResponse.json(users)
}

export async function POST(request: Request) {
  const body = await request.json()
  const user = await db.users.create({ data: body })
  return NextResponse.json(user, { status: 201 })
}
```

### Dynamic API Route

```tsx
// app/api/users/[id]/route.ts
import { NextResponse } from 'next/server'

export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  const user = await db.users.findUnique({ where: { id: params.id } })

  if (!user) {
    return NextResponse.json({ error: 'Not found' }, { status: 404 })
  }

  return NextResponse.json(user)
}

export async function DELETE(
  request: Request,
  { params }: { params: { id: string } }
) {
  await db.users.delete({ where: { id: params.id } })
  return new NextResponse(null, { status: 204 })
}
```

### Error Handling

```tsx
// app/api/users/route.ts
import { NextResponse } from 'next/server'

export async function POST(request: Request) {
  try {
    const body = await request.json()

    // Validation
    if (!body.email) {
      return NextResponse.json(
        { error: 'Email is required' },
        { status: 400 }
      )
    }

    const user = await db.users.create({ data: body })
    return NextResponse.json(user, { status: 201 })

  } catch (error) {
    console.error('Failed to create user:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}
```

---

## Navigation

### Link Component

Always use `Link` for internal navigation.

```tsx
import Link from 'next/link'

// Basic
<Link href="/about">About</Link>

// With dynamic route
<Link href={`/users/${user.id}`}>View Profile</Link>

// With shadcn Button
import { Button } from '@/components/ui/button'

<Button asChild>
  <Link href="/dashboard">Go to Dashboard</Link>
</Button>
```

### useRouter (Client Components)

For programmatic navigation.

```tsx
'use client'

import { useRouter } from 'next/navigation'

export function LoginForm() {
  const router = useRouter()

  const handleSubmit = async () => {
    await login()
    router.push('/dashboard')     // Navigate
    router.replace('/dashboard')  // Navigate without history entry
    router.refresh()              // Refresh current route
    router.back()                 // Go back
  }
}
```

### usePathname / useSearchParams

```tsx
'use client'

import { usePathname, useSearchParams } from 'next/navigation'

export function NavLink({ href, children }: { href: string; children: React.ReactNode }) {
  const pathname = usePathname()
  const isActive = pathname === href

  return (
    <Link href={href} className={isActive ? 'text-primary' : ''}>
      {children}
    </Link>
  )
}

export function SearchFilter() {
  const searchParams = useSearchParams()
  const query = searchParams.get('q') // ?q=hello → 'hello'
}
```

---

## Metadata

### Static Metadata

```tsx
// app/about/page.tsx
import { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'About Us',
  description: 'Learn about our company',
}

export default function AboutPage() {
  return <div>About content</div>
}
```

### Dynamic Metadata

```tsx
// app/users/[id]/page.tsx
import { Metadata } from 'next'

interface Props {
  params: { id: string }
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const user = await getUser(params.id)

  return {
    title: user.name,
    description: `Profile of ${user.name}`,
  }
}

export default function UserPage({ params }: Props) {
  // ...
}
```

### Root Metadata Template

```tsx
// app/layout.tsx
import { Metadata } from 'next'

export const metadata: Metadata = {
  title: {
    template: '%s | My App',  // Pages can override
    default: 'My App',
  },
  description: 'App description',
}
```

---

## Images

Use the `Image` component for optimization.

```tsx
import Image from 'next/image'

// Local image
<Image
  src="/hero.jpg"
  alt="Hero image"
  width={800}
  height={400}
  priority  // Load immediately (above the fold)
/>

// Remote image (must configure domain in next.config.js)
<Image
  src="https://example.com/photo.jpg"
  alt="Photo"
  width={400}
  height={300}
/>

// Fill container
<div className="relative h-64 w-full">
  <Image
    src="/background.jpg"
    alt="Background"
    fill
    className="object-cover"
  />
</div>
```

### Configure Remote Images

```js
// next.config.js
module.exports = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'example.com',
      },
      {
        protocol: 'https',
        hostname: '*.supabase.co',
      },
    ],
  },
}
```

---

## Environment Variables

```bash
# .env.local

# Public (available in browser)
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_APP_NAME=My App

# Private (server only)
SUPABASE_SERVICE_ROLE_KEY=secret
DATABASE_URL=postgres://...
```

Access in code:

```tsx
// Client or Server
const url = process.env.NEXT_PUBLIC_SUPABASE_URL

// Server only (API routes, Server Components)
const secret = process.env.SUPABASE_SERVICE_ROLE_KEY
```

---

## Middleware

Run code before requests are completed.

```tsx
// middleware.ts (root of project)
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  // Check auth
  const token = request.cookies.get('token')

  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/dashboard/:path*', '/settings/:path*'],
}
```

---

## Common Patterns

### Protected Routes

```tsx
// middleware.ts
import { createMiddlewareClient } from '@supabase/auth-helpers-nextjs'
import { NextResponse } from 'next/server'

export async function middleware(req: NextRequest) {
  const res = NextResponse.next()
  const supabase = createMiddlewareClient({ req, res })
  const { data: { session } } = await supabase.auth.getSession()

  if (!session && req.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', req.url))
  }

  return res
}
```

### Redirect After Action

```tsx
// app/actions.ts
'use server'

import { redirect } from 'next/navigation'

export async function createProject(formData: FormData) {
  const project = await db.projects.create({
    data: { name: formData.get('name') as string }
  })

  redirect(`/projects/${project.id}`)
}
```

### Parallel Data Fetching

```tsx
// app/dashboard/page.tsx
export default async function DashboardPage() {
  // Fetch in parallel, not sequentially
  const [user, projects, stats] = await Promise.all([
    getUser(),
    getProjects(),
    getStats(),
  ])

  return (
    <>
      <UserCard user={user} />
      <ProjectList projects={projects} />
      <StatsCard stats={stats} />
    </>
  )
}
```

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| `'use client'` everywhere | Larger JS bundle | Only where needed |
| Using `<a>` instead of `Link` | Full page reload | Use `Link` component |
| Fetching in useEffect | Waterfalls, loading states | Fetch in Server Components |
| Not handling loading states | Blank screens | Add `loading.tsx` |
| Not handling errors | Crashes | Add `error.tsx` |
| Forgetting `key` in lists | React warnings, bugs | Always add unique keys |
| `window` in Server Component | Build error | Check `typeof window` or use client component |

---

*See also: [React](react.md) · [Styling & shadcn/ui](styling.md) · [Accessibility](accessibility.md)*
