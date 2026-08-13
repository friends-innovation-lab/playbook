# WP-01 Breakable Downstream Simulator — Canonical Specification

Version: v2.0
Status: Canonical
Supersedes: docs/WP-01-downstream-simulator.md (v1.1 draft)
Depends on: None

## Architecture Decisions

The following decisions were resolved during architecture intake and are
normative for implementation.

| Decision | Value |
|---|---|
| Implementation home | `friends-innovation-lab/downstream-simulator` (standalone repo) |
| Implementation runtime | Python >= 3.12 |
| Framework | FastAPI |
| Process model | Persistent HTTP service (Uvicorn) |
| State model | In-memory stateful |
| MVP workers | 1 (single Uvicorn worker) |
| MVP replicas | 1 (single Railway service replica) |
| State distribution | None (single-process only) |
| Deployment target | Railway |
| PLAT-01 blockers | None |

Railway account access does not block local development or CI. The service
must remain container/process portable.

### Single-Instance State Constraint

Because MVP state is in memory, the application requires:

- one application process
- one Uvicorn worker
- one Railway service replica
- no horizontal scaling

Global mode, request history, idempotency registry, and intermittent-failure
counters would diverge between processes if this constraint were violated.

State mutations must be concurrency-safe within the single async process.
The implementation shall use a single `SimulatorState` abstraction with an
asyncio-compatible lock around compound state transitions.

Distributed or persistent state is out of MVP scope.

## Purpose

Provide a small standalone HTTP service that behaves like a downstream
transactional dependency and can be deliberately placed into known failure
modes.

The simulator exists to support development, testing, and demonstration of:

- submission failure handling
- retries
- idempotency
- delayed acknowledgements
- transaction tracing
- recovery and reconciliation
- monitoring and alerting

It is a test dependency, not a production service.

The simulator shall remain domain-neutral. VA-specific workflows may use it,
but the core simulator must be reusable for other federal, healthcare,
financial, SaaS, and internal delivery scenarios.

## Deployment Target

The simulator shall run as a persistent service on Railway.

Railway is the preferred target because the simulator needs to support
behaviors such as holding open connections, maintaining in-memory request
history, and producing controlled delays without relying on serverless
execution semantics.

The simulator shall remain outside the standard lab spinup automation path
for this work package.

Future challenge or domain profiles may provision or reference the simulator
as a dependency, but WP-01 shall remain standalone.

The service must:

- listen on environment `PORT` (Railway convention) or `8000` default
- expose `GET /health` returning 200 when ready
- include Railway-compatible deployment configuration (Procfile or equivalent)
- remain container/process portable for local and CI use

## Required Interface

### Submission Endpoint

`POST /submit`

Accept a synthetic structured submission.

Request contract:

```json
{
  "submissionId": "string (required)",
  "correlationId": "string (optional)",
  "idempotencyKey": "string (required)",
  "payload": {}
}
```

If `correlationId` is omitted, the simulator shall generate a UUID v4. This
behavior is deterministic: absent correlation IDs are always generated, never
rejected.

The simulator must preserve enough request metadata to inspect what happened
during a test.

#### Per-Request Overrides

The submission endpoint shall support request-scoped overrides via headers:

```text
X-Simulator-Mode: <mode>
X-Simulator-Delay-Ms: <int>
X-Simulator-Retry-After: <int>
X-Simulator-Fail-Count: <int>
```

Header names are namespaced with `X-Simulator-` so they cannot be mistaken
for production protocol headers.

Per-request override values always take precedence over the current global
setting.

#### Success Response Contract

```json
{
  "simulator": true,
  "status": "accepted",
  "submissionId": "...",
  "correlationId": "...",
  "idempotencyKey": "...",
  "downstreamReference": "...",
  "effectiveMode": "healthy",
  "modeSource": "default",
  "duplicate": false
}
```

Field definitions:

