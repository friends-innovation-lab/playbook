# Demo Standards

A prototype is not ready to show until it meets every item on this list.
No exceptions for "we'll explain it during the demo."

## Non-negotiable (do not demo if any of these fail)

- [ ] Live at `[name].lab.cityfriends.tech` and accessible without VPN
- [ ] Primary user flow works end to end without errors
- [ ] No console errors in browser (open DevTools and check)
- [ ] Auth works — demo credentials exist and function
- [ ] Mobile works at 375px — tested on a real device, not just browser resize
- [ ] No lorem ipsum or placeholder text visible to the user
- [ ] `npm run test:a11y` passes with zero violations

## Should have before any government client demo

- [ ] Lighthouse accessibility score 90+
- [ ] All links work (no 404s the user can reach)
- [ ] Loading states visible on all data operations
- [ ] Error states visible and helpful (not blank screens)
- [ ] Empty states visible with clear direction for the user
- [ ] Tested in Chrome and Safari
- [ ] Sentry showing zero errors in the last 24 hours

## For government procurement challenge evaluations

- [ ] Demo credentials documented: username / password
- [ ] A backup plan exists if the live URL fails (screenshot deck minimum)
- [ ] Someone has run through the full demo flow cold (not just tested features)
- [ ] The team can answer: why did you choose this stack?
- [ ] The team can answer: how is this accessible?
- [ ] The team can answer: how does the data model work?
- [ ] The team can make a minor change request live during the meeting

## The live change test

Before any evaluation, verify that the team can:
1. Receive a change request verbally
2. Make the change in VS Code with CC's help
3. Push to GitHub
4. Have Vercel auto-deploy it
5. Refresh the live URL and show the change

This should take under 10 minutes. If it takes longer, practice until it doesn't.
