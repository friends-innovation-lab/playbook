# Authentication Standards

*How we handle auth at Friends Innovation Lab.*

---

## Overview

We use **Supabase Auth** for authentication. It provides:

- Email/password authentication
- OAuth providers (Google, GitHub, etc.)
- Magic link (passwordless) login
- Session management with JWTs
- Integration with Row Level Security

---

## Auth Setup

### Install Dependencies

```bash
npm install @supabase/supabase-js @supabase/ssr
```

### Client Setup

See [Database Standards](database.md) for full client setup. Key files:

```
lib/supabase/
├── client.ts    # Browser client
├── server.ts    # Server Component client
└── middleware.ts # Middleware client
```

### Middleware for Session Refresh

```typescript
// middleware.ts (root of project)
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let supabaseResponse = NextResponse.next({
    request,
  })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) =>
            request.cookies.set(name, value)
          )
          supabaseResponse = NextResponse.next({
            request,
          })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  // Refresh session if expired
  await supabase.auth.getUser()

  return supabaseResponse
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
```

---

## Authentication Methods

### Email/Password Sign Up

```typescript
// Client-side
const supabase = createClient()

const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'securepassword123',
  options: {
    data: {
      name: 'John Doe',  // Custom user metadata
    },
    emailRedirectTo: `${window.location.origin}/auth/callback`,
  },
})

if (error) {
  console.error('Sign up error:', error.message)
  return
}

// User needs to verify email before they can sign in
// (if email confirmation is enabled in Supabase dashboard)
```

### Email/Password Sign In

```typescript
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'securepassword123',
})

if (error) {
  console.error('Sign in error:', error.message)
  return
}

// data.user contains the user
// data.session contains the session
```

### Magic Link (Passwordless)

```typescript
const { error } = await supabase.auth.signInWithOtp({
  email: 'user@example.com',
  options: {
    emailRedirectTo: `${window.location.origin}/auth/callback`,
  },
})

// User receives email with login link
```

### OAuth (Google, GitHub, etc.)

```typescript
const { error } = await supabase.auth.signInWithOAuth({
  provider: 'google',  // or 'github', 'azure', etc.
  options: {
    redirectTo: `${window.location.origin}/auth/callback`,
  },
})
```

### Sign Out

```typescript
const { error } = await supabase.auth.signOut()
```

---

## Auth Callback Handler

Handle OAuth and magic link redirects:

```typescript
// app/auth/callback/route.ts
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')
  const next = searchParams.get('next') ?? '/dashboard'

  if (code) {
    const supabase = createClient()
    const { error } = await supabase.auth.exchangeCodeForSession(code)

    if (!error) {
      return NextResponse.redirect(`${origin}${next}`)
    }
  }

  // Auth error - redirect to error page
  return NextResponse.redirect(`${origin}/auth/error`)
}
```

---

## Getting Current User

### In Server Components

```typescript
// app/dashboard/page.tsx
import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'

export default async function DashboardPage() {
  const supabase = createClient()
  const { data: { user }, error } = await supabase.auth.getUser()

  if (!user) {
    redirect('/login')
  }

  return <div>Welcome, {user.email}</div>
}
```

### In Client Components

```typescript
'use client'

import { useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { User } from '@supabase/supabase-js'

export function useUser() {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const supabase = createClient()

  useEffect(() => {
    // Get initial user
    supabase.auth.getUser().then(({ data: { user } }) => {
      setUser(user)
      setLoading(false)
    })

    // Listen for auth changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (event, session) => {
        setUser(session?.user ?? null)
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  return { user, loading }
}
```

### In API Routes

```typescript
// app/api/me/route.ts
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function GET() {
  const supabase = createClient()
  const { data: { user }, error } = await supabase.auth.getUser()

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  return NextResponse.json({ user })
}
```

---

## Protected Routes

### Server Component Protection

```typescript
// app/dashboard/layout.tsx
import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const supabase = createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    redirect('/login')
  }

  return <>{children}</>
}
```

### Middleware Protection

```typescript
// middleware.ts
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

const publicRoutes = ['/', '/login', '/signup', '/auth/callback']
const authRoutes = ['/login', '/signup']

export async function middleware(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          )
          supabaseResponse = NextResponse.next({ request })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  const { data: { user } } = await supabase.auth.getUser()
  const pathname = request.nextUrl.pathname

  // Redirect to login if accessing protected route without auth
  if (!user && !publicRoutes.some(route => pathname.startsWith(route))) {
    const url = request.nextUrl.clone()
    url.pathname = '/login'
    url.searchParams.set('next', pathname)
    return NextResponse.redirect(url)
  }

  // Redirect to dashboard if accessing auth routes while logged in
  if (user && authRoutes.some(route => pathname.startsWith(route))) {
    const url = request.nextUrl.clone()
    url.pathname = '/dashboard'
    return NextResponse.redirect(url)
  }

  return supabaseResponse
}
```

---

## Auth Context Provider

