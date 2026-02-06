# UI/UX & Interaction Design Guide

*The complete visual toolkit for building professional prototypes fast*

---

## How to Use This Guide

This guide has three purposes:

1. **Reference** - Look up patterns, components, and code when building
2. **Vocabulary** - Learn how to describe what you want to Claude Code
3. **Speed** - Copy/paste code blocks directly into projects

Everything here uses Tailwind CSS and works with your Next.js template.

---

# Part 1: Foundations

---

## 1. Design System Foundations

### Color System

Your template includes a `brand` color scale. Customize per client:

```typescript
// tailwind.config.ts
colors: {
  brand: {
    50: '#f0f9ff',   // Lightest - backgrounds
    100: '#e0f2fe',  // Light - hover backgrounds
    200: '#bae6fd',  // Light accents
    300: '#7dd3fc',  // 
    400: '#38bdf8',  // 
    500: '#0ea5e9',  // Primary - buttons, links
    600: '#0284c7',  // Primary hover
    700: '#0369a1',  // Dark accents
    800: '#075985',  // 
    900: '#0c4a6e',  // Darkest - text on light
    950: '#082f49',  // Near black
  }
}
```

**Generate a palette from any color:** https://uicolors.app/create

**Semantic colors (add these too):**

```typescript
colors: {
  // Status colors
  success: {
    50: '#f0fdf4',
    500: '#22c55e',
    700: '#15803d',
  },
  warning: {
    50: '#fffbeb',
    500: '#f59e0b',
    700: '#b45309',
  },
  error: {
    50: '#fef2f2',
    500: '#ef4444',
    700: '#b91c1c',
  },
  info: {
    50: '#eff6ff',
    500: '#3b82f6',
    700: '#1d4ed8',
  }
}
```

---

### Typography Scale

Use Tailwind's default scale consistently:

| Class | Size | Use for |
|-------|------|---------|
| `text-xs` | 12px | Labels, captions, metadata |
| `text-sm` | 14px | Secondary text, table cells |
| `text-base` | 16px | Body text (default) |
| `text-lg` | 18px | Lead paragraphs, emphasis |
| `text-xl` | 20px | Card titles, section headers |
| `text-2xl` | 24px | Page section titles |
| `text-3xl` | 30px | Page titles |
| `text-4xl` | 36px | Hero headlines |
| `text-5xl` | 48px | Marketing headlines |

**Font weights:**

| Class | Weight | Use for |
|-------|--------|---------|
| `font-normal` | 400 | Body text |
| `font-medium` | 500 | Emphasis, labels |
| `font-semibold` | 600 | Subheadings, buttons |
| `font-bold` | 700 | Headings, strong emphasis |

---

### Spacing System

Use Tailwind's 4px base grid consistently:

| Class | Size | Use for |
|-------|------|---------|
| `p-1` / `m-1` | 4px | Tight spacing, icon padding |
| `p-2` / `m-2` | 8px | Compact elements |
| `p-3` / `m-3` | 12px | Button padding |
| `p-4` / `m-4` | 16px | Card padding, standard gaps |
| `p-6` / `m-6` | 24px | Section padding |
| `p-8` / `m-8` | 32px | Large section padding |
| `p-12` / `m-12` | 48px | Page sections |
| `p-16` / `m-16` | 64px | Hero sections |

**Gaps in flex/grid:**

```html
<div class="flex gap-2">  <!-- 8px between items -->
<div class="flex gap-4">  <!-- 16px between items -->
<div class="grid gap-6">  <!-- 24px between items -->
```

---

### Border Radius

| Class | Radius | Feel |
|-------|--------|------|
| `rounded-none` | 0px | Sharp, technical, gov |
| `rounded-sm` | 2px | Subtle softness |
| `rounded` | 4px | Default, professional |
| `rounded-md` | 6px | Slightly softer |
| `rounded-lg` | 8px | Friendly, modern |
| `rounded-xl` | 12px | Very friendly |
| `rounded-2xl` | 16px | Soft, approachable |
| `rounded-full` | 9999px | Pills, avatars, tags |

---

### Shadows

| Class | Use for |
|-------|---------|
| `shadow-sm` | Subtle lift, cards |
| `shadow` | Default elevation |
| `shadow-md` | Dropdowns, popovers |
| `shadow-lg` | Modals, prominent cards |
| `shadow-xl` | Floating elements |

**For a flat/border-based design (gov style):**
```html
<div class="border border-gray-200">  <!-- Instead of shadow -->
```

---

## 2. Visual Vocabulary Cheat Sheet

How to describe what you want to Claude Code:

### Mood → Tailwind Translation

| What you want | How to describe it | Key Tailwind classes |
|---------------|-------------------|---------------------|
| Light and airy | "Lots of white space, light backgrounds, subtle shadows" | `bg-gray-50`, `p-8`, `gap-6`, `shadow-sm` |
| Dark and premium | "Dark color scheme, generous padding, subtle accents" | `bg-gray-900`, `text-white`, `p-8`, `border-gray-800` |
| Friendly and approachable | "Rounded corners, warm colors, playful spacing" | `rounded-xl`, `bg-orange-50`, `text-orange-900` |
| Sharp and modern | "High contrast, sharp edges, bold typography" | `rounded-none`, `font-bold`, `text-4xl`, `bg-black` |
| Clean and minimal | "Minimal decoration, lots of space, subtle borders" | `border`, `p-6`, `gap-4`, `text-gray-600` |
| Professional/corporate | "Structured, conventional, clear hierarchy" | `rounded-md`, `shadow-sm`, `font-medium` |
| Government/official | "Accessible, no-frills, USWDS-inspired" | `rounded-sm`, `border`, `font-sans`, blue palette |

---

### Spacing Vocabulary

| What you say | What it means |
|--------------|---------------|
| "Spacious" / "breathable" | `p-8`, `gap-6`, `my-12` |
| "Compact" / "dense" | `p-2`, `gap-2`, `text-sm` |
| "Tight" | `p-1`, `gap-1`, `leading-tight` |
| "Generous padding" | `p-8` or `p-12` |
| "Comfortable spacing" | `p-4`, `gap-4` |

---

### Shape Vocabulary

| What you say | What it means |
|--------------|---------------|
| "Soft" / "friendly" | `rounded-xl`, `rounded-2xl` |
| "Sharp" / "crisp" | `rounded-none`, `rounded-sm` |
| "Rounded buttons" | `rounded-lg` or `rounded-full` |
| "Pill-shaped" | `rounded-full` on buttons/tags |
| "Subtle rounding" | `rounded-md` |

---

### Depth Vocabulary

| What you say | What it means |
|--------------|---------------|
| "Flat design" | No shadows, use borders instead |
| "Elevated" / "floating" | `shadow-md`, `shadow-lg` |
| "Subtle lift" | `shadow-sm` |
| "Layered" | Multiple z-index levels, overlapping elements |
| "Card-based" | `bg-white shadow-sm rounded-lg p-6` |

---

### Color Vocabulary

| What you say | What it means |
|--------------|---------------|
| "Muted" | Low saturation colors, `-400`, `-500` range |
| "Vibrant" / "bold" | High saturation, `-500`, `-600` range |
| "Pastel" | Light tints, `-50`, `-100`, `-200` range |
| "High contrast" | Dark text on light, or light on dark |
| "Monochrome" | Single color with shades, or just grays |
| "Accent color" | One pop of color against neutral background |

---