| Field | Type | Description |
|---|---|---|
| `simulator` | boolean | Always `true`. Simulator marker. |
| `status` | string | `"accepted"` for successful submissions. |
| `submissionId` | string | Echoed from request. |
| `correlationId` | string | Echoed from request, or generated UUID if absent. |
| `idempotencyKey` | string | Echoed from request. |
| `downstreamReference` | string | Generated UUID representing downstream transaction ID. |
| `effectiveMode` | string | The failure mode actually applied to this request. |
| `modeSource` | string | One of `"default"`, `"global"`, `"override"`. |
| `duplicate` | boolean | `true` if this idempotency key was previously seen. |

#### Error Response Contract

Error responses (HTTP 500, 429) shall preserve `simulator`, `correlationId`,
`effectiveMode`, `modeSource`, and `duplicate` where structurally possible.

The `status` field shall reflect the error condition (e.g. `"error"`,
`"rate_limited"`).

### Health Endpoint

`GET /health`

Returns HTTP 200 with:

```json
{
  "simulator": true,
  "status": "healthy",
  "currentMode": "...",
  "version": "..."
}
```

### Control Interface

All control routes require shared-secret authentication (see Safety section).

Control routes are clearly separated from the simulated downstream interface.

#### Set Global Mode

`PUT /control/mode`

Set the global simulator behavior at runtime without redeployment.

Request body:

```json
{
  "mode": "healthy",
  "delayMs": 0,
  "retryAfter": 0,
  "failCount": 0
}
```

All fields except `mode` are optional and retain their current values if
omitted.

#### Get Global Mode

`GET /control/mode`

Returns current global configuration.

#### Reset State

`POST /control/reset`

Clears:

- request history
- idempotency registry
- intermittent-failure counters
- resets global mode to `healthy` with default values

#### Get Request History

`GET /control/history`

Returns recent request history entries from the ring buffer, newest first.

Optional query parameter `limit` controls how many entries to return.

### Configuration Precedence

Failure behavior resolves using this precedence order:

```text
per-request override > global simulator mode > default healthy
```

Tests should use per-request overrides so concurrent tests do not mutate
shared global state.

Interactive demonstrations and manual testing may use the global control
interface.

The effective mode applied to a request must be recorded in:

1. response metadata (`effectiveMode` and `modeSource` fields)
2. the corresponding request-history entry

The `modeSource` field makes it unambiguous whether a request used:

- `"override"` — a per-request override header
- `"global"` — the current global simulator setting
- `"default"` — the default healthy mode (no global override set, no request override)

## Failure Modes

The simulator must support:

```text
healthy
http_500
http_429
timeout
malformed_response
delayed_success
intermittent_failure
```

### Healthy

Returns a successful acknowledgement with the full success response contract.

### HTTP 500

Return an HTTP 500 response representing a downstream internal failure.

The response body includes the simulator marker, correlation metadata,
`effectiveMode`, `modeSource`, and `duplicate` where practical.

### HTTP 429

Return an HTTP 429 response immediately.

Include a configurable `Retry-After` header. `Retry-After` is response
metadata instructing the client when it may retry. The simulator must NOT
sleep or delay the response when emitting `Retry-After`. Server-side
sleeping occurs only in modes whose explicit behavior is delay or timeout
simulation (`delayed_success`, `timeout`).

The effective retry duration must be captured in request history.

### Timeout

Accept the connection but delay completion beyond a configurable duration.

The simulator must not rely on terminating or crashing the process to create
this condition.

**Distinction from delayed success:** Timeout uses a delay duration intended
to exceed the caller's timeout threshold. The simulator still eventually
returns a valid response, but the expectation is that the caller will have
abandoned the connection. Delayed success uses a shorter delay and returns
before the caller times out. The difference is configurable duration and
intended caller experience, not response validity.

### Malformed Response

Return HTTP 200 with a response body that violates the documented success
contract.

This mode exists to demonstrate that transport success does not necessarily
mean business success.

Where possible, the response should still include the `simulator` marker
unless doing so would defeat the purpose of the malformed-response scenario.

### Delayed Success

Return a valid successful acknowledgement after a configurable delay.

See the timeout section for the operational distinction between delayed
success and timeout.

### Intermittent Failure

Fail according to a deterministic configurable pattern.

Example:

```text
fail first 2 requests, then succeed
```

