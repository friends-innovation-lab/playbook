# Friends Innovation Lab - Progress Journal

## Project Overview
Building out an Innovation Lab as a new line of business for Friends From The City. The lab offers rapid prototyping services for civic tech organizations - government agencies, government contractors, and nonprofits serving the public.

**Specialization:** Internal tools and operational software for civic tech. We build dashboards, portals, case management, workflow tools, proposal systems, accessibility tools, knowledge management platforms, AI chatbots, and compliance trackers.

**We don't build:** Marketing websites, mobile apps, e-commerce.

---

## January 12, 2025

### What We Accomplished

**1. Defined the Business Model**
- Three service tiers established:
  - **Discovery Prototype** ($15K-$25K) - Fast, disposable, minimal docs. Good for gov't micropurchase.
  - **Pilot-Ready MVP** ($35K-$60K) - Production-grade for limited use, light maintenance.
  - **Foundation Build** ($75K-$120K) - Architected for scale, full documentation, handoff support.
- 2-month engagement structure with 4 iterations/check-ins
- Key differentiators: Founder-built, government-native, HCD/research-first, AI-augmented, right-sized for the work

**2. Set Up Domain Structure**
- Using `cityfriends.tech` for the lab
- Pattern: `[project].lab.cityfriends.tech`
- DNS configured at tech.domains:
  - CNAME: `lab` → `cname.vercel-dns.com`
  - CNAME: `*.lab` → `cname.vercel-dns.com`
  - Project-specific CNAMEs as needed (e.g., `truebid.lab`)