## 3. Style Recipes

Pre-built combinations for common styles:

### SaaS Dashboard

```typescript
// tailwind.config.ts
colors: {
  brand: { /* blue or purple scale */ }
}
```

```html
<!-- Layout -->
<div class="flex min-h-screen">
  <!-- Sidebar -->
  <aside class="w-64 bg-gray-900 text-white">
  
  <!-- Main -->
  <main class="flex-1 bg-gray-50 p-8">
    <!-- Cards -->
    <div class="bg-white rounded-lg shadow-sm p-6">
```

**Characteristics:**
- Dark sidebar, light content area
- Cards with subtle shadows
- Blue or purple accent
- `rounded-lg` on cards
- Clean sans-serif font

---

### Friendly Small Business Tool

```typescript
colors: {
  brand: { /* teal, coral, or warm tone */ }
}
```

```html
<!-- Layout -->
<div class="min-h-screen bg-gradient-to-b from-orange-50 to-white">
  <!-- Header -->
  <header class="bg-white shadow-sm">
  
  <!-- Cards -->
  <div class="bg-white rounded-2xl shadow-md p-6">
  
  <!-- Buttons -->
  <button class="bg-brand-500 text-white rounded-full px-6 py-3">
```

**Characteristics:**
- Warm background tint
- Extra rounded corners (`rounded-2xl`)
- Rounded-full buttons
- Friendly typography (consider Nunito, Poppins)
- Warmer shadows

---

### Government / USWDS-Inspired

```typescript
colors: {
  primary: '#005ea2',      // USWDS blue
  'primary-dark': '#1a4480',
  secondary: '#d83933',    // USWDS red
  base: {
    lightest: '#f0f0f0',
    lighter: '#dfe1e2',
    light: '#a9aeb1',
    DEFAULT: '#71767a',
    dark: '#565c65',
    darker: '#3d4551',
    darkest: '#1b1b1b',
  }
}
```

```html
<!-- Layout -->
<div class="min-h-screen bg-white">
  <!-- Header -->
  <header class="bg-primary-dark text-white">
  
  <!-- Cards use borders, not shadows -->
  <div class="border border-base-lighter p-6">
  
  <!-- Buttons -->
  <button class="bg-primary text-white rounded px-5 py-3 font-bold">
  
  <!-- Alerts -->
  <div class="border-l-4 border-primary bg-primary/5 p-4">
```

