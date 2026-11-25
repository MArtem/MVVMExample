# iOS Network Resilience Standard

## Purpose
Make API integrations reliable under mobile network conditions.

For retry/replay, transfers, pagination or realtime recovery, consult
`./docs/knowledge/global/ios/NETWORKING_WEB_AND_REALTIME_SYSTEMS.md` for the relevant
contract and failure paths; static review does not establish server behavior.

## Required Rules
- Define request timeout, cancellation, retry, backoff, idempotency, and offline behavior per endpoint class.
- Map transport, server, auth, decoding, validation, rate-limit, and cancellation errors separately.
- Never expose raw backend DTOs directly to UI if they can change independently of presentation needs.
- Token refresh and session expiration must be single-owner flows.
- Pagination must define ordering, duplication, refresh, and partial failure behavior.
- Upload/download flows define cancellation, owned temporary-file cleanup and failure semantics.
  Provide progress and retry only where the product and operation contract require them; progress
  is not exact without a trustworthy total, and replay must be safe and bounded.
- Logs must redact tokens, secrets, PII, and request bodies unless explicitly safe.

## Review Checklist
- What happens on airplane mode, timeout, 401, 403, 404, 409, 429, 5xx, malformed JSON?
- Is the operation idempotent?
- What does the UI show during partial success?
- Can concurrent requests race or duplicate side effects?
- Are retries bounded?

## Required Verification
- Choose evidence appropriate to the changed endpoint and current permissions.
  Test creation/execution and manual/offline runtime validation remain
  user-owned unless separately delegated; otherwise mark them not run and
  state the unverified failure-path risk.
- Select permitted evidence for error mapping and failure paths. Static inspection can establish
  source-level mapping, but does not prove runtime transport, server behavior or cancellation.
- For user-critical flows, perform manual/offline validation only when currently authorized; otherwise report it as not run and retain the associated risk.
