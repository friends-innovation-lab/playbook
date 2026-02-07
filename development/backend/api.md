# API Standards

*How we build APIs at Friends Innovation Lab.*

---

## Overview

We use **Next.js API Routes** (App Router) for backend logic. For simple CRUD, we often skip custom APIs and use Supabase directly from the client with RLS.

### When to Use API Routes

| Use API Routes | Use Supabase Direct |
|----------------|---------------------|
| Complex business logic | Simple CRUD |
| Third-party API calls | Basic queries with RLS |
| Sensitive operations | Real-time subscriptions |
| Rate limiting needed | Client-side filtering |
| Data transformation | Direct table access |
| Webhooks | Auth operations |

---

## API Route Basics

### File Structure

```
src/app/api/
├── users/
│   ├── route.ts              # GET /api/users, POST /api/users
│   └── [id]/
│       └── route.ts          # GET/PUT/DELETE /api/users/:id
├── projects/
│   ├── route.ts              # GET/POST /api/projects
│   └── [id]/
│       ├── route.ts          # GET/PUT/DELETE /api/projects/:id
│       └── members/
│           └── route.ts      # GET/POST /api/projects/:id/members
└── webhooks/
    └── stripe/
        └── route.ts          # POST /api/webhooks/stripe
```

### Basic Route Handler

```typescript
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

### Dynamic Route Handler

```typescript
// app/api/users/[id]/route.ts
import { NextResponse } from 'next/server'

interface RouteParams {
  params: { id: string }
}

export async function GET(request: Request, { params }: RouteParams) {
  const user = await db.users.findUnique({
    where: { id: params.id }
  })

  if (!user) {
    return NextResponse.json(
      { error: 'User not found' },
      { status: 404 }
    )
  }

  return NextResponse.json(user)
}

export async function PUT(request: Request, { params }: RouteParams) {
  const body = await request.json()
  const user = await db.users.update({
    where: { id: params.id },
    data: body,
  })
  return NextResponse.json(user)
}

export async function DELETE(request: Request, { params }: RouteParams) {
  await db.users.delete({ where: { id: params.id } })
  return new NextResponse(null, { status: 204 })
}
```

---

## Request Handling

### Reading the Request Body

```typescript
export async function POST(request: Request) {
  // JSON body
  const body = await request.json()

  // Form data
  const formData = await request.formData()
  const name = formData.get('name')

  // Raw text
  const text = await request.text()

  // ...
}
```

### Query Parameters

```typescript
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)

  const page = parseInt(searchParams.get('page') || '1')
  const limit = parseInt(searchParams.get('limit') || '10')
  const search = searchParams.get('search') || ''

  const users = await db.users.findMany({
    skip: (page - 1) * limit,
    take: limit,
    where: search ? { name: { contains: search } } : undefined,
  })

  return NextResponse.json(users)
}
```

### Headers

```typescript
export async function GET(request: Request) {
  // Read request headers
  const authHeader = request.headers.get('authorization')
  const contentType = request.headers.get('content-type')

  // Set response headers
  return NextResponse.json(data, {
    headers: {
      'Cache-Control': 'max-age=60',
      'X-Custom-Header': 'value',
    },
  })
}
```

### Cookies

```typescript
import { cookies } from 'next/headers'

export async function GET() {
  const cookieStore = cookies()
  const token = cookieStore.get('token')

  // ...
}

export async function POST() {
  const cookieStore = cookies()

  cookieStore.set('token', 'value', {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'lax',
    maxAge: 60 * 60 * 24 * 7, // 1 week
  })

  return NextResponse.json({ success: true })
}
```

---

## Response Patterns

### Standard Response Format

```typescript
// Success response
{
  "data": { ... },
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 100
  }
}

// Error response
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid email address",
    "details": {
      "field": "email",
      "reason": "Must be a valid email"
    }
  }
}
```

### Response Helpers

```typescript
// lib/api.ts
import { NextResponse } from 'next/server'

export function successResponse<T>(data: T, status = 200) {
  return NextResponse.json({ data }, { status })
}

export function errorResponse(
  code: string,
  message: string,
  status = 400,
  details?: Record<string, unknown>
) {
  return NextResponse.json(
    { error: { code, message, details } },
    { status }
  )
}

export function paginatedResponse<T>(
  data: T[],
  page: number,
  limit: number,
  total: number
) {
  return NextResponse.json({
    data,
    meta: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  })
}

