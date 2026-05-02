# React Standards

*How we write React components at Friends Innovation Lab.*

---

## Component Patterns

### Functional Components Only

Always use functional components with hooks. No class components.

```tsx
// ✅ Do this
function UserProfile({ user }: { user: User }) {
  return <div>{user.name}</div>
}

// ❌ Not this
class UserProfile extends React.Component { ... }
```

### Component File Structure

One component per file. Name file same as component.

```
components/
├── ui/                      # shadcn/ui components
│   ├── button.tsx
│   ├── input.tsx
│   └── card.tsx
├── features/                # Feature-specific components
│   ├── UserProfile.tsx
│   ├── ProjectList.tsx
│   └── DashboardStats.tsx
└── layout/                  # Layout components
    ├── Header.tsx
    ├── Footer.tsx
    └── Sidebar.tsx
```

### Component Template

```tsx
// components/features/UserProfile.tsx

import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"

interface UserProfileProps {
  user: User
  showEmail?: boolean
}

export function UserProfile({ user, showEmail = false }: UserProfileProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>{user.name}</CardTitle>
      </CardHeader>
      <CardContent>
        <Avatar>
          <AvatarImage src={user.avatar} alt={user.name} />
          <AvatarFallback>{user.name[0]}</AvatarFallback>
        </Avatar>
        {showEmail && <p>{user.email}</p>}
      </CardContent>
    </Card>
  )
}
```

---

## Props

### Use TypeScript Interfaces

Define props with interfaces, not inline types.

```tsx
// ✅ Do this
interface ButtonProps {
  label: string
  onClick: () => void
  disabled?: boolean
}

function Button({ label, onClick, disabled = false }: ButtonProps) {
  return <button onClick={onClick} disabled={disabled}>{label}</button>
}

// ❌ Not this
function Button({ label, onClick, disabled }: { label: string; onClick: () => void; disabled?: boolean }) {
  ...
}
```

### Destructure Props

Always destructure in the function signature.

```tsx
// ✅ Do this
function Card({ title, children }: CardProps) {
  return <div>{title}{children}</div>
}

// ❌ Not this
function Card(props: CardProps) {
  return <div>{props.title}{props.children}</div>
}
```

### Default Props

Use default values in destructuring.

```tsx
// ✅ Do this
function Button({ variant = "default", size = "md" }: ButtonProps) {
  ...
}

// ❌ Not this
Button.defaultProps = { variant: "default", size: "md" }
```

### Children Prop

Use `React.ReactNode` for children.

```tsx
interface CardProps {
  children: React.ReactNode
  title?: string
}

function Card({ children, title }: CardProps) {
  return (
    <div>
      {title && <h2>{title}</h2>}
      {children}
    </div>
  )
}
```

---

## Hooks

### useState

```tsx
// Simple state
const [count, setCount] = useState(0)

// State with type inference
const [user, setUser] = useState<User | null>(null)

// State with initial value from prop
const [value, setValue] = useState(initialValue)

// Updating state based on previous value
setCount(prev => prev + 1)
```

### useEffect

```tsx
// Run once on mount
useEffect(() => {
  fetchData()
}, [])

// Run when dependency changes
useEffect(() => {
  fetchUser(userId)
}, [userId])

// Cleanup
useEffect(() => {
  const subscription = subscribe()
  return () => subscription.unsubscribe()
}, [])
```

**Rules:**
- Always include dependency array
- Keep effects focused (one purpose per effect)
- Clean up subscriptions, timers, listeners

### useMemo and useCallback

Use sparingly. Only when you have measured performance issues.

```tsx
// Memoize expensive computation
const sortedItems = useMemo(() => {
  return items.sort((a, b) => a.name.localeCompare(b.name))
}, [items])

// Memoize callback passed to child
const handleClick = useCallback(() => {
  doSomething(id)
}, [id])
```

**Don't over-optimize:**
```tsx
// ❌ Unnecessary - simple computation
const fullName = useMemo(() => `${first} ${last}`, [first, last])

// ✅ Just compute it
const fullName = `${first} ${last}`
```

### Custom Hooks

Extract reusable logic into custom hooks.

