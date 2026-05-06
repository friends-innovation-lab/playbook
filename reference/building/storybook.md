# Storybook

Storybook is the component documentation and testing tool for every
project. It runs alongside the main app and shows every UI component
in isolation with all its variants, states, and accessibility results.

---

## What Storybook does

Every component in the project template has a story — a documented
page showing all its variants and states. Each story automatically
runs axe-core accessibility checks so violations are caught at the
component level, not just during full page tests.

When a project is deployed, Storybook deploys alongside it at:
`storybook.[projectname].lab.cityfriends.tech`

---

## Running Storybook locally

From inside your project folder:
```bash
npm run storybook
```

Opens at http://localhost:6006

---

## Using Storybook as a CC reference

This is the most important use of Storybook. Instead of only giving
CC a Figma file when building UI, also give it the Storybook URL.
CC gets a rendered component reference — actual browser CSS — which
produces higher fidelity output than Figma designs alone.

When asking CC to build a new feature:
```
Read CLAUDE.md. Reference the live Storybook at:
https://storybook.[projectname].lab.cityfriends.tech

Build [feature description] using the components documented
in Storybook. Match the component variants and states shown there.
```

---

## How to add a story for a new component

When you build a new component, add a story immediately.
Co-locate the story file with the component:
```
src/components/shared/my-component.tsx
src/components/shared/my-component.stories.tsx  ← add this
```

Minimum story structure:
```typescript
import type { Meta, StoryObj } from '@storybook/react'
import { MyComponent } from './my-component'

const meta: Meta<typeof MyComponent> = {
  title: 'Shared/MyComponent',
  component: MyComponent,
  tags: ['autodocs'],
  parameters: {
    layout: 'centered',
  },
}

export default meta
type Story = StoryObj<typeof MyComponent>

export const Default: Story = {
  args: {
    // your props here
  },
}
```

Every story must have `tags: ['autodocs']` — this generates the
documentation page automatically.

---

## Checking accessibility in Storybook

Click any story, then click the **Accessibility** tab in the
bottom panel. axe-core runs automatically and shows:

- **Violations** — must fix before shipping
- **Incomplete** — needs manual review
- **Passes** — confirmed accessible

A story with violations means the component fails accessibility
standards. Fix violations before merging.

---

## Building Storybook

```bash
npm run storybook:build
```

Outputs to `storybook-static/`. This is what gets deployed to Vercel.
The CI pipeline runs this on every PR — if it fails, the PR is blocked.

---

## Deployed Storybook

Every project gets a Storybook deployment at:
`storybook.[projectname].lab.cityfriends.tech`

This deploys automatically when you merge to main via the
`storybook-deploy.yml` GitHub Actions workflow.

The spinup script creates the Storybook Vercel project automatically
alongside the main project — you don't need to set anything up manually.

---

## Available components

Open Storybook to see all documented components. Current categories:

- **Auth** — LoginForm, SignupForm
- **Layout** — Header, Sidebar
- **Shared** — EmptyState, ErrorState, LoadingSkeleton, PageHeader
- **UI** — Avatar, Badge, Button, Card, Input
