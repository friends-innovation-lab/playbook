# Unit Testing Standards

*How we write unit tests at Friends Innovation Lab.*

---

## Overview

We use **Vitest** for unit testing. It's fast, ESM-native, and compatible with Jest's API.

### When to Unit Test

| Test | Don't Test |
|------|------------|
| Utility functions | Simple pass-through components |
| Custom hooks | Third-party libraries |
| Complex logic | Styling/layout |
| Data transformations | Constants |
| Validation schemas | Generated code |

---

## Setup

### Install Dependencies

```bash
npm install -D vitest @testing-library/react @testing-library/jest-dom @vitejs/plugin-react jsdom
```

### Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: ['./tests/setup.ts'],
    include: ['**/*.test.{ts,tsx}'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
      exclude: ['node_modules/', 'tests/setup.ts'],
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
```

### Setup File

```typescript
// tests/setup.ts
import '@testing-library/jest-dom'
import { expect, afterEach } from 'vitest'
import { cleanup } from '@testing-library/react'
import * as matchers from '@testing-library/jest-dom/matchers'

expect.extend(matchers)

// Cleanup after each test
afterEach(() => {
  cleanup()
})
```

### Package.json Scripts

```json
{
  "scripts": {
    "test": "vitest",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage"
  }
}
```

---

## File Organization

```
src/
├── lib/
│   ├── utils.ts
│   └── utils.test.ts        # Co-located with source
├── hooks/
│   ├── useDebounce.ts
│   └── useDebounce.test.ts
└── components/
    ├── Button.tsx
    └── Button.test.tsx

# Or in separate folder:
tests/
├── unit/
│   ├── utils.test.ts
│   └── hooks/
│       └── useDebounce.test.ts
└── setup.ts
```

We prefer **co-located tests** (test file next to source file).

---

## Writing Tests

### Basic Structure

```typescript
// lib/utils.test.ts
import { describe, it, expect } from 'vitest'
import { formatCurrency, slugify } from './utils'

describe('formatCurrency', () => {
  it('formats positive numbers', () => {
    expect(formatCurrency(1234.56)).toBe('$1,234.56')
  })

  it('formats zero', () => {
    expect(formatCurrency(0)).toBe('$0.00')
  })

  it('formats negative numbers', () => {
    expect(formatCurrency(-50)).toBe('-$50.00')
  })
})

describe('slugify', () => {
  it('converts to lowercase', () => {
    expect(slugify('Hello World')).toBe('hello-world')
  })

  it('removes special characters', () => {
    expect(slugify('Hello! World?')).toBe('hello-world')
  })

  it('handles multiple spaces', () => {
    expect(slugify('hello    world')).toBe('hello-world')
  })
})
```

### Test Naming

```typescript
// Pattern: "it [does something] [when/with condition]"

// ✅ Good
it('returns null when user is not found')
it('throws error for invalid email')
it('formats date with custom format string')

// ❌ Bad
it('test1')
it('works')
it('should work correctly')
```

### Arrange-Act-Assert

```typescript
it('calculates total with tax', () => {
  // Arrange
  const items = [
    { price: 10, quantity: 2 },
    { price: 5, quantity: 1 },
  ]
  const taxRate = 0.1

  // Act
  const total = calculateTotal(items, taxRate)

  // Assert
  expect(total).toBe(27.5) // (20 + 5) * 1.1
})
```

---

## Common Assertions

```typescript
// Equality
expect(value).toBe(expected)           // Strict equality (===)
expect(value).toEqual(expected)        // Deep equality
expect(value).not.toBe(unexpected)

// Truthiness
expect(value).toBeTruthy()
expect(value).toBeFalsy()
expect(value).toBeNull()
expect(value).toBeUndefined()
expect(value).toBeDefined()

// Numbers
expect(value).toBeGreaterThan(3)
expect(value).toBeGreaterThanOrEqual(3)
expect(value).toBeLessThan(5)
expect(value).toBeCloseTo(0.3, 5)      // Floating point

// Strings
expect(str).toMatch(/pattern/)
expect(str).toContain('substring')
expect(str).toHaveLength(5)

// Arrays
expect(array).toContain(item)
expect(array).toHaveLength(3)
expect(array).toEqual(expect.arrayContaining([1, 2]))

// Objects
expect(obj).toHaveProperty('key')
expect(obj).toHaveProperty('key', 'value')
expect(obj).toMatchObject({ key: 'value' })
expect(obj).toEqual(expect.objectContaining({ key: 'value' }))

// Errors
expect(() => fn()).toThrow()
expect(() => fn()).toThrow('error message')
expect(() => fn()).toThrow(ErrorClass)

// Async
await expect(promise).resolves.toBe(value)
await expect(promise).rejects.toThrow()
```

---

## Testing Utilities

### Example: Testing a Utility Function

```typescript
// lib/utils.ts
export function formatDate(date: Date, format: string = 'YYYY-MM-DD'): string {
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')

  return format
    .replace('YYYY', String(year))
    .replace('MM', month)
    .replace('DD', day)
}

// lib/utils.test.ts
import { describe, it, expect } from 'vitest'
import { formatDate } from './utils'

describe('formatDate', () => {
  it('formats date with default format', () => {
    const date = new Date('2024-03-15')
    expect(formatDate(date)).toBe('2024-03-15')
  })

  it('formats date with custom format', () => {
    const date = new Date('2024-03-15')
    expect(formatDate(date, 'MM/DD/YYYY')).toBe('03/15/2024')
  })

  it('pads single digit month and day', () => {
    const date = new Date('2024-01-05')
    expect(formatDate(date)).toBe('2024-01-05')
  })
})
```

### Example: Testing Validation Schema

```typescript
// lib/validations.ts
import { z } from 'zod'

export const userSchema = z.object({
  name: z.string().min(1, 'Name is required').max(100),
  email: z.string().email('Invalid email'),
  age: z.number().int().positive().optional(),
})

// lib/validations.test.ts
import { describe, it, expect } from 'vitest'
import { userSchema } from './validations'

describe('userSchema', () => {
  it('validates correct data', () => {
    const data = { name: 'John', email: 'john@example.com' }
    expect(userSchema.safeParse(data).success).toBe(true)
  })

  it('rejects missing name', () => {
    const data = { email: 'john@example.com' }
    const result = userSchema.safeParse(data)
    expect(result.success).toBe(false)
  })

  it('rejects invalid email', () => {
    const data = { name: 'John', email: 'not-an-email' }
    const result = userSchema.safeParse(data)
    expect(result.success).toBe(false)
    if (!result.success) {
      expect(result.error.issues[0].message).toBe('Invalid email')
    }
  })

  it('accepts optional age', () => {
    const data = { name: 'John', email: 'john@example.com', age: 25 }
    expect(userSchema.safeParse(data).success).toBe(true)
  })

  it('rejects negative age', () => {
    const data = { name: 'John', email: 'john@example.com', age: -5 }
    expect(userSchema.safeParse(data).success).toBe(false)
  })
})
```

---

## Testing Hooks

### Basic Hook Test

```typescript
// hooks/useCounter.ts
import { useState, useCallback } from 'react'

export function useCounter(initial = 0) {
  const [count, setCount] = useState(initial)

  const increment = useCallback(() => setCount(c => c + 1), [])
  const decrement = useCallback(() => setCount(c => c - 1), [])
  const reset = useCallback(() => setCount(initial), [initial])

  return { count, increment, decrement, reset }
}

// hooks/useCounter.test.ts
import { renderHook, act } from '@testing-library/react'
import { describe, it, expect } from 'vitest'
import { useCounter } from './useCounter'

describe('useCounter', () => {
  it('starts with initial value', () => {
    const { result } = renderHook(() => useCounter(10))
    expect(result.current.count).toBe(10)
  })

  it('starts with 0 by default', () => {
    const { result } = renderHook(() => useCounter())
    expect(result.current.count).toBe(0)
  })

  it('increments count', () => {
    const { result } = renderHook(() => useCounter())

    act(() => {
      result.current.increment()
    })

    expect(result.current.count).toBe(1)
  })

  it('decrements count', () => {
    const { result } = renderHook(() => useCounter(5))

    act(() => {
      result.current.decrement()
    })

    expect(result.current.count).toBe(4)
  })

  it('resets to initial value', () => {
    const { result } = renderHook(() => useCounter(10))

    act(() => {
      result.current.increment()
      result.current.increment()
      result.current.reset()
    })

    expect(result.current.count).toBe(10)
  })
})
```

### Hook with Dependencies

```typescript
// hooks/useDebounce.ts
import { useState, useEffect } from 'react'

export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value)

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay)
    return () => clearTimeout(timer)
  }, [value, delay])

  return debouncedValue
}

