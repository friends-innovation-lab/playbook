# WP-01 Implementation Plan

Version: v1.0
Status: Draft
Implements: docs/specs/WP-01-downstream-simulator.md (v2.0 Canonical)

## Architecture Decisions Carried Forward

```
WP01_TARGET_HOME=friends-innovation-lab/downstream-simulator
WP01_IMPLEMENTATION_RUNTIME=python_3_12_plus
WP01_FRAMEWORK=FastAPI
WP01_PROCESS_MODEL=persistent_http_service
WP01_STATE_MODEL=in_memory_stateful
WP01_MVP_WORKERS=1
WP01_MVP_REPLICAS=1
WP01_STATE_DISTRIBUTION=none
WP01_RAILWAY_TARGET=yes
WP01_REPO_PROVISIONING=explicit_shared_infrastructure_bootstrap
WP01_REPO_CREATED_BY_PROJECT_SPINUP=no
WP01_RAILWAY_PROVISIONING=explicit_shared_infrastructure_bootstrap
WP01_RAILWAY_CREATED_BY_PROJECT_SPINUP=no
WP01_PLAT01_BLOCKERS=none
WP01_INTERMITTENT_SEMANTICS=deterministic_fail_n_then_success
WP01_FAILED_ATTEMPTS_IDEMPOTENCY_CACHED=no
WP01_SUCCESS_IDEMPOTENCY_CACHED=yes
WP01_ADMIN_SECRET_COMPARE=hmac.compare_digest
WP01_RETRY_AFTER_SERVER_SLEEP=no
WP01_MODESOURCE_VALUES=default_global_override
WP01_MVP_KEY_REGISTRIES=unbounded_until_reset
WP01_STATE_SNAPSHOT_LOCKING=required
```

---

## 1. Repository Layout

```
downstream-simulator/
├── simulator/
│   ├── __init__.py          # Package marker, exports __version__
│   ├── app.py               # FastAPI application, route registration
│   ├── models.py            # Pydantic request/response models, enums
│   ├── state.py             # SimulatorState: config, history, registries
│   ├── modes.py             # Failure-mode dispatch and execution
│   └── auth.py              # Admin secret dependency (hmac.compare_digest)
├── tests/
│   ├── __init__.py
│   ├── conftest.py          # Shared fixtures: async client, state reset
│   ├── test_submission.py   # Healthy, error modes, malformed, delayed
│   ├── test_overrides.py    # Per-request overrides, precedence, isolation
│   ├── test_intermittent.py # Fail-N-then-succeed, counter keying
│   ├── test_idempotency.py  # Key reuse, duplicate field, ref reuse
│   ├── test_control.py      # Mode set/get, reset, history inspection
│   ├── test_auth.py         # Valid/missing/invalid secret, public routes
│   └── test_history.py      # Ring buffer eviction, ordering, reset
├── pyproject.toml           # Project metadata, dependencies, tool config
├── Makefile                 # run, test, lint, format shortcuts
├── Procfile                 # Railway entry point
├── .github/
│   └── workflows/
│       └── ci.yml           # GitHub Actions: lint + test
├── .gitignore
├── .env.example             # Documents required env vars (no values)
├── CLAUDE.md                # Claude Code instructions for this repo
└── README.md                # Usage, connection, control, reset docs
```

### Module Boundaries

| Module | Responsibility | Imports from |
|---|---|---|
| `app.py` | Route definitions, lifespan, FastAPI instance | `models`, `state`, `modes`, `auth` |
| `models.py` | Pydantic models, `SimulatorMode` enum, type contracts | stdlib only |
| `state.py` | `SimulatorState` class, lock, history deque, registries | `models` |
| `modes.py` | `execute_mode()` dispatch, delay/timeout/malformed logic | `models`, `state` |
| `auth.py` | `require_admin` FastAPI dependency | stdlib `hmac`, `os` |

No circular imports. Dependency flows one direction: `app` → `modes` → `state` → `models`.

---

## 2. Dependencies

### Runtime Dependencies