```tsx
// hooks/useLocalStorage.ts
export function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    if (typeof window === 'undefined') return initialValue
    const stored = localStorage.getItem(key)
    return stored ? JSON.parse(stored) : initialValue
  })

  useEffect(() => {
    localStorage.setItem(key, JSON.stringify(value))
  }, [key, value])

  return [value, setValue] as const
}

// Usage
const [theme, setTheme] = useLocalStorage('theme', 'light')
```

**Naming:** Always prefix with `use`.

---

## State Management

### Local State First

Start with local state. Only lift up when needed.

```tsx
// ✅ Local state - component owns its state
function SearchInput() {
  const [query, setQuery] = useState('')
  return <input value={query} onChange={e => setQuery(e.target.value)} />
}
```

### Lifting State

Lift state to nearest common ancestor when siblings need to share.

```tsx
// Parent owns state, children receive via props
function SearchPage() {
  const [query, setQuery] = useState('')

  return (
    <>
      <SearchInput value={query} onChange={setQuery} />
      <SearchResults query={query} />
    </>
  )
}
```

### Context for Global State

Use React Context for truly global state (theme, auth, etc.).

```tsx
// contexts/AuthContext.tsx
interface AuthContextType {
  user: User | null
  login: (email: string, password: string) => Promise<void>
  logout: () => void
}

const AuthContext = createContext<AuthContextType | null>(null)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)

  const login = async (email: string, password: string) => {
    const user = await authService.login(email, password)
    setUser(user)
  }

  const logout = () => {
    authService.logout()
    setUser(null)
  }

  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return context
}
```

### When to Use External State Library

Consider Zustand or Jotai only if:
- Context re-renders become a performance problem
- You need state persistence across sessions
- Complex state logic with many actions

For most projects, `useState` + Context is enough.

---

## Event Handling

### Naming Convention

Prefix handlers with `handle`, props with `on`.

```tsx
interface ButtonProps {
  onClick: () => void  // Prop uses "on"
}

function Form() {
  const handleSubmit = () => { ... }  // Handler uses "handle"

  return <Button onClick={handleSubmit} />
}
```

### Event Types

Use proper TypeScript event types.

```tsx
function Input() {
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    console.log(e.target.value)
  }

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
  }

  const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
    console.log(e.clientX)
  }

  return (
    <form onSubmit={handleSubmit}>
      <input onChange={handleChange} />
      <button onClick={handleClick}>Submit</button>
    </form>
  )
}
```

### Prevent Default

Always prevent default on form submissions.

```tsx
const handleSubmit = (e: React.FormEvent) => {
  e.preventDefault()
  // handle submission
}
```

---

## Conditional Rendering

### Short Circuit

For simple conditions.

```tsx
// Show if true
{isLoggedIn && <UserMenu />}

// Show if exists
{user && <UserProfile user={user} />}
```

### Ternary

For if/else.

```tsx
{isLoading ? <Spinner /> : <Content />}
```

### Early Return

For complex conditions.

```tsx
function UserProfile({ user }: { user: User | null }) {
  if (!user) {
    return <div>Please log in</div>
  }

  return <div>{user.name}</div>
}
```

### Avoid Nested Ternaries

```tsx
// ❌ Hard to read
{status === 'loading' ? <Spinner /> : status === 'error' ? <Error /> : <Content />}

// ✅ Use early returns or extract to function
function StatusContent({ status }: { status: Status }) {
  if (status === 'loading') return <Spinner />
  if (status === 'error') return <Error />
  return <Content />
}
```

---

## Lists and Keys

### Always Use Keys

Keys must be unique and stable.

```tsx
// ✅ Use unique ID
{users.map(user => (
  <UserCard key={user.id} user={user} />
))}

// ❌ Don't use index (unless list is static and never reordered)
{users.map((user, index) => (
  <UserCard key={index} user={user} />
))}
```

### Extracting List Items

For complex items, extract to component.

```tsx
// ✅ Clean
function UserList({ users }: { users: User[] }) {
  return (
    <ul>
      {users.map(user => (
        <UserListItem key={user.id} user={user} />
      ))}
    </ul>
  )
}

function UserListItem({ user }: { user: User }) {
  return (
    <li>
      <Avatar user={user} />
      <span>{user.name}</span>
      <span>{user.email}</span>
    </li>
  )
}
```

