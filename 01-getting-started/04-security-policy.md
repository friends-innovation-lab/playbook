# Token Security Policy

The lab uses shared service account tokens for automation — the spinup
and teardown scripts use these tokens to create and manage projects
across GitHub, Vercel, and Supabase on your behalf.

These tokens carry elevated permissions. Everyone on the team is
responsible for handling them carefully.

---

## Where tokens are stored

- All shared tokens are stored in **1Password** under the
  **Friends Innovation Lab** vault
- Contact Lapedra to get access to the vault during onboarding
- **Never** store tokens in Slack, email, Google Docs, or anywhere else
- **Never** commit tokens to any repository — even private ones

---

## Token expiry standard

- All tokens must be set to expire in **1 year** (the maximum)
- Lapedra will rotate tokens annually before they expire
- You will be notified when a token has been rotated and given the
  new value to update in your `~/.zshrc`

---

## Required MFA

- The `lab@cityfriends.tech` Supabase service account must have
  MFA enabled at all times
- If you notice MFA is disabled on this account, notify Lapedra immediately
- Your personal Supabase and Vercel accounts should also have MFA enabled —
  this is strongly recommended but not enforced

---

## When someone leaves the lab

1. Lapedra will revoke and regenerate all shared tokens within
   24 hours of an employee's last day
2. New tokens will be distributed to remaining team members via 1Password
3. Update your `~/.zshrc` with the new values and run:
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
5. Update the token in **1Password**
6. Notify the team

### Vercel

1. Log into Vercel as **Friends Innovation Lab** team owner
2. Go to **Settings** → **Tokens**
3. Revoke the old token
4. Generate a new token (set expiry to 1 year, scope to Friends Innovation Lab)
5. Update the token in **1Password**
6. Notify the team