Verified releases as of 2026-08-13. Version policy ranges are independent
of the verified release and will not require updates when new patch versions
are published.

| Package | Purpose | Version Policy | Verified Release | Runtime/Dev |
|---|---|---|---|---|
| `fastapi` | ASGI framework, routing, validation, OpenAPI | `>=0.115,<1.0` | 0.139.2 | Runtime |
| `uvicorn[standard]` | ASGI server with uvloop and httptools | `>=0.30,<1.0` | 0.51.0 | Runtime |

FastAPI transitively provides `starlette` and `pydantic` (v2). Neither is
declared as a direct dependency unless a future need requires independent
pinning.

**Total runtime dependency count: 2** (plus their transitive trees).

### Dev Dependencies

| Package | Purpose | Version Policy | Verified Release | Runtime/Dev |
|---|---|---|---|---|
| `pytest` | Test runner | `>=8.0` | 9.1.1 | Dev |
| `pytest-asyncio` | Async test support for pytest | `>=0.23` | 1.4.0 | Dev |
| `httpx` | Async HTTP client with ASGI transport | `>=0.27` | 0.28.1 | Dev |
| `ruff` | Linter and formatter | `>=0.5` | 0.15.22 | Dev |

`httpx.ASGITransport` is in the core package; no extras required.

**Not included:**

- `mypy` — Omitted from MVP. Pydantic models and FastAPI type annotations
  provide runtime validation. Type checking can be added later if the
  codebase grows.
- `coverage` — Omitted from MVP. Test completeness is verified against the
  spec's required test list, not line coverage metrics.

---

## 3. Application Module Detail

### 3.1 models.py — Data Contracts

```python
# SimulatorMode enum
class SimulatorMode(str, Enum):
    HEALTHY = "healthy"
    HTTP_500 = "http_500"
    HTTP_429 = "http_429"
    TIMEOUT = "timeout"
    MALFORMED_RESPONSE = "malformed_response"
    DELAYED_SUCCESS = "delayed_success"
    INTERMITTENT_FAILURE = "intermittent_failure"

# ModeSource enum
class ModeSource(str, Enum):
    DEFAULT = "default"
    GLOBAL = "global"
    OVERRIDE = "override"

# Request model
class SubmissionRequest(BaseModel):
    submissionId: str
    correlationId: str | None = None
    idempotencyKey: str
    payload: dict = {}

# Global config model
class GlobalConfig(BaseModel):
    mode: SimulatorMode = SimulatorMode.HEALTHY
    delayMs: int = 0
    retryAfter: int = 0
    failCount: int = 0

# Success response model
class SubmissionResponse(BaseModel):
    simulator: bool = True
    status: str
    submissionId: str
    correlationId: str
    idempotencyKey: str
    downstreamReference: str
    effectiveMode: SimulatorMode
    modeSource: ModeSource
    duplicate: bool

# Error response model
class ErrorResponse(BaseModel):
    simulator: bool = True
    status: str
    submissionId: str
    correlationId: str
    idempotencyKey: str
    effectiveMode: SimulatorMode
    modeSource: ModeSource
    duplicate: bool

# Health response model
class HealthResponse(BaseModel):
    simulator: bool = True
    status: str = "healthy"
    currentMode: SimulatorMode
    version: str

# History entry model
class HistoryEntry(BaseModel):
    timestamp: str
    submissionId: str
    correlationId: str
    idempotencyKey: str
    globalModeAtTime: SimulatorMode
    requestOverrideMode: SimulatorMode | None = None
    effectiveMode: SimulatorMode
    modeSource: ModeSource
    attemptNumber: int
    httpStatus: int
    downstreamReference: str | None = None
    duplicate: bool

# Control mode request model
class SetModeRequest(BaseModel):
    mode: SimulatorMode
    delayMs: int | None = None
    retryAfter: int | None = None
    failCount: int | None = None
```

### 3.2 state.py — SimulatorState

Single instance, created at application startup. All mutable state lives here.