Random failure behavior shall not be used for automated acceptance tests.

**Failure counter key:** Intermittent-failure state is keyed by
`idempotencyKey`. This aligns with retry and idempotency test scenarios
where the same logical submission is retried with the same idempotency key.

**Deterministic sequence:** For a configured `failCount` of N:

- Attempts 1 through N return a deterministic failure response.
- Attempt N+1 returns success and registers the `downstreamReference` in
  the idempotency cache.
- Failed attempts advance the counter but are NOT stored in the idempotency
  cache. Only the first successful response is cached.
- Subsequent requests with the same `idempotencyKey` return the cached
  success with `duplicate: true`.
- No random re-roll occurs. The sequence is strictly deterministic.

## Idempotency Behavior

The simulator shall record idempotency keys.

For repeated requests using the same idempotency key where a prior
successful response exists:

- The previously generated `downstreamReference` is reused.
- The response includes `"duplicate": true`.
- The duplicate attempt is recorded in request history with its own entry,
  clearly marked as a duplicate.

Failed attempts (including intermittent-failure attempts before the success
threshold) do not create idempotency cache entries. Only the first
successful response for a given `idempotencyKey` is cached.

In `intermittent_failure` mode, the fail counter increments per attempt.
Once the configured threshold is exceeded, the request succeeds and the
`downstreamReference` is registered in the idempotency cache. Subsequent
requests with that `idempotencyKey` return the cached success with
`duplicate: true`.

The simulator does not define the calling application's idempotency strategy.
That belongs to a later work package.

WP-01 only needs to provide a reliable test surface for idempotency behavior.

## Observability

### Structured Logging

The simulator shall emit structured JSON logs to stdout (Railway captures
stdout).

For every request, log at minimum:

```text
timestamp
submissionId
correlationId
idempotencyKey
configuredGlobalMode
requestOverrideMode (if present)
effectiveMode
modeSource
attemptNumber
httpStatus
downstreamReference (if created)
duplicate
```

Do not log synthetic payload fields.

### Request History

Request history shall be maintained in memory using a bounded ring buffer.

Requirements:

- maximum entry count must be configurable (default: 1000)
- oldest entries are evicted first
- process restart clears history
- history is diagnostic only and is not durable
- the authenticated reset operation clears history
- recent history must be inspectable via `GET /control/history`
- history entries must expose `effectiveMode` and `modeSource`

No database is required for WP-01.

If a later work package requires durable trace inspection, persistence may be
added behind a separate adapter without changing the public simulator contract.

### History Entry Schema

Each history entry records:

```json
{
  "timestamp": "ISO 8601",
  "submissionId": "...",
  "correlationId": "...",
  "idempotencyKey": "...",
  "globalModeAtTime": "...",
  "requestOverrideMode": null,
  "effectiveMode": "...",
  "modeSource": "default|global|override",
  "attemptNumber": 1,
  "httpStatus": 200,
  "downstreamReference": "...",
  "duplicate": false
}
```

## Configuration

### Runtime Configuration (Control Interface)

Global simulator behavior is configurable at runtime via the control
interface:

```text
mode (default: healthy)
delayMs (default: 0)
retryAfter (default: 0)
failCount (default: 0)
```

Changing runtime behavior does not require editing source code, rebuilding,
or redeploying.

Per-request overrides remain independent of global configuration.

### Environment Configuration

```text
PORT — listening port (default: 8000)
SIMULATOR_ADMIN_SECRET — shared secret for control routes (required)
SIMULATOR_HISTORY_SIZE — ring buffer capacity (default: 1000)
```

## Safety

Use synthetic data only.

The simulator must:

- contain no VA credentials
- contain no production credentials
- contain no production endpoints
- contain no Veteran data
- make it structurally obvious that it is a simulator
- prevent accidental configuration as a production downstream service

### Simulator Marker

Every response body that can return structured content must include:

```json
{
  "simulator": true
}
```

Where response bodies are intentionally malformed, the implementation should
still provide a simulator marker where doing so does not defeat the purpose
of the malformed-response scenario.

### Control-Route Authentication

All control and administrative routes must require a shared-secret header.

