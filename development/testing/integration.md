# Integration Testing Standards

*How we test API routes and data flows at Friends Innovation Lab.*

---

## Overview

Integration tests verify that different parts of the system work together. For us, this primarily means:

- **API route testing** — Testing Next.js API routes
- **Database integration** — Testing queries with real (test) database
- **Service integration** — Testing services that combine multiple modules

---

## When to Integration Test

| Integration Test | Unit Test Instead |
|------------------|-------------------|
| API endpoints | Pure utility functions |
| Database queries | Data transformations |
| Auth flows | Validation schemas |
| Multi-step workflows | Individual components |
| External API wrappers | Simple calculations |

---

## Setup

### Test Database

Use a separate Supabase project or local Supabase for testing:

```bash
# .env.test
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-local-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-local-service-key
```

### Vitest Config for Integration Tests

```typescript
// vitest.integration.config.ts
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'node',
    include: ['**/*.integration.test.ts'],
    setupFiles: ['./tests/integration/setup.ts'],
    // Run sequentially to avoid database conflicts
    pool: 'forks',
    poolOptions: {
      forks: {
        singleFork: true,
      },
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
```

### Package.json Scripts

```json
{
  "scripts": {
    "test": "vitest",
    "test:unit": "vitest run",
    "test:integration": "vitest run --config vitest.integration.config.ts",
    "test:all": "npm run test:unit && npm run test:integration"
  }
}
```

---

## Testing API Routes

### Basic API Route Test

```typescript
// app/api/users/route.ts
import { NextResponse } from 'next/server'
import { createClient } from '@/lib/supabase/server'

export async function GET() {
  const supabase = createClient()
  const { data, error } = await supabase.from('users').select('*')

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json({ data })
}

export async function POST(request: Request) {
  const supabase = createClient()
  const body = await request.json()

  const { data, error } = await supabase
    .from('users')
    .insert(body)
    .select()
    .single()

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 400 })
  }

  return NextResponse.json({ data }, { status: 201 })
}
```

```typescript
// app/api/users/route.integration.test.ts
import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { GET, POST } from './route'
import { createTestClient, cleanupTestData } from '@/tests/integration/helpers'

describe('GET /api/users', () => {
  beforeEach(async () => {
    const supabase = createTestClient()
    await supabase.from('users').insert([
      { id: 'test-1', email: 'user1@test.com', name: 'User 1' },
      { id: 'test-2', email: 'user2@test.com', name: 'User 2' },
    ])
  })

  afterEach(async () => {
    await cleanupTestData('users', ['test-1', 'test-2'])
  })

  it('returns all users', async () => {
    const response = await GET()
    const json = await response.json()

    expect(response.status).toBe(200)
    expect(json.data).toHaveLength(2)
  })
})

describe('POST /api/users', () => {
  afterEach(async () => {
    await cleanupTestData('users', ['test-new'])
  })

  it('creates a new user', async () => {
    const request = new Request('http://localhost/api/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        id: 'test-new',
        email: 'new@test.com',
        name: 'New User',
      }),
    })

    const response = await POST(request)
    const json = await response.json()

    expect(response.status).toBe(201)
    expect(json.data.email).toBe('new@test.com')
  })

  it('returns 400 for invalid data', async () => {
    const request = new Request('http://localhost/api/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ invalid: 'data' }),
    })

    const response = await POST(request)

    expect(response.status).toBe(400)
  })
})
```

### Test Helpers

```typescript
// tests/integration/helpers.ts
import { createClient } from '@supabase/supabase-js'

// Use service role for test setup/teardown (bypasses RLS)
export function createTestClient() {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  )
}

export async function cleanupTestData(table: string, ids: string[]) {
  const supabase = createTestClient()
  await supabase.from(table).delete().in('id', ids)
}

export async function seedTestData<T extends Record<string, unknown>>(
  table: string,
  data: T[]
) {
  const supabase = createTestClient()
  const { error } = await supabase.from(table).insert(data)
  if (error) throw error
}

export function createMockRequest(
  url: string,
  options: {
    method?: string
    body?: unknown
    headers?: Record<string, string>
  } = {}
) {
  return new Request(url, {
    method: options.method || 'GET',
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
    body: options.body ? JSON.stringify(options.body) : undefined,
  })
}
```

