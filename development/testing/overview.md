# Testing with Claude Code

*How to build prototypes that don't break when you change things*

---

## Why Test Prototypes?

You might think: "It's just an MVP, testing is overkill."

But even light testing:
- Catches bugs before clients see them
- Lets you change code confidently without breaking things
- Proves to clients (especially government) that you're professional
- Makes handoff easier - tests document how things should work

You don't need 100% coverage. You need **confidence in the critical paths**.

---

## The Testing Pyramid (Simplified)

```
         /\
        /  \      E2E Tests (few)
       /----\     User flows, critical paths
      /      \    
     /--------\   Integration Tests (some)
    /          \  API routes, database operations
   /------------\ 
  /              \ Unit Tests (many)
 /________________\ Utility functions, pure logic
```

**For MVPs, focus on:**
1. Unit tests for utility functions (easy wins)
2. Integration tests for critical API routes
3. One or two E2E tests for the main user flow

---

## Setting Up Testing in Your Projects

**Add to your template's package.json:**

```bash
npm install -D vitest @testing-library/react @testing-library/jest-dom @playwright/test
```

**Create `vitest.config.ts`:**
```typescript
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './test/setup.ts',
  },
})
```

**Create `test/setup.ts`:**
```typescript
import '@testing-library/jest-dom'
```

**Add scripts to `package.json`:**
```json
{
  "scripts": {
    "test": "vitest",
    "test:run": "vitest run",
    "test:e2e": "playwright test"
  }
}
```

---

## What to Test (Priority Order)

### Priority 1: Utility Functions

These are easy wins. Pure functions with no side effects.

**Example - testing `lib/utils.ts`:**

```typescript
// lib/utils.test.ts
import { describe, it, expect } from 'vitest'
import { formatCurrency, formatDate, truncate } from './utils'

describe('formatCurrency', () => {
  it('formats USD correctly', () => {
    expect(formatCurrency(1234.56)).toBe('$1,234.56')
  })
  
  it('handles zero', () => {
    expect(formatCurrency(0)).toBe('$0.00')
  })
  
  it('handles negative numbers', () => {
    expect(formatCurrency(-50)).toBe('-$50.00')
  })
})

describe('truncate', () => {
  it('truncates long strings', () => {
    expect(truncate('hello world', 5)).toBe('hello...')
  })
  
  it('leaves short strings alone', () => {
    expect(truncate('hi', 10)).toBe('hi')
  })
})
```

**Ask Claude Code:** "Write unit tests for all functions in lib/utils.ts"

---

### Priority 2: API Routes

Test that your endpoints handle valid input, invalid input, and errors.

**Example - testing an API route:**

```typescript
// app/api/items/route.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { POST, GET } from './route'

// Mock Supabase
vi.mock('@/lib/supabase-server', () => ({
  createServerSupabaseClient: () => ({
    from: () => ({
      insert: vi.fn().mockResolvedValue({ data: { id: 1 }, error: null }),
      select: vi.fn().mockResolvedValue({ data: [], error: null }),
    }),
  }),
}))

describe('POST /api/items', () => {
  it('creates item with valid data', async () => {
    const request = new Request('http://localhost/api/items', {
      method: 'POST',
      body: JSON.stringify({ name: 'Test Item' }),
    })
    
    const response = await POST(request)
    const data = await response.json()
    
    expect(response.status).toBe(200)
    expect(data.data.id).toBe(1)
  })
  
  it('returns 400 for missing name', async () => {
    const request = new Request('http://localhost/api/items', {
      method: 'POST',
      body: JSON.stringify({}),
    })
    
    const response = await POST(request)
    
    expect(response.status).toBe(400)
  })
})
```

**Ask Claude Code:** "Write integration tests for this API route. Test success, validation errors, and database errors."

---

### Priority 3: Critical User Flows (E2E)

Test the main thing your app does, end to end.

**Example - Playwright test:**

