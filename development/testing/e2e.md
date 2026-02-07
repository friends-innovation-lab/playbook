# E2E Testing Standards

*How we write end-to-end tests at Friends Innovation Lab.*

---

## Overview

We use **Playwright** for E2E testing. It's fast, reliable, and supports all modern browsers.

### When to E2E Test

| E2E Test | Don't E2E Test |
|----------|----------------|
| Critical user flows | Every feature |
| Auth flows | Unit-testable logic |
| Checkout/payment | Visual styling |
| Multi-page workflows | API responses (use integration) |
| Cross-browser issues | Edge cases |

**Keep E2E tests focused on critical paths.** They're slower and more brittle than unit tests.

---

## Setup

### Install Playwright

```bash
npm init playwright@latest

# Or add to existing project
npm install -D @playwright/test
npx playwright install
```

### Configuration

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html'],
    ['list'],
  ],
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    // Mobile
    {
      name: 'mobile-chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'mobile-safari',
      use: { ...devices['iPhone 12'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
})
```

### Package.json Scripts

```json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:headed": "playwright test --headed",
    "test:e2e:debug": "playwright test --debug"
  }
}
```

---

## File Structure

```
e2e/
├── auth.spec.ts           # Auth flow tests
├── dashboard.spec.ts      # Dashboard tests
├── projects.spec.ts       # Project CRUD tests
├── fixtures/
│   └── auth.ts            # Auth fixtures
├── pages/                 # Page Object Models
│   ├── login.page.ts
│   ├── dashboard.page.ts
│   └── projects.page.ts
└── utils/
    └── helpers.ts         # Test helpers
```

---

## Writing Tests

### Basic Test

```typescript
// e2e/home.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Home Page', () => {
  test('has title', async ({ page }) => {
    await page.goto('/')
    await expect(page).toHaveTitle(/My App/)
  })

  test('shows hero section', async ({ page }) => {
    await page.goto('/')
    await expect(page.getByRole('heading', { name: 'Welcome' })).toBeVisible()
  })

  test('navigates to login', async ({ page }) => {
    await page.goto('/')
    await page.getByRole('link', { name: 'Sign In' }).click()
    await expect(page).toHaveURL('/login')
  })
})
```

### Testing Forms

```typescript
// e2e/contact.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Contact Form', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/contact')
  })

  test('submits form successfully', async ({ page }) => {
    // Fill form
    await page.getByLabel('Name').fill('John Doe')
    await page.getByLabel('Email').fill('john@example.com')
    await page.getByLabel('Message').fill('Hello, this is a test message.')

    // Submit
    await page.getByRole('button', { name: 'Send Message' }).click()

    // Verify success
    await expect(page.getByText('Message sent successfully')).toBeVisible()
  })

  test('shows validation errors', async ({ page }) => {
    // Submit empty form
    await page.getByRole('button', { name: 'Send Message' }).click()

    // Check errors
    await expect(page.getByText('Name is required')).toBeVisible()
    await expect(page.getByText('Email is required')).toBeVisible()
  })

  test('validates email format', async ({ page }) => {
    await page.getByLabel('Name').fill('John')
    await page.getByLabel('Email').fill('invalid-email')
    await page.getByRole('button', { name: 'Send Message' }).click()

    await expect(page.getByText('Invalid email address')).toBeVisible()
  })
})
```

---

## Authentication Tests

### Login Flow

```typescript
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Authentication', () => {
  test('logs in with valid credentials', async ({ page }) => {
    await page.goto('/login')

    await page.getByLabel('Email').fill('test@example.com')
    await page.getByLabel('Password').fill('password123')
    await page.getByRole('button', { name: 'Sign In' }).click()

    // Should redirect to dashboard
    await expect(page).toHaveURL('/dashboard')
    await expect(page.getByText('Welcome back')).toBeVisible()
  })

  test('shows error for invalid credentials', async ({ page }) => {
    await page.goto('/login')

    await page.getByLabel('Email').fill('test@example.com')
    await page.getByLabel('Password').fill('wrongpassword')
    await page.getByRole('button', { name: 'Sign In' }).click()

    await expect(page.getByText('Invalid email or password')).toBeVisible()
    await expect(page).toHaveURL('/login')
  })

  test('logs out successfully', async ({ page }) => {
    // Login first
    await page.goto('/login')
    await page.getByLabel('Email').fill('test@example.com')
    await page.getByLabel('Password').fill('password123')
    await page.getByRole('button', { name: 'Sign In' }).click()
    await expect(page).toHaveURL('/dashboard')

    // Logout
    await page.getByRole('button', { name: 'Account' }).click()
    await page.getByRole('menuitem', { name: 'Sign Out' }).click()

    // Should redirect to home
    await expect(page).toHaveURL('/')
  })
})
```

### Auth Fixtures

```typescript
// e2e/fixtures/auth.ts
import { test as base, expect } from '@playwright/test'

