---
name: ios-concurrency-runtime
description: Use this skill for iOS concurrency/runtime reviews involving async/await, Task lifecycle, actor ownership, @MainActor boundaries, Sendable, cancellation, detached tasks, callback bridging, and Swift 6 readiness. Trigger whenever concurrency, tasks, async, actor, Sendable, main thread, or cancellation is mentioned.
---

# iOS Concurrency Runtime

## Workflow
1. Identify state owners and actor boundaries.
2. Check every async operation for owner, cancellation, error handling, and lifetime.
3. Flag heavy work inherited by the main actor.
4. Treat Swift 6 warnings as future production failures.
5. Report findings with severity, evidence, target state, and verification.

## References
- `./docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md`
- `./docs/EVIDENCE_BASED_ENGINEERING_RULES.md`