For easy access to auth state across your app:

```typescript
// contexts/auth-context.tsx
'use client'

import { createContext, useContext, useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { User, Session } from '@supabase/supabase-js'

interface AuthContextType {
  user: User | null
  session: Session | null
  loading: boolean
  signOut: () => Promise<void>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)
  const supabase = createClient()

  useEffect(() => {
    // Get initial session
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session)
      setUser(session?.user ?? null)
      setLoading(false)
    })

    // Listen for changes
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (event, session) => {
        setSession(session)
        setUser(session?.user ?? null)
        setLoading(false)
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  const signOut = async () => {
    await supabase.auth.signOut()
  }

  return (
    <AuthContext.Provider value={{ user, session, loading, signOut }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}
```

```typescript
// app/layout.tsx
import { AuthProvider } from '@/contexts/auth-context'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <AuthProvider>
          {children}
        </AuthProvider>
      </body>
    </html>
  )
}
```

```typescript
// Usage in components
'use client'

import { useAuth } from '@/contexts/auth-context'

export function Header() {
  const { user, loading, signOut } = useAuth()

  if (loading) return <Skeleton />

  return (
    <header>
      {user ? (
        <>
          <span>{user.email}</span>
          <Button onClick={signOut}>Sign Out</Button>
        </>
      ) : (
        <Link href="/login">Sign In</Link>
      )}
    </header>
  )
}
```

---

## User Metadata

### Setting Metadata on Sign Up

```typescript
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password',
  options: {
    data: {
      name: 'John Doe',
      role: 'user',
      avatar_url: 'https://...',
    },
  },
})
```

### Updating Metadata

```typescript
const { data, error } = await supabase.auth.updateUser({
  data: {
    name: 'Jane Doe',
    avatar_url: 'https://new-avatar.com',
  },
})
```

### Accessing Metadata

```typescript
const { data: { user } } = await supabase.auth.getUser()

const name = user?.user_metadata?.name
const role = user?.user_metadata?.role
```

---

## User Profiles Table

For more complex user data, create a profiles table:

```sql
-- Create profiles table
create table profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  email text,
  name text,
  avatar_url text,
  role text default 'user' check (role in ('admin', 'user', 'guest')),
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

-- Enable RLS
alter table profiles enable row level security;

-- Policies
create policy "Users can view own profile"
  on profiles for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on profiles for update
  using (auth.uid() = id);

-- Auto-create profile on sign up
create or replace function handle_new_user()
returns trigger as $
begin
  insert into public.profiles (id, email, name, avatar_url)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data->>'name',
    new.raw_user_meta_data->>'avatar_url'
  );
  return new;
end;
$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();
```

### Fetching Profile with User

```typescript
const { data: { user } } = await supabase.auth.getUser()

if (user) {
  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single()
}
```

---

## Password Management

### Password Reset Request

```typescript
const { error } = await supabase.auth.resetPasswordForEmail(
  'user@example.com',
  {
    redirectTo: `${window.location.origin}/auth/reset-password`,
  }
)
```

### Update Password (After Reset)

```typescript
// On the reset-password page, after user clicks link in email
const { error } = await supabase.auth.updateUser({
  password: 'newpassword123',
})
```

### Change Password (While Logged In)

```typescript
const { error } = await supabase.auth.updateUser({
  password: 'newpassword123',
})
```

---

## Email Verification

### Check if Email is Verified

```typescript
const { data: { user } } = await supabase.auth.getUser()

if (user && !user.email_confirmed_at) {
  // Email not verified
  return <VerifyEmailPrompt />
}
```

### Resend Verification Email

```typescript
const { error } = await supabase.auth.resend({
  type: 'signup',
  email: 'user@example.com',
  options: {
    emailRedirectTo: `${window.location.origin}/auth/callback`,
  },
})
```

---

## Role-Based Access Control

### Check Roles in Components

```typescript
'use client'

import { useAuth } from '@/contexts/auth-context'

export function AdminPanel() {
  const { user } = useAuth()
  const role = user?.user_metadata?.role

  if (role !== 'admin') {
    return <div>Access denied</div>
  }

  return <div>Admin content</div>
}
```

### Check Roles in API Routes

```typescript
// app/api/admin/route.ts
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function GET() {
  const supabase = createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  const role = user.user_metadata?.role
  if (role !== 'admin') {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 })
  }

  // Admin-only logic
  return NextResponse.json({ data: 'admin data' })
}
```

### Role-Based RLS Policies

```sql
-- Only admins can delete
create policy "Admins can delete projects"
  on projects for delete
  using (
    (select (raw_user_meta_data->>'role')::text from auth.users where id = auth.uid()) = 'admin'
  );
```

---

## Auth UI Components

### Login Form