**Characteristics:**
- Borders instead of shadows (accessibility)
- Sharp or slightly rounded corners
- USWDS blue (#005ea2) primary
- High contrast text
- Clear focus states
- Public Sans or Source Sans font

---

### Premium / Luxury

```typescript
colors: {
  brand: { /* gold, emerald, or deep navy */ },
  gold: '#b8860b',
}
```

```html
<!-- Layout -->
<div class="min-h-screen bg-gray-950 text-white">
  <!-- Or light premium -->
<div class="min-h-screen bg-stone-50 text-gray-900">
  
  <!-- Cards -->
  <div class="bg-gray-900 border border-gray-800 p-8">
  
  <!-- Typography -->
  <h1 class="font-serif text-4xl tracking-tight">
  
  <!-- Accent -->
  <span class="text-gold">
  
  <!-- Buttons -->
  <button class="border border-gold text-gold hover:bg-gold hover:text-black px-8 py-3 transition-all duration-300">
```

**Characteristics:**
- Dark backgrounds or warm stone/cream
- Serif headings (Playfair Display, Merriweather)
- Gold or muted accent color
- Generous whitespace
- Slow, smooth transitions (`duration-300`, `duration-500`)
- Subtle borders

---

### Startup / Bold Modern

```typescript
colors: {
  brand: { /* bright, saturated color */ }
}
```

```html
<!-- Layout -->
<div class="min-h-screen bg-white">
  <!-- Hero with gradient -->
  <section class="bg-gradient-to-r from-brand-500 to-purple-600 text-white py-24">
  
  <!-- Big bold text -->
  <h1 class="text-6xl font-black tracking-tight">
  
  <!-- Cards with color -->
  <div class="bg-brand-50 border-2 border-brand-200 rounded-xl p-6">
```

**Characteristics:**
- Bold gradients
- Extra large typography
- High saturation colors
- Asymmetric layouts
- Motion and interaction

---

## 4. Layout Templates

### Dashboard Layout (Sidebar)

```tsx
// components/layouts/DashboardLayout.tsx
export function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen bg-gray-50">
      {/* Sidebar */}
      <aside className="w-64 bg-gray-900 text-white flex flex-col">
        {/* Logo */}
        <div className="p-6 border-b border-gray-800">
          <span className="text-xl font-bold">AppName</span>
        </div>
        
        {/* Navigation */}
        <nav className="flex-1 p-4">
          <ul className="space-y-2">
            <li>
              <a href="#" className="flex items-center gap-3 px-4 py-2 rounded-lg bg-gray-800 text-white">
                <HomeIcon className="w-5 h-5" />
                Dashboard
              </a>
            </li>
            <li>
              <a href="#" className="flex items-center gap-3 px-4 py-2 rounded-lg text-gray-400 hover:bg-gray-800 hover:text-white transition-colors">
                <UsersIcon className="w-5 h-5" />
                Users
              </a>
            </li>
            {/* More nav items */}
          </ul>
        </nav>
        
        {/* User menu */}
        <div className="p-4 border-t border-gray-800">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-gray-700" />
            <div>
              <p className="font-medium">User Name</p>
              <p className="text-sm text-gray-400">user@email.com</p>
            </div>
          </div>
        </div>
      </aside>
      
      {/* Main content */}
      <main className="flex-1 flex flex-col">
        {/* Top bar */}
        <header className="bg-white border-b border-gray-200 px-8 py-4">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-semibold text-gray-900">Page Title</h1>
            <button className="bg-brand-500 text-white px-4 py-2 rounded-lg hover:bg-brand-600 transition-colors">
              Action
            </button>
          </div>
        </header>
        
        {/* Page content */}
        <div className="flex-1 p-8">
          {children}
        </div>
      </main>
    </div>
  )
}
```

---

### Dashboard Layout (Top Nav)

```tsx
// components/layouts/TopNavLayout.tsx
export function TopNavLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Top navigation */}
      <header className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            {/* Logo */}
            <div className="flex items-center gap-8">
              <span className="text-xl font-bold text-gray-900">AppName</span>
              
              {/* Nav links */}
              <nav className="hidden md:flex items-center gap-6">
                <a href="#" className="text-gray-900 font-medium">Dashboard</a>
                <a href="#" className="text-gray-500 hover:text-gray-900">Projects</a>
                <a href="#" className="text-gray-500 hover:text-gray-900">Reports</a>
                <a href="#" className="text-gray-500 hover:text-gray-900">Settings</a>
              </nav>
            </div>
            
            {/* Right side */}
            <div className="flex items-center gap-4">
              <button className="p-2 text-gray-400 hover:text-gray-600">
                <BellIcon className="w-6 h-6" />
              </button>
              <div className="w-10 h-10 rounded-full bg-gray-200" />
            </div>
          </div>
        </div>
      </header>
      
      {/* Page content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {children}
      </main>
    </div>
  )
}
```

---

### Form Page Layout

```tsx
// components/layouts/FormLayout.tsx
export function FormLayout({ 
  title, 
  description, 
  children 
}: { 
  title: string
  description?: string
  children: React.ReactNode 
}) {
  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <div className="max-w-2xl mx-auto px-4">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">{title}</h1>
          {description && (
            <p className="mt-2 text-gray-600">{description}</p>
          )}
        </div>
        
        {/* Form card */}
        <div className="bg-white rounded-xl shadow-sm p-8">
          {children}
        </div>
      </div>
    </div>
  )
}
```

---

### Split Layout (Auth Pages)

```tsx
// components/layouts/SplitLayout.tsx
export function SplitLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen flex">
      {/* Left - Branding */}
      <div className="hidden lg:flex lg:w-1/2 bg-brand-600 text-white p-12 flex-col justify-between">
        <div>
          <span className="text-2xl font-bold">AppName</span>
        </div>
        <div>
          <h2 className="text-4xl font-bold mb-4">
            Welcome back
          </h2>
          <p className="text-brand-100 text-lg">
            Sign in to continue to your dashboard.
          </p>
        </div>
        <div className="text-brand-200 text-sm">
          © 2025 Company Name
        </div>
      </div>
      
      {/* Right - Form */}
      <div className="flex-1 flex items-center justify-center p-8">
        <div className="w-full max-w-md">
          {children}
        </div>
      </div>
    </div>
  )
}
```

---

### Marketing / Landing Page Layout

```tsx
// components/layouts/MarketingLayout.tsx
export function MarketingLayout({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-screen">
      {/* Navigation */}
      <header className="absolute top-0 left-0 right-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-20">
            <span className="text-xl font-bold">AppName</span>
            <nav className="hidden md:flex items-center gap-8">
              <a href="#" className="text-gray-600 hover:text-gray-900">Features</a>
              <a href="#" className="text-gray-600 hover:text-gray-900">Pricing</a>
              <a href="#" className="text-gray-600 hover:text-gray-900">About</a>
              <a href="#" className="bg-brand-500 text-white px-4 py-2 rounded-lg">
                Get Started
              </a>
            </nav>
          </div>
        </div>
      </header>
      
      {/* Page content */}
      <main>
        {children}
      </main>
      
      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <p className="text-gray-400">© 2025 Company Name. All rights reserved.</p>
        </div>
      </footer>
    </div>
  )
}
```

---

# Part 2: Components

---

## 5. Component Library

### Buttons

```tsx
// components/ui/Button.tsx
import { cn } from '@/lib/utils'

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'destructive'
  size?: 'sm' | 'md' | 'lg'
}

export function Button({ 
  variant = 'primary', 
  size = 'md', 
  className, 
  children, 
  ...props 
}: ButtonProps) {
  return (
    <button
      className={cn(
        // Base styles
        'inline-flex items-center justify-center font-medium transition-colors',
        'focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-brand-500',
        'disabled:opacity-50 disabled:cursor-not-allowed',
        
        // Variants
        variant === 'primary' && 'bg-brand-500 text-white hover:bg-brand-600',
        variant === 'secondary' && 'bg-gray-100 text-gray-900 hover:bg-gray-200',
        variant === 'outline' && 'border border-gray-300 bg-transparent hover:bg-gray-50',
        variant === 'ghost' && 'bg-transparent hover:bg-gray-100',
        variant === 'destructive' && 'bg-red-500 text-white hover:bg-red-600',
        
        // Sizes
        size === 'sm' && 'text-sm px-3 py-1.5 rounded-md',
        size === 'md' && 'text-sm px-4 py-2 rounded-lg',
        size === 'lg' && 'text-base px-6 py-3 rounded-lg',
        
        className
      )}
      {...props}
    >
      {children}
    </button>
  )
}
```

**Usage:**
```tsx
<Button>Primary</Button>
<Button variant="secondary">Secondary</Button>
<Button variant="outline">Outline</Button>
<Button variant="destructive">Delete</Button>
<Button size="lg">Large Button</Button>
<Button disabled>Disabled</Button>
```

---

### Input Fields

```tsx
// components/ui/Input.tsx
import { cn } from '@/lib/utils'

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string
  error?: string
  hint?: string
}

export function Input({ 
  label, 
  error, 
  hint, 
  className, 
  id,
  ...props 
}: InputProps) {
  const inputId = id || label?.toLowerCase().replace(/\s/g, '-')
  
  return (
    <div className="space-y-1">
      {label && (
        <label htmlFor={inputId} className="block text-sm font-medium text-gray-700">
          {label}
        </label>
      )}
      <input
        id={inputId}
        className={cn(
          'block w-full rounded-lg border px-3 py-2 text-sm',
          'focus:outline-none focus:ring-2 focus:ring-offset-0 focus:ring-brand-500',
          'placeholder:text-gray-400',
          error 
            ? 'border-red-500 focus:ring-red-500' 
            : 'border-gray-300',
          className
        )}
        {...props}
      />
      {hint && !error && (
        <p className="text-sm text-gray-500">{hint}</p>
      )}
      {error && (
        <p className="text-sm text-red-500">{error}</p>
      )}
    </div>
  )
}
```

---

### Select Dropdown

```tsx
// components/ui/Select.tsx
import { cn } from '@/lib/utils'

interface SelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  label?: string
  error?: string
  options: { value: string; label: string }[]
}

export function Select({ 
  label, 
  error, 
  options, 
  className, 
  id,
  ...props 
}: SelectProps) {
  const selectId = id || label?.toLowerCase().replace(/\s/g, '-')
  
  return (
    <div className="space-y-1">
      {label && (
        <label htmlFor={selectId} className="block text-sm font-medium text-gray-700">
          {label}
        </label>
      )}
      <select
        id={selectId}
        className={cn(
          'block w-full rounded-lg border px-3 py-2 text-sm',
          'focus:outline-none focus:ring-2 focus:ring-offset-0 focus:ring-brand-500',
          error 
            ? 'border-red-500 focus:ring-red-500' 
            : 'border-gray-300',
          className
        )}
        {...props}
      >
        {options.map(option => (
          <option key={option.value} value={option.value}>
            {option.label}
          </option>
        ))}
      </select>
      {error && (
        <p className="text-sm text-red-500">{error}</p>
      )}
    </div>
  )
}
```

---

### Card Components

```tsx
// components/ui/Card.tsx
import { cn } from '@/lib/utils'

export function Card({ 
  children, 
  className,
  padding = 'md' 
}: { 
  children: React.ReactNode
  className?: string
  padding?: 'none' | 'sm' | 'md' | 'lg'
}) {
  return (
    <div
      className={cn(
        'bg-white rounded-xl shadow-sm border border-gray-100',
        padding === 'sm' && 'p-4',
        padding === 'md' && 'p-6',
        padding === 'lg' && 'p-8',
        className
      )}
    >
      {children}
    </div>
  )
}

export function CardHeader({ children, className }: { children: React.ReactNode; className?: string }) {
  return <div className={cn('mb-4', className)}>{children}</div>
}

export function CardTitle({ children, className }: { children: React.ReactNode; className?: string }) {
  return <h3 className={cn('text-lg font-semibold text-gray-900', className)}>{children}</h3>
}

export function CardDescription({ children, className }: { children: React.ReactNode; className?: string }) {
  return <p className={cn('text-sm text-gray-500 mt-1', className)}>{children}</p>
}

export function CardContent({ children, className }: { children: React.ReactNode; className?: string }) {
  return <div className={cn(className)}>{children}</div>
}

export function CardFooter({ children, className }: { children: React.ReactNode; className?: string }) {
  return <div className={cn('mt-6 flex items-center gap-3', className)}>{children}</div>
}
```

---

### Stat Card

```tsx
// components/ui/StatCard.tsx
import { cn } from '@/lib/utils'

interface StatCardProps {
  title: string
  value: string | number
  change?: string
  changeType?: 'positive' | 'negative' | 'neutral'
  icon?: React.ReactNode
}

export function StatCard({ title, value, change, changeType = 'neutral', icon }: StatCardProps) {
  return (
    <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
      <div className="flex items-center justify-between">
        <p className="text-sm font-medium text-gray-500">{title}</p>
        {icon && <div className="text-gray-400">{icon}</div>}
      </div>
      <p className="mt-2 text-3xl font-bold text-gray-900">{value}</p>
      {change && (
        <p className={cn(
          'mt-2 text-sm font-medium',
          changeType === 'positive' && 'text-green-600',
          changeType === 'negative' && 'text-red-600',
          changeType === 'neutral' && 'text-gray-500',
        )}>
          {change}
        </p>
      )}
    </div>
  )
}
```

---

### Badge

```tsx
// components/ui/Badge.tsx
import { cn } from '@/lib/utils'

interface BadgeProps {
  children: React.ReactNode
  variant?: 'default' | 'success' | 'warning' | 'error' | 'info'
  size?: 'sm' | 'md'
}

export function Badge({ children, variant = 'default', size = 'sm' }: BadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center font-medium rounded-full',
        size === 'sm' && 'text-xs px-2 py-0.5',
        size === 'md' && 'text-sm px-3 py-1',
        variant === 'default' && 'bg-gray-100 text-gray-700',
        variant === 'success' && 'bg-green-100 text-green-700',
        variant === 'warning' && 'bg-yellow-100 text-yellow-700',
        variant === 'error' && 'bg-red-100 text-red-700',
        variant === 'info' && 'bg-blue-100 text-blue-700',
      )}
    >
      {children}
    </span>
  )
}
```

---

### Alert

```tsx
// components/ui/Alert.tsx
import { cn } from '@/lib/utils'
import { CheckCircle, AlertTriangle, XCircle, Info } from 'lucide-react'

interface AlertProps {
  title?: string
  children: React.ReactNode
  variant?: 'success' | 'warning' | 'error' | 'info'
}

const icons = {
  success: CheckCircle,
  warning: AlertTriangle,
  error: XCircle,
  info: Info,
}

export function Alert({ title, children, variant = 'info' }: AlertProps) {
  const Icon = icons[variant]
  
  return (
    <div
      className={cn(
        'rounded-lg p-4 flex gap-3',
        variant === 'success' && 'bg-green-50 text-green-800',
        variant === 'warning' && 'bg-yellow-50 text-yellow-800',
        variant === 'error' && 'bg-red-50 text-red-800',
        variant === 'info' && 'bg-blue-50 text-blue-800',
      )}
    >
      <Icon className="w-5 h-5 flex-shrink-0 mt-0.5" />
      <div>
        {title && <p className="font-semibold">{title}</p>}
        <div className={cn(title && 'mt-1', 'text-sm')}>{children}</div>
      </div>
    </div>
  )
}
```

---

### Modal

```tsx
// components/ui/Modal.tsx
'use client'
import { useEffect } from 'react'
import { cn } from '@/lib/utils'
import { X } from 'lucide-react'

interface ModalProps {
  isOpen: boolean
  onClose: () => void
  title?: string
  children: React.ReactNode
  size?: 'sm' | 'md' | 'lg' | 'xl'
}

export function Modal({ isOpen, onClose, title, children, size = 'md' }: ModalProps) {
  useEffect(() => {
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose()
    }
    if (isOpen) {
      document.addEventListener('keydown', handleEscape)
      document.body.style.overflow = 'hidden'
    }
    return () => {
      document.removeEventListener('keydown', handleEscape)
      document.body.style.overflow = 'unset'
    }
  }, [isOpen, onClose])

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 z-50">
      <div className="absolute inset-0 bg-black/50" onClick={onClose} />
      <div className="absolute inset-0 flex items-center justify-center p-4">
        <div className={cn(
          'relative bg-white rounded-xl shadow-xl w-full',
          size === 'sm' && 'max-w-sm',
          size === 'md' && 'max-w-md',
          size === 'lg' && 'max-w-lg',
          size === 'xl' && 'max-w-xl',
        )}>
          {title && (
            <div className="flex items-center justify-between p-6 border-b border-gray-100">
              <h2 className="text-lg font-semibold text-gray-900">{title}</h2>
              <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
                <X className="w-5 h-5" />
              </button>
            </div>
          )}
          <div className="p-6">{children}</div>
        </div>
      </div>
    </div>
  )
}
```

---

# Part 3: Government & Data Patterns

---

## 6. Data Tables

### Basic Table

```tsx
// components/ui/Table.tsx
import { cn } from '@/lib/utils'

interface Column<T> {
  key: keyof T | string
  header: string
  render?: (item: T) => React.ReactNode
  className?: string
}

interface TableProps<T> {
  data: T[]
  columns: Column<T>[]
  onRowClick?: (item: T) => void
}

export function Table<T extends { id: string | number }>({ 
  data, 
  columns, 
  onRowClick 
}: TableProps<T>) {
  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            {columns.map(column => (
              <th
                key={String(column.key)}
                className={cn(
                  'px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider',
                  column.className
                )}
              >
                {column.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {data.map(item => (
            <tr
              key={item.id}
              onClick={() => onRowClick?.(item)}
              className={cn(
                onRowClick && 'cursor-pointer hover:bg-gray-50'
              )}
            >
              {columns.map(column => (
                <td
                  key={String(column.key)}
                  className={cn(
                    'px-6 py-4 whitespace-nowrap text-sm text-gray-900',
                    column.className
                  )}
                >
                  {column.render 
                    ? column.render(item)
                    : String(item[column.key as keyof T] ?? '')
                  }
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
```

**Usage:**
```tsx
<Table
  data={users}
  columns={[
    { key: 'name', header: 'Name' },
    { key: 'email', header: 'Email' },
    { 
      key: 'status', 
      header: 'Status',
      render: (user) => <Badge variant={user.status === 'active' ? 'success' : 'default'}>{user.status}</Badge>
    },
    { 
      key: 'actions', 
      header: '',
      render: (user) => <Button size="sm" variant="ghost">Edit</Button>
    },
  ]}
  onRowClick={(user) => router.push(`/users/${user.id}`)}
/>
```

---

### Table with Sorting

```tsx
// components/ui/SortableTable.tsx
'use client'
import { useState } from 'react'
import { cn } from '@/lib/utils'
import { ChevronUp, ChevronDown } from 'lucide-react'

interface Column<T> {
  key: keyof T | string
  header: string
  sortable?: boolean
  render?: (item: T) => React.ReactNode
}

interface SortableTableProps<T> {
  data: T[]
  columns: Column<T>[]
}

export function SortableTable<T extends { id: string | number }>({ 
  data, 
  columns 
}: SortableTableProps<T>) {
  const [sortKey, setSortKey] = useState<string | null>(null)
  const [sortDirection, setSortDirection] = useState<'asc' | 'desc'>('asc')

  const sortedData = [...data].sort((a, b) => {
    if (!sortKey) return 0
    const aVal = a[sortKey as keyof T]
    const bVal = b[sortKey as keyof T]
    if (aVal < bVal) return sortDirection === 'asc' ? -1 : 1
    if (aVal > bVal) return sortDirection === 'asc' ? 1 : -1
    return 0
  })

  const handleSort = (key: string) => {
    if (sortKey === key) {
      setSortDirection(sortDirection === 'asc' ? 'desc' : 'asc')
    } else {
      setSortKey(key)
      setSortDirection('asc')
    }
  }

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            {columns.map(column => (
              <th
                key={String(column.key)}
                className={cn(
                  'px-6 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider',
                  column.sortable && 'cursor-pointer select-none hover:bg-gray-100'
                )}
                onClick={() => column.sortable && handleSort(String(column.key))}
              >
                <div className="flex items-center gap-2">
                  {column.header}
                  {column.sortable && sortKey === column.key && (
                    sortDirection === 'asc' 
                      ? <ChevronUp className="w-4 h-4" />
                      : <ChevronDown className="w-4 h-4" />
                  )}
                </div>
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {sortedData.map(item => (
            <tr key={item.id}>
              {columns.map(column => (
                <td
                  key={String(column.key)}
                  className="px-6 py-4 whitespace-nowrap text-sm text-gray-900"
                >
                  {column.render 
                    ? column.render(item)
                    : String(item[column.key as keyof T] ?? '')
                  }
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
```

---

### Pagination

```tsx
// components/ui/Pagination.tsx
import { cn } from '@/lib/utils'
import { ChevronLeft, ChevronRight } from 'lucide-react'

interface PaginationProps {
  currentPage: number
  totalPages: number
  onPageChange: (page: number) => void
}

export function Pagination({ currentPage, totalPages, onPageChange }: PaginationProps) {
  const pages = Array.from({ length: totalPages }, (_, i) => i + 1)
  
  // Show max 7 page buttons
  const getVisiblePages = () => {
    if (totalPages <= 7) return pages
    if (currentPage <= 4) return [...pages.slice(0, 5), '...', totalPages]
    if (currentPage >= totalPages - 3) return [1, '...', ...pages.slice(-5)]
    return [1, '...', currentPage - 1, currentPage, currentPage + 1, '...', totalPages]
  }

  return (
    <div className="flex items-center justify-between px-6 py-3 bg-white border-t border-gray-200">
      <div className="text-sm text-gray-500">
        Page {currentPage} of {totalPages}
      </div>
      <div className="flex items-center gap-1">
        <button
          onClick={() => onPageChange(currentPage - 1)}
          disabled={currentPage === 1}
          className="p-2 rounded-lg hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <ChevronLeft className="w-5 h-5" />
        </button>
        
        {getVisiblePages().map((page, i) => (
          typeof page === 'number' ? (
            <button
              key={i}
              onClick={() => onPageChange(page)}
              className={cn(
                'w-10 h-10 rounded-lg text-sm font-medium',
                currentPage === page
                  ? 'bg-brand-500 text-white'
                  : 'hover:bg-gray-100 text-gray-700'
              )}
            >
              {page}
            </button>
          ) : (
            <span key={i} className="px-2 text-gray-400">...</span>
          )
        ))}
        
        <button
          onClick={() => onPageChange(currentPage + 1)}
          disabled={currentPage === totalPages}
          className="p-2 rounded-lg hover:bg-gray-100 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <ChevronRight className="w-5 h-5" />
        </button>
      </div>
    </div>
  )
}
```

---

## 7. Search & Filters

### Search Input

```tsx
// components/ui/SearchInput.tsx
import { Search } from 'lucide-react'

interface SearchInputProps {
  value: string
  onChange: (value: string) => void
  placeholder?: string
}

export function SearchInput({ value, onChange, placeholder = 'Search...' }: SearchInputProps) {
  return (
    <div className="relative">
      <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
      <input
        type="text"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-brand-500"
      />
    </div>
  )
}
```

---

### Filter Bar

```tsx
// components/ui/FilterBar.tsx
interface FilterOption {
  value: string
  label: string
}

interface FilterBarProps {
  filters: {
    key: string
    label: string
    options: FilterOption[]
    value: string
    onChange: (value: string) => void
  }[]
  onClear?: () => void
}

export function FilterBar({ filters, onClear }: FilterBarProps) {
  const hasActiveFilters = filters.some(f => f.value !== '')
  
  return (
    <div className="flex flex-wrap items-center gap-4 p-4 bg-gray-50 rounded-lg">
      {filters.map(filter => (
        <div key={filter.key} className="flex items-center gap-2">
          <label className="text-sm font-medium text-gray-700">
            {filter.label}:
          </label>
          <select
            value={filter.value}
            onChange={(e) => filter.onChange(e.target.value)}
            className="text-sm border border-gray-300 rounded-lg px-3 py-1.5 focus:outline-none focus:ring-2 focus:ring-brand-500"
          >
            <option value="">All</option>
            {filter.options.map(option => (
              <option key={option.value} value={option.value}>
                {option.label}
              </option>
            ))}
          </select>
        </div>
      ))}
      
      {hasActiveFilters && onClear && (
        <button
          onClick={onClear}
          className="text-sm text-brand-600 hover:text-brand-700 font-medium"
        >
          Clear filters
        </button>
      )}
    </div>
  )
}
```

---

### Search with Filters Combined

```tsx
// Example usage combining search and filters
export function DataTableWithSearch() {
  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState('')
  const [typeFilter, setTypeFilter] = useState('')
  
  return (
    <Card padding="none">
      {/* Toolbar */}
      <div className="p-4 border-b border-gray-200">
        <div className="flex flex-col md:flex-row gap-4">
          <div className="flex-1">
            <SearchInput 
              value={search} 
              onChange={setSearch}
              placeholder="Search by name or email..."
            />
          </div>
          <div className="flex gap-2">
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="text-sm border border-gray-300 rounded-lg px-3 py-2"
            >
              <option value="">All Status</option>
              <option value="active">Active</option>
              <option value="pending">Pending</option>
              <option value="inactive">Inactive</option>
            </select>
            <select
              value={typeFilter}
              onChange={(e) => setTypeFilter(e.target.value)}
              className="text-sm border border-gray-300 rounded-lg px-3 py-2"
            >
              <option value="">All Types</option>
              <option value="admin">Admin</option>
              <option value="user">User</option>
            </select>
          </div>
        </div>
      </div>
      
      {/* Table */}
      <Table data={filteredData} columns={columns} />
      
      {/* Pagination */}
      <Pagination 
        currentPage={page} 
        totalPages={totalPages} 
        onPageChange={setPage} 
      />
    </Card>
  )
}
```

---

## 8. Government-Specific Patterns

### USWDS-Style Components

```tsx
// components/gov/GovButton.tsx
import { cn } from '@/lib/utils'

interface GovButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline' | 'unstyled'
  size?: 'default' | 'big'
}

export function GovButton({ 
  variant = 'primary', 
  size = 'default',
  className, 
  children, 
  ...props 
}: GovButtonProps) {
  return (
    <button
      className={cn(
        'font-bold transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2',
        // USWDS colors
        variant === 'primary' && 'bg-[#005ea2] text-white hover:bg-[#1a4480] focus:ring-[#005ea2]',
        variant === 'secondary' && 'bg-[#d83933] text-white hover:bg-[#b50909] focus:ring-[#d83933]',
        variant === 'outline' && 'bg-transparent border-2 border-[#005ea2] text-[#005ea2] hover:bg-[#005ea2] hover:text-white',
        variant === 'unstyled' && 'bg-transparent text-[#005ea2] underline hover:text-[#1a4480]',
        // Sizes
        size === 'default' && 'px-5 py-3 text-base rounded',
        size === 'big' && 'px-6 py-4 text-lg rounded',
        className
      )}
      {...props}
    >
      {children}
    </button>
  )
}
```

---

### USWDS Alert

```tsx
// components/gov/GovAlert.tsx
import { cn } from '@/lib/utils'

interface GovAlertProps {
  variant: 'info' | 'success' | 'warning' | 'error' | 'emergency'
  heading?: string
  children: React.ReactNode
  slim?: boolean
}

export function GovAlert({ variant, heading, children, slim }: GovAlertProps) {
  const colors = {
    info: 'border-[#00bde3] bg-[#e7f6f8]',
    success: 'border-[#00a91c] bg-[#ecf3ec]',
    warning: 'border-[#ffbe2e] bg-[#faf3d1]',
    error: 'border-[#d54309] bg-[#f4e3db]',
    emergency: 'border-[#b50909] bg-[#9c3d10] text-white',
  }
  
  return (
    <div
      className={cn(
        'border-l-4',
        colors[variant],
        slim ? 'py-2 px-4' : 'py-4 px-5'
      )}
      role="alert"
    >
      {heading && !slim && (
        <h3 className={cn(
          'font-bold mb-2',
          variant === 'emergency' ? 'text-white' : 'text-gray-900'
        )}>
          {heading}
        </h3>
      )}
      <div className={cn(
        'text-sm',
        variant === 'emergency' ? 'text-white' : 'text-gray-700'
      )}>
        {children}
      </div>
    </div>
  )
}
```

---

### Step Indicator (Process Steps)

```tsx
// components/gov/StepIndicator.tsx
import { cn } from '@/lib/utils'
import { Check } from 'lucide-react'

interface Step {
  id: string
  label: string
  status: 'complete' | 'current' | 'incomplete'
}

interface StepIndicatorProps {
  steps: Step[]
}

export function StepIndicator({ steps }: StepIndicatorProps) {
  return (
    <nav aria-label="Progress">
      <ol className="flex items-center">
        {steps.map((step, index) => (
          <li 
            key={step.id} 
            className={cn('relative', index !== steps.length - 1 && 'flex-1')}
          >
            <div className="flex items-center">
              {/* Circle */}
              <div
                className={cn(
                  'w-10 h-10 rounded-full flex items-center justify-center border-2 font-bold',
                  step.status === 'complete' && 'bg-[#005ea2] border-[#005ea2] text-white',
                  step.status === 'current' && 'bg-white border-[#005ea2] text-[#005ea2]',
                  step.status === 'incomplete' && 'bg-white border-gray-300 text-gray-400',
                )}
              >
                {step.status === 'complete' ? (
                  <Check className="w-5 h-5" />
                ) : (
                  index + 1
                )}
              </div>
              
              {/* Connector line */}
              {index !== steps.length - 1 && (
                <div
                  className={cn(
                    'h-0.5 flex-1 mx-4',
                    step.status === 'complete' ? 'bg-[#005ea2]' : 'bg-gray-300'
                  )}
                />
              )}
            </div>
            
            {/* Label */}
            <p
              className={cn(
                'mt-2 text-sm font-medium',
                step.status === 'current' ? 'text-[#005ea2]' : 'text-gray-500'
              )}
            >
              {step.label}
            </p>
          </li>
        ))}
      </ol>
    </nav>
  )
}
```

---

### Summary Box

```tsx
// components/gov/SummaryBox.tsx
interface SummaryBoxProps {
  heading: string
  items: string[]
}

export function SummaryBox({ heading, items }: SummaryBoxProps) {
  return (
    <div className="bg-[#f0f0f0] border-l-4 border-[#005ea2] p-5">
      <h3 className="text-lg font-bold text-gray-900 mb-3">{heading}</h3>
      <ul className="space-y-2">
        {items.map((item, i) => (
          <li key={i} className="flex items-start gap-2 text-gray-700">
            <span className="text-[#005ea2] font-bold">•</span>
            {item}
          </li>
        ))}
      </ul>
    </div>
  )
}
```

---

## 9. Dashboard Patterns

### Dashboard Header

```tsx
// components/dashboard/DashboardHeader.tsx
interface DashboardHeaderProps {
  title: string
  description?: string
  actions?: React.ReactNode
}

export function DashboardHeader({ title, description, actions }: DashboardHeaderProps) {
  return (
    <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">{title}</h1>
        {description && (
          <p className="mt-1 text-gray-500">{description}</p>
        )}
      </div>
      {actions && (
        <div className="flex items-center gap-3">
          {actions}
        </div>
      )}
    </div>
  )
}
```

---

### Stats Grid

```tsx
// components/dashboard/StatsGrid.tsx
import { StatCard } from '@/components/ui/StatCard'

interface Stat {
  title: string
  value: string | number
  change?: string
  changeType?: 'positive' | 'negative' | 'neutral'
  icon?: React.ReactNode
}

interface StatsGridProps {
  stats: Stat[]
  columns?: 2 | 3 | 4
}

export function StatsGrid({ stats, columns = 4 }: StatsGridProps) {
  const gridCols = {
    2: 'md:grid-cols-2',
    3: 'md:grid-cols-3',
    4: 'md:grid-cols-2 lg:grid-cols-4',
  }
  
  return (
    <div className={`grid grid-cols-1 ${gridCols[columns]} gap-6`}>
      {stats.map((stat, i) => (
        <StatCard key={i} {...stat} />
      ))}
    </div>
  )
}
```

---

### Activity Feed

```tsx
// components/dashboard/ActivityFeed.tsx
interface Activity {
  id: string
  user: string
  action: string
  target: string
  time: string
}

interface ActivityFeedProps {
  activities: Activity[]
  maxItems?: number
}

export function ActivityFeed({ activities, maxItems = 5 }: ActivityFeedProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Recent Activity</CardTitle>
      </CardHeader>
      <CardContent>
        <ul className="space-y-4">
          {activities.slice(0, maxItems).map(activity => (
            <li key={activity.id} className="flex items-start gap-3">
              <div className="w-8 h-8 rounded-full bg-gray-200 flex-shrink-0" />
              <div className="flex-1 min-w-0">
                <p className="text-sm text-gray-900">
                  <span className="font-medium">{activity.user}</span>
                  {' '}{activity.action}{' '}
                  <span className="font-medium">{activity.target}</span>
                </p>
                <p className="text-xs text-gray-500 mt-1">{activity.time}</p>
              </div>
            </li>
          ))}
        </ul>
      </CardContent>
    </Card>
  )
}
```

---

## 10. Account Center Patterns

### Account Settings Layout

```tsx
// components/account/AccountLayout.tsx
'use client'
import { usePathname } from 'next/navigation'
import Link from 'next/link'
import { cn } from '@/lib/utils'
import { User, Shield, Bell, CreditCard, Settings } from 'lucide-react'

const navItems = [
  { href: '/account/profile', label: 'Profile', icon: User },
  { href: '/account/security', label: 'Security', icon: Shield },
  { href: '/account/notifications', label: 'Notifications', icon: Bell },
  { href: '/account/billing', label: 'Billing', icon: CreditCard },
  { href: '/account/preferences', label: 'Preferences', icon: Settings },
]

export function AccountLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname()
  
  return (
    <div className="max-w-5xl mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold text-gray-900 mb-8">Account Settings</h1>
      
      <div className="flex flex-col md:flex-row gap-8">
        {/* Sidebar nav */}
        <nav className="w-full md:w-64 flex-shrink-0">
          <ul className="space-y-1">
            {navItems.map(item => {
              const Icon = item.icon
              const isActive = pathname === item.href
              return (
                <li key={item.href}>
                  <Link
                    href={item.href}
                    className={cn(
                      'flex items-center gap-3 px-4 py-2 rounded-lg text-sm font-medium transition-colors',
                      isActive
                        ? 'bg-brand-50 text-brand-700'
                        : 'text-gray-600 hover:bg-gray-100'
                    )}
                  >
                    <Icon className="w-5 h-5" />
                    {item.label}
                  </Link>
                </li>
              )
            })}
          </ul>
        </nav>
        
        {/* Content */}
        <main className="flex-1">
          {children}
        </main>
      </div>
    </div>
  )
}
```

---

### Settings Section

```tsx
// components/account/SettingsSection.tsx
interface SettingsSectionProps {
  title: string
  description?: string
  children: React.ReactNode
}

export function SettingsSection({ title, description, children }: SettingsSectionProps) {
  return (
    <div className="pb-8 mb-8 border-b border-gray-200 last:border-0 last:pb-0 last:mb-0">
      <div className="mb-6">
        <h2 className="text-lg font-semibold text-gray-900">{title}</h2>
        {description && (
          <p className="mt-1 text-sm text-gray-500">{description}</p>
        )}
      </div>
      {children}
    </div>
  )
}
```

---

### Toggle Setting

```tsx
// components/account/ToggleSetting.tsx
'use client'
import { useState } from 'react'
import { cn } from '@/lib/utils'

interface ToggleSettingProps {
  label: string
  description?: string
  defaultChecked?: boolean
  onChange?: (checked: boolean) => void
}

export function ToggleSetting({ 
  label, 
  description, 
  defaultChecked = false,
  onChange 
}: ToggleSettingProps) {
  const [checked, setChecked] = useState(defaultChecked)
  
  const handleChange = () => {
    const newValue = !checked
    setChecked(newValue)
    onChange?.(newValue)
  }
  
  return (
    <div className="flex items-center justify-between py-4">
      <div>
        <p className="text-sm font-medium text-gray-900">{label}</p>
        {description && (
          <p className="text-sm text-gray-500">{description}</p>
        )}
      </div>
      <button
        type="button"
        role="switch"
        aria-checked={checked}
        onClick={handleChange}
        className={cn(
          'relative inline-flex h-6 w-11 items-center rounded-full transition-colors',
          checked ? 'bg-brand-500' : 'bg-gray-200'
        )}
      >
        <span
          className={cn(
            'inline-block h-4 w-4 rounded-full bg-white transition-transform',
            checked ? 'translate-x-6' : 'translate-x-1'
          )}
        />
      </button>
    </div>
  )
}
```
}: { 
  sidebar: React.ReactNode
  children: React.ReactNode 
}) {
  const [isOpen, setIsOpen] = useState(false)
  
  return (
    <div className="flex min-h-screen">
      {/* Mobile menu button */}
      <button
        className="fixed top-4 left-4 z-50 p-2 bg-white rounded-lg shadow-md md:hidden"
        onClick={() => setIsOpen(!isOpen)}
      >
        {isOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
      </button>
      
      {/* Backdrop */}
      {isOpen && (
        <div 
          className="fixed inset-0 bg-black/50 z-40 md:hidden" 
          onClick={() => setIsOpen(false)}
        />
      )}
      
      {/* Sidebar */}
      <aside
        className={cn(
          'fixed inset-y-0 left-0 z-40 w-64 bg-white border-r border-gray-200 transform transition-transform md:relative md:translate-x-0',
          isOpen ? 'translate-x-0' : '-translate-x-full'
        )}
      >
        {sidebar}
      </aside>
      
      {/* Main content */}
      <main className="flex-1 md:ml-0">
        {children}
      </main>
    </div>
  )
}
```

---

### Responsive Card Grid

```tsx
// components/ui/CardGrid.tsx
import { cn } from '@/lib/utils'

interface CardGridProps {
  children: React.ReactNode
  columns?: 1 | 2 | 3 | 4
}

export function CardGrid({ children, columns = 3 }: CardGridProps) {
  const gridCols = {
    1: 'grid-cols-1',
    2: 'grid-cols-1 md:grid-cols-2',
    3: 'grid-cols-1 md:grid-cols-2 lg:grid-cols-3',
    4: 'grid-cols-1 sm:grid-cols-2 lg:grid-cols-4',
  }
  
  return (
    <div className={cn('grid gap-6', gridCols[columns])}>
      {children}
    </div>
  )
}
```

---

### Touch Targets

For mobile, ensure touch targets are at least 44x44px:

```html
<!-- Good: Large enough touch target -->
<button class="p-3 min-h-[44px] min-w-[44px]">
  <Icon />
</button>

<!-- Good: Link with padding -->
<a href="#" class="block py-3 px-4">Menu Item</a>
```

---

## 12. Working with Client Brand Systems

### Extract Brand Colors

When a client gives you brand guidelines:

1. **Get the primary color hex code**
2. **Generate a full palette** at https://uicolors.app/create
3. **Copy into tailwind.config.ts**

```typescript
// tailwind.config.ts
colors: {
  brand: {
    50: '#fdf4f3',   // Generated lightest
    100: '#fce8e6',
    200: '#fad5d1',
    300: '#f5b4ac',
    400: '#ed867a',
    500: '#e63946',  // Client's primary color
    600: '#d32838',
    700: '#b1212e',
    800: '#931f2b',
    900: '#7a1f29',
    950: '#420c12',  // Generated darkest
  }
}
```

---

### Brand Application Checklist

When customizing for a client:

- [ ] Replace `brand` colors in `tailwind.config.ts`
- [ ] Update favicon (`/app/favicon.ico`)
- [ ] Update metadata in `layout.tsx`
- [ ] Add logo (if provided) to header
- [ ] Match button border-radius to their brand (rounded vs sharp)
- [ ] Import their font (if specified) via Google Fonts

---

### Loading Custom Fonts

```tsx
// app/layout.tsx
import { Inter, Playfair_Display } from 'next/font/google'

const inter = Inter({ 
  subsets: ['latin'],
  variable: '--font-sans',
})

const playfair = Playfair_Display({ 
  subsets: ['latin'],
  variable: '--font-serif',
})

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${inter.variable} ${playfair.variable}`}>
      <body>{children}</body>
    </html>
  )
}
```

```typescript
// tailwind.config.ts
fontFamily: {
  sans: ['var(--font-sans)', 'system-ui', 'sans-serif'],
  serif: ['var(--font-serif)', 'Georgia', 'serif'],
}
```

---

### Quick Brand Swap

For fast brand customization, update just these 3 things:

1. **tailwind.config.ts** - `brand` color palette
2. **app/layout.tsx** - Title, description, font
3. **globals.css** - CSS variables if needed

Everything using `brand-*` classes will automatically update.

---

## 13. Image Patterns

### Image with Overlay Text

```tsx
<div className="relative rounded-xl overflow-hidden">
  <img 
    src="/image.jpg" 
    alt="Description"
    className="w-full h-64 object-cover"
  />
  <div className="absolute inset-0 bg-gradient-to-t from-black/70 to-transparent" />
  <div className="absolute bottom-0 left-0 right-0 p-6 text-white">
    <h3 className="text-xl font-bold">Card Title</h3>
    <p className="text-white/80">Card description text</p>
  </div>
</div>
```

---

### Avatar Sizes

```tsx
// components/ui/Avatar.tsx
import { cn } from '@/lib/utils'

interface AvatarProps {
  src?: string
  name: string
  size?: 'sm' | 'md' | 'lg' | 'xl'
}

export function Avatar({ src, name, size = 'md' }: AvatarProps) {
  const initials = name.split(' ').map(n => n[0]).join('').toUpperCase()
  
  const sizes = {
    sm: 'w-8 h-8 text-xs',
    md: 'w-10 h-10 text-sm',
    lg: 'w-12 h-12 text-base',
    xl: 'w-16 h-16 text-lg',
  }
  
  if (src) {
    return (
      <img 
        src={src} 
        alt={name}
        className={cn('rounded-full object-cover', sizes[size])}
      />
    )
  }
  
  return (
    <div className={cn(
      'rounded-full bg-brand-100 text-brand-700 flex items-center justify-center font-medium',
      sizes[size]
    )}>
      {initials}
    </div>
  )
}
```

---

### Aspect Ratio Images

```html
<!-- 16:9 video aspect ratio -->
<div class="aspect-video relative">
  <img src="..." class="absolute inset-0 w-full h-full object-cover" />
</div>

<!-- Square -->
<div class="aspect-square relative">
  <img src="..." class="absolute inset-0 w-full h-full object-cover" />
</div>

<!-- 4:3 -->
<div class="aspect-[4/3] relative">
  <img src="..." class="absolute inset-0 w-full h-full object-cover" />
</div>
```

---

# Part 5: Claude Code Prompts

---

## 14. Prompt Formulas

### For Overall Page Style

```
Create a [page type] with a [mood/style] feel. 
Use [color scheme], [corner style], [spacing level]. 
The vibe should be [adjectives].
```

**Example:**
```
Create a dashboard with a premium, minimal feel.
Use a dark color scheme with a muted gold accent, sharp corners, and spacious padding.
The vibe should be calm, confident, and professional.
```

---

### For Specific Components

```
Build a [component] that feels [adjectives]. 
It should have [specific features].
Style it with [Tailwind classes or descriptions].
```

**Example:**
```
Build a pricing card that feels premium and trustworthy.
It should have a plan name, price, feature list, and CTA button.
Style it with a dark background, subtle border, and gold accent on the button.
```

---

### For Layouts

```
Create a [layout type] layout with:
- [Header description]
- [Sidebar/nav description]
- [Main content area description]
- [Any special features]
Make it responsive - [mobile behavior].
```

**Example:**
```
Create a dashboard layout with:
- A dark sidebar (gray-900) with logo at top and nav items
- A light main content area (gray-50 background)
- A top bar with page title and action buttons
Make it responsive - sidebar collapses to hamburger menu on mobile.
```

---

### For Matching a Reference

```
I want to recreate this style: [paste URL or describe]
Key elements I see:
- Colors: [describe]
- Spacing: [dense/spacious]
- Corners: [rounded/sharp]
- Shadows: [none/subtle/prominent]
- Typography: [describe]
Build a [component] matching this style.
```

---

### For Government/Accessible Design

```
Build this [component] following USWDS/government design principles:
- Accessible (WCAG 2.1 AA compliant)
- High contrast text
- Clear focus states (visible ring on focus)
- Use USWDS blue (#005ea2) as primary
- Minimal decoration, borders instead of shadows
- Mobile-friendly
```

---

### For Responsive Behavior

```
Make this [component/layout] responsive:
- Mobile (< 768px): [behavior]
- Tablet (768px-1024px): [behavior]
- Desktop (> 1024px): [behavior]
```

**Example:**
```
Make this card grid responsive:
- Mobile: 1 column, full width cards
- Tablet: 2 columns
- Desktop: 3 columns with max-width container
```

---

### For Data-Heavy Components

```
Build a [table/list/grid] that displays [data type] with:
- Columns: [list columns]
- Features needed: [sorting/filtering/pagination/search]
- Row actions: [edit/delete/view details]
- Empty state: [what to show when no data]
- Loading state: [skeleton/spinner]
```

---

### For Forms

```
Build a [form type] form with:
- Fields: [list fields with types]
- Validation: [required fields, formats]
- Submit behavior: [what happens on submit]
- Error handling: [how to show errors]
- Success state: [what to show on success]
```

---

## 15. Describe What You See

When you find a design you like, break it down:

### Questions to Ask

1. **Layout:** Is it sidebar + content? Top nav? Split screen? Full width?
2. **Colors:** What's the background? Primary accent? Text colors?
3. **Spacing:** Dense or spacious? Even or varied?
4. **Shapes:** Rounded or sharp corners? How rounded?
5. **Depth:** Flat? Shadows? Borders? Layered elements?
6. **Typography:** Big bold headers? Subtle? Serif or sans?
7. **Effects:** Any gradients? Blurs? Animations?

### Example Analysis

"I like this design. Let me describe it:
- Layout: Sidebar on left (dark), main content (light gray background)
- Colors: Navy sidebar (#1e293b), white cards, blue accent (#3b82f6)
- Spacing: Generous - lots of padding in cards (p-6), big gaps between elements
- Shapes: Rounded corners on everything (rounded-xl on cards)
- Depth: Subtle shadows on cards (shadow-sm), no heavy drop shadows
- Typography: Clean sans-serif, bold headings, gray secondary text
- Effects: Hover states on nav items, smooth transitions

Build me a dashboard matching this style."

---

## 16. Quick Reference Card

### When client says... → Use this

| Client says | You build |
|-------------|-----------|
| "Make it pop" | Add brand-500 accent, increase contrast |
| "Too busy" | Remove shadows, increase spacing, reduce colors |
| "More professional" | Use gray/blue, reduce roundness, add borders |
| "More friendly" | Warmer colors, more rounded corners, softer shadows |
| "Like Apple" | Lots of white space, thin fonts, minimal UI |
| "Like Google" | Material-inspired, shadows, FAB buttons |
| "Government compliant" | USWDS colors, high contrast, focus states |

---

## Checklist Before Shipping

### Visual Quality
- [ ] Consistent spacing throughout
- [ ] Colors all from the defined palette
- [ ] Typography hierarchy is clear
- [ ] No orphaned text (single words on new lines)
- [ ] Images are properly sized/cropped

### Responsive
- [ ] Looks good on mobile (375px)
- [ ] Looks good on tablet (768px)
- [ ] Looks good on desktop (1280px)
- [ ] No horizontal scroll at any size
- [ ] Touch targets are 44px minimum on mobile

### Accessibility
- [ ] Color contrast passes (4.5:1 for text)
- [ ] Focus states visible on all interactive elements
- [ ] Form inputs have labels
- [ ] Images have alt text
- [ ] Buttons have clear text or aria-label

### Polish
- [ ] Loading states for async content
- [ ] Empty states for lists/tables
- [ ] Error states for forms
- [ ] Hover/active states on interactive elements
- [ ] Smooth transitions (no jarring changes)

---

*This guide is a living document. Update it as you learn new patterns and find what works for your clients.*
