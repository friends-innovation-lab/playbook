# Domain Setup for Projects

*Deploy new projects to `[project].lab.cityfriends.tech`*

---

## TL;DR

One command to launch a new project:

```bash
spinup project-slug "Client Name"
```

---

## Automated Setup (Recommended)

New projects are created with a single command that handles GitHub, Supabase, Vercel, and DNS automatically:

```bash
spinup project-slug "Project Name"
```

Example:
```bash
spinup acme-crm "Acme Corp CRM"
# Creates: https://acme-crm.lab.cityfriends.tech
```

**That's it.** The script handles everything including domain configuration.

See [automation/README.md](automation/README.md) for full documentation.

---

## How It Works

### DNS Architecture

- **Nameservers**: `ns1.vercel-dns.com`, `ns2.vercel-dns.com`
- **Wildcard SSL**: `*.lab.cityfriends.tech` is automatically covered
- **No manual DNS**: Vercel manages all DNS records for the domain

When the spinup script runs `vercel domains add`, the subdomain is instantly available because Vercel controls the nameservers.

### What Gets Created

| Resource | Location |
|----------|----------|
| GitHub repo | `github.com/friends-innovation-lab/[project-slug]` |
| Supabase project | `[project-ref].supabase.co` |
| Vercel deployment | Auto-deployed on push |
| Live URL | `https://[project-slug].lab.cityfriends.tech` |

---

## Manual Domain Addition (If Needed)

If you need to add a domain to an existing Vercel project:

```bash
cd [project-directory]
vercel domains add [project-slug].lab.cityfriends.tech
```

The domain will be active within 1-2 minutes. No DNS configuration required.

---

## Email/MX Records (Reference)

Email for `cityfriends.tech` is configured and working. No action needed for new projects.

| Type | Host | Value | Priority |
|------|------|-------|----------|
| MX | @ | `mx1.privateemail.com` | 10 |
| MX | @ | `mx2.privateemail.com` | 10 |
| TXT | @ | SPF record | - |
| CNAME | mail | `privateemail.com` | - |

---

## Deprecated: Manual DNS via Get.tech/tech.domains

> **Note**: The following instructions are deprecated. Domain DNS is now managed entirely through Vercel nameservers. These steps are preserved for historical reference only.

<details>
<summary>Old manual workflow (no longer needed)</summary>

### Step 1: Vercel (Add Domain)
1. Go to vercel.com → Project → Settings → Domains
2. Add `[projectname].lab.cityfriends.tech`
3. Copy the CNAME value Vercel shows

### Step 2: tech.domains (Add DNS Record)
1. Go to tech.domains → cityfriends.tech → DNS settings
2. Add CNAME record:
   - Host Name: `[projectname].lab`
   - Value: paste from Vercel
   - TTL: `7200`

### Step 3: Verify
1. Refresh in Vercel, wait for ✅ Valid Configuration
2. Visit `https://[projectname].lab.cityfriends.tech`

</details>

---

*Last updated: February 2025*