// hooks/useDebounce.test.ts
import { renderHook, act } from '@testing-library/react'
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { useDebounce } from './useDebounce'

describe('useDebounce', () => {
  beforeEach(() => {
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.restoreAllMocks()
  })

  it('returns initial value immediately', () => {
    const { result } = renderHook(() => useDebounce('hello', 500))
    expect(result.current).toBe('hello')
  })

  it('debounces value changes', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, 500),
      { initialProps: { value: 'hello' } }
    )

    // Change value
    rerender({ value: 'world' })

    // Value shouldn't change immediately
    expect(result.current).toBe('hello')

    // Fast forward time
    act(() => {
      vi.advanceTimersByTime(500)
    })

    // Now it should be updated
    expect(result.current).toBe('world')
  })

  it('cancels pending update on new value', () => {
    const { result, rerender } = renderHook(
      ({ value }) => useDebounce(value, 500),
      { initialProps: { value: 'a' } }
    )

    rerender({ value: 'b' })
    act(() => vi.advanceTimersByTime(300))

    rerender({ value: 'c' })
    act(() => vi.advanceTimersByTime(300))

    // Should still be 'a' because 'b' was cancelled
    expect(result.current).toBe('a')

    act(() => vi.advanceTimersByTime(200))

    // Now should be 'c'
    expect(result.current).toBe('c')
  })
})
```

---

## Testing Components

### Simple Component Test

```typescript
// components/Greeting.tsx
interface GreetingProps {
  name: string
}