This includes routes that:

- change global failure mode
- change runtime delay values
- set retry behavior
- reset state
- clear history
- inspect request history

Requirements:

- the secret is read from the `SIMULATOR_ADMIN_SECRET` environment variable
- the secret must never be committed to source control
- the secret must never be written to logs
- missing or invalid secrets must be rejected with HTTP 401
- secret comparison must use `hmac.compare_digest` (constant-time) to
  prevent timing side-channels
- simulated downstream routes (`/submit`, `/health`) remain unauthenticated

The shared-secret mechanism is sufficient for WP-01 because this is a test
dependency, not a production service.

## Acceptance Criteria

WP-01 is accepted when all of the following can be demonstrated:

1. A synthetic submission succeeds in healthy mode.
2. The same client can encounter a deterministic HTTP 500.
3. The simulator can produce an HTTP 429 with `Retry-After`.
4. The simulator can produce a timeout.
5. The simulator can return a malformed HTTP 200 response.
6. The simulator can delay an otherwise valid acknowledgement.
7. It can fail a configurable number of attempts and then succeed.
8. Requests preserve `submissionId`, `correlationId`, and `idempotencyKey` according to the documented contract.
9. Duplicate requests using the same idempotency key can be identified via the `duplicate` field.
10. A reviewer can inspect the sequence of attempts after a test via `GET /control/history`.
11. Automated tests cover every failure mode.
12. Failure modes can be changed without redeployment.
13. Per-request overrides take precedence over global simulator mode.
14. Parallel automated tests do not depend on mutating shared global failure state.
15. Effective mode is visible in `effectiveMode` and `modeSource` response fields and in request history.
16. Control routes reject missing or invalid shared-secret credentials with HTTP 401.
17. Request history uses a bounded in-memory ring buffer with oldest-entry eviction.
18. State can be reset via `POST /control/reset` without restarting or redeploying.
19. The simulator runs successfully as a persistent Railway service.
20. No real VA data, credentials, or endpoints are required.
21. README documentation explains how another application connects to, controls, observes, and resets the simulator.
22. The application runs with a single Uvicorn worker and single Railway replica.
23. In-memory state mutations are concurrency-safe under async request handling.

## Required Tests

At minimum:

```text
healthy submission
500 response
429 + Retry-After
timeout
malformed 200 response
delayed success
fail-N-then-succeed (keyed by idempotencyKey)
idempotency-key reuse (duplicate field, downstreamReference reuse)
correlation-ID preservation
correlation-ID generation when absent
per-request override precedence
global-mode behavior
default-healthy behavior
parallel override isolation
control-route authentication (valid, missing, invalid secret)
history ring-buffer eviction
history reset
effective-mode recording (effectiveMode + modeSource)
modeSource accuracy (default vs global vs override)
simulator-marker presence
duplicate detection in history entries
```

Tests must be deterministic.

Automated tests must not rely on random failure generation.

Tests that mutate global simulator state must either restore it explicitly or
remain isolated from parallel test cases.

Tests shall use `pytest` with `httpx.AsyncClient` against the ASGI app
(in-process, no network, no port binding required).

## Out of Scope

Do not add these in WP-01:

- retry logic in the calling application
- application submission state machine
- production queue
- dead-letter handling
- user-facing recovery
- VA authentication
- PIV integration
- VA Design System integration
- production deployment architecture
- durable database-backed simulator history
- domain-specific VA business rules
- horizontal scaling or multi-worker deployment
- distributed state synchronization

These belong to later work packages or profiles.

## Architecture Review Checkpoint

Before WP-01 is considered complete, provide:

- final endpoint contracts
- failure-mode configuration model
- control-route authentication approach
- request-history model
- persistence decision confirmation (in-memory only, single process)
- test results
- one example trace showing intermittent failure followed by success
- one example showing per-request override taking precedence over global mode
- one example showing idempotency-key reuse with `duplicate: true`
- confirmation of single-worker / single-replica constraint
- any design decisions that constrain WP-02
- known limitations or deviations from this specification

## Implementation Evidence

- Commit(s):
- Test results:
- ADRs:
- Known deviations:
