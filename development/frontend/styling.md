# Styling & shadcn/ui Standards

*How we style applications at Friends Innovation Lab.*

---

## Our Styling Stack

| Tool | Purpose |
|------|---------|
| **Tailwind CSS** | Utility-first CSS framework |
| **shadcn/ui** | Accessible, customizable component library |
| **CSS Variables** | Design tokens (colors, spacing, etc.) |
| **cn() helper** | Merge Tailwind classes conditionally |

---

## shadcn/ui Setup

### Initial Setup

```bash
# Initialize shadcn/ui in a new project
npx shadcn@latest init

# Options:
# - Style: Default
# - Base color: Slate (or your preference)
# - CSS variables: Yes
# - tailwind.config.js location: tailwind.config.ts
# - Components location: @/components
# - Utils location: @/lib/utils
```

### Adding Components

```bash
# Add individual components
npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add input
npx shadcn@latest add dialog

# Add multiple at once
npx shadcn@latest add button card input dialog

# Add all components (use sparingly)
npx shadcn@latest add -a
```

### Recommended Base Components

Add these to every project:

```bash
npx shadcn@latest add button card input label textarea select checkbox radio-group switch dialog alert alert-dialog dropdown-menu toast skeleton avatar badge separator
```

---

## Using shadcn/ui Components

### Basic Usage

```tsx
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"

export function LoginForm() {
  return (
    <Card className="w-96">
      <CardHeader>
        <CardTitle>Login</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="space-y-2">
          <Label htmlFor="email">Email</Label>
          <Input id="email" type="email" placeholder="you@example.com" />
        </div>
        <div className="space-y-2">
          <Label htmlFor="password">Password</Label>
          <Input id="password" type="password" />
        </div>
        <Button className="w-full">Sign In</Button>
      </CardContent>
    </Card>
  )
}
```

### Component Variants

shadcn/ui components use variants for different styles.

```tsx
// Button variants
<Button variant="default">Default</Button>
<Button variant="secondary">Secondary</Button>
<Button variant="outline">Outline</Button>
<Button variant="ghost">Ghost</Button>
<Button variant="link">Link</Button>
<Button variant="destructive">Destructive</Button>

// Button sizes
<Button size="default">Default</Button>
<Button size="sm">Small</Button>
<Button size="lg">Large</Button>
<Button size="icon"><IconComponent /></Button>
```

### Extending Components

Since shadcn/ui components are in your codebase, you can modify them directly.

```tsx
// components/ui/button.tsx
// Add a new variant
const buttonVariants = cva(
  "...",
  {
    variants: {
      variant: {
        default: "...",
        // Add your custom variant
        success: "bg-green-600 text-white hover:bg-green-700",
      },
    },
  }
)

// Usage
<Button variant="success">Save</Button>
```

---

## Tailwind Conventions

### Class Order

Follow a consistent order for readability:

```tsx
<div className="
  // 1. Layout (position, display, flex/grid)
  relative flex items-center justify-between

  // 2. Sizing (width, height)
  w-full h-16

  // 3. Spacing (margin, padding)
  mx-auto px-4 py-2

  // 4. Typography
  text-sm font-medium text-gray-900

  // 5. Visual (background, border, shadow)
  bg-white border border-gray-200 rounded-lg shadow-sm

  // 6. Interactive (hover, focus, transition)
  hover:bg-gray-50 focus:ring-2 transition-colors
">
```

In practice, keep it on one line if short:

```tsx
<div className="flex items-center gap-2 p-4 bg-white rounded-lg">
```

### Responsive Design

Mobile-first. Add breakpoints for larger screens.

```tsx
// Mobile: stack, Tablet+: row
<div className="flex flex-col md:flex-row gap-4">

// Mobile: full width, Desktop: half
<div className="w-full lg:w-1/2">

// Mobile: hidden, Desktop: visible
<nav className="hidden md:flex">

// Mobile: 1 column, Tablet: 2, Desktop: 3
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
```

Breakpoints:
- `sm`: 640px
- `md`: 768px
- `lg`: 1024px
- `xl`: 1280px
- `2xl`: 1536px

### Spacing Scale

Use Tailwind's spacing scale consistently.

| Class | Size | Use For |
|-------|------|---------|
| `gap-1`, `p-1` | 4px | Tight spacing |
| `gap-2`, `p-2` | 8px | Related elements |
| `gap-4`, `p-4` | 16px | Standard spacing |
| `gap-6`, `p-6` | 24px | Section padding |
| `gap-8`, `p-8` | 32px | Large sections |

```tsx
// Consistent spacing
<Card className="p-6">
  <CardHeader className="pb-4">
    <CardTitle>Title</CardTitle>
  </CardHeader>
  <CardContent className="space-y-4">
    <Input />
    <Input />
    <Button>Submit</Button>
  </CardContent>
</Card>
```