// Test user credentials
const TEST_USER = {
  email: 'test@example.com',
  password: 'password123',
}

// Extend base test with authenticated page
export const test = base.extend<{ authenticatedPage: typeof base }>({
  authenticatedPage: async ({ page }, use) => {
    // Login
    await page.goto('/login')
    await page.getByLabel('Email').fill(TEST_USER.email)
    await page.getByLabel('Password').fill(TEST_USER.password)
    await page.getByRole('button', { name: 'Sign In' }).click()
    await expect(page).toHaveURL('/dashboard')

    // Use the authenticated page
    await use(page)
  },
})

export { expect }
```

```typescript
// e2e/dashboard.spec.ts
import { test, expect } from './fixtures/auth'

test.describe('Dashboard (Authenticated)', () => {
  test('shows user projects', async ({ authenticatedPage: page }) => {
    await page.goto('/dashboard')
    await expect(page.getByRole('heading', { name: 'Your Projects' })).toBeVisible()
  })
})
```

### Storage State (Persist Auth)

```typescript
// e2e/auth.setup.ts
import { test as setup, expect } from '@playwright/test'

const authFile = 'e2e/.auth/user.json'

setup('authenticate', async ({ page }) => {
  await page.goto('/login')
  await page.getByLabel('Email').fill('test@example.com')
  await page.getByLabel('Password').fill('password123')
  await page.getByRole('button', { name: 'Sign In' }).click()

  await expect(page).toHaveURL('/dashboard')

  // Save storage state
  await page.context().storageState({ path: authFile })
})
```

```typescript
// playwright.config.ts
export default defineConfig({
  projects: [
    // Setup project
    { name: 'setup', testMatch: /.*\.setup\.ts/ },

    // Tests that need auth
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        storageState: 'e2e/.auth/user.json',
      },
      dependencies: ['setup'],
    },
  ],
})
```

---

## Page Object Model

### Page Object

```typescript
// e2e/pages/login.page.ts
import { Page, Locator, expect } from '@playwright/test'

export class LoginPage {
  readonly page: Page
  readonly emailInput: Locator
  readonly passwordInput: Locator
  readonly submitButton: Locator
  readonly errorMessage: Locator

  constructor(page: Page) {
    this.page = page
    this.emailInput = page.getByLabel('Email')
    this.passwordInput = page.getByLabel('Password')
    this.submitButton = page.getByRole('button', { name: 'Sign In' })
    this.errorMessage = page.getByRole('alert')
  }

  async goto() {
    await this.page.goto('/login')
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email)
    await this.passwordInput.fill(password)
    await this.submitButton.click()
  }

  async expectError(message: string) {
    await expect(this.errorMessage).toContainText(message)
  }

  async expectSuccess() {
    await expect(this.page).toHaveURL('/dashboard')
  }
}
```

```typescript
// e2e/pages/dashboard.page.ts
import { Page, Locator, expect } from '@playwright/test'

export class DashboardPage {
  readonly page: Page
  readonly heading: Locator
  readonly projectList: Locator
  readonly newProjectButton: Locator

  constructor(page: Page) {
    this.page = page
    this.heading = page.getByRole('heading', { name: 'Dashboard' })
    this.projectList = page.getByTestId('project-list')
    this.newProjectButton = page.getByRole('button', { name: 'New Project' })
  }

  async goto() {
    await this.page.goto('/dashboard')
  }

  async createProject(name: string) {
    await this.newProjectButton.click()
    await this.page.getByLabel('Project Name').fill(name)
    await this.page.getByRole('button', { name: 'Create' }).click()
  }

  async expectProjectVisible(name: string) {
    await expect(this.projectList.getByText(name)).toBeVisible()
  }

  async getProjectCount() {
    return await this.projectList.getByRole('listitem').count()
  }
}
```

### Using Page Objects

```typescript
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test'
import { LoginPage } from './pages/login.page'
import { DashboardPage } from './pages/dashboard.page'