// Usage
export async function GET() {
  const users = await db.users.findMany()
  return successResponse(users)
}

export async function POST(request: Request) {
  const body = await request.json()

  if (!body.email) {
    return errorResponse(
      'VALIDATION_ERROR',
      'Email is required',
      400,
      { field: 'email' }
    )
  }

  const user = await db.users.create({ data: body })
  return successResponse(user, 201)
}
```

### HTTP Status Codes

| Code | Meaning | Use For |
|------|---------|---------|
| 200 | OK | Successful GET, PUT |
| 201 | Created | Successful POST (created resource) |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Validation errors, malformed request |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Authenticated but not allowed |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Duplicate resource, version conflict |
| 422 | Unprocessable Entity | Valid syntax but semantic errors |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Unexpected server error |

---

## Input Validation

### With Zod

```typescript
// lib/validations/user.ts
import { z } from 'zod'

export const createUserSchema = z.object({
  name: z.string().min(1, 'Name is required').max(100),
  email: z.string().email('Invalid email address'),
  role: z.enum(['admin', 'user', 'guest']).default('user'),
  age: z.number().int().positive().optional(),
})

export const updateUserSchema = createUserSchema.partial()

export type CreateUserInput = z.infer<typeof createUserSchema>
export type UpdateUserInput = z.infer<typeof updateUserSchema>
```

```typescript
// app/api/users/route.ts
import { createUserSchema } from '@/lib/validations/user'
import { errorResponse, successResponse } from '@/lib/api'

export async function POST(request: Request) {
  const body = await request.json()

  // Validate
  const result = createUserSchema.safeParse(body)

  if (!result.success) {
    return errorResponse(
      'VALIDATION_ERROR',
      'Invalid input',
      400,
      { errors: result.error.flatten().fieldErrors }
    )
  }

  // result.data is now typed and validated
  const user = await db.users.create({ data: result.data })
  return successResponse(user, 201)
}
```

### Validation Helper

```typescript
// lib/api.ts
import { ZodSchema } from 'zod'

export async function validateRequest<T>(
  request: Request,
  schema: ZodSchema<T>
): Promise<{ data: T } | { error: NextResponse }> {
  try {
    const body = await request.json()
    const result = schema.safeParse(body)

    if (!result.success) {
      return {
        error: errorResponse(
          'VALIDATION_ERROR',
          'Invalid input',
          400,
          { errors: result.error.flatten().fieldErrors }
        ),
      }
    }

    return { data: result.data }
  } catch {
    return {
      error: errorResponse('INVALID_JSON', 'Invalid JSON body', 400),
    }
  }
}

// Usage
export async function POST(request: Request) {
  const validation = await validateRequest(request, createUserSchema)

  if ('error' in validation) {
    return validation.error
  }

  const user = await db.users.create({ data: validation.data })
  return successResponse(user, 201)
}
```

---

## Error Handling

### Try-Catch Pattern

```typescript
export async function POST(request: Request) {
  try {
    const body = await request.json()
    const user = await db.users.create({ data: body })
    return successResponse(user, 201)

  } catch (error) {
    console.error('Failed to create user:', error)

    // Handle known errors
    if (error instanceof PrismaClientKnownRequestError) {
      if (error.code === 'P2002') {
        return errorResponse(
          'DUPLICATE_ERROR',
          'A user with this email already exists',
          409
        )
      }
    }

    // Unknown error
    return errorResponse(
      'INTERNAL_ERROR',
      'An unexpected error occurred',
      500
    )
  }
}
```

### Error Wrapper

```typescript
// lib/api.ts
type RouteHandler = (
  request: Request,
  context?: { params: Record<string, string> }
) => Promise<NextResponse>

export function withErrorHandling(handler: RouteHandler): RouteHandler {
  return async (request, context) => {
    try {
      return await handler(request, context)
    } catch (error) {
      console.error('API Error:', error)

      if (error instanceof z.ZodError) {
        return errorResponse(
          'VALIDATION_ERROR',
          'Invalid input',
          400,
          { errors: error.flatten().fieldErrors }
        )
      }

      if (error instanceof AuthError) {
        return errorResponse('UNAUTHORIZED', error.message, 401)
      }

      return errorResponse(
        'INTERNAL_ERROR',
        process.env.NODE_ENV === 'development'
          ? error.message
          : 'An unexpected error occurred',
        500
      )
    }
  }
}