---

## Testing with Authentication

### Mock Auth for Tests

```typescript
// tests/integration/auth-helpers.ts
import { vi } from 'vitest'

export function mockAuthenticatedUser(user: {
  id: string
  email: string
  role?: string
}) {
  vi.mock('@/lib/supabase/server', () => ({
    createClient: () => ({
      auth: {
        getUser: () => Promise.resolve({
          data: {
            user: {
              id: user.id,
              email: user.email,
              user_metadata: { role: user.role || 'user' },
            },
          },
          error: null,
        }),
      },
      from: vi.fn(() => ({
        select: vi.fn().mockReturnThis(),
        insert: vi.fn().mockReturnThis(),
        update: vi.fn().mockReturnThis(),
        delete: vi.fn().mockReturnThis(),
        eq: vi.fn().mockReturnThis(),
        single: vi.fn(),
      })),
    }),
  }))
}

export function mockUnauthenticatedUser() {
  vi.mock('@/lib/supabase/server', () => ({
    createClient: () => ({
      auth: {
        getUser: () => Promise.resolve({
          data: { user: null },
          error: { message: 'Not authenticated' },
        }),
      },
    }),
  }))
}
```

### Auth Integration Test

```typescript
// app/api/me/route.integration.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { GET } from './route'

describe('GET /api/me', () => {
  beforeEach(() => {
    vi.resetModules()
  })

  it('returns user when authenticated', async () => {
    vi.doMock('@/lib/supabase/server', () => ({
      createClient: () => ({
        auth: {
          getUser: () => Promise.resolve({
            data: {
              user: { id: 'user-123', email: 'test@example.com' },
            },
            error: null,
          }),
        },
      }),
    }))

    const { GET } = await import('./route')
    const response = await GET()
    const json = await response.json()

    expect(response.status).toBe(200)
    expect(json.user.email).toBe('test@example.com')
  })

  it('returns 401 when not authenticated', async () => {
    vi.doMock('@/lib/supabase/server', () => ({
      createClient: () => ({
        auth: {
          getUser: () => Promise.resolve({
            data: { user: null },
            error: null,
          }),
        },
      }),
    }))

    const { GET } = await import('./route')
    const response = await GET()

    expect(response.status).toBe(401)
  })
})
```

---

## Testing Database Operations

### Service Layer Test

```typescript
// lib/services/projects.ts
import { createClient } from '@/lib/supabase/server'

export async function getProjectsForUser(userId: string) {
  const supabase = createClient()

  const { data, error } = await supabase
    .from('projects')
    .select('*, members:project_members(*)')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })

  if (error) throw error
  return data
}

export async function createProject(userId: string, data: {
  name: string
  description?: string
}) {
  const supabase = createClient()

  const { data: project, error } = await supabase
    .from('projects')
    .insert({ ...data, user_id: userId })
    .select()
    .single()

  if (error) throw error
  return project
}
```

```typescript
// lib/services/projects.integration.test.ts
import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import { createTestClient, cleanupTestData } from '@/tests/integration/helpers'

// Test with real database
describe('Project Service', () => {
  const testUserId = 'test-user-123'
  const testProjectIds: string[] = []
  const supabase = createTestClient()

  beforeAll(async () => {
    // Create test user if using auth.users
    // Or just use a fake UUID for testing
  })

  afterAll(async () => {
    // Cleanup all test projects
    if (testProjectIds.length > 0) {
      await supabase.from('projects').delete().in('id', testProjectIds)
    }
  })

  describe('createProject', () => {
    it('creates a project with required fields', async () => {
      const { data, error } = await supabase
        .from('projects')
        .insert({
          name: 'Test Project',
          user_id: testUserId,
        })
        .select()
        .single()

      expect(error).toBeNull()
      expect(data.name).toBe('Test Project')
      expect(data.user_id).toBe(testUserId)

      testProjectIds.push(data.id)
    })

    it('creates a project with all fields', async () => {
      const { data, error } = await supabase
        .from('projects')
        .insert({
          name: 'Full Project',
          description: 'A test project',
          user_id: testUserId,
        })
        .select()
        .single()

      expect(error).toBeNull()
      expect(data.description).toBe('A test project')

      testProjectIds.push(data.id)
    })
  })

  describe('getProjectsForUser', () => {
    beforeEach(async () => {
      // Seed test data
      const { data } = await supabase
        .from('projects')
        .insert([
          { name: 'Project 1', user_id: testUserId },
          { name: 'Project 2', user_id: testUserId },
        ])
        .select()

      if (data) {
        testProjectIds.push(...data.map(p => p.id))
      }
    })

    it('returns all projects for user', async () => {
      const { data, error } = await supabase
        .from('projects')
        .select('*')
        .eq('user_id', testUserId)

      expect(error).toBeNull()
      expect(data?.length).toBeGreaterThanOrEqual(2)
    })
  })
})
```