---

## cn() Helper

The `cn()` function merges Tailwind classes and handles conflicts.

```tsx
// lib/utils.ts
import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

### Usage

```tsx
import { cn } from "@/lib/utils"

// Conditional classes
<div className={cn(
  "p-4 rounded-lg",
  isActive && "bg-primary text-primary-foreground",
  isDisabled && "opacity-50 cursor-not-allowed"
)}>

// Merging with props
interface CardProps {
  className?: string
  children: React.ReactNode
}

function CustomCard({ className, children }: CardProps) {
  return (
    <div className={cn("p-4 bg-white rounded-lg shadow", className)}>
      {children}
    </div>
  )
}

// Usage - className prop overrides defaults
<CustomCard className="bg-blue-50">Content</CustomCard>
```

---

## CSS Variables (Design Tokens)

shadcn/ui uses CSS variables for theming.

### Default Variables

```css
/* globals.css */
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    --secondary: 210 40% 96%;
    --secondary-foreground: 222.2 47.4% 11.2%;
    --muted: 210 40% 96%;
    --muted-foreground: 215.4 16.3% 46.9%;
    --accent: 210 40% 96%;
    --accent-foreground: 222.2 47.4% 11.2%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;
    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 222.2 84% 4.9%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    /* ... dark mode values */
  }
}
```

### Using Variables in Tailwind

```tsx
// These classes use CSS variables automatically
<div className="bg-background text-foreground">
<div className="bg-primary text-primary-foreground">
<div className="bg-muted text-muted-foreground">
<div className="border-border">
<div className="text-destructive">
```

### Customizing Theme Colors

Edit CSS variables to match your brand:

```css
/* globals.css */
:root {
  /* Change primary to your brand color */
  --primary: 220 90% 56%;        /* Blue */
  --primary-foreground: 0 0% 100%;

  /* Adjust radius for sharper/rounder corners */
  --radius: 0.75rem;
}
```

---

## Common Patterns

### Page Layout

```tsx
// app/layout.tsx
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body className="min-h-screen bg-background font-sans antialiased">
        <div className="relative flex min-h-screen flex-col">
          <Header />
          <main className="flex-1">{children}</main>
          <Footer />
        </div>
      </body>
    </html>
  )
}
```

### Container

```tsx
// Centered content with max width
<div className="container mx-auto px-4">
  {/* Content */}
</div>

// Or with custom max width
<div className="mx-auto max-w-4xl px-4">
  {/* Content */}
</div>
```

### Card Grid

```tsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  {items.map(item => (
    <Card key={item.id}>
      <CardHeader>
        <CardTitle>{item.title}</CardTitle>
      </CardHeader>
      <CardContent>
        <p className="text-muted-foreground">{item.description}</p>
      </CardContent>
    </Card>
  ))}
</div>
```

### Form Layout

```tsx
<form className="space-y-6">
  {/* Form fields with consistent spacing */}
  <div className="space-y-2">
    <Label htmlFor="name">Name</Label>
    <Input id="name" />
  </div>

  <div className="space-y-2">
    <Label htmlFor="email">Email</Label>
    <Input id="email" type="email" />
  </div>

  {/* Two columns on larger screens */}
  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
    <div className="space-y-2">
      <Label htmlFor="city">City</Label>
      <Input id="city" />
    </div>
    <div className="space-y-2">
      <Label htmlFor="state">State</Label>
      <Input id="state" />
    </div>
  </div>

  {/* Actions */}
  <div className="flex justify-end gap-2">
    <Button variant="outline">Cancel</Button>
    <Button type="submit">Save</Button>
  </div>
</form>
```

### Empty State

```tsx
<div className="flex flex-col items-center justify-center py-12 text-center">
  <div className="rounded-full bg-muted p-4 mb-4">
    <InboxIcon className="h-8 w-8 text-muted-foreground" />
  </div>
  <h3 className="text-lg font-semibold">No projects yet</h3>
  <p className="text-muted-foreground mt-1 mb-4">
    Get started by creating your first project.
  </p>
  <Button>Create Project</Button>
</div>
```

### Loading State

```tsx
import { Skeleton } from "@/components/ui/skeleton"

// Card skeleton
<Card>
  <CardHeader>
    <Skeleton className="h-6 w-48" />
  </CardHeader>
  <CardContent className="space-y-2">
    <Skeleton className="h-4 w-full" />
    <Skeleton className="h-4 w-3/4" />
  </CardContent>
</Card>

// List skeleton
<div className="space-y-4">
  {[1, 2, 3].map(i => (
    <div key={i} className="flex items-center gap-4">
      <Skeleton className="h-12 w-12 rounded-full" />
      <div className="space-y-2">
        <Skeleton className="h-4 w-32" />
        <Skeleton className="h-3 w-24" />
      </div>
    </div>
  ))}