export function Greeting({ name }: GreetingProps) {
  return <h1>Hello, {name}!</h1>
}

// components/Greeting.test.tsx
import { render, screen } from '@testing-library/react'
import { describe, it, expect } from 'vitest'
import { Greeting } from './Greeting'

describe('Greeting', () => {
  it('renders greeting with name', () => {
    render(<Greeting name="John" />)
    expect(screen.getByText('Hello, John!')).toBeInTheDocument()
  })
})
```

### Component with User Interaction

```typescript
// components/Counter.tsx
'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'

export function Counter() {
  const [count, setCount] = useState(0)

  return (
    <div>
      <span data-testid="count">{count}</span>
      <Button onClick={() => setCount(c => c + 1)}>Increment</Button>
      <Button onClick={() => setCount(c => c - 1)}>Decrement</Button>
    </div>
  )
}

// components/Counter.test.tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { describe, it, expect } from 'vitest'
import { Counter } from './Counter'

describe('Counter', () => {
  it('starts at 0', () => {
    render(<Counter />)
    expect(screen.getByTestId('count')).toHaveTextContent('0')
  })

  it('increments when clicking increment button', async () => {
    const user = userEvent.setup()
    render(<Counter />)

    await user.click(screen.getByText('Increment'))

    expect(screen.getByTestId('count')).toHaveTextContent('1')
  })

  it('decrements when clicking decrement button', async () => {
    const user = userEvent.setup()
    render(<Counter />)

    await user.click(screen.getByText('Decrement'))

    expect(screen.getByTestId('count')).toHaveTextContent('-1')
  })
})
```

---

## Mocking

### Mock Functions

```typescript
import { vi, describe, it, expect } from 'vitest'

describe('callback handling', () => {
  it('calls callback with correct args', () => {
    const callback = vi.fn()

    processData([1, 2, 3], callback)

    expect(callback).toHaveBeenCalled()
    expect(callback).toHaveBeenCalledTimes(3)
    expect(callback).toHaveBeenCalledWith(1, 0)
    expect(callback).toHaveBeenLastCalledWith(3, 2)
  })
})
```

### Mock Return Values

```typescript
const mockFn = vi.fn()
  .mockReturnValue('default')
  .mockReturnValueOnce('first call')
  .mockReturnValueOnce('second call')

mockFn() // 'first call'
mockFn() // 'second call'
mockFn() // 'default'
```

### Mock Modules

```typescript
// Mock entire module
vi.mock('@/lib/api', () => ({
  fetchUsers: vi.fn(() => Promise.resolve([{ id: 1, name: 'John' }])),
}))