// Usage
export const POST = withErrorHandling(async (request) => {
  const body = await request.json()
  const user = await db.users.create({ data: body })
  return successResponse(user, 201)
})
```

### Custom Error Classes

```typescript
// lib/errors.ts
export class ApiError extends Error {
  constructor(
    public code: string,
    message: string,
    public status: number = 400,
    public details?: Record<string, unknown>
  ) {
    super(message)
    this.name = 'ApiError'
  }
}

export class NotFoundError extends ApiError {
  constructor(resource: string) {
    super('NOT_FOUND', `${resource} not found`, 404)
  }
}

export class UnauthorizedError extends ApiError {
  constructor(message = 'Unauthorized') {
    super('UNAUTHORIZED', message, 401)
  }
}

export class ForbiddenError extends ApiError {
  constructor(message = 'Forbidden') {
    super('FORBIDDEN', message, 403)
  }
}

export class ValidationError extends ApiError {
  constructor(details: Record<string, unknown>) {
    super('VALIDATION_ERROR', 'Validation failed', 400, details)
  }
}

// Usage
export async function GET(request: Request, { params }: RouteParams) {
  const user = await db.users.findUnique({ where: { id: params.id } })

  if (!user) {
    throw new NotFoundError('User')
  }

  return successResponse(user)
}
```

---

## Authentication

### Checking Auth in API Routes

```typescript
// With Supabase
import { createClient } from '@/lib/supabase/server'

export async function GET() {
  const supabase = createClient()
  const { data: { user }, error } = await supabase.auth.getUser()

  if (error || !user) {
    return errorResponse('UNAUTHORIZED', 'Not authenticated', 401)
  }

  // User is authenticated
  const data = await db.items.findMany({
    where: { userId: user.id }
  })

  return successResponse(data)
}
```

### Auth Middleware Helper

```typescript
// lib/api.ts
import { createClient } from '@/lib/supabase/server'
import { User } from '@supabase/supabase-js'

type AuthenticatedHandler = (
  request: Request,
  context: { params: Record<string, string>; user: User }
) => Promise<NextResponse>

export function withAuth(handler: AuthenticatedHandler): RouteHandler {
  return async (request, context) => {
    const supabase = createClient()
    const { data: { user }, error } = await supabase.auth.getUser()

    if (error || !user) {
      return errorResponse('UNAUTHORIZED', 'Not authenticated', 401)
    }

    return handler(request, { ...context, user })
  }
}

// Usage
export const GET = withAuth(async (request, { user }) => {
  const items = await db.items.findMany({
    where: { userId: user.id }
  })
  return successResponse(items)
})
```

### Role-Based Access

```typescript
// lib/api.ts
type Role = 'admin' | 'user' | 'guest'

export function withRole(roles: Role[], handler: AuthenticatedHandler) {
  return withAuth(async (request, context) => {
    const userRole = context.user.user_metadata?.role as Role

    if (!roles.includes(userRole)) {
      return errorResponse(
        'FORBIDDEN',
        'You do not have permission to access this resource',
        403
      )
    }

    return handler(request, context)
  })
}

// Usage - only admins can access
export const DELETE = withRole(['admin'], async (request, { params }) => {
  await db.users.delete({ where: { id: params.id } })
  return new NextResponse(null, { status: 204 })
})
```

---

## Rate Limiting

### Simple In-Memory Rate Limiter

```typescript
// lib/rate-limit.ts
const requests = new Map<string, { count: number; resetTime: number }>()

export function rateLimit(
  key: string,
  limit: number = 10,
  windowMs: number = 60 * 1000 // 1 minute
): { success: boolean; remaining: number; resetIn: number } {
  const now = Date.now()
  const record = requests.get(key)

  if (!record || now > record.resetTime) {
    requests.set(key, { count: 1, resetTime: now + windowMs })
    return { success: true, remaining: limit - 1, resetIn: windowMs }
  }

  if (record.count >= limit) {
    return {
      success: false,
      remaining: 0,
      resetIn: record.resetTime - now
    }
  }

  record.count++
  return {
    success: true,
    remaining: limit - record.count,
    resetIn: record.resetTime - now
  }
}
```

### Rate Limit Middleware

```typescript
// lib/api.ts
export function withRateLimit(
  limit: number = 10,
  windowMs: number = 60 * 1000
) {
  return (handler: RouteHandler): RouteHandler => {
    return async (request, context) => {
      // Use IP or user ID as key
      const ip = request.headers.get('x-forwarded-for') || 'anonymous'
      const key = `${request.method}:${new URL(request.url).pathname}:${ip}`

      const result = rateLimit(key, limit, windowMs)

      if (!result.success) {
        return NextResponse.json(
          {
            error: {
              code: 'RATE_LIMIT_EXCEEDED',
              message: 'Too many requests',
              retryAfter: Math.ceil(result.resetIn / 1000)
            }
          },
          {
            status: 429,
            headers: {
              'Retry-After': String(Math.ceil(result.resetIn / 1000)),
              'X-RateLimit-Limit': String(limit),
              'X-RateLimit-Remaining': '0',
            }
          }
        )
      }

      const response = await handler(request, context)

      // Add rate limit headers to response
      response.headers.set('X-RateLimit-Limit', String(limit))
      response.headers.set('X-RateLimit-Remaining', String(result.remaining))

      return response
    }
  }
}

