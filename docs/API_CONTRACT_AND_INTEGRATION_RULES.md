# API Contract And Integration Rules

## Purpose
Production rules for backend/API integration, DTOs, error mapping, retry, sync, and offline behavior.

## Required Checks
### DTO And Domain Boundaries
- DTO/backend shapes do not leak into UI rows.
- Mapping handles missing/unknown/extra fields.
- API versioning and compatibility are considered.

### Errors
- Transport, auth, validation, permission, rate-limit, server, timeout, and decode errors are distinct where behavior differs.
- User-facing messages are localized and actionable where practical.

### Retry And Idempotency
- Mutations consider duplicate submissions.
- Retry/backoff is bounded.
- Cancellation does not leave inconsistent local state.

### Pagination And Sync
- Cursor/page state is durable where needed.
- Refresh does not destroy valid local content on transient failure.
- Conflict policy is explicit.

### Offline
- Define whether existing local data remains visible.
- Define queue/outbox behavior for mutations where relevant.
- Define recovery after reconnect.

### Observability
- Log/report failures without sensitive payloads.
- Measure request latency and failure rates for critical endpoints.
