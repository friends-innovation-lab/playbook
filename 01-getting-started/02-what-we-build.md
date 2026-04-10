# What We Build

Friends Innovation Lab builds two types of projects.

---

## 1. Government / client-facing prototypes

Working prototypes built in response to government procurement challenges
or for specific client engagements.

**The context:** Federal agencies increasingly run challenge-based
procurements where vendors submit a working prototype instead of a
written proposal. Evaluators stress test these prototypes — they look
at accessibility, real functionality, design quality, and whether the
vendor can defend their decisions under pressure.

**What this means for how we build:**
- Every prototype is live at a real URL from day one
- Section 508 accessibility is non-negotiable, not an afterthought
- The design system, code quality, and documentation must be defensible
- We should be able to make a change request live during an evaluation meeting

**Timeline:** Typically 1–2 weeks from spinup to demo-ready.

**Examples of what we build:**
- Veteran intake and eligibility screening tools
- Program management dashboards for federal agencies
- Research and survey tools for government user research
- Document generation tools for procurement and contracting
- Case management interfaces

---

## 2. Internal tools

Tools that help FFTC and the lab operate more efficiently.

**The context:** We build the same types of tools for ourselves that we
build for clients. This keeps our skills sharp, produces real value for
FFTC operations, and gives us working examples to show during evaluations.

**What this means for how we build:**
- Faster and more flexible than government work — fewer constraints
- Still built on the same stack and standards
- Accessibility is still important but not blocking
- Timeline is more flexible

**Examples:**
- Qori — AI-enabled research operations platform
- Truebid — Basis of Estimate document generator for government contractors
- Internal dashboards, admin tools, workflow automation

---

## The rules that apply to both

Regardless of project type, every project we build:

| Rule | Why |
|---|---|
| Lives at `[name].labs.cityfriends.tech` | Real URL signals legitimacy |
| Uses the standard stack | Consistency = speed |
| Has auth wired up from day one | Nothing ships without knowing who the user is |
| Has RLS on every database table | Data security is non-negotiable |
| Passes `npm run check` before any PR | Code quality is automatic, not manual |
| Has a `CLAUDE.md` in the project root | CC needs context to be useful |

---

## What we don't build

- Full production systems (we prototype, then hand off or evolve)
- Marketing websites (not our focus)
- Native mobile apps (we use responsive web)
- Anything that requires FedRAMP ATO at prototype stage
  (we build on a path toward FedRAMP, not certified yet)