test.describe('Authentication', () => {
  test('logs in successfully', async ({ page }) => {
    const loginPage = new LoginPage(page)

    await loginPage.goto()
    await loginPage.login('test@example.com', 'password123')
    await loginPage.expectSuccess()
  })

  test('shows error for invalid credentials', async ({ page }) => {
    const loginPage = new LoginPage(page)

    await loginPage.goto()
    await loginPage.login('test@example.com', 'wrong')
    await loginPage.expectError('Invalid email or password')
  })
})

test.describe('Dashboard', () => {
  test('creates new project', async ({ page }) => {
    // Login first
    const loginPage = new LoginPage(page)
    await loginPage.goto()
    await loginPage.login('test@example.com', 'password123')

    // Create project
    const dashboard = new DashboardPage(page)
    await dashboard.createProject('My New Project')
    await dashboard.expectProjectVisible('My New Project')
  })
})
```

---

## Locators

### Best Practices

```typescript
// ✅ Accessible locators (preferred)
page.getByRole('button', { name: 'Submit' })
page.getByRole('link', { name: 'Home' })
page.getByRole('textbox', { name: 'Email' })
page.getByLabel('Password')
page.getByPlaceholder('Search...')
page.getByText('Welcome')

// ✅ Test IDs (for complex elements)
page.getByTestId('project-card')
page.getByTestId('user-menu')

// ⚠️ Avoid when possible
page.locator('.btn-primary')  // CSS selector
page.locator('#submit')        // ID selector
page.locator('//div[@class="card"]')  // XPath
```

### Locator Chaining

```typescript
// Find within element
const card = page.getByTestId('project-card').first()
await card.getByRole('button', { name: 'Edit' }).click()

// Filter
await page.getByRole('listitem')
  .filter({ hasText: 'Project A' })
  .getByRole('button', { name: 'Delete' })
  .click()

// Multiple elements
const items = page.getByRole('listitem')
await expect(items).toHaveCount(5)

// First/last/nth
await page.getByRole('button').first().click()
await page.getByRole('button').last().click()
await page.getByRole('button').nth(2).click()
```

---

## Assertions

```typescript
// Visibility
await expect(element).toBeVisible()
await expect(element).toBeHidden()
await expect(element).toBeAttached()

// State
await expect(element).toBeEnabled()
await expect(element).toBeDisabled()
await expect(element).toBeChecked()
await expect(element).toBeFocused()

// Content
await expect(element).toHaveText('Hello')
await expect(element).toContainText('Hello')
await expect(element).toHaveValue('input value')
await expect(element).toHaveAttribute('href', '/about')
await expect(element).toHaveClass('active')

// Count
await expect(elements).toHaveCount(5)

// Page
await expect(page).toHaveURL('/dashboard')
await expect(page).toHaveURL(/\/dashboard/)
await expect(page).toHaveTitle('Dashboard')

// Screenshots
await expect(page).toHaveScreenshot('homepage.png')
await expect(element).toHaveScreenshot('button.png')
```

---

## Waiting

Playwright auto-waits for elements. Sometimes you need explicit waits:

```typescript
// Wait for element
await page.waitForSelector('[data-testid="loading"]', { state: 'hidden' })

// Wait for URL
await page.waitForURL('/dashboard')

// Wait for response
await page.waitForResponse(response =>
  response.url().includes('/api/users') && response.status() === 200
)

// Wait for network idle
await page.waitForLoadState('networkidle')

// Custom wait
await expect(async () => {
  const count = await page.getByRole('listitem').count()
  expect(count).toBeGreaterThan(0)
}).toPass({ timeout: 5000 })
```

---

## API Testing

```typescript
// e2e/api.spec.ts
import { test, expect } from '@playwright/test'

test.describe('API Tests', () => {
  test('GET /api/users returns users', async ({ request }) => {
    const response = await request.get('/api/users')

    expect(response.ok()).toBeTruthy()

    const data = await response.json()
    expect(data).toHaveProperty('users')
    expect(Array.isArray(data.users)).toBe(true)
  })

  test('POST /api/users creates user', async ({ request }) => {
    const response = await request.post('/api/users', {
      data: {
        name: 'John Doe',
        email: 'john@example.com',
      },
    })

    expect(response.status()).toBe(201)

    const user = await response.json()
    expect(user.name).toBe('John Doe')
  })

  test('POST /api/users validates input', async ({ request }) => {
    const response = await request.post('/api/users', {
      data: { name: '' },
    })

    expect(response.status()).toBe(400)

    const error = await response.json()
    expect(error.message).toContain('required')
  })
})
```

---

## Visual Testing

### Screenshots

```typescript
// Capture and compare
test('homepage looks correct', async ({ page }) => {
  await page.goto('/')
  await expect(page).toHaveScreenshot('homepage.png')
})

