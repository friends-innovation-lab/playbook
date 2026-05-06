# Database Standards

*How we use Supabase at Friends Innovation Lab.*

---

## Overview

We use **Supabase** (managed PostgreSQL) for our database layer. Supabase provides:

- PostgreSQL database
- Auto-generated REST API
- Real-time subscriptions
- Row Level Security (RLS)
- Authentication
- Storage (for files)
- Edge Functions

---

## Project Setup

### Create Supabase Project

1. Go to [supabase.com/dashboard](https://supabase.com/dashboard)
2. Select org: **Friends Innovation Lab**
3. Click **New Project**
4. Name it: `project-slug`
5. Generate and save the database password
6. Select region: **East US** (or closest to users)
7. Click **Create new project**

### Environment Variables

```bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Server-only (for admin operations)
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Never expose `SUPABASE_SERVICE_ROLE_KEY` to the client.** It bypasses RLS.

---

## Supabase Client Setup

### Client-Side (Browser)

```typescript
// lib/supabase/client.ts
import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

### Server-Side (Server Components, Route Handlers)

```typescript
// lib/supabase/server.ts
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export function createClient() {
  const cookieStore = cookies()

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {
            // Called from Server Component - ignore
          }
        },
      },
    }
  )
}
```

### Admin Client (Bypasses RLS)

```typescript
// lib/supabase/admin.ts
import { createClient } from '@supabase/supabase-js'

// Only use in server-side code for admin operations
export const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)
```

---

## Database Schema Design

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Tables | snake_case, plural | `users`, `project_members` |
| Columns | snake_case | `created_at`, `user_id` |
| Primary keys | `id` (UUID) | `id uuid default gen_random_uuid()` |
| Foreign keys | `{table}_id` | `user_id`, `project_id` |
| Timestamps | `created_at`, `updated_at` | Auto-managed |
| Booleans | `is_` or `has_` prefix | `is_active`, `has_access` |

### Standard Table Template

```sql
create table projects (
  -- Primary key
  id uuid default gen_random_uuid() primary key,

  -- Foreign keys
  user_id uuid references auth.users(id) on delete cascade not null,
  organization_id uuid references organizations(id) on delete cascade,

  -- Data columns
  name text not null,
  description text,
  status text default 'draft' check (status in ('draft', 'active', 'archived')),
  is_public boolean default false,
  metadata jsonb default '{}',

  -- Timestamps
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

-- Index for common queries
create index projects_user_id_idx on projects(user_id);
create index projects_status_idx on projects(status);

-- Auto-update updated_at
create trigger projects_updated_at
  before update on projects
  for each row
  execute function update_updated_at();
```

### Updated At Trigger

```sql
-- Create this function once per database
create or replace function update_updated_at()
returns trigger as $
begin
  new.updated_at = now();
  return new;
end;
$ language plpgsql;
```

### Common Patterns

#### User-Owned Resources

```sql
create table notes (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  title text not null,
  content text,
  created_at timestamptz default now() not null,
  updated_at timestamptz default now() not null
);

-- RLS: Users can only access their own notes
alter table notes enable row level security;

create policy "Users can view own notes"
  on notes for select
  using (auth.uid() = user_id);

create policy "Users can create own notes"
  on notes for insert
  with check (auth.uid() = user_id);

create policy "Users can update own notes"
  on notes for update
  using (auth.uid() = user_id);

create policy "Users can delete own notes"
  on notes for delete
  using (auth.uid() = user_id);
```

#### Many-to-Many (Join Table)

```sql
-- Projects can have many members, users can be in many projects
create table project_members (
  id uuid default gen_random_uuid() primary key,
  project_id uuid references projects(id) on delete cascade not null,
  user_id uuid references auth.users(id) on delete cascade not null,
  role text default 'member' check (role in ('owner', 'admin', 'member', 'viewer')),
  created_at timestamptz default now() not null,

  -- Prevent duplicate memberships
  unique(project_id, user_id)
);

create index project_members_project_id_idx on project_members(project_id);
create index project_members_user_id_idx on project_members(user_id);
```

#### Soft Deletes

```sql
create table documents (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  deleted_at timestamptz, -- null = not deleted
  created_at timestamptz default now() not null
);

-- Only show non-deleted by default
create policy "Hide deleted documents"
  on documents for select
  using (deleted_at is null);
```

---

## Row Level Security (RLS)

### Why RLS?

- **Security at the database level** — Even if app code has bugs, data is protected
- **Works with direct client access** — Safe to query from browser
- **Automatic filtering** — No need to add `WHERE user_id = ?` everywhere

### Enable RLS

```sql
-- Always enable RLS on tables with user data
alter table projects enable row level security;
```

### Policy Patterns

#### Owner-Only Access

```sql
-- Users can only access their own data
create policy "Owner access only"
  on notes for all
  using (auth.uid() = user_id);
```

#### Team/Organization Access

```sql
-- Users can access data in their organization
create policy "Organization members can view"
  on projects for select
  using (
    organization_id in (
      select organization_id from organization_members
      where user_id = auth.uid()
    )
  );
```

#### Role-Based Access

```sql
-- Different permissions based on role
create policy "Admins can update"
  on projects for update
  using (
    exists (
      select 1 from project_members
      where project_id = projects.id
        and user_id = auth.uid()
        and role in ('owner', 'admin')
    )
  );

create policy "Members can view"
  on projects for select
  using (
    exists (
      select 1 from project_members
      where project_id = projects.id
        and user_id = auth.uid()
    )
  );
```

#### Public + Private

```sql
-- Anyone can view public projects, only members can view private
create policy "View public or member projects"
  on projects for select
  using (
    is_public = true
    or exists (
      select 1 from project_members
      where project_id = projects.id
        and user_id = auth.uid()
    )
  );
```

#### Insert Policies

```sql
-- Ensure user_id is set correctly on insert
create policy "Users can create with own user_id"
  on notes for insert
  with check (auth.uid() = user_id);
```

### Debugging RLS

```sql
-- Temporarily disable RLS to debug (never in production!)
alter table projects disable row level security;

-- Check current user
select auth.uid();

-- Check what policies exist
select * from pg_policies where tablename = 'projects';
```

---

## Queries

### Basic CRUD

```typescript
import { createClient } from '@/lib/supabase/client'

const supabase = createClient()

// SELECT
const { data, error } = await supabase
  .from('projects')
  .select('*')

// SELECT with filter
const { data, error } = await supabase
  .from('projects')
  .select('*')
  .eq('status', 'active')
  .order('created_at', { ascending: false })

// SELECT single row
const { data, error } = await supabase
  .from('projects')
  .select('*')
  .eq('id', projectId)
  .single()

// INSERT
const { data, error } = await supabase
  .from('projects')
  .insert({ name: 'New Project', user_id: userId })
  .select()
  .single()

// UPDATE
const { data, error } = await supabase
  .from('projects')
  .update({ name: 'Updated Name' })
  .eq('id', projectId)
  .select()
  .single()

// DELETE
const { error } = await supabase
  .from('projects')
  .delete()
  .eq('id', projectId)
```

### Selecting Related Data

```typescript
// Join related tables
const { data, error } = await supabase
  .from('projects')
  .select(`
    *,
    user:users(id, name, email),
    members:project_members(
      id,
      role,
      user:users(id, name, email)
    )
  `)
  .eq('id', projectId)
  .single()

// Result shape:
// {
//   id: '...',
//   name: 'Project',
//   user: { id: '...', name: 'John', email: '...' },
//   members: [
//     { id: '...', role: 'admin', user: { id: '...', name: 'Jane', email: '...' } }
//   ]
// }
```

### Filtering

```typescript
// Equals
.eq('status', 'active')

// Not equals
.neq('status', 'archived')

// Greater than / Less than
.gt('price', 100)
.gte('price', 100)
.lt('price', 100)
.lte('price', 100)

// IN array
.in('status', ['draft', 'active'])

// LIKE (pattern matching)
.like('name', '%search%')
.ilike('name', '%search%')  // case insensitive

// IS NULL
.is('deleted_at', null)

// Contains (for arrays)
.contains('tags', ['javascript'])

// JSONB
.eq('metadata->category', 'tech')

// OR conditions
.or('status.eq.draft,status.eq.active')

// Complex filters
.or(`name.ilike.%${search}%,description.ilike.%${search}%`)
```

### Pagination

```typescript
// Offset pagination
const pageSize = 10
const page = 1

const { data, error, count } = await supabase
  .from('projects')
  .select('*', { count: 'exact' })
  .range((page - 1) * pageSize, page * pageSize - 1)
  .order('created_at', { ascending: false })

// count = total number of rows
// data = current page rows
```

### Counting

```typescript
// Count only
const { count, error } = await supabase
  .from('projects')
  .select('*', { count: 'exact', head: true })
  .eq('status', 'active')
```

---

## Migrations

### Local Development with Supabase CLI

```bash
# Install CLI
npm install -g supabase

# Login
supabase login

# Link to project
supabase link --project-ref your-project-ref

# Pull remote schema
supabase db pull

# Create new migration
supabase migration new create_projects_table

# Apply migrations locally
supabase db reset

# Push migrations to remote
supabase db push
```

### Migration File Structure

```
supabase/
├── config.toml
├── migrations/
│   ├── 20240115000000_create_users_profile.sql
│   ├── 20240115000001_create_projects.sql
│   └── 20240116000000_add_project_status.sql
└── seed.sql
```

### Writing Migrations

```sql
-- supabase/migrations/20240115000000_create_projects.sql

-- Up migration
create table projects (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  name text not null,
  created_at timestamptz default now() not null
);

alter table projects enable row level security;

create policy "Users can manage own projects"
  on projects for all
  using (auth.uid() = user_id);
```

### Rollback Strategy

Supabase doesn't have automatic rollbacks. Write reversible migrations:

```sql
-- Migration: Add column
alter table projects add column description text;

-- To reverse (run manually if needed):
-- alter table projects drop column description;
```

### Seed Data

```sql
-- supabase/seed.sql
-- Runs after migrations on `supabase db reset`

insert into projects (id, user_id, name) values
  ('11111111-1111-1111-1111-111111111111', 'user-uuid', 'Demo Project');
```

---

## TypeScript Types

### Generate Types from Database

```bash
# Generate types
supabase gen types typescript --project-id your-project-ref > src/types/database.ts
```

### Using Generated Types

```typescript
// types/database.ts (generated)
export type Database = {
  public: {
    Tables: {
      projects: {
        Row: {
          id: string
          user_id: string
          name: string
          created_at: string
        }
        Insert: {
          id?: string
          user_id: string
          name: string
          created_at?: string
        }
        Update: {
          id?: string
          user_id?: string
          name?: string
          created_at?: string
        }
      }
    }
  }
}
```

```typescript
// lib/supabase/client.ts
import { createBrowserClient } from '@supabase/ssr'
import { Database } from '@/types/database'

export function createClient() {
  return createBrowserClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}

// Usage - fully typed!
const supabase = createClient()

const { data } = await supabase
  .from('projects')  // autocomplete
  .select('*')
  .eq('status', 'active')  // type-checked

// data is typed as Database['public']['Tables']['projects']['Row'][]
```

### Helper Types

```typescript
// types/index.ts
import { Database } from './database'

// Table row types
export type Project = Database['public']['Tables']['projects']['Row']
export type ProjectInsert = Database['public']['Tables']['projects']['Insert']
export type ProjectUpdate = Database['public']['Tables']['projects']['Update']

// With relations (define manually)
export type ProjectWithMembers = Project & {
  members: (ProjectMember & { user: User })[]
}
```

---

## Real-Time Subscriptions

### Subscribe to Changes

```typescript
'use client'

import { useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase/client'

export function useRealtimeProjects() {
  const [projects, setProjects] = useState<Project[]>([])
  const supabase = createClient()

  useEffect(() => {
    // Initial fetch
    supabase
      .from('projects')
      .select('*')
      .then(({ data }) => setProjects(data || []))

    // Subscribe to changes
    const channel = supabase
      .channel('projects-changes')
      .on(
        'postgres_changes',
        {
          event: '*',  // INSERT, UPDATE, DELETE
          schema: 'public',
          table: 'projects',
        },
        (payload) => {
          if (payload.eventType === 'INSERT') {
            setProjects(prev => [...prev, payload.new as Project])
          } else if (payload.eventType === 'UPDATE') {
            setProjects(prev =>
              prev.map(p => p.id === payload.new.id ? payload.new as Project : p)
            )
          } else if (payload.eventType === 'DELETE') {
            setProjects(prev => prev.filter(p => p.id !== payload.old.id))
          }
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [])

  return projects
}
```

### Filter Subscriptions

```typescript
// Only subscribe to user's projects
.on(
  'postgres_changes',
  {
    event: '*',
    schema: 'public',
    table: 'projects',
    filter: `user_id=eq.${userId}`,
  },
  handleChange
)
```

---

## Storage

### Upload Files

```typescript
const supabase = createClient()

// Upload file
const { data, error } = await supabase.storage
  .from('avatars')  // bucket name
  .upload(`${userId}/avatar.png`, file, {
    cacheControl: '3600',
    upsert: true,
  })

// Get public URL
const { data: { publicUrl } } = supabase.storage
  .from('avatars')
  .getPublicUrl(`${userId}/avatar.png`)
```

### Storage Policies

```sql
-- Create bucket (in Supabase dashboard or SQL)
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true);

-- RLS for storage
create policy "Users can upload own avatar"
  on storage.objects for insert
  with check (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Anyone can view avatars"
  on storage.objects for select
  using (bucket_id = 'avatars');
```

---

## Performance Tips

### Indexes

```sql
-- Index columns used in WHERE, ORDER BY, JOIN
create index projects_user_id_idx on projects(user_id);
create index projects_status_idx on projects(status);

-- Composite index for common query patterns
create index projects_user_status_idx on projects(user_id, status);

-- Partial index for filtered queries
create index active_projects_idx on projects(created_at)
  where status = 'active';
```

### Query Optimization

```typescript
// Only select needed columns
const { data } = await supabase
  .from('projects')
  .select('id, name, status')  // Not select('*')

// Use count wisely
const { count } = await supabase
  .from('projects')
  .select('*', { count: 'exact', head: true })  // head: true = don't return rows

// Limit results
const { data } = await supabase
  .from('projects')
  .select('*')
  .limit(10)
```

### Connection Pooling

Supabase handles connection pooling automatically. For high-traffic apps:

```typescript
// Use connection pooler URL for serverless
// Settings → Database → Connection string → Mode: Transaction
```

---

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| RLS not enabled | Data exposed to all users | Always `enable row level security` |
| No policies | Users can't access data | Add appropriate policies |
| Using service key client-side | Full database access exposed | Only use anon key in browser |
| No indexes | Slow queries | Index frequently queried columns |
| SELECT * everywhere | Wasted bandwidth | Select only needed columns |
| N+1 queries | Many round trips | Use joins in select |
| Not using types | Type errors at runtime | Generate types with CLI |
| Forgetting ON DELETE CASCADE | Orphaned records | Set cascade on foreign keys |

---

## Quick Reference

### Supabase CLI Commands

```bash
supabase login           # Authenticate
supabase link            # Link to remote project
supabase db pull         # Pull remote schema
supabase db push         # Push migrations
supabase db reset        # Reset local database
supabase migration new   # Create migration
supabase gen types       # Generate TypeScript types
supabase start           # Start local Supabase
supabase stop            # Stop local Supabase
```

### Common Queries

```typescript
// Get all
await supabase.from('table').select('*')

// Get by ID
await supabase.from('table').select('*').eq('id', id).single()

// Get with relations
await supabase.from('table').select('*, relation(*)')

// Insert
await supabase.from('table').insert({ ... }).select().single()

// Update
await supabase.from('table').update({ ... }).eq('id', id)

// Delete
await supabase.from('table').delete().eq('id', id)

// Count
await supabase.from('table').select('*', { count: 'exact', head: true })
```

---

*See also: [API Routes](api.md) · [Auth](auth.md)*
