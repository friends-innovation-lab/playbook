# Performance Optimization

*How we keep apps fast at Friends Innovation Lab.*

---

## Performance Budget

### Targets

| Metric | Target | Acceptable |
|--------|--------|------------|
| First Contentful Paint (FCP) | < 1.5s | < 2.5s |
| Largest Contentful Paint (LCP) | < 2.0s | < 3.0s |
| Time to Interactive (TTI) | < 3.0s | < 5.0s |
| Cumulative Layout Shift (CLS) | < 0.1 | < 0.25 |
| First Input Delay (FID) | < 100ms | < 200ms |
| Total Bundle Size (JS) | < 200KB | < 350KB |

### Measuring

```bash
# Lighthouse CLI
npx lighthouse https://your-site.com --view

# Or use Chrome DevTools > Lighthouse tab
```

---

## Next.js Optimizations

### Use Server Components (Default)

Server Components don't add to client bundle:

```tsx
// ✅ Server Component (default) - no JS shipped to client
export default async function Page() {
  const data = await fetchData()
  return <div>{data.title}</div>
}

// ❌ Client Component - adds to bundle
'use client'
export default function Page() {
  const [data, setData] = useState(null)
  // ...
}
```

**Rule:** Only add `'use client'` when you need interactivity.

### Dynamic Imports (Code Splitting)

Load components only when needed:

```tsx
import dynamic from 'next/dynamic'

// Heavy component loaded on demand
const HeavyChart = dynamic(() => import('@/components/HeavyChart'), {
  loading: () => <ChartSkeleton />,
  ssr: false, // Skip server rendering if not needed
})

export default function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      <HeavyChart /> {/* Only loads when rendered */}
    </div>
  )
}
```

### Route-Based Code Splitting

Next.js automatically splits by route. Keep pages focused:

```
app/
├── page.tsx          # Home - separate chunk
├── dashboard/
│   └── page.tsx      # Dashboard - separate chunk
├── settings/
│   └── page.tsx      # Settings - separate chunk
```

### Lazy Load Below-the-Fold Content

```tsx
'use client'

import { useEffect, useState } from 'react'

export function LazySection() {
  const [isVisible, setIsVisible] = useState(false)

  useEffect(() => {
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setIsVisible(true)
          observer.disconnect()
        }
      },
      { rootMargin: '100px' }
    )

    const element = document.getElementById('lazy-section')
    if (element) observer.observe(element)

    return () => observer.disconnect()
  }, [])

  return (
    <div id="lazy-section">
      {isVisible ? <HeavyContent /> : <Placeholder />}
    </div>
  )
}
```

---

## Image Optimization

### Use Next.js Image Component

```tsx
import Image from 'next/image'

// ✅ Optimized - automatic WebP, lazy loading, sizing
<Image
  src="/hero.jpg"
  alt="Hero image"
  width={1200}
  height={600}
  priority // For above-the-fold images
/>

// ✅ Responsive images
<Image
  src="/photo.jpg"
  alt="Photo"
  fill
  sizes="(max-width: 768px) 100vw, 50vw"
  className="object-cover"
/>

// ❌ Unoptimized
<img src="/hero.jpg" alt="Hero" />
```

### Image Best Practices

| Practice | Why |
|----------|-----|
| Use `priority` for LCP image | Preloads critical image |
| Specify `sizes` for responsive | Loads appropriate size |
| Use `fill` with container | Responsive without layout shift |
| Use WebP/AVIF source | Smaller file size |
| Lazy load below fold | Reduces initial load |

### Placeholder for Layout Stability

```tsx
<Image
  src="/photo.jpg"
  alt="Photo"
  width={800}
  height={600}
  placeholder="blur"
  blurDataURL="data:image/jpeg;base64,/9j/4AAQ..." // Tiny base64
/>
```

Generate blur placeholder:

```bash
# Using plaiceholder
npx plaiceholder ./public/image.jpg
```

---

## Bundle Analysis

### Analyze Bundle Size

```bash
# Install analyzer
npm install -D @next/bundle-analyzer

# next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
})

module.exports = withBundleAnalyzer({
  // your config
})

# Run analysis
ANALYZE=true npm run build
```

### Common Bundle Bloat

| Problem | Solution |
|---------|----------|
| Moment.js (300KB) | Use date-fns or dayjs (2-20KB) |
| Lodash full import | Import specific functions |
| Large icon libraries | Import individual icons |
| Unused dependencies | Remove from package.json |
| Duplicate dependencies | Check with `npm dedupe` |

### Tree Shaking

```typescript
// ❌ Imports entire library
import _ from 'lodash'
_.debounce(fn, 300)

// ✅ Imports only what's needed
import debounce from 'lodash/debounce'
debounce(fn, 300)

// ❌ Imports all icons
import * as Icons from 'lucide-react'

// ✅ Imports only needed icons
import { Search, Menu, X } from 'lucide-react'
```

---

## Data Fetching

### Fetch in Server Components

```tsx
// ✅ Server Component - data fetched at build/request time
export default async function Page() {
  const data = await fetch('https://api.example.com/data', {
    next: { revalidate: 3600 } // Cache for 1 hour
  })
  return <DataDisplay data={data} />
}
```

### Parallel Data Fetching

```tsx
// ❌ Sequential - slow
const user = await getUser(id)
const posts = await getPosts(id)
const comments = await getComments(id)

// ✅ Parallel - fast
const [user, posts, comments] = await Promise.all([
  getUser(id),
  getPosts(id),
  getComments(id),
])
```

### Streaming with Suspense

