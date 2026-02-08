# Cold Start Prevention

*How we keep demos fast at Friends Innovation Lab.*

---

## Why This Matters

Cold starts happen when a serverless function or edge function hasn't been used recently. The platform spins up a new instance, causing delays of 1-5+ seconds.

**For client demos, this is unacceptable.** A slow first load undermines credibility.

---

## Our Strategy

1. **Edge-based warming** — Redirect through edge function that pings backend
2. **External monitoring** — UptimeRobot pings every 5 minutes
3. **Optimized serverless** — Minimize cold start duration

---

## Implementation

### 1. Edge Redirect with Warming

Create a middleware that warms the backend on every request:

```typescript
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  // Fire warming request (don't await)
  fetch(`${request.nextUrl.origin}/api/health`, {
    method: 'HEAD',
  }).catch(() => {})  // Ignore errors

  return NextResponse.next()
}

export const config = {
  // Run on all pages except static assets
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
```

### 2. Health Check Endpoint

```typescript
// app/api/health/route.ts
import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export const runtime = 'edge'  // Fast edge function
export const dynamic = 'force-dynamic'  // Never cache

export async function GET() {
  const start = Date.now()

  // Quick database ping
  try {
    const supabase = createClient()
    await supabase.from('_health').select('1').limit(1).maybeSingle()
  } catch {
    // Table might not exist, that's okay
  }

  return NextResponse.json({
    status: 'ok',
    latency: Date.now() - start,
    timestamp: new Date().toISOString(),
  })
}

export async function HEAD() {
  return new NextResponse(null, { status: 200 })
}
```

### 3. Vercel Configuration

```json
// vercel.json
{
  "functions": {
    "app/api/**/*.ts": {
      "maxDuration": 10
    }
  },
  "crons": [
    {
      "path": "/api/health",
      "schedule": "*/5 * * * *"
    }
  ]
}
```

**Note:** Vercel cron jobs require Pro plan. Use UptimeRobot as alternative.

### 4. UptimeRobot Setup