```python
class SimulatorState:
    def __init__(self, history_size: int = 1000):
        self._lock = asyncio.Lock()
        self.global_config = GlobalConfig()
        self.global_config_explicitly_set: bool = False    # tracks default vs global modeSource
        self.history: deque[HistoryEntry] = deque(maxlen=history_size)
        self.idempotency_cache: dict[str, str] = {}       # key -> downstreamReference
        self.attempt_counters: dict[str, int] = {}         # key -> attempt count
```

**Unbounded key registries (MVP limitation):**

Both `idempotency_cache` and `attempt_counters` are keyed by arbitrary
caller-supplied `idempotencyKey` values. Neither has a size limit. Both
grow with each unique key until `POST /control/reset` clears them.

This is an accepted single-instance test-service limitation. The simulator
is not a production service and is expected to be reset between test runs
or demonstrations. `POST /control/reset` clears both registries along with
history and global config.

Eviction semantics are intentionally not introduced in MVP because evicting
idempotency or intermittent-failure state mid-test would change deterministic
behavior and would require a spec-level decision.

**Lock protocol:**

The `_lock` provides a single synchronization boundary for all state
access that requires a consistent snapshot or compound mutation.

**Routes that acquire the lock:**

- `POST /submit` — acquires the lock around:
  1. Reading `idempotency_cache` to check for duplicates
  2. Reading/incrementing `attempt_counters` for intermittent failure
  3. Writing to `idempotency_cache` on success
  4. Appending to `history`
  5. **Releases the lock BEFORE any `asyncio.sleep()` for delay/timeout
     modes.** The sleep occurs outside the lock. After the sleep completes,
     the lock is re-acquired to write the idempotency cache entry and
     history entry for the result.

- `PUT /control/mode` — acquires the lock to update `global_config` and
  set the `global_config_explicitly_set` flag.

- `POST /control/reset` — acquires the lock to clear all state atomically.

- `GET /control/mode` — acquires the lock while obtaining a snapshot of
  the current global config.

- `GET /control/history` — acquires the lock while copying the history
  entries to return.

**Routes that do NOT acquire the lock:**

- `GET /health` — reads only `global_config.mode` for the `currentMode`
  field. This is an informational display, not a state-dependent decision.
  A momentarily stale value is acceptable for a health check.

**Reset behavior:**

```python
async def reset(self):
    async with self._lock:
        self.global_config = GlobalConfig()
        self.global_config_explicitly_set = False
        self.history.clear()
        self.idempotency_cache.clear()
        self.attempt_counters.clear()
```

### 3.3 modes.py — Failure Mode Dispatch

Single dispatch function called from the `/submit` route handler.

**Algorithm:**

```
execute_mode(effective_mode, effective_config, request, state) -> Response:

    1. Resolve effective config values:
       - delayMs:    override header OR global config OR 0
       - retryAfter: override header OR global config OR 0
       - failCount:  override header OR global config OR 0

    2. Check idempotency cache:
       - If idempotencyKey exists in cache:
         - Set duplicate = True
         - Set downstreamReference = cached value
         - Return success response (skip mode execution)
         - Record in history

    3. Dispatch on effective_mode:

       HEALTHY:
         - Generate downstreamReference (UUID4)
         - Store in idempotency cache
         - Return 200 with success response

       HTTP_500:
         - Increment attempt counter
         - Return 500 with error response (status="error")
         - Do NOT store in idempotency cache

       HTTP_429:
         - Increment attempt counter
         - Return 429 with error response (status="rate_limited")
         - Set Retry-After header to effective retryAfter value
         - Do NOT sleep
         - Do NOT store in idempotency cache

       TIMEOUT:
         - Increment attempt counter
         - Release state lock
         - await asyncio.sleep(effective delayMs / 1000)
         - Re-acquire state lock
         - Store in idempotency cache
         - Return 200 with success response
         - Note: caller is expected to have abandoned the connection

       MALFORMED_RESPONSE:
         - Return 200 with deliberately broken JSON:
           {"simulator": true, "status": "accepted", "garbage": true}
         - Missing required fields (no submissionId, no downstreamReference)
         - Do NOT store in idempotency cache

       DELAYED_SUCCESS:
         - Release state lock
         - await asyncio.sleep(effective delayMs / 1000)
         - Re-acquire state lock
         - Generate downstreamReference (UUID4)
         - Store in idempotency cache
         - Return 200 with success response

       INTERMITTENT_FAILURE:
         - Read/increment attempt counter for this idempotencyKey
         - If attempt_count <= effective failCount:
           - Return 500 with error response (status="intermittent_error")
           - Do NOT store in idempotency cache
         - Else:
           - Generate downstreamReference (UUID4)
           - Store in idempotency cache
           - Return 200 with success response

    4. Record history entry (all modes, all outcomes)
```

