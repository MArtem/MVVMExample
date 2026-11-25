---
name: ios-api-contracts
description: "Use this skill for iOS API contract work: DTO/domain/persistence mapping, schema/version compatibility, decode failures, API error taxonomy, and request/response contract review. Trigger when the task reviews or changes a backend contract or mapping; add network-resilience or offline-sync only for those separate risks."
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
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:API_CONTRACT_AND_INTEGRATION_RULES.md`