```typescript
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'

export function LoginForm() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)
  const router = useRouter()
  const supabase = createClient()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError(null)
    setLoading(true)

    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (error) {
      setError(error.message)
      setLoading(false)
      return
    }

    router.push('/dashboard')
    router.refresh()
  }

  return (
    <Card className="w-full max-w-md">
      <CardHeader>
        <CardTitle>Sign In</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-4">
          {error && (
            <div className="p-3 text-sm text-destructive bg-destructive/10 rounded-md">
              {error}
            </div>
          )}

          <div className="space-y-2">
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="password">Password</Label>
            <Input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>

          <Button type="submit" className="w-full" disabled={loading}>
            {loading ? 'Signing in...' : 'Sign In'}
          </Button>
        </form>
      </CardContent>
    </Card>
  )
}
```

### OAuth Buttons

```typescript
'use client'

import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'

export function OAuthButtons() {
  const supabase = createClient()

  const handleOAuth = async (provider: 'google' | 'github') => {
    await supabase.auth.signInWithOAuth({
      provider,
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
      },
    })
  }

  return (
    <div className="space-y-2">
      <Button
        variant="outline"
        className="w-full"
        onClick={() => handleOAuth('google')}
      >
        Continue with Google
      </Button>
      <Button
        variant="outline"
        className="w-full"
        onClick={() => handleOAuth('github')}
      >
        Continue with GitHub
      </Button>
    </div>
  )
}
```

---

## Session Management

### Session Lifetime

Configure in Supabase Dashboard → Auth → Settings:

- **JWT expiry**: How long until token expires (default: 3600s / 1 hour)
- **Refresh token rotation**: Enable for security
- **Refresh token reuse interval**: Grace period for reuse

### Manually Refresh Session

```typescript
const { data, error } = await supabase.auth.refreshSession()
```

### Get Current Session

```typescript
const { data: { session } } = await supabase.auth.getSession()

if (session) {
  const accessToken = session.access_token
  const expiresAt = session.expires_at
}
```

---

## Security Best Practices

### 1. Always Use `getUser()` for Auth Checks

```typescript
// ✅ Server-side - validates with Supabase Auth server
const { data: { user } } = await supabase.auth.getUser()

// ⚠️ Client-side only - reads from local storage, can be spoofed
const { data: { session } } = await supabase.auth.getSession()
```

### 2. Validate on the Server

Never trust client-side auth state for sensitive operations:

```typescript
// API route - always validate
export async function POST(request: Request) {
  const supabase = createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  // Now safe to proceed
}
```

### 3. Use RLS

Don't rely solely on application code for data access control:

```sql
-- Even if app code has bugs, RLS protects data
alter table projects enable row level security;

create policy "Users can only access own projects"
  on projects for all
  using (auth.uid() = user_id);
```

### 4. Secure Redirects

Validate redirect URLs to prevent open redirect attacks:

```typescript
const allowedRedirects = ['/dashboard', '/settings', '/projects']

const next = searchParams.get('next') ?? '/dashboard'
const safeNext = allowedRedirects.includes(next) ? next : '/dashboard'

return NextResponse.redirect(`${origin}${safeNext}`)
```

### 5. HTTPS Only

Ensure cookies are secure in production:

```typescript
// Supabase handles this, but for custom cookies:
cookieStore.set('token', value, {
  httpOnly: true,
  secure: process.env.NODE_ENV === 'production',
  sameSite: 'lax',
})
```

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Using `getSession()` for auth checks | Can be spoofed client-side | Use `getUser()` on server |
| No middleware session refresh | Sessions expire unexpectedly | Add middleware to refresh |
| Hardcoded redirect URLs | Breaks in different environments | Use `window.location.origin` |
| No email verification | Fake signups | Enable email confirmation |
| Storing roles only in metadata | Can be manipulated | Use profiles table + RLS |
| No loading states | Flash of wrong content | Show loading skeleton |
| Not handling auth errors | Poor UX | Display error messages |

---

## Quick Reference

### Auth Methods

```typescript
// Sign up
supabase.auth.signUp({ email, password })

// Sign in
supabase.auth.signInWithPassword({ email, password })
supabase.auth.signInWithOtp({ email })
supabase.auth.signInWithOAuth({ provider: 'google' })

// Sign out
supabase.auth.signOut()

// Get user (server-validated)
supabase.auth.getUser()

// Get session (local)
supabase.auth.getSession()

// Update user
supabase.auth.updateUser({ data: { name: '...' } })
supabase.auth.updateUser({ password: '...' })

// Password reset
supabase.auth.resetPasswordForEmail(email)

// Listen for changes
supabase.auth.onAuthStateChange((event, session) => { ... })
```

### Auth Events

```typescript
supabase.auth.onAuthStateChange((event, session) => {
  // event can be:
  // 'INITIAL_SESSION' - Initial load
  // 'SIGNED_IN' - User signed in
  // 'SIGNED_OUT' - User signed out
  // 'TOKEN_REFRESHED' - Token was refreshed
  // 'USER_UPDATED' - User data changed
  // 'PASSWORD_RECOVERY' - Password reset initiated
})
```

---

*See also: [API Routes](api.md) · [Database](database.md)*
