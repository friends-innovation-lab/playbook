# Costs

What each tool costs and when you'll hit paid tiers.

## Free tiers — what you get

| Tool | Free tier | Limit to watch |
|---|---|---|
| Vercel | Unlimited personal projects | Bandwidth: 100GB/month |
| Supabase | 2 active projects | Database size: 500MB per project |
| Sentry | 5,000 errors/month | Errors per month |
| Resend | 3,000 emails/month | Emails per month |
| Upstash | 10,000 requests/day | Requests per day |
| GitHub | Unlimited public + private repos | Actions: 2,000 min/month |

## What triggers paid tiers for us

**Supabase** is the most common constraint. Free tier allows 2 active
projects. If you have more than 2 projects running simultaneously, you'll
need to either upgrade or tear down inactive projects.

Action: Run the teardown script on any project that has been idle for
30+ days.

**Vercel** bandwidth can be hit if a prototype goes viral or gets
heavily tested. Unlikely for most prototypes but watch for it.

## Paid tier costs (if needed)

| Tool | Paid tier | Cost |
|---|---|---|
| Supabase Pro | Unlimited projects | $25/project/month |
| Vercel Pro | Higher bandwidth | $20/month |
| Sentry Team | More errors | $26/month |
| Resend | More emails | $20/month |

## Cost hygiene rules

1. Run the teardown script on every project that is no longer active
2. Check active Supabase projects monthly — pause any not in active use
3. Check Vercel projects monthly — remove any not connected to active repos
4. Never leave client data in a Supabase project after a project ends

## Checking current costs

- Supabase: supabase.com/dashboard → org settings → billing
- Vercel: vercel.com → Settings → Billing
- Sentry: sentry.io → Settings → Billing
