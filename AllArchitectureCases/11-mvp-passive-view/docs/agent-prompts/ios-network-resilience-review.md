# iOS Network Resilience Review Prompt

Use this for mobile API reliability, retries, cancellation, auth refresh, pagination, uploads/downloads, and offline behavior.

## Prompt
Проведи production-grade iOS network resilience review.

Проверь:
- timeout, retry, backoff, cancellation;
- idempotency and duplicate side effects;
- auth refresh/session expiration ownership;
- pagination and partial failure;
- upload/download progress, retry, cleanup;
- DTO/domain/UI boundaries;
- error taxonomy;
- logging redaction.

For every finding provide severity, affected files, evidence, target state, remediation order, and verification.
