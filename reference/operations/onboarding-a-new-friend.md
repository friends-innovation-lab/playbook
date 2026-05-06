# Onboarding (and Offboarding) a New Friend

The operational checklist for adding someone to the Treehouse — and removing them when they leave. Both halves matter equally. Skipping a step on offboarding leaves access dangling; skipping a step on onboarding leaves the new person stuck before they start.

> [!IMPORTANT]
> Offboarding matters as much as onboarding. Lingering access creates real risk. When someone leaves, work through the offboarding checklist on their last day — every platform, every credential.

Use this as a working document. Copy it for each person, check off as you go.

---

## Onboarding checklist

### Step 1: Confirm the basics

Before granting access, confirm with the new Friend:

- [ ] Their full name as it should appear in shared tools
- [ ] Their `@cityfriends.tech` email (or whatever Friends domain we're using)
- [ ] Their GitHub username — they need an account already; if they don't have one, ask them to create one before continuing
- [ ] Their role on the team (developer, designer, project lead, etc.) — affects which permissions they get

### Step 2: Grant access to all the platforms

Each of these is a separate invitation flow. The order doesn't matter strictly, but doing them in one sitting prevents forgetting one.

- [ ] **GitHub** — Add to `friends-innovation-lab` org with appropriate team membership (developers, designers, leads)
- [ ] **Vercel** — Invite to the Friends team with the role they need (Member is usually right; Admin only for senior people)
- [ ] **Supabase (Friends Innovation Lab org)** — Invite via the org settings; this is the production org for real projects
- [ ] **Supabase (Friends Lab CI org)** — Invite via the org settings; this is the test infrastructure org with the LAB_SUPABASE_ORG_ID
- [ ] **Railway** — Invite to the Friends team
- [ ] **Figma** — Add to the FFTC team so they can see the Tokens, Components, and Templates files
- [ ] **Anthropic Console** — Only if they specifically need API access for their work; most won't

### Step 3: Send the credentials email

The new Friend needs a small set of values to add to their shell profile during first-time setup.

The values shared on day one are identifiers (org IDs, team names) — not secrets that grant access on their own. Plain email is acceptable. For an extra layer of control, Gmail's Confidential mode (the lock icon when composing) lets you set an expiration date and prevent forwarding.

When new credentials get added that *do* grant access on their own — API keys, service tokens, database passwords — use 1Password share or another secure channel instead. The credentials email template should be updated to reflect those changes when they happen.

Copy the template below. Fill in the values from your records.

---

```text
Subject: Treehouse Innovation Lab — your credentials

Hi [Name],

Welcome to the Treehouse. A few values you'll need during first-time setup. Add them to your shell profile when the playbook tells you to.

# Friends Innovation Lab — shared credentials
export LAB_SUPABASE_ORG_ID="vbnqtawlnyzaioqbgwtw"

Some projects will need additional credentials (transactional email, rate limiting, AI APIs). Those get provisioned per-project when each one starts. You don't need them for setup or for your first test project.

Let me know if you have any trouble during setup. Better to ask early than struggle quietly.

— Lapedra
```

---

> [!TIP]
> Future Friends may need additional shared credentials (RESEND_API_KEY, UPSTASH_REDIS_REST_URL, UPSTASH_REDIS_REST_TOKEN). Add them to the email template above when those services get set up at the Friends level.

### Step 4: Send the welcome message

After the credentials email, point them at the playbook. Use Slack, email, or whatever's normal for Friends.

Copy the template below. Adjust the tone if you know them well.

---

```text
Subject: Welcome to the Treehouse — start here when you have an hour

Hi [Name],

The Treehouse Innovation Lab is set up and ready for you. When you have an hour, head to the playbook:

https://github.com/friends-innovation-lab/playbook/blob/main/START-HERE.md

That's the entry point. It walks you through what the lab is, how to set up your machine, and how to run your first test project. The whole onboarding takes a few hours spread across however many days work for you. No rush.

I'm available all of [day/week] if anything gets stuck or unclear. Better to flag a confusing step ten times than struggle quietly.

— Lapedra
```

---

### Step 5: Note the date

- [ ] Add the new Friend's name and start date to wherever you track team members (Notion, a spreadsheet, etc.)

This matters mostly for the offboarding checklist later. Knowing when someone joined helps with cleanup.

### Step 6: Be available

- [ ] Block 30 minutes on your calendar within their first week to check in
- [ ] Watch Slack for questions during their first week
- [ ] After their test project, schedule a debrief — what worked, what didn't, what should change

The first few people through any system find every rough edge. Treat their friction as data, not as their problem.

---

## Offboarding checklist

When a Friend leaves — whether they're moving on, the engagement is ending, or anything else — every access granted during onboarding needs to be revoked. This protects both Friends and the departing person.

### Step 1: Confirm the timeline

Before revoking anything, confirm with the departing Friend:

- [ ] Their last working day
- [ ] Whether they have any in-progress work that needs handoff
- [ ] Whether they need access preserved for any specific period (rare, but happens for contract reasons)

> [!WARNING]
> Revoke access *on* their last day, not before. They may need to wrap up work, export anything they want to keep, or do final handoffs.

### Step 2: Revoke platform access

Reverse of Step 2 in onboarding. Each platform is its own action.

- [ ] **GitHub** — Remove from `friends-innovation-lab` org (this revokes repo access)
- [ ] **Vercel** — Remove from the Friends team
- [ ] **Supabase (Friends Innovation Lab org)** — Remove from the org
- [ ] **Supabase (Friends Lab CI org)** — Remove from the org
- [ ] **Railway** — Remove from the Friends team
- [ ] **Figma** — Remove from the FFTC team
- [ ] **Anthropic Console** — Remove if they had access

> [!IMPORTANT]
> Removing someone from GitHub does not delete code they've contributed. Their commits remain in the history under their username. This is correct and expected.

### Step 3: Audit shared credentials

If they had access to shared lab credentials (`LAB_SUPABASE_ORG_ID` and any others), think through whether those values need to be rotated.

- [ ] Project-specific credentials they had access to (Anthropic API keys for specific projects, third-party services configured for projects they worked on) — rotate if there's any reason for concern
- [ ] Shared lab credentials (`LAB_SUPABASE_ORG_ID`) — generally don't need rotation since they're effectively public infrastructure identifiers, but reassess if circumstances warrant

For most amicable departures, no rotation is needed.

> [!CAUTION]
> For terminations or sensitive situations, rotate credentials liberally and update the credentials email template above. The cost of unnecessary rotation is small. The cost of leaving access in place after a difficult departure can be very large.

### Step 4: Reassign their work

- [ ] Identify projects where they were primary or co-owner
- [ ] Update CODEOWNERS files in those project repos to remove them
- [ ] Reassign Vercel project ownership if they were the owner
- [ ] Document any in-progress work in a handoff note

### Step 5: Update team records

- [ ] Mark them as departed in your team tracking with the offboarding date
- [ ] Archive any personal notes or documents specific to them that aren't needed going forward

### Step 6: Final check

A week or so after offboarding, do a quick verification:

- [ ] No open PRs from their account on lab repos
- [ ] No active deploy notifications going to their email
- [ ] No outstanding org invitations addressed to them

---

## When this checklist needs updating

This document is the operational record of how Friends manages access. It needs updating when:

- A new platform gets added to the lab stack (add to both onboarding and offboarding sections)
- A new shared credential gets provisioned (add to the credentials email template)
- A platform changes how invitations work (update the relevant step)
- Something goes wrong during onboarding or offboarding that this checklist didn't catch (add the missing step)

> [!TIP]
> Treat this as a living document. Updates are good. Stale checklists fail people.

---

*This checklist is for the operations team — currently Lapedra, eventually whoever handles Friends operations. Not part of the new-employee onboarding flow.*