**Timeout vs delayed success — implementation distinction:**

Both use `asyncio.sleep()`. The only difference is the configured duration.
Timeout mode uses a duration intended to exceed the client's timeout. Delayed
success uses a shorter duration. The implementation is identical; the
distinction is in configuration and documentation.

If a caller disconnects during a timeout sleep, FastAPI/Starlette may raise
a disconnect exception. The implementation should catch this and still record
the history entry.

### 3.4 auth.py — Admin Authentication

```python
import hmac
import os
from fastapi import Header, HTTPException

_ADMIN_SECRET = os.environ.get("SIMULATOR_ADMIN_SECRET", "")

async def require_admin(
    x_admin_token: str = Header(alias="X-Admin-Token"),
) -> None:
    if not _ADMIN_SECRET:
        raise HTTPException(status_code=500, detail="Admin secret not configured")
    if not hmac.compare_digest(x_admin_token, _ADMIN_SECRET):
        raise HTTPException(status_code=401, detail="Unauthorized")
```

**Header name:** `X-Admin-Token`. Namespaced to avoid collision with
`X-Simulator-*` override headers.

**Secret not logged:** The dependency never logs, prints, or includes the
secret value in any response or error detail.

**Empty secret rejection:** If `SIMULATOR_ADMIN_SECRET` is empty or unset,
all control routes return 500. This prevents running without authentication.

### 3.5 app.py — Route Registration

```python
app = FastAPI(title="Downstream Simulator", version=__version__)
state = SimulatorState(history_size=int(os.environ.get("SIMULATOR_HISTORY_SIZE", "1000")))

# Public routes
@app.get("/health")           -> HealthResponse
@app.post("/submit")          -> SubmissionResponse | ErrorResponse

# Admin routes (require_admin dependency)
@app.put("/control/mode",     dependencies=[Depends(require_admin)])
@app.get("/control/mode",     dependencies=[Depends(require_admin)])
@app.post("/control/reset",   dependencies=[Depends(require_admin)])
@app.get("/control/history",  dependencies=[Depends(require_admin)])
```

**`/submit` handler algorithm:**

```
1. Parse and validate request body (Pydantic)
2. Generate correlationId if absent (uuid4)
3. Read override headers (X-Simulator-Mode, X-Simulator-Delay-Ms, etc.)
4. Resolve effective mode and source:
   - If X-Simulator-Mode header present and valid: mode=override value, source=override
   - Elif global_config_explicitly_set: mode=global config value, source=global
   - Else: mode=healthy, source=default
5. Acquire state lock
6. Check idempotency cache; check/increment attempt counters
7. If mode requires sleep (delayed_success, timeout):
   a. Release state lock
   b. await asyncio.sleep(delayMs / 1000)
   c. Re-acquire state lock
   d. Write idempotency cache entry (if success)
   e. Record history entry
   f. Release state lock
8. Else (non-sleeping modes):
   a. Execute mode logic
   b. Write idempotency cache entry (if success)
   c. Record history entry
   d. Release state lock
9. Emit structured JSON log
10. Return response
```

**Mode resolution detail for `modeSource`:**

`modeSource` describes which configuration source won, not whether its
value differs from another source.

