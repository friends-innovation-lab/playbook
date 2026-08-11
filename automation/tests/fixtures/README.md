# Test Fixtures

Synthetic provider API response data for mocked-boundary tests.

**These fixtures are NOT provider-policy evidence.** They test resolver
diagnostic classification behavior, not actual provider role/permission
semantics. Do not cite fixture data as proof that a role is sufficient
or insufficient for any real workflow.

Authoritative provider evidence is recorded in:
  docs/specs/PLAT-01-implementation-plan.md (WP0 Bootstrap Evidence)

## Fixture conventions

- JSON files represent provider API response bodies
- `.txt` files represent malformed or non-JSON responses
- Fixture names describe the test scenario, not provider policy
- Roles and permissions in fixtures are synthetic test values