```tsx
import { Suspense } from 'react'

export default function Page() {
  return (
    <div>
      <h1>Dashboard</h1>

      {/* Shows immediately */}
      <QuickStats />

      {/* Streams in when ready */}
      <Suspense fallback={<ChartSkeleton />}>
        <SlowChart />
      </Suspense>

      <Suspense fallback={<TableSkeleton />}>
        <SlowTable />
      </Suspense>
    </div>
  )
}
```

### Cache Expensive Operations

```typescript
import { cache } from 'react'

// Deduplicated within a request
export const getUser = cache(async (id: string) => {
  const user = await db.user.findUnique({ where: { id } })
  return user
})

// Multiple components can call getUser(id)
// Only one database query happens
```

---

## CSS & Styling

### Tailwind CSS Optimization

Tailwind automatically purges unused CSS in production.

Ensure `content` paths are correct:

```javascript
// tailwind.config.js
module.exports = {
  content: [
    './src/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  // ...
}
```

### Avoid CSS-in-JS Runtime

```tsx
// ❌ Runtime CSS-in-JS (adds JS, slower)
import styled from 'styled-components'
const Button = styled.button`...`

// ✅ Tailwind (compile-time, no runtime)
<button className="px-4 py-2 bg-blue-500">Click</button>

// ✅ CSS Modules (compile-time)
import styles from './Button.module.css'
<button className={styles.button}>Click</button>
```

### Critical CSS

Next.js automatically inlines critical CSS. Help it by:

- Keeping above-the-fold styles minimal
- Avoiding large global stylesheets
- Using component-scoped styles

---

## Third-Party Scripts

### Load Scripts Efficiently

```tsx
import Script from 'next/script'

// ✅ Load after page is interactive
<Script
  src="https://analytics.example.com/script.js"
  strategy="afterInteractive"
/>

// ✅ Load when browser is idle
<Script
  src="https://widget.example.com/widget.js"
  strategy="lazyOnload"
/>

// ✅ Load before page hydrates (rare)
<Script
  src="https://critical.example.com/script.js"
  strategy="beforeInteractive"
/>
```

### Script Loading Strategies

| Strategy | When to Use |
|----------|-------------|
| `beforeInteractive` | Critical scripts (auth, A/B testing) |
| `afterInteractive` | Analytics, chat widgets |
| `lazyOnload` | Low-priority (social embeds) |
| `worker` | Offload to web worker (experimental) |

---

## Font Optimization

### Use next/font

```tsx
// app/layout.tsx
import { Inter } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
})

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={inter.variable}>
      <body>{children}</body>
    </html>
  )
}
```

Benefits:
- Self-hosted (no external requests)
- Automatic subsetting
- No layout shift (`display: swap`)
- Preloaded

### Font Best Practices

| Practice | Why |
|----------|-----|
| Limit font weights | Each weight = more KB |
| Use `display: swap` | Prevents invisible text |
| Subset to needed characters | Smaller file |
| Preload critical fonts | Faster initial render |

---

## React Performance

### Avoid Unnecessary Re-renders

```tsx
'use client'

import { memo, useCallback, useMemo } from 'react'

// Memoize expensive calculations
const sortedItems = useMemo(
  () => items.sort((a, b) => a.name.localeCompare(b.name)),
  [items]
)

// Memoize callbacks passed to children
const handleClick = useCallback((id: string) => {
  setSelected(id)
}, [])

// Memoize components that receive stable props
const ExpensiveList = memo(function ExpensiveList({ items, onSelect }) {
  return items.map(item => (
    <ExpensiveItem key={item.id} item={item} onSelect={onSelect} />
  ))
})
```

### When to Memoize

| Memoize | Don't Memoize |
|---------|---------------|
| Expensive calculations | Simple values |
| Callbacks to memoized children | Callbacks to DOM elements |
| Large list items | Small, fast components |
| Components with many props | Components that always re-render |

### Keys for Lists

```tsx
// ✅ Stable, unique key
{items.map(item => (
  <Item key={item.id} item={item} />
))}

// ❌ Index as key (causes issues with reordering)
{items.map((item, index) => (
  <Item key={index} item={item} />
))}

// ❌ Random key (forces remount every render)
{items.map(item => (
  <Item key={Math.random()} item={item} />
))}
```

---

## Database Performance

### Efficient Queries

```typescript
// ✅ Select only needed columns
const { data } = await supabase
  .from('posts')
  .select('id, title, created_at')  // Not select('*')
  .limit(10)

// ✅ Use indexes for filtered columns
const { data } = await supabase
  .from('posts')
  .select('*')
  .eq('user_id', userId)  // user_id should be indexed
  .order('created_at', { ascending: false })
  .limit(20)

// ✅ Paginate large results
const { data } = await supabase
  .from('posts')
  .select('*')
  .range(0, 19)  // First 20 items
```

### Avoid N+1 Queries

```typescript
// ❌ N+1 - one query per post
const posts = await getPosts()
for (const post of posts) {
  post.author = await getUser(post.author_id)  // N queries!
}

// ✅ Join in single query
const { data } = await supabase
  .from('posts')
  .select(`
    *,
    author:users(id, name, avatar)
  `)
```

---

## Quick Wins Checklist

### Before Launch

- [ ] Run Lighthouse, fix critical issues
- [ ] Analyze bundle, remove unused dependencies
- [ ] Optimize images (WebP, proper sizes)
- [ ] Enable caching headers
- [ ] Test on slow 3G network

### Easy Improvements

- [ ] Add `priority` to LCP image
- [ ] Use Server Components where possible
- [ ] Dynamic import heavy components
- [ ] Lazy load below-fold content
- [ ] Use `next/font` for fonts

### Ongoing

- [ ] Monitor Core Web Vitals
- [ ] Review bundle size on PRs
- [ ] Profile slow interactions
- [ ] Test on real devices

---

*See also: [Cold Start Prevention](cold-start.md) · [Monitoring](monitoring.md)*