- `"override"` — `X-Simulator-Mode` header was present and valid on the
  request, regardless of whether the override value matches the current
  global mode.
- `"global"` — no override header present, and global config has been
  explicitly set via `PUT /control/mode` (even if the operator set it
  to `healthy`).
- `"default"` — no override header present, and global config is at its
  startup default (no `PUT /control/mode` has been issued since startup
  or the last reset).

The `SimulatorState` tracks whether global config has been explicitly set
(a boolean flag, reset by `POST /control/reset`). This distinguishes
`source=global` from `source=default` even when the global mode value
is `healthy`.

---

## 4. Structured Logging

Use Python stdlib `logging` with a JSON formatter. No external logging
library required.

```python
import json
import logging

class JSONFormatter(logging.Formatter):
    def format(self, record):
        log_entry = {
            "timestamp": self.formatTime(record),
            "level": record.levelname,
            "message": record.getMessage(),
        }
        if hasattr(record, "request_data"):
            log_entry.update(record.request_data)
        return json.dumps(log_entry)
```

Attach to the root logger at startup. Configure handler to write to stdout.

Each `/submit` request logs via `logger.info()` with `request_data` extra
containing the fields specified in the canonical spec observability section.

Control route operations log mode changes and resets at `INFO` level.

The `SIMULATOR_ADMIN_SECRET` value must never appear in any log output.

---

## 5. Configuration and Environment

### Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `PORT` | No | `8000` | Listening port (Railway sets this) |
| `SIMULATOR_ADMIN_SECRET` | Yes | — | Shared secret for control routes |
| `SIMULATOR_HISTORY_SIZE` | No | `1000` | Ring buffer max entries |

### .env.example

```
PORT=8000
SIMULATOR_ADMIN_SECRET=
SIMULATOR_HISTORY_SIZE=1000
```

No actual secret values in the example file.

---

## 6. Health / Readiness

`GET /health` returns 200 immediately with:

```json
{
  "simulator": true,
  "status": "healthy",
  "currentMode": "healthy",
  "version": "0.1.0"
}
```

This is the readiness signal for Railway health checks. The health endpoint
does not require authentication.

The `currentMode` field reflects the current global mode setting, not
individual request outcomes.

---

## 7. Test Layout

### conftest.py — Shared Fixtures

```python
@pytest.fixture
def admin_secret(monkeypatch):
    monkeypatch.setenv("SIMULATOR_ADMIN_SECRET", "test-secret")

@pytest.fixture
async def client(admin_secret):
    from simulator.app import create_app
    app = create_app()
    transport = httpx.ASGITransport(app=app)
    async with httpx.AsyncClient(transport=transport, base_url="http://test") as c:
        yield c

@pytest.fixture
def admin_headers():
    return {"X-Admin-Token": "test-secret"}
```

**Application factory:** `create_app()` returns a fresh FastAPI instance
with fresh `SimulatorState` each time. This ensures test isolation — no
shared state leaks between test modules.

### Test File Mapping to Spec Requirements

| Test File | Spec Required Tests |
|---|---|
| `test_submission.py` | healthy submission, 500 response, 429 + Retry-After, timeout, malformed 200, delayed success, correlation-ID preservation, correlation-ID generation, simulator-marker presence |
| `test_overrides.py` | per-request override precedence, global-mode behavior, default-healthy behavior, parallel override isolation, modeSource accuracy |
| `test_intermittent.py` | fail-N-then-succeed, effective-mode recording |
| `test_idempotency.py` | idempotency-key reuse, duplicate detection in history |
| `test_control.py` | control-route authentication (delegated to test_auth.py), history reset |
| `test_auth.py` | control-route auth (valid, missing, invalid secret) |
| `test_history.py` | history ring-buffer eviction, history reset |

### Test Isolation Rules

- All tests use per-request overrides via `X-Simulator-*` headers.
- Tests that exercise global mode changes use a dedicated client fixture
  with fresh state, or explicitly reset state before/after.
- No test depends on execution ordering.
- All tests are deterministic. No random data generation for mode selection.

