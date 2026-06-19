# iOS Network Resilience Standard

## Purpose
Make API integrations reliable under mobile network conditions.

## Required Rules
- Define request timeout, cancellation, retry, backoff, idempotency, and offline behavior per endpoint class.
- Map transport, server, auth, decoding, validation, rate-limit, and cancellation errors separately.
- Never expose raw backend DTOs directly to UI if they can change independently of presentation needs.
- Token refresh and session expiration must be single-owner flows.
- Pagination must define ordering, duplication, refresh, and partial failure behavior.
- Upload/download flows must support progress, cancellation, retry, and cleanup.
- Logs must redact tokens, secrets, PII, and request bodies unless explicitly safe.

## Review Checklist
- What happens on airplane mode, timeout, 401, 403, 404, 409, 429, 5xx, malformed JSON?
- Is the operation idempotent?
- What does the UI show during partial success?
- Can concurrent requests race or duplicate side effects?
- Are retries bounded?

## Required Verification
- Stubbed transport tests or equivalent static proof for error mapping.
- Manual/offline validation for user-critical flows.
