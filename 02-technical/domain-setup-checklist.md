# Adding a New Subdomain (Checklist)

*Use this every time you deploy a new project to `[project].lab.cityfriends.tech`*

---

## Step 1: Vercel (Add Domain)

1. Go to **vercel.com**
2. Click on your project (e.g., candlelight-trading)
3. Click **Settings** (top right tabs)
4. Click **Domains** (left sidebar)
5. Click **Add Domain** button
6. Type: `[projectname].lab.cityfriends.tech`
7. Make sure "Connect to an environment" → **Production** is selected
8. Click **Save**
9. You'll see a yellow "DNS Change Recommended" warning - **this is normal**
10. Copy the CNAME value Vercel shows you (something like `642419c215da309a.vercel-dns-016.com`)

---

## Step 2: tech.domains (Add DNS Record)

1. Go to **tech.domains**
2. Log in
3. Find **cityfriends.tech** → DNS settings
4. Click **CNAME Records** tab
5. Add new record:
   - **Host Name:** `[projectname].lab` *(just that part, not the full domain)*
   - **Value:** paste the value from Vercel
   - **TTL:** `7200`
6. Click **Add Record**

---

## Step 3: Verify

1. Go back to **Vercel**
2. Click **Refresh** next to your domain
3. Wait 1-5 minutes (sometimes up to an hour for DNS to propagate)
4. Once it shows ✅ **Valid Configuration**, you're done!
5. Visit your URL to confirm: `https://[projectname].lab.cityfriends.tech`

---

## Troubleshooting

**Still showing "Invalid Configuration" after an hour?**
- Double-check the CNAME value matches exactly what Vercel shows
- Make sure there's no typo in the Host Name
- Check if there's a conflicting A record for the same subdomain

**Site loads but shows wrong project?**
- Make sure you added the domain to the correct project in Vercel

**SSL certificate error?**
- Wait a few more minutes - Vercel auto-provisions SSL but it can take time

---

## Quick Reference

| Where | What to enter |
|-------|---------------|
| Vercel domain field | `projectname.lab.cityfriends.tech` (full) |
| tech.domains Host Name | `projectname.lab` (partial) |
| tech.domains Value | Copy from Vercel's recommendation |
| tech.domains TTL | `7200` |

---

*Last updated: January 13, 2025*
