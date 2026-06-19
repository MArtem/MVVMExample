# iOS Concurrency Review Prompt

Use this for async/await, actors, tasks, cancellation, Sendable, callback bridging, and Swift 6 readiness.

## Prompt
Проведи production-grade iOS concurrency review.

Проверь:
- actor ownership and `@MainActor` boundaries;
- heavy work accidentally running on main actor;
- task lifecycle, cancellation, and owner lifetime;
- detached task justification;
- Sendable / Swift 6 warning risks;
- callback-to-async bridging;
- races between UI, persistence, networking, and background work.

For every finding provide severity, affected files, evidence, target state, remediation order, and verification.