---

## Forms

### Controlled Components

Prefer controlled components (React owns the state).

```tsx
function LoginForm() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    login(email, password)
  }

  return (
    <form onSubmit={handleSubmit}>
      <Input
        value={email}
        onChange={e => setEmail(e.target.value)}
        placeholder="Email"
      />
      <Input
        type="password"
        value={password}
        onChange={e => setPassword(e.target.value)}
        placeholder="Password"
      />
      <Button type="submit">Log In</Button>
    </form>
  )
}
```

### Form Libraries

For complex forms, consider:
- **react-hook-form** — Performance-focused, minimal re-renders
- **zod** — Schema validation (pairs well with react-hook-form)

```tsx
// With react-hook-form + zod
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
})

type FormData = z.infer<typeof schema>

function LoginForm() {
  const { register, handleSubmit, formState: { errors } } = useForm<FormData>({
    resolver: zodResolver(schema)
  })

  const onSubmit = (data: FormData) => {
    login(data.email, data.password)
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <Input {...register('email')} placeholder="Email" />
      {errors.email && <span>{errors.email.message}</span>}

      <Input {...register('password')} type="password" placeholder="Password" />
      {errors.password && <span>{errors.password.message}</span>}

      <Button type="submit">Log In</Button>
    </form>
  )
}
```

---

## Error Boundaries

Catch rendering errors and show fallback UI.

```tsx
// components/ErrorBoundary.tsx
'use client'

import { Component, ReactNode } from 'react'

interface Props {
  children: ReactNode
  fallback?: ReactNode
}

interface State {
  hasError: boolean
}

export class ErrorBoundary extends Component<Props, State> {
  state = { hasError: false }

  static getDerivedStateFromError() {
    return { hasError: true }
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    console.error('Error caught by boundary:', error, info)
    // Log to error tracking service
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || <div>Something went wrong</div>
    }
    return this.props.children
  }
}

// Usage
<ErrorBoundary fallback={<ErrorPage />}>
  <App />
</ErrorBoundary>
```

---

## Performance

### Avoid Unnecessary Re-renders

```tsx
// ❌ Creates new object every render
<Component style={{ color: 'red' }} />

// ✅ Define outside or memoize
const style = { color: 'red' }
<Component style={style} />
```

### Lazy Loading

Split large components.

```tsx
import { lazy, Suspense } from 'react'

const HeavyComponent = lazy(() => import('./HeavyComponent'))

function App() {
  return (
    <Suspense fallback={<Spinner />}>
      <HeavyComponent />
    </Suspense>
  )
}
```

### Virtualization

For long lists (100+ items), use virtualization.

```tsx
// Use @tanstack/react-virtual or react-window
import { useVirtualizer } from '@tanstack/react-virtual'
```

---

## Testing Components

### Basic Test Structure

```tsx
// UserProfile.test.tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { UserProfile } from './UserProfile'

describe('UserProfile', () => {
  it('renders user name', () => {
    render(<UserProfile user={{ name: 'John', email: 'john@example.com' }} />)
    expect(screen.getByText('John')).toBeInTheDocument()
  })

  it('shows email when showEmail is true', () => {
    render(<UserProfile user={{ name: 'John', email: 'john@example.com' }} showEmail />)
    expect(screen.getByText('john@example.com')).toBeInTheDocument()
  })

  it('handles click', async () => {
    const handleClick = vi.fn()
    render(<Button onClick={handleClick}>Click me</Button>)

    await userEvent.click(screen.getByText('Click me'))
    expect(handleClick).toHaveBeenCalled()
  })
})
```

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| State for derived data | Unnecessary complexity | Compute during render |
| useEffect for transforms | Extra re-renders | Compute during render |
| Mutating state directly | Won't trigger re-render | Use setter function |
| Missing dependency array | Infinite loops | Always include deps |
| Overusing useMemo/useCallback | Premature optimization | Measure first |
| Props drilling 5+ levels | Hard to maintain | Use Context |
| Giant components | Hard to test/maintain | Extract smaller components |

---

*See also: [Next.js](nextjs.md) · [Styling & shadcn/ui](styling.md) · [Accessibility](accessibility.md)*
