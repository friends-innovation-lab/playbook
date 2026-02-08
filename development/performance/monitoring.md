# Monitoring & Error Tracking

*How we know when things break at Friends Innovation Lab.*

---

## Overview

Monitoring tells us:
1. **Is the app up?** — Uptime monitoring
2. **Are there errors?** — Error tracking
3. **Is it fast?** — Performance monitoring
4. **What's happening?** — Logging

---

## Uptime Monitoring

### UptimeRobot (Free Tier)

We use UptimeRobot for basic uptime monitoring.

**Setup:**
1. Create account at [uptimerobot.com](https://uptimerobot.com/)
2. Add monitor for each environment:
   - Production: `https://app.example.com/api/health`
   - Staging: `https://staging.app.example.com/api/health`

**Settings:**
- Monitor Type: HTTP(s)
- Monitoring Interval: 5 minutes
- Alert Contacts: Team email/Slack

### Health Endpoint

```typescript
// app/api/health/route.ts
import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export const dynamic = 'force-dynamic'

export async function GET() {
  const checks: Record<string, 'ok' | 'error'> = {}

  // Check database
  try {
    const supabase = createClient()
    await supabase.from('profiles').select('id').limit(1)
    checks.database = 'ok'
  } catch {
    checks.database = 'error'
  }

  // Check external services (if any)
  // try {
  //   await fetch('https://api.stripe.com/v1/health')
  //   checks.stripe = 'ok'
  // } catch {
  //   checks.stripe = 'error'
  // }

  const allHealthy = Object.values(checks).every(v => v === 'ok')

  return NextResponse.json(
    {
      status: allHealthy ? 'healthy' : 'degraded',
      checks,
      timestamp: new Date().toISOString(),
    },
    { status: allHealthy ? 200 : 503 }
  )
}
```

### Status Page (Optional)

For client-facing status, consider:
- [Instatus](https://instatus.com/) (free tier)
- [Statuspage](https://www.atlassian.com/software/statuspage)
- Simple static page with UptimeRobot widget

---

## Error Tracking

### Sentry (Recommended)

Sentry captures errors with full context.

**Install:**

```bash
npx @sentry/wizard@latest -i nextjs
```

**Configuration:**

```typescript
// sentry.client.config.ts
import * as Sentry from '@sentry/nextjs'

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,

  // Performance
  tracesSampleRate: 0.1,  // 10% of transactions

  // Only in production
  enabled: process.env.NODE_ENV === 'production',

  // Ignore common non-errors
  ignoreErrors: [
    'ResizeObserver loop limit exceeded',
    'Non-Error promise rejection captured',
  ],
})
```

```typescript
// sentry.server.config.ts
import * as Sentry from '@sentry/nextjs'

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  tracesSampleRate: 0.1,
  enabled: process.env.NODE_ENV === 'production',
})
```

```typescript
// sentry.edge.config.ts
import * as Sentry from '@sentry/nextjs'

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  tracesSampleRate: 0.1,
  enabled: process.env.NODE_ENV === 'production',
})
```

**Capture Custom Errors:**

```typescript
import * as Sentry from '@sentry/nextjs'

try {
  await riskyOperation()
} catch (error) {
  Sentry.captureException(error, {
    tags: {
      feature: 'checkout',
      userId: user.id,
    },
    extra: {
      orderId: order.id,
      amount: order.total,
    },
  })
  throw error  // Re-throw if needed
}
```

**Add User Context:**

```typescript
// After login
Sentry.setUser({
  id: user.id,
  email: user.email,
})

// After logout
Sentry.setUser(null)
```

### Simple Error Logging (No Sentry)

If not using Sentry, at minimum log to console:

```typescript
// lib/error.ts
export function logError(error: Error, context?: Record<string, unknown>) {
  console.error('[ERROR]', {
    message: error.message,
    stack: error.stack,
    ...context,
    timestamp: new Date().toISOString(),
  })
}

// Usage
try {
  await operation()
} catch (error) {
  logError(error as Error, { userId: user.id, action: 'checkout' })
}
```

Vercel captures console.error in the Logs tab.

---

## Performance Monitoring

### Vercel Analytics

Built into Vercel, easy setup:

```tsx
// app/layout.tsx
import { Analytics } from '@vercel/analytics/react'
import { SpeedInsights } from '@vercel/speed-insights/next'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  )
}
```

Tracks:
- Core Web Vitals (LCP, FID, CLS)
- Page views
- Custom events

### Custom Performance Marks

```typescript
// Track specific operations
export async function fetchDashboardData() {
  const start = performance.now()

  const data = await fetch('/api/dashboard')

  const duration = performance.now() - start

  // Log slow requests
  if (duration > 2000) {
    console.warn(`Slow dashboard fetch: ${duration.toFixed(0)}ms`)
  }

  // Send to analytics
  if (typeof window !== 'undefined' && window.va) {
    window.va('event', {
      name: 'api_latency',
      data: { route: '/api/dashboard', duration },
    })
  }

  return data
}
```

---

## Logging

### Structured Logging

```typescript
// lib/logger.ts
type LogLevel = 'debug' | 'info' | 'warn' | 'error'

interface LogEntry {
  level: LogLevel
  message: string
  timestamp: string
  [key: string]: unknown
}

function log(level: LogLevel, message: string, data?: Record<string, unknown>) {
  const entry: LogEntry = {
    level,
    message,
    timestamp: new Date().toISOString(),
    ...data,
  }

  const output = JSON.stringify(entry)

  switch (level) {
    case 'error':
      console.error(output)
      break
    case 'warn':
      console.warn(output)
      break
    default:
      console.log(output)
  }
}

export const logger = {
  debug: (msg: string, data?: Record<string, unknown>) => log('debug', msg, data),
  info: (msg: string, data?: Record<string, unknown>) => log('info', msg, data),
  warn: (msg: string, data?: Record<string, unknown>) => log('warn', msg, data),
  error: (msg: string, data?: Record<string, unknown>) => log('error', msg, data),
}

// Usage
logger.info('User logged in', { userId: user.id, method: 'google' })
logger.error('Payment failed', { userId: user.id, error: error.message })
```

### What to Log

| Log | Don't Log |
|-----|-----------|
| Authentication events | Passwords |
| API errors | Full credit card numbers |
| Slow queries | Personal data (unless needed) |
| Business events | High-volume debug info |
| State changes | Sensitive tokens |

### Viewing Logs

**Vercel:**
1. Go to Project → Logs
2. Filter by function, level, or time
3. Search for specific errors

**Supabase:**
1. Go to Project → Logs
2. View API logs, database logs, auth logs

---

## Alerting

### UptimeRobot Alerts

Configure in UptimeRobot:
- Email alerts for downtime
- Slack integration (optional)
- Escalation after X minutes

### Sentry Alerts

Configure in Sentry → Alerts:
- Alert on new errors
- Alert on error spike
- Alert on specific error types

Example rules:
- "New issue" → Slack notification
- "Issue count > 10 in 1 hour" → Email
- "P0 error" → PagerDuty (for critical apps)

### Custom Alerts

For business-critical events:

```typescript
// lib/alerts.ts
export async function sendAlert(message: string, severity: 'info' | 'warning' | 'critical') {
  // Slack webhook
  if (process.env.SLACK_WEBHOOK_URL) {
    await fetch(process.env.SLACK_WEBHOOK_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        text: `[${severity.toUpperCase()}] ${message}`,
      }),
    })
  }

  // Also log
  console.log(`[ALERT:${severity}] ${message}`)
}

// Usage
if (failedPayments > 5) {
  await sendAlert('High payment failure rate detected', 'warning')
}
```

---

## Dashboard Setup

### Vercel Dashboard

Built-in, shows:
- Deployment status
- Function invocations
- Error rate
- Bandwidth usage

### Custom Dashboard (Optional)

For clients who need visibility:

```tsx
// app/admin/status/page.tsx
export default async function StatusPage() {
  const [health, metrics] = await Promise.all([
    fetch('/api/health').then(r => r.json()),
    fetch('/api/metrics').then(r => r.json()),
  ])

  return (
    <div>
      <h1>System Status</h1>

      <section>
        <h2>Health Checks</h2>
        {Object.entries(health.checks).map(([name, status]) => (
          <div key={name}>
            {name}: {status === 'ok' ? '✅' : '❌'}
          </div>
        ))}
      </section>

      <section>
        <h2>Metrics (24h)</h2>
        <p>Requests: {metrics.requests}</p>
        <p>Errors: {metrics.errors}</p>
        <p>Avg Latency: {metrics.avgLatency}ms</p>
      </section>
    </div>
  )
}
```

---

## Incident Response

### When Things Break

1. **Acknowledge** — Note the time, start investigating
2. **Assess** — What's affected? How many users?
3. **Communicate** — Update status page, notify stakeholders
4. **Fix** — Deploy fix or rollback
5. **Document** — Post-mortem, prevent recurrence

### Post-Mortem Template

```markdown
# Incident: [Brief Description]

## Summary
- **Date:** YYYY-MM-DD
- **Duration:** X hours
- **Impact:** Y users affected, Z revenue lost

## Timeline
- HH:MM - Issue first reported
- HH:MM - Team alerted
- HH:MM - Root cause identified
- HH:MM - Fix deployed
- HH:MM - Monitoring confirmed resolution

## Root Cause
[What actually broke and why]

## Resolution
[What was done to fix it]

## Prevention
[What we'll do to prevent this in the future]

## Action Items
- [ ] Action 1 - Owner - Due date
- [ ] Action 2 - Owner - Due date
```

---

## Monitoring Checklist

### New Project Setup

- [ ] Health endpoint created
- [ ] UptimeRobot monitor added
- [ ] Sentry configured (or basic logging)
- [ ] Vercel Analytics enabled
- [ ] Alert channels configured

### Ongoing

- [ ] Review error dashboard weekly
- [ ] Check uptime reports monthly
- [ ] Update alerts as needed
- [ ] Document incidents

---

## Quick Reference

### Key URLs

| Service | URL |
|---------|-----|
| Vercel Dashboard | `vercel.com/[team]/[project]` |
| Vercel Logs | `vercel.com/[team]/[project]/logs` |
| Sentry | `sentry.io` |
| UptimeRobot | `uptimerobot.com/dashboard` |
| Supabase Logs | `supabase.com/dashboard/project/[id]/logs` |

### Health Check Pattern

```typescript
// Minimum viable health check
export async function GET() {
  return Response.json({ status: 'ok', time: Date.now() })
}
```

---

*See also: [Performance Optimization](optimization.md) · [Cold Start Prevention](cold-start.md)*
