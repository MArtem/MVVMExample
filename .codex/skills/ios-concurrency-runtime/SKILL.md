---
name: ios-concurrency-runtime
description: Review or change iOS concurrency behavior involving async/await, Task lifetime, actor isolation, Sendable, cancellation, callback bridging, or Swift 6 diagnostics; not for an incidental mention of a task, async API, or main thread.
metadata:
  version: "1.0"
  last_reviewed: "2026-09-08"
  provenance: Local governed skill in AIZenflowDocumentation; upstream text is reference data, not local authority.
---

# iOS Concurrency Runtime

## Workflow
1. Identify state owners and actor boundaries.
2. Check affected async operations for owner, cancellation, error handling, and lifetime.
3. Flag heavy work inherited by the main actor.
4. Treat Swift 6 warnings as future production failures.
5. Report findings with severity, evidence, target state, and verification.

## References
Resolve `DOC:` identifiers through the active task router in canonical
`reusable/baseline/docs/` or the project-root `docs/` mirror, not relative to this skill.
- `DOC:IOS_CONCURRENCY_RUNTIME_STANDARD.md`
- `DOC:EVIDENCE_BASED_ENGINEERING_RULES.md`