1. Go to [UptimeRobot](https://uptimerobot.com/)
2. Create free account
3. Add monitor:
   - **Monitor Type:** HTTP(s)
   - **URL:** `https://your-app.vercel.app/api/health`
   - **Monitoring Interval:** 5 minutes
4. Repeat for each deployed app

---

## Supabase Connection Warming

Supabase connections can also go cold. Keep them warm:

```typescript
// app/api/health/route.ts
import { createClient } from '@/lib/supabase/server'

export async function GET() {
  const supabase = createClient()

  // Simple query to warm connection pool
  const { error } = await supabase
    .from('profiles')  // Use a small, indexed table
    .select('id')
    .limit(1)

  return NextResponse.json({
    status: error ? 'degraded' : 'ok',
    database: error ? 'cold' : 'warm',
  })
}
```

### Create Health Table (Optional)

For cleaner separation:

```sql
-- migrations/create_health_table.sql
CREATE TABLE IF NOT EXISTS _health (
  id INT PRIMARY KEY DEFAULT 1,
  updated_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO _health (id) VALUES (1) ON CONFLICT DO NOTHING;

-- Index for fast lookup
CREATE INDEX IF NOT EXISTS idx_health_id ON _health(id);
```

---

## Pre-Demo Checklist

### 30 Minutes Before Demo

- [ ] Visit the app yourself (triggers warm-up)
- [ ] Navigate through key pages
- [ ] Check UptimeRobot shows "Up"
- [ ] Test any heavy operations (reports, exports)

### 5 Minutes Before Demo

- [ ] Refresh the app
- [ ] Open DevTools Network tab
- [ ] Verify fast load times (< 2s)
- [ ] Close other browser tabs (memory)

### During Demo

- [ ] Don't mention "loading" or "warming up"
- [ ] Have backup screenshots ready
- [ ] If slow, narrate while loading

---

## Reducing Cold Start Duration

Even with warming, minimize cold start time:

### 1. Minimize Dependencies

```typescript
// ❌ Heavy imports at top level
import { everything } from 'massive-library'

// ✅ Dynamic import when needed
export async function POST(request: Request) {
  const { specificFunction } = await import('massive-library')
  return specificFunction(request)
}
```

### 2. Use Edge Runtime

```typescript
// app/api/fast/route.ts
export const runtime = 'edge'  // Faster cold starts than Node.js

export async function GET() {
  return Response.json({ fast: true })
}
```

Edge runtime limitations:
- No Node.js APIs (fs, path, etc.)
- Limited npm package support
- 1MB bundle size limit

### 3. Lazy Initialize Heavy Clients

```typescript
// ❌ Initialize on module load
const heavyClient = new HeavySDK({ apiKey: process.env.API_KEY })

export async function GET() {
  return heavyClient.doThing()
}

// ✅ Initialize on first use
let heavyClient: HeavySDK | null = null

function getClient() {
  if (!heavyClient) {
    heavyClient = new HeavySDK({ apiKey: process.env.API_KEY })
  }
  return heavyClient
}

export async function GET() {
  return getClient().doThing()
}
```

### 4. Optimize Bundle Size

```bash
# Check function size
npx @vercel/nft print ./app/api/heavy/route.ts
```

Keep serverless functions small:
- Extract shared code to edge middleware
- Use dynamic imports
- Remove unused dependencies

---

## Monitoring Cold Starts

### Log Cold Starts

```typescript
// lib/cold-start.ts
let isWarm = false

export function logColdStart(route: string) {
  if (!isWarm) {
    console.log(`[COLD START] ${route} - ${new Date().toISOString()}`)
    isWarm = true
  }
}

// In API route
import { logColdStart } from '@/lib/cold-start'

export async function GET() {
  logColdStart('/api/data')
  // ...
}
```

### Track in Analytics

```typescript
export async function GET() {
  const start = Date.now()

  // Do work...

  const duration = Date.now() - start

  // Log slow responses (likely cold starts)
  if (duration > 1000) {
    console.warn(`Slow response: ${duration}ms`)
    // Send to analytics
  }

  return NextResponse.json({ data })
}
```

---

## Architecture for Demos

### Critical Demo Paths

Identify and optimize the exact flow you'll demo:

```
1. Landing page (/)
2. Login (/login)
3. Dashboard (/dashboard)
4. Key feature (/dashboard/feature)
5. Results (/dashboard/feature/results)
```

Ensure each has:
- Fast server component rendering
- Warmed database connections
- Cached static assets

### Pre-Render Demo Data

For demos, consider pre-rendering with real-looking data:

```typescript
// app/dashboard/page.tsx
export default async function Dashboard() {
  const data = await getCachedDemoData()  // Pre-computed
  return <DashboardView data={data} />
}

// lib/demo-data.ts
import { unstable_cache } from 'next/cache'

export const getCachedDemoData = unstable_cache(
  async () => {
    return await fetchDemoData()
  },
  ['demo-data'],
  { revalidate: 3600 }  // Cache 1 hour
)
```

---

## Fallback Strategies

### Optimistic UI

Show UI immediately, load data in background:

```tsx
'use client'

export function Dashboard() {
  const [data, setData] = useState(SKELETON_DATA)  // Show skeleton

  useEffect(() => {
    fetchRealData().then(setData)
  }, [])

  return <DashboardView data={data} />
}
```

### Streaming

Show parts of page as they load:

```tsx
import { Suspense } from 'react'

export default function Page() {
  return (
    <div>
      <Header />  {/* Immediate */}

      <Suspense fallback={<ChartSkeleton />}>
        <SlowChart />  {/* Streams in */}
      </Suspense>
    </div>
  )
}
```

---

## Quick Setup for New Projects

### 1. Add Health Endpoint

```typescript
// app/api/health/route.ts
export const runtime = 'edge'
export const dynamic = 'force-dynamic'

export async function GET() {
  return Response.json({ status: 'ok', time: Date.now() })
}

export async function HEAD() {
  return new Response(null, { status: 200 })
}
```

### 2. Add Middleware Warming

```typescript
// middleware.ts
import { NextResponse } from 'next/server'

export function middleware(request) {
  fetch(`${request.nextUrl.origin}/api/health`, { method: 'HEAD' }).catch(() => {})
  return NextResponse.next()
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
}
```

### 3. Set Up UptimeRobot

- URL: `https://your-app.vercel.app/api/health`
- Interval: 5 minutes
- Alert: Email on down

### 4. Pre-Demo Ritual

```bash
# Quick script to warm up
curl -I https://your-app.vercel.app/api/health
curl -I https://your-app.vercel.app/
curl -I https://your-app.vercel.app/dashboard
```

---

## Checklist

### Project Setup

- [ ] Health endpoint created
- [ ] Middleware warming added
- [ ] UptimeRobot configured
- [ ] Demo paths identified

### Before Deploy

- [ ] Bundle size checked
- [ ] Heavy imports made dynamic
- [ ] Edge runtime where possible

### Before Demo

- [ ] Manually warm the app
- [ ] Check monitoring shows "Up"
- [ ] Test full demo flow
- [ ] Have backup plan ready

---

*See also: [Performance Optimization](optimization.md) · [Monitoring](monitoring.md)*
