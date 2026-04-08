# Starter Prompts

Prompts that get a project 50% built from the start. Each prompt encodes
the right stack, structure, and standards for a specific type of tool.

## How to use a starter prompt

1. Spin up a new project with the spinup script
2. Open the project in VS Code
3. Tell CC:
   ```
   Read CLAUDE.md first. Then I'm going to give you a starter prompt
   for this type of project. Build what the prompt describes, using
   the project name and context from CLAUDE.md.
   ```
4. Paste the contents of the starter prompt
5. Add any project-specific requirements at the end

## Available prompts

| Prompt | Use for |
|---|---|
| [form-tool.md](form-tool.md) | Multi-step forms, intake, eligibility screening |
| [dashboard.md](dashboard.md) | Data display, filtering, program management views |
| [research-tool.md](research-tool.md) | Participant tracking, note-taking, synthesis |
| [document-generator.md](document-generator.md) | Inputs → structured document output |
| [internal-tool.md](internal-tool.md) | Admin panels, team workflows, FFTC tools |
| [challenge-response.md](challenge-response.md) | Government procurement challenge prototypes |
| [facility-finder.md](facility-finder.md) | Location-based search, provider lookup, site locators |
| [status-tracking.md](status-tracking.md) | Application status, claim tracking, permit status |
| [onboarding-tool.md](onboarding-tool.md) | Employee onboarding, training tracking, certifications |
| [scheduling.md](scheduling.md) | Appointment booking, resource scheduling, reservations |

## Common government challenge types

| Challenge type | Agencies | Starter prompt |
|---|---|---|
| Benefits eligibility & screening | VA, SSA, HHS | challenge-response + form-tool |
| Intake & application forms | VA, USCIS, SBA | form-tool |
| Case management interface | VA, HHS, DOJ | dashboard |
| Program dashboard & reporting | VA, DOD, EPA | dashboard |
| Document generation | DOD, GSA, contracting | document-generator |
| Facility & provider finder | VA, CMS, HRSA | facility-finder |
| Application status tracking | VA, USCIS, SSA | status-tracking |
| Research & survey tool | VA, NIH, Census | research-tool |
| Onboarding & training | VA, DOD, OPM | onboarding-tool + dashboard |
| Scheduling & appointments | VA, CMS | scheduling |

## What evaluators check every time

| Criterion | What they actually check |
|---|---|
| Section 508 / WCAG 2.1 AA | `npm run test:a11y` — zero violations |
| Mobile responsiveness | Real iPhone at 390px |
| Plain language | No jargon, clear labels |
| Performance | Lighthouse 90+ |
| Security | HTTPS, no exposed keys, input validation |
| Design system | Looks like it belongs in a federal context |
| Maintainability | Documented, another team could pick it up |

## What a starter prompt does not do

- It does not replace reading the challenge brief or requirements
- It does not make design decisions — those are yours
- It does not handle project-specific business logic
- It gets the structure right so you can focus on what matters