</div>
```

### Status Badges

```tsx
import { Badge } from "@/components/ui/badge"

// Using variants
<Badge variant="default">Active</Badge>
<Badge variant="secondary">Pending</Badge>
<Badge variant="destructive">Failed</Badge>
<Badge variant="outline">Draft</Badge>

// Custom status colors (extend in badge.tsx)
<Badge className="bg-green-100 text-green-800">Complete</Badge>
<Badge className="bg-yellow-100 text-yellow-800">In Progress</Badge>
<Badge className="bg-red-100 text-red-800">Blocked</Badge>
```

---

## Dark Mode

### Setup with next-themes

```bash
npm install next-themes
```

```tsx
// app/providers.tsx
'use client'

import { ThemeProvider } from 'next-themes'

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
      {children}
    </ThemeProvider>
  )
}

// app/layout.tsx
import { Providers } from './providers'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}
```

### Theme Toggle

```tsx
'use client'

import { useTheme } from 'next-themes'
import { Button } from '@/components/ui/button'
import { Moon, Sun } from 'lucide-react'

export function ThemeToggle() {
  const { theme, setTheme } = useTheme()

  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
    >
      <Sun className="h-5 w-5 rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
      <Moon className="absolute h-5 w-5 rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
      <span className="sr-only">Toggle theme</span>
    </Button>
  )
}
```

---

## Icons

Use **Lucide React** (included with shadcn/ui).

```tsx
import {
  Home,
  User,
  Settings,
  Plus,
  Trash,
  Edit,
  ChevronRight,
  Loader2
} from 'lucide-react'

// Basic usage
<Home className="h-5 w-5" />

// With button
<Button>
  <Plus className="h-4 w-4 mr-2" />
  Add Item
</Button>

// Icon button
<Button variant="ghost" size="icon">
  <Settings className="h-5 w-5" />
</Button>

// Loading spinner
<Button disabled>
  <Loader2 className="h-4 w-4 mr-2 animate-spin" />
  Loading...
</Button>
```

---

## Typography

### Headings

```tsx
<h1 className="text-4xl font-bold tracking-tight">Page Title</h1>
<h2 className="text-3xl font-semibold tracking-tight">Section Title</h2>
<h3 className="text-2xl font-semibold">Subsection</h3>
<h4 className="text-xl font-semibold">Card Title</h4>
```

### Body Text

```tsx
<p className="text-base text-foreground">Regular paragraph text</p>
<p className="text-sm text-muted-foreground">Secondary/helper text</p>
<p className="text-xs text-muted-foreground">Fine print</p>
```

### Links

```tsx
<a className="text-primary underline-offset-4 hover:underline">Link text</a>

// Or use Button as link
<Button variant="link" asChild>
  <Link href="/about">Learn more</Link>
</Button>
```

---

## Animation

### Built-in Transitions

```tsx
// Color transition
<button className="bg-primary hover:bg-primary/90 transition-colors">

// All transitions
<div className="transition-all hover:scale-105 hover:shadow-lg">

// Opacity
<div className="opacity-0 group-hover:opacity-100 transition-opacity">
```

### Tailwind Animations

```tsx
// Spin (loading)
<Loader2 className="animate-spin" />

// Pulse (skeleton)
<div className="animate-pulse bg-muted h-4 w-32 rounded" />

// Bounce
<div className="animate-bounce">👆</div>
```

### Custom Animations

```js
// tailwind.config.ts
module.exports = {
  theme: {
    extend: {
      keyframes: {
        "fade-in": {
          "0%": { opacity: "0", transform: "translateY(10px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
      },
      animation: {
        "fade-in": "fade-in 0.3s ease-out",
      },
    },
  },
}

// Usage
<div className="animate-fade-in">Content</div>
```

---

## Don't Do This

| ❌ Don't | ✅ Do Instead |
|----------|---------------|
| Inline styles | Tailwind classes |
| `style={{ marginTop: 16 }}` | `className="mt-4"` |
| Create custom CSS files | Use Tailwind utilities |
| `!important` | Fix specificity with proper class order |
| Arbitrary values everywhere | Use design tokens / scale |
| `className="mt-[17px]"` | `className="mt-4"` (stick to scale) |
| Override shadcn internally | Extend via className prop |
| Mix styling approaches | Pick one (Tailwind + shadcn) |

---

## File Organization

```
src/
├── app/
│   └── globals.css          # CSS variables, base styles
├── components/
│   └── ui/                   # shadcn/ui components
│       ├── button.tsx
│       ├── card.tsx
│       └── ...
├── lib/
│   └── utils.ts              # cn() helper
└── tailwind.config.ts        # Tailwind configuration
```

---

*See also: [React](react.md) · [Next.js](nextjs.md) · [Accessibility](accessibility.md)*