**3. Created GitHub Organization**
- New org: `friends-innovation-lab` (https://github.com/friends-innovation-lab)
- Separate from main Friends From The City org for cleaner client separation
- Template repo created: `project-template`
- Marked as GitHub template for easy "Use this template" workflow

**4. Built Project Template**
Template includes:
- Next.js 14 with App Router
- TypeScript
- Tailwind CSS
- Supabase client setup (`lib/supabase.ts`, `lib/supabase-server.ts`)
- Utility functions (`lib/utils.ts`)
- Environment template (`.env.example`)
- Internal setup guide (`docs/SETUP.md`)
- Client handoff template (`docs/HANDOFF.md`)

**5. Connected Vercel**
- Vercel connected to `friends-innovation-lab` GitHub org
- First subdomain live: `truebid.lab.cityfriends.tech` ✅
- Workflow: Deploy project → Add domain in Vercel → Add CNAME in tech.domains

**6. Set Up Supabase**
- Renamed org to "Friends Innovation Lab"
- TrueBid project already there
- New client projects will be created as needed
- Free tier = 2 projects, Pro = $25/month per project

**7. Created Foundational Documents**
- 01 - Why Friends Innovation Lab Exists (North Star document)
- 02 - Solutions Architecture Basics
- 03 - Testing with Claude Code

**8. Defined the Vision**
Three revenue streams from one capability:
1. **Service revenue** - client-paid prototypes
2. **Contract feeder** - prototypes that convert to larger Friends From The City contracts
3. **Product incubator** - prototypes that become SaaS products (TrueBid is the first)

**9. Mapped the Friends Proposal Suite**
Defined how TrueBid connects to a larger product ecosystem:
- TrueBid (scoping engine) → Past Performance AI → Technical Volume AI → Key Personnel Manager → Proposal Workspace

---

### Tech Stack Summary
| Layer | Tool |
|-------|------|
| Framework | Next.js 14 (App Router) |
| Language | TypeScript |
| Styling | Tailwind CSS |
| Components | shadcn/ui (install per-project as needed) |
| Database | Supabase (PostgreSQL) |
| Auth | Supabase Auth |
| Hosting | Vercel |
| Domain | cityfriends.tech (via tech.domains) |
| Repo | GitHub (friends-innovation-lab org) |

---

### New Client Project Workflow
1. GitHub: Go to `project-template` → "Use this template" → name it `client-[name]`
2. Local: Clone repo, run `npm install`, copy `.env.example` to `.env.local`
3. Supabase: Create new project, copy URL + anon key to `.env.local`
4. Vercel: Import repo, add env vars, deploy
5. Domain: Add `[name].lab.cityfriends.tech` in Vercel, add CNAME in tech.domains
6. Build: Start prototyping!

---

## Full Roadmap

### Innovation Lab Playbook (Service Business)

**Completed:**
- [x] 01 - Why Friends Innovation Lab Exists
- [x] 02 - Solutions Architecture Basics
- [x] 03 - Testing with Claude Code

**Design & Frontend:**
- [ ] 04 - UI/UX & Interaction Design Guide (comprehensive, with reusable code, brand systems, USWDS, visual vocabulary, government patterns)

**Code Quality:**
- [ ] 05 - Code Standards & Best Practices
- [ ] 06 - Frontend Guide
- [ ] 07 - Backend Guide (includes file uploads, email, auth, PDFs, integrations)

**Client Experience & Operations:**
- [ ] 08 - Client Journey Map
- [ ] 09 - Client Communication Templates (kickoff, check-ins, delays, handoff emails)
- [ ] 10 - Intake Form
- [ ] 11 - Proposal Templates (by tier)
- [ ] 12 - Contract/SOW Template
- [ ] 13 - How to Say No (scoping boundaries, change requests)
- [ ] 14 - Offboarding Checklist

**Running the Business:**
- [ ] 15 - Project Management System
- [ ] 16 - Pricing Calculator
- [ ] 17 - Time Tracking
- [ ] 18 - Claude Code Workflow Guide

**Growth:**
- [ ] 19 - Case Study Template
- [ ] 20 - One-Pager / Pitch Deck
- [ ] 21 - Content & Thought Leadership Plan

**Automation:**
- [ ] 22 - Project Spinup Script (repo, Supabase, Vercel, domain, issues - one command)
- [ ] 23 - Client Portal Page (status, changelog, decisions, docs - built into each app)
- [ ] 24 - Intake Form → GitHub Automation
- [ ] 25 - Deploy → Client Notification Automation
- [ ] 26 - Auto-Generated Handoff Packet
- [ ] 27 - Post-Project Feedback Automation

**Specialization:**
- [ ] 28 - Service Specialization Guide (civic tech focus, what we build, what we don't)
- [ ] 29 - Tool Type Templates (dashboard, portal, case management, proposal builder, tracker, knowledge base, AI chatbot)

---

### Friends Proposal Suite (Products)

**TrueBid (Foundation Layer - exists):**
- Parses RFP SHALL statements
- Generates WBS from requirements
- Estimates LOE per WBS
- Assigns labor categories
- Calculates team structure
- Prices with BLS validation
- Outputs: Pricing volume, team structure for technical volume, match criteria for PP

**Products to Build:**
- [ ] 30 - Past Performance AI (database, AI matching, narrative generation in Friends voice)
- [ ] 31 - Key Personnel Manager (resume database, AI-tailored resumes per RFP)
- [ ] 32 - Technical Volume AI (approach, staffing, management, risk - generated from TrueBid WBS)
- [ ] 33 - Proposal Workspace (unified view, compliance tracking, team collaboration)
- [ ] 34 - Voice Training System (capture and encode Friends writing style)
- [ ] 35 - Product Suite Integration Spec (how products pass data to each other)
- [ ] 36 - Proposal Team Operating Model (who does what, when)

**Additional Product Ideas:**
- [ ] 37 - Product Bundles (Contractor Starter Kit, Agency Ops Bundle, etc.)
- [ ] 38 - Maintenance & Support Tiers (recurring revenue)
- [ ] 39 - Retainer Model (Innovation Lab on call)
- [ ] 40 - Workshop/Training Offerings
- [ ] 41 - Partnership Strategy
- [ ] 42 - Open Source Play (starters as lead gen)

---

### Tool Types We Build

**For Small Businesses (Civic Tech):**
- Custom CRM
- Client Portal
- Intake/Onboarding System
- Internal Dashboard
- Scheduling/Booking Tool
- Quote/Estimate Builder
- Inventory Tracker
- Approval Workflow

**For Government:**
- Case Management System
- Eligibility Screener
- Application Portal
- Internal Dashboard
- Document Management
- Reporting Tool
- Workflow Automation
- Training/Certification Tracker
- Grant Management
- Inventory/Asset Tracker
- Scheduling/Resource Allocation
- Audit Tracker
- FOIA Request Tracker
- Public Comment Manager
- Constituent Service Tracker
- Contract Management
- Compliance Tracker
- Equity Assessment Tool

**For Government Contractors:**
- Proposal Builder (TrueBid)
- RFP Response Tracker
- Capture Management
- Past Performance Database
- Teaming Partner Tracker
- Pricing Calculator
- Compliance Checklist Tool

**Accessibility Tools:**
- Accessibility Checker Dashboard
- VPAT Generator
- Remediation Tracker
- Alt Text Manager
- Accessibility Training Tracker
- Complaint/Request Tracker

**Knowledge Management:**
- Internal Wiki/Knowledge Base
- Onboarding Portal
- Policy Library
- Lessons Learned Database
- FAQ Builder
- Training Resource Hub
- Decision Repository
- Process Documentation Tool

**AI/Chatbots:**
- Internal Q&A Bot
- Policy Assistant
- Onboarding Buddy
- Public-Facing FAQ Bot
- Document Search Assistant
- Eligibility Assistant
- RFP Q&A Bot
- IT Help Desk Bot

---

## Quick Reference

**GitHub Org**: https://github.com/friends-innovation-lab
**Template Repo**: https://github.com/friends-innovation-lab/project-template
**Live Example**: https://truebid.lab.cityfriends.tech
**Supabase**: https://supabase.com/dashboard (org: Friends Innovation Lab)
**DNS Management**: tech.domains (cityfriends.tech)
**Vercel Team**: Friends Innovation Lab

---

## Next Session Priorities

1. **UI/UX & Interaction Design Guide** - comprehensive, with reusable code, visual vocabulary, client brand systems, USWDS, government patterns (dashboards, tables, search, account centers)

2. **Past Performance AI spec** - database schema, AI matching logic, voice training system, user flows

3. **Client Journey Map** - every touchpoint from awareness to referral

---

*Last updated: January 13, 2025*