// Usage - 5 requests per minute
export const POST = withRateLimit(5, 60 * 1000)(
  async (request) => {
    // Handle request
  }
)
```

### Production Rate Limiting

For production, use Redis or Upstash:

```typescript
// With Upstash
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '60 s'),
})

export async function POST(request: Request) {
  const ip = request.headers.get('x-forwarded-for') || 'anonymous'
  const { success, limit, remaining, reset } = await ratelimit.limit(ip)

  if (!success) {
    return NextResponse.json(
      { error: { code: 'RATE_LIMIT_EXCEEDED', message: 'Too many requests' } },
      {
        status: 429,
        headers: {
          'X-RateLimit-Limit': String(limit),
          'X-RateLimit-Remaining': String(remaining),
          'X-RateLimit-Reset': String(reset),
        }
      }
    )
  }

  // Handle request
}
```

---

## Third-Party API Calls

### Fetch with Error Handling

```typescript
// lib/external-api.ts
interface FetchOptions extends RequestInit {
  timeout?: number
}

export async function fetchWithTimeout(
  url: string,
  options: FetchOptions = {}
): Promise<Response> {
  const { timeout = 10000, ...fetchOptions } = options

  const controller = new AbortController()
  const timeoutId = setTimeout(() => controller.abort(), timeout)

  try {
    const response = await fetch(url, {
      ...fetchOptions,
      signal: controller.signal,
    })

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }

    return response
  } finally {
    clearTimeout(timeoutId)
  }
}

// Usage
export async function getWeather(city: string) {
  const response = await fetchWithTimeout(
    `https://api.weather.com/v1/current?city=${city}`,
    {
      headers: {
        'Authorization': `Bearer ${process.env.WEATHER_API_KEY}`,
      },
      timeout: 5000,
    }
  )

  return response.json()
}
```

### Retry Logic

```typescript
// lib/external-api.ts
export async function fetchWithRetry(
  url: string,
  options: FetchOptions = {},
  retries = 3,
  backoff = 1000
): Promise<Response> {
  for (let attempt = 0; attempt <= retries; attempt++) {
    try {
      return await fetchWithTimeout(url, options)
    } catch (error) {
      if (attempt === retries) throw error

      // Exponential backoff
      const delay = backoff * Math.pow(2, attempt)
      await new Promise(resolve => setTimeout(resolve, delay))
    }
  }

  throw new Error('Max retries exceeded')
}
```

### Caching External API Calls

```typescript
// Simple in-memory cache
const cache = new Map<string, { data: unknown; expires: number }>()

export async function cachedFetch<T>(
  key: string,
  fetcher: () => Promise<T>,
  ttlMs = 60 * 1000 // 1 minute
): Promise<T> {
  const cached = cache.get(key)

  if (cached && cached.expires > Date.now()) {
    return cached.data as T
  }

  const data = await fetcher()
  cache.set(key, { data, expires: Date.now() + ttlMs })

  return data
}

// Usage
export async function GET() {
  const weather = await cachedFetch(
    'weather:chicago',
    () => getWeather('Chicago'),
    5 * 60 * 1000 // Cache for 5 minutes
  )

  return successResponse(weather)
}
```

---

## Webhooks

### Webhook Handler

```typescript
// app/api/webhooks/stripe/route.ts
import { headers } from 'next/headers'
import Stripe from 'stripe'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)
const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET!