```typescript
// e2e/create-item.spec.ts
import { test, expect } from '@playwright/test'

test('user can create an item', async ({ page }) => {
  // Go to the app
  await page.goto('/')
  
  // Fill out the form
  await page.fill('[name="itemName"]', 'My New Item')
  await page.fill('[name="description"]', 'A test item')
  
  // Submit
  await page.click('button[type="submit"]')
  
  // Verify success
  await expect(page.locator('.success-message')).toBeVisible()
  await expect(page.locator('.item-list')).toContainText('My New Item')
})

test('shows error for invalid input', async ({ page }) => {
  await page.goto('/')
  
  // Submit empty form
  await page.click('button[type="submit"]')
  
  // Should show validation error
  await expect(page.locator('.error-message')).toContainText('Name is required')
})
```

**Ask Claude Code:** "Write a Playwright E2E test for the main user flow: [describe the flow]"

---

## Prompts for Claude Code

**Setting up tests:**
- "Add Vitest to this project with React Testing Library. Create the config files."
- "Set up Playwright for E2E testing in this Next.js project."

**Writing tests:**
- "Write unit tests for lib/utils.ts covering edge cases."
- "Write integration tests for the /api/items route. Mock Supabase and test success, validation, and error cases."
- "Write a Playwright test for the user signup flow."

**Improving tests:**
- "What edge cases am I missing in these tests?"
- "This test is flaky. How can I make it more reliable?"
- "How do I test this component that fetches data on mount?"

**Debugging:**
- "This test is failing with [error]. What's wrong?"
- "How do I mock [specific thing] in Vitest?"

---

## Testing Checklist for MVPs

Before shipping, at minimum:

**Unit Tests**
- [ ] All utility functions in `lib/` have tests
- [ ] Edge cases covered (empty input, null, negative numbers, etc.)

**Integration Tests**
- [ ] Critical API routes tested
- [ ] Validation errors handled
- [ ] Database errors handled

**E2E Tests (at least one)**
- [ ] Main happy path works
- [ ] Critical error state shows correctly

**Manual Testing**
- [ ] Test on mobile viewport
- [ ] Test with slow network (Chrome DevTools → Network → Slow 3G)
- [ ] Test with JavaScript disabled (graceful degradation)

---

## Quick Wins Without Full Testing

If you're tight on time, at least do this:

**1. TypeScript Strict Mode**
Catches many bugs at compile time. In `tsconfig.json`:
```json
{
  "compilerOptions": {
    "strict": true
  }
}
```

**2. Console Error Check**
Before shipping, open the app and check browser console. Fix any errors or warnings.

**3. Error Boundaries**
Wrap your app so crashes show a friendly message instead of blank screen:

```typescript
// components/ErrorBoundary.tsx
'use client'
import { Component, ReactNode } from 'react'

class ErrorBoundary extends Component<
  { children: ReactNode },
  { hasError: boolean }
> {
  state = { hasError: false }
  
  static getDerivedStateFromError() {
    return { hasError: true }
  }
  
  render() {
    if (this.state.hasError) {
      return (
        <div className="p-8 text-center">
          <h2>Something went wrong</h2>
          <button onClick={() => window.location.reload()}>
            Refresh page
          </button>
        </div>
      )
    }
    return this.props.children
  }
}
```

---

## Tier-Specific Testing Guidance

| Tier | Testing Expectation |
|------|---------------------|
| **Discovery** | Manual testing only. Console error-free. Basic error handling. |
| **Pilot-Ready** | Unit tests for utils. Integration tests for critical routes. One E2E test. |
| **Foundation** | Comprehensive test suite. CI pipeline runs tests on push. Test coverage documented in handoff. |

---

## CI/CD Integration (Future)

When you're ready to level up, add GitHub Actions to run tests automatically:

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm ci
      - run: npm run test:run
      - run: npx playwright install --with-deps
      - run: npm run test:e2e
```

---

*Testing isn't about perfection. It's about confidence. Even basic tests mean you can change code without fear.*
