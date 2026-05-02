# Solutions Architecture Basics for Prototypes

*A practical guide for building MVPs with good bones*

---

## Why This Matters

You can ship a pretty app that works on demo day but falls apart in real use. Architecture is about making intentional decisions so your prototypes:

- Don't break in embarrassing ways
- Can be understood by future-you (or a handoff team)
- Can grow if needed without a full rewrite

You don't need to be a systems architect. You need to ask the right questions.

---

## The 7 Questions to Ask Every Project

Before building (or when reviewing what Claude Code generated), run through these:

### 1. Where does the truth live?

**Ask:** If a user updates something, where is that change stored? What's the single source of truth?

**Watch for:**
- Data duplicated in multiple places that can get out of sync
- Storing important state only in the browser (lost on refresh)
- Unclear whether the database or the UI is "right"

**Good pattern:** Database is the source of truth. UI reads from it and writes to it. Local state is temporary and disposable.

---

### 2. What happens when this fails?

**Ask:** When [database / API / network / auth] fails, what does the user see? What data could be lost?

**Watch for:**
- Blank screens with no explanation
- Lost form data after an error
- Silent failures (user thinks it worked, but it didn't)

**Good pattern:** Every external call (database, API) has error handling. Users see clear messages. Critical actions confirm success.

---

### 3. Who can do what?

**Ask:** Are there different types of users? What should each be able to see/do? How is that enforced?

**Watch for:**
- Authorization logic only in the UI (can be bypassed)
- No clear definition of roles
- Sensitive data exposed to wrong users

**Good pattern:** Authorization enforced at the database level (Row Level Security in Supabase) AND in the UI. Never trust the client alone.

---

### 4. What are the boundaries?

**Ask:** Where does your app end and external services begin? What data format do you expect from each?

**Watch for:**
- Tight coupling to a specific service (hard to swap later)
- No validation of incoming data
- Assumptions about data shape that aren't checked

**Good pattern:** External calls go through a wrapper function (like `lib/supabase.ts`). Validate data at boundaries. Type your expected responses.

---

### 5. What state lives where?

**Ask:** What data is in the database vs. the server vs. the browser? Why?

| Location | Good for | Bad for |
|----------|----------|---------|
| Database | Persistent data, shared data, source of truth | Temporary UI state |
| Server | Sensitive logic, API keys, heavy computation | Things that need instant updates |
| Browser | UI state, form inputs, optimistic updates | Anything that must survive refresh |

**Watch for:**
- Storing sensitive data in browser (localStorage, cookies without encryption)
- Fetching the same data repeatedly instead of caching
- State that's unclear about where it lives

---

### 6. How does data flow?

**Ask:** When a user takes an action, trace the path: UI → Server → Database → back. Where could it break?

**Draw it out:**
```
User clicks "Save"
  → Form validates (client)
  → API route called (server)
  → Supabase insert (database)
  → Success/error returned (server)
  → UI updates (client)
```

**Watch for:**
- Too many hops (overcomplication)
- No validation at any step
- Unclear what happens at each stage

---

### 7. What are the trade-offs?

**Ask:** What did you choose NOT to do? Why? What would trigger a different decision?

**Examples:**
- "We skipped authentication because this is an internal tool with 3 users. If it goes to 20+ users, add Supabase Auth."
- "We're storing files in Supabase Storage. If files get large or numerous, consider S3."
- "No caching right now. If pages feel slow, add React Query."

**Good pattern:** Document trade-offs in your README or HANDOFF.md. Future-you will thank you.

---

## Architecture Checklist for Claude Code

When Claude Code generates something, or before you ship, verify:

**Data & State**
- [ ] Source of truth is clear (usually the database)
- [ ] No sensitive data in browser storage
- [ ] Forms don't lose data on error

**Error Handling**
- [ ] Every database/API call has try/catch or .catch()
- [ ] Users see helpful error messages
- [ ] Console logs errors for debugging

**Security**
- [ ] API keys are in environment variables, not code
- [ ] Authorization checked on server, not just UI
- [ ] Row Level Security enabled in Supabase (if applicable)

**Boundaries**
- [ ] External services wrapped in lib/ functions
- [ ] TypeScript types defined for data shapes
- [ ] Validation on incoming data

**Maintainability**
- [ ] Someone else could understand this in 6 months
- [ ] Trade-offs documented
- [ ] No "magic" - logic is explicit

---

## Prompts to Use with Claude Code

When building, ask Claude these:

**During development:**
- "Explain why you structured it this way. What are the trade-offs?"
- "What happens if [Supabase / the API / the network] fails here?"
- "Where is the source of truth for [this data]?"
- "Is this secure? What could a malicious user do?"

**Before shipping:**
- "Review this code for error handling. What's missing?"
- "What would need to change if this had 100x more users?"
- "Write a summary of the architecture decisions for the handoff doc."

**When debugging:**
- "Why did this break? What assumption failed?"
- "Trace the data flow from user action to database and back."
- "What's the minimal change to fix this without breaking other things?"

---

## Quick Reference: Common Patterns

**API Route Structure (Next.js)**
```typescript
export async function POST(request: Request) {
  try {
    // 1. Parse and validate input
    const body = await request.json()
    if (!body.name) {
      return Response.json({ error: 'Name required' }, { status: 400 })
    }
    
    // 2. Do the work
    const result = await supabase.from('items').insert(body)
    
    // 3. Handle errors
    if (result.error) {
      console.error('DB error:', result.error)
      return Response.json({ error: 'Failed to save' }, { status: 500 })
    }
    
    // 4. Return success
    return Response.json({ data: result.data })
    
  } catch (error) {
    console.error('Unexpected error:', error)
    return Response.json({ error: 'Something went wrong' }, { status: 500 })
  }
}
```

**Component with Loading/Error States**
```typescript
function DataList() {
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  
  useEffect(() => {
    fetchData()
      .then(setData)
      .catch(setError)
      .finally(() => setLoading(false))
  }, [])
  
  if (loading) return <Spinner />
  if (error) return <ErrorMessage error={error} />
  if (!data.length) return <EmptyState />
  
  return <List items={data} />
}
```

---

## Keep Learning

**Books:**
- "Designing Data-Intensive Applications" by Martin Kleppmann - the bible

**YouTube/Newsletters:**
- ByteByteGo - visual system design explanations
- Fireship - fast, practical web dev concepts

**Documentation:**
- Supabase Docs (especially Row Level Security)
- Next.js Docs (App Router patterns)
- AWS Well-Architected Framework (principles apply everywhere)

---

*This isn't about building for millions of users. It's about making decisions explicit so things don't break in embarrassing ways and future-you can understand why things work the way they do.*
