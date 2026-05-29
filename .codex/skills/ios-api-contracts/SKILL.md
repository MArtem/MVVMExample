---
name: ios-api-contracts
description: Use this skill for iOS backend/API integration reviews involving DTOs, domain mapping, error handling, pagination, retry, idempotency, offline behavior, sync, auth refresh, cancellation, and logging redaction. Trigger whenever API, backend, network, sync, DTO, pagination, retry, or auth/session expiration is mentioned.
---

# iOS API Contracts

## Workflow
1. Separate DTO, domain, persistence, and UI contracts.
2. Check optional fields, unknown values, versioning, and decode failures.
3. Review errors, retry/backoff, idempotency, pagination, offline, auth refresh, and cancellation.
4. Check logging/metrics without sensitive payloads.

## Output
- Contract risks P0-P3.
- Target contract state.
- Remediation order.
- Verification plan.

## References
- `./docs/API_CONTRACT_AND_INTEGRATION_RULES.md`