---

## 8. CI Workflow

### .github/workflows/ci.yml

```yaml
name: CI
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  lint-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install -e ".[dev]"
      - run: ruff check simulator/ tests/
      - run: ruff format --check simulator/ tests/
      - run: pytest --tb=short -q
```

Single job. No matrix (single Python version: 3.12). No Docker. No
database. No network services. Tests run entirely in-process via ASGI
transport.

---

## 9. Railway Deployment Configuration

### Procfile

```
web: uvicorn simulator.app:app --host 0.0.0.0 --port $PORT --workers 1
```

Explicit `--workers 1` enforces the single-instance state constraint.

### Railway Environment Variables

Set via Railway dashboard or CLI (never committed):

```
SIMULATOR_ADMIN_SECRET=<generated secret>
SIMULATOR_HISTORY_SIZE=1000
```

`PORT` is set automatically by Railway.

### Railway Health Check

Configure Railway health check to probe `GET /health` expecting HTTP 200.

### Railway Build

Railway auto-detects Python via `pyproject.toml`. No custom Dockerfile
needed for MVP. If Railway requires explicit build config:

```
[tool.railway]
# Railway detects Python automatically from pyproject.toml
```

Falls back to: `pip install .` then `Procfile` start command.

---

## 10. pyproject.toml Structure

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "downstream-simulator"
version = "0.1.0"
description = "Breakable downstream simulator for resilience testing"
requires-python = ">=3.12"
dependencies = [
    "fastapi>=0.115,<1.0",
    "uvicorn[standard]>=0.30,<1.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0",
    "pytest-asyncio>=0.23",
    "httpx>=0.27",
    "ruff>=0.5",
]

[tool.pytest.ini_options]
asyncio_mode = "auto"