// Mock specific function
import { fetchUsers } from '@/lib/api'
vi.mocked(fetchUsers).mockResolvedValue([{ id: 1, name: 'John' }])
```

### Mock Supabase

```typescript
// tests/mocks/supabase.ts
import { vi } from 'vitest'

export const mockSupabase = {
  from: vi.fn(() => ({
    select: vi.fn(() => ({
      eq: vi.fn(() => ({
        single: vi.fn(() => Promise.resolve({ data: null, error: null })),
      })),
    })),
    insert: vi.fn(() => ({
      select: vi.fn(() => ({
        single: vi.fn(() => Promise.resolve({ data: null, error: null })),
      })),
    })),
  })),
  auth: {
    getUser: vi.fn(() => Promise.resolve({ data: { user: null }, error: null })),
  },
}

vi.mock('@/lib/supabase/client', () => ({
  createClient: () => mockSupabase,
}))
```

---

## Test Isolation

### Reset Mocks Between Tests

```typescript
import { vi, beforeEach, afterEach } from 'vitest'

beforeEach(() => {
  vi.clearAllMocks()  // Clear call history
})

// Or
afterEach(() => {
  vi.resetAllMocks()  // Reset to initial implementation
})

// Or
afterEach(() => {
  vi.restoreAllMocks() // Restore original implementations
})
```

### Isolate Date/Time

```typescript
beforeEach(() => {
  vi.useFakeTimers()
  vi.setSystemTime(new Date('2024-01-15'))
})

afterEach(() => {
  vi.useRealTimers()
})

it('formats today', () => {
  expect(formatRelativeDate(new Date())).toBe('Today')
})
```

---

## Code Coverage

### Run Coverage

```bash
npm run test:coverage
```

### Coverage Thresholds

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov'],
      exclude: [
        'node_modules/',
        'tests/',
        '**/*.d.ts',
        '**/*.config.*',
      ],
      thresholds: {
        lines: 70,
        functions: 70,
        branches: 70,
        statements: 70,
      },
    },
  },
})
```

### What to Cover

| High Priority | Low Priority |
|---------------|--------------|
| Business logic | UI styling |
| Data transformations | Third-party wrappers |
| Validation | Generated code |
| Custom hooks | Simple getters |
| Error handling | Constants |

---

## Common Patterns

### Testing Async Code

```typescript
it('fetches data', async () => {
  const data = await fetchData()
  expect(data).toEqual({ id: 1 })
})

it('handles errors', async () => {
  await expect(fetchBadData()).rejects.toThrow('Not found')
})
```

### Testing Error Boundaries

```typescript
it('catches errors', () => {
  const spy = vi.spyOn(console, 'error').mockImplementation(() => {})

  const ThrowError = () => {
    throw new Error('Test error')
  }

  render(
    <ErrorBoundary fallback={<div>Error</div>}>
      <ThrowError />
    </ErrorBoundary>
  )

  expect(screen.getByText('Error')).toBeInTheDocument()
  spy.mockRestore()
})
```

### Parameterized Tests

```typescript
describe('isValidEmail', () => {
  it.each([
    ['test@example.com', true],
    ['user.name@domain.org', true],
    ['invalid', false],
    ['@nodomain.com', false],
    ['spaces in@email.com', false],
  ])('isValidEmail(%s) = %s', (email, expected) => {
    expect(isValidEmail(email)).toBe(expected)
  })
})
```

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Testing implementation | Brittle tests | Test behavior/output |
| Too many mocks | Tests don't reflect reality | Mock only boundaries |
| No edge cases | Bugs in edge cases | Test empty, null, error states |
| Async without await | Tests pass incorrectly | Always await async operations |
| Shared state | Flaky tests | Reset state in beforeEach |
| Testing library code | Wasted effort | Trust third-party libraries |

---

## Quick Reference

### Vitest Commands

```bash
vitest              # Watch mode
vitest run          # Single run
vitest run file.ts  # Run specific file
vitest --coverage   # With coverage
vitest --ui         # Visual UI
```

### Test Structure

```typescript
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'

describe('feature', () => {
  beforeEach(() => {
    // Setup
  })

  afterEach(() => {
    // Cleanup
  })

  it('does something', () => {
    // Arrange
    // Act
    // Assert
  })
})
```

---

*See also: [Integration Testing](integration.md) · [E2E Testing](e2e.md) · [QA Checklist](qa-checklist.md)*