---

## Testing External APIs

### Mock External Services

```typescript
// lib/services/weather.ts
export async function getWeather(city: string) {
  const response = await fetch(
    `https://api.weather.com/v1/current?city=${city}`,
    {
      headers: {
        'Authorization': `Bearer ${process.env.WEATHER_API_KEY}`,
      },
    }
  )

  if (!response.ok) {
    throw new Error(`Weather API error: ${response.status}`)
  }

  return response.json()
}
```

```typescript
// lib/services/weather.integration.test.ts
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { getWeather } from './weather'

describe('Weather Service', () => {
  beforeEach(() => {
    vi.stubGlobal('fetch', vi.fn())
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('returns weather data for valid city', async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: true,
      json: () => Promise.resolve({
        city: 'Chicago',
        temp: 72,
        conditions: 'Sunny',
      }),
    } as Response)

    const weather = await getWeather('Chicago')

    expect(weather.city).toBe('Chicago')
    expect(weather.temp).toBe(72)
    expect(fetch).toHaveBeenCalledWith(
      'https://api.weather.com/v1/current?city=Chicago',
      expect.objectContaining({
        headers: expect.objectContaining({
          'Authorization': expect.stringContaining('Bearer'),
        }),
      })
    )
  })

  it('throws on API error', async () => {
    vi.mocked(fetch).mockResolvedValueOnce({
      ok: false,
      status: 404,
    } as Response)

    await expect(getWeather('InvalidCity')).rejects.toThrow('Weather API error: 404')
  })

  it('handles network errors', async () => {
    vi.mocked(fetch).mockRejectedValueOnce(new Error('Network error'))

    await expect(getWeather('Chicago')).rejects.toThrow('Network error')
  })
})
```

---

## Testing Webhooks

```typescript
// app/api/webhooks/stripe/route.ts
import { headers } from 'next/headers'
import { NextResponse } from 'next/server'
import Stripe from 'stripe'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

export async function POST(request: Request) {
  const body = await request.text()
  const signature = headers().get('stripe-signature')!

  let event: Stripe.Event

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    )
  } catch (error) {
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 })
  }

  // Handle event...

  return NextResponse.json({ received: true })
}
```

```typescript
// app/api/webhooks/stripe/route.integration.test.ts
import { describe, it, expect, vi } from 'vitest'
import { POST } from './route'
import Stripe from 'stripe'

// Mock Stripe
vi.mock('stripe', () => ({
  default: vi.fn(() => ({
    webhooks: {
      constructEvent: vi.fn(),
    },
  })),
}))

describe('POST /api/webhooks/stripe', () => {
  it('returns 400 for invalid signature', async () => {
    const stripe = new Stripe('fake-key')
    vi.mocked(stripe.webhooks.constructEvent).mockImplementation(() => {
      throw new Error('Invalid signature')
    })

    const request = new Request('http://localhost/api/webhooks/stripe', {
      method: 'POST',
      body: JSON.stringify({ type: 'test' }),
      headers: {
        'stripe-signature': 'invalid',
      },
    })

    const response = await POST(request)

    expect(response.status).toBe(400)
  })

  it('processes valid webhook', async () => {
    const mockEvent = {
      id: 'evt_123',
      type: 'checkout.session.completed',
      data: { object: { id: 'cs_123' } },
    }

    const stripe = new Stripe('fake-key')
    vi.mocked(stripe.webhooks.constructEvent).mockReturnValue(
      mockEvent as unknown as Stripe.Event
    )

    const request = new Request('http://localhost/api/webhooks/stripe', {
      method: 'POST',
      body: JSON.stringify(mockEvent),
      headers: {
        'stripe-signature': 'valid-signature',
      },
    })

    const response = await POST(request)
    const json = await response.json()

    expect(response.status).toBe(200)
    expect(json.received).toBe(true)
  })
})
```

---

## Test Database Setup

### Using Local Supabase

```bash
# Start local Supabase
supabase start