export async function POST(request: Request) {
  const body = await request.text()
  const signature = headers().get('stripe-signature')!

  let event: Stripe.Event

  try {
    event = stripe.webhooks.constructEvent(body, signature, webhookSecret)
  } catch (error) {
    console.error('Webhook signature verification failed:', error)
    return NextResponse.json(
      { error: 'Invalid signature' },
      { status: 400 }
    )
  }

  // Handle the event
  switch (event.type) {
    case 'checkout.session.completed':
      const session = event.data.object as Stripe.Checkout.Session
      await handleCheckoutComplete(session)
      break

    case 'customer.subscription.deleted':
      const subscription = event.data.object as Stripe.Subscription
      await handleSubscriptionCanceled(subscription)
      break

    default:
      console.log(`Unhandled event type: ${event.type}`)
  }

  return NextResponse.json({ received: true })
}

async function handleCheckoutComplete(session: Stripe.Checkout.Session) {
  // Update database, send email, etc.
}

async function handleSubscriptionCanceled(subscription: Stripe.Subscription) {
  // Update user status, send email, etc.
}
```

### Webhook Security

```typescript
// Always verify signatures
// Never trust unverified webhook data
// Log all webhook events for debugging
// Make handlers idempotent (same event processed twice = same result)
// Return 200 quickly, process asynchronously if needed

export async function POST(request: Request) {
  // 1. Verify signature
  const isValid = verifySignature(request)
  if (!isValid) {
    return NextResponse.json({ error: 'Invalid' }, { status: 400 })
  }

  // 2. Parse event
  const event = await request.json()

  // 3. Check if already processed (idempotency)
  const processed = await db.webhookEvents.findUnique({
    where: { eventId: event.id }
  })

  if (processed) {
    return NextResponse.json({ received: true })
  }

  // 4. Process and record
  await db.webhookEvents.create({
    data: { eventId: event.id, type: event.type, processedAt: new Date() }
  })

  // 5. Handle event
  await processEvent(event)

  return NextResponse.json({ received: true })
}
```

---

## API Documentation

### Inline Documentation

```typescript
/**
 * Create a new user
 *
 * @route POST /api/users
 * @param {string} body.name - User's full name
 * @param {string} body.email - User's email address
 * @param {string} [body.role=user] - User's role (admin, user, guest)
 * @returns {201} Created user object
 * @returns {400} Validation error
 * @returns {409} Email already exists
 */
export async function POST(request: Request) {
  // ...
}
```

### README Documentation

```markdown
## API Endpoints

### Users

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /api/users | List all users |
| POST | /api/users | Create a user |
| GET | /api/users/:id | Get a user |
| PUT | /api/users/:id | Update a user |
| DELETE | /api/users/:id | Delete a user |

### Create User

POST /api/users

Request:
\`\`\`json
{
  "name": "John Doe",
  "email": "john@example.com",
  "role": "user"
}
\`\`\`

Response (201):
\`\`\`json
{
  "data": {
    "id": "123",
    "name": "John Doe",
    "email": "john@example.com",
    "role": "user",
    "createdAt": "2024-01-15T10:00:00Z"
  }
}
\`\`\`
```

---

## Testing API Routes

```typescript
// __tests__/api/users.test.ts
import { POST, GET } from '@/app/api/users/route'
import { NextRequest } from 'next/server'

describe('POST /api/users', () => {
  it('creates a user with valid data', async () => {
    const request = new NextRequest('http://localhost/api/users', {
      method: 'POST',
      body: JSON.stringify({ name: 'John', email: 'john@example.com' }),
    })

    const response = await POST(request)
    const data = await response.json()

    expect(response.status).toBe(201)
    expect(data.data.name).toBe('John')
  })

  it('returns 400 for invalid email', async () => {
    const request = new NextRequest('http://localhost/api/users', {
      method: 'POST',
      body: JSON.stringify({ name: 'John', email: 'invalid' }),
    })

    const response = await POST(request)

    expect(response.status).toBe(400)
  })
})
```

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| No input validation | Security vulnerabilities | Always validate with Zod |
| Exposing stack traces | Information leakage | Generic errors in production |
| No rate limiting | DDoS vulnerability | Add rate limits |
| Sync heavy operations | Slow responses | Use queues/background jobs |
| No error logging | Hard to debug | Log all errors |
| Trusting client data | Security risk | Validate everything server-side |
| No auth checks | Data exposure | Check auth on every route |
| Hardcoded secrets | Security breach | Use environment variables |

---

*See also: [Database](database.md) · [Auth](auth.md)*
