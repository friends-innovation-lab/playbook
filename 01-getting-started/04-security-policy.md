# Token Security Policy

The lab uses service account tokens for automation — the spinup
and teardown scripts use these tokens to create and manage projects
across GitHub, Vercel, and Supabase on your behalf.

**Supabase** uses a shared service account token distributed by Lapedra.
**Vercel** tokens are individually generated — each team member creates
their own token scoped to the Friends Innovation Lab team
(see [First-Time Setup, Step 12](01-first-time-setup.md#vercel_token)).

These tokens carry elevated permissions. Everyone on the team is
responsible for handling them carefully.

---

## Where tokens are stored

- The shared Supabase token is stored in **Rippling RPASS** under the
  **Friends Innovation Lab** vault
- Contact Lapedra to get access to the vault during onboarding
- Vercel tokens are individually generated and managed — they are not in RPASS
- **Never** store tokens in Slack, email, Google Docs, or anywhere else
- **Never** commit tokens to any repository — even private ones

---

## Token expiry standard

- All tokens — shared and individual — must be set to expire in
  **1 year** (the maximum)
- The shared Supabase token is rotated by Lapedra annually before
  it expires; the new value is distributed via RPASS
- Individual Vercel tokens are managed by each team member — set a
  calendar reminder for your token's expiration and regenerate it
  yourself when it expires

---

## Required MFA

- The `lab@cityfriends.tech` Supabase service account must have
  MFA enabled at all times
- If you notice MFA is disabled on this account, notify Lapedra immediately
- Your personal Supabase and Vercel accounts should also have MFA enabled —
  this is strongly recommended but not enforced

---

## When someone leaves the lab

1. Remove the departing member from the Friends Innovation Lab Vercel
   team — this revokes their token's access to team resources (the
   token technically survives on their personal account, but team
   resources are what we're protecting)
2. Lapedra will revoke and regenerate the shared Supabase token within
   24 hours of the employee's last day
3. The new Supabase token will be distributed to remaining team members via Rippling RPASS
4. Update your `~/.zshrc` with the new value and run:
   ```bash
   source ~/.zshrc
   ```

---

## If a token is compromised

If you believe a token has been exposed (accidentally committed,
shared in Slack, etc.):

1. **Notify Lapedra immediately** — do not wait
2. Lapedra will revoke the token immediately and issue a new one
3. Do not attempt to fix it yourself

---

## Token rotation process (for Lapedra)

### Supabase

1. Log into `lab@cityfriends.tech` Supabase account
2. Go to **Account** → **Access Tokens**
3. Revoke the old token
4. Generate a new token (set expiry to 1 year)
5. Update the token in **Rippling RPASS**
6. Notify the team

### Vercel

Individual Vercel tokens do not require centralized rotation. When a team
member leaves, removing them from the Vercel team revokes their token's
access to team resources. No action is needed for remaining team members'
tokens.