# Run migrations
supabase db reset

# Run tests
npm run test:integration
```

### Setup Script

```typescript
// tests/integration/setup.ts
import { beforeAll, afterAll } from 'vitest'
import { createTestClient } from './helpers'

beforeAll(async () => {
  // Verify database connection
  const supabase = createTestClient()
  const { error } = await supabase.from('users').select('count').limit(1)

  if (error) {
    throw new Error(`Database connection failed: ${error.message}`)
  }

  console.log('✓ Database connected')
})

afterAll(async () => {
  // Global cleanup if needed
  console.log('✓ Tests complete')
})
```

### Test Data Fixtures

```typescript
// tests/integration/fixtures.ts
export const testUsers = [
  { id: 'user-1', email: 'user1@test.com', name: 'Test User 1' },
  { id: 'user-2', email: 'user2@test.com', name: 'Test User 2' },
]

export const testProjects = [
  { id: 'proj-1', name: 'Project 1', user_id: 'user-1' },
  { id: 'proj-2', name: 'Project 2', user_id: 'user-1' },
  { id: 'proj-3', name: 'Project 3', user_id: 'user-2' },
]

export async function seedFixtures(supabase: SupabaseClient) {
  await supabase.from('users').insert(testUsers)
  await supabase.from('projects').insert(testProjects)
}

export async function cleanupFixtures(supabase: SupabaseClient) {
  await supabase.from('projects').delete().in('id', testProjects.map(p => p.id))
  await supabase.from('users').delete().in('id', testUsers.map(u => u.id))
}
```

---

## Common Patterns

### Testing Validation

```typescript
describe('POST /api/users', () => {
  it.each([
    [{ name: '' }, 'Name is required'],
    [{ name: 'John', email: 'invalid' }, 'Invalid email'],
    [{ name: 'John', email: 'john@example.com', age: -1 }, 'Age must be positive'],
  ])('rejects invalid input: %o', async (body, expectedError) => {
    const request = createMockRequest('/api/users', {
      method: 'POST',
      body,
    })

    const response = await POST(request)
    const json = await response.json()

    expect(response.status).toBe(400)
    expect(json.error.message).toContain(expectedError)
  })
})
```

### Testing Pagination

```typescript
describe('GET /api/projects', () => {
  beforeAll(async () => {
    // Seed 25 projects
    await seedTestData('projects', Array.from({ length: 25 }, (_, i) => ({
      id: `proj-${i}`,
      name: `Project ${i}`,
      user_id: testUserId,
    })))
  })

  it('returns paginated results', async () => {
    const request = createMockRequest('/api/projects?page=1&limit=10')
    const response = await GET(request)
    const json = await response.json()

    expect(json.data).toHaveLength(10)
    expect(json.meta.total).toBe(25)
    expect(json.meta.totalPages).toBe(3)
  })

  it('returns second page', async () => {
    const request = createMockRequest('/api/projects?page=2&limit=10')
    const response = await GET(request)
    const json = await response.json()

    expect(json.data).toHaveLength(10)
    expect(json.meta.page).toBe(2)
  })
})
```

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Shared test data | Tests affect each other | Isolate data per test |
| Not cleaning up | Data accumulates | Always cleanup in afterEach |
| Testing in production DB | Dangerous | Use separate test database |
| Parallel tests with DB | Race conditions | Run sequentially |
| Hardcoded IDs | Conflicts | Generate unique IDs |
| No error case tests | Missing coverage | Test failure paths |

---

*See also: [Unit Testing](unit.md) · [E2E Testing](e2e.md) · [QA Checklist](qa-checklist.md)*