[tool.ruff]
target-version = "py312"
line-length = 99

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B", "SIM"]
```

### Package Layout

Simple (non-src) layout. The `simulator/` directory is the package.

```
downstream-simulator/
├── simulator/
│   ├── __init__.py
│   └── ...
├── tests/
└── pyproject.toml
```

This is simpler than src-layout and sufficient for a standalone service
that will never be published to PyPI.

---

## 11. Repo Bootstrap Sequence

**These steps are NOT executed now. Each requires separate explicit approval.**

### Phase 1: GitHub Repo Creation (provider mutation — requires approval)

1. Create repo `friends-innovation-lab/downstream-simulator`
   - Visibility: per org policy (likely private for lab infrastructure)
   - No template — this is not a project-template consumer
   - Default branch: `main`
   - Do NOT use spinup automation

2. Clone locally to `~/Projects/downstream-simulator`

3. Initialize with:
   - `pyproject.toml`
   - `.gitignore` (Python standard)
   - `.env.example`
   - `Procfile`
   - `Makefile`
   - `CLAUDE.md`
   - `README.md` (stub)
   - `.github/workflows/ci.yml`
   - `simulator/__init__.py`

4. Push initial scaffold commit to `main`

5. Apply branch protection if org policy requires it

### Phase 2: Implementation (on feature branch, reviewed via PR)

See milestone/commit sequence below.

### Phase 3: Railway Deployment (provider mutation — requires approval)

1. Create Railway project for the lab (shared infrastructure)
2. Create service within the project
3. Connect GitHub repo for auto-deploy
4. Set environment variables:
   - `SIMULATOR_ADMIN_SECRET` — generated, never logged
   - `SIMULATOR_HISTORY_SIZE` — `1000`
   - `PORT` is set automatically by Railway
5. Verify health check at deployed URL
6. Run acceptance tests against deployed instance

---

## 12. Milestone / Commit Sequence

Implementation proceeds in this order. Each milestone is one logical commit.
No commit without explicit approval.

### M1: Project scaffold

Files: `pyproject.toml`, `.gitignore`, `.env.example`, `Procfile`,
`Makefile`, `CLAUDE.md`, `README.md` (stub), `.github/workflows/ci.yml`,
`simulator/__init__.py`

Verification: `pip install -e ".[dev]"` succeeds, `ruff check` passes,
`pytest` runs (0 tests collected).

### M2: Data models and state

Files: `simulator/models.py`, `simulator/state.py`

Verification: Models import cleanly, `SimulatorState` instantiates,
lock acquires/releases.

### M3: Auth dependency

Files: `simulator/auth.py`, `tests/test_auth.py`

Verification: Auth rejects missing/invalid secret, accepts valid secret,
returns 500 if env var unset.

### M4: Health endpoint and app skeleton

Files: `simulator/app.py` (health route only), `tests/conftest.py`

Verification: `GET /health` returns 200 with correct schema. Test client
fixture works.

### M5: Control routes

Files: `simulator/app.py` (control routes), `tests/test_control.py`

Verification: Set/get global mode, reset state, all require auth.

### M6: Submission endpoint — healthy mode

Files: `simulator/app.py` (submit route), `simulator/modes.py` (healthy
only), `tests/test_submission.py` (healthy tests)

Verification: Healthy submission returns correct response contract,
simulator marker present, correlationId generated when absent.

### M7: Error failure modes

Files: `simulator/modes.py` (http_500, http_429, malformed_response),
`tests/test_submission.py` (error mode tests)

Verification: 500 returns error response, 429 returns immediately with
Retry-After header (no server sleep), malformed returns broken JSON with
simulator marker.

### M8: Delay and timeout modes

Files: `simulator/modes.py` (delayed_success, timeout),
`tests/test_submission.py` (delay/timeout tests)

Verification: Delayed success sleeps then returns valid response, timeout
sleeps longer duration. Both record in history.

### M9: Intermittent failure mode

Files: `simulator/modes.py` (intermittent_failure),
`tests/test_intermittent.py`

Verification: Fail-N-then-succeed per idempotencyKey, counter increments,
success on attempt N+1, deterministic sequence.

### M10: Idempotency behavior

Files: `simulator/modes.py` (idempotency cache integration),
`tests/test_idempotency.py`

Verification: Duplicate detection, downstreamReference reuse, duplicate
field in response and history, failed attempts not cached, intermittent +
idempotency interaction correct.

### M11: Request history

Files: `simulator/state.py` (history inspection), `simulator/app.py`
(history endpoint), `tests/test_history.py`

Verification: Ring buffer eviction at configured max, newest-first
ordering, reset clears history, entries contain effectiveMode and
modeSource.

### M12: Per-request overrides and precedence

Files: `simulator/app.py` (override header parsing),
`tests/test_overrides.py`

Verification: Override > global > default precedence, modeSource accuracy,
parallel override isolation (concurrent tests with different overrides
do not interfere).

### M13: Structured logging

Files: `simulator/app.py` (JSON log formatter, request logging)

Verification: Log output is valid JSON, contains all spec-required fields,
does not contain payload data or secret values.

### M14: README and documentation

Files: `README.md` (complete usage documentation)

Verification: Documents connection, control, observation, reset workflows.
Includes examples for curl or httpx usage.

---

## 13. Contradictions Discovered in Canonical Spec

None.

The canonical spec is internally consistent. All implementation decisions
in this plan derive directly from the spec without contradiction.

---

## 14. WP-02 Constraints

The following design decisions in WP-01 constrain WP-02 (submission state,
retry, idempotency in the calling application):

1. **Idempotency key semantics:** The simulator treats `idempotencyKey` as
   the deduplication key. WP-02's retry logic must send the same
   `idempotencyKey` across retries of the same logical submission.

2. **Intermittent failure keying:** Counters are keyed by `idempotencyKey`.
   WP-02's retry logic will naturally exercise this because retries reuse
   the same key.

3. **No server-side retry:** The simulator never retries on behalf of the
   caller. WP-02 must implement its own retry strategy.

4. **History is ephemeral:** WP-02 cannot depend on simulator history
   surviving restarts. If durable trace inspection is needed, a persistence
   adapter would be added without changing the public contract.