// With options
await expect(page).toHaveScreenshot('page.png', {
  fullPage: true,
  maxDiffPixels: 100,
})

// Element screenshot
await expect(page.getByTestId('header')).toHaveScreenshot('header.png')
```

### Update Snapshots

```bash
npx playwright test --update-snapshots
```

---

## Debugging

### Debug Mode

```bash
# Debug specific test
npx playwright test --debug auth.spec.ts

# Open UI mode
npx playwright test --ui

# Headed mode
npx playwright test --headed
```

### In-Test Debugging

```typescript
test('debug example', async ({ page }) => {
  await page.goto('/')

  // Pause execution
  await page.pause()

  // Console log
  console.log(await page.title())

  // Screenshot
  await page.screenshot({ path: 'debug.png' })
})
```

### Trace Viewer

```typescript
// playwright.config.ts
use: {
  trace: 'on-first-retry', // or 'on', 'retain-on-failure'
}
```

```bash
# View trace
npx playwright show-trace trace.zip
```

---

## CI Configuration

### GitHub Actions

```yaml
# .github/workflows/e2e.yml
name: E2E Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    timeout-minutes: 15
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright browsers
        run: npx playwright install --with-deps

      - name: Run E2E tests
        run: npm run test:e2e
        env:
          BASE_URL: http://localhost:3000

      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 7
```

---

## Best Practices

### 1. Test Critical Paths Only

```typescript
// ✅ Critical user journeys
test('user can complete checkout', async ({ page }) => { })
test('user can sign up and verify email', async ({ page }) => { })

// ❌ Not worth E2E testing
test('button has correct color', async ({ page }) => { })
test('tooltip appears on hover', async ({ page }) => { })
```

### 2. Keep Tests Independent

```typescript
// ❌ Tests depend on each other
test('create project', async ({ page }) => {
  // Creates project used by next test
})

test('edit project', async ({ page }) => {
  // Assumes project exists from previous test
})

// ✅ Independent tests
test('create project', async ({ page }) => {
  await createProject(page, 'Test Project')
  await expect(page.getByText('Test Project')).toBeVisible()
})

test('edit project', async ({ page }) => {
  await createProject(page, 'Original Name')  // Setup own data
  await editProject(page, 'Original Name', 'New Name')
  await expect(page.getByText('New Name')).toBeVisible()
})
```

### 3. Use Descriptive Test Names

```typescript
// ❌ Vague
test('works', async ({ page }) => { })
test('test 1', async ({ page }) => { })

// ✅ Descriptive
test('user can filter projects by status', async ({ page }) => { })
test('displays error when payment fails', async ({ page }) => { })
```

### 4. Don't Sleep

```typescript
// ❌ Arbitrary sleep
await page.waitForTimeout(2000)

// ✅ Wait for specific condition
await expect(page.getByText('Loaded')).toBeVisible()
await page.waitForResponse('/api/data')
```

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| Too many E2E tests | Slow CI, flaky | Focus on critical paths |
| Hardcoded waits | Slow, flaky | Use proper assertions |
| CSS selectors | Brittle | Use accessible locators |
| Dependent tests | Cascading failures | Make tests independent |
| Not using Page Objects | Duplicated code | Extract to page objects |
| Ignoring flaky tests | False confidence | Fix or delete them |

---

## Quick Reference

### Commands

```bash
npx playwright test                  # Run all tests
npx playwright test auth.spec.ts     # Run specific file
npx playwright test --grep "login"   # Filter by name
npx playwright test --project=chromium  # Specific browser
npx playwright test --headed         # See browser
npx playwright test --ui             # UI mode
npx playwright test --debug          # Debug mode
npx playwright show-report           # Open report
npx playwright codegen               # Generate tests
```

### Test Template

```typescript
import { test, expect } from '@playwright/test'

test.describe('Feature', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/page')
  })

  test('does something', async ({ page }) => {
    // Arrange (if needed beyond beforeEach)

    // Act
    await page.getByRole('button', { name: 'Click' }).click()

    // Assert
    await expect(page.getByText('Result')).toBeVisible()
  })
})
```

---

*See also: [Unit Testing](unit.md) · [Integration Testing](integration.md) · [QA Checklist](qa-checklist.md)*
